Talented.IcyVeinsSpecs = {
    GameVersion = "8.0.1",
    -- DK - Blood
    ["250"] = { build = "2221021" },
    -- DK - Frost
    ["251"] = { build = "2102033" },
    -- DK - Unholy
    ["252"] = { build = "3103012" },

    -- DH - Havoc
    ["577"] = { build = "3211203" },
    -- DH - Vengeance
    ["581"] = { build = "1213122" },

    -- Druid - Balance
    ["102"] = { build = "2323121" },
    -- Druid - Feral
    ["103"] = { build = "3310232" },
    -- Druid - Guardian
    ["104"] = { build = "3310133" },
    -- Druid - Restoration
    ["105"] = { build = "3330213" },

    -- Hunter - Beast Mastery
    ["253"] = { build = "1323212" },
    -- Hunter - Marksmanship
    ["254"] = { build = "3123212" },
    -- Hunter - Survival
    ["255"] = { build = "1121211" },

    -- Mage - Arcane
    ["62"] = { build = "3312121" },
    -- Mage - Fire
    ["63"] = { build = "1211122" },
    -- Mage - Frost
    ["64"] = { build = "2313023" },

    -- Monk - Brewmaster
    ["268"] = { build = "1232121" },
    -- Monk - Windwalker
    ["269"] = { build = "3132132" },
    -- Monk - Mistweaver
    ["270"] = { build = "3203332" },

    -- Paladin - Holy
    ["65"] = { build = "2303322" },
    -- Paladin - Protection
    ["66"] = { build = "1103111" },
    -- Paladin - Retribution
    ["70"] = { build = "2303131" },

    -- Priest - Discipline
    ["256"] = { build = "2310233" },
    -- Priest - Holy
    ["257"] = { build = "1310213" },
    -- Priest - Shadow
    ["258"] = { build = "3120321" },

    -- Rogue - Assassination
    ["259"] = { build = "1210321" },
    -- Rogue - Outlaw
    ["260"] = { build = "2310323" },
    -- Rogue - Subtlety
    ["261"] = { build = "2330031" },

    -- Shaman - Elemental
    ["262"] = { build = "1301021" },
    -- Shaman - Enhancement
    ["263"] = { build = "3101033" },
    -- Shaman - Restoration
    ["264"] = { build = "3301111" },

    -- Warlock - Affliction
    ["265"] = { build = "3102321" },
    -- Warlock - Demonology
    ["266"] = { build = "2103021" },
    -- Warlock - Destruction
    ["267"] = { build = "2222021" },

    -- Warrior - Arms
    ["71"] = { build = "3102211" },
    -- Warrior - Fury
    ["72"] = { build = "2133121" },
    -- Warrior - Protection
    ["73"] = { build = "1223011" },
}

function Talented:IcyVersionCheck()
    if self.db.global.config.hideIcyVeins 
        or self.db.global.config.ignoreIcyCheck 
    then return end

    C_Timer.After(5, function() 
        local patch = GetBuildInfo()
        local buildsPatch = Talented.IcyVeinsSpecs.GameVersion
        if patch ~= buildsPatch then
            PlaySound(SOUNDKIT.TELL_MESSAGE)
            self:Print(
                ("IcyVeins builds are relevant for %s and "
                    .."have not been updated for %s yet. "
                    .."Use at your own discretion."):format(
                        buildsPatch,
                        patch
                )
            )
        end
    end)
end
