# Reconstruction changes

The starting project contained only an empty Room1 and platform options. No unrelated game resources were replaced. A ZIP of that blank project was saved before editing.

- Imported the 39 recovered sprites / 132 frames and three source WAVs without altering source bytes.
- Recreated all 23 named objects, original solid/hazard inheritance, Room1 and rm_congrats, editor folders, sprite sequences and event registrations.
- Added five editable GML scripts and the complete controller/player/event implementation.
- Restored autorun, grounded jumping, all three appearances, two attacks, scenery destruction, camera, original animation tuning and sound behavior.
- Rebuilt the four procedural segment families and added safe opening, bounded generation and owned-segment cleanup.
- Fixed the unreachable finish: explicit lifecycle, visible flag, logical crossing independent of a collision sprite, safe runway and one-shot victory.
- Added distance score, compact HUD, frozen results and replay.
- Fixed fractional movement rounding, attack/form completion, below-body hit geometry, unbounded death/restart, stale references and audio lifecycle.
- Added Developer seed control and executable regression, full-route, retry, replay and soak tests.
- Retained the complete recovery evidence outside GameMaker resource folders.

Deliberate reconstruction choices and test limits are documented in README.md and TEST_REPORT.md. No replacement art, new combat mechanics, menus, enemies, pickups, sprint, double jump, statistics bonuses or online services were added.
