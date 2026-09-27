function sr_win() {
    if (!sr_active(state) || !instance_exists(player) || player.is_dead) return;
    state = RunState.WON;
    global.final_score = score; global.final_steps = elapsed_steps;
    global.final_seed = run_seed;
    global.test_mode = test_mode;
    sr_stop_audio(run_audio); run_audio = noone;
    sr_stop_audio(music_audio); music_audio = noone;
    player.attack_kind = 0; player.hsp = 0; player.vsp = 0; player.image_speed = 0;
    if (DEV_BUILD) show_debug_message("SR WON seed=" + string(run_seed) + " steps=" + string(elapsed_steps) + " score=" + string(score)
        + " grounded=" + string(player.on_ground) + " max_instances=" + string(test_max_instances) + " max_segments=" + string(test_max_segments));
    room_goto(rm_congrats);
}

function sr_draw_reset() {
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_set_alpha(1);
}

function sr_replay() { room_goto(Room1); }
