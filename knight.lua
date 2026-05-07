function knight_new(x, y)
    -- constants
    local walk_anim = { frames = { 34, 35, 36, 35 }, fps = 1, tall = true }
    local wind_up_anim = { frames = { 37 }, fps = 1, tall = true }
    local attack_anim = { frames = { 38 }, fps = 1, tall = true }
    local windup_dur = 0.5
    local attack_dur = 0.5
    local shockwave_step_dur = 0.1
    local shockwave_steps = 5
    local attack_range = 12

    -- local functions
    local function shockwave_add(body, entities)
        local flip_x = body.facing < 0
        local steps = 0
        local timer = timer_new(shockwave_step_dur)

        local shock_wave = {
            body = body_new(body.x, body.y, 0, 0, body.facing, false),
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

    local function weapon_add(body, entities)
        local offset = body.facing == 1 and 6 or -6
        local flip_x = body.facing < 0
        local weapon = {
            body = body_new(body.x + offset, body.y, 0, 0, body.facing, false),
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 4, w = 4, h = 2 }),
            anim = { frames = { 3 }, fps = 1, flip_x = flip_x }
        }
        add(entities, weapon)
        shockwave_add(weapon.body, entities)
        return weapon
    end

    -- state
    local timer = nil
    local weapon = nil

    local state_map = {
        walk = function(me, entities)
            local player = entities[1]
            local dx = abs(player.body.x - me.body.x)

            me.body.facing = player.body.x < me.body.x and -1 or 1

            if dx <= attack_range then
                timer = timer_new(windup_dur)
                me.anim = wind_up_anim
                return "wind_up"
            end
        end,
        wind_up = function(me, entities)
            if timer() then
                timer = timer_new(attack_dur)
                me.anim = attack_anim
                weapon = weapon_add(me.body, entities)
                return "attack"
            end
        end,
        attack = function(me, entities)
            if timer() then
                del(entities, weapon)

                timer = nil
                me.anim = walk_anim
                return "walk"
            end
        end
    }

    return {
        body = body_new(x, y - 8, 0, 0, 1, true),
        hitbox = hitbox_new("enemy", 3, { x = 2, y = -4, w = 6, h = 6 }),
        hurtbox = hurtbox_new("player", 1, { x = 2, y = -4, w = 6, h = 12 }),
        anim = walk_anim,
        update = state_machine_new("walk", state_map)
    }
end