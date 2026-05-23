function merman_new(x, y)
    -- animations
    local idle_anim = anim_new({ 64 }, 1, "tall")
    local submerge_anim_1 = anim_new({ 67 }, 1, "tall")
    local submerge_anim_2 = anim_new({ 68 }, 8, "tall")
    local submerged_anim = anim_new({ 69, 70 }, 6)
    local windup_anim = anim_new({ 65 }, 1, "tall")
    local attack_anim = anim_new({ 66 }, 1, "tall")
    local fireball_anim = anim_new({ 85, 86 }, 6)

    -- constants
    local idle_dur = 0.5
    local windup_dur = 0.5
    local attack_dur = 0.5
    local fireball_speed = 2
    local x_locs = { x - 4, x + 20, x + 44, x + 68 }
    local tx = flr(x / 8)
    local ty = flr(y / 8)
    local room_tx = flr(tx / 16) * 16
    local room_ty = flr(ty / 9) * 9
    local player_x_threshold = room_tx + 14 * 8
    local pickup_x = 8 * 8
    local pickup_y = 23 * 8
    local key = tx .. "," .. ty

    -- state
    local hitbox = hitbox_new("enemy", 5, { x = 2, y = -4, w = 6, h = 6 })
    local hurtbox = hurtbox_new("player", 1, { x = 3, y = -2, w = 4, h = 10 })
    local timer = nil

    -- local functions
    local function add_fireball(me, entities)
        local offset = me.body.facing == 1 and 4 or -4
        local facing = me.body.facing

        local fireball = {
            body = body_new(me.body.x + offset, me.body.y - 4, facing * fireball_speed, 0, facing, false),
            hurtbox = hurtbox_new("player", 1, { x = 2, y = 2, w = 4, h = 4 }),
            anim = fireball_anim
        }

        add(entities, fireball)
    end

    -- state map

    local state_map = {
        init = function(me, entities)
            local player = entities[1]
            me.hitbox = nil
            me.hurtbox = nil
            me.anim = submerged_anim
            if player.body.x < player_x_threshold then
                global.enemy_hitbox = hitbox
                me.hitbox = hitbox
                me.hurtbox = hurtbox
                me.anim = submerge_anim_2
                timer = timer_new(0.125)
                mset(15, 23, 6)
                return "emerge_1"
            end
        end,
        idle = function(me, entities)
            local player = entities[1]
            me.body.facing = player.body.x < me.body.x and -1 or 1
            me.anim.flip_x = me.body.facing < 0

            if timer() then
                timer = timer_new(windup_dur)
                me.anim = windup_anim
                return "windup"
            end
        end,
        windup = function(me, entities)
            if timer() then
                timer = timer_new(attack_dur)
                me.anim = attack_anim
                add_fireball(me, entities)
                return "attack"
            end
        end,
        attack = function(me)
            if timer() then
                timer = timer_new(idle_dur)
                me.anim = idle_anim
                return "idle_2"
            end
        end,
        idle_2 = function(me)
            if timer() then
                timer = timer_new(0.125)
                me.anim = submerge_anim_1
                me.hitbox = nil
                me.hurtbox = nil
                return "submerge_1"
            end
        end,
        submerge_1 = function(me)
            if timer() then
                timer = timer_new(0.125)
                me.anim = submerge_anim_2
                return "submerge_2"
            end
        end,
        submerge_2 = function(me)
            if timer() then
                timer = timer_new(2)
                me.anim = submerged_anim
                me.body.x = x_locs[flr(rnd(4)) + 1]
                return "submerged"
            end
        end,
        submerged = function(me)
            if timer() then
                timer = timer_new(0.125)
                me.anim = submerge_anim_2
                return "emerge_1"
            end
        end,
        emerge_1 = function(me)
            if timer() then
                timer = timer_new(0.125)
                me.anim = submerge_anim_1
                return "emerge_2"
            end
        end,
        emerge_2 = function(me)
            if timer() then
                timer = timer_new(idle_dur)
                me.anim = idle_anim
                me.hitbox = hitbox
                me.hurtbox = hurtbox
                return "idle"
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0, 1, false),
        hitbox = hitbox_new("enemy", 3, { x = 2, y = -4, w = 6, h = 6 }),
        hurtbox = hurtbox_new("player", 1, { x = 2, y = -4, w = 6, h = 12 }),
        anim = idle_anim,
        update = state_machine_new("init", state_map),
        on_death = function(me, entities)
            global.enemy_hitbox = nil
            global.dont_respawn[key] = true
            add_heart_pickup(pickup_x, pickup_y, entities)
        end,
        on_player_death = function()
            mset(15, 23, 0)
            global.enemy_hitbox = nil
        end
    }
end