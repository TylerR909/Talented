local AddonName, Addon = ...

local defaultOptions = {
    global = {
        config = {
            ldb = {
                title = true,
                build = true
            },
            squelch = 1, -- 0: Never, 1: When Talented Switches Talents, 2: Always
            hidePvPButton = false,
            disableSpellPush = true,
            debug = false
        },
        v2seen = false
    },
}

local orderNum = 0;
local function order()
    orderNum = orderNum + 1;
    return orderNum
end

local optionsTable = {
    name = "Talented",
    handler = Talented,
    type = 'group',
    args = {
        LDBHeader = {
            name = "LDB Plugin",
            order = order(),
            type = "header"
        },
        LDBTitle = {
            name = "Title",
            order = order(),
            type = "toggle",
            set = function(_,val)
                Talented.db.global.config.ldb.title = val 
                Talented.ldb:Refresh()
            end,
            get = function() return Talented.db.global.config.ldb.title end,
        },
        LDBBuild = {
            name = "Build",
            order = order(),
            type = "toggle",
            set = function(_,val) 
                Talented.db.global.config.ldb.build = val
                Talented.ldb:Refresh()
            end,
            get = function() return Talented.db.global.config.ldb.build end,
        },
        OtherHeader = {
            name = "Other",
            order = order(),
            type = "header"
        },
        Squelch = {
            name = "Squelch",
            desc = "Control when Talented should silence Learned/Unlearned system messages",
            order = order(),
            width = 1.5,
            type = "select",
            values = {
                [0] = "Never",
                [1] = "When Talented Changes Talents",
                [2] = "Always"
            },
            set = function(_, val) 
                Talented:Debug(val)
                Talented.db.global.config.squelch = val
                Talented:InitSquelch()
            end,
            get = function() return Talented.db.global.config.squelch end
        },
        HidePvPButton = {
            name = "Hide PvP Button",
            desc = "Renders the PvP Button on the Talents Frame",
            order = order(),
            type = "toggle",
            get = function() return Talented.db.global.config.hidePvPButton end,
            set = function(_,val)
                if val then
                    Talented.PvPTab:Hide()
                else
                    Talented.PvPTab:Show()
                end
                Talented.db.global.config.hidePvPButton = val
            end
        },
        SpellPushActionbar = {
            name = "Stop New Spells on Actionbars",
            desc = "Stops new spells from pushing themselves to the actionbars",
            order = order(),
            type = "toggle",
            get = function() return Talented.db.global.config.disableSpellPush end,
            set = function(_, val) 
                Talented.db.global.config.disableSpellPush = val
                Talented.tools.SetSpellPushDisabled(val)
            end
        },
        Debug = {
            name = "debug",
            hidden = true,
            order = order(),
            type = "toggle",
            get = function() return Talented.debug end,
            set = function(_, val) 
                Talented.debug = val 
                Talented.db.global.config.debug = val
            end
        }
    }
}

function Talented:OpenOptionsFrame(input)
    if not input or input:trim() == "" then
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
        InterfaceOptionsFrame_OpenToCategory(self.optionsFrame)
    else
        LibStub("AceConfigCmd-3.0"):HandleCommand("talented", AddonName, input)
    end
end

function Talented:InitOpts()
    LibStub("AceConfig-3.0"):RegisterOptionsTable(AddonName, optionsTable)
    self.db = LibStub("AceDB-3.0"):New("TalentedDB", defaultOptions, true)
    self.optionsFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddonName, "Talented", nil)
    self:RegisterChatCommand("talented", "OpenOptionsFrame")
    self:InitSquelch()
    self.tools.SetSpellPushDisabled(self.db.global.config.disableSpellPush)
    self.debug = self.db.global.config.debug

    -- GetNumSpecializations and GetSpecializationInfo don't return
    -- anything on initialization (num=0, info=nil), so we need to
    -- delay calling those until the player loads in
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:SeedDB()
        Talented.ldb:Refresh()
    end)
end

function Talented:SeedDB()
    local classDB = self.db.class
    for i=1, GetNumSpecializations(), 1 do
        local specid = GetSpecializationInfo(i)
        classDB[specid] = classDB[specid] or {
            PvE = {},
            PvP = {}
        }
    end
end

function Talented:InitSquelch()
    self:RemoveSquelch()
    local squelchLevel = self.db.global.config.squelch
    if squelchLevel > 1 then self:AddSquelch() end
end

function Talented:AddSquelch()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.Squelch)
end

function Talented:RemoveSquelchDelayed()
    C_Timer.After(1, function() self:RemoveSquelch() end)
end

function Talented:RemoveSquelch()
    ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self.Squelch)
end

local token = ".+"
local unlearned = ERR_SPELL_UNLEARNED_S:format(token)
local spell = ERR_LEARN_SPELL_S:format(token)
local ability = ERR_LEARN_ABILITY_S:format(token)
local passive = ERR_LEARN_PASSIVE_S:format(token)
function Talented.Squelch(self, event, msg, ...)
    if string.match(msg, unlearned) 
        or string.match(msg, spell)
        or string.match(msg, ability)
        or string.match(msg, passive)
    then
        return true
    end

    return false
end
