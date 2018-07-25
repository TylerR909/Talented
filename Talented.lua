local AddonName, Addon = ...

Talented = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function Talented:OnInitialize()
    self:InitOpts()
    -- local f = AceGUI:Create("Frame")
    -- f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    -- f:SetTitle("Talented")
    self:SeedUI()
    -- self:SaveActiveBuild()
end

function Talented:SaveActiveBuild()
    self:OpenSaveFrame(self:GenerateActiveBuild())
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

function Talented:GenerateActiveBuild()
    return {
        name = '',
        talents = self.tools.GetActiveTalentString(),
        pvpTalents = self.tools.GetActivePvpTalentIDs(),
        pvpTalentsEnabled = true
    }
end

--@do-not-package@
    Talented.debug = true
--@end-do-not-package@

-- /tinspect C_SpecializationInfo has lots of PVP Talent stuff we need
-- LearnPvpTalent(spellId, slotNumber)
-- local { 3494, 161, 155, 3509 } = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
-- local selectedTalentForTier = GetTalentTierInfo(tier, 1)