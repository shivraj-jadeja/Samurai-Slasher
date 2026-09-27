hsp = 2;
vsp = 0;
grav = 0.5;
jump_speed = -11;
is_dead = false;
is_attacking = false;
form = UnknownEnum.Value_0;

function apply_form_sprites()
{
    switch (form)
    {
        case UnknownEnum.Value_0:
            spr_run = spr_samurai_red_run;
            spr_idle = spr_samurai_red_idle;
            spr_jump = spr_samurai_red_jump;
            spr_fall = spr_samurai_red_fall;
            spr_atk1 = spr_samurai_red_attack1;
            spr_atk2 = spr_samurai_red_attack2;
            spr_death = spr_samurai_red_death;
            break;
        case UnknownEnum.Value_1:
            spr_run = spr_samurai_mid_run;
            spr_idle = spr_samurai_mid_idle;
            spr_jump = spr_samurai_mid_jump;
            spr_fall = spr_samurai_mid_fall;
            spr_atk1 = spr_samurai_mid_attack1;
            spr_atk2 = spr_samurai_mid_attack2;
            spr_death = spr_samurai_mid_death;
            break;
        case UnknownEnum.Value_2:
            spr_run = spr_samurai_neon_run;
            spr_idle = spr_samurai_neon_idle;
            spr_jump = spr_samurai_neon_jump;
            spr_fall = spr_samurai_neon_fall;
            spr_atk1 = spr_samurai_neon_attack1;
            spr_atk2 = spr_samurai_neon_attack2;
            spr_death = spr_samurai_neon_death;
            break;
    }
    mask_index = spr_run;
}

apply_form_sprites();
sprite_index = spr_run;
image_speed = 0.3;
image_index = 0;
if (!audio_is_playing(snd_music_loop))
{
    audio_play_sound(snd_music_loop, 0, true);
}

enum UnknownEnum
{
    Value_0,
    Value_1,
    Value_2
}
