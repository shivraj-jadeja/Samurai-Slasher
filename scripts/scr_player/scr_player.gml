function sr_apply_form(_form) {
    form = _form;
    switch (form) {
        case SamuraiForm.RED:
            spr_idle = spr_samurai_red_idle; spr_run = spr_samurai_red_run;
            spr_jump = spr_samurai_red_jump; spr_fall = spr_samurai_red_fall;
            spr_atk1 = spr_samurai_red_attack1; spr_atk2 = spr_samurai_red_attack2;
            spr_death = spr_samurai_red_death;
            break;
        case SamuraiForm.MIDNIGHT:
            spr_idle = spr_samurai_mid_idle; spr_run = spr_samurai_mid_run;
            spr_jump = spr_samurai_mid_jump; spr_fall = spr_samurai_mid_fall;
            spr_atk1 = spr_samurai_mid_attack1; spr_atk2 = spr_samurai_mid_attack2;
            spr_death = spr_samurai_mid_death;
            break;
        case SamuraiForm.NEON:
            spr_idle = spr_samurai_neon_idle; spr_run = spr_samurai_neon_run;
            spr_jump = spr_samurai_neon_jump; spr_fall = spr_samurai_neon_fall;
            spr_atk1 = spr_samurai_neon_attack1; spr_atk2 = spr_samurai_neon_attack2;
            spr_death = spr_samurai_neon_death;
            break;
    }
    // Same rectangle across every form/animation, including both swords.
    mask_index = spr_samurai_red_run;
    if (attack_kind != 0) {
        var _frame = image_index;
        sprite_index = attack_kind == 1 ? spr_atk1 : spr_atk2;
        image_index = _frame; // Remap appearance without restarting the swing.
    }
}

function sr_animation(_sprite, _rate) {
    if (sprite_index != _sprite) { sprite_index = _sprite; image_index = 0; }
    image_speed = _rate;
}

function sr_start_attack(_kind) {
    if (is_dead || attack_kind != 0) return;
    attack_kind = _kind;
    sprite_index = _kind == 1 ? spr_atk1 : spr_atk2;
    image_index = 0; image_speed = 0.6;
    audio_play_sound(snd_katana, 1, false);
}

function sr_die() {
    if (is_dead || !instance_exists(controller) || !sr_active(controller.state)) return;
    is_dead = true; attack_kind = 0; death_steps = 0;
    controller.state = RunState.DEAD;
    sr_stop_audio(controller.run_audio); controller.run_audio = noone;
    sprite_index = spr_death; image_index = 0; image_speed = 0.4;
    vsp = -6; sub_x = 0; sub_y = 0;
}

/// Integer collision probes with signed subpixel accumulators. Maximum 12 probes/axis.
/// Half pixels accumulate instead of being rounded away from zero.
function sr_move_axis(_amount, _vertical) {
    if (_vertical) sub_y += clamp(_amount, -FALL_LIMIT, FALL_LIMIT);
    else sub_x += clamp(_amount, -FALL_LIMIT, FALL_LIMIT);
    var _remainder = _vertical ? sub_y : sub_x;
    var _whole = sign(_remainder) * floor(abs(_remainder));
    if (_vertical) sub_y -= _whole; else sub_x -= _whole;
    var _direction = sign(_whole);
    repeat (abs(_whole)) {
        var _dx = _vertical ? 0 : _direction;
        var _dy = _vertical ? _direction : 0;
        if (place_meeting(x + _dx, y + _dy, obj_solid_parent)) {
            if (_vertical) { vsp = 0; sub_y = 0; } else sub_x = 0;
            break;
        }
        x += _dx; y += _dy;
        // Swept one-pixel checks preserve thin/padded hazard bounds.
        if (place_meeting(x, y, obj_hazard_kill)) { sr_die(); break; }
    }
}

function sr_hit_decor(_object) {
    // Short forward sword area, measured from the physical body, not padded origin.
    var _target = collision_rectangle(bbox_right - 4, bbox_top + 8,
        bbox_right + 34, bbox_bottom, _object, false, true);
    if (instance_exists(_target)) with (_target) instance_destroy();
    // Destroyed targets cannot receive repeated hits from this or later attack frames.
}
