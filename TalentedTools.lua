function Talented:Debug(msg)
    if self.debug then
        self:Print(msg)
    end
end

local tools = {}

function tools.LearnTalentString(build)
    local squelch = Talented.db.global.config.squelch
    if squelch > 0 then Talented:AddSquelch() end

    if build == nil or #build < 1 then return end
    Talented:Debug("Learning talent build "..build)

    for tier=1, #build do
        local column = build:sub(tier,tier)
        local talent = GetTalentInfo(tier, column, 1)
        if column ~= "0" then
            LearnTalents(talent)
        end
    end

    if squelch < 2 then Talented:RemoveSquelchDelayed() end
end

function tools.LearnPvPTalentGroup(group)
    local squelch = Talented.db.global.config.squelch
    if squelch > 0 then Talented:AddSquelch() end
    local active = Talented.tools.GetActivePvPTalentIDs()

    for slot=1, #group do
        if group[slot] ~= 0 and active[slot] ~= group[slot] then 
            LearnPvpTalent(group[slot], slot)
        end
    end
    if squelch < 2 then Talented:RemoveSquelchDelayed() end
end

function tools.GetActiveTalentString()
    local result = ''
    for tier=1, MAX_TALENT_TIERS do
        result = result..select(2, GetTalentTierInfo(tier, 1))
    end
    return result
end

function tools.GetActivePvPTalentIDs()
    return C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
end

function tools.ProcessPvEIgnore(build, ignore)
    local talentString = ''
    for i=1, #ignore do
        if ignore[i] then
            talentString = talentString..'0'
        else
            talentString = talentString..build:sub(i,i)
        end
    end
    return talentString
end

function tools.ProcessPvPIgnore(build, ignore)
    for i=1, #ignore do
        if ignore[i] then
            build[i] = 0
        end
    end
    return build
end

function tools.CompareTalentStrings(a,b)
    if #a ~= #b then return false end
    local chara, charb;
    for i=1, #a do
        chara = a:sub(i,i)
        charb = b:sub(i,i)
        if charb ~= '0' and chara ~= '0' and chara ~= charb then
            return false
        end
    end
    return true
end

function tools.traverseBuilds(builds)
    local a = {}
    for k in pairs(builds) do tinsert(a, k) end
    table.sort(a, function(left,right)
        return string.lower(left) < string.lower(right)
    end)

    local i = 0
    local iter = function()
        i = i+1
        if a[i] == nil then return nil end
        local build = builds[a[i]]
        return build.name, build.build
    end

    return iter
end

function tools.ComparePvPTalentBuilds(a,b)
    if #a ~= #b then return false end
    local tala, talb;
    for i=1, #a do
        tala = a[i]
        talb = b[i]
        if tala ~= 0 and talb ~= 0  and tala ~= talb then
            return false
        end
    end
    return true
end

function tools.GetActiveSpecInfo()
    return GetSpecializationInfo(GetSpecialization())
end

function tools.SetSpellPushDisabled(disable)
    if disable then
        IconIntroTracker:UnregisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
        IconIntroTracker:Hide()
        IconIntroTracker:SetParent(UIHider)
    else
        IconIntroTracker:RegisterEvent("SPELL_PUSHED_TO_ACTIONBAR")
        IconIntroTracker:Show()
        IconIntroTracker:SetParent(UIParent)
    end
end

function tools.ActiveSpecID()
    return select(1, tools.GetActiveSpecInfo())
end

Talented.tools = tools
