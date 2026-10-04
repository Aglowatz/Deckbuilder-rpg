# The Grand Clashatorium (brief 9, Part G)

A colosseum in Concord Crossing (`world/arena_building.gd`, gate dressing in `world/town_dressing.gd`), chained until the first zone is completed
(`ZoneCompletion.ARENA_UNLOCK_COUNT`), then Marshal Vesna Tuskmore welcomes you and `ArenaScreen` lists the encounters.

8 encounters in 3 tiers (`core/arena/arena_defs.gd`): battles with your own deck, restricted-deck battles (Gladiator's Kit, Spellslinger's Satchel),
a "no creature casts" rule (`Modifier.Kind.NO_CREATURE_CASTS`), and preset-board puzzles: win this turn (turn limit 1) and survive 3 enemy turns
(drawn clock with the player alive counts as a win, `ArenaEncounter.player_won`). First clears pay a prize once (gold, XP, essence of a Path or all Paths,
an item, or arena-exclusive equipment); replays pay 15 gold. Cleared state is saved (flags `arena_cleared_<id>`).

Equipment (never sold; new modifier hooks, all through the pipeline): Champion's Laurels (`START_OF_DUEL_EFFECT`), Crowd-Pleaser's Cape
(`ON_ATTACK_DECLARED_EFFECT`), Gladiator's Net (`ON_ENEMY_CREATURE_ENTER_EFFECT`), Bloodsand Boots (`ON_PLAYER_DAMAGED_EFFECT`).
Tests: `tests/core/arena/test_arena.gd`.
