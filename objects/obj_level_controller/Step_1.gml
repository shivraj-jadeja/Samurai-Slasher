if (keyboard_check_pressed(vk_escape)) { game_end(); exit; }
if (!sr_active(state) || !instance_exists(player)) exit;
if (elapsed_steps >= finish_after_steps && state == RunState.PLAYING) sr_schedule_finish();
repeat (4) {
    if (next_spawn_x >= player.x + SEGMENT_WIDTH * 3) break;
    sr_spawn_segment(state == RunState.FINISH_APPROACH ? -1 : (force_segment < 0 ? irandom(3) : force_segment));
}
sr_clean_segments();
