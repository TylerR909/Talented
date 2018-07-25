local talname, tal = ...

local defaultops = {
    squelch = 1, --[0: No Squelch]
                 --[1: When Talented swaps talents]
                 --[2: Always]
    ldb = {
        title_on = true
    }
}

function tal:ParseConfig() 
    -- Recursve through defaults and verify that instances of the options exist
    function checkSetOption(opt,defaults) 
        if type(defaults) == "table" then opt = {}
        else return defaults end

        for k, v in pairs(defaults) do
            if type(v) == "table" then
                opt[k] = checkSetOptions(opt[k],v)
            elseif type(v) ~= type(opt[k]) then
                opt[k] = v
            end
        end
        return opt
    end

    -- Verify config is set up
    if tal.config then
        tal.config = checkSetOption(tal.config,defaultops)
    else
        tal.config = {}
        tal.config = defaultops;
    end
end
