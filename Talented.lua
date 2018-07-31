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

function Talented:SavePvEBuild()
    local newBuild = {
        name = '',
        build = self.tools.GetActiveTalentString(),
        link = nil
    }
    self:OpenPvESavePanel(newBuild)
end

function Talented:SavePvPBuild(name)
    local newBuild = {
        name = name,
        build = self.tools.GetActivePvPTalentIDs(),
        link = nil
    }
    self:OpenPvPSavePanel(newBuild)
end

function Talented:CommitBuild(build, key)
    local specid = self.tools.GetActiveSpecInfo()
    local classTable = self.db.class
    classTable[specid] = classTable[specid] or { PvE = {}, PvP = {}}
    classTable[specid][key][build.name] = build
    self.ldb:Refresh()
end

function Talented:DeleteMatchingBuilds(key, build, comparator)
    local specid = self.tools.GetActiveSpecInfo()
    local specTable = self.db.class[specid]
    if not specTable or not specTable[key] then return end
    specTable = specTable[key]

    local buildsToRemove = {}

    for k,v in pairs(specTable) do
        if comparator(build, v.build) then
            tinsert(buildsToRemove, k)
        end
    end

    for _,k in ipairs(buildsToRemove) do
        self:Debug(("Removing %d"):format(
            specTable[k].name
        ))
        specTable[k] = nil
    end
    self.ldb:Refresh()
end

function Talented:GetActiveBuilds(key)
    local specid = self.tools.ActiveSpecID()
    -- if not self.db.class[specid] then return {} end
    -- if not self.db.class[specid][key] then return {} end
    local spectable = self.db.class[specid][key]

    local activeBuild, compare
    if key == "PvE" then
        activeBuild = self.tools.GetActiveTalentString()
        compare = self.tools.CompareTalentStrings
    elseif key == "PvP" then
        activeBuild = self.tools.GetActivePvPTalentIDs()
        compare = self.tools.ComparePvPTalentBuilds
    else
        return {}
    end

    local activeBuilds = {}
    for _,build in pairs(spectable) do
        if compare(build.build, activeBuild) then
            tinsert(activeBuilds, build)
        end
    end

    local icyBuild = Talented.IcyVeinsSpecs[tostring(specid)]
    if key == "PvE" and compare(icyBuild.build, activeBuild) then
        tinsert(activeBuilds, {
            name = "Icy Veins",
            build = icyBuild.build
        })
    end
    return activeBuilds
end

--@do-not-package@
    Talented.debug = true
--@end-do-not-package@

-- /tinspect C_SpecializationInfo has lots of PVP Talent stuff we need
-- LearnPvpTalent(spellId, slotNumber)
-- local { 3494, 161, 155, 3509 } = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
-- local selectedTalentForTier = GetTalentTierInfo(tier, 1)