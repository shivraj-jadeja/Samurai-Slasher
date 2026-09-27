player = -4;
with (obj_player_samurai)
{
    other.player = id;
}
tile_size = 16;
segment_width = tile_size * 16;
ground_top_y = 640;
ground_bottom_y = room_height;
next_spawn_x = 0;
elapsed_frames = 0;
goal_ready = false;
goal_spawned = false;
var prewarm = 4;
for (var i = 0; i < prewarm; i++)
{
    spawn_random_segment();
}

function spawn_random_segment()
{
    var choice = irandom(3);
    switch (choice)
    {
        case 0:
            seg_flat_run(next_spawn_x, ground_top_y, ground_bottom_y, segment_width, tile_size);
            break;
        case 1:
            seg_small_gap(next_spawn_x, ground_top_y, ground_bottom_y, segment_width, tile_size);
            break;
        case 2:
            seg_upper_step(next_spawn_x, ground_top_y, ground_bottom_y, segment_width, tile_size);
            break;
        case 3:
            seg_air_hazard(next_spawn_x, ground_top_y, ground_bottom_y, segment_width, tile_size);
            break;
    }
    next_spawn_x += segment_width;
}

function spawn_goal_segment()
{
    seg_goal(next_spawn_x, ground_top_y, ground_bottom_y, segment_width, tile_size);
    next_spawn_x += segment_width;
}
