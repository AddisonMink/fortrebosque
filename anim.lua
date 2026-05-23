-- #region animation
function anim_new(frames, fps, flag)
    local anim = {
        frames = type(frames) == "table" and frames or { frames },
        fps = fps or 1
    }
    if flag then anim[flag] = true end
    return anim
end

function draw_anim(a, body, hitbox)
    local n, i, s, f
    local flashing = hitbox and hitbox.invuln_timer
    local flash = flashing and flr(time() * 10) % 2 == 0

    if flash then
        return
    end

    n = #a.frames
    i = time() * a.fps
    i = flr(i) % n + 1
    s = a.frames[i]
    f = body.facing < 0

    if a.tall then
        spr(s, body.x, body.y - 8, 1, 2, f)
    elseif a.big then
        spr(s, body.x, body.y, 2, 2, f)
    else
        spr(s, body.x, body.y, 1, 1, f)
    end
end
-- #endregion