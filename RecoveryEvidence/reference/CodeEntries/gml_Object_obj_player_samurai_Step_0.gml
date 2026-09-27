if (is_dead)
{
    audio_stop_sound(snd_run_loop);
    vsp += grav;
    if (vsp > 12)
    {
        vsp = 12;
    }
    y += vsp;
    if (y > (room_height + 64))
    {
        room_restart();
    }
    exit;
}
var move = hsp;
var step = sign(move);
while (move != 0)
{
    if (!place_meeting(x + step, y, obj_solid_parent))
    {
        x += step;
    }
    else
    {
        while (!place_meeting(x + step, y, obj_solid_parent))
        {
            x += step;
        }
        move = 0;
        break;
    }
    move -= step;
}
vsp += grav;
if (vsp > 12)
{
    vsp = 12;
}
var steps = abs(vsp);
var dir = sign(vsp);
for (var i = 0; i < steps; i++)
{
    if (!place_meeting(x, y + dir, obj_solid_parent))
    {
        y += dir;
    }
    else
    {
        vsp = 0;
        break;
    }
}
var on_ground = place_meeting(x, y + 1, obj_solid_parent);
if (!is_dead)
{
    var on_gold = place_meeting(x, y + 1, obj_solid_gold);
    var on_skyblue = place_meeting(x, y + 1, obj_solid_skyblue);
    if (on_gold && form != UnknownEnum.Value_1)
    {
        form = UnknownEnum.Value_1;
        apply_form_sprites();
    }
    else if (on_skyblue && form != UnknownEnum.Value_2)
    {
        form = UnknownEnum.Value_2;
        apply_form_sprites();
    }
}
if (!is_dead)
{
    if (on_ground)
    {
        if (!audio_is_playing(snd_run_loop))
        {
            audio_play_sound(snd_run_loop, 0, true);
        }
    }
    else if (audio_is_playing(snd_run_loop))
    {
        audio_stop_sound(snd_run_loop);
    }
}
if (y > (room_height + 64) && !is_dead)
{
    is_dead = true;
    sprite_index = spr_death;
    image_speed = 0.4;
    image_index = 0;
}
if (!is_dead && is_attacking)
{
    var hit_x = x + 16;
    var hit_y = y;
    var inst = instance_place(hit_x, hit_y, obj_deco_volcano);
    if (inst == -4)
    {
        inst = instance_place(hit_x, hit_y, obj_deco_tree_tall);
    }
    if (inst == -4)
    {
        inst = instance_place(hit_x, hit_y, obj_deco_tree_cluster);
    }
    if (inst != -4)
    {
        with (inst)
        {
            instance_destroy();
        }
    }
}
if (!is_dead && !is_attacking)
{
    if (!on_ground && vsp < 0)
    {
        sprite_index = spr_jump;
        image_speed = 0.4;
    }
    else if (!on_ground && vsp >= 0)
    {
        sprite_index = spr_fall;
        image_speed = 0.4;
    }
    else
    {
        sprite_index = spr_run;
        image_speed = 0.3;
    }
}

enum UnknownEnum
{
    Value_1 = 1,
    Value_2
}
