function bat_new(x, y)
    -- animations
    local hang_anim = anim_new(9)
    local fly_anim = anim_new({ 7, 8 }, 6)

    -- constants
    local x_range = 40
    local y_range = 20
    local speed = 1

    -- state
    local target_y = nil

    local state_map = {
        hang = function(me, entities)
            local player = entities[1]
            local me_x, me_y = me.body.x, me.body.y
            local p_x, p_y = player.body.x, player.body.y
            local x_dist = abs(p_x - me_x)
            local y_dist = abs(p_y - me_y)
            if x_dist < x_range and y_dist < y_range and p_y > me_y then
                target_y = p_y - 4
                me.anim = fly_anim
                me.body.facing = p_x < me_x and -1 or 1
                me.body.vel_x = me.body.facing * speed
                return "fly"
            end
        end,
        fly = function(me, entities)
            if me.body.y < target_y then
                me.body.vel_y += 0.2
            else
                me.body.vel_y = 0
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0, 1, false),
        hitbox = hitbox_new("enemy", 1),
        hurtbox = hurtbox_new("player", 1, { x = 0, y = 0, w = 6, h = 6 }),
        anim = hang_anim,
        update = state_machine_new("hang", state_map)
    }
end