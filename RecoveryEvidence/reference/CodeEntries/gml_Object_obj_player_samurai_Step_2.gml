var cam = view_camera[0];
var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);
var target_x = x - (vw * 0.5);
var target_y = y - (vh * 0.5);
target_x = clamp(target_x, 0, room_width - vw);
target_y = clamp(target_y, 0, room_height - vh);
camera_set_view_pos(cam, target_x, target_y);
