if (is_dead)
{
    exit;
}
var on_ground = place_meeting(x, y + 1, obj_solid_parent);
if (on_ground)
{
    vsp = jump_speed;
}
