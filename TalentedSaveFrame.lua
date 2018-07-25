local AceGUI = LibStub("AceGUI-3.0")

function Talented:OpenSaveFrame(build)
    local function newline()
        local n = AceGUI:Create("Label")
        n:SetText("\n")
        return n
    end

    local f = AceGUI:Create("Frame")
    f:SetLayout("List")
    f:SetTitle("Talented")
    f:SetWidth(250)
    f:EnableResize(false)
    f.statustext:GetParent():Hide()
    f:SetCallback("OnClose", function(widget) 
        widget:ReleaseChildren();
        AceGUI:Release(widget); 
    end)
    f:SetAutoAdjustHeight(true)


    -- EDIT BOX 
    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Build Name:")
    editbox:SetFullWidth(true)
    editbox:SetCallback("OnEnterPressed", function(widget, event, text) build.name = text end)
    editbox:SetFocus()
    f:AddChild(editbox)
    f:AddChild(newline())


    -- PVE TALENT TIERS
    local h = AceGUI:Create("Label")
    h:SetText(IGNORE)
    f:AddChild(h)

    local ignoreMask = {
        talents = {},
        pvpTalents = {}
    }
    for tier=1, #build.talents do
        ignoreMask.talents[tier] = false
        local talentName = select(2, GetTalentInfo(tier, build.talents:sub(tier, tier), 1))
        local b = AceGUI:Create("Button")
        b:SetText(talentName)
        b:SetFullWidth(true)
        b:SetCallback("OnClick", function()
            ignoreMask.talents[tier] = not ignoreMask.talents[tier]
            if ignoreMask.talents[tier] then
                b:SetText(("Tier %d - %s"):format(tier, IGNORED))
            else 
                b:SetText(talentName)
            end
        end)
        f:AddChild(b)
    end

    f:AddChild(newline())


    -- PVP TALENT TIERS
    h = AceGUI:Create("Label")
    h:SetText(("%s %s"):format(IGNORE, PVP))
    f:AddChild(h)

    for pvpSlot=1, #build.pvpTalents do
        ignoreMask.pvpTalents[pvpSlot] = false
        local talentName = select(2, GetPvpTalentInfoByID(build.pvpTalents[pvpSlot]))
        local b = AceGUI:Create("Button")
        b:SetText(talentName)
        b:SetFullWidth(true)
        b:SetCallback("OnClick", function()
            ignoreMask.pvpTalents[pvpSlot] = not ignoreMask.pvpTalents[pvpSlot]
            if ignoreMask.pvpTalents[pvpSlot] then
                b:SetText(("%s Slot %d - %s"):format(PVP, pvpSlot, IGNORED))
            else
                b:SetText(talentName)
            end
        end)
        f:AddChild(b)
    end

    f:AddChild(newline())


    -- SAVE BUTTON
    local saveButton = AceGUI:Create("Button")
    saveButton:SetText(SAVE)
    saveButton:SetFullWidth(true)
    saveButton:SetCallback("OnClick", function()
        if build.name ~= '' then
            self:SaveCompletedBuild(
                self:ProcessIgnoreMask(build, ignoreMask)
            )
            f:ReleaseChildren()
            AceGUI:Release(f)
        end
    end)
    f:AddChild(saveButton)
end

function Talented:ProcessIgnoreMask(build, ignoreMask)
    -- PvE
    self:Debug("Starting talent string is "..build.talents)
    local talentString = ''
    for i=1, #ignoreMask.talents do
        if ignoreMask.talents[i] then
            self:Debug("Ignoring tier "..i)
            talentString = talentString..'0'
        else 
            talentString = talentString..build.talents:sub(i,i)
        end
    end
    build.talents = talentString
    self:Debug("New talent string is "..build.talents)

    -- PvP Talents
    for i=1, #ignoreMask.pvpTalents do
        if ignoreMask.pvpTalents[i] then
            self:Debug("Ignoring pvp slot "..i)
            build.pvpTalents[i] = 0
        end
    end

    return build
end

function Talented:SaveCompletedBuild(build)
    self:Print(build.talents)
    self:Print(build.pvpTalents)
end
