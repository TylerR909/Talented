-- Talented v1.0.4

local Talented = "|cff00e0ffTalented|r"
local Talented_UpdateInterval = 0.3;
local MaxTalentTier, PvpMaxTalentTier = 7,6
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

    build.player_name = GetUnitName("player")
    local tmp,_,_ = UnitClass("player")
    build.class = tmp
    build.spec = GetSpecialization()
    build.mode = mode_key
    build.code = build_code
    build.build_name = build_name
    --TODO: The editbox would be the place to "Ignore" tiers and sweep through the string to zero out values
    TalentedCommitBuild(build)
    TalentedRefresh()
end



function TalentedPrepActiveBuild(self,mode_key) --mode_key should be PvP or PvE
    --self is the button. This funciton was attached to the button's OnClick.
    -- self.value is the build code associated with the button.
    if InCombatLockdown() == true then
        print(Talented..": Can't save build while in combat.")
        return
    end

    --Show TalentedPopup and hand it self.value (build code)
    TalentedPopup:Show()
    TalentedPopupButton.mode_key = mode_key
    TalentedPopupButton.build_code = self.value
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
    if mode_key == "PvE" then
        for i = 1, MaxTalentTier do
            local s = build:sub(i,i)
            --TODO: error checking
            LearnTalents(GetTalentInfo(i,s,1))
        end
    elseif mode_key == "PvP" then
        for i = 1, PvpMaxTalentTier do
            local s = build:sub(i,i)
            LearnPvpTalents(GetPvpTalentInfo(i,s,1))
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
    UIDropDownMenu_SetSelectedValue(self,build_code)
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

    if TalentedDB then
        --OnLoad TalentedDB hasn't been loaded yet, meaning this is not entered at the start
        for i = 1,#TalentedDB do
            info = TalentedDB[i]

            if (info.player_name == GetUnitName("player") and
                    info.class == UnitClass("player") and --Redundant unless there's another toon with a diff class on another server maybe
                    info.spec == GetSpecialization() and
                    info.mode == mode_key) then
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
local function TalentedLoad(self, event, ...)
    if ... == "Blizzard_TalentUI" then
        CreateFrame("Frame","TalentedSavedBuildsDropdownPvE",_,"TalentedPvETemplate")
        TalentedSavedBuildsDropdownPvE:Show()
        --PvP too
    end
end
init:SetScript("OnEvent", TalentedLoad)



function TalentedRefresh()
    --Inefficient but it works
    if TalentedSavedBuildsDropdownPvE then
        UIDropDownMenu_Initialize(TalentedSavedBuildsDropdownPvE,TalentedInitDropdownPvE)
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvE,TalentedGetActiveBuild())
        --PvP Too
    end
end
