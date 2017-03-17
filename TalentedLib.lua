local talname, tal = ...

local defaultops = {
    squelch = 1, --[0: No Squelch]
                 --[1: When Talented swaps talents]
                 --[2: Always]
    ldb = {
        title_on = true
    }
}

function tal:ParseConfig() {
    local config = tal.config;
    function checkSetOption(opt,dopt) {
        -- foreach i in 
        -- if type(elem) == "table" then
        -- end
    }
    if config then
        -- config.version = GetAddonMetadata(talname,"Version")
        if not squelch then
            squelch = defaultops.squelch
        end
        if not config.ldb then 
            config.ldb = defaultops.ldb
        else
            -- check each piece of config.ldb 
        end
        -- check that each option exists
    else
        tal.config = defaultops;
    end

}