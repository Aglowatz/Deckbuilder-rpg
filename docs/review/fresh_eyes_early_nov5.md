# Fresh eyes - early game, Nov 5 (Necrocrat)

Screenshots cited are in `fresh_eyes_early_nov5/` (names are `<run>_<shot>.png`).

## Summary

I did not get past the tutorial cave. In about 80 minutes of wall-clock time I played the opening, picked **Necrocrat**, played most of
the first tutorial duel myself with clicks, and then went through the Forgotten Cave four times. I lost two of those runs: to the
second regular fight (Hollow Stalker) and to the cave boss (Hollow Warden). The other two runs stopped short of the boss for
input reasons (described below). Crosspath, Tilly, Maren's errand, the shops, the road, the D.N.A. and its first dungeon were **not
reached**, so this review covers only the first 15-20 minutes a player sees. Treat that as the main finding: a scripted, fairly
careful player got stuck in the tutorial dungeon. A real new player who loses the cave boss is sent back to the forest bedroll and
must replay the whole cave from the start.

What works: the art is the best thing here. The title screen (`n5a_01_title`), the wake-up still (`n5a_02_wake`) and the painted cave
map (`n5g_g02`) look like a commercial game. The defeat screen's "What beat you" panel (`n5t_t03_boss_end`) is excellent: it names the
card that killed you and gives a concrete tip. The tutorial tips are short and mostly well-timed. The card-pick reward screen
(`n5p_p05_win`) is clean, and its keyword glossary underneath is a nice touch.

What hurts: the tutorial cave is too punishing for a first dungeon. Several popups ignore the keys the game says will work (E/Space).
The battle board shows numbers that don't explain themselves (every enemy has "3" HP next to a mostly empty bar). The Path choice
screen shows cards at a size nobody can read.

## How I played

- **Path:** Necrocrat (I liked "Shrink their blockers with Red Tape, then outlast them" and the Pink Slip art).
- **Runs** (all from `/c/Dev/wp_critic`, scripts `docs/review/play_scripts/critic_nov5_*.txt`):
  - n5a-n5c: title, wake-up, Rescuer conversation, Path choice + More, Begin. Saved `n5_forest`. (`dev save` during the Path choice
    said "Nothing to save yet", which is fine.)
  - n5d-n5j: finding and entering the cave. It took several runs because E at the arch often did nothing (see Findings).
  - n5k-n5o: I played the first duel (Cave Scavenger) by hand: infrastructure, Skeleton Clerk, Red Tape on the Courier Pigeon,
    attack, more units. The opening hand is random between runs, so my replayed inputs desynced in n5o (a Peek popup appeared).
  - n5p: Cave Scavenger won by `pilot` (7 turns), card pick (Audit Wraith).
  - n5q: Hollow Well event (I pressed E, which **revealed** the test; I failed it and lost Middle Management Zombie for the dungeon),
    then **lost to Hollow Stalker** (pilot, 12 turns; "Cannon Fodder dealt 8 of the 17 damage"). I was carried back to the **forest
    bedroll** (`n5q_q_map_1311`), not to town as the dungeon tip says.
  - n5r: replay. Scavenger won, skipped the Well, beat Hollow Stalker in 16 turns (ended at 10/15 HP), then got stuck on the
    Whispering Shrine popup (`n5r_r_end`): E, Space and 20 skip taps did not press Rest, and the popup has no way out.
  - n5s: replay. My single click on the boss node only selected it ("Click again or press E to go"); the run ended at the boss's
    turn 1 (`n5s_s02_town`).
  - n5t: replay. Clicked the boss twice, read its intro, played my first turn by hand, then `pilot`. **Lost to the Hollow Warden** in 12
    turns: "Traveling Brawler dealt 9 of the 15 damage you took (3 hits)" and "You played no Infrastructure on 2 of your 6 turns"
    (`n5t_t03_boss_end`).
- **Debug use:** `dev newgame`, `dev save`/`dev load` only. No `dev travel`, `win`, `autowin`, `level` or `gold`.
- **Gold:** 120 at the start, 160 after the first win, 200 after re-winning it, 240 after Hollow Stalker. I never reached a shop, so
  there is nothing to report on prices.
- **Time:** about 80 minutes, most of it spent on the input issues and replaying the cave.

## Scores

| | Score | Why |
|---|---|---|
| Fun | **5/10** | The first duel is satisfying once it clicks: make Red Tape, shrink a blocker, swing. But losing the second fight or the boss of a tutorial cave and replaying it from the bedroll is the opposite of fun. Fights against 3-HP enemies run 12-16 turns and drag. |
| Clarity | **5/10** | Tips are good and the defeat recap is the best in the genre. But "3" enemy HP next to a 1/3-full bar, "Turn 3" meaning your second turn, single-click boss node, popups ignoring E/Space and unreadable Path cards all cost trust. |
| Difficulty | **4/10** (too hard for its place) | A tutorial dungeon that the built-in pilot loses 2 of 4 times, with HP carried between fights and a failed Well costing a card, is too harsh for minute 10. |
| Text quality | **7/10** | The voice is warm and lightly funny ("Even in death, he files.", "They are still tying their shoes.", "The most important card of the day."). The Rescuer scene is a bit generic ("A friend. That's all I can tell you"), and the Path tooltip is a wall of jargon. |

## Findings

### Opening and Path choice
- The opening reads well: "You wake in a forest clearing with leaves in your hair" sets a light tone (`n5a_02_wake`). The Rescuer
  lines are serviceable but stock amnesia-fantasy. "I'll find you. I always do." is the best line.
- The Wanderer's first line, "I should get up. My legs have other ideas", is good (`n5a_12`).
- **Path choice cards are unreadable** (`n5b_13_after`): three cards per column at about 70 px wide. You pick a Path from a one-line
  blurb. "More" (`n5c_c02_more`) adds a dense paragraph ("orderly and value-grinding: small tokens, reanimation, drain, delayed but
  inevitable effects, taxes and fees, Red Tape and Contracts") and a 45-card list with no pictures.
- The Necrocrat blurb promises "Shrink their blockers with Red Tape", but none of the three preview cards says what Red Tape does.
  You only learn it from More.
- A feat toast ("Feat: Leaves in Your Hair - Menu > Feats") appears in the middle of the Rescuer's farewell. It's cute, but it lands
  during a story beat.

### Forest and cave entrance
- The forest is moody and good-looking, but there are **untextured grey low-poly rocks** right in front of the bedroll
  (`n5c_c06_forest`). They are the first thing in the foreground and look like missing assets.
- Walking anywhere except the arch gives "The trees are packed too tight to get through. The cave it is, then." That's fine.
- **E at the cave arch is unreliable.** Standing on the ring with "[E] Enter the cave" showing, my first one or two E presses often
  did nothing and only replayed the bark "No point getting lost twice in one day..." (`n5e_e03`). It took a third press in several
  runs. The confirm popup's "Enter" button also wasn't always found right after it opened. Players will think the game froze.

### Cave map
- The painted map is gorgeous (`n5g_g02`). The fog of "?" nodes reads fine: you know there is something there and that you have to
  go to find out. The subtitle "The Forest Clearing" under "The Forgotten Cave" is confusing: it names where you came from, not
  where you are.
- **Boss node needs a second click** ("Unknown. Step on it to find out what waits there. / Click again or press E to go."). Other
  nodes went on one click. Being inconsistent is worse than either rule.
- **Hollow Well** (`n5q_q_node_740`): clear and fair as a gamble ("about 69 % to pass"). But pressing E (the universal "continue" key)
  chose **Reveal**, not "Leave it", so a player mashing through text gambles away a card. Failing it cost Middle Management Zombie,
  my best card, for the run.
- **Whispering Shrine** (`n5r_r_end`): a modal with one button, "Rest", which E/Space do not press, and no close or leave option. The
  HP bar draws red over green in a way that reads as damage, not healing.

### Battles
- First-duel tips are good: "Play an Infrastructure... The most important card of the day", Energy, "You made a Resource!", "Spend
  your Red Tape" with a highlighted tray icon (`n5j_j02`, `n5k_k06_t2`). The tip boxes overlap the phase panel on the right
  (`n5k_k06_t2`, the "onto th table" text shows through).
- **Enemy HP is "3"** for every cave enemy, including the boss, but the red bar under it is about a third full (`n5j_j02`,
  `n5s_s02_town`). I never understood whether 3 is current HP, max HP or something else. Meanwhile I have 15. Enemies at 3 HP that
  take 7-16 turns to kill means most damage is blocked. A new player feels they "almost won" every fight.
- **Turn counter counts both sides**: my second turn is "Turn 3". The defeat screen then says "your 6 turns" after "12 turns".
- The enemy's name plate text overflows the frame ("CAVE SCAVENGER" and "HOLLOW WARDEN" run into the portrait ring), and the hand
  cards are cut off by the bottom of the screen (`n5j_j02`).
- The tutorial opponent plays **Feastforge** (a Gourmand infrastructure making Ingredients) and **Wasteworks** (Refusemancer). That
  means three Resource types on the trays in the first fight, which I hadn't been taught.
- The first tutorial tip tells you to Red Tape a Courier Pigeon that is "Just Arrived" and can't attack yet. It's correct by the
  rules (it stays shrunk through their turn), but it feels pointless as a first use.
- "Exhaust: add ." in the dump suggests an icon-only mana symbol. On screen it is a tiny green dot that is hard to read at card size.
- Boss intro: a "Before the fight" rules card with "Hidden trait ?: Something happens in this fight you haven't seen yet" (good
  tension), then a skippable quote card ("Then I will do what I was left here to do."). The Warden's two lines are atmospheric and
  the best writing in the cave.
- **Defeat screen** (`n5t_t03_boss_end`): genuinely great. It names the killer card and the hits, and gives an actionable tip. But
  "You are carried out of the dungeon" sends you to the **forest bedroll** (`n5q_q_map_1311`) with no message, and the cave restarts
  from node 1. Gold and the picked cards were kept, which is good, but nothing tells you so.
- No `SCRIPT ERROR` appeared in any run's stdout.

### Rewards
- The Victory/card-pick screen (`n5p_p05_win`) is clear: +40 gold, +15 XP, three cards, and keyword definitions for the highlighted
  card. Card body text is small (about 10 px), so you read the glossary line, not the card.

## Top 10 issues

1. **The tutorial cave is too hard and a loss restarts it from the bedroll.**
   - **Where:** `n5t_t03_boss_end`, `n5q_q_map_1311`. The pilot lost to Hollow Stalker once and to the Hollow Warden once, out of four tries.
   - **Why it matters:** players quit tutorials they lose, especially when the loss replays 10 minutes of content.
   - **Fix:** make the cave unlosable or near-unlosable. Full heal before the boss, weaker boss deck, or on a cave defeat respawn at
     the node you lost on with full HP. Also say "Your gold and cards are kept" on the defeat screen.
2. **Popups ignore E/Space, and the Shrine has no exit.**
   - **Where:** `n5r_r_end` (Rest not triggered by E/Space; no close button). The Well's E picks the risky option (`n5q_q_node_740`).
   - **Why it matters:** the HUD promises "E / Space / Click: interact". A modal that ignores those reads as a freeze, and one that
     defaults E to a gamble punishes a player for mashing through text.
   - **Fix:** E/Space press the primary safe button on every popup. Make the Well default to "Leave it" until a choice is clicked.
     Give the Shrine a "Not now" button and Esc.
3. **E at the cave arch often needs 2-3 presses.**
   - **Where:** `n5e_e03`; repeated in runs n5e, n5f, n5h and n5i.
   - **Why it matters:** this is the very first interaction in the game.
   - **Fix:** the first E on the prompt should open the confirm popup. Don't let the bark bubble eat the input, and accept E on the
     same frame the prompt shows.
4. **Enemy HP "3" doesn't match its bar, and fights run 12-16 turns.**
   - **Where:** `n5j_j02`, `n5s_s02_town`.
   - **Why it matters:** players can't judge how close they are to winning, so it's unclear why they won or lost.
   - **Fix:** show "3 / X" like the player's "15 / 15" and make the bar match. If cave enemies really have 3 HP, explain why the
     fight is about getting past blockers.
5. **Path choice cards are unreadable.**
   - **Where:** `n5b_13_after`, `n5c_c02_more`.
   - **Why it matters:** this is the biggest decision of the opening, and it gets made blind.
   - **Fix:** hover or click to enlarge a card. Put one plain-language line under each Path, e.g. "Red Tape: pay 1, an enemy unit
     gets -2 attack", instead of the jargon paragraph.
6. **Inconsistent node clicks: the boss needs two, others need one.**
   - **Where:** run n5s (the boss tooltip says "Click again or press E to go").
   - **Why it matters:** players think the click failed.
   - **Fix:** use one rule for every node. One click to go, with a hover tooltip for information.
7. **Placeholder-looking grey rocks in the opening shot.**
   - **Where:** `n5c_c06_forest`, `n5q_q_map_1311`.
   - **Why it matters:** this is the first gameplay frame, and it looks unfinished next to the painted art.
   - **Fix:** texture or replace that rock cluster.
8. **The turn counter counts both players' turns.**
   - **Where:** `n5k_k06_t2` ("Turn 3" on my second turn), and the defeat text "12 turns" vs "your 6 turns".
   - **Why it matters:** this is a small confusion, but it shows up in every fight.
   - **Fix:** number rounds ("Round 2 - your turn") and use the same counting on the defeat screen.
9. **The tutorial foe uses other Paths' Resources.**
   - **Where:** run n5k, where the enemy plays Feastforge and Wasteworks so the enemy tray shows Ingredient and Garbage.
   - **Why it matters:** it adds systems the player hasn't been taught in the first five minutes.
   - **Fix:** give cave enemies only colourless or same-Path cards, or add one tip: "Enemies use other Paths' Resources."
10. **Battle layout clipping: name plates overflow and hand cards are cut off.**
    - **Where:** `n5j_j02` ("CAVE SCAVENGER" over the portrait ring, card bottoms cut off by the screen edge), and `n5k_k06_t2`
      (the tip overlaps the phase panel).
    - **Why it matters:** it looks unpolished and hides card stats (the attack/HP badge sits at the very bottom).
    - **Fix:** shrink-to-fit the name plates, raise the hand by about 40 px or show full cards on hover, and anchor tips away from
      the phase panel.
