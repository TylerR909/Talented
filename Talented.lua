local AddonName, Addon = ...

Talented = LibStub("AceAddon-3.0"):NewAddon(AddonName, "AceEvent-3.0", "AceConsole-3.0")
local AceGUI = LibStub("AceGUI-3.0")

function Talented:Debug(msg)
    if self.debug then
        self:Print(msg)
    end
end

function Talented:OnInitialize()
    -- local f = AceGUI:Create("Frame")
    -- f:SetCallback("OnClose", function(widget) AceGUI:Release(widget) end)
    -- f:SetTitle("Talented")
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

function Talented:InitUI()
    self:Print("Initializing")
    self.InitRightClickSpecSwapButtons()
    self:Print("Initialized")
end

function Talented.InitRightClickSpecSwapButtons()
    local btnHeader = "PlayerTalentFrameSpecializationSpecButton"

    for i=1, GetNumSpecializations() do
        local btn = _G[btnHeader..i]
        btn:RegisterForClicks("LeftButtonUp","RightButtonUp")
        btn:HookScript("OnClick", function(self, button, down) 
            if button ~= "RightButton" then return end
            if i ~= GetSpecialization() then SetSpecialization(i) end
        end)
    end
end

--@do-not-package@
    Talented.debug = true
--@end-do-not-package@