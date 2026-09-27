# Rebuild Samurai Runner in my local GameMaker project

You are working on my own game, Samurai Runner, also called Samurai Slasher in some earlier discussions. I lost the source project. The accompanying recovery package contains the surviving compiled build, recovered assets, original resource metadata, decompiled gameplay logic, and a reconstruction specification. **Implement a complete editable GameMaker GML project directly in the local files. Do not stop at giving me code snippets or manual instructions.**

Use the local project and recovery-package paths supplied with this prompt. If they are not written explicitly, locate the `.yyp` and this prompt within the accessible workspace. Resolve routine implementation details yourself. Ask only for a genuinely missing path/tool or a decision that cannot be settled from the package.

## 1. Read the evidence and inspect the workspace

Read `START_HERE.md`, `ORIGINAL_GAME_SPEC.md`, `ASSET_IMPORT_GUIDE.md`, `BUG_REPORT.md`, `TEST_PLAN.md`, and `HISTORY_AND_PROVENANCE.md`. Inspect `metadata/asset_manifest.json`, `objects.json`, `rooms.json`, `sounds.json`, and the actual recovered GML in `reference/CodeEntries/`. Use the contact sheets to understand the visual style.

The final build takes precedence over inconsistent old chat recollections. Changes requested below take precedence over copying known bugs. The raw GML is reference material, not original source: restore sensible argument names, one intentional `SamuraiForm { RED, MIDNIGHT, NEON }` enum, and valid resource references. Do not copy duplicate `UnknownEnum` declarations or compiled numeric object IDs into production code. Preserve the original build and reference files.

Identify the installed GameMaker IDE/runtime version and the project's actual schema. The old build reports GameMaker 2024.14 and VM bytecode 17; do not force a downgrade. Work with the current local project's valid `.yyp`/`.yy` resource format. Register every new asset, folder, room, event, sprite frame/sequence, and dependency properly. Reuse valid local templates; do not guess UUID relationships or create disconnected `.gml` files. If there is no project and no reliable matching scaffold available, prepare all assets/code first and tell me the minimal blank-GML-project step needed. Never claim success for an unopenable project.

Inspect existing files and retain unrelated work. Use Git if a repository is present; otherwise produce the complete source project with a clear change summary. Keep recovery documents outside generated GameMaker resource directories.

## 2. Recreate this game

This is a single-player, side-scrolling, lava-themed automatic runner with procedural finite stages, pixel art, three samurai appearances, jumping, two katana attacks, and a finish/results screen. It is not a new combat RPG or a boss game. Start directly in gameplay, as the original did; a large menu system is unnecessary.

- Default window: **1280×720**. Gameplay camera: **640×360**, displayed at 2× scale. Original gameplay room `Room1` is **20000×720**. Ground starts at **y=640**. Horizontally repeat `spr_bg_volcano`, without stretching it across the entire room. Layer order: background behind decor/supports, then gameplay; GUI on top.
- At **60 simulation steps/second**, player automatically moves right at **2 world pixels/step**, gravity is **0.5 pixels/step²**, jump velocity **−11**, and falling speed caps at **12**. These are starting fidelity values. Space jumps only when grounded. No double jump, unlimited aerial jump, manual left/right movement, or new sprint feature.
- Z plays attack 1; X plays attack 2. A fresh key press starts an attack only when alive and not already attacking. Running and jumping continue during attacks. Play `snd_katana` once when an attack starts. Attacks can destroy the tree and small volcano decorations in front of the player; the build contains no enemy AI or health-based combat to recreate.
- Start in RED. **Landing on gold solid platforms changes to MIDNIGHT; landing on sky-blue solid platforms changes to NEON.** These are solid form-changing platforms, not inventory pickups. The new form persists until another form platform is landed on or the run restarts. Normal blue/brick ground does not revert the form. All forms share movement values and each has idle/run/jump/fall/attack1/attack2/death art. Do not invent statistical bonuses.
- Lava and airborne lava hazards kill. Ordinary ground/platforms are solid, not lethal. Air-hazard supports and trees/volcano decorations are non-solid scenery. While dead, stop horizontal gameplay/attacks, play the death animation, apply falling motion, then restart the run. Preserve the original brief death-and-fall feel; make restart reliably bounded.
- Loop `snd_music_loop` once per gameplay session and `snd_run_loop` only while alive and grounded. Stop running audio while airborne, on death, and on victory. Avoid duplicate audio instances across retries. Esc exits the Windows game, consistent with the original.

## 3. Import the recovered assets faithfully

Import all **39 sprites / 132 PNG frames and 3 WAV sounds**, preserving resource names. The manifest provides exact paths, frame order, canvas dimensions, original custom origins, bounds, and playback rates. A sprite can be imported from ordered `000.png`, `001.png`, etc., or its matching `_stripN.png`; never import both as separate resources. Keep full transparent canvases and RGBA pixels, with no trimming, resampling, palette change, or replacement art.

All character frames are **200×200**, originally at custom origin **(100,200)**. All have native **30 FPS** playback. Initial fidelity rates are `image_speed=0.3` for run, `0.4` for jump/fall/death, and `0.6` for attacks: approximately 9/12/18 animation frames per second, not 18/24/36. Use one stable rectangular player movement mask matching the original run bounds, not an attack sprite's sword-shaped extent. See the import guide for the important difference between the canvas origin and the character's visible feet.

Preserve the original origins in the first working implementation. Base attack hitboxes and safety checks on the actual player bounding box rather than assuming `(x,y)` is at the torso or feet. This avoids breaking gameplay through origin offsets. If you later normalize origins, do it consistently for all 21 character sprites and the mask, adjust coordinates, document the conversion, and retest before claiming fidelity.

Terrain block sprites are already **16×16** at scale 1. Lava/air-hazard art uses **128×128** source canvases, drawn at **0.125×0.125** to occupy 16×16 world units. Tree/volcano decor uses **0.4×0.4**, its recovered bottom-center origins, and depth 50. Do not apply the hazard scale to the samurai or background. Preserve recovered rectangle bounds; some hazard/support art has transparent padding and does not fill a 16×16 collision rectangle. Supports remain nonlethal.

Use `metadata/objects.json` and the object table in the guide to restore inheritance: solid children under `obj_solid_parent`; lava and air hazards under `obj_hazard_kill`. Never instantiate an abstract no-sprite hazard parent and run sprite-size division on it. Prefer direct resource references after imports over runtime name guessing.

Keep the recovered art intact. You may draw a simple finish marker and HUD with GameMaker drawing/text using the existing palette; these are required UI improvements, not recovered assets. A pixel-art filtering change must be documented: the compiled build had interpolation enabled. Start from that setting for comparison; disabling interpolation is an optional deliberate sharpness improvement, not a recovered fact.

## 4. Rebuild procedural generation efficiently

Recreate the functions described in the recovered `scr_segments`: 16-pixel tiles, 16 columns per segment, **256-pixel segment width**, ground rows from y=640 through y=720 inclusive. Four random segment families originally have equal probability: flat run, three-column lava gap, raised gold/sky-blue platform, and overhead lava hazard. Prewarm four segments and keep roughly three segments ahead of the player. Use a bounded catch-up generation loop when needed.

Use the original layouts as the fidelity baseline: gap columns 8–10; raised platform columns 9–15 at y=592; overhead hazards of 1/3/5 tiles at y=560 with supports at y=568; random trees/volcano decor as documented. Ensure segment boundaries and jump arcs remain traversable. Start with a safe opening segment so the user can orient; mark this as a small robustness improvement. Keep random-seed control in developer builds for reproducible testing.

Track generated segments and clean up complete segments safely behind the camera. Include solid tiles, lava, decorative instances, and supports in that cleanup. Use bounded counts, no scan of every world object on every frame, no endless accumulation, and no premature deletion under the player. Straightforward segment ownership is enough; avoid building a general-purpose engine or a large pooling framework for this small game.

Implement collision movement with bounded work and deliberate fractional movement handling. Do not copy the old `for(i < abs(vsp))` loop that rounds fractional displacement away from zero, or a `while(move != 0)` loop that can fail to terminate if speed becomes fractional. Preserve the starting movement feel and document any small physics correction.

## 5. Fix the ending as a complete state transition

Read `BUG_REPORT.md` before implementing this. The actual build already calls `room_goto(rm_congrats)` in the goal collision. The problem is that the goal has **no sprite or collision mask**, and the world stops generating after placing it. Do not repeat that architecture.

Use an explicit run lifecycle such as `PLAYING → FINISH_APPROACH → WON`, with a separate dead/restarting state. At approximately **60 seconds of active simulation**, schedule exactly one safe finish segment beyond the already-generated terrain. This preserves the original intention: 60 seconds schedules the goal; crossing it may happen several seconds later. Do not abruptly win at the timer while the player is mid-jump elsewhere.

Record a `finish_x` on a safe continuous runway. Draw a clear finish marker. Detect an alive player's forward crossing of that line by position/bounding box, independent of whether the marker has a sprite. Make crossing work both grounded and while jumping, including a single step that crosses the line. Provide ample safe ground through and beyond the line. Do not stop terrain before the finish is reachable or let a player continue into an ungenerated pit. Trigger victory once, freeze the final score/time, stop movement/hazard/death processing and running audio, and enter the results room. Define death as taking precedence if a lethal contact and finish crossing would otherwise happen in the same simulation step; the safe finish runway should prevent this in normal play.

If you also add a goal collision mask, treat it as supplementary: the logical finish must not depend solely on sprite collision. Do not place a tiny required trigger three tiles above the ground and force an unexplained jump to win.

Add a real **distance-based score**, as requested in the old chats but missing in the compiled code. Default to one point per whole forward world pixel from the run's start: `floor(max(0, furthest_x - start_x))`. Keep the scoring scale in one constant so it is easy to tune. This exact points-per-pixel formula is a reconstruction choice, not an extracted historical rule. Update only while the run is active, do not award points while stationary or after death/victory, reset on retry, and preserve the finalized value when changing rooms.

Show a compact score and time/progress HUD without obscuring play. The results screen must show **CONGRATULATIONS!**, **Final Score**, a replay action (Enter or R), and Esc to exit. Replay resets player/form/physics/animation, score/time, segment state, goal flags, camera, and audio cleanly. No duplicate controllers or retained generated world. Initialize global/session state explicitly; do not depend on an undefined `global.score` fallback.

## 6. Prevent related state and resource bugs

- Use validated instance references (`instance_exists`) and symbolic constants (`noone`) rather than recovered raw instance sentinel numbers.
- End attacks from attack state/animation completion, not a comparison against sprite variables that can change when the form changes. Test landing on a transformation platform mid-attack.
- Use a defined short rectangle in front of the player's body for decoration hits. Base it on `bbox_*`; do not use the old single point at `(x+16,y)`, which is below the character due to its padded canvas. Each attack should hit the intended nearby decor once; it should not destroy terrain or make lava harmless.
- Give death and victory single entry points so input, animation, collision, sound, cleanup, and room transitions agree. Do not reset animation frame 0 every Step.
- Keep generation/timing out of Draw events. Set a clear 60-step simulation rate; do not mix wall time and simulation time. No new pause system is necessary.
- Reset drawing alignment/colors after GUI rendering. Scale GUI intentionally and keep it readable at the default window and resized windows.
- Keep logic modular but small: player, run/level controller, segment helpers, hazards/solids/decor, goal presentation, results controller. Avoid unnecessary per-frame allocations or dynamic asset lookups.

## 7. Build in verifiable stages and finish the work

1. Inspect/scaffold valid GameMaker files; import assets, rooms, and object hierarchy. Verify every resource path/reference and frame count.
2. Make a playable movement/camera/hazard slice with the original art and audio. Confirm grounded jumping, collision and restart.
3. Add all segment patterns, form transitions, both attacks, decoration interaction, and cleanup.
4. Add scoring, finish state/marker/runway, results, and replay. Fix the recovered defects.
5. Compile with the available local GameMaker tools and execute `TEST_PLAN.md`. Run complete normal-speed runs, repeat retries, and test the finish under several seeds. Do not call a project tested because JSON parses or the linter passes.

If you cannot invoke the compiler or GUI, still complete all source/resource work possible, run static consistency checks, and provide the precise remaining run steps and expected outcomes. Explicitly label runtime checks as not run. If the original executable can be run locally, use it as a visual/control reference, but do not reproduce its known ending failure.

Deliver the actual `.yyp` project with editable GML/resources and all required assets. Include a short README with controls and run instructions, an asset inventory, and a test report stating what passed, what was not run, and any remaining issue. Ensure the source is safely versioned or packaged so it cannot be lost like the original. Do not replace this implementation task with another plan, a web game, a patched executable, or a decompiled-code-only dump. Finish with the project path and concise verification results.
