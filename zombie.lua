function zombie_behavior_new()
    -- constants
    local mound_anim = { frames = { 23 }, fps = 1 }
    local rise_anim = { frames = { 24 }, fps = 1 }
    local walk_anim = { frames = { 25, 26 }, fps = 1 }
    local min_x_dist = 32
    local min_y_dist = 16
    local rise_dur = 0.5
    local speed = 0.5

    -- state
    local timer = nil

    local state_map = {
        mound = function(me, entities)
            local player = entities[1]        
            local dx = abs(player.body.x - me.body.x)
            local dy = abs(player.body.y - me.body.y)

            me.anim = mound_anim

            if dx <= min_x_dist and dy <= min_y_dist then
                local facing = player.body.x > me.body.x and 1 or -1
                me.body.facing = facing
                timer = timer_new(rise_dur)
                me.anim = rise_anim
                return "rise"
            end
        end,
        rise = function(me)
            if timer() then
                me.body.vel_x = speed * me.body.facing
                me.anim = walk_anim
                me.hitbox = hitbox_new("enemy", 2)
                me.hurtbox = hurtbox_new("player", 1, { x = 2, y = 4, w = 4, h = 4 })
                return "walk"
            end
        end,
        walk = function(me)
            local offset = me.body.facing == 1 and 8 or 0
            local new_x = me.body.x + offset + me.body.vel_x
            if body_would_collide_x(me.body, new_x) then
                me.anim = rise_anim
                me.body.vel_x = 0
                timer = timer_new(rise_dur)
                return "sink"
            end
        end,
        sink = function(me)
            if timer() then
                me.anim = mound_anim
                timer = timer_new(rise_dur)
                return "submerge"
            end
        end,
        submerge = function(me, entities)
            if timer() then
                timer = nil
                del(entities, me)
            end
        end
    }

    return state_machine_new("mound", state_map)
end

function zombie_new(x, y)
    return {
        body = body_new(x, y, 0, 0, 1, true),
        update = zombie_behavior_new()
    }
end