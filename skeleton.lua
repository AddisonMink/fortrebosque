function skeleton_new(x, y)
    -- constants
    local idle_anim = { frames = { 10, 11, 12, 11 }, fps = 3 }
    local windup_anim = { frames = { 13 }, fps = 1 }
    local attack_anim = { frames = { 14 }, fps = 1 }
    local weapon_anim = { frames = { 27, 28 }, fps = 3 }
    local windup_dur = 0.5
    local attack_dur = 0.25
    local attack_cooldown = 3
    local weapon_y_vel = -2
    local weapon_x_speed = 1

    -- local functions
    local function add_weapon(me, entities)
        local weapon = {
            body = body_new(
                me.body.x,
                me.body.y,
                weapon_x_speed * me.body.facing,
                weapon_y_vel,
                me.body.facing
            ),
            anim = weapon_anim,
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 4, h = 4 }),
            update = function(me)
                me.body.vel_y += 0.2

                local tile = body_center_tile(me.body)
                if fget(tile, 0) then
                    del(entities, me)
                end
            end
        }
        add(entities, weapon)
    end

    -- state
    local timer = nil

    local state_map = {
        idle = function(me, entities)
            local player = entities[1]
            local facing = player.body.x > me.body.x and 1 or -1

            me.body.facing = facing

            if not timer then timer = timer_new(attack_cooldown) end

            if timer() then
                me.anim = windup_anim
                timer = timer_new(windup_dur)
                return "windup"
            end
        end,
        windup = function(me, entities)
            if timer() then
                me.anim = attack_anim
                timer = timer_new(attack_dur)
                add_weapon(me, entities)
                return "attack"
            end
        end,
        attack = function(me)
            if timer() then
                me.anim = idle_anim
                timer = timer_new(attack_cooldown)
                return "idle"
            end
        end
    }

    return {
        body = body_new(x, y),
        hitbox = hitbox_new("enemy", 2),
        hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 6, h = 6 }),
        anim = idle_anim,
        update = state_machine_new("idle", state_map)
    }
end