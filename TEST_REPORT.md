# Samurai Runner rebuild — verification report

Project: `G:\GameMaker Projects\Samurai Slasher\Samurai Slasher.yyp`

Verification performed locally on 26 September 2026. This report distinguishes static validation, actual GameMaker execution, and remaining manual checks.

## Toolchain and build

| Check | Result |
|---|---|
| Installed IDE | GameMaker 2022.9.1.51, confirmed from executable version and IDE |
| Supplied project schema | GMProject 1.6, GMRoom/GMObject/GMSprite 1.0; GMSpriteFrame 1.1 from installed serializer |
| Selected runtime | 2024.14.4.268, incomplete: Igor and GMAssetCompiler binaries absent |
| IDE run with selected runtime | BLOCKED by installation: IDE log reports `Corrupt or damaged GameMaker build tools.` |
| Available compiler/runtime used | Existing 2022.9.1.66, Windows VM, through Igor with the user's existing licensed local profile |
| Default configuration compilation | PASS, actual Windows executable and data.win produced |
| Developer configuration compilation | PASS, actual executable used for regression and route tests |
| IDE resource loading | PASS: project reloaded in GameMaker and recovered sprite thumbnails appeared in Asset Browser |
| Runtime settings changed | None; no runtime downgrade, update, or installation performed |

The initial direct compiler invocation lacked its required profile/context and returned a permission error. Invoking Igor with the existing local profile resolved that issue. No license or access-control bypass was used. The remaining IDE F5 blocker belongs to the incomplete selected 2024.14 installation, not a reported GML compile error.

Compiler warnings: all three recovered WAV headers trigger the 2022.9 compiler's “malformed - forcing conversion” warning; it successfully generates PCM16 mono 44.1 kHz build audio. The editable source WAV files remain byte-for-byte unchanged. Auditory fidelity has not been independently listened through and certified.

## Asset/resource validation — PASS

- 72 registered resources: 39 sprites, three sounds, 23 objects, two rooms, five scripts.
- 132 frames in the correct sequence order; both editor-layer and composite PNG copies match recovered SHA-256 bytes.
- Full RGBA canvas sizes, all original origins, native playback rates, and rectangle bounds verified against the manifest.
- Three source WAV hashes match recovery; original object parent mappings retained.
- All .yy references, event .gml files, image-layer paths, sequence frame keys, room instance IDs and creation-order references resolve.
- One intentional SamuraiForm enum in production; decompiled UnknownEnum/raw argument artifacts exist only in unregistered RecoveryEvidence.
- Recovery package verification also passed its original atlas-pixel, audio-data and archive-CRC checks.

See `qa/static-checks.json`, `qa/verify_project.py`, and `ASSET_INVENTORY.md`.

## Actual GameMaker regression tests — PASS

`qa/logs/checks-final.log` records **112 passing in-engine assertions**, including:

- Clean initialization, single player/controller, four prewarmed segments and original animation rates.
- Measured stable player mask and modern right/bottom collision-edge semantics.
- Fractional horizontal speed 0.25 terminates and accumulates correctly; vertical half-pixel remainders and bounded ground collision.
- Actual player Step landings on gold and sky-blue during each attack; preserved attack progress, correct form, stable mask, Animation End and subsequent attack acceptance.
- Each of the three decorations hit with each attack in each form; behind-player scenery and solid terrain survive.
- All nine lethal lava/air-hazard child types, inherited 0.125 scale, single death entry, stopped attacks and idempotent death handling.
- Support collision remains nonsolid/nonlethal.
- One finish marker, sufficient runway, a deliberately maskless marker, grounded/airborne straddle geometry, and death overriding a simultaneous finish attempt.

These are engine tests of actual objects and GML, not a separate physics approximation.

## Complete normal-speed routes — PASS

Developer automated input drove the real player Step, physics, generation and room transition at 60 simulation steps/sec. It did not teleport, grant invulnerability, accelerate time, skip the initial fall, or force an early goal in these five runs.

| Seed | Finish step | Active time | Final score | Crossing | Maximum instances | Maximum owned segments |
|---:|---:|---:|---:|---|---:|---:|
| 42 | 4183 | 69.7167 s | 8366 | Grounded | 976 | 10 |
| 1 | 4183 | 69.7167 s | 8366 | Grounded | 994 | 10 |
| 7 | 4183 | 69.7167 s | 8366 | Airborne | 1002 | 10 |
| 12345 | 4183 | 69.7167 s | 8366 | Grounded | 964 | 10 |
| 8675309 | 4183 | 69.7167 s | 8366 | Airborne | 977 | 10 |

The identical scores/times are expected: these inputs avoid horizontal blocking, speed stays 2, and seed affects scenery/layout rather than queued segment width. The finish schedules after step 3600, beyond queued terrain, and the forward collision edge reaches it later. Each run entered results once and checked a stable final snapshot. Logs: `qa/logs/route-*.log`.

## Retry, replay and soak — PASS

- **Five death/retry cycles:** each resets RED, velocity, attack, score, elapsed steps, goal state, world ownership and controller count; the previous music handle is stopped. `retries.log`.
- **Two-minute results hold:** 7,200 actual steps with frozen final score/time, no player instance and no running sound. `replay.log`.
- **Three replay transitions:** two complete normal-length runs, followed by two explicitly shortened goal-approach runs for repeated reset/transition coverage. Every replay checks fresh session/world state and the old music handle. The shortened runs are not counted among the five normal-speed routes. `replay.log`.
- **Five-minute generation soak:** seed 42; finish delayed to 18,000 steps, camera allowed past the original room width. Won at step 18,519 (308.65 active seconds), score 37,038. Ordinary generation retained about 6–7 segments; peak including the finish runway was 9 segments / 865 instances. No continuing geometry accumulation or runtime error was observed. `soak.log`.

## Visual/manual checks and limits

The rebuilt Windows executable was launched interactively. The 1280×720 display showed original samurai/environment art, 2× camera, repeated background, ground, raised platforms, lava and readable HUD. A blocked player remained at score 350 while time advanced, demonstrating distance-based scoring in the visible build. The complete source was then loaded in the IDE. The preserved original executable was also launched for comparison: its character/environment proportions and camera presentation match the reconstruction baseline; Space jumping and the cyan form were observed. The original ending failure was not replayed.

NOT RUN to completion: a human-controlled full playthrough; a comprehensive manual key-repeat/double-jump/underside-collision matrix; physical Enter/R/Esc checks in both rooms; a resized-window GUI sweep; ear-based audio comparison. Automatic replay uses the same replay function as Enter/R, but does not claim physical key testing. Automatic route tests cover movement and transitions; they do not replace subjective feel assessment.

## Remaining local steps

1. Repair/install a complete runtime compatible with your IDE in GameMaker's Runtime Manager. The selected 2024.14 installation currently cannot invoke its compiler. The project has already compiled/run with the separate installed 2022.9.1.66 toolchain, and the supplied Windows build can be played immediately.
2. Open Samurai Slasher.yyp, choose Default / Windows VM, and run with a complete runtime. Expect immediate RED gameplay, Space-only grounded jumps, Z/X attacks, and a visible finish after about 70 seconds of unobstructed travel.
3. Perform the manual checks above. Expect frozen numeric results, Enter/R replay, Esc exit, readable resize behavior and one music loop with footsteps only while grounded/alive.

No known gameplay failure remains in the executed automated cases. The incomplete selected runtime and unperformed manual checks are the outstanding verification limitations.
