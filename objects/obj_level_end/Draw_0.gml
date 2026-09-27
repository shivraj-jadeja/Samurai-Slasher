// Presentation only: victory never depends on this object's sprite or mask.
draw_set_color(make_color_rgb(239, 175, 70));
draw_rectangle(x - 2, y - 146, x + 2, y, false);
for (var _row = 0; _row < 3; ++_row) {
    for (var _col = 0; _col < 6; ++_col) {
        draw_set_color((_row + _col) mod 2 == 0 ? c_white : make_color_rgb(38, 27, 56));
        draw_rectangle(x + _col * 8, y - 146 + _row * 8, x + _col * 8 + 7, y - 139 + _row * 8, false);
    }
}
draw_set_color(c_white); draw_set_halign(fa_center); draw_set_valign(fa_bottom);
draw_text(x, y - 153, "FINISH"); sr_draw_reset();
