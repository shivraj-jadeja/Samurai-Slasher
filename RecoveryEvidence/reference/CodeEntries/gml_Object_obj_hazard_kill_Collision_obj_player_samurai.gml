with (other)
{
    if (!is_dead)
    {
        is_dead = true;
        sprite_index = spr_death;
        image_speed = 0.4;
        image_index = 0;
        vsp = -6;
    }
}
