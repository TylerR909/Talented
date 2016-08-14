-- Talented 0.1 - Prototype

local Talented = "|cff00e0ffTalented|r"
local Talented_UpdateInterval = 0.3; --1/4 of a second TODO: Play with this value until it "Feels" right, hopefully up to 0.5sec
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



function TalentedSaveActiveBuild(build_code,mode_key,build_name) -- mode_key will be "PvE" or "PvP" to set a bool
    --TODO: Parse build_name to make sure it's not too long, has bad data, etc
    local build = {}

    build.player_name = GetUnitName("player")
    local tmp,_,_ = UnitClass("player")
    build.class = tmp
    build.spec = GetSpecialization()
    build.mode = mode_key
    build.code = build_code
    build.build_name = build_name
    --TODO: The editbox would be the place to "Ignore" rows and sweep through the string to zero out values
    TalentedCommitBuild(build)
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
                print(Talented..": Build exists in table. Updating name to "..build.build_name)
                current.build_name = build.build_name
                return -- Item exists in table. Update data and do not commit.
                end
            elseif current.build_name == build.build_name then do
                print(Talented..": Build name already exists in table as "..current.build_name)
                current.code = build.code
                print(Talented..": Updating the build with new saved spec.")
                return -- Item exists in table. Update data and do not commit.
                end
            end
        end
    end

    --Checked the table and no existing code or build name exists. Commiting new table.
    tinsert(TalentedDB,build)
end



local function ApplyBuild(build,mode_key)
    if mode_key == "PvE" then mode_key = 1 elseif mode_key == "PvP" then mode_key = 2 end
    for i = 1, GetMaxTalentTier() do
        local s = build:sub(i,i)
        --TODO: error checking
        LearnTalents(GetTalentInfo(i,s,mode_key))
    end
end



function TalentedGetActiveBuild()
    local active_spec = ""

    for row = 1,GetMaxTalentTier() do
       for column = 1,3 do
           local _,_,_,active = GetTalentInfo(row,column,1)
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
        if (mode == "PvE") then value = TalentedGetActiveBuild() elseif (mode == "PvP") then value = nil end
        TalentedUpdateButtonText(self,value)
    end
    --TalentedSavedBuildsDropdownPvE
    --TalentedSavedBuildsDropdownPvP
end



function TalentedUpdateButtonText(self,build_code)
    print("Updating button text.")
    self.TimeSinceLastUpdate = 0;
    UIDropDownMenu_SetSelectedValue(self,build_code)
    --If I can figure out how to get through this, I can probably figure out how to centralize the Init
    --I think maybe the frame, or the things being passed with frame (arg1,arg2...) aren't being passed
    --and the UIDropDownMenu stuff uses those to function properly
end



function TalentedInitDropdownPvE(self)
    TalentedInitDropdown(self,"PvE")
end



function TalentedInitDropdownPvP(self)
    TalentedInitDropdown(self,"PvP")
end



function TalentedInitDropdown(self,mode_key)
    print(mode_key.." initializing.")
    local dat = {}
    local info

    if TalentedDB then
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

                if (active) then UIDropDownMenu_SetText(self,info.name) end
            end
        end
    end

    --Add button to bottom to save currently-active build
    dat.text = "Add Active Build"
    dat.colorCode = "|cff00ff00"
    dat.value = TalentedGetActiveBuild()
    dat.arg1 = mode_key
    dat.func = TalentedPrepActiveBuild
    dat.notCheckable = true
    dat.justifyH = "CENTER"
    --dat.icon = "Spell_chargepositive.png"
    UIDropDownMenu_AddButton(dat)
end



function TalentedSelectBuild(self,arg1)
    if InCombatLockdown() == 1 then
        print(Talented..": can't modify talents while in combat.")
        return
    end

    ApplyBuild(self.value,arg1)

    if arg1=="PvE" then
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvE,self.value) -- frame name and value to search for/set
    elseif arg1=="PvP" then
        TalentedUpdateButtonText(TalentedSavedBuildsDropdownPvP,self.value)
    end
end



function TalentedPrepActiveBuild(self,mode_key) --mode_key should be PvP or PvE
    if InCombatLockdown() == 1 then
        print(Talented..": can't save build while in combat.")
        return
    end

    --TODO InCombat blocking isn't working

    --Show TalentedPopup and hand it self.value (build code)
    TalentedPopup:Show()
    TalentedPopupButton.mode_key = mode_key
    TalentedPopupButton.build_code = self.value
    --A frame will pop up. When the user clicks save, the OnClick handler
    --will fire TalentedSaveActiveBuild with EditBox and Ignore-information
end



--[[ OnClick seems deprecated with this implementation, and as such these are no longer called or needed
function TalentedDropdownMenuButton_OnClickPvP()
end

function TalentedDropdownMenuButton_OnClickPvE(self,arg1,arg2,checked)
    print("Toggling...")
    print(self,arg1,arg2,checked) -- print arguments
    local name = self:GetName()
    ToggleDropDownMenu(1, nil, TalentedSavedBuildsDropdownPvE, name,0,0)
end
--]]