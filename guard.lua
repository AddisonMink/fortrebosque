function guard_new(x, y)
    -- animations
    local walk_anim = anim_new({ 97, 98 })
    local turn_anim = anim_new(99)
    local windup_anim = anim_new(100)
    local attack_anim = anim_new(101)
    local weapon_anim = anim_new(102)

    -- constants
    local speed = 0.125
    local attack_range = 4
    local turn_dur = 0.5
    local windup_dur = 0.5
    local attack_dur = 0.25
    local weapon_speed = 2

    -- state
    local timer = nil

    -- local functions
    local function add_weapon(me, entities)
        local weapon = {
            body = body_new(me.body.x, me.body.y, 0, weapon_speed, me.body.facing),
            hurtbox = hurtbox_new("player", 1, { x = 4, y = 1, w = 3, h = 7 }),
            anim = weapon_anim
        }
        add(entities, weapon)
    end

    local function player_in_range(me, player)
        return abs(player.body.x - me.body.x) < attack_range
    end

    local state_map = {
        walk = function(me, entities)
            local player = entities[1]
            local next_x = me.body.x + (me.body.facing > 0 and 8 or -1)
            local next_y = me.body.y + 8

            local turn = point_would_collide(next_x, me.body.y, 0)
                    or not point_would_collide(next_x, next_y, 1)

            if player_in_range(me, player) then
                me.body.vel_x = 0
                me.anim = windup_anim
                timer = timer_new(windup_dur)
                return "windup"
            elseif turn then
                me.anim = turn_anim
                timer = timer_new(turn_dur)
                return "turn"
            else
                me.body.vel_x = me.body.facing * speed
            end
        end,
        turn = function(me, entities)
            local player = entities[1]

            if player_in_range(me, player) then
                me.anim = windup_anim
                me.body.facing *= -1
                timer = timer_new(windup_dur)
                return "windup"
            elseif timer() then
                me.body.facing *= -1
                me.anim = walk_anim
                return "walk"
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
        attack = function(me, entities)
            if timer() then
                me.anim = walk_anim
                return "walk"
            end
        end
    }

    return {
        body = body_new(x, y, speed, 0, 1, true),
        anim = walk_anim,
        hurtbox = hurtbox_new("player", 1, { x = 3, y = 3, w = 2, h = 2 }),
        hitbox = hitbox_new("enemy", 2),
        update = state_machine_new("walk", state_map)
    }
end