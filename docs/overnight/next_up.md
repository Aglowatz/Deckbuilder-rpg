# Overnight Oct 18 - next up (ranked)

Kept by the Phase 2 loop. Most player-visible first. Last night's list: `docs/overnight/oct17/next_up.md`.

1. **Save hitch** (Performance, a regression from Part 3): the crash-safe write parses the whole save twice per write; town frames over 33 ms went 30-39 -> 82. Validate by size, not by parsing.
2. **Early walls** (Balance / Playtest readiness): Gainlands roamers 58-75% at L5, Colonel Casserole 42%, Prudence 38%, Iron Cave / Vault normals 63-67%. Next lever: their one-sided rules (Casserole's free Golem, Prudence's 2 Red Tape), or the Pump It Up buff player-only (inbox).
3. **Late elites and bosses too easy** (Balance): one-sided stat rules for the remaining ones (D-HFA boss, D-HOG boss, Primm phase 1, the Spotter, the Lab elites, Shiro, the graveyard), --games=6 per check.
4. **First opens of big screens** (Performance): after cycle 3 the character screen is ~140 ms, the deck ~135 ms; the card vendor visit still holds ~11 slow frames - not its tile rate and not the 3D world under it (cycle 8); instrument the visit itself with Hitch.
5. **Enemy pictures** (Collection): 90 prompts ready in docs/art/bestiary_image_requests.md (art, not code).
6. **Onboarding timed end to end**: a bot that plays the forest -> cave -> first deck edit with real input and reports minutes and clicks.
7. **The Buffet's flat gravy plane** in front of the bridge (Visuals - Buffet).
8. **One tile style** for hand-styled choice tiles (UI consistency).
9. **Townsfolk strollers in the zone hubs** (NPC life).
10. **Necrocrat tutorial clear 71%** (the lowest Path): check its three tutorial fights card by card.
