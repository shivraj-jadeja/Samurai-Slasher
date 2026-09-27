if (is_dead)
{
    exit;
}
if (!is_attacking)
{
    is_attacking = true;
    sprite_index = spr_atk2;
    image_index = 0;
    image_speed = 0.6;
    audio_play_sound(snd_katana, 1, false);
}
