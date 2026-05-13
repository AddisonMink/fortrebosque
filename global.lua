global = {
    subweapons = {},
    subweapon_index = 1,
    mp = 0,
    mp_max = 0,
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