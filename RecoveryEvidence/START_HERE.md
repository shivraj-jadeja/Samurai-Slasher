# Samurai Runner — recovered assets and Codex rebuild handoff

This package was prepared from `Jadeja_Shivraj_Assn3.zip` and relevant retrieved Samurai Runner conversations. It contains the actual art and audio shipped in that build, reconstructed resource metadata, and readable decompiled gameplay logic. It is a rebuild handoff, **not yet a runnable GameMaker source project**.

## Use it with local Codex

1. Extract this entire ZIP to a normal local folder. Keep the folder together; the prompt refers to relative paths inside it.
2. Open your intended GameMaker project folder in Codex. If you have not created one, create an empty **GML** project named `Samurai_Runner_Rebuilt` in your installed GameMaker version, save it, and close the IDE while Codex edits its files. This provides valid `.yyp`/`.yy` templates for your installed version. Keep this handoff folder beside or inside that project, outside its generated resource folders.
3. Give Codex access to both folders. Paste the complete contents of **`CODEX_REBUILD_PROMPT.md`** into Codex and include the two actual local folder paths. Codex should read the supporting files and implement the project directly.
4. Reopen the `.yyp` in GameMaker to run and test. The prompt tells Codex to run available compiler checks and report honestly if interactive GameMaker testing still requires your PC.

You do not need to find or download replacement art. Sprite frames are in `assets/sprites/`, convenient horizontal strips are in `assets/strips/`, and sounds are in `assets/audio/`. Import one representation of each sprite, not both.

## What was recovered

| Item | Recovered |
|---|---:|
| Named sprite resources | 39 |
| Individual full-canvas PNG frames | 132 |
| Horizontal sprite strips | 39 |
| Embedded sounds, exported as WAV | 3 |
| Compiled texture pages | 2 |
| Object definitions | 23 |
| Rooms | 2 |
| Readable top-level GML files | 20 |
| Compiled code entries represented, including nested functions | 32 |

The compiled sprite table contains 43 slots, four of which are null. They are not four recoverable named sprites. The 39 named sprites account for every referenced sprite frame. The background art is itself a sprite (`spr_bg_volcano`), not a missing tileset.

## Read order

- `CODEX_REBUILD_PROMPT.md`: the full implementation instruction to paste into Codex.
- `ORIGINAL_GAME_SPEC.md`: what the surviving build actually contains and does.
- `ASSET_IMPORT_GUIDE.md`: frame ordering, sizes, origins, masks, animation rates, audio, and object wiring.
- `BUG_REPORT.md`: evidence for the ending failure and other defects to avoid.
- `TEST_PLAN.md`: completion criteria for the remade game.
- `HISTORY_AND_PROVENANCE.md`: earlier intent versus final-build evidence, extraction method, and limits.
- `metadata/asset_manifest.csv` and `.json`: exact per-sprite import settings and file paths.
- `metadata/objects.json`, `rooms.json`, `sounds.json`, `general.json`: original resource settings.
- `reference/CodeEntries/`: recovered GML for behavioral reference; do not blindly paste it as production code.
- `previews/`: labeled art contact sheets; these are asset previews, not screenshots of a running remake.
- `validation/`: extraction checks, source hashes, and a portable verification script.
- `original_build/`: untouched uploaded ZIP for comparison.

## Main finding

The final build already has `rm_congrats`, and its finish collision calls `room_goto(rm_congrats)`. However, `obj_level_end` has **no sprite or mask**, so the intended collision cannot be detected normally. Once the generator places this ineffective goal, it stops producing terrain. This is a concrete explanation for running past the ending and eventually falling off the generated world. It is based on recovered code and metadata; the Windows executable was not played in this environment.

All shipped named art/audio resources were recovered. Original editable art projects, pre-encoding audio masters, unused assets excluded from compilation, original comments, and the original `.yyp`/`.yy` files are not in the build and have not been recovered. The rebuild prompt addresses the working game, while preserving this distinction.
