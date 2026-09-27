draw_set_color(make_color_rgb(24, 18, 39)); draw_rectangle(0, 0, 640, 360, false);
draw_set_color(make_color_rgb(239, 175, 70)); draw_rectangle(112, 91, 528, 94, false);
draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_text_transformed(320, 132, "CONGRATULATIONS!", 1.65, 1.65, 0);
draw_set_color(c_white);
draw_text_transformed(320, 188, "Final Score: " + string(final_score), 1.4, 1.4, 0);
draw_text(320, 222, "Time: " + string_format(final_steps / SIM_HZ, 1, 1) + " seconds");
draw_text(320, 275, "ENTER / R  Replay       ESC  Exit");
sr_draw_reset();
