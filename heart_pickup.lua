function add_heart_pickup(x, y, entities)
    local heart_pickup = {
        body = body_new(x, y, 0, 0, 1, false),
        anim = { frames = { 47 }, fps = 1 },
        update = function(me, entities)
            local player = entities[1]
            local x = player.body.x + 4
            local y = player.body.y + 4
            if abs(me.body.x - x) < 8 and abs(me.body.y - y) < 8 then
                player.hitbox.hp_max += 1
                player.hitbox.hp = player.hitbox.hp_max
                del(entities, me)
                mset(15, 23, 0)
            end
        end
    }

    add(entities, heart_pickup)
end