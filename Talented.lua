-- Talented 0.1 - Prototype

--[[ LOAD_PARAMETERS
Register when it opens
    When player opens talent menu and switches to player talents
        call initialize
    Interact with user
    Destroy Button on Exit
--]]

--TODO: How to delete builds?

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
    push new object to table
    print update? "name saved for future reference."
--]]



local function ApplyBuild(build)
    for i = 1, GetMaxTalentTier() do
        local s = build:sub(i,i)
        --TODO: error checking
        LearnTakents(GetTalentInfo(i,s,1))
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
