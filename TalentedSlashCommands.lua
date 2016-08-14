local Talented = "|cff00e0ffTalented|r"

local function TalentedDeleteChar(name)
    local deleted_something = false;
    local indices = {}

    if TalentedDB == nil then do
        print (Talented..": Database is empty. Nothing to delete!")
        return
        end
    end

    local current
    for i = 1,#TalentedDB do
        current = TalentedDB[i]
        if current.player_name == name then do
            deleted_something = true;
            tinsert(indices,i)
            end
        end
    end

    local offset = 0
    for i = 1,#indices do
        tremove(TalentedDB,indices[i]-offset)
        offset = offset+1
    end

    if deleted_something == false then do
        print(Talented..": Nothing deleted. Format is...")
        print(Talented..(": \"/talented delete character [Name]\" Leave [Name] blank for current character"))
        end
    end
end


local function TalentedDeleteSpec(spec)
    print(Talented..": Delete spec not yet implemented.")
    --TODO: Implement Delete Spec
end

local function TalentedDeleteActive()
    local active = TalentedGetActiveBuild()
    if TalentedDB == nil then return end

    local current
    for i = 1,#TalentedDB do
        current = TalentedDB[i]
        if current.code == active then
            print(Talented..": Deleting active build: "..current.build_name)
            tremove(TalentedDB,i)
            return true
        end
    end

    return false
end

local function TalentedDelete(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$");

    if command == "all" then TalentedDB = nil
    elseif (command == "character" or command == "char") then
        if (rest == "") then TalentedDeleteChar(GetUnitName("player"))
        else TalentedDeleteChar(rest) end
    elseif (command == "spec") then TalentedDeleteSpec(rest)
    elseif (command == "active") then TalentedDeleteActive()
    else
        print(Talented..": /tal delete [active | all | spec | character]")
    end
end

local function TalentedParse(msg,editbox)
    if TalentedDB == nil then do
        print(Talented..": Database is empty. Nothing to do.")
        return
        end
    end

    local command, rest = msg:match("^(%S*)%s*(.-)$");

    if command == "delete" or
        command == "del" or
        command == "rm" or
        command == "remove" or
        command == "clear" or
        command == "wipe" then
            TalentedDelete(rest)
    else print(Talented..": /tal [delete | remove | clear]")
    end
end

SLASH_TALENTED1= "/talented"
SLASH_TALENTED2 = "/tal"
SlashCmdList.TALENTED = function(msg)
    TalentedParse(msg)
end
