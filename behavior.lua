function timed_behavior_new(dur, behavior)
    local t0 = 0

    return function(me, entities)
        if time() - t0 > dur then
            t0 = time()
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

function sidle_behavior_new()
    local t0 = 0
    local dx = 1
    local dur = 1

    return function(me)
        local body = me.body

        if time() - t0 > dur then
            t0 = time()
            dx *= -1
        end

        body.vel_x = dx
    end
end

