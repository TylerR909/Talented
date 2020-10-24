local AceGUI = LibStub("AceGUI-3.0")

function Talented:InitUI()
    self:Debug("Initializing")
    self.InitRightClickSpecSwapButtons()
    self:MakeButtonTabs()
    self:Debug("Initialized")
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

function Talented:MakeButtonTabs()
    local pve = CreateFrame("Button",nil,PlayerTalentFrameTalents,"SpellBookSkillLineTabTemplate")
    pve:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 0, -35)
    Talented.PvETexture = "Interface\\Icons\\INV_Helmet_08"
    pve:SetNormalTexture(Talented.PvETexture)
    pve:SetScript("OnClick", function(btn)
        self:InitPvEDropdown()
    end)
    pve.tooltip = "PVE Builds"
    pve:Show()
    self.PvETab = pve

    local pvp = CreateFrame("Button",nil,pve,"SpellBookSkillLineTabTemplate")
    pvp:SetPoint("TOPLEFT", pve, "BOTTOMLEFT", 0, -22)
    -- For ElvUI AddOnSkins plugin
    Talented.PvPTexture = "Interface\\Icons\\achievement_bg_winwsg" 
    pvp:SetNormalTexture(Talented.PvPTexture)
    pvp:SetScript("OnClick", function(btn)
        self:InitPvPDropdown()
    end)
    pvp.tooltip = "PVP Builds"
    pvp:Show()
    self.PvPTab = pvp

    if self.db.global.config.hidePvPButton then
        self.PvPTab:Hide()
    end
end

function Talented:InitPvEDropdown()
    GameTooltip:Hide()
    local specid = self.tools.ActiveSpecID()
    local activeBuild = self.tools.GetActiveTalentString()
    local compare = self.tools.CompareTalentStrings
    local menu = {
        { text=TALENTS, isTitle=true, notCheckable=true}
    }

    for _,build in pairs(self.db.class[specid].PvE) do
        local btn = {
            text = build.name,
            value = build.build,
            checked = compare(build.build, activeBuild),
            func = function(btn) self.tools.LearnTalentString(btn.value) end
        }
        tinsert(menu, btn)
    end

    tinsert(menu, {text='', isTitle=true, notCheckable=true})

    -- Save Button
    tinsert(menu, {
        text=SAVE,
        colorCode="|cff00ff00",
        func = function() self:SavePvEBuild(GetServerTime()) end,
        notCheckable=true
    })

    -- Delete Button
    tinsert(menu, {
        text=DELETE,
        colorCode="|cffff0000",
        func = function() self:DeleteMatchingBuilds("PvE", activeBuild, compare) end,
        notCheckable=true
    })

    Talented.PvEDropdown = Talented.PvEDropdown or CreateFrame("Frame", "TalentedPvEDropdown", Talented.PvETab, "UIDropDownMenuTemplate")
    local menuFrame = Talented.PvEDropdown
    menuFrame:ClearAllPoints()
    menuFrame:SetPoint("TOPLEFT", Talented.PvETab,"TOPRIGHT")
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU", 1)
end

function Talented:InitPvPDropdown()
    GameTooltip:Hide()
    local specid = self.tools.ActiveSpecID()
    local activeBuild = self.tools.GetActivePvPTalentIDs()
    local compare = self.tools.ComparePvPTalentBuilds
    local menu = {
        { text = PVP..' '..TALENTS, isTitle=true, notCheckable=true}
    }

    for _,build in pairs(self.db.class[specid].PvP) do
        local btn = {
            text = build.name,
            value = build.build,
            checked = compare(build.build, activeBuild),
            func = function(btn) self.tools.LearnPvPTalentGroup(btn.value) end
        }
        tinsert(menu, btn)
    end

    tinsert(menu, {text='', isTitle=true, notCheckable=true})

    -- Save Button
    tinsert(menu, {
        text=SAVE,
        colorCode="|cff00ff00",
        func = function() self:SavePvPBuild(GetServerTime()) end,
        notCheckable=true
    })

    -- Delete Button
    tinsert(menu, {
        text=DELETE,
        colorCode="|cffff0000",
        func = function() self:DeleteMatchingBuilds("PvP", activeBuild, compare) end,
        notCheckable=true
    })

    tinsert(menu, saveBtn)

    Talented.PvPDropdown = Talented.PvPDropdown or CreateFrame("Frame", "TalentedPvEDropdown", Talented.PvPTab, "UIDropDownMenuTemplate")
    local menuFrame = Talented.PvPDropdown
    menuFrame:ClearAllPoints()
    menuFrame:SetPoint("TOPLEFT", Talented.PvPTab,"TOPRIGHT")
    EasyMenu(menu, menuFrame, "cursor", 0, 0, "MENU", 1)
end
