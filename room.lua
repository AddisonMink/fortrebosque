function room_load(rx, ry, player)
    local tile_to_spawner_map = {
        [1] = knight_new,
        [23] = zombie_new,
        [9] = bat_new
    }

    local tx = rx * 16
    local ty = ry * 9
    local entities = { player }

    for tx = tx, tx + 15 do
        for ty = ty, ty + 8 do
            local tile = mget(tx, ty)
            local spawner = tile_to_spawner_map[tile]
            if spawner then
                mset(tx, ty, 0)
                add(entities, spawner(tx * 8, ty * 8))
            end
        end
    end

    return {
        tx = tx,
        ty = ty,
        update = function()
            for e in all(entities) do
                if e.update then
                    e.update(e, entities)
                end
            end

            for e in all(entities) do
                if e.body then
                    update_body(e.body)
                end
            end

            for e in all(entities) do
                if e.hurtbox then
                    update_hurtbox(e, entities)
                end
            end

            for e in all(entities) do
                if e.hitbox then
                    update_hitbox(e, entities)
                end
            end
        end,
        draw = function()
            map(tx, ty, 0, 0, 16, 9)

            for e in all(entities) do
                if e.anim then
                    draw_anim(e.anim, e.body, e.hitbox)
                end
            end

            local y = -8
            local x = print("hp", 1, y, player.hitbox.hp > 0 and 8 or 2)
            for i = 1, player.hitbox.hp_max do
                x = print("♥", x, y, i <= player.hitbox.hp and 8 or 2)
            end
        end
    }
end