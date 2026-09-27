draw_set_alpha(0.85); draw_set_color(make_color_rgb(18, 16, 34));
draw_rectangle(12, 12, 628, 54, false); draw_set_alpha(1);
draw_set_color(c_white); draw_set_halign(fa_left); draw_set_valign(fa_top);
draw_text(22, 18, "SCORE  " + string(score));
draw_text(202, 18, "TIME  " + string_format(elapsed_steps / SIM_HZ, 1, 1) + "s");
var _label = state == RunState.FINISH_APPROACH ? "FINISH AHEAD" : "SURVIVE TO THE FINISH";
if (state == RunState.DEAD || state == RunState.RESTARTING) _label = "TRY AGAIN";
draw_text(372, 18, _label);
draw_set_color(make_color_rgb(239, 175, 70));
draw_rectangle(22, 44, 22 + 596 * min(1, elapsed_steps / FINISH_STEPS), 47, false);
if (elapsed_steps < 360) {
    draw_set_color(c_white);
    draw_text(18, 334, "SPACE  Jump     Z / X  Katana     ESC  Exit");
}
if (DEV_BUILD) {
    draw_set_color(c_white);
    draw_text(18, 60, "Seed " + string(run_seed) + " | segments " + string(ds_queue_size(segments)) + " | instances " + string(instance_count));
}
sr_draw_reset();
