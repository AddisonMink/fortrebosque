function demon_new(x, y)
    -- animations
    local inert_anim = anim_new({ 105 }, 1, "big")
    local idle_anim = anim_new({ 73, 75 }, 1, "big")
    local windup_anim = anim_new({ 77 }, 1, "big")
    local fireball_anim = anim_new({ 85, 86 }, 6)

    -- constants
    local idle_dur = 3
    local idle_speed = 1
    local windup_dur = 0.5
    local fireball_dur = 0.5
    local fireball_max_speed = 5
    local fireball_accel = 0.4
    local max_fireballs = 3
    local heart_pickup_x = 53 * 8
    local heart_pickup_y = 7 * 8

    -- state
    local hitbox = hitbox_new("enemy", 5, { x = 2, y = 2, w = 12, h = 12 })
    local hurtbox = hurtbox_new("player", 1, { x = 4, y = 4, w = 8, h = 8 })
    local timer = timer_new(idle_dur)
    local fireball_count = 0
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local key = tx .. "," .. ty
    local rx = flr(tx / 16) * 16
    local room_x = rx * 8
    local min_x = room_x + 8
    local max_x = room_x + 104

    -- local functions
    local function add_fireball(me, entities)
        local timer = timer_new(fireball_dur)
        local player_body = entities[1].body
        local facing = player_body.x > me.body.x and 1 or -1
        local dy = sgn(player_body.y - me.body.y)
        local target_y = player_body.y

        local fireball = {
            body = body_new(me.body.x + 8 * facing, me.body.y + 8, 0, 0, facing),
            anim = fireball_anim,
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 4, h = 4 }),
            update = function(me, entities)
                if timer() then
                    del(entities, me)
                else
                    local speed = min(fireball_max_speed, abs(me.body.vel_x) + fireball_accel)
                    me.body.vel_x = facing * speed
                    if me.body.y < target_y then
                        me.body.vel_y = dy
                    else
                        me.body.vel_y = 0
                    end
                end
            end
        }

        add(entities, fireball)
    end

    local state_map = {
        inert = function(me, entities)
            local player = entities[1]
            if player.body.x > min_x then
                me.anim = idle_anim
                me.hitbox = hitbox
                me.hurtbox = hurtbox
                global.enemy_hitbox = hitbox
                mset(48, 4, 6)
                mset(48, 5, 6)
                timer = timer_new(idle_dur)
                return "idle"
            end
        end,
        idle = function(me)
            me.body.vel_x = me.body.facing * idle_speed

            local next_x = me.body.x + me.body.vel_x

            if next_x < min_x or next_x > max_x then
                me.body.facing *= -1
            end

            if timer() then
                me.body.vel_x = 0
                me.anim = windup_anim
                timer = timer_new(windup_dur)
                return "windup"
            end
        end,
        windup = function(me, entities)
            if timer() then
                timer = timer_new(windup_dur)
                fireball_count += 1
                add_fireball(me, entities)
            end

            if fireball_count >= max_fireballs then
                fireball_count = 0
                timer = timer_new(idle_dur)
                me.anim = idle_anim
                return "idle"
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0, -1),

        anim = inert_anim,
        update = state_machine_new("inert", state_map),
        on_death = function(me, entities)
            global.dont_respawn[key] = true
            global.enemy_hitbox = nil

            -- open doors.
            mset(48, 4, 0)
            mset(48, 5, 0)

            -- remove demon statue.
            mset(62, 16, 0)
        end,
        on_player_death = function(me)
            mset(48, 4, 0)
            mset(48, 5, 0)
            global.enemy_hitbox = nil
        end
    }
end