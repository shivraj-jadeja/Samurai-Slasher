if (!instance_exists(controller)) exit;
if (is_dead) {
    death_steps++;
    vsp = min(vsp + RUN_GRAVITY, FALL_LIMIT); y += vsp;
    if ((death_steps >= 30 && bbox_top > room_height + 32) || death_steps >= DEATH_MAX_STEPS) {
        controller.state = RunState.RESTARTING;
        room_restart();
    }
    exit;
}
if (!sr_active(controller.state)) exit;

previous_right = bbox_right;
var _ground_before = place_meeting(x, y + 1, obj_solid_parent);
var _jump = keyboard_check_pressed(vk_space);
var _attack1 = keyboard_check_pressed(ord("Z"));
var _attack2 = keyboard_check_pressed(ord("X"));
if (DEV_BUILD && (controller.test_mode == "route" || controller.test_mode == "soak" || controller.test_mode == "replay")) {
    // Automated input at the normal 60 Hz: uses the same collisions/physics as keys.
    if (_ground_before) {
        var _pit = collision_point(bbox_right + 20, GROUND_Y + 1, obj_solid_parent, false, true) == noone;
        var _wall = collision_rectangle(bbox_right + 1, bbox_top, bbox_right + 30, bbox_bottom - 1, obj_solid_parent, false, true) != noone;
        _jump = _pit || _wall;
        if (controller.test_air_finish && controller.finish_x > 0 && controller.finish_x - bbox_right < 45 && controller.finish_x > bbox_right) _jump = true;
    }
    _attack1 = controller.elapsed_steps mod 91 == 0;
    _attack2 = controller.elapsed_steps mod 91 == 45;
}
if (_jump && _ground_before) { vsp = JUMP_SPEED; sub_y = 0; }
if (_attack1) sr_start_attack(1);
else if (_attack2) sr_start_attack(2);

if (place_meeting(x, y, obj_hazard_kill)) { sr_die(); exit; }
sr_move_axis(hsp, false);
if (is_dead) exit;
vsp = min(vsp + RUN_GRAVITY, FALL_LIMIT);
sr_move_axis(vsp, true);
if (is_dead) exit;
if (bbox_top > room_height + 32) { sr_die(); exit; }

on_ground = vsp >= 0 && place_meeting(x, y + 1, obj_solid_parent);
if (on_ground) {
    if (place_meeting(x, y + 1, obj_solid_gold) && form != SamuraiForm.MIDNIGHT) sr_apply_form(SamuraiForm.MIDNIGHT);
    else if (place_meeting(x, y + 1, obj_solid_skyblue) && form != SamuraiForm.NEON) sr_apply_form(SamuraiForm.NEON);
}

if (attack_kind != 0) {
    sr_hit_decor(obj_deco_tree_tall); sr_hit_decor(obj_deco_tree_cluster); sr_hit_decor(obj_deco_volcano);
} else if (on_ground) sr_animation(spr_run, 0.3);
else sr_animation(vsp < 0 ? spr_jump : spr_fall, 0.4);

if (on_ground) {
    if (controller.run_audio == noone || !audio_is_playing(controller.run_audio))
        controller.run_audio = audio_play_sound(snd_run_loop, 0, true);
} else { sr_stop_audio(controller.run_audio); controller.run_audio = noone; }
