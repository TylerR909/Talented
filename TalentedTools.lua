function Talented:Debug(msg)
    if self.debug then
        self:Print(msg)
    end
end

local tools = {}

function tools.LearnTalentString(build)
    if build == nil or #build < 1 then return end
    Talented:Debug("Learning talent build "..build)

    for tier=1, #build do
        local column = build:sub(tier,tier)
        local talent = GetTalentInfo(tier, column, 1)
        Talented:Debug(talent)
        if column ~= "0" then LearnTalents(talent) end
    end
end

function tools.LearnPvpTalentGroup(group)
    for slot=1, #group do
        LearnPvpTalent(group[slot], slot)
    end
end

function tools.GetActiveTalentString()
    local result = ''
    for tier=1, GetMaxTalentTier() do
        result = result..select(2, GetTalentTierInfo(tier, 1))
    end
    return result
end

function tools.GetActivePvpTalentIDs()
    return C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
end

function tools.GetActiveSpecInfo()
    return GetSpecializationInfo(GetSpecialization())
end

Talented.tools = tools
