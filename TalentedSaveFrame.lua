local AceGUI = LibStub("AceGUI-3.0")

function Talented:OpenPvESavePanel(build)
    self:OpenSaveFrame(build, function(talentString, tier) 
        return select(2, GetTalentInfo(tier, talentString:sub(tier, tier), 1))
    end,"Tier",self.tools.ProcessPvEIgnore,"PvE")
end

function Talented:OpenPvPSavePanel(build)
    self:OpenSaveFrame(build, function(talents, tier) 
        return select(2, GetPvpTalentInfoByID(talents[tier], 1))
    end, "Slot", self.tools.ProcessPvPIgnore,"PvP")
end

function Talented:OpenSaveFrame(build, talentNameFunc, talentIgnoreTag, ignoreProcessor, CommitTag)
    local function newline()
        local n = AceGUI:Create("Label")
        n:SetText("\n")
        return n
    end

    local function Desaturate(btn, desat)
        SetDesaturation(btn.frame.Middle, desat)
        SetDesaturation(btn.frame.Left, desat)
        SetDesaturation(btn.frame.Right, desat)
    end

    local g = AceGUI:Create("Window")
    g:Hide()
    g:EnableResize(false)
    g:SetTitle("Talented")
    g:SetPoint("TOPLEFT", self.PvETab, "TOPRIGHT", 5, 37)
    g:SetWidth(250)
    g:SetHeight(169 + #build.build * 23)
    g:SetCallback("OnClose", function(frm) frm:ReleaseChildren(); AceGUI:Release(frm); end)

    local saveButton = AceGUI:Create("Button")
    local editbox = AceGUI:Create("EditBox")
    editbox:SetLabel("Build Name:")
    editbox:SetFullWidth(true)
    editbox:SetCallback("OnTextChanged", function(widget, event, text)
        build.name = text
        if text and text ~= '' then
            saveButton:SetDisabled(false)
        else
            saveButton:SetDisabled(true)
        end
    end)
    g:AddChild(editbox)
    g:AddChild(newline())

    local h = AceGUI:Create("Label")
    h:SetText(IGNORE..' '..TALENTS)
    h:SetJustifyH("CENTER")
    g:AddChild(h)

    local ignoreMask = {};
    for tier=1, #build.build do
        ignoreMask[tier] = false
        local talentName = talentNameFunc(build.build, tier)
        local b = AceGUI:Create("Button")
        b:SetText(talentName)
        b:SetFullWidth(true)
        Desaturate(b, false)
        b:SetCallback("OnClick", function()
            ignoreMask[tier] = not ignoreMask[tier]
            if ignoreMask[tier] then
                Desaturate(b, true)
                b:SetText(("%s %d - %s"):format(talentIgnoreTag, tier, IGNORED))
            else 
                Desaturate(b, false)
                b:SetText(talentName)
            end
        end)
        g:AddChild(b)
    end

    g:AddChild(newline())

    saveButton:SetText(SAVE)
    saveButton:SetFullWidth(true)
    saveButton:SetDisabled(true)
    Desaturate(saveButton, false)
    saveButton:SetCallback("OnClick", function()
        if build.name ~= '' then
            build.build = ignoreProcessor(build.build, ignoreMask)
            self:CommitBuild(build, CommitTag)
            g:ReleaseChildren()
            AceGUI:Release(g)
        end
    end)
    g:AddChild(saveButton)

    g:Show()
    editbox:SetFocus()

end

function Talented:SaveCompletedBuild(build)
    self:Print(build.talents)
    self:Print(build.pvpTalents)
end
