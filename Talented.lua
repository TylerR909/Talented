-- Talented 0.1 - Prototype

local Talented = "|cff00e0ffTalented|r"
Talented_UpdateInterval = .3; --1/4 of a second TODO: Play with this value until it "Feels" right, hopefully up to 0.5sec

testInfo = {}
-- each save has a Build Name, Player Name, Class Name, Specialization, Build Code, Active State, PvE/PvP
testInfo[1] = {
    name = "Ones",
    class = "Warlock",
    spec = 3,
    code = "1111111",
    active = false,
    pname = "Imamagejk",
    PvE = true
}
testInfo[2] = {
    name = "Twos",
    class = "Warlock",
    spec = 3,
    code = "2222212",
    active = false,
    pname = "Imamagejk",
    PvE = true
}
testInfo[3] = {
    name = "Single-target",
    class = "Warlock",
    spec = 3,
    code = "2111113",
    active = true,
    pname = "Imamagejk",
    PvE = true
}
testInfo[4] = {
    name = "Questing",
    class = "Warlock",
    spec = 3,
    code = "3111113",
    active = false,
    pname = "Imamagejk",
    PvE = true
}
testInfo[5] = {
    name = "Dungeon AoE",
    class = "Warlock",
    spec = 3,
    code = "3212112",
    active = false,
    pname = "Imamagejk",
    PvE = true
}

--TODO: How to delete builds?
function testFrames()
    local btn = CreateFrame("Button","TestFrame",PlayerTalentFrameTalents,"UIPanelButtonTemplate")
    btn:SetWidth(100)
    btn:SetHeight(20)
    btn:SetPoint("BOTTOMRIGHT",0,-21)
    btn:SetScript("OnClick",function(self) self:Hide() print("I'm shy") end)
end

--[[ INITIALIZE
    Load data into table?
    create dropdown frame/button
    lock frame to top left corner of talent frame
    drop table data into dropdown frame
--]]


--[[ SAVE_ACTIVE_BUILD
    -- User clicked save button and that button called this function
    -- A full build has a Class, Specialization, Talent Pane # (Talents vs PvP Talents), Build Code (7 digit string), NAME, Active State?
    GetActiveBuild()
    get class
    get specialization
    get talent pane
    Prompt user for string name
    if cancel or nil, return/end
    if name already exists, --Overwrite/Deny/Handle--
    push new object to table print update? "name saved for future reference."
--]]

local function SaveActiveBuild(build_code,mode_key) -- mode_key will be "PvE" or "PvP" to set a bool
    local build = {}

    build.name = GetUnitName("player")
    local tmp,_,_ = UnitClass("player")
    build.class = tmp
    build.specialization = GetSpecialization()
    if mode_key == "PvE" then build.pve = true else build.pve = false end
    build.code = build_code
    build.active = true
    --Call the editbox and gather a build name
    --TODO: The editbox would be the place to "Ignore" rows and sweep through the string to zero out values
    TalentDB.insert(build)
end


local function ApplyBuild(build,mode_key)
    if mode_key == "PvE" then mode_key = 1 else if mode_key == "PvP" then mode_key = 2 end end
    for i = 1, GetMaxTalentTier() do
        local s = build:sub(i,i)
        --TODO: error checking
        LearnTalents(GetTalentInfo(i,s,mode_key))
    end
end


local function GetActiveBuild()
    local active_spec = ""

    for row = 1,GetMaxTalentTier() do
       for column = 1,3 do
           local _,_,_,active = GetTalentInfo(row,column,1)
           if active == true then active_spec = active_spec..column end
       end
    end

    return active_spec
end

function UpdateButtonText_OnUpdate(self,elapsed)
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;

    if (self.TimeSinceLastUpdate > Talented_UpdateInterval) then
        local value = GetActiveBuild();
        UIDropDownMenu_SetSelectedValue(self,value)

        self.TimeSinceLastUpdate = 0
    end
    --TalentedSavedBuildsDropdownPvE
    --TalentedSavedBuildsDropdownPvP
end

function UpdateButtonText(arg1)
end



function TalentedInitDropdownPvE(self,_,mode_key)
    mode_key = mode_key or "PvE"
    print("|cff00e0ffStarting|r PvE init...")
    print("Mode key = "..mode_key)

    local dat = {}
    local info

    for i = 1,#testInfo do
        info = testInfo[i]

        if (info.pname == GetUnitName("player") and
           info.class == UnitClass("player") and --Redundant unless there's another toon with a diff class on another server maybe
           info.spec == GetSpecialization()) then
                dat.text = info.name
                dat.value = info.code
                dat.arg1 = "PvE"
                dat.func = TalentedSelectBuild --Change to SelectBuild after bug-fixing
                local active = (GetActiveBuild() == info.code)
                dat.checked = active

                UIDropDownMenu_AddButton(dat);

                if (active) then UIDropDownMenu_SetText(self,info.name) end
        end
    end

    --Add button to bottom to save currently-active build
    dat.text = "Add Active Build"
    dat.colorCode = "|cff00ff00"
    dat.value = GetActiveBuild()
    dat.arg1 = "PvE"
    dat.func = TalentedSaveActiveBuild
    dat.notCheckable = true
    dat.justifyH = "CENTER"
    --dat.icon = "Spell_chargepositive.png"
    UIDropDownMenu_AddButton(dat)
end

function TalentedInitDropdownPvP(self,level)
    TalentedInitDropdownPvE(self,level,"PvP")
end

--[[ -PvP and -PvE wrapper functions should call this
-- can't figure out how to pass the frame in? PvE is working with source-code
-- when pasted in the wrapper, but when PvP acts as wrapped and calls the same code, it doesn't happen
-- I'd love to make this a local function but it may be too protected
function TalentedInitDropdown(self,_,mode_key)
    mode_key = mode_key or "PvE"
    print("Starting PvE init...")
    print("Mode key = "..mode_key)

    local dat = {}
    local info

    for i = 1,#testInfo do
        info = testInfo[i]

        if (info.pname == GetUnitName("player") and
                info.class == UnitClass("player") and --Redundant unless there's another toon with a diff class on another server maybe
                info.spec == GetSpecialization()) then
            dat.text = info.name
            dat.value = info.code
            dat.arg1 = "PvE"
            dat.func = TalentedSelectBuild --Change to SelectBuild after bug-fixing
            local active = (GetActiveBuild() == info.code)
            dat.checked = active

            UIDropDownMenu_AddButton(dat);

            if (info.checked == true) then
                UIDropDownMenu_SetSelectedName(self,info.name)
            end
        end
    end

    --Add button to bottom to save currently-active build
    dat.text = "Add Active Build"
    dat.colorCode = "|cff00ff00"
    dat.value = GetActiveBuild()
    dat.arg1 = "PvE"
    dat.func = TalentedSaveActiveBuild
    dat.notCheckable = true
    dat.justifyH = "CENTER"
    --dat.icon = "Spell_chargepositive.png"
    UIDropDownMenu_AddButton(dat)
end
--]]

function PrintTest(self)
    print("We did it!")
    print(self.value)
end

function TalentedSelectBuild(self,arg1)
    if InCombatLockdown() == 1 then
        print(Talented..": can't modify talents while in combat.")
        return
    end

    ApplyBuild(self.value,arg1)
    --UpdateButtonText(self.parent(),nil,arg1)
    UpdateButtonText(arg1)
end

function TalentedSaveActiveBuild(self,arg1)
    if InCombatLockdown() == 1 then
        print(Talented..": can't save build while in combat.")
        return
    end

    SaveActiveBuild(self.value,arg1)
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