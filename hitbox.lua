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