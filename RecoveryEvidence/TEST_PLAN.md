# Remake acceptance tests

These are tests for local Codex and GameMaker to perform **after implementation**. They are not reported as passed by this recovery package. Extraction checks are separate in `validation/extraction_report.json`.

## Resource/build gate

| Check | Pass condition |
|---|---|
| Project loading | `.yyp` opens in the user's installed GameMaker without missing resources or broken frame references. |
| Asset counts | All 39 sprites, 132 frames and 3 sounds imported; animation order/dimensions/origins match manifest. |
| Compile | GameMaker builds successfully; no duplicate enum declarations, missing script names, or numeric compiled resource IDs used as source references. |
| Object wiring | Solids/hazards have correct parents; inherited hazard setup executes; supports/decor remain nonlethal/non-solid. |
| Visual comparison | Original art, proportions, background repeat, camera scale and layers match the specification; no stretched or trimmed character frames. |

## Core play and input

- Start a clean run: one player, one controller, RED form, zero score/time, valid camera, and no duplicate music/footsteps.
- Player runs automatically right. At 60 simulation Steps per second, unobstructed movement is 120 world pixels per second. Space jumps while grounded; repeated presses in midair do not add another jump.
- Collide with ground, underside and sides of raised platforms. No tunneling, embedded player, infinite collision loops, unintended lethal solid, or uncontrolled fractional drift.
- Z/X play distinct attacks once per press; attacking does not halt running or jumping. Repeated attack input during the active animation does not restart frame 0 every Step or spam sound.
- Test jump/fall/run transitions in all three forms. All use the same stable body mask; sword extent does not push the character out of terrain.
- Land on gold, then ordinary ground, then sky-blue. Expect MIDNIGHT to persist on ordinary ground and NEON after sky-blue. A fresh run returns RED.
- Land on a form platform during attack 1 and during attack 2. Attack completes, locomotion resumes and a subsequent attack works with the new form.
- Hit each decoration type with both attacks in each form. Nearby targets are removed using the intended forward hit area; terrain and lava remain. No hit occurs far behind or well below the samurai.

## Hazards/death/audio

- Fall into a gap and touch every lethal lava/air-hazard family. One death transition occurs, attacks stop, death art plays, footsteps stop, and the run restarts within the intended brief delay.
- Run underneath airborne hazards without touching them: survive. Contact support art alone: survive.
- Fall beyond the world: restart reliably instead of hanging offscreen. No old form/score/goal/camera/generated instances survive restart.
- Jump repeatedly and die/retry at least five times. Footsteps play only while alive and grounded. Music does not layer additional instances. Katana SFX triggers once per accepted attack.

## Procedural generation and finite ending

- Force each of the four segment types and verify exact layouts. Cross boundaries and reach raised platforms with the configured jump. Ensure a safe initial segment and no impossible transitions.
- Use several recorded seeds (at least five) to inspect generation through the finish. Inspectability/debug acceleration can help, but it does not replace a normal-speed completion test.
- Complete at least one full normal-speed run: readiness at about 60 active simulation seconds, safe approach through queued terrain, then visible finish and Congratulations. There is no mandatory tiny airborne trigger.
- Cross the finish grounded; repeat while jumping. Also test a single simulation step whose old/new position straddles the line. Each wins exactly once.
- Force the finish marker's sprite/mask absent in a developer test. Logical crossing still wins; this is the direct regression test for the recovered bug.
- Observe the entire route beyond the old failure window (roughly 70 seconds for an unobstructed old run). The remake must enter results, not continue into an ungenerated pit. Record the actual remake time and seed.
- Test death immediately before finish; do not award victory. For a forced simultaneous lethal contact and crossing, apply the defined death precedence consistently. Normal finish terrain should be safe.
- After winning, leave results open for two minutes. Score/time stay fixed, no delayed deaths/restarts or footsteps occur, and GUI remains responsive.
- Replay from results at least three times. Verify fresh state and complete another run. Esc exits both gameplay and results.

## Score/GUI

- Score increases with forward distance according to the documented scale, not total elapsed time alone. Stationary blocked frames do not add distance score.
- Death/retry resets score; victory preserves the final snapshot between rooms. No undefined-global fallback is necessary.
- Results always shows Congratulations and numeric Final Score plus replay/exit instructions. Default window and resized views keep text readable and inside the screen.

## Bounded performance

- Track generated segment/instance counts during full runs and across retries. Counts stabilize with behind-camera cleanup and return to baseline on replay.
- In a developer-only soak mode, postpone the finish for five minutes and extend logical camera/world bounds as needed. Verify no accumulating geometry/audio, stale references, or growing per-frame traversal cost. Remove/disable soak settings for normal gameplay.
- If physics is changed to accept fractional horizontal speeds, test a fractional value explicitly to prove collision loops terminate; restore the intended speed 2 afterward.

## Required report format

Report the project path, IDE/runtime version, compile outcome, tests actually performed, seeds/timings for complete runs, and remaining issues. Mark unsupported GUI/runtime tests **NOT RUN**. Keep screenshots or concise logs for the finish/results and repeat-run checks. Static JSON validation is not a substitute for playtesting.
