local AddonName, Addon = ...

Talented = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function Talented:OnInitialize()
    self:InitOpts()
    self:SeedUI()
end

function Talented:SeedUI()
    if IsAddOnLoaded("Blizzard_TalentUI") then 
        self:InitUI()
    else 
        self:RegisterEvent("ADDON_LOADED", function(event, ...) 
            if ... == "Blizzard_TalentUI" then 
                self:UnregisterEvent("ADDON_LOADED")
                self:InitUI()
            end
        end)
    end
end

function Talented:SavePvEBuild(name)
    local newBuild = {
        name = name,
        build = self.tools.GetActiveTalentString(),
        link = nil
    }
    self:CommitBuild(newBuild, "PvE")
end

function Talented:SavePvPBuild(name)
    local newBuild = {
        name = name,
        build = self.tools.GetActivePvPTalentIDs(),
        link = nil
    }
    self:CommitBuild(newBuild, "PvP")
end

function Talented:CommitBuild(build, key)
    local specid = self.tools.GetActiveSpecInfo()
    local classTable = self.db.class
    classTable[specid] = classTable[specid] or { PvE = {}, PvP = {}}
    classTable[specid][key][build.name] = build
end

--@do-not-package@
    Talented.debug = true
--@end-do-not-package@

-- /tinspect C_SpecializationInfo has lots of PVP Talent stuff we need
-- LearnPvpTalent(spellId, slotNumber)
-- local { 3494, 161, 155, 3509 } = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
-- local selectedTalentForTier = GetTalentTierInfo(tier, 1)