# The four zone card minigames (Fable Nov 16b)

One per Path zone. Each replaces that zone's non-card minigame at the same spot, with the same host, rewards, unlock and replay
rules. Dex's card matching (all zones) and Kyle's matching game (the D.N.A.'s Rec Room) are unchanged.

| Zone | Game | Replaces | Spot and host | Rules class | Screen |
|---|---|---|---|---|---|
| Gainlands | **Reps** (higher or lower) | Rep Counter (rhythm) | Studio 3 AM, Chet Thunderabs | `RepsCardGame` | `RepsCardScreen` |
| Endless Buffet | **Order Up** (exact-cost orders) | Order Up! (ingredient stacking) | Dinner in a Dash, Chef Flambe Fontaine | `OrderCardGame` | `OrderCardScreen` |
| Verdant Dump | **Sort It Out** (conveyor sorting) | Sort It Out! (junk sorting) | the County Fair stage, Recycle Rhonda | `SortCardGame` | `SortCardScreen` |
| D.N.A. | **File in Order** (filing) | Pneumatic Soul Routing (tube puzzle) | the Mail Room's terminal, no host | `FileCardGame` | `FileCardScreen` |

Rules live in `core/zone/card_games/`, screens in `ui/zone/card_games/` (shared base: `CardGameScreen`). The zone scenes pick the
screen in `_make_minigame_screen()` (the D.N.A.: `_make_puzzle_screen()`); the old screens were deleted on Nov 16c (see the end of this file); before that one
line per zone puts an old game back.

## The cards

`CardGamePool.cards(content, zone_id)`: the zone's Path plus the colourless cards, real cards a player can own (no tokens, no
enemy-only cards, no reward-locked cards, no multi-Path cards). Each card is drawn by the game's own `CardView`: art, name, cost,
power / toughness, Path icon. Face-down cards show the Path's card back.

## Rules

**Reps.** One unit is face up. Guess whether the next card's power is higher or lower; a tie is right either way. Eight right in a
row wins. A miss puts the streak back to nothing; three misses are allowed and the fourth ends the set. The deal leans the player's
way: after a low card the next is more often higher, after a high card more often lower, and middling cards come up less. Someone
who only guesses away from the nearer edge of the printed range wins 84 % of first sets; a coin flip wins 8 %.

**Order Up.** A ticket shows a total. Six cards lie on the pass. Pick cards whose costs add up to exactly the ticket and ring the
bell. Three tickets win. The row can be swapped for six new cards twice; a plate with the wrong total is sent back, and the third
one sent back ends the shift. Every row (also after a swap) holds at least one right answer; the first two tickets are built round
a two-card answer, the third round a three-card one.

**Sort It Out.** Twenty cards ride the belt one after another. Send the front card to the bin of its type: Unit, Spell,
Infrastructure, Other (Tools, Traps, Wonders). Sixteen right wins; the fifth card lost (wrong bin or off the end) stops the belt.
A card rides for 9 s at the start and 6.7 s at the end; cards come 3 s apart at the start and 1.7 s apart at the end. Every belt
holds 8 units, 5 spells, 3 Infrastructure and 4 others.

**File in Order.** Seven cards with seven different (cost, power) keys lie in the wrong order (at least four out of place). Put
them in ascending cost, the same cost by ascending power, by swapping two at a time: nine swaps at most (six are always enough).
The stamp checks the order. The first wrong check is free and marks the cards out of place; a second wrong check, or a wrong
order with no swap left, is REJECTED.

## Stars and rewards

Stars count the slips of a won game (`CardGamePool.stars_for`): none 3 stars, one or two 2 stars, more 1 star. A lost game has
none and pays nothing. Slips: Reps misses; Order Up plates sent back plus swaps used; Sort It Out cards lost; File in Order swaps
beyond six plus checks used.

The three replayable games pay through the replaced game's own function (`RepGame.apply_result`, `OrderGame.apply_result`,
`SortGame.apply_result`): the first win pays double the star reward plus 50 gold and the zone's item (and the zone's minigame
pack prize), every later win the small repeat reward. File in Order pays what the tube puzzle paid: the zone's puzzle gear, once,
through the zone scene's `solved` handler; it can be replayed for nothing.

## Every game

- Opens on a one-screen "How to play": three lines and a small looping example with real cards. "?" in the header reopens it;
  a running game waits while it is open.
- Ends on a win or lose panel: stars, the host's line, the reward, Play again, Leave.
- Mouse, keyboard and controller: every control is a button the D-pad reaches. Quick keys: Reps Up / Down (or W / S); Order Up
  1-6, Space, R (controller X rings, Y swaps); Sort It Out 1-4 or the arrows (the D-pad); File in Order 1-7, Space (X stamps).
- Backdrop: MG-BG-GYM for Reps; the zone's loading painting, blurred (`ui/shaders/soft_blur.gdshader`), behind a wood and brass
  frame for the other three, until Batch 17 brings their own rooms.

## Tools and tests

- `bash tools/minigame_shots.sh [reps order sort file]`: how / mid / win / lose shots, one at 1280x720, one with Large text.
- A zone shot with `--open=minigame --mg=mid` (the D.N.A.: `--open=puzzle`) puts the game in that state.
- `tests/core/zone/test_card_games.gd` (rules, 17 tests), `tests/ui/test_card_game_screens.gd` (screens, 12 tests).

## The card quiz (Fable Nov 16c)

The classroom trivia in all four zones is a card game too: `CardQuizGame` (rules), `CardQuizScreen` (the classroom, MG-BG-CLASSROOM,
the zone's quiz-giver as the host). Same spot, teacher, rewards, pass mark and flags as the trivia (`QuizRules.apply`), so the
D.N.A.'s "Pass Director Ectomund's Compliance quiz" works as before.

- **Four questions**, from the zone's Path plus colourless (`CardGamePool.cards`), four different cards, in a shuffled order:
  - two **picture** questions: a cropped piece of a card's painting (46 % of its width, 34 % of its height, from the middle of the
    painting), "Which card is this?", four card names (cards of the same type first);
  - one **cost** question: the card's painting and name, "What does it cost?", four numbers;
  - one **power** question (a unit): the painting and name, "What is the POWER of ...?", four numbers.
- The card's face is never shown before the answer (it prints the cost and the power). After the answer the whole card turns up.
- **Three right answers pass.** A first pass pays the large reward for that score; after it every finished attempt pays the small
  repeat reward, pass or not; a fail before the first pass pays nothing. Stars on the panel: 4 right 3, 3 right 2, 2 right 1.
- 1 to 4 pick an answer, or the buttons (mouse, keyboard, controller). How to play, "?" and the result panel are `CardGameScreen`'s.
- Shots: `bash tools/minigame_shots.sh quiz_gain quiz_buffet quiz_dump quiz_dna`; a zone shot with `--open=quiz --mg=how|mid|win|lose`.

## The three puzzles are gone (Fable Nov 16c)

The Gainlands' hamster-wheel Power Grid, the Buffet's Mystery Stew Pot and the Dump's Seed Shrine are removed. Each one's one-time
reward (`ZoneDef.puzzle_equipment_id`, flag `flag_puzzle_solved`) lies in a chest at the same spot (spot kind `reward_chest`,
`ZoneScene._build_reward_chest`): the Grid Crew's Strongbox (Gainsmith's Lifting Belt), the Stew Cook's Chest (Head Chef's Ladle), the Gardeners'
Chest (Refusemancer Seed Satchel). The four old minigame screens, the three puzzle screens, the trivia screen and their rule code are deleted;
`RepGame`, `OrderGame` and `SortGame` keep only the reward tables the card games pay through.

