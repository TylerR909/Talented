local AddonName, Addon = ...

local defaultOptions = {}

function Talented:InitOpts()
    self.db = LibStub("AceDB-3.0"):New("TalentedDB", defaultOptions, true)
    self:InitSquelch()

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
    self:AddSquelch()
end

function Talented:AddSquelch()
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", self.Squelch)
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
