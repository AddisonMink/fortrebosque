function timer_new(dur)
    local t = 0
    return function()
        if t < dur then
            t += 1 / 30
        else
            return true
        end
    end
end

function state_machine_new(initial_state, state_behavior_map)
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

function rects_overlap(rect1, rect2)
    return rect1.x < rect2.x + rect2.w
            and rect1.x + rect1.w > rect2.x
            and rect1.y < rect2.y + rect2.h
            and rect1.y + rect1.h > rect2.y
end

function room_position(rx, ry)
    return rx * 128, ry * 72
end

function print_controls(x, y)
    print("controls", x, y, 7)
    y += 8
    print("❎ - aTTACK", x, y, 7)
    y += 8
    print("🅾️ - jUMP", x, y, 7)
    y += 8
    print("⬅️➡️ - mOVE", x, y, 7)
    y += 8
    print("⬇️ - sWITCH sUBWEAPON", x, y, 7)
    y += 8
    print("⬆️+❎ - sUBWEAPON", x, y, 7)
end