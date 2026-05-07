-- #region hitbox
function hitbox_new(layer, hp, rect)
    return {
        layer = layer,
        hp = hp,
        hp_max = hp,
        rect = rect or { x = 0, y = 0, w = 8, h = 8 }
    }
end

function hurtbox_new(layer, damage, rect)
    return {
        layer = layer,
        damage = damage,
        rect = rect or { x = 0, y = 0, w = 8, h = 8 }
    }
end

function _apply_hit(hurtbox, entity, entities)
    entity.hitbox.hp -= hurtbox.damage
    entity.hitbox.invuln_timer = timer_new(0.5)

    if entity.hitbox.hp <= 0 then
        del(entities, entity)
    end
end

function update_hurtbox(entity, entities)
    local hurt_rect = {
        x = entity.body.x + entity.hurtbox.rect.x,
        y = entity.body.y + entity.hurtbox.rect.y,
        w = entity.hurtbox.rect.w,
        h = entity.hurtbox.rect.h
    }

    for e in all(entities) do
        if e.hitbox and e.hitbox.layer == entity.hurtbox.layer then
            local hit_rect = {
                x = e.body.x + e.hitbox.rect.x,
                y = e.body.y + e.hitbox.rect.y,
                w = e.hitbox.rect.w,
                h = e.hitbox.rect.h
            }

            local hit = rects_overlap(hurt_rect, hit_rect)
                    and not e.hitbox.invuln_timer

            if hit then
                _apply_hit(entity.hurtbox, e, entities)
            end
        end
    end
end

function update_hitbox(entity)
    if entity.hitbox.invuln_timer and entity.hitbox.invuln_timer() then
        entity.hitbox.invuln_timer = nil
    end
end
-- #endregion

-- #region animation
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
    else
        spr(s, body.x, body.y, 1, 1, f)
    end
end
-- #endregion