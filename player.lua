function player_behavior_new()
    -- constants
    local idle_anim = { frames = { 16 }, fps = 1 }
    local walk_anim = { frames = { 16, 17, 18, 17 }, fps = 4 }
    local windup_anim = { frames = { 20 }, fps = 1 }
    local attack_anim = { frames = { 21 }, fps = 1 }
    local jump_anim = { frames = { 19 }, fps = 1 }
    local weapon_anim = { frames = { 22 }, fps = 1 }
    local jump_vel = -2.1
    local attack_windup_dur = 0.25
    local attack_dur = 0.25

    -- local functions
    local function weapon_new(player_body)
        local offset_x = player_body.facing == 1 and 8 or -8
        local x = player_body.x + offset_x
        local y = player_body.y

        return {
            body = body_new(
                0, 0, 0, 0, player_body.facing, false,
                { body = player_body, offset_x = offset_x, offset_y = 0 }
            ),
            hurtbox = hurtbox_new("enemy", 1),
            anim = weapon_anim
        }
    end

    -- state
    local timer = nil
    local weapon = nil

    local state_map = {
        idle = function(me, entities)
            me.body.vel_x = 0

            if not me.body.grounded then
                me.anim = jump_anim
                return "jump"
            elseif btnp(4) then
                me.body.vel_y = jump_vel
                me.anim = jump_anim
                return "jump"
            elseif btnp(5) then
                me.anim = windup_anim
                timer = timer_new(attack_windup_dur)
                return "attack_windup"
            elseif btn(0) or btn(1) then
                local dx = btn(0) and -1 or 1
                me.body.vel_x = dx
                me.anim = walk_anim
                me.body.facing = dx
                return "walk"
            end
        end,
        walk = function(me, entities)
            if not me.body.grounded then
                me.body.vel_x = 0
                me.anim = jump_anim
                return "jump"
            elseif btnp(4) then
                me.body.vel_y = jump_vel
                me.anim = jump_anim
                return "jump"
            elseif btnp(5) then
                me.anim = windup_anim
                timer = timer_new(0.25)
                return "attack_windup"
            elseif not (btn(0) or btn(1)) then
                me.body.vel_x = 0
                me.anim = idle_anim
                return "idle"
            else
                local dx = btn(0) and -1 or 1
                me.body.vel_x = dx
                me.anim = walk_anim
                me.body.facing = dx
            end
        end,
        attack_windup = function(me, entities)
            if me.body.grounded then me.body.vel_x = 0 end

            if timer() then
                me.anim = attack_anim
                timer = timer_new(attack_dur)
                weapon = weapon_new(me.body)
                add(entities, weapon)
                return "attack"
            end
        end,
        attack = function(me, entities)
            if me.body.grounded then me.body.vel_x = 0 end

            if timer() then
                me.anim = idle_anim
                del(entities, weapon)
                weapon = nil
                return "idle"
            end
        end,
        jump = function(me, entities)
            if me.body.grounded then
                me.anim = idle_anim
                return "idle"
            elseif btnp(5) then
                me.anim = windup_anim
                timer = timer_new(attack_windup_dur)
                return "attack_windup"
            elseif btn(0) or btn(1) then
                local dx = btn(0) and -1 or 1
                me.body.facing = dx
            end
        end
    }

    return state_machine_new("idle", state_map)
end

player = {
    body = body_new(16, 48, 0, 0, 1, true),
    hitbox = hitbox_new("player", 3),
    anim = { frames = { 16 }, fps = 1 },
    update = player_behavior_new()
}