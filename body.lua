function body_new(x, y, vel_x, vel_y, facing, solid, pinned_body)
    return {
        x = x,
        y = y,
        vel_x = vel_x or 0,
        vel_y = vel_y or 0,
        facing = facing or 1,
        solid = solid,
        pinned_body = pinned_body
    }
end

function point_would_collide(x, y, dy)
    local tx, ty = flr(x / 8), flr(y / 8)
    local tile = mget(tx, ty)
    return fget(tile, 0)
            or dy > 0 and fget(tile, 1) and flr(y % 8) == 0
end

function body_would_collide_y(body, new_y, dy)
    local left = body.x
    local right = body.x + 7
    return point_would_collide(left, new_y, dy)
            or point_would_collide(right, new_y, dy)
end

function body_would_collide_x(body, new_x)
    local top = body.y
    local bottom = body.y + 7
    return point_would_collide(new_x, top, 0)
            or point_would_collide(new_x, bottom, 0)
end

function _nudge_body_y(body, dy)
    local offset = dy > 0 and 7 or 0

    if body_would_collide_y(body, body.y + dy + offset, dy) then
        body.vel_y = 0
        return true
    else
        body.y += dy
    end
end

function _nudge_body_x(body, dx)
    local offset = dx > 0 and 7 or 0

    if body_would_collide_x(body, body.x + dx + offset) then
        return true
    else
        body.x += dx
    end
end

function _move_body_y(body)
    if not body.solid then
        body.y += body.vel_y
        return
    end

    local steps = flr(abs(body.vel_y))
    local fraction = abs(body.vel_y) - steps
    local dy = sgn(body.vel_y)

    for i = 1, steps do
        if _nudge_body_y(body, dy) then
            return
        end
    end
    if fraction > 0 then
        _nudge_body_y(body, fraction * dy)
    end
end

function _move_body_x(body)
    if not body.solid then
        body.x += body.vel_x
        return
    end

    local steps = flr(abs(body.vel_x))
    local fraction = abs(body.vel_x) - steps
    local dx = sgn(body.vel_x)

    for i = 1, steps do
        if _nudge_body_x(body, dx) then
            return
        end
    end
    if fraction > 0 then
        _nudge_body_x(body, fraction * dx)
    end
end

function update_body(body)
    local g = 0.2

    if body.pinned_body then
        local pinned = body.pinned_body
        body.x = pinned.body.x + pinned.offset_x
        body.y = pinned.body.y + pinned.offset_y
        return
    end

    if body.solid then
        body.vel_y += g
    end

    _move_body_x(body)
    _move_body_y(body)

    body.grounded = body.solid and body_would_collide_y(body, body.y + 8, 1)
end