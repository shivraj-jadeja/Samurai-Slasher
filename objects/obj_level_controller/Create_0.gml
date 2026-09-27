game_set_speed(SIM_HZ, gamespeed_fps);
display_set_gui_size(640, 360);
window_set_caption("Samurai Runner");
window_set_size(1280, 720);
gpu_set_texfilter(true); // Original compiled setting, intentionally preserved.
state = RunState.PLAYING;
elapsed_steps = 0; score = 0; finish_x = -1; next_spawn_x = 0;
global.final_score = 0; global.final_steps = 0; global.final_seed = 0;
segments = ds_queue_create();
run_audio = noone; music_audio = noone;
run_seed = 0; force_segment = -1; test_mode = ""; test_air_finish = false;
test_max_instances = 0; test_max_segments = 0;
finish_after_steps = FINISH_STEPS;
if (DEV_BUILD) {
    // Developer configuration only: --seed=12345 and --segment=0..3.
    for (var _i = 1; _i <= parameter_count(); ++_i) {
        var _arg = parameter_string(_i);
        if (string_pos("--seed=", _arg) == 1) run_seed = real(string_delete(_arg, 1, 7));
        if (string_pos("--segment=", _arg) == 1) force_segment = clamp(real(string_delete(_arg, 1, 10)), 0, 3);
        if (string_pos("--test=", _arg) == 1) test_mode = string_delete(_arg, 1, 7);
        if (_arg == "--air-finish") test_air_finish = true;
    }
}
if (run_seed == 0) { randomize(); run_seed = random_get_seed(); }
if (DEV_BUILD && test_mode == "soak") finish_after_steps = SIM_HZ * 300;
random_set_seed(run_seed);
// Safe opening is the documented robustness change; subsequent choices are uniform.
sr_spawn_segment(-1);
repeat (3) sr_spawn_segment(force_segment < 0 ? irandom(3) : force_segment);
player = instance_create_layer(32, 496, "Instances", obj_player_samurai);
player.controller = id; player.previous_right = player.bbox_right;
start_x = player.x; furthest_x = start_x;
camera_set_view_pos(view_camera[0], 0, 360);
// Room cleanup owns handles; defensive resource stops prevent legacy duplicates.
audio_stop_sound(snd_music_loop); audio_stop_sound(snd_run_loop);
music_audio = audio_play_sound(snd_music_loop, 0, true);
if (DEV_BUILD) show_debug_message("SR START seed=" + string(run_seed));
if (DEV_BUILD && test_mode == "checks") sr_test_checks();
if (DEV_BUILD && (test_mode == "retries" || test_mode == "replay")) {
    if (!variable_global_exists("qa_cycle")) global.qa_cycle = 0; else global.qa_cycle++;
    sr_assert(player.form == SamuraiForm.RED && player.vsp == 0 && player.attack_kind == 0 && score == 0 && elapsed_steps == 0 && finish_x == -1, "retry/replay resets player and session");
    sr_assert(instance_number(obj_player_samurai) == 1 && instance_number(obj_level_controller) == 1 && instance_number(obj_level_end) == 0 && ds_queue_size(segments) == 4, "retry/replay clears old world and goal");
    if (global.qa_cycle > 0) sr_assert(!audio_is_playing(global.qa_previous_music), "previous music handle stopped");
    global.qa_previous_music = music_audio;
    show_debug_message("SR CYCLE " + string(global.qa_cycle));
    if (test_mode == "retries" && global.qa_cycle == 5) { show_debug_message("SR FIVE DEATH RETRIES PASS"); game_end(); }
    // First two replay runs keep the full 60-second schedule; last two exercise reset/transition.
    if (test_mode == "replay" && global.qa_cycle >= 2) sr_schedule_finish();
}
