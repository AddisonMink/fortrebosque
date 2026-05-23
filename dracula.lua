function dracula_new(x, y)
    -- animations
    local inert_anim = anim_new(110, 1, "tall")
    local idle_anim = anim_new(107, 1, "tall")
    local windup_anim = anim_new(108, 1, "tall")
    local attack_anim = anim_new(109, 1, "tall")
    local fireball_anim = anim_new({ 85, 86 }, 6)

    -- constants
    local idle_dur = 1
    local windup_dur = 0.5
    local attack_dur = 1
    local idle_dur_2 = 0.5
    local tx = flr(x / 8)
    local rx = flr(tx / 16) * 16
    local start_x = rx * 8 + 8
    local min_tx = 67
    local max_tx = 76

    -- state
    local hitbox = hitbox_new("enemy", 5, { x = 0, y = -8, w = 8, h = 8 })
    local timer = nil

    local function draw_teleport(me)
        local x1 = me.body.x - 4
        local x2 = me.body.x + 11
        local y1 = me.body.y - 7 * 8
        local y2 = me.body.y + 7
        rectfill(x1, y1, x2, y2, 7)
    end

    local function add_fireball(me, entities, top, fast)
        local facing = me.body.facing
        local vel_x = facing * (fast and 2.5 or 1.5)
        local x = me.body.x
        local y = top and me.body.y - 8 or me.body.y
        local timer = timer_new(5)

        local fireball = {
            body = body_new(x, y, vel_x, 0, facing),
            anim = fireball_anim,
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 4, h = 4 }),
            update = function(me, entities)
                if timer() then
                    del(entities, me)
                end
            end
        }

        add(entities, fireball)
    end

    local state_map = {
        inert = function(me, entities)
            local player_x = entities[1].body.x
            if player_x > start_x then
                me.anim = idle_anim
                me.hitbox = hitbox
                global.enemy_hitbox = hitbox
                mset(64, 15, 6)
                mset(64, 16, 6)
                timer = timer_new(idle_dur)
                return "idle"
            end
        end,
        idle = function(me, entities)
            me.body.facing = sgn(entities[1].body.x - me.body.x)
            if timer() then
                me.anim = windup_anim
                timer = timer_new(windup_dur)
                return "windup"
            end
        end,
        windup = function(me, entities)
            if timer() then
                local top_fast = flr(rnd(2)) % 2 == 0
                add_fireball(me, entities, true, top_fast)
                add_fireball(me, entities, false, not top_fast)

                me.anim = attack_anim
                timer = timer_new(attack_dur)
                return "attack"
            end
        end,
        attack = function(me)
            if timer() then
                me.anim = idle_anim
                timer = timer_new(idle_dur_2)
                return "idle_2"
            end
        end,
        idle_2 = function(me, entities)
            if timer() then
                me.draw = draw_teleport
                timer = timer_new(0.125)
                return "pre_teleport"
            end
        end,
        pre_teleport = function(me, entities)
            if timer() then
                me.anim = inert_anim
                timer = timer_new(0.125)
                return "pre_teleport_2"
            end
        end,
        pre_teleport_2 = function(me, entities)
            if timer() then
                me.anim = nil
                me.hitbox = nil
                me.hurtbox = nil
                timer = timer_new(0.125)
                return "pre_teleport_3"
            end
        end,
        pre_teleport_3 = function(me, entities)
            if timer() then
                timer = timer_new(0.125)
                return "gone"
            end
        end,
        gone = function(me, entities)
            if timer() then
                local tx = flr(rnd(max_tx - min_tx)) + min_tx
                me.body.x = tx * 8
                me.draw = nil
                timer = timer_new(1)
                return "gone_2"
            end
        end,
        gone_2 = function(me)
            if timer() then
                me.draw = draw_teleport
                timer = timer_new(0.125)
                return "post_teleport"
            end
        end,
        post_teleport = function(me, entities)
            if timer() then
                me.anim = inert_anim
                me.hitbox = hitbox
                me.hurtbox = hurtbox
                timer = timer_new(0.125)
                return "post_teleport_2"
            end
        end,
        post_teleport_2 = function(me)
            if timer() then
                me.anim = idle_anim
                timer = timer_new(0.125)
                return "post_teleport_3"
            end
        end,
        post_teleport_3 = function(me)
            if timer() then
                me.draw = nil
                timer = timer_new(idle_dur)
                return "idle"
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0, -1),
        anim = inert_anim,
        update = state_machine_new("inert", state_map),
        on_death = function(me, entities)
            add(entities, nosferatu_new(x, y))
        end,
        on_player_death = function()
            global.enemy_hitbox = nil
            mset(64, 15, 0)
            mset(64, 16, 0)
        end
    }
end