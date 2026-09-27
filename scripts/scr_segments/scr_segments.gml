function pick_decor_obj() {
    var _roll = irandom(99);
    if (_roll < 5) return obj_deco_volcano;
    return _roll < 50 ? obj_deco_tree_tall : obj_deco_tree_cluster;
}

function segment_instance(_segment, _x, _y, _object, _scenery) {
    var _instance = instance_create_layer(_x, _y, _scenery ? "Scenery" : "Instances", _object);
    array_push(_segment.instances, _instance);
    return _instance;
}

function column_ground(_segment, _x) {
    for (var _y = GROUND_Y; _y <= 720; _y += TILE_SIZE)
        segment_instance(_segment, _x, _y, choose(obj_solid_neon, obj_solid_neon_brick), false);
}

function build_pit_lava_column(_segment, _column) {
    var _x = _segment.start_x + _column * TILE_SIZE;
    segment_instance(_segment, _x, 672, obj_lava_surface, false);
    segment_instance(_segment, _x, 688, obj_lava_fill, false);
    var _bottom = _column == 8 ? obj_lava_bottom_left : (_column == 10 ? obj_lava_bottom_right : obj_lava_bottom_mid);
    segment_instance(_segment, _x, 704, _bottom, false);
}

function build_air_hazard_line(_segment) {
    var _length = choose(1, 3, 5);
    var _column = max(8, 16 - _length - 2);
    for (var _i = 0; _i < _length; ++_i) {
        var _object = _length == 1 ? obj_airhaz_single : (_i == 0 ? obj_airhaz_left : (_i == _length - 1 ? obj_airhaz_right : obj_airhaz_mid));
        var _x = _segment.start_x + (_column + _i) * TILE_SIZE;
        segment_instance(_segment, _x, 560, _object, false);
        segment_instance(_segment, _x, 568, obj_airhaz_support, true);
    }
}

function seg_flat_run(_segment) {
    for (var _i = 0; _i < 16; ++_i) column_ground(_segment, _segment.start_x + _i * TILE_SIZE);
}
function seg_small_gap(_segment) {
    for (var _i = 0; _i < 16; ++_i) {
        if (_i >= 8 && _i <= 10) build_pit_lava_column(_segment, _i);
        else column_ground(_segment, _segment.start_x + _i * TILE_SIZE);
    }
}
function seg_upper_step(_segment) {
    seg_flat_run(_segment);
    var _object = choose(obj_solid_gold, obj_solid_skyblue);
    for (var _i = 9; _i < 16; ++_i)
        segment_instance(_segment, _segment.start_x + _i * TILE_SIZE, 592, _object, false);
}
function seg_air_hazard(_segment) {
    seg_flat_run(_segment); build_air_hazard_line(_segment);
}

/// Called in the controller scope. Allocation happens once per segment, never per tile Step.
function sr_spawn_segment(_kind) {
    var _segment = { start_x: next_spawn_x, end_x: next_spawn_x + SEGMENT_WIDTH, kind: _kind, instances: [] };
    switch (_kind) {
        case 1: seg_small_gap(_segment); break;
        case 2: seg_upper_step(_segment); break;
        case 3: seg_air_hazard(_segment); break;
        default: seg_flat_run(_segment); break;
    }
    if (_kind >= 0 && _kind != 1)
        segment_instance(_segment, next_spawn_x + 136, GROUND_Y, pick_decor_obj(), true);
    ds_queue_enqueue(segments, _segment);
    next_spawn_x += SEGMENT_WIDTH;
}

function sr_schedule_finish() {
    if (state != RunState.PLAYING || finish_x >= 0) return;
    state = RunState.FINISH_APPROACH;
    finish_x = next_spawn_x + 224;
    // Exactly one marker; 544 pixels of additional continuous ground past the line.
    repeat (3) sr_spawn_segment(-1);
    var _marker = instance_create_layer(finish_x, GROUND_Y, "Instances", obj_level_end);
    _marker.controller = id;
}

function sr_clean_segments() {
    var _limit = camera_get_view_x(view_camera[0]) - SEGMENT_WIDTH;
    // Only examine queue head; no scan over every world object each frame.
    repeat (4) {
        if (ds_queue_empty(segments)) break;
        var _old = ds_queue_head(segments);
        if (_old.end_x >= _limit) break;
        _old = ds_queue_dequeue(segments);
        for (var _i = 0; _i < array_length(_old.instances); ++_i) {
            var _instance = _old.instances[_i];
            if (instance_exists(_instance)) with (_instance) instance_destroy();
        }
    }
}
