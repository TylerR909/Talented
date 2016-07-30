-- Talented Beta Build B-0.1

--[[ LOAD_PARAMETERS
Register when it opens
    When player opens talent menu and switches to player talents
        call initialize
    Interact with user
    Destroy Button on Exit
--]]


--[[ INITIALIZE
    Load data into table?
    create dropdown frame/button
    lock frame to top left corner of talent frame
    drop date into table
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
