-- #region sidle
function sidle_new(dx)
    return {
        t0 = 0,
        dx = 1
    }
end

function update_sidle(sidle, body)
    local dur = 1

    if time() - sidle.t0 > dur then
        sidle.t0 = time()
        sidle.dx *= -1
    end

    body.vel_x = sidle.dx
end
-- #endregion