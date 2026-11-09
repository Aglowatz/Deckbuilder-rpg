# Cut or finish? (Nov 9) - analysis only, no decisions taken

Every feature and content piece, rated against the bar set by the Deck Station and the Character page (painted backdrop, clear layout, tooltips,
pad support, no placeholder look). Sources: tonight's quest audit and per-Path story bot (`docs/quests/quest_audit.md`, `_logs/full_play/`),
the Nov 6 and Nov 8 critic reports (`docs/review/critic_nov6/`, `docs/review/critic_nov8c/N8.md`), the art audit (`docs/art/art_audit_nov9.md`)
and the inbox. **Nothing was changed because of this page.**

Columns: **Done** = content completeness. **Bugs** = known open issues. **Polish** vs the Deck Station bar (A = at the bar, B = close, C = looks
or feels placeholder). **E2E** = plays start to finish (bot or critic). **Effort** to make it 1.0-solid: S (under 2 h), M (half a day), L (a day+).

## Zones and dungeons

| Piece | Done | Bugs | Polish | E2E | Effort | Recommendation | Why |
|---|---|---|---|---|---|---|---|
| Opening forest + Forgotten Cave (tutorial) | full | critic N8: forest too dark, hero lost behind foliage, black slab over the cave arch; a loss restarts the whole cave from the bedroll | B | yes | M | **finish** (S for the light/slab, S for "restart at the cave mouth") | first 60 seconds of every player's game |
| Crosspath (hub) | full | roofs fill a third of the default view; NPC tags stack at Low camera; fountain look (partly fixed Nov 8) | B | yes | M | **finish**: roof fade near the camera (M) | the hub is seen most |
| The Gainlands + House of Gains | full | none blocking | A | yes (bot, 4 Paths) | S | keep as is | |
| The D.N.A. + Hall of Final Approvals | full | none blocking | A | yes | S | keep as is | |
| The Endless Buffet + Test Kitchen | full | none blocking | A | yes | S | keep as is | |
| The Verdant Dump + the Rotheart | full | thorn wall now painted (Nov 8) | A- | yes | S | keep as is | |
| The Capital + Primm's castle | full | load 6-9 s (accepted Nov 8) | A | yes | S | keep as is | |
| Side dungeons S-IRON, S-NECRO, S-GOUR, S-REF, S-CAP, S-PASTE, S-TOWN | full | none blocking | A- | yes (bot/critics) | S | keep as is | |
| Path-ology Lab (postgame) | full | none found tonight | A- | yes (bot) | S | keep as is | the story's real ending beat (Elowen) |
| Shattered Gallery (postgame) | full | N8: a stale node tooltip under the pre-fight modal; the entrance node shows "?" after a dev jump | B | yes (bot) | S | **finish** (tooltip close, S) | |
| Mount Swolympus (S-BEEF, postgame) | full | entry needs Old Man Mountain's errand first (by design) | A- | yes (bot) | S | keep as is | |
| The Undercroft arena | 8 bouts | none known | B | partly (Loose Ends needs one bout; not botted) | S | keep as is | |
| Town extras: store-room ghosts, graveyard, ninja chests (Shiro), four-lever vault | full | none known | A- | yes (tests; critics) | S | keep as is | |

## Minigames

| Piece | Done | Bugs | Polish | E2E | Effort | Recommendation | Why |
|---|---|---|---|---|---|---|---|
| Quizzes (one per zone, painted classroom since Nov 8) | full | N8: no right/wrong highlight, feedback bubble near-invisible; one answer key looked wrong to the critic (Gainlands "mills and hamster wheels") | B | yes | S | **finish**: flash right/wrong 1.5 s + check that key (S) | an "obviously right answer marked wrong" reads as a bug |
| Rep Counter (gym, painted since Nov 8) | full | none known | A- | yes | S | keep as is | |
| Dex's Matching Circuit (5 tables) | full | N8: flat placeholder cards, no table/backdrop, quest toast over the title | C | yes | M | **finish** (M: painted back + felt backdrop + Dex portrait) **or hide** the circuit for 1.0 (S: Dex not placed; quest not offered) | the only minigame that looks unfinished |
| Hamster wheel / protein stand / flex mirrors / oven / mounts / herding (zone favours) | full | none known | B | yes | S | keep as is | |

## Systems

| Piece | Done | Bugs | Polish | E2E | Effort | Recommendation | Why |
|---|---|---|---|---|---|---|---|
| Battle (rules, AI, boss scripts) | full | N8: played Infrastructure shows as a tiny card above the hand; 12-card hands overlap in two rows | A- | yes | M | **finish** the infrastructure row (S) ; hand fan cap (S) | core loop |
| Deck Station + deck slots + Refuse Pile viewer | full | none | A (the bar) | yes | - | keep as is | |
| Character page + equipment | full | pill text fixed Nov 8 | A (the bar) | yes | - | keep as is | |
| Items (4 slots, single use) | full | none known | A- | yes | - | keep as is | |
| Packs + Card Packs page | full | N8: shelf cut-off 8th pack, no scroll affordance; HUD/page count disagree by 1 | B | yes | S | **finish** (arrows + count refresh, S) | |
| Economy (gold, shops, high shelf) | tuned Nov 8 (21.3k no-grind) | none known | A- | sims | - | keep as is | |
| Crafting (Auntie Alembic's) | full | N8: essence bars don't fill, empty brew panel | B | yes | S | **finish** (fill bars, S) | |
| Wardrobe (hats, cloaks, dyes) | full | N8: cloak tile ignores the dye | B | yes | S | **finish** (tint tile, S) | |
| Feats | full | none known | B | tests | - | keep as is | |
| Bestiary / Collection Book / Glossary | full | none known | B | tests | - | keep as is | |
| Quests (all lines, 42 quests) | full; audit clean tonight | fixed tonight: 5 side quests could be stranded by taking once-ever pickups early | A- | yes (bot + audit) | - | keep as is | |
| Saves (3 campaigns x slots, autosave, backups) | full | fixed tonight: a save taken in a dungeon/battle reloaded in Crosspath instead of the zone | A- | yes (bot save/load) | S | add an autosave indicator (S, see ship checklist) | |
| Settings / controller / rebinding | full | - | A- | tests | - | keep as is | |
| Fast travel (Rift Express) | full | none known | A- | yes | - | keep as is | |

## Totals against the 3 days left (Nov 9-11)

Recommended "finish" list: forest light + slab + cave restart (M), Crosspath roof fade (M), quiz feedback + key check (S), Dex circuit art
(M) *or* hide it (S), battle infrastructure row + hand cap (M), packs shelf (S), alchemy bars (S), wardrobe tint (S), Gallery tooltip (S),
autosave indicator (S). **About 2.5-3 working days** if Dex is finished, **about 2 days** if Dex is hidden for 1.0. That fits Nov 9-11 only with
night runs doing the M items and the owner spending the day on art (Batch 14) and playtesting; the S items are good daytime $20-plan tasks
after Nov 12 too.

Nothing is recommended for cutting outright: every zone, dungeon and system plays end to end. The one "hide for 1.0" candidate is Dex's
Matching Circuit, and only if its art can't be done in time.
