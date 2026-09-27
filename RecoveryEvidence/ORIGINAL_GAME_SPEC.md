# Original game specification — recovered final build

Source of truth: the `data.win` inside the uploaded `Jadeja_Shivraj_Assn3.zip`. Values below are from its resource metadata and decompiled GML, not from playing the executable. Earlier discussion evidence and requested remake changes are separated in `HISTORY_AND_PROVENANCE.md` and `CODEX_REBUILD_PROMPT.md`.

## Identity, view, and start

The display name is **Samurai Runner** and internal project name is `Samurai_Runner`. It is a 2D automatic side-scrolling platform runner with a purple volcanic backdrop, dark blue neon/brick ground, lava pits, overhead lava hazards, and destructible dead-tree/volcano scenery. The player is a pixel-art samurai wearing a broad hat and carrying a katana. RED uses red accents, MIDNIGHT uses yellow/cream accents, and NEON uses cyan/magenta accents.

The original default window is 1280×720 and the target rate is 60 FPS. Room order is gameplay `Room1`, followed by `rm_congrats`. There is no recovered title/menu room.

| Gameplay setting | Original value |
|---|---|
| Room dimensions | 20000×720 |
| Camera view | 640×360 |
| Camera viewport | 1280×720 at (0,0) |
| Player placement | (32,496), scale 1, `spr_samurai_red_run` |
| Level controller placement | (0,0) |
| Creation order | Player, then level controller |
| Background layer | `spr_bg_volcano`, horizontal repeat, no vertical repeat, no stretch, depth 100 |
| Gameplay instance layer | `Instances`, depth 0 |
| Runtime decor/support depth | 50 |

The player's End Step centers the camera on its instance origin, clamped to room bounds. The camera starts with a view offset of (0,360), although End Step replaces its position. The original texture interpolation flag is enabled; nearest-neighbor filtering would be a deliberate improvement, not original metadata.

## Player motion and controls

| Input/parameter | Recovered behavior |
|---|---|
| Automatic movement | Rightward, `hsp=2` pixels per Step; not input-controlled |
| Space key press | Jump only if `place_meeting(x,y+1,obj_solid_parent)` succeeds |
| Gravity | `grav=0.5`, applied each Step |
| Jump velocity | `jump_speed=-11` |
| Maximum falling velocity | 12 |
| Z key press | Attack 1, unless dead or already attacking |
| X key press | Attack 2, unless dead or already attacking |
| Esc key press | `game_end()` |

At 60 Steps/s, unobstructed horizontal travel is 120 world pixels/s. There is no recovered health bar, double jump, dash, crouch, player-controlled horizontal motion, enemy behavior, or boss system. Earlier unlimited-jump experiments were replaced with the grounded check in this build.

Horizontal movement tests collision one pixel at a time. Vertical movement also steps whole pixels, but loops while `i < abs(vsp)`, which effectively rounds fractional magnitudes up. Keep this fact in mind when comparing corrected physics with the old jump arc. It is a defect to handle deliberately, not an exact continuous-physics model to assume.

The player's movement mask is set to its current form's run sprite. Attack animation does not pause movement. Run animation uses `image_speed=0.3`; jump and fall use 0.4; attacks use 0.6. Each source sprite is configured at 30 FPS, so those multipliers imply 9, 12, and 18 animation FPS respectively. Attack completion is checked in the Animation End event.

## Form changes

The initial form is RED. When standing on gold (`obj_solid_gold`), switch to MIDNIGHT. When standing on sky-blue (`obj_solid_skyblue`), switch to NEON. Switching updates seven cached sprite references and the run mask. A form persists on ordinary terrain; there is no automatic timeout or reversion. All three have the same speed, gravity and attack behavior. A restart reinitializes RED.

These transformations are triggered by landing on solid platforms. The final compiled game does not contain a separate collectible/pickup object, despite broader earlier descriptions using that word. The correct final asset is `spr_samurai_mid_attack1`, not the older chat typo `spr_samurai_midn_attack1`.

## Attacks and scenery

Z/X select distinct six-frame katana attack animations and play the same `snd_katana` once. Inputs during an attack are ignored. During attack Steps, the original code tests a point at `(x+16,y)` against, in order, small volcano, tall tree, and tree-cluster instances. It destroys the first matching instance. This is a simple scenery interaction, not enemy combat.

The original character origin is at (100,200), while its visible body/feet end near source y=121. Consequently, a point at world `y` is well below the visible body. The remake must place a short-range hitbox relative to `bbox_*` so the intended scenery interaction actually works reliably. Changing forms during an attack also needs explicit state handling (see bug report).

## Procedural world

The level controller uses 16-pixel world tiles and 16 columns per segment: 256 world pixels. Ground begins at y=640 and is filled through y=720 inclusive in six rows. Each ordinary ground cell chooses either `obj_solid_neon` or `obj_solid_neon_brick`. The controller prewarms four random segments, starting at x=0, and adds a segment when its next spawn position is less than 768 pixels ahead of the player. It uses one spawn per Step and has no recovered cleanup routine.

The four random segment types are selected uniformly using `irandom(3)`:

| Segment | Layout |
|---|---|
| `seg_flat_run` | All 16 columns filled with ground. One decoration at x=start+136, y=640. |
| `seg_small_gap` | Columns 8,9,10 have no ordinary ground: a 48-pixel-wide pit. Each gap column has lava surface at y=672, lava fill at y=688, and left/middle/right lava-bottom art at y=704. |
| `seg_upper_step` | Continuous ground plus seven solid gold **or** sky-blue blocks in columns 9–15 at y=592, 48 pixels above ground. Color chosen once per segment with equal probability. One ground decoration at start+136. |
| `seg_air_hazard` | Continuous ground plus an overhead line of 1,3,or5 hazard tiles at y=560. Supports at y=568. Start column is `max(8,16-length-2)`, giving 13/11/9 for 1/3/5 tiles. One ground decoration at start+136. |

Decoration selection is 5% small volcano, 45% tall tree, 50% tree cluster. Decorations use scale 0.4 and bottom-center origins. Hazard sprites use 128×128 source canvases scaled to 16×16 world units. Hazard support objects are separate, nonlethal decoration at depth 50.

All five lava objects and four overhead hazard objects inherit `obj_hazard_kill`. Its Create scales the sprite to a 16-pixel tile. Its collision with the player sets `is_dead`, changes to the death sprite at multiplier 0.4, resets animation to frame zero, and applies an upward death velocity of −6. Ordinary solids inherit `obj_solid_parent` and have no lethal collision handler.

## Death and sound

When dead, the player stops its normal movement logic, stops running sound, falls under gravity with speed capped at 12, ignores terrain, and restarts the room once its origin passes `room_height+64` (784). Falling out of the map alive marks the player dead; on the next Step it restarts if already below that boundary.

| Sound | Recovered duration | Original use |
|---|---:|---|
| `snd_katana` | 0.888 s | One shot on each accepted Z/X attack, priority 1 |
| `snd_music_loop` | 11.154 s | Looped on player creation if not already playing, priority 0 |
| `snd_run_loop` | 6.264 s | Looped while grounded, stopped when airborne/dead, priority 0 |

All three recovered streams are mono 44.1 kHz PCM WAV. The compiled metadata remembers `.mp3` source filenames, but the embedded bytes are WAV; the package contains those bytes without re-encoding. Original volume is 1 for each sound. Use normal audio playback pitch; metadata's raw pitch field of 0 is not an instruction to silence playback via `audio_sound_pitch`.

## Original intended ending versus effective behavior

After `room_speed*60` elapsed Steps, the controller marks the goal ready. When it next needs a segment, it creates exactly one `seg_goal` and sets `goal_spawned=true`. `seg_goal` builds continuous ground, a decoration, and `obj_level_end` at x=start+224, y=592. No more terrain is generated afterward.

The goal object has **no sprite, no mask, and no Create/Step code**, only a collision event with the player. That event correctly calls `room_goto(rm_congrats)`. However, with no collision mask, ordinary instance collision cannot activate that event. The player can continue to the edge of the generated terrain and fall. This is static evidence explaining the reported end-of-game failure, not a reproduced runtime crash trace.

The timer schedules the goal; it is not a direct 60-second victory. A simplified unobstructed controller simulation places the goal segment at x=8192 after about 61.6 seconds, the finish at x=8416, and the terrain edge at x=8448 after about 70.1 seconds of travel. These are illustrative values assuming no death, no horizontal blocking and the stated update order, not measured gameplay timings.

`rm_congrats` is 1366×768 with a black background and `obj_congrats_controller` at (0,0). Its Draw GUI prints white centered text at 40/50/60% of GUI height:

- `CONGRATULATIONS!`
- `Final Score: <global.score>` **if** that variable exists; otherwise `Thanks for playing!`
- `Press ESC to exit`

No recovered code initializes or updates `global.score`, and gameplay has no HUD Draw event. The compiled game contains no replay action on the Congratulations screen. Distance scoring, visible progress/HUD, a reliable finish and replay are required remake improvements grounded in the user's intention, not features already proven to work in the old executable.
