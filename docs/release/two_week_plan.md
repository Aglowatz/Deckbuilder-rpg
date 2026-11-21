# The two weeks to 1.0 - The Wayward Path

Written Nov 21 2026 (Fable Nov 21 review, Part 8). Everything left before the release, **ranked by what a player would feel**.
Release day in this plan: **Saturday Dec 5**. If it moves, move the days with it; the order stays.

**Who:** *You* = the owner, by hand. *Claude* = one Claude Code run (the size says how long). *Art* = a ChatGPT art batch you
run from the sheet, then a short Claude run to import it. **Size:** S under an hour, M an evening (2 to 3 hours), L a day.

Where the facts behind each line are: the audit, the performance numbers and the polish list in `docs/overnight_report.md`
("Fable Nov 21 review"); the balance tables in `docs/balance_report_nov21.md`; the steps of the release itself in
`docs/release/release_checklist.md`.

## The short version

The game holds together: four automated playthroughs (one per Path, new game to the postgame) pass every check, old saves load,
no quest can strand a player, and nothing clips at 720p or 1080p. What is left is **your hands on the real game**, **three balance
decisions**, **the page**, and a short list of small things. Nothing on this list is a blocker today.

## A. What a player would feel most (do these)

| # | What | Why a player feels it | Who | Size | Day |
|---|---|---|---|---|---|
| 1 | **Play the exported game start to finish once, with real fights, on a fresh save.** Note every wall, every moment you did not know where to go, every line that reads wrong. | No machine has played real fights through the real screens since Nov 17, and four days of changes sit on top (the heal rooms, the drawbacks, the foe's opening hand, the reward boxes, the glass screens). The bots prove the game cannot break; only you can say whether it is fun and fair. | **You** | L (12 to 16 hours over several evenings) | Sun Nov 22 to Fri Nov 27 |
| 2 | **Decide the House of Gains as a first dungeon.** The sims say the new heal rooms cost almost nothing (0 to 3 points of clear rate; leave the heal at 5), and that the House of Gains is cleared at the first try by one run in four on level 8, because Vivienne Quota ends a third of all runs before the heal room (balance report, 1b). Play it, then decide whether she should lose a step. | It is most players' first real dungeon. A wall there is felt by everybody; a wall at Mortimer only by Beefcake players. | **You** decide, Claude applies | S | Tue Nov 24 |
| 3 | **Approve the Arena table** line by line (balance report, section 2) and have it applied. | Four of the six Arena battles are won nine times in ten or more; the last tier, meant as the hardest fight in the Arena, is won 98 times in 100. A player who likes the Arena finds nothing to chew on. | **You** tick, **Claude** applies and re-simulates | S + M | Mon Nov 23 (tick), Tue Nov 24 (apply) |
| 4 | **Decide Mortimer for Beefcake** (balance report, 1c). An on-level Beefcake deck lost to him 18 times in 18 (8 fights, 10 whole runs). The other one-Path walls (Clench for Refusemancer, Compostella and Siphon for Beefcake, two optional bosses) I would leave. | A Beefcake player who reaches the D.N.A. on level cannot win its boss without a second Path. The level hint on the door helps; one step off Mortimer helps more. | **You** decide, Claude applies | S | Wed Nov 25 |
| 5 | **A second playthrough by a real-fight bot** on the final numbers (`bash tools/run_full_real.sh <path>`, one Path a night). The bots can finish boss fights again since today (they stopped at every scripted-event pop-up since Nov 19). | It finds the walls you did not hit because you play one Path. | **Claude** (unattended, one Godot) | L per Path (3 to 4 hours each) | nights of Nov 25, 26, 27 |
| 6 | **The final build and the 20-minute check of the real .exe** (checklist D), on your PC and, if you can, a second one. | A build that does not start is the only true blocker a release can have. | Claude builds, **You** check | M | Sat Nov 28 |
| 7 | **Playtesters for five days** on the Restricted itch page (checklist F), then fix what they find. | Fresh eyes find the first-hour stumbles nobody on the inside can see any more. | **You** invite, Claude triages and fixes | M + M | Sat Nov 28 to Thu Dec 3 |
| 8 | **Release** (checklist G): tag, last look, Public. | - | **You** | S | **Sat Dec 5** |

## B. Things a player would notice (do them if the week allows)

| # | What | Who | Size | Day |
|---|---|---|---|---|
| 9 | **Batch 19, two pictures:** the Endless Buffet's map with the Raw Deal in its new place, and the locked Necrocrat pack as a sealed parcel like the other three (`docs/art/batch19.csv`). The D.N.A. map's mood stays as it is (your answer). | **Art**, then Claude imports | S + S | Mon Nov 23 (paint), Tue Nov 24 (import) |
| 10 | **Two "freed" lines for the Gainlands:** Gary (still under his barbell while Brenda says he is lifting) and the rep-game host (still "the regime banned my show"). Two to four lines in your voice; the importer takes them from a CSV. | **You** write, Claude imports | S | any evening |
| 11 | **Which camera preset a new player starts on.** Today +6 degrees (preset 1 of 5). Play ten minutes on 2 and 3 and pick; it is one number. | **You** decide, Claude sets | S | during item 1 |
| 12 | **The itch page:** edit `docs/release/itch_page.md` in your words, choose among the eight screenshots, decide the AI disclosure's "Code" tick (inbox 4) and the donation link. | **You** | M | Thu Nov 26 |
| 13 | **The economy** (balance report, section 3): a no-grind run earns 23,131 gold against your 21.2k target (9 % over). Leave it, or trim the newest quests. Separately: a full collection costs about 75,800 gold today (a brew is 6 essence a Path again); decide whether that is the length you want. | **You** decide | S | Wed Nov 25 |
| 14 | **The player read-me in the zip:** switch the export from the playtest read-me to `docs/release/player_readme.txt` for the public build. | Claude, on your word | S | with item 6 |

## C. Nice to have (after 1.0 is fine)

| # | What | Who | Size |
|---|---|---|---|
| 15 | **More Arena puzzles:** two more would make six, one per pair of Paths. The solver and the lab tool make a new one cheap to prove; inventing a good one is yours. | You design, Claude proves | M each |
| 16 | **The gold screens beside the glass ones:** the Deck Station and the Character page converted to the glass look (no new art needed). | Claude | L |
| 17 | **Glossary keywords in their Path's colour** (one column in the keyword table, then the glossary reads it). | Claude | S |
| 18 | **Rip's walk** (he turns on the spot; walking frames would only matter if he ever follows the player). | Art + Claude | M |
| 19 | **An on-screen keyboard for the Deck Station's search box** (controller only). | Claude | M |
| 20 | **"Freed" lines for the other zones' quiz masters and minigame hosts** (they say nothing that dates, so nobody will notice). | You | S |
| 21 | **The D.N.A.'s map repainted at dusk** (the optional Batch 19 row). | Art | S |

Closed by this review, so off the list: **Elowen's walk** (it is not missing: she and her disguise both have full walk sets in the
game); the info screens following the Text size setting; the rose window on the title; the zone maps' sharpness.

## The balance decisions in one place

They are spelled out with numbers in `docs/balance_report_nov21.md`. In order of how much a player feels them:

1. **The Arena table** (item 3): one proposed row per battle, each with its simulated win rate (for example Grand Bellows
   from 88 % to 54 %, the Unbound champion from 98 % to 50 %).
2. **The House of Gains** (item 2): one first-try clear in four; Vivienne Quota is the lever, not the heal room. The heal
   rooms themselves: leave them at 5 HP.
3. **Mortimer for Beefcake** (item 4): 0 wins in 18. The other one-Path walls: leave.
4. **The economy** (item 13): income 9 % over the target; and what "finish everything" should cost (about 75,800 gold
   today, 13 hours of repeat clears after the story).

I changed no card, enemy or Arena number.

## If time runs short: what to cut, in this order

1. **Cut section C whole.** None of it is felt in a first playthrough.
2. **Cut item 5** (the real-fight bots) down to one Path, your own.
3. **Cut item 4:** leave Mortimer. The level hint and a second Path already soften him, and a wall for one Path is a smaller
   sin than a last-minute number nobody has played.
4. **Cut item 13:** leave the economy; a little too much gold hurts nobody.
5. **Cut item 9's second picture** (the locked pack). Keep the Buffet map: its mistake is on a screen players open often.
6. **Shorten item 7** to a weekend with two testers.

**Do not cut:** item 1 (your own playthrough), item 3 (the Arena is the one place the game is plainly unfinished), item 6 (the
real .exe check). If only three things happen in two weeks, those are the three.

## Day by day

| Day | You | Claude Code (one run) |
|---|---|---|
| Sat Nov 21 | read the report and the inbox | this review |
| Sun Nov 22 | play: the forest, the cave, Crosspath, your own zone | - |
| Mon Nov 23 | play: the second zone; tick the Arena table; start Batch 19 | - |
| Tue Nov 24 | play: the third zone; decide the House of Gains | apply the Arena rows and that decision, re-simulate, import Batch 19 |
| Wed Nov 25 | play: the fourth zone; decide Mortimer and the economy | apply; real-fight bot, Path 1 (night) |
| Thu Nov 26 | play: the Capital and the castle; edit the itch page | real-fight bot, Path 2 (night) |
| Fri Nov 27 | play: Primm, the ending, an hour of postgame; write Gary's lines | fix what you found; real-fight bot, Path 3 (night) |
| Sat Nov 28 | the 20-minute .exe check; page to Restricted; invite testers | the suite, the smokes, the export, the exported checks |
| Sun Nov 29 to Wed Dec 2 | collect reports | triage; fix blockers and first-hour stumbles |
| Thu Dec 3 | last decisions | the final suite and export; the exported checks |
| Fri Dec 4 | the final .exe check; upload; read the page as a stranger | tag v1.0.0 on your word |
| **Sat Dec 5** | **Public** | - |
