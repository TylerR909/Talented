local addonName, addon = ...

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject(addonName, {
    type = "data source",
    text = 'Talented'
})

function dataobj:RefreshText()
    local activePvEBuilds = Talented:GetActiveBuilds("PvE")
    local buildNamesString = nil
    -- If Build Names is Enabled
    if true then
        for _,build in ipairs(activePvEBuilds) do
            if buildNamesString == nil then
                buildNamesString = build.name
            else 
                buildNamesString = buildNamesString..', '..build.name
            end
        end
    end
    -- If Title is Enabled
    if true then 
        if buildNamesString then
            buildNamesString = "Talented: "..buildNamesString
        else 
            buildNamesString = "Talented"
        end
    end
    self.text = buildNamesString
end

function dataobj:UpdateIcon()
    self.icon = select(4, GetSpecializationInfo(GetSpecialization()))
end

function dataobj:Refresh()
    dataobj:UpdateIcon()
    dataobj:RefreshText()
end

function dataobj:OnClick(button)
    local shift = IsShiftKeyDown()
    local left = button == "LeftButton"
    local right = button == "RightButton"

    if not shift and left then
        Talented:InitPvEDropdown()
    elseif not shift and right then
        Talented:InitPvPDropdown()
    elseif shift and left then
        ToggleTalentFrame(2)
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_TALENT_UPDATE")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        f:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
    dataobj:Refresh()
end)

function dataobj:OnTooltipShow()
    self:AddLine("Talented")
    local tt = function(l, r)
        self:AddDoubleLine(l, r, 1,1,1, 0,1,0)
    end
    local addList = function(list, key)
        for i,b in ipairs(list) do
            if i == 1 then
                tt(key, b.name)
            else
                tt(" ", b.name)
            end
        end
    end
    addList(Talented:GetActiveBuilds("PvE"), "PvE")
    addList(Talented:GetActiveBuilds("PvP"), "PvP")
    self:AddLine(" ")
    tt("Left Click", "PvE Talents")
    tt("Right Click", "PvP Talents")
    tt("Shift + Left", "Open Talents")
end

Talented.ldb = dataobj
