# Battle feel - moment to moment (overnight Oct 28-29, Part 4)

Earlier passes: "Battle feel" (Oct 16, decisions BT-1..BT-15 in `docs/design/open_questions.md`), combat feel 2.0 (overnight Oct 17,
Part 8 and Phase 2 cycles 8 / 19). This pass upgrades the juice with the game's existing art and sounds only; no enemy intent, no new art.

## Audit (before)

What a turn already did: a played card lifts off the hand and flies to the middle on a bowed arc with a small turn and overshoot; a unit
lands with a squash, a puff of dust and its Path's summon thud; an attacker winds up, lunges and settles; the target recoils and flashes red;
damage numbers grow with the blow; heals and buffs float; a hit pauses the game for a moment, big blows shake the screen, the final blow
plays in slow motion; a dying unit cracks, bursts and dissolves on its way to the Refuse Pile; a resource pops at its tray socket; a ribbon
says YOUR TURN / ENEMY TURN.

Gaps against the brief: the hit pause ran 42-120 ms and the shake up to 20 px; numbers were one fixed red / green (no Path colour); made
resources appeared at their counter rather than flying there, spent ones only flashed; a Legendary arrived like any Common; a spell or
item arrived in the middle silently; the floating numbers, rings and sparks ignored the battle speed; there was no 4x and no way to hurry
an animation.

## What changed

| Effect | Now | Timing at 1x | Code |
|---|---|---|---|
| Card to the board | the arc ends with a soft `land_play` thump and a small puff of dust where the card lands (units keep their landing squash + summon thud) | at 0.34 s of the 0.36 s arc; not waited on | `BattleBoard._thump_on_arrival` |
| Hit-stop | 40 ms for a 1-damage blow up to 80 ms for 5 or more (was up to 120 ms) | real time; halved at 4x | `BattleBoard.hit_stop_seconds` |
| Shake | big blows (3+) and every blow on a hero: 3 + 1.4 px per damage, capped at 12 px (was 20), 0.22 s; off with Reduce screen shake | - | `BattleBoard._on_damage`, `BattleFX.shake` |
| Numbers | pop past full size and settle, then float; damage is red with a third of the attacker's Path colour and its sparks are half Path colour; buffs in the buffed card's Path colour, debuffs violet, heals green | 0.9 s, scaled by speed; not waited on | `damage_number_color`, `BattleFX.floating_text` |
| Resources | a made resource (Iron, Red Tape, Ingredients, Garbage) flies as a glowing mote from the card that made it to its counter and pops there (+1); a spent one flies off its counter toward the board | 0.32 s / 0.24 s, scaled; not waited on | `BattleFX.fly_mote`, `BattleBoard._on_resource` |
| Turn banner | the ribbon carries the turn number under YOUR TURN / ENEMY TURN | 0.75 s, scaled (unchanged) | `BattleFX.turn_banner(..., subtitle)` |
| Legendary entrance | a gold ring, a shower of gold sparks, LEGENDARY over the card, a gold glow on the card, a ring in its Path colour, a 4 px shake and the `pack_reveal_legend` chime | +0.15 s on that card's arrival | `BattleBoard._legendary_flourish` |
| Deaths | unchanged: crack, burst, dissolve on the way to the Refuse Pile (they already crumble) | 0.13 + 0.4 s, scaled | `_on_died` |
| Speed | every timed effect on the effects layer follows the battle speed (`BattleBoard.speed` sets `BattleFX.speed`); new **4x** option (1x / 1.5x / 2x / 4x; saved settings keep their choice) | - | `Settings.BATTLE_SPEEDS` |
| Skip / hurry | **hold Space** (or the pad's advance button) while the board is busy - animations or the enemy's turn - and everything runs 3x faster; let go to return to the chosen speed | - | `BattleScreen._update_hurry`, `HURRY_FACTOR` |

Nothing new is awaited except the Legendary flourish (0.15 s, Legendaries only), so a turn is never more than ~0.3 s longer: the
first-battles smoke's third duel took 37 s for 14 turns before and after.

## Settings that shape it

- Battle speed (Settings > Battle, or the Speed button on the board): 1x / 1.5x / 2x / 4x.
- Reduce screen shake: no shake at all (the Legendary's included).
- Reduce flashing: no red hit flash, no Legendary glow.
- Hold Space: hurry the current animations (3x on top of the chosen speed).

## How to try it

- Play any battle: watch a unit attack (lunge, 40-80 ms stop, Path-tinted number), a resource card (the mote flying to its counter),
  the turn ribbon (turn number). A Legendary: any Path's Legendary from the Collection (or the Dev Menu's give-card) played in a duel.
- Hold Space during the enemy's turn.
- Before / after contact sheets (one bot-played turn per Path, frames every 0.3 s): `_screenshots/oct28/before_<path>.png` and
  `after_<path>.png`, made by `Godot --path . --resolution 1600x900 res://tools/battle_sequence.tscn -- --path=<path> --out=<name>
  --from=16 --every=0.3 --frames=20`.

## Checks

`tests/ui/test_battle_feel_oct28.gd` (hit-stop range, Path-coloured numbers, speed sync, the mote lands, four speeds); first-battles smoke
OK (lowest 53 fps while animating, same as before); battle AI tests (core group) pass; boss-rules smoke OK; battle frame budget met
(3.1 ms avg against 3.8).
