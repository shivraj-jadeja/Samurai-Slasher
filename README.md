# Samurai Slasher

Samurai Slasher is a 2D action platformer built in GameMaker. The samurai moves forward automatically through a volcanic landscape; the player has to time jumps over lava, avoid overhead hazards, and use two katana attacks to clear the path. A run ends at a visible finish line and records a score based on distance traveled.

**Playable version:** [itch.io link coming soon]

## Gameplay

- Run through four types of procedurally assembled terrain: open ground, lava gaps, raised platforms, and overhead hazards.
- Land on gold platforms to switch to the Midnight appearance or sky-blue platforms to switch to Neon. Both changes persist until another form platform is reached.
- Use either katana attack while running or jumping to cut down trees and small volcano scenery.
- Reach the finish, see your final score and time, and replay for another run.

| Control | Action |
|---|---|
| Space | Jump while grounded |
| Z | Katana attack 1 |
| X | Katana attack 2 |
| Enter or R | Replay from the results screen |
| Esc | Exit |

## Built with GameMaker

The game is written in GML. Gameplay runs at 60 steps per second with a 640 × 360 camera shown in a 1280 × 720 window. The level uses 16-pixel tiles grouped into 256-pixel segments. The opening gives players a safe moment to settle in; later segments vary by seed, and the final stretch provides a clear runway through the finish.

I kept the systems small and focused. The player controller handles movement, collisions, animation and attacks; the level controller owns generated segments and removes them after they leave the camera. A run state controls death, finish approach and victory so score, audio and room transitions stay in sync. Fractional movement is accumulated explicitly, and a stable collision mask keeps the katana animations from changing the player's physical size.

The project includes three samurai appearances, 39 sprite resources, 132 animation frames, and three sound resources. A Developer configuration supports repeatable seeds and automated gameplay checks. I used it to complete five seeded runs, exercise retries and replays, and run a five-minute generation test.

## Run the project

1. Open `Samurai Slasher.yyp` in GameMaker.
2. Select the **Default** configuration and **Windows / VM** target.
3. Run the project with a complete GameMaker runtime.

The project was built and played with GameMaker IDE 2022.9.1.51 and runtime 2022.9.1.66. All sprites, sounds, rooms and GML source needed to edit and build the game are in this repository.
