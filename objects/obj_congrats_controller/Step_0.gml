if (keyboard_check_pressed(vk_escape)) { game_end(); exit; }
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("R"))) sr_replay();
if (DEV_BUILD && (global.test_mode == "route" || global.test_mode == "soak" || global.test_mode == "replay")) {
    test_wait++;
    if (final_score != global.final_score || final_steps != global.final_steps || instance_exists(obj_player_samurai) || audio_is_playing(snd_run_loop))
        show_error("Results state changed or gameplay/audio leaked into results", true);
    var _hold = global.test_mode == "replay" && global.qa_cycle == 0 ? 7200 : 120;
    if (test_wait == _hold) {
        show_debug_message("SR RESULTS stable PASS steps=" + string(_hold));
        if (global.test_mode == "replay" && global.qa_cycle < 3) sr_replay();
        else { show_debug_message("SR SESSION TEST COMPLETE"); game_end(); }
    }
}
