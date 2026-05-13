function lever_new(x, y)
    -- constants
    local not_flipped_anim = { frames = { 113 }, fps = 1 }
    local flipped_anim = { frames = { 114 }, fps = 1 }
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local key = tx .. "," .. ty

    -- state
    local flipped = global.lever_states[key]

    return {
        body = body_new(x, y, 0, 0, 1, false),
        anim = flipped and flipped_anim or not_flipped_anim,
        hitbox = hitbox_new("enemy", 999),
        update = function(me)
            if me.hitbox and me.hitbox.hp < 999 then
                me.hitbox = nil
                flipped = not flipped
                global.lever_states[key] = flipped
                global.lever_funcs[key]()
                me.anim = flipped_anim
            end
        end
    }
end