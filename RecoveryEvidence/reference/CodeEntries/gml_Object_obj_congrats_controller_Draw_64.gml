var gw = display_get_gui_width();
var gh = display_get_gui_height();
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(gw * 0.5, gh * 0.4, "CONGRATULATIONS!");
if (variable_global_exists("score"))
{
    draw_text(gw * 0.5, gh * 0.5, "Final Score: " + string(global.score));
}
else
{
    draw_text(gw * 0.5, gh * 0.5, "Thanks for playing!");
}
draw_text(gw * 0.5, gh * 0.6, "Press ESC to exit");
