# Onboarding timing: New Game -> first deck edit

Daytime Oct 19, Part 3. Tool: `bash tools/run_onboarding_timing.sh` (windowed, ~70 s; writes `_screenshots/onboarding_timing.json`
and two screenshots, `onboarding_gate.png` / `onboarding_station.png`). Bot: `tools/onboarding_timing.gd`.

## How it measures

- **Real input**: clicks on the title (New Game) and the Path choice, **E for every dialogue line** after the line has finished typing
  (a reader never skips the typewriter here), WASD walking at the hero's real speed, E at the cave gate and the Deck Station, a click on a
  collection card, Save Deck and a rack slot.
- **Reading model**: 3.5 words per second (210 wpm) plus half a second to press on, with the typewriter as the floor; screens count
  their visible words (the Path choice counts all four tiles - an upper bound, most people read one or two).
- **Modelled, not played**: the Forgotten Cave (three duels from the first-battles smoke - 9 / 13 / 5 turns, 46 / 35 / 13 s at bot
  pace - plus ~12 s of thinking per own turn, 90 s for the map, the Hollow Well, the shrine and three reward picks). The bot gives itself the
  cave's three reward cards the way `apply_rewards` does, then leaves through the Session's own exit.
- **Walks**: the bot walks in a straight line; where a building or fence stops it, the rest is modelled at walking speed x1.4.
- **Dead time** = seconds the SceneManager was busy (loading, fades) - input does nothing then.

## Result (Beefcake, Mon Oct 19, after the fixes below)

| Segment | Bot s | Person ~s | Clicks/keys | Dialogue lines | Dead s | Note |
|---|---:|---:|---:|---:|---:|---|
| Title -> New Game | 4.2 | 4 | 2 | 0 | 0.9 | one click is the overwrite question (this PC has saves; a new player has 1 click) |
| Forest: the opening still and wake-up -> Path choice | 21.4 | 70 | 18 | 18 | 0 | 4 still captions + 14 lines |
| Path choice | 0.6 | 80 | 2 | 0 | 0 | 279 visible words (four tiles of ~70) |
| Forest: the Rescuer after the choice | 9.1 | 30 | 6 | 6 | 0 | |
| Walk to the cave gate + Enter | 7.7 | 12 | 3 | 0 | 1.0 | |
| The Forgotten Cave (modelled) | - | 364 | ~54 | - | 1.5 | three duels ~4.5 min, the rest ~1.5 min |
| Crosspath: Maren's welcome | 12.3 | 43 | 7 | 7 | 0 | |
| Walk to the Deck Station | 4.3 | 13 | 1 | 0 | 0 | ~32 m, around the square |
| Deck Station: tip, Save Deck, pick slot 1 | 3.0 | 20 | 4 | 0 | 0 | |
| **Total** | **70 s** | **~10.6 min** | **97** | **31** | **3.4** | |

Without the cave: ~4.5 minutes, 43 clicks/keys, 31 dialogue lines, of which ~2.5 minutes is reading before the first step in the forest.
Loading and fades are negligible (3.4 s in all).

Other Paths (`ONBOARD_PATH=necrocrat bash tools/run_onboarding_timing.sh`, loop cycle 3): Necrocrat ~10.6 min, Gourmand ~10.8,
Refusemancer ~10.6 - the same 97 clicks/keys and 31 lines; every Path reaches the first saved deck edit with no Path-specific snag.

## Slow or confusing spots, and what was done

1. **Fixed - the first deck save was impossible without a pointless change.** The cave's reward cards join the deck as they are picked,
   and a new hero owns exactly one set of cards, so on the first Deck Station visit every card is already in the deck ("You do not own
   another copy") and **Save Deck sat greyed out as "Saved"** - but "Make It Yours" completes only on a save. Save Deck now stays available
   until the first save (`DeckbuilderScreen._refresh`; test `test_the_first_save_needs_no_change`).
2. **Fixed - the quest told players to add cards that are already in.** "Make It Yours" read "Put the ones you like into your deck";
   it now says the cave's cards are already in the deck, to look it over (swap out what you don't like) and save it to a slot.
3. **Noted, not changed (content call) - the Path choice is the longest read**: 279 words on one screen, after 18 lines of dialogue.
   Options for later: show the one-line game plan on the tile and move the identity paragraph to hover; or keep it (a first choice
   deserves reading). See the inbox.

Other observations: the first-visit Deck Station tip covers the top of the collection until "Got it" (fine, it is the lesson); typing
is ~1.2 s per line at the default speed, never in the way; the walk from Maren to the station is ~13 s with the quest marker pointing.
The bot found no dead ends besides item 1.
