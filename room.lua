function room_load(rx, ry)
    local tile_to_spawner_map = {
        [1] = knight_new,
        [23] = zombie_new,
        [9] = bat_new,
        [10] = skeleton_new
    }

    local tx = rx * 16
    local ty = ry * 9
    local x = tx * 8
    local y = ty * 8
    local x2 = x + 128
    local y2 = y + 72
    local entities = {}
    local spawn_list = {}
    local player = nil

    for tx = tx, tx + 15 do
        for ty = ty, ty + 8 do
            local tile = mget(tx, ty)
            local spawner = tile_to_spawner_map[tile]
            local x, y = tx * 8, ty * 8
            if spawner then
                mset(tx, ty, 0)
                add(spawn_list, { x = x, y = y, spawner = spawner })
            end
        end
    end

    return {
        tx = tx,
        ty = ty,
        init = function(p)
            player = p
            entities = { player }
            for s in all(spawn_list) do
                add(entities, s.spawner(s.x, s.y))
            end
        end,
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

            local player_tile = body_center_tile(player.body)
            if fget(player_tile, 2) then
                player.hitbox.hp = 0
            end

            for e in all(entities) do
                if e.hitbox and e.hitbox.hp <= 0 then
                    if e.on_death then
                        e.on_death(e, entities)
                    end
                    del(entities, e)
                end
            end

            local px = player.body.x + 4
            local py = player.body.y + 4

            if player.hitbox.hp <= 0 then
                return { dead = true }
            elseif px < x then
                return { rx = rx - 1, ry = ry }
            elseif px > x2 then
                return { rx = rx + 1, ry = ry }
            elseif py < y then
                return { rx = rx, ry = ry - 1 }
            elseif py > y2 then
                return { rx = rx, ry = ry + 1 }
            end
        end,
        draw = function()
            camera(tx * 8, ty * 8 - 8)
            map(tx, ty, tx * 8, ty * 8, 16, 9)

            for e in all(entities) do
                if e.anim then
                    draw_anim(e.anim, e.body, e.hitbox)
                end
            end

            local y = ty * 8 - 8
            local x = tx * 8
            x = print("hp", x + 1, y, player.hitbox.hp > 0 and 8 or 2)
            for i = 1, player.hitbox.hp_max do
                x = print("♥", x, y, i <= player.hitbox.hp and 8 or 2)
            end
        end
    }
end