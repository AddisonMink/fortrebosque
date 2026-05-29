function player_new(x, y)
    -- animations
    local idle_anim = anim_new(16)
    local walk_anim = anim_new({ 16, 17, 18, 17 }, 4)
    local windup_anim = anim_new(20)
    local attack_anim = anim_new(21)
    local jump_anim = anim_new(19)
    local weapon_anim = anim_new(22)
    local knife_anim = anim_new(5)
    local axe_anim = anim_new({ 62, 115 }, 6)
    local fire_anim = anim_new({ 118, 119 }, 4)
    local water_anim = anim_new(117)

    -- constants
    local hp_max = global.mode == "easy" and 5 or 3
    local jump_vel = -2.1
    local attack_windup_dur = 0.25
    local attack_dur = 0.25
    local knife_speed = 4
    local axe_speed_x = 1
    local axe_vel_y = -4

    -- state
    local timer = nil
    local weapon = nil
    local add_subweapon = nil

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

    local function destroy_on_wall_collision(me, entities)
        local collide = point_would_collide(me.body.x, me.body.y, 0)
                or point_would_collide(me.body.x + 7, me.body.y, 0)
                or point_would_collide(me.body.x, me.body.y + 7, 0)
                or point_would_collide(me.body.x + 7, me.body.y + 7, 0)
        if collide then
            del(entities, me)
            return true
        end
    end

    local function add_knife(me, entities)
        local offset_x = me.body.facing == 1 and 4 or -4
        local x = me.body.x + offset_x
        local y = me.body.y

        local knife = {
            body = body_new(x, y, knife_speed * me.body.facing, 0, me.body.facing),
            hurtbox = hurtbox_new("enemy", 1, { x = 2, y = 4, w = 6, h = 2 }),
            anim = knife_anim,
            update = destroy_on_wall_collision
        }
        add(entities, knife)
    end

    local function add_axe(me, entities)
        local offset_x = me.body.facing == 1 and 4 or -4
        local x = me.body.x + offset_x
        local y = me.body.y

        local axe = {
            body = body_new(x, y, axe_speed_x * me.body.facing, axe_vel_y, me.body.facing),
            hurtbox = hurtbox_new("enemy", 1, { x = 2, y = 2, w = 4, h = 4 }),
            anim = axe_anim,
            update = function(me)
                me.body.vel_y += 0.2
                destroy_on_wall_collision(me, entities)
            end
        }
        add(entities, axe)
    end

    local function add_fire(me, entities)
        local timer = timer_new(1)
        local y = flr(me.body.y / 8) * 8

        local fire = {
            body = body_new(me.body.x, y, 0, 0, me.body.facing),
            hurtbox = hurtbox_new("enemy", 1, { x = 2, y = -2, w = 4, h = 10 }),
            anim = fire_anim,
            update = function(me)
                if timer() then
                    del(entities, me)
                end
            end
        }

        add(entities, fire)
    end

    local function add_water(me, entities)
        local offset_x = me.body.facing == 1 and 4 or -4
        local x = me.body.x + offset_x
        local y = me.body.y

        local water = {
            body = body_new(x, y, axe_speed_x * me.body.facing, -1, me.body.facing),
            hurtbox = hurtbox_new("enemy", 1, { x = 2, y = 2, w = 4, h = 4 }),
            anim = water_anim,
            update = function(me, entities)
                me.body.vel_y += 0.2
                if destroy_on_wall_collision(me, entities) then
                    add_fire(me, entities)
                end
            end
        }
        add(entities, water)
    end

    local function handle_attacks(me, entities, state_ref)
        add_subweapon = nil
        local subweapon_name = global.subweapons[global.subweapon_index]

        add_subweapon = subweapon_name
                and (subweapon_name == "knife" and add_knife
                    or subweapon_name == "axe" and add_axe
                    or subweapon_name == "water" and add_water)

        if btnp(5) and btn(2) and add_subweapon and global.mp >= 1 then
            global.mp -= 1
            me.anim = windup_anim
            timer = timer_new(attack_windup_dur)
            state_ref.state = "throw_windup"
        elseif btnp(3) then
            global.subweapon_index = (global.subweapon_index % #global.subweapons) + 1
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
                add_subweapon(me, entities)
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
        hitbox = hitbox_new("player", hp_max, { x = 2, y = 2, w = 4, h = 4 }),
        anim = { frames = { 16 }, fps = 1 },
        update = state_machine_new("idle", state_map),
        on_death = function(me, entities)
            if weapon then
                del(entities, weapon)
            end
        end
    }
end