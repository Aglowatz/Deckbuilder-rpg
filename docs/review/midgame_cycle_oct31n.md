# Mid-game critic cycle - Overnight Oct 31 -> Nov 1

Save: `midgame_real` (story bot: cave, Maren's chain, the Gainlands and the D.N.A. freed with their dungeons; L13 expected deck, gear,
600 gold, packs). Both critics played from a worktree at the last commit (`/c/Dev/wp_critic`), never from the working tree.
Brief: `docs/review/critic_brief_midgame_oct31n.md` (second look: `_second_oct31n.md`, same brief, fresh agent, did not see the first report).

## Scores

| Area | First (3a2cbaf5) | Second look (df634833) |
|---|---|---|
| Clarity | 5 | 6 |
| Pacing / friction | 3 | 4 |
| Combat depth / feel | 5 | 4 |
| Bosses | 4 | (in combat) |
| Deck-building | 6 | 6 |
| Packs / shops / reward rhythm | 5 / 4 | 5 |
| Exploration / world | 6 | 6 |
| Story / humour | 7 | 6 |
| Visuals / readability | 6 | 7 |
| UI/UX consistency | 4 | 5 |
| Performance | 7 | 7 |
| Bugs | 4 | 5 |
| **Overall** | **4.8** | **5.5** (mean of its areas) |

Reports: `docs/review/fresh_eyes_midgame_oct31n.md`, `docs/review/fresh_eyes_midgame_oct31n_second.md`. Triage of the first:
`docs/review/fresh_eyes_midgame_oct31n_triage.md`.

## Fixes between the two (df634833)

1. The "frozen" boss intro: clicks on the cutscene's text panel were swallowed by the panel (keys worked) - the panel lets clicks through.
2. Plain tooltips spell energy codes ("Exhaust: add one Beefcake energy."; "(N)(N)" -> "two Necrocrat energy").
3. "units and spells" instead of "spells" in the opening-hand and Deck Station counts.
4. Esc closes the topmost Deck Station popup ("Suggest a deck"...) before the station.
5. Deck-test events state the test and your deck's chance before the reveal; only the tutorial well says "the well stays silent".
6. "Where to?" names every place on the map, walked to or not (Deck Station, Hall of Records included, up to 16); a pinged place shows
   its icon and name through the fog.
7. "No cards match these filters" in the Deck Station.
8. The Rotheart's dungeon rule "Overgrowth" is "Wild Growth" (the Dump's zone effect keeps "Overgrowth").
9. Toasts wait, hidden with their timers paused, while a reward pick is up (a feat toast covered the boss reward header).
10. A once-per-visit "X is free" banner in freed zones.

## After the second look (this commit)

- **Sable unreachable** (both critics): her prompt needed you north of her, behind the stall. Vendor reach 2.3 -> 2.7 (x 1.2 = 3.24 m, her
  bark's range); NPC prompts name who answers ("[E] Talk to Sable").
- **Stuck in "Choose a target"**: clicking another card in hand cancels the target choice and picks that card up.
- **Quit Game** asks first and saves (it closed at once, unsaved).
- **"Open all" packs** (both critics): every plain pack in one go with one summary (new cards, more copies, essence/gold); gilded packs keep
  their ceremony.

## What the second look still says (design calls, in the inbox)

- **Difficulty wall in the Buffet and the Dump** for a two-zones-freed Beefcake deck (4 of 4 fights lost, mostly by the pilot): zone rules
  Rot / Wild Growth counter the Path; the sims put the Doppelganger at 25 % (TOO HARD band). Recommended: a danger/recommended-level tag on
  nodes, and a boss tune pass with the built deck.
- **The large hand** (13 cards by turn 11 overlap; clicks hit the wrong card): needs a hand-layout change (second row or compression).
- **Boss scenes long; the twist named early**: "The Doppelganger" on the plate is the designer's answer 10 (cover name until the reveal);
  the node card says "Boss: Grand Chef Escoffina". Typewriter: one press finishes, one advances (kept).
- Placeholder icon stages in cutscenes without a still (art), E takes the highlighted reward card (the one Continue rule), the freed D.N.A.
  still has no healing (the HP rules call).
