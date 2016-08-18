-- Talented beta-1.1.1

local Talented = "|cff00e0ffTalented|r"
local Talented_UpdateInterval = 0.3;
local MaxTalentTier, PvpMaxTalentTier = 7,6
local TalentPool
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

--TODO: Add delete GUI for "All this char, all this class, all"
--TODO: Add button to use consumables to initiate spec changes
--TODO: Add location-based loading. Autoload "Dungeon" spec when entering dungeons, etc

function TalentedSaveActiveBuild(build_code,mode_key,build_name) -- mode_key will be "PvE" or "PvP" to set a bool
    local build = {}
    --TODO: Auto-fail zero string

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
    -- self is the button. This funciton was attached to the button's OnClick.
    -- self.value is the build code associated with the button.
    if InCombatLockdown() == true then
        print(Talented..": Can't save build while in combat.")
        return
    end

    --Show TalentedPopup and hand it self.value (build code)
    TalentedPopupButton.mode_key = mode_key
    TalentedPopupButton.build_code = self.value
    TalentedPopup:Show()
    --A frame will pop up. When the user clicks save, the OnClick handler
    --will fire TalentedSaveActiveBuild with EditBox and ignore-information
end



function TalentedCommitBuild(build)
    if TalentedDB == nil then TalentedDB = {} end
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



function TalentedIsAnActiveSpec(code,active)
    for i = 1, #active do
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

    if TalentPool then
        --OnLoad TalentedDB hasn't been loaded yet, meaning this is not entered at the start
        for i = 1,#TalentPool do
            info = TalentPool[i]

            if (info.mode == mode_key) then
                dat.text = info.build_name
                dat.value = info.code
                dat.arg1 = mode_key
                dat.func = TalentedSelectBuild --Change to SelectBuild after bug-fixing
                local active = (TalentedGetActiveBuild() == info.code)
                dat.checked = active
                UIDropDownMenu_AddButton(dat);
            end
        end
    end

    local blank = {}
    blank.disabled = 1
    blank.notCheckable = true
    UIDropDownMenu_AddButton(blank)

    --Add button to bottom to save currently-active build
    dat.text = "Save Active Build"
    dat.colorCode = "|cff00ff00"
    dat.value = TalentedGetActiveBuild()
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



--TODO: Create class-specific database for dropdown on load.
-- Advantages: Can set Dropdown text directly with a quick sift through the smaller database
-- Disadvantages: Adding/Deleting to two databases; long-term/short-term storage
--I would save as char-specific in .toc but I want to be able to
-- 1) Load all saved builds for a CLASS, not just 1 char
-- 2) Delete all for a spec, class, or the entire database

local init = CreateFrame("Frame")
init:RegisterEvent("ADDON_LOADED")
init:RegisterEvent("VARIABLES_LOADED")
init:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
local function TalentedLoad(self, event, ...)
    if event == "VARIABLES_LOADED" then
        TalentedCreateTierIgnoreButtons(TalentedPopupButton)
        TalentedUpdateTalentPool()
    elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
        TalentedUpdateTalentPool()
    elseif ... == "Blizzard_TalentUI" then
        CreateFrame("Frame","TalentedSavedBuildsDropdownPvE",_,"TalentedPvETemplate")
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

function TalentedPrepKeys(repo,mode_key)
    local maxKeysToShow

    if mode_key == "PvP" then maxKeysToShow = PvpMaxTalentTier elseif mode_key == "PvE" then maxKeysToShow = MaxTalentTier end

    for i = 1,#repo do
        repo[i]:Show()

        if i > maxKeysToShow then repo[i]:Hide() end
    end
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

