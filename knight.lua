function knight_new(x, y)
    -- animations
    local walk_anim = anim_new({ 34, 35, 36, 35 }, 1, "tall")
    local wind_up_anim = anim_new(37, 1, "tall")
    local attack_anim = anim_new(38, 1, "tall")
    local shockwave_anim = anim_new(2)

    -- constants
    local windup_dur = 0.5
    local attack_dur = 0.5
    local shockwave_step_dur = 0.1
    local shockwave_steps = 5
    local attack_range = 16
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local room_tx = flr(tx / 16) * 16
    local room_ty = flr(ty / 9) * 9
    local key = tx .. "," .. ty

    -- local functions
    local function shockwave_add(body, entities)
        local flip_x = body.facing < 0
        local steps = 0
        local timer = timer_new(shockwave_step_dur)

        local shock_wave = {
            body = body_new(body.x, body.y, 0, 0, body.facing, false),
            hurtbox = hurtbox_new("player", 1, { x = 0, y = 6, w = 6, h = 2 }),
            anim = shockwave_anim,
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
        update = state_machine_new("walk", state_map),
        on_death = function(me, entities)
            -- delete weapon if exist
            if weapon then
                del(entities, weapon)
            end

            -- open any gates in the room
            for tx = room_tx, room_tx + 15 do
                for ty = room_ty, room_ty + 8 do
                    if mget(tx, ty) == 6 then
                        mset(tx, ty, 0)
                    end
                end
            end

            -- dont respawn knight
            global.dont_respawn[key] = true
        end
    }
end