function knight_new(x, y)
    local walk_anim = { frames = { 34, 35, 36, 35 }, fps = 1, tall = true }

    return {
        body = body_new(x, y - 8, 0, 0, 1, true),
        anim = walk_anim
    }
end