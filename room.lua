function room_load(rx, ry)
    local tile_to_spawner_map = {
        [1] = knight_new,
        [23] = zombie_new,
        [9] = bat_new,
        [10] = skeleton_new,
        [15] = merman_new,
        [113] = lever_new
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
            if spawner then
                mset(tx, ty, 0)
                add(spawn_list, { tx = tx, ty = ty, spawner = spawner })
            end
        end
    end

    return {
        tx = tx,
        ty = ty,
        init = function(p)
            global.mp = global.mp_max
            player = p
            entities = { player }
            for s in all(spawn_list) do
                local key = s.tx .. "," .. s.ty
                if not global.dont_respawn[key] then
                    local x = s.tx * 8
                    local y = s.ty * 8
                    add(entities, s.spawner(x, y))
                end
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

            local tx, ty = body_center_tile(player.body)
            local tile = mget(tx, ty)
            if fget(tile, 2) then
                player.hitbox.hp = 0
            elseif tile == 5 then
                mset(tx, ty, 0)
                add(global.subweapons, "knife")
                global.mp_max += 1
                global.mp = global.mp_max
            elseif tile == 62 then
                mset(tx, ty, 0)
                add(global.subweapons, "axe")
                global.mp_max += 1
                global.mp = global.mp_max
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
            camera(tx * 8, ty * 8 - 9)
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
            x += 2

            x = print("mp", x, y, 12)
            local subweapon_name = global.subweapons[global.subweapon_index]
            if subweapon_name then
                local s = subweapon_name == "knife" and 5
                        or subweapon_name == "axe" and 62
                spr(s, x, y - 1)
            end
            x += 8
            for i = 1, global.mp_max do
                x = print("\134", x, y, i <= global.mp and 12 or 1)
            end

            if not global.enemy_hitbox then return end
            x = 80
            spr(46, x, y - 1)
            x += 7
            for i = 1, global.enemy_hitbox.hp_max do
                x = print("♥", x, y, i <= global.enemy_hitbox.hp and 8 or 2)
            end
        end
    }
end