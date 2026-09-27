/// Developer-only in-engine regression checks. Never called in Default builds.
function sr_assert(_condition, _label) {
    if (!_condition) { show_debug_message("SR CHECK FAILED: " + _label); show_error("SR CHECK FAILED: " + _label, true); }
    show_debug_message("SR CHECK PASS: " + _label);
}

function sr_test_checks() {
    sr_assert(instance_number(obj_player_samurai) == 1 && instance_number(obj_level_controller) == 1, "single controller/player");
    sr_assert(player.form == SamuraiForm.RED && score == 0 && elapsed_steps == 0, "explicit clean run state");
    sr_assert(ds_queue_size(segments) == 4, "four prewarmed segments");
    sr_assert(sprite_get_xoffset(spr_samurai_red_run) == 100 && sprite_get_yoffset(spr_samurai_red_run) == 200, "original character origin");
    sr_assert(sprite_get_speed(spr_samurai_red_run) == 30 && player.image_speed == 0.3, "native 30 FPS and run multiplier");
    // Use a remote arena in the actual room, leaving the procedural slice intact.
    var _solid = instance_create_layer(15000, 640, "Instances", obj_solid_gold);
    with (player) {
        x = 15000; y = 718; sub_x = 0; sub_y = 0; vsp = 0;
        show_debug_message("SR BBOX " + string(bbox_left) + "," + string(bbox_top) + "," + string(bbox_right) + "," + string(bbox_bottom));
        // Modern collision mode exposes right/bottom edges one past inclusive source bounds.
        sr_assert(bbox_left == 14972 && bbox_right == 15018 && bbox_top == 592 && bbox_bottom == 640, "stable run movement rectangle");
        sr_assert(place_meeting(x, y + 1, obj_solid_parent), "gold is solid ground");
        sr_assert(!place_meeting(x, y, obj_hazard_kill), "ordinary solids are nonlethal");
        var _oldx = x;
        repeat (8) sr_move_axis(0.25, false);
        sr_assert(x == _oldx + 2 && sub_x == 0, "fractional horizontal movement terminates and accumulates");
        x = 15000; y = 400; sub_y = 0; vsp = 0;
        sr_move_axis(0.5, true); sr_assert(y == 400, "half-pixel remainder retained");
        sr_move_axis(0.5, true); sr_assert(y == 401, "two half pixels become one pixel");
        y = 718; vsp = 12; sr_move_axis(vsp, true);
        sr_assert(y == 718 && vsp == 0, "downward ground collision bounded");
        // Actual landing during each attack, then real Animation End event.
        for (var _kind = 1; _kind <= 2; ++_kind) {
            for (var _form = SamuraiForm.MIDNIGHT; _form <= SamuraiForm.NEON; ++_form) {
                attack_kind = 0; sr_apply_form(SamuraiForm.RED); sr_start_attack(_kind);
                image_index = 2.5;
                var _platform = instance_create_layer(16000, 640, "Instances", _form == SamuraiForm.MIDNIGHT ? obj_solid_gold : obj_solid_skyblue);
                x = 16000; y = 717; hsp = 0; vsp = 2; sub_y = 0;
                event_perform(ev_step, ev_step_normal);
                sr_assert(form == _form && on_ground, "actual landing transforms during either attack");
                sr_assert(attack_kind == _kind && image_index == 2.5 && mask_index == spr_samurai_red_run, "form change preserves attack progress and mask");
                with (_platform) instance_destroy();
                event_perform(ev_other, ev_animation_end);
                sr_assert(attack_kind == 0, "attack completes after form change");
                sr_start_attack(_kind); sr_assert(attack_kind == _kind, "subsequent attack accepted");
                var _frame = image_index; sr_start_attack(_kind == 1 ? 2 : 1);
                sr_assert(image_index == _frame && attack_kind == _kind, "attack input cannot restart active swing");
            }
        }
        x = 15000; y = 718; hsp = RUN_SPEED;
        var _decor_types = [obj_deco_tree_tall, obj_deco_tree_cluster, obj_deco_volcano];
        for (var _form = 0; _form < 3; ++_form) {
            sr_apply_form(_form);
            for (var _kind = 1; _kind <= 2; ++_kind) {
                attack_kind = 0; sr_start_attack(_kind);
                for (var _i = 0; _i < 3; ++_i) {
                    var _deco = instance_create_layer(bbox_right + 12, 640, "Scenery", _decor_types[_i]);
                    sr_hit_decor(_decor_types[_i]);
                    sr_assert(!instance_exists(_deco), "nearby decoration hit in each form and attack");
                    var _behind = instance_create_layer(bbox_left - 40, 640, "Scenery", _decor_types[_i]);
                    sr_hit_decor(_decor_types[_i]);
                    sr_assert(instance_exists(_behind), "decoration behind player survives");
                    with (_behind) instance_destroy();
                }
            }
        }
    }
    sr_assert(instance_exists(_solid), "attacks preserve terrain");
    with (_solid) instance_destroy();
    var _hazards = [obj_lava_surface, obj_lava_fill, obj_lava_bottom_left, obj_lava_bottom_mid, obj_lava_bottom_right,
        obj_airhaz_left, obj_airhaz_mid, obj_airhaz_right, obj_airhaz_single];
    for (var _i = 0; _i < array_length(_hazards); ++_i) {
        var _hazard = instance_create_layer(15000, 600, "Instances", _hazards[_i]);
        sr_assert(_hazard.image_xscale == 0.125 && _hazard.image_yscale == 0.125, "inherited hazard scale");
        player.x = 15000; player.y = 700; player.is_dead = false; state = RunState.PLAYING;
        with (player) { sr_assert(place_meeting(x, y, obj_hazard_kill), "lethal family contact detected"); sr_die(); }
        sr_assert(player.is_dead && state == RunState.DEAD && player.attack_kind == 0, "single death transition stops attacks");
        with (player) { var _velocity = vsp; sr_die(); sr_assert(vsp == _velocity, "death entry idempotent"); }
        with (_hazard) instance_destroy();
    }
    var _support = instance_create_layer(15000, 600, "Scenery", obj_airhaz_support);
    with (player) sr_assert(!place_meeting(x, y, obj_hazard_kill) && !place_meeting(x, y, obj_solid_parent), "support nonlethal and nonsolid");
    with (_support) instance_destroy();
    state = RunState.PLAYING; player.is_dead = false;
    sr_schedule_finish(); var _finish = finish_x;
    sr_schedule_finish();
    sr_assert(finish_x == _finish && instance_number(obj_level_end) == 1, "finish scheduled exactly once");
    sr_assert(next_spawn_x - finish_x >= 512, "safe runway beyond finish");
    with (obj_level_end) sr_assert(sprite_index == -1 && mask_index == -1, "logical goal deliberately maskless");
    player.x = finish_x - 19; player.y = 718; player.previous_right = player.bbox_right;
    player.x += 2;
    sr_assert(player.previous_right < finish_x && player.bbox_right >= finish_x, "one-step grounded crossing geometry");
    player.y = 620;
    sr_assert(player.previous_right < finish_x && player.bbox_right >= finish_x, "airborne crossing geometry");
    with (player) sr_die();
    sr_win(); sr_assert(state == RunState.DEAD && room == Room1, "death takes precedence over finish");
    show_debug_message("SR ALL CHECKS PASSED");
    game_end();
}
