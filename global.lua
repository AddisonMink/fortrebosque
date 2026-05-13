global = {
    knife = true,
    axe = true,
    subweapons = {},
    mp = 2,
    mp_max = 2,
    dont_respawn = {},
    lever_states = {},

    lever_funcs = {
        ["44,21"] = function()
            for tx = 37, 40 do
                mset(tx, 24, 33)
            end
        end
    }
}