if (!instance_exists(player)) exit;
var _camera = view_camera[0];
var _world_width = (DEV_BUILD && test_mode == "soak") ? max(room_width, player.x + 640) : room_width;
camera_set_view_pos(_camera, clamp(player.x - 320, 0, _world_width - 640), clamp(player.y - 180, 0, room_height - 360));
if (!sr_active(state) || player.is_dead) exit;
elapsed_steps++;
if (DEV_BUILD) {
    test_max_instances = max(test_max_instances, instance_count);
    test_max_segments = max(test_max_segments, ds_queue_size(segments));
    if (test_mode != "" && elapsed_steps mod 600 == 0)
        show_debug_message("SR ROUTE step=" + string(elapsed_steps) + " x=" + string(player.x) + " segments=" + string(ds_queue_size(segments)));
    if (test_mode == "retries" && elapsed_steps == 120) {
        with (player) { sr_apply_form(SamuraiForm.NEON); sr_start_attack(2); sr_die(); }
        exit;
    }
}
furthest_x = max(furthest_x, player.x);
score = floor(max(0, furthest_x - start_x) * SCORE_PER_PIXEL);
// Player Step resolves lethal contact first. Both grounded and airborne crossings win.
if (state == RunState.FINISH_APPROACH && player.previous_right < finish_x && player.bbox_right >= finish_x) sr_win();
