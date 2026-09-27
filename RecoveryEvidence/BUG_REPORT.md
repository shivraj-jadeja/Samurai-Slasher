# Recovered defects and required fixes

This is a static code/resource review of the supplied final build. The executable was not run here, so these findings do not claim a reproduced Windows crash or a tested remake.

## 1. Finish collision cannot work with the recovered goal resource

**Evidence:** `metadata/objects.json` shows `obj_level_end` with both `Sprite=null` and `TextureMaskId=null`, no parent, and only a player-collision event. `gml_Object_obj_level_end_Collision_obj_player_samurai.gml` contains `room_goto(rm_congrats);`. The global segment script creates this object but never assigns it a sprite or mask. There is no other goal Step/Create handler that performs a position test.

GameMaker's ordinary collision events require valid collision masks. Therefore this invisible, maskless goal cannot trigger the intended player collision. Merely drawing a goal later would not fix it without a real mask or independent logical check.

**Fix:** Record a finish line and check an alive player's forward position crossing; show a visible marker separately. Allow grounded and airborne crossings, invoke the win transition once, and preserve final state. A collision mask may supplement this but must not be the sole condition. This also avoids accidentally requiring a jump to the old y=592 marker location.

## 2. Terrain generation stops even though victory has not occurred

**Evidence:** controller Step runs its spawn branch only while `!goal_spawned`. As soon as it adds `seg_goal`, it sets that flag true. The goal segment is only 256 pixels long, with the marker 32 pixels before its end. There is no additional runway, completion fallback, or cleanup/failure state.

**Consequence inferred from code:** the player can pass the ineffective goal and run off the end of generated terrain. The fall/death/restart logic then takes over. This explains the user's report that the game breaks toward the end, without establishing that every observed symptom is this exact path.

**Fix:** Separate “goal scheduled/spawned” from “game won.” Generate a safe finish approach/runway, reliably detect crossing, and freeze/end the session before reaching ungenerated space. Time readiness alone must not terminate generation at an unsafe place.

## 3. Score is displayed conditionally but never maintained

**Evidence:** the results Draw GUI checks `variable_global_exists("score")`, otherwise displays “Thanks for playing!”. No recovered top-level/nested game code initializes or increments that variable; the player/controller have no gameplay Draw GUI/HUD event.

**Fix:** Implement distance scoring and its initialization, display and final snapshot. User's earlier intent specifies distance-based scoring; exact conversion is not recoverable. The prompt explicitly selects one point per whole forward world pixel as a transparent reconstruction choice. Do not award points after death/victory.

## 4. Form change during an attack can leave the attack state stuck

**Evidence:** the player Step can change `form`, which calls `apply_form_sprites()` and updates `spr_atk1/spr_atk2`, while `is_attacking=true`. That path does not replace the current attack sprite. Animation End clears `is_attacking` only if `sprite_index` equals one of the **current** attack sprite variables. An old-form attack sprite no longer matches the new form's variables. The regular animation selector runs only when not attacking.

**Consequence inferred from code:** landing on a transformation platform mid-swing can cause the old attack animation/state to remain active and block further attacks.

**Fix:** Finish attacks using explicit attack state and animation progress. Either remap the active animation while preserving progress when forms change, or defer form application until the attack completes. Do not tie state exit solely to mutable sprite references. Test both attack variants during both form transitions.

## 5. Decoration hit point is positioned below the character

**Evidence:** all character origins are (100,200), but run art/bounds end at y=121. Attack code checks `(x+16,y)`. The foot-relative error is roughly 78 pixels, below decor rooted at the ground. This is a concrete geometric mismatch; an exact runtime hit rate was not measured.

**Fix:** Preserve sprite canvases/origins, but use a small forward hit rectangle based on actual body bounds and intended sword reach. Keep damage limited to destructible decor, avoid one hit per Step on the same target, and test each form and both attacks.

## 6. Fractional movement and resource growth

**Evidence:** `for(i=0;i<abs(vsp);i++)` moves an integer number of pixels even when gravity produces half-pixel speed, rounding magnitude upward. The horizontal `while(move!=0)` is safe for the original integer speed 2, but unsafe to generalize to arbitrary fractions. There is no generated-world cleanup in the recovered code.

**Fix:** Use bounded collision stepping with a subpixel remainder or another deliberate fractional-motion method. Preserve initial tuning and compare jump reach. Track and remove segments behind the camera; include all scenery/support/hazard instances, not just ground. Profile bounded counts rather than overengineering object pooling.

## 7. Missing reliable replay/session and audio cleanup

**Evidence:** results room only handles Esc; no replay event. Running sound stops only in player Step paths for airborne/dead. The goal transition does not stop it explicitly. Music is guarded by `audio_is_playing` on player creation but not owned by a dedicated session lifecycle. Controller references are checked against recovered `-4`/`noone`, not validated for destruction.

**Fix:** Single session initialization and completion paths; replay resets every state; explicitly stop footsteps on victory and room end; use valid instance checks. Keep music ownership intentional so repeats do not layer copies.

## Implementation priority

1. Import correctly and restore movement/masks.
2. Make finish detection, safe runway and one-shot victory reliable.
3. Implement/reset/freeze score, results and replay.
4. Resolve transformation/attack geometry/state defects.
5. Bound generation/physics/audio lifecycle and verify full playthroughs.

## Primary documentation consulted

- GameMaker collision event semantics: https://github.com/YoYoGames/GameMaker-Manual/blob/develop/Manual/contents/The_Asset_Editors/Object_Properties/Object_Events.htm
- Sprite mask configuration: https://manual.gamemaker.io/monthly/en/The_Asset_Editors/Sprites.htm
- Animation speed units: https://manual.gamemaker.io/lts/en/GameMaker_Language/GML_Reference/Asset_Management/Sprites/Sprite_Information/sprite_get_speed.htm

Recovered game files are the evidence for project-specific findings. These documentation links support engine semantics, not proof that the executable was played.
