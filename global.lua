global = {
    subweapons = {},
    subweapon_index = 1,
    mp = 0,
    mp_max = 0,
    dracula_dead = false,
    dont_respawn = {},
    lever_states = {},

    lever_funcs = {
        ["44,21"] = function()
            for tx = 37, 40 do
                mset(tx, 24, 33)
            end
        end,
        ["17,4"] = function()
            mset(31, 7, 0)
            mset(32, 7, 0)
            mset(33, 8, 96)
            mset(36, 8, 96)
            mset(38, 8, 96)
        end
    }
}