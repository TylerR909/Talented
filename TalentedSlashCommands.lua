local Talented = "|cff00e0ffTalented|r"
local isaPlayerClass


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
    end -- Collecting indices of objects to remove. Can't remove while going or #TalentedDB gets smaller while I head towards the first call

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



local function TalentedDeleteClass(class)
    class = class:match("^(%S*)%s*(.-)$");
    if not isaPlayerClass(class) then
        print(Talented..": '"..class.."' is not a valid class")
        return
    end

    print(Talented..": Deleting all saved builds for "..class.."s")

    local indices = {}
    for i = 1, #TalentedDB do
        if TalentedDB[i].class == class then tinsert(indices,i) end
    end

    local offset = 0
    for i = 1, #indices do
        tremove(TalentedDB,indices[i]-offset)
        offset = offset+1
    end
end



function TalentedDeleteActive()
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



local function TalentedDeleteTarget(target)
    local pname = GetUnitName("player")

    for i = 1, #TalentedDB do
        if TalentedDB[i].player_name == pname and
            TalentedDB[i].build_name == target then
            print(Talented..": Deleting build '|cffff0000"..target.."|r'")
            tremove(TalentedDB,i)
            return true
        end
    end

    print(Talented..": No match for '|cffff0000"..target.."|r'")
    return false
end



local function TalentedDelete(msg)
    local command, rest = msg:match("^(%S*)%s*(.-)$");

    if command == "all" then TalentedDB = nil
    elseif (command == "character" or command == "char") then
        if (rest == "") then TalentedDeleteChar(GetUnitName("player"))
        else TalentedDeleteChar(rest) end
    elseif (command == "class") then TalentedDeleteClass(rest)
    elseif (command == "active") then TalentedDeleteActive()
    elseif (command ~= "" and TalentedDeleteTarget(command)) then
    else
        print(Talented..": /tal del [active | all | character | class | [saved build name]]")
    end
    TalentedRefresh()
end



local function TalentedSlashShow(msg)
    local command = msg:match("^(%S*)%s*(.-)$");
    local current

    if command == "" or command == "all" then
        print(Talented..": Showing all saved builds by name...")

        for i = 1, #TalentedDB do
            current = TalentedDB[i]
            print(Talented..':',current.class,current.spec,current.build_name)
        end
    elseif isaPlayerClass(command) then
        print(Talented..": Showing all saved "..command.." builds...")

        local cmpto = string.lower(command)

        for i = 1, #TalentedDB do
            current = TalentedDB[i]

            if (string.lower(current.class) == cmpto) then
                print(Talented..':',current.class,current.spec,current.build_name,current.code)
            end
        end
    else
        print(Talented..": /tal show [all | [class]]")
    end

end




------------------------------------------------------------------------------
local function TalentedParse(msg)
    if TalentedDB == nil then do
        print(Talented..": No saved builds. Nothing to do.")
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
    elseif command == "show" or
            command == "display" or
            command == "print" then
                TalentedSlashShow(rest)
    --elseif command == "e" then TalentedPopup:Show()
    else print(Talented..": /tal [delete | show]")
    end
end

SLASH_TALENTED1= "/talented"
SLASH_TALENTED2 = "/tal"
SlashCmdList.TALENTED = function(msg)
    TalentedParse(msg)
end



----UTILITIES----
function isaPlayerClass(class) -- defined locally up top
    class = string.lower(class)
    if class == "warrior" then return true end
    if class == "paladin" then return true end
    if class == "hunter" then return true end
    if class == "rogue" then return true end
    if class == "priest" then return true end
    if class == "death" then return true end -- incoming string might not've captured the "knight"
        if class == "dk" then return true end
    if class == "shaman" then return true end
    if class == "mage" then return true end
    if class == "warlock" then return true end
    if class == "monk" then return true end
    if class == "druid" then return true end
    if class == "demon" then return true end
        if class == "dh" then return true end
    return false
end