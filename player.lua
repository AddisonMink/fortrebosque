function player_new(x, y)
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
    local knife_speed = 4

    -- state
    local timer = nil
    local weapon = nil

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
            hurtbox = hurtbox_new("enemy", 1, { x = 0, y = 2, w = 8, h = 4 }),
            anim = weapon_anim
        }
    end

    local function add_knife(me, entities)
        local offset_x = me.body.facing == 1 and 4 or -4
        local x = me.body.x + offset_x
        local y = me.body.y

        local knife = {
            body = body_new(x, y, knife_speed * me.body.facing, 0, me.body.facing),
            hurtbox = hurtbox_new("enemy", 1, { x = 2, y = 4, w = 6, h = 2 }),
            anim = { frames = { 5 }, fps = 1 }
        }
        add(entities, knife)
    end

    local function handle_attacks(me, entities, state_ref)
        if btnp(5) and btn(2) and global.knife and global.mp >= 1 then
            global.mp -= 1
            me.anim = windup_anim
            timer = timer_new(attack_windup_dur)
            state_ref.state = "throw_windup"
        elseif btnp(5) then
            me.anim = windup_anim
            timer = timer_new(attack_windup_dur)
            state_ref.state = "attack_windup"
        end
        return true
    end

    local state_map = {
        idle = function(me, entities)
            me.body.vel_x = 0
            local state_ref = {}

            if not me.body.grounded then
                me.anim = jump_anim
                return "jump"
            elseif btnp(4) then
                me.body.vel_y = jump_vel
                me.anim = jump_anim
                return "jump"
            elseif handle_attacks(me, entities, state_ref) and state_ref.state then
                return state_ref.state
            elseif btn(0) or btn(1) then
                local dx = btn(0) and -1 or 1
                me.body.vel_x = dx
                me.anim = walk_anim
                me.body.facing = dx
                return "walk"
            end
        end,
        walk = function(me, entities)
            local state_ref = {}

            if not me.body.grounded then
                me.body.vel_x = 0
                me.anim = jump_anim
                return "jump"
            elseif btnp(4) then
                me.body.vel_y = jump_vel
                me.anim = jump_anim
                return "jump"
            elseif handle_attacks(me, entities, state_ref) and state_ref.state then
                return state_ref.state
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
        throw_windup = function(me, entities)
            if me.body.grounded then me.body.vel_x = 0 end

            if timer() then
                add_knife(me, entities)
                me.anim = attack_anim
                timer = timer_new(attack_dur)
                return "throw"
            end
        end,
        throw = function(me, entities)
            if me.body.grounded then me.body.vel_x = 0 end

            if timer() then
                me.anim = idle_anim
                return "idle"
            end
        end,
        jump = function(me, entities)
            local state_ref = {}
            if me.body.grounded then
                me.anim = idle_anim
                return "idle"
            elseif handle_attacks(me, entities, state_ref) and state_ref.state then
                return state_ref.state
            elseif btn(0) or btn(1) then
                local dx = btn(0) and -1 or 1
                me.body.facing = dx
            end
        end
    }

    return {
        body = body_new(x, y, 0, 0, 1, true),
        hitbox = hitbox_new("player", 3),
        anim = { frames = { 16 }, fps = 1 },
        update = state_machine_new("idle", state_map),
        on_death = function(me, entities)
            if weapon then
                del(entities, weapon)
            end
        end
    }
end