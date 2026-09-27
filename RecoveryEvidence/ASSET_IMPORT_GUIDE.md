# Asset import and GameMaker wiring

## Canonical files and import method

`metadata/asset_manifest.json` and `.csv` contain all 39 named sprites, their dimensions, counts, original origins, bounding boxes, mask types, and paths. `metadata/sprites.json` retains more original fields. Use these per-resource values rather than guessing from cropped previews.

For each sprite, create a GameMaker sprite with its exact manifest resource name. Import `assets/sprites/<name>/000.png`, `001.png`, etc. in numeric order. Alternatively, import the single horizontal strip in `assets/strips/<name>_stripN.png` as **N frames**, each of the manifest width/height. The strip has no border, spacing, or extra row. Verify the result is N frames, not one very wide sprite. Use either frames or strips, not both.

All individual PNGs are restored to their full source canvas, including transparent margins. Do not auto-crop character frames or resize frames to the visible figure; their shared coordinates are important for animation alignment. The strips are a lossless layout of those same frames. The contact sheets crop/enlarge artwork only for preview; never import the contact sheet.

Create valid sprite `.yy` frame/layer/sequence data using the installed GameMaker project's schema, with generated unique IDs and registered project paths. Do not copy compiled resource indices into `.yy` references. Validate every frame path and origin after import.

## Characters — all three forms

The exact prefix sets are `spr_samurai_red_`, `spr_samurai_mid_`, and `spr_samurai_neon_`. Each has the seven suffixes below. All canvases are **200×200**, all original origins are **custom (100,200)**, and native playback is **30 frames per second**.

| Suffix | Frames | Recovered rectangle bounds L,T,R,B | Runtime multiplier |
|---|---:|---|---:|
| `idle` | 8 | 76,70,112,121 | Not selected by the normal autorun loop |
| `run` | 8 | 72,74,117,121 | 0.3 |
| `jump` | 2 | 76,69,113,121 | 0.4 |
| `fall` | 2 | 69,66,116,121 | 0.4 |
| `attack1` | 6 | 69,53,188,121 | 0.6 |
| `attack2` | 6 | 82,59,193,121 | 0.6 |
| `death` | 6 | 69,69,119,121 | 0.4 |

These are rectangle bounds in full-canvas coordinates, inclusive. The compiled mask type is `AxisAlignedRect`, with original automatic bounding-box mode (`BBoxMode=0`). To reproduce the recorded rectangle deterministically in the remake, choose a rectangular mask and explicitly set the documented bounds; label manual bounds as the implementation mechanism, not the old editor setting. Do not use precise per-frame sword shapes for movement collision.

### The important origin issue

The character's feet lie near image row 121, not row 199. Origin (100,200) therefore lies about 78–79 pixels below the feet. Keeping the original origin is valid, but `(x,y)` is not the visible foot or torso position. Use `bbox_top/bottom/left/right` when locating attack hitboxes, grounded contact, camera framing improvements, and offscreen checks.

Use a stable movement mask across all animations/forms with run bounds **(72,74,117,121)** and matching origin. All three recovered run masks share these values. This prevents swings changing the player's physical width. The original applied each form's run sprite as `mask_index`; that is also workable if rectangle settings are identical.

Optional later normalization: set all 21 character origins plus the mask to **(100,122)** and translate each old instance y to **old y − 78** to keep the artwork at the same world coordinates. Example initial placement becomes (32,418), instead of (32,496). Reevaluate origin-based camera/death thresholds and event logic. Do not change only some animation origins. The first rebuild should keep original origins and avoid introducing this conversion unnecessarily.

## Environment assets

| Resource(s) | Source canvas | Original origin | World scale/use |
|---|---|---|---|
| `spr_bg_volcano` | 1280×720 | 0,0 | Background layer, scale 1; repeat horizontally, no stretch |
| `spr_block_neon_blue`, `spr_block_neon_gold`, `spr_block_neon_skyblue`, `spr_neon_brick` | 16×16 | 0,0 | 1×1; solid 16×16 blocks |
| `spr_lava_surface`, `spr_lava_fill`, `spr_lava_bottom_left/mid/right` | 128×128 | 0,0 | 0.125×0.125; lethal lava tiles |
| `spr_airhaz_left/mid/right/single` | 128×128 | 0,0 | 0.125×0.125; lethal overhead tiles |
| `spr_airhaz_support` | 128×128 | 0,0 | 0.125×0.125; nonlethal scenery, depth 50 |
| `spr_deco_tree_cluster` | 128×128 | 64,128 | 0.4×0.4; non-solid destructible scenery, depth 50 |
| `spr_deco_tree_tall` | 128×256 | 64,256 | 0.4×0.4; non-solid destructible scenery, depth 50 |
| `spr_deco_volcano` | 128×128 | 64,128 | 0.4×0.4; non-solid destructible scenery, depth 50 |

All these are single-frame sprites. The manifest provides their precise bounds. Specifically, overhead hazard bounds end at source row 71, supports end at row 55, and lava-surface bounds start at row 31. Do not silently expand them to full-canvas damage areas. `spr_deco_volcano` is scenery, while the lava sprites are hazards.

## Object wiring

All original objects are nonpersistent, do not use physics, and have the built-in Solid checkbox false. Solidity is implemented with parent-based GML collision checks, not Box2D or GameMaker's legacy solid-response behavior. Original Sprite/Parent mappings:

| Object | Sprite | Parent |
|---|---|---|
| `obj_player_samurai` | `spr_samurai_red_run` | None |
| `obj_solid_parent` | None | None |
| `obj_solid_neon` | `spr_block_neon_blue` | `obj_solid_parent` |
| `obj_solid_neon_brick` | `spr_neon_brick` | `obj_solid_parent` |
| `obj_solid_gold` | `spr_block_neon_gold` | `obj_solid_parent` |
| `obj_solid_skyblue` | `spr_block_neon_skyblue` | `obj_solid_parent` |
| `obj_hazard_kill` | None | None |
| `obj_airhaz_left` | `spr_airhaz_left` | `obj_hazard_kill` |
| `obj_airhaz_mid` | `spr_airhaz_mid` | `obj_hazard_kill` |
| `obj_airhaz_right` | `spr_airhaz_right` | `obj_hazard_kill` |
| `obj_airhaz_single` | `spr_airhaz_single` | `obj_hazard_kill` |
| `obj_airhaz_support` | `spr_airhaz_support` | None |
| `obj_lava_surface` | `spr_lava_surface` | `obj_hazard_kill` |
| `obj_lava_fill` | `spr_lava_fill` | `obj_hazard_kill` |
| `obj_lava_bottom_left` | `spr_lava_bottom_left` | `obj_hazard_kill` |
| `obj_lava_bottom_mid` | `spr_lava_bottom_mid` | `obj_hazard_kill` |
| `obj_lava_bottom_right` | `spr_lava_bottom_right` | `obj_hazard_kill` |
| `obj_deco_tree_tall` | `spr_deco_tree_tall` | None |
| `obj_deco_tree_cluster` | `spr_deco_tree_cluster` | None |
| `obj_deco_volcano` | `spr_deco_volcano` | None |
| `obj_level_controller` | None | None |
| `obj_level_end` | **None — defective finish setup** | None |
| `obj_congrats_controller` | None | None |

The hazard parent supplies Create and player-collision events inherited by its sprite-bearing children. If a child later defines its own Create event, preserve required inherited setup. The support and decor have their own scaling Create events. There is no collectible, enemy or health object to recover.

## Recovered event placement

| Recovered GML filename pattern | GameMaker event/location |
|---|---|
| `gml_GlobalScript_scr_segments.gml` | Script resource `scr_segments`: named helper functions |
| `gml_Object_*_Create_0.gml` | That object's Create event |
| `gml_Object_*_Step_0.gml` | Step event |
| `gml_Object_obj_player_samurai_Step_2.gml` | End Step: camera logic |
| `gml_Object_obj_player_samurai_Other_7.gml` | Other → Animation End |
| `gml_Object_*_KeyPress_32.gml` | Key Press → Space |
| `gml_Object_*_KeyPress_90.gml` | Key Press → Z |
| `gml_Object_*_KeyPress_88.gml` | Key Press → X |
| `gml_Object_*_KeyPress_27.gml` | Key Press → Escape |
| `gml_Object_*_Collision_obj_player_samurai.gml` | Collision with player |
| `gml_Object_obj_congrats_controller_Draw_64.gml` | Draw GUI |

The remake may consolidate input into a player Step using `keyboard_check_pressed`; avoid simultaneously keeping Key Press handlers that would double-trigger it. Restore global script functions once. Nested functions inside recovered Create events explain why there are more compiled code entries than exported top-level files. The Congratulations Create event has an empty compiled action with no code; this is not a failed export.

## Audio import

Import the three files in `assets/audio/` as sounds named `snd_katana`, `snd_music_loop`, and `snd_run_loop`. Use the default audio group and normal playback pitch. They are real recovered WAV streams even though old metadata lists MP3 input filenames. Preserve audio bytes; do not re-encode them simply to match the old extension.

For this small game, ordinary in-memory sound assets are sufficient. Configure looping in GML, not by assuming the source WAV contains loop markers. Keep one tracked handle for music and one for footsteps, and stop/restart handles on the appropriate session transitions. The original volume was 1; any mixing reduction for comfort is a deliberate tuning change.

## Project validation

After importing, verify 39 sprites, 132 frames, three sound resources, and no unresolved references. Do not create assets for null compiled sprite slots 22,30,38,42. The texture atlas has one additional unreferenced 64×64 item retained in the raw pages; it is not a named gameplay sprite. No compiled fonts, shaders, paths, or custom extensions were present. Use GameMaker text for the original-style results/HUD; a new font asset would be optional new work.
