# Samurai Runner — editable recovery rebuild

Open **Samurai Slasher.yyp** in GameMaker. The project starts directly in `Room1`.

## Controls

| Key | Action |
|---|---|
| Space | Jump when grounded |
| Z / X | Katana attack 1 / 2 |
| Enter / R | Replay from Congratulations |
| Esc | Exit |

Run right automatically, jump over lava, and land on gold or sky-blue platforms to become MIDNIGHT or NEON. Forms change appearance only. Trees and small volcano scenery can be cut; supports are scenery, and lava remains lethal.

## Running and editing

Select Windows / VM and the **Default** configuration, then press F5 with a complete installed runtime. The default window is 1280×720 and the camera is 640×360. Resizing keeps the fixed logical GUI scaled with the game.

This project preserves the supplied blank project's GameMaker 2022.9.1.51 schema (`GMProject 1.6`, current serializer's sprite frames `1.1`). It was compiled and executed with the already-installed **runtime 2022.9.1.66**. No IDE/runtime setting was changed. At reconstruction time, the IDE selected **2024.14.4.268**, but that installation lacked its Igor and asset-compiler binaries. F5 using that incomplete runtime cannot build until that runtime is repaired. A complete installed runtime is required; the source itself does not require a downgrade. The original build's 2024.14 provenance is retained in `RecoveryEvidence`.

A ready-to-run Windows build is supplied separately from the editable source. Read `TEST_REPORT.md` for the actual toolchain, test evidence, and remaining manual checks.

## Source map

- `scr_config`: one `SamuraiForm` enum, lifecycle states, movement/score constants.
- `scr_player`: form sprites, bounded subpixel collision movement, attacks and death entry.
- `scr_segments`: original four segment layouts, ownership, queue cleanup, safe finish runway.
- `scr_run`: victory snapshot, audio cleanup helpers, replay transition.
- `obj_level_controller`: session initialization, generation in Begin Step, score/finish in End Step, GUI.
- `obj_player_samurai`: input, movement, hazard checks, animation completion.
- `obj_level_end`: visible finish presentation; deliberately has no sprite/mask dependency.
- `obj_congrats_controller`: frozen results and replay.
- `scr_verify`: opt-in Developer tests; disabled in Default builds.

## Fidelity and deliberate corrections

All **39 sprites, 132 full-canvas frames, and 3 WAV files** retain their recovered names and exact file bytes. All 21 character sprites retain custom origin (100,200), 30 FPS native playback, and original rectangle bounds. Recorded inclusive bounds are set manually for deterministic masks. `spr_samurai_red_run` supplies a stable rectangle for every form and animation. Current GameMaker collision mode reports the right/bottom *edges* one pixel past those inclusive source bounds; code uses the actual `bbox_*` values.

Terrain stays at scale 1; lava/hazard/support art at 0.125; decor at 0.4 and depth 50. The volcano background repeats horizontally at scale 1. Original interpolation remains enabled. Source texture cropping is disabled; no source PNG was trimmed, resized, recolored, or replaced.

Movement remains 2 pixels/step, gravity 0.5, jump −11, fall cap 12 at 60 steps/sec. Signed fractional remainders replace the old upward rounding bug. The opening segment is safe. Uniform random family selection follows it. Segment ownership removes complete segments more than 256 pixels behind the camera; no per-frame scan of world instances is used.

After 3,600 active steps, the controller schedules one finish **beyond all queued terrain**. It adds three safe segments, places the line 224 pixels into the first, and leaves 544 pixels of runway beyond it. Crossing with the forward body edge wins both grounded and airborne. Lethal contact is resolved first. The marker is presentation only. Death falls for at least 30 steps and restarts by 90 steps, freezing horizontal movement and score.

Distance score is `floor(max(0, furthest_x - start_x) * SCORE_PER_PIXEL)`, with `SCORE_PER_PIXEL=1`. This is a documented reconstruction choice. A stationary blocked player earns no extra points. Final time/score are captured once; replay creates a fresh nonpersistent room, controller, player, terrain, camera and audio handles.

Each attack remaps art without losing animation progress when a platform changes the form. Animation End exits the attack by state, independent of sprite names. A short forward rectangle based on body bounds destroys nearby decorations once, through their removal; it cannot destroy ground or hazards.

## Developer checks

Build the **Developer** configuration to enable the seed HUD and command-line test switches. Default builds ignore these switches. For an exported Developer executable:

```powershell
& '.\Samurai Slasher.exe' --seed=42 --test=checks
& '.\Samurai Slasher.exe' --seed=7 --test=route --air-finish
& '.\Samurai Slasher.exe' --seed=42 --test=retries
& '.\Samurai Slasher.exe' --seed=42 --test=replay
& '.\Samurai Slasher.exe' --seed=42 --test=soak
```

`--segment=0`, `1`, `2`, or `3` forces flat, gap, platform, or overhead-hazard families after the opening. Automated route input runs through the same player Step, collision functions and animation events at normal speed. The soak delays finish scheduling to five minutes and extends the camera's logical horizontal bounds. Replay testing keeps two full-length runs, holds the first results for two minutes, and uses short goal approaches for the last two reset checks. These test settings never affect Default play.

## Preservation

`RecoveryEvidence/` retains the complete recovery package, raw GML, metadata, contact sheets, and untouched original-build ZIP. It is evidence, not registered production code. `ASSET_INVENTORY.md` lists imported assets. `qa/logs/` contains build/runtime evidence. The supplied source archive, checksum and Git snapshot provide independent recoverable copies. Keep the archive on another drive or your own backup service as well.
