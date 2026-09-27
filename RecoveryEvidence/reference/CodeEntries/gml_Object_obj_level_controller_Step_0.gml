elapsed_frames++;
if (!goal_ready && elapsed_frames >= (room_speed * 60))
{
    goal_ready = true;
}
if (player == -4)
{
    with (obj_player_samurai)
    {
        other.player = id;
    }
}
if (player != -4 && !goal_spawned)
{
    var buffer = segment_width * 3;
    if ((next_spawn_x - player.x) < buffer)
    {
        if (goal_ready)
        {
            spawn_goal_segment();
            goal_spawned = true;
        }
        else
        {
            spawn_random_segment();
        }
    }
}
