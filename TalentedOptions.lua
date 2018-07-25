local AddonName, Addon = ...

local defaultOptions = {}

function Talented:InitOpts()
    self.db = LibStub("AceDB-3.0"):New("TalentedDB", defaultOptions, true)
end
