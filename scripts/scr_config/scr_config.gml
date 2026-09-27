/// Fixed simulation tuning; origins and source pixels are unchanged.
enum SamuraiForm { RED, MIDNIGHT, NEON }
enum RunState { PLAYING, FINISH_APPROACH, DEAD, RESTARTING, WON }
#macro SIM_HZ 60
#macro TILE_SIZE 16
#macro SEGMENT_WIDTH 256
#macro GROUND_Y 640
#macro RUN_SPEED 2
#macro RUN_GRAVITY 0.5
#macro JUMP_SPEED -11
#macro FALL_LIMIT 12
#macro SCORE_PER_PIXEL 1
#macro FINISH_STEPS 3600
#macro DEATH_MAX_STEPS 90
#macro DEV_BUILD false
#macro Developer:DEV_BUILD true

function sr_active(_state) {
    return _state == RunState.PLAYING || _state == RunState.FINISH_APPROACH;
}

function sr_stop_audio(_handle) {
    if (_handle != noone && audio_is_playing(_handle)) audio_stop_sound(_handle);
}
