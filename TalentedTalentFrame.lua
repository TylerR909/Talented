local AceGUI = LibStub("AceGUI-3.0")

function Talented:InitUI()
    self:Print("Initializing")
    self.InitRightClickSpecSwapButtons()
    self:MakeButtonTabs()
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

function Talented:MakeButtonTabs()
    local pve = CreateFrame("Button",nil,PlayerTalentFrameTalents,"SpellBookSkillLineTabTemplate")
    pve:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 0, -35)
    pve:SetNormalTexture("Interface\\Icons\\INV_Helmet_08")
    pve:SetScript("OnClick", function(btn)
        self:InitPvEDropdown()
    end)
    pve.tooltip = "PVE Builds"
    pve:Show()
    self.PvETab = pve

    local pvp = CreateFrame("Button",nil,pve,"SpellBookSkillLineTabTemplate")
    pvp:SetPoint("TOPLEFT", pve, "BOTTOMLEFT", 0, -22)
    pvp:SetNormalTexture("Interface\\Icons\\achievement_bg_winwsg")
    pvp:SetScript("OnClick", function(btn)
        self:InitPvPDropdown()
    end)
    pvp.tooltip = "PVP Builds"
    pvp:Show()
    self.PvPTab = pvp
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

    local icyBuild = Talented.IcyVeinsSpecs[tostring(specid)].build
    tinsert(menu, {
        text="Icy Veins",
        value = icyBuild,
        checked = compare(icyBuild, activeBuild),
        func = function(btn) self.tools.LearnTalentString(btn.value) end
    })

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
        func = function() end,
        notCheckable=true
    })

    local menuFrame = CreateFrame("Frame", "TalentedPvEDropdown", Talented.PvETab, "UIDropDownMenuTemplate")
    menuFrame:ClearAllPoints()
    menuFrame:SetPoint("TOPLEFT", Talented.PvETab,"TOPRIGHT")
    EasyMenu(menu, menuFrame, menuFrame, 5, 40, "MENU", 1)
end

function Talented:InitPvPDropdown()
    GameTooltip:Hide()
    local specid = self.tools.ActiveSpecID()
    local activeBuild = self.tools.GetActivePvPTalentIDs()
    local menu = {
        { text = PVP..' '..TALENTS, isTitle=true, notCheckable=true}
    }

    for _,build in pairs(self.db.class[specid].PvP) do
        local btn = {
            text = build.name,
            value = build.build,
            checked = self.tools.ComparePvPTalentBuilds(build.build, activeBuild),
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
        func = function() end,
        notCheckable=true
    })

    tinsert(menu, saveBtn)

    local menuFrame = CreateFrame("Frame", "TalentedPvEDropdown", Talented.PvPTab, "UIDropDownMenuTemplate")
    menuFrame:ClearAllPoints()
    menuFrame:SetPoint("TOPLEFT", Talented.PvPTab,"TOPRIGHT")
    EasyMenu(menu, menuFrame, menuFrame, 5, 40, "MENU", 1)
end