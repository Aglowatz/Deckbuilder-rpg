# Part 1 - one complete game with no shortcuts (Nov 16-17)

**Tool:** `bash tools/run_strict_playthrough.sh refusemancer` (`tools/strict_playthrough.gd`, new tonight): the story bot with its debug
shortcuts taken out. Every fight is played by the game's own planning AI in the hero's seat (ELITE, the player the balance sims use,
items unused); a lost fight is retried (never decreed) up to 10 times; every walk is real keys along the walkable route the quest arrow
uses; quests are done by walking to the place and pressing E; Maren's errands, the favours, the side dungeons, the Capital's gate, the
manhole and Fig Sly are played. A few menu steps call the function their button calls (logged `UI`): equip Tilly's item, buy at Sable,
open packs, save the deck, track a quest, the Rescuer's Path tile. Log: `docs/playthroughs/strict_refusemancer_nov17.log`.

**Path:** Refusemancer (the bot's best Path on Nov 9; the others: Beefcake and Necrocrat walled at their 2nd-4th dungeon on Nov 9,
Gourmand at Primm and the Gallery).

**One save:** the game was played in three sittings of the same save. The bot crashed twice on its own code (a freed scene); each time
it continued from the save it had just made through the real save path (`--resume`, what Continue does): at the Gainlands' entrance and
at Crosspath before the Capital.

## The facts

| Chapter | Bot time | Level / gold at the end | Losses |
|---|---|---|---|
| The forest and the Forgotten Cave | 1.6 min | L3 / 520 | 0 |
| Crosspath: Settling In (Tilly, Sable, Pip, the Deck Station, the store room ghosts, Bertram, one roamer) | 2.9 min | L5 / 554 | 0 |
| Verdant Dump: gatekeeper Moss Mulligan, the side quest + Landfill Depths, the Rotheart | 19 min | L10 / 1,379 | 3 (side dungeon x2, Rotheart x1) |
| Gainlands: gatekeeper, a favour (gain_power, by play), the House of Gains | about 15 min | L13 / 1,484 | 2 (House of Gains) |
| D.N.A.: gatekeeper, the Hall of Final Approvals | 5.5 min | L14 / 1,524 | 0 |
| Endless Buffet: gatekeeper, the Test Kitchen | 6.0 min | L16 / 2,619 | 0 |
| The Capital: Captain Spotless at the gate | 2.4 min | L17 / 2,769 | 2 |
| The Crease, Fig Sly | 0.4 min | L17 / 1,809 | 0 |
| Primm's Castle and Primm | 42 min, 10 tries | L24 -> decreed | 10 |

- **Total:** 1.40 h of game time at the fastest battle speed (a person at normal speed: roughly 4-6 h); 59 fights won, 12 lost.
- **Level and gold when each main dungeon was entered:** the Rotheart L8 (514 gold), the House of Gains L10 (444), the Hall of Final
  Approvals L13 (384), the Test Kitchen L14 (1,099), Captain Spotless L16 (2,344), Primm's Castle L17 (1,809), Primm himself first at L19.
- **Gold** never ran short for the bot: it bought cards at Sable before every try (keeping a third), and still had 2,300-5,000 from the
  Capital on. Cards fell behind nowhere; the deck was always a legal 45 from the Deck Station's own Suggest.

## Blockers, walls and findings

| # | What | Kind | Verdict / fix |
|---|---|---|---|
| 1 | **Primm's Castle is a wall for the planning AI**: 10 tries from L17 to L24; it lost the castle's 4th fight 5 times (turn 10-14) and Primm's later phases 5 times (turn 8-18); it never won Primm. Each loss sends the bot back to the castle's start (it did not take "Fight Primm again") | wall | **Not changed** (owner: Primm unchanged). Logged with the Nov 9 walls question. The AI plays without items; a person with items and the retry button fares better. The castle's 4th room (before Primm) is worth a look: it is the most-lost fight of the game |
| 2 | **The Rescuer's cave-mouth scenes had no marker.** After each freed zone she waits at the Forgotten Cave's mouth with a story scene; the tracker points at Maren and nothing marked her (a toast only) | marker | **Fixed:** she wears a "!" while she waits (`QuestMarkerLayer.refresh`) |
| 3 | Captain Spotless beat the L16 hero twice before the third try | difficulty | Inside the sims' band; logged |
| 4 | The Dump's side door and the Rotheart lie beyond the Magic Bean bridges: from the entrance the hero cannot walk there until the beans are planted (the arrow points at a bean). The bot did not plant them and was moved | not a game fault | The route is correct; the walk smoke covers the bridges |
| 5 | A zone giver with two quests offers one at a time (Barnaby: onboarding before his side quest; Odalys: Mend the Meatloaf before hers) | design | Not a fault; the bot expected the side quest first |
| 6 | After the Crease, nothing marked the castle in this save: "Free the Four Zones" (Brannoch's quest, which carries the castle step) was never given, because the bot's hero was held by an overlay at Brannoch | bot / small | A player who never talks to Brannoch has no castle marker. Logged as an owner question (start the quest on the first Capital visit?) |
| 7 | The ending's own flow after Primm (the ending, the credits, the return) was not reached: the bot decreed Primm after the wall, which skips the scene change | not reached | Covered by critic 2 tonight (played to the credits), and by the new tracker tests |

**No soft-lock, no unwinnable fight below Primm, no lost marker on the main line, no walls or props that trapped the hero** (the 11
"TRAPPED" walks were the bot's own walker in places with gates or rooms: the Dump's ungrown bridges, the D.N.A.'s office rooms, the way
up from the Crease, which needs its ladder).

## The other Paths' early game (from the sims, not played tonight)

The Nov 9 full runs (all four Paths) and the Nov 23-30 sims: Refusemancer and Gourmand reach Primm with no wall before him; Beefcake
walled at its 2nd and 4th main dungeon and Necrocrat at its own side dungeon (S-NECRO) early. Nothing tonight changed a number.
