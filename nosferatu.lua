function nosferatu_new(x, y)
    x -= 16
    y -= 40

    -- animations
    local idle_anim = anim_new({ 128, 130 }, 1, "big")
    local rain_anim = anim_new(132, 1, "big")
    local dive_windup_anim = anim_new(134, 1, "big")
    local dive_anim = anim_new(136, 1, "big")
    local inert_1_anim = anim_new(138, 1, "big")
    local inert_2_anim = anim_new(140, 1, "big")
    local blood_anim = anim_new({ 160, 161 }, 6)
    local explosion_anim = anim_new({ 162, 164, 166, 168 }, 6, "big")

    -- constants
    local origin_y = y
    local idle_dur = 3
    local rain_windup_dur = 0.25
    local rain_dur = 2
    local post_rain_dur = 0.125
    local dive_windup_dur = 0.25
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local rx = flr(tx / 16) * 16
    local ry = flr(ty / 9) * 9
    local start_y = ry * 8
    local stop_y = start_y + 8 * 6
    local start_x = rx * 8 + 8
    local min_tx = 67
    local max_tx = 76
    local min_x = min_tx * 8
    local max_x = max_tx * 8
    local shockwave_step_dur = 0.05
    local shockwave_steps = 10

    -- state
    local hitbox = hitbox_new("enemy", 5, { x = 2, y = 2, w = 12, h = 12 })
    local hurtbox = hurtbox_new("player", 1, { x = 4, y = 4, w = 8, h = 8 })
    timer = timer_new(3)

    local function add_blood(x, y, entities)
        local timer = timer_new(5)

        local blood = {
            body = body_new(x, y),
            anim = blood_anim,
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 4, h = 4 }),
            update = function(me)
                me.body.vel_y += 0.2
                if timer() then
                    del(entities, me)
                end
            end
        }

        add(entities, blood)
    end

    local function blood_rain(entities)
        local offset = flr(rnd(16))
        local x = start_x + offset
        for i = 1, 8 do
            add_blood(x, start_y - 8, entities)
            x += 16
        end
    end

    local function shockwave_add(x, y, entities, flip_x)
        local steps = 0
        local timer = timer_new(shockwave_step_dur)

        local shock_wave = {
            body = body_new(x, y, 0, 0, flip_x and -1 or 1, false),
            hurtbox = hurtbox_new("player", 1, { x = 0, y = 6, w = 6, h = 2 }),
            anim = { frames = { 2 }, fps = 1, flip_x = flip_x },
            update = function(me, entities)
                if timer() then
                    me.body.x += me.body.facing * 4
                    steps += 1
                    if steps >= shockwave_steps then
                        del(entities, me)
                    end
                    timer = timer_new(shockwave_step_dur)
                end
            end
        }
        add(entities, shock_wave)
        return shock_wave
    end

    local function add_death(me, entities)
        local timer = timer_new(3)
        local death = {
            body = body_new(me.body.x, me.body.y, 0, 0, 0),
            anim = explosion_anim,
            update = function(me, entities)
                if timer() then
                    del(entities, me)
                    global.dracula_dead = true
                end
            end,
            draw = function(me)
                spr(132, me.body.x, me.body.y, 2, 2)
            end
        }
        add(entities, death)
    end

    local state_map = {
        inert_1 = function(me)
            if timer() then
                me.anim = inert_1_anim
                timer = timer_new(0.5)
                return "inert_2"
            end
        end,
        inert_2 = function(me)
            if timer() then
                me.anim = inert_2_anim
                timer = timer_new(0.5)
                return "inert_3"
            end
        end,
        inert_3 = function(me)
            if timer() then
                me.anim = idle_anim
                timer = timer_new(idle_dur)
                return "idle"
            end
        end,
        idle = function(me)
            global.enemy_hitbox = hitbox
            if me.body.facing > 0 then
                me.body.vel_x = 1
                if me.body.x > max_x then
                    me.body.facing = -0.5
                end
            else
                me.body.vel_x = -1
                if me.body.x < min_x then
                    me.body.facing = 0.5
                end
            end

            if timer() then
                me.body.vel_x = 0
                me.anim = rain_anim
                timer = timer_new(rain_windup_dur)
                return "rain_windup"
            end
        end,
        rain_windup = function(me, entities)
            if timer() then
                timer = timer_new(rain_dur)
                blood_rain(entities)
                return "rain"
            end
        end,
        rain = function(me)
            if timer() then
                me.anim = idle_anim
                timer = timer_new(post_rain_dur)
                return "post_rain"
            end
        end,
        post_rain = function(me)
            if timer() then
                me.anim = dive_windup_anim
                timer = timer_new(dive_windup_dur)
                return "dive_windup"
            end
        end,
        dive_windup = function(me)
            if timer() then
                me.anim = dive_anim
                timer = timer_new(dive_windup_dur)
                return "dive"
            end
        end,
        dive = function(me, entities)
            me.body.vel_y += 0.5
            if me.body.y > stop_y then
                me.body.y = stop_y
                me.body.vel_y = 0
                shockwave_add(me.body.x + 4, me.body.y + 8, entities, false)
                shockwave_add(me.body.x + 4, me.body.y + 8, entities, true)
                timer = timer_new(0.5)
                return "dive_stop"
            end
        end,
        dive_stop = function(me)
            if timer() then
                me.body.vel_y = -1
                me.anim = idle_anim
                return "dive_return"
            end
        end,
        dive_return = function(me)
            if me.body.y < origin_y then
                me.body.y = origin_y
                me.body.vel_y = 0
                timer = timer_new(idle_dur)
                return "idle"
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0),
        hitbox = hitbox,
        hurtbox = hurtbox,
        update = state_machine_new("inert_1", state_map),
        on_death = function(me, entities)
            add_death(me, entities)
        end,
        on_player_death = function()
            global.enemy_hitbox = nil
            mset(64, 15, 0)
            mset(64, 16, 0)
        end
    }
end