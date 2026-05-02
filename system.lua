-- #region body
function body_new(x, y, vel_x, vel_y, facing, solid)
    return {
        x = x,
        y = y,
        vel_x = vel_x or 0,
        vel_y = vel_y or 0,
        facing = facing or 1,
        solid = solid
    }
end

function update_body(body)
    local g = 0.2

    if body.solid then
        body.vel_y += g
    end

    body.x += body.vel_x
    body.y += body.vel_y
end
-- #endregion