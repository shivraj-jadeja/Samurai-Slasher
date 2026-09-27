# Evidence, earlier conversations, and recovery limits

## Inputs used

1. User-supplied `Jadeja_Shivraj_Assn3.zip`: `data.win` (1,737,326 bytes), `options.ini` (27 bytes), `Samurai Runner.exe` (7,890,432 bytes). The original archive is retained unchanged under `original_build/`.
2. Relevant retrieved Samurai Runner conversation excerpts, especially the development discussions from November 22–23, 2025, and later user descriptions. Retrieval supplied contextual excerpts/summaries, not a full export of every message or attachment in the project folder. This package does not claim exhaustive access to every old chat.
3. GameMaker primary documentation for collision masks/animation semantics, and the official UndertaleModTool project for compiled-resource extraction.

No substitute artwork was generated or downloaded. The sprite pixels and sound data come from the surviving game itself. Earlier chat attachments were not required to recover the named assets shipped in this build.

## How historical discrepancies were resolved

| Earlier context | Final-build evidence / decision |
|---|---|
| Samurai Runner / Samurai Slasher names | Compiled display name is Samurai Runner; preserve it for the remake. |
| Unlimited jumping during an earlier working prototype | Final Space handler checks grounded state. Rebuild grounded jumping. |
| Jump speed −13 in an early code version | Final Create contains −11. Use −11. |
| Earlier 32-pixel tiles and different ground heights | Final controller uses 16-pixel tiles, 256-pixel segments, y=640 ground. |
| Forms described broadly as collectible power-ups | Final code changes forms when standing on gold/sky-blue solids; no pickup objects exist. |
| MIDNIGHT attack1 spelling `midn` in a late chat excerpt | Final asset and code both use `spr_samurai_mid_attack1`. |
| Earlier goal collision called room restart | Final compiled collision calls `room_goto(rm_congrats)`; maskless goal prevents normal collision detection. |
| User wanted a Congratulations screen with a distance-based final score and an approximately 60-second level | Preserve this intent. A results room exists, but the score implementation is absent and the finish is defective. |
| Later descriptions/resume language implied a complete results/scoring loop | Do not use those descriptions as proof of working code. The supplied final build is authoritative. |
| Early themes/names TheDarkRedOne, MidnightSlash, NeonPhantom | Useful historical appearance context; actual final resources use red/mid/neon prefixes. Do not add unproven character abilities. |

## Extraction method

The game is a VM build (`IsYYC=false`, bytecode 17), reporting GameMaker 2024.14. Resources and code were read using **UndertaleModTool CLI 0.9.2.0**, from the official project:

- https://github.com/UnderminersTeam/UndertaleModTool
- https://github.com/UnderminersTeam/UndertaleModTool/releases/tag/0.9.2.0

The CLI exported all named sprite frames to full PNG canvases, two raw texture pages, compiled strings and readable top-level GML. A small reflection/export script captured room/object/sprite/sound metadata and wrote embedded audio bytes directly to WAV. Animation strips and labeled previews were assembled from the recovered PNGs without altering the source frames. The extraction script is included in `validation/export_metadata.csx` for provenance; normal rebuilding does not require installing the extractor.

`reference/CodeEntries/` contains 20 top-level GML exports representing the 32 compiled code entries, including nested functions. The decompiler reconstructs readable logic but not original comments/formatting or all original symbolic names. For example, enum names become `UnknownEnum`, arguments become `arg0` etc., and `noone` sometimes appears as −4. The code must be rewritten into clean source, not pasted wholesale.

`metadata/*.json` is extracted compiled metadata, not ready-to-import GameMaker `.yy` schema. Some reflection fields are diagnostic aliases (e.g. an event subtype interpreted as several unrelated event enums). Interpret events by their event-list category and the readable GML filenames. Do not blindly translate every alias into an IDE field.

## Completeness and limits

- All 39 non-null named sprite resources and their 132 referenced frames were exported. The original table has four null slots, not four missing named assets.
- All three named sound resources have recovered nonempty embedded WAV data. They were not synthesized or replaced.
- Both texture pages are retained, including the extra unreferenced 64×64 texture item. No named gameplay asset was inferred from that item.
- Original `.yyp`, `.yy`, source comments, editor folder organization and source-art authoring files are not contained in the build. Original uncompressed audio masters/MP3 inputs are not recovered; the exact embedded WAV audio is.
- Assets that were never compiled into this final build cannot be extracted from it. No additional missing historical asset pack is claimed recovered.
- Original artist/source-pack credit and license documents were not present in the ZIP or established by retrieved context. Do not invent attribution. Preserve any later-supplied credits alongside the reconstructed project.
- No actual GameMaker project has been implemented or compiled in this recovery task. The Codex prompt requests that work in the user's local GameMaker environment.
- The Windows executable was not executed. Ending and secondary bug findings are based on static code/resource analysis. The extraction validation report verifies files, not game runtime behavior.

## Clearly labeled remake decisions

The following are specified improvements rather than assertions about the original build: a visible finish marker with independent crossing detection, safe finish runway, explicit session states, distance score formula, compact HUD, replay keys, bounded segment cleanup, safe opening segment, stable attack/form transitions, corrected attack geometry, and deliberate fractional physics. Preserve the original art, core mechanics and starting tuning while implementing these fixes.
