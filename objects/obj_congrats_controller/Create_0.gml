display_set_gui_size(640, 360);
audio_stop_sound(snd_run_loop); audio_stop_sound(snd_music_loop);
// The gameplay controller explicitly initializes and snapshots these before room_goto.
final_score = global.final_score; final_steps = global.final_steps;
test_wait = 0;
