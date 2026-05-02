function timed_behavior_new(dur, behavior)
    local t_ref = { t = 0 }

    return function(me, entities)
        t_ref.t += 1 / 30
        if t_ref.t > dur then
            t_ref.t = 0
            return behavior(me, entities)
        end
    end
end

function parallel_behavior_new(behaviors)
    return function(me, entities)
        for b in all(behaviors) do
            b(me, entities)
        end
    end
end

function sequence_behavior_new(behaviors)
    return function(me, entities)
        for b in all(behaviors) do
            local result = b(me, entities)
            if result then
                return result
            end
        end
    end
end

function state_machine_behavior_new(initial_state, state_behavior_map)
    local state = initial_state

    return function(me, entities)
        local behavior = state_behavior_map[state]
        if behavior then
            local new_state = behavior(me, entities)
            if new_state then
                state = new_state
            end
        end
    end
end

function sidle_behavior_new()
    local dx = 1

    return timed_behavior_new(
        1, function(me)
            dx *= -1
            me.body.vel_x = dx
        end
    )
end