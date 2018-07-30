local AddonName, Addon = ...

local defaultOptions = {}

function Talented:InitOpts()
    self.db = LibStub("AceDB-3.0"):New("TalentedDB", defaultOptions, true)

    -- GetNumSpecializations and GetSpecializationInfo don't return
    -- anything on initialization (num=0, info=nil), so we need to
    -- delay calling those until the player loads in
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        self:SeedDB()
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
