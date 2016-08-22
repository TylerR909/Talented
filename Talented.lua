-- Talented release v1.2.0

local addonName, addonTable = ...
local Talented = "|cff00e0ffTalented|r"
local Talented_UpdateInterval = 0.3;
local MaxTalentTier, PvpMaxTalentTier = 7,6
local TalentPool, ldb
local Talented_ClassColors = {
    WARRIOR = "|cffc79c6e",
    PALADIN = "|cfff58cba",
    HUNTER = "|cffabd473",
    ROGUE = "|cfffff569",
    PRIEST = "|cffffffff",
    DEATHKNIGHT = "|cffc41f3b",
    SHAMAN = "|cff0070de",
    MAGE = "|cff69ccf0",
    WARLOCK = "|cff9482c9",
    MONK = "|cff00ff96",
    DRUID = "|cffff7d0a",
    DEMONHUNTER = "|cffa330c9"
}

local defaultops = {
    squelch = 1, --[0: No Squelch][1: When Talented swaps talents][2: Always]
    ldb = {
        title_on = true
    }
}


--TODO: Add delete GUI for "All this char, all this class, all"
--TODO: Add button to use consumables to initiate spec changes
--TODO: Add location-based loading. Autoload "Dungeon" spec when entering dungeons, etc
--TODO: Add player-leveled event and update player-specific (not class) builds to build.."0" to ignore next tier (keeps TalentedGetActiveBuild and #build the same length for TalentedIsAnActiveSpec)
--      Note: If Talented isn't running when player levels, code won't be updated. Save player level into db and when addon loads check for differences and update?
--TODO: 101121 and 111121 - No differentiation is made on DeleteActive. Delete calls GetActive then the first match on the table is deleted

function TalentedSaveActiveBuild(build_code,mode_key,build_name) -- mode_key will be "PvE" or "PvP" to set a bool
    local build = {}

    if TalentedIsZeros(build_code) then
        print(Talented..": Nothing to save if ignoring all tiers.")
        return
    end

    build.player_name = GetUnitName("player")
    local tmp,_,_ = UnitClass("player")
    build.class = tmp
    build.spec = GetSpecialization()
    build.mode = mode_key
    build.code = build_code
    build.build_name = build_name

    TalentedCommitBuild(build)
    TalentedRefresh()
end



function TalentedPrepActiveBuild(self,mode_key) --mode_key should be PvP or PvE
    -- self is the button. This function was attached to the button's OnClick.
    if InCombatLockdown() == true then
        print(Talented..": Can't save build while in combat.")
        return
    end

    --Show TalentedPopup and hand it self.value (build code)
    TalentedPopupButton.mode_key = mode_key
    TalentedPopup:Show()
    --A frame will pop up. When the user clicks save, the OnClick handler
    --will fire TalentedSaveActiveBuild with EditBox and ignore-information
end



function TalentedCommitBuild(build)
    if TalentedDB == nil then --noinspection GlobalCreationOutsideO
    TalentedDB = {} end
    local current

    for i = 1,#TalentedDB do
        current = TalentedDB[i]
        if current.player_name == build.player_name and
           current.spec == build.spec and
           current.mode == build.mode
        then
            if current.code == build.code and current.build_name == build.build_name then do
                print(Talented..": You've already saved that build.")
                return
                end
            elseif current.code == build.code then do
                print(Talented..": Build exists as "..current.build_name..". Updating name to "..build.build_name)
                current.build_name = build.build_name
                return -- Item exists in table. Update build order and do not commit.
                end
            elseif current.build_name == build.build_name then do
                print(Talented..": You've already saved that build as |cffff0000"..current.build_name.."|r. Updating to new name.")
                current.code = build.code
                return -- Item exists in table. Update name and do not commit.
                end
            end
        end
    end

    --Checked the table and no existing code or build name exists. Commiting new table.
    tinsert(TalentedDB,build)
end



local function ApplyBuild(build,mode_key)
    if build == nil or #build < 1 then return end

    if TalentedOptions.squelch ~= 0 then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM",TalentedSquelch) end

    if mode_key == "PvE" then
        for i = 1, #build do
            local s = build:sub(i,i)
            if s ~= "0" then LearnTalents(GetTalentInfo(i,s,1)) end
        end
    elseif mode_key == "PvP" then
        for i = 1, #build do
            local s = build:sub(i,i)
            if s ~= "0" then LearnPvpTalents(GetPvpTalentInfo(i,s,1)) end
        end
    end

    if TalentedOptions.squelch ~= 2 then
        C_Timer.After(1,function () ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM",TalentedSquelch) end) end
end



function TalentedGetActiveBuild()
    local active_spec = ""

    for tier = 1,MaxTalentTier do
       for column = 1,3 do
           local _,_,_,active = GetTalentInfo(tier,column,1)
           if active == true then active_spec = active_spec..column end
       end
    end

    return active_spec
end

function TalentedPvpGetActiveBuild()
    local active_spec = ""

    for tier = 1, PvpMaxTalentTier do
        for column = 1,3 do
            local _,_,_,active = GetPvpTalentInfo(tier,column,1)
            if active == true then active_spec = active_spec..column end
        end
    end

    return active_spec
end



function TalentedIsAnActiveSpec(code,active)
    if #code ~= #active then return false end

    for i = 1, #code do
        if code:sub(i,i) ~= "0" then
            if code:sub(i,i) ~= active:sub(i,i) then
                return false
            end
        end
    end
    return true
end



function TalentedUpdateButtonText_OnUpdate(self,elapsed,mode)
    --TODO: Add PvP Functionality. Update args list? So much branching...
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

    if (self.TimeSinceLastUpdate > Talented_UpdateInterval) then
        local value
        if (mode == "PvE") then
            value = TalentedGetActiveBuild()
        elseif (mode == "PvP") then
            value = nil
        end
        TalentedUpdateButtonText(self,value)
    end
    --TalentedSavedBuildsDropdownPvE
    --TalentedSavedBuildsDropdownPvP
end



function TalentedUpdateButtonText(self,build_code)
    self.TimeSinceLastUpdate = 0;

    local target
    --loop through TalentPool until we find an active spec
    --store TalentPool[i].build_name

    if TalentPool then
        for i = 1, #TalentPool do
            if TalentedIsAnActiveSpec(TalentPool[i].code,build_code) then
                target = TalentPool[i].build_name
            end
        end
    end

    UIDropDownMenu_SetSelectedName(self,target)
end



function TalentedInitDropdownPvE(self)
    TalentedInitDropdown(self,"PvE")
end



function TalentedInitDropdownPvP(self)
    TalentedInitDropdown(self,"PvP")
end



function TalentedInitDropdown(self,mode_key)
    local dat = {}
    local info
    local added_something = false;

    if TalentPool then
        --OnLoad TalentedDB hasn't been loaded yet, meaning this is not entered at the start
        for i = 1,#TalentPool do
            info = TalentPool[i]

            if (info.mode == mode_key) then
                dat.text = info.build_name
                dat.value = info.code
                dat.arg1 = mode_key
                dat.func = TalentedSelectBuild
                local active = (TalentedGetActiveBuild() == info.code)
                dat.checked = active
                UIDropDownMenu_AddButton(dat);
                added_something = true
            end
        end
    end

    if (added_something) then
        local blank = {}
        blank.disabled = 1
        blank.notCheckable = true
        UIDropDownMenu_AddButton(blank)
    end

    --Add button to bottom to save currently-active build
    dat.text = "Save Active Build"
    dat.colorCode = "|cff00ff00"
    dat.value = nil
    dat.arg1 = mode_key
    dat.func = TalentedPrepActiveBuild
    dat.notCheckable = true
    dat.justifyH = "CENTER"
    --dat.icon = "Spell_chargepositive.png"
    UIDropDownMenu_AddButton(dat)

    dat.text = "Delete Active Build"
    dat.colorCode = "|cffff0000"
    dat.value = nil
    dat.func = TalentedDeleteButton
    UIDropDownMenu_AddButton(dat)
end



function TalentedSelectBuild(self,arg1)
    if InCombatLockdown() == true then
        print(Talented..": Can't modify talents while in combat.")
        return
    end

    if (self.value == TalentedGetActiveBuild()) then return end

    ApplyBuild(self.value,arg1)

    if arg1=="PvE" then
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvE,self.value) -- frame name and value to search for/set
    elseif arg1=="PvP" then
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvP,self.value)
    end
end



function TalentedDeleteButton()
    TalentedDeleteActive()
    TalentedRefresh()
end





--[[  LOAD HANDLER AND RELATED FUNCTIONS   --]]

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:RegisterEvent("VARIABLES_LOADED")
init:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
local function TalentedLoad(self, event, ...)
    if event == "VARIABLES_LOADED" then
        TalentedOptions = TalentedOptions or defaultops
        TalentedCreateTierIgnoreButtons(TalentedPopupButton)
        TalentedLoadOptions()
        TalentedUpdateTalentPool()
        TalentedLoadLDB()
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        TalentedUpdateTalentPool()
    elseif ... == "Blizzard_TalentUI" then
        CreateFrame("Frame","TalentedSavedBuildsDropdownPvE", PlayerTalentFrameTalents,"TalentedPvETemplate")
        TalentedSavedBuildsDropdownPvE:Show()
        --PvP too
    end
end
init:SetScript("OnEvent", TalentedLoad)



function TalentedRefresh()
    --Inefficient but it works
    if TalentedSavedBuildsDropdownPvE then
        TalentedUpdateTalentPool()
        UIDropDownMenu_Initialize(TalentedSavedBuildsDropdownPvE,TalentedInitDropdownPvE)
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvE,TalentedGetActiveBuild())
        --PvP Too
    end
end



function TalentedUpdateTalentPool()
    TalentPool = {}

    local current

    for i = 1, #TalentedDB do
        current = TalentedDB[i]

        if current.player_name == GetUnitName("player") and
           current.class == UnitClass("player") and
           current.spec == GetSpecialization()
        then
            local temp = {}

            temp.spec = current.spec
            temp.build_name = current.build_name
            temp.code = current.code
            temp.mode = current.mode

            tinsert(TalentPool,temp)
        end
    end
end








--[[     LDB Loader & Functions              --]]

function TalentedLoadLDB()
    --TODO: Clean up library in files and update .toc to auto-include libraries from Curse
    local f = CreateFrame("frame","TalentedLDB")
    local update_interval, elapsed = 1.5,0
    local dropdown, buttons

    ldb = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Talented", {
        type = "launcher",
        icon = "Interface\\Icons\\Ability_marksmanship",
        text = "Talented",
        OnClick = function(p, button)
            if not dropdown then dropdown = TalentedLDBDropdown(p) end

            if InCombatLockdown() then dropdown:Hide(); return end

            if button == "RightButton" then ToggleTalentFrame(); dropdown:Hide(); return end

            if dropdown:IsVisible() then dropdown:Hide()
            else dropdown:Show(); GameTooltip:Hide() end
        end,
    })

    f:SetScript("OnUpdate", function(self,elap)
        elapsed = elapsed + elap
        if elapsed < update_interval then return end

        elapsed = 0

        local t = ""
        if (TalentedOptions.ldb.title_on) then t = Talented..": " end
        t = t..ldb.TalentedLDBUpdate()
        ldb.text = t
    end)

    function ldb:OnTooltipShow()
        self:AddLine(Talented)
        self:AddLine("Your currently-active build is saved as: |cff00ff00"..ldb.TalentedLDBUpdate(),1,1,1,true)
    end

    function ldb:OnEnter()
        --if dropdown:IsVisible() then GameTooltip:Hide(); return end

        GameTooltip:SetOwner(self,"ANCHOR_NONE")
        GameTooltip:SetPoint("TOPLEFT",self,"BOTTOMLEFT")
        GameTooltip:ClearLines()
        ldb.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    end

    function ldb:OnLeave()
        GameTooltip:Hide()
    end

    function ldb:TalentedLDBUpdate()
        local active = TalentedGetActiveBuild()

        for i = 1, #TalentPool do
            if TalentedIsAnActiveSpec(TalentPool[i].code,active) then
                return TalentPool[i].build_name
            end
        end

        return "Custom"
    end

    function TalentedLDBDropdown(p)
        GameTooltip:Hide()
        GameTooltip:ClearLines()

        local d = CreateFrame("Frame","TalentedLDBDropdown_",UIParent,"InsetFrameTemplate2")
        --OptionsBoxTemplate
        --GlowBoxTemplate
        --if d:IsShown() then d:Hide(); return end
        d:ClearAllPoints()
        d:SetPoint("TOP",p,"BOTTOM")
        d:SetFrameStrata("DIALOG")
        d:SetWidth(125)
        d:SetClampedToScreen(true)

        d.texture = d:CreateTexture(nil,"BACKGROUND")
        --d.texture:SetColorTexture(0,0,0,0.8)
        d.texture:SetAllPoints(d)

        d:SetScript("OnLeave", function() d:Hide() end)
        d:SetScript("OnShow", function() TalentedLDBPopulateDropdown(d) end)

        d:Hide()

        return d
    end

    function TalentedLDBPopulateDropdown(d)
        if #TalentPool < 1 then d:Hide(); return end

        if buttons and #buttons > 0 then
            for i=1,#buttons do
                buttons[i]:Hide()
            end
        end

        buttons = {}
        local button_height = 30

        for i = 1, #TalentPool do
            local b = CreateFrame("Button","TalentedLDBButton"..i,d)
            b:SetHeight(button_height)
            b:SetWidth(d:GetWidth()-8)
            b:SetNormalFontObject("GameFontNormalSmall")
            b:SetHighlightFontObject("GameFontHighlightSmall")
            b:SetText(TalentPool[i].build_name)
            b:SetFrameStrata("HIGH")

                --NORMAL
            local norm = b:CreateTexture()
            norm:SetAllPoints(b)
            if i % 2 ~= 0  then norm:SetColorTexture(0,0,0,0.7)
                           else norm:SetColorTexture(0.1,0.1,0.1,0.9) end
            b:SetNormalTexture(norm,"DISABLE")
                --PUSHED
            local pushed = b:CreateTexture()
            pushed:SetColorTexture(0,0.5,0.5,0.8)
            pushed:SetAllPoints(true)
            b:SetPushedTexture(pushed)
                --HIGHLIGHT
            local highlight = b:CreateTexture()
            highlight:SetColorTexture(0,1,1,0.8)
            highlight:SetAllPoints(true)
            b:SetHighlightTexture(highlight,"MOD")
            --[[
            --]]

            if i == 1 then b:SetPoint("TOP",d,"TOP",0,-4)
            else b:SetPoint("TOP",buttons[i-1],"BOTTOM",0,0) end

            b:SetScript("OnClick",function() ApplyBuild(TalentPool[i].code,"PvE"); d:Hide() end)

            buttons[i] = b
        end

        d:SetHeight((#buttons * button_height)+8)
    end
end







--[[       Talented Options Loader         --]]
function TalentedLoadOptions()
    if TalentedOptions.squelch == 2 then ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM",TalentedSquelch) end

    TalentedOptions.pane = CreateFrame("Frame",nil,InterfaceOptionsFramePanelContainer)
    local p = TalentedOptions.pane
    p:Hide()

    p:SetAllPoints()

    p.name = Talented
    p.okay = function(self) end
    p.cancel = function(self) end
    p.default = function(self) TalentedOptions = defaultops end

    local title = p:CreateFontString(nil,"ARTWORK","GameFontNormalLarge")
    --title:Hide()
    title:SetText("Talented")
    title:SetJustifyH("LEFT")
    title:SetJustifyV("TOP")
    title:SetPoint("TOPLEFT",16,-16)


    --Squelch Dropdown
    local squelch_label = p:CreateFontString(nil,"ARTWORK","GameFontHighlightSmall")
    squelch_label:SetPoint("TOPLEFT",p,"TOPLEFT",16,-50)
    squelch_label:SetText("When should "..Talented.." silence Talent-chat-spam?")

    local dropdown = CreateFrame("Frame","TalentedSquelchSettings",p,"UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT",squelch_label,"BOTTOMLEFT",0,-10)
    dropdown.initialize = function(d)
        local squelch_settings = {"Never","Talented only","Always" }
        for i = 1, #squelch_settings do
            local b = UIDropDownMenu_CreateInfo()
            b.text = squelch_settings[i]
            b.value = i-1
            b.func = function(self)
                TalentedOptions.squelch = self.value
                UIDropDownMenu_SetSelectedValue(d,self.value)
                TalentedSquelchUpdate()
            end
            UIDropDownMenu_AddButton(b)
        end
        UIDropDownMenu_SetSelectedValue(d,TalentedOptions.squelch)
    end
    dropdown:HookScript("OnShow",dropdown.initialize)



    --LDB Title
    local ldb_title = CreateFrame("CheckButton","TalentedLDBTitleOption",p,"InterfaceOptionsCheckButtonTemplate")
    ldb_title:SetPoint("TOPLEFT",dropdown,"BOTTOMLEFT",0,-25)
    getglobal(ldb_title:GetName().."Text"):SetText("Title in LDB Plugin")
    ldb_title.tooltipText = "Enable the "..Talented.." title in the LDB Broker display."
    ldb_title:SetScript("OnClick", function(self)
        --Button switches state THEN this is run
        if self:GetChecked() then
            TalentedOptions.ldb.title_on = true
        else
            TalentedOptions.ldb.title_on = false
        end
    end)
    ldb_title:SetScript("OnShow", function(self) self:SetChecked(TalentedOptions.ldb.title_on) end)

    InterfaceOptions_AddCategory(TalentedOptions.pane)
end



--[[  TIER FUNCTIONS AND UTILITIES   --]]

function TalentedCreateTierIgnoreButtons(bin)
    bin.ignoreKeys = {}

    for i = 1, math.max(PvpMaxTalentTier,MaxTalentTier) do
        local btn = CreateFrame("Button","TalentedTier"..i.."IgnoreButton",bin:GetParent(),"TalentedIgnoreTierTemplate")
        bin.ignoreKeys[i] = btn

        btn:SetText("Tier "..i)
        if i ~= 1 then btn:SetPoint("TOP",bin.ignoreKeys[i-1],"BOTTOM",0,-5) end
        btn:Show()
    end
end

function TalentedPrepKeys(repo,build_code)
    local maxKeysToShow = #build_code

    for i = 1,#repo do
        repo[i]:Show()

        if i > maxKeysToShow then repo[i]:Hide() end
    end

    if maxKeysToShow == 0 then TalentedPopup:SetHeight(105)
    else TalentedPopup:SetHeight(125 + (maxKeysToShow * 25)) end
end

function TalentedProcessIgnoreKeys(repo)
    local ignoreCode = ""

    local numShown = 0

    for i = 1, #repo do if repo[i]:IsShown() then numShown = numShown + 1 end end

    for i = 1, numShown do
        if repo[i].selected then ignoreCode = ignoreCode.."0"
            else ignoreCode = ignoreCode.."1"
        end
    end

    return ignoreCode
end

function TalentedIgnoreSmush(build,ignore)
    local rval = ""

    for i = 1,strlen(build) do
        if ignore:sub(i,i) == "1" then rval = rval.."0"
          else rval = rval..build:sub(i,i) end
    end

    return rval
end

function TalentedIsZeros(code)
    if code == nil then return true end

    for i = 1, #code do
        if code:sub(i,i) ~= "0" then return false end
    end

    return true
end

function TalentedSquelch(self, event, msg,...)
    if msg:find("You have unlearned") then
        return true
    end
    if msg:find("You have learned") then
        return true
    end

    return false
end

function TalentedSquelchUpdate()
    local op = TalentedOptions.squelch

    if op == 0 then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM",TalentedSquelch)
    elseif op == 2 or op == 1 then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM",TalentedSquelch)
    end
end
