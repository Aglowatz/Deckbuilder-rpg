# Overnight Oct 18 - next up (ranked)

Kept by the Phase 2 loop. Most player-visible first. Last night's list: `docs/overnight/oct17/next_up.md`. Re-ranked after cycle 8.

1. **Early walls left** (Balance / Playtest readiness): Gainlands roamers for Necrocrat (17%: the zone debuff; players are now warned, cycle 5) and Gourmand (33-83%), the Iron Cave and Forgotten Vault normals (63-67%), Brick Bronson and Moss Mulligan (58%), the Rotheart normals (58-63%, an AI limit under Overgrowth + Rot; inbox).
2. **Late bosses that ignore stat rules** (Balance): Captain Spotless 92%, the Vault Automaton 71%, Shiro 83%, the Spotter 79%, Primm phase 1 100% (Standardization overrides stats). Needs a design call (inbox 4) or start-of-duel effects.
3. **Necrocrat's tutorial run 76%** (Onboarding): the lowest Path, lost mostly at the Hollow Warden; check its three fights card by card.
4. **The card vendor visit** (Performance): ~13 slow frames per visit in every bot run; not the tile build (167 tiles, measured; trickling them changed nothing), not the 3D world under it. Profile the visit itself (talk -> VendorStage art -> music push -> first frames) with Hitch; the town-only bot is bimodal (~45 / ~80 slow frames), so compare several runs.
5. **Onboarding timed end to end**: a bot that plays the forest -> cave -> first deck edit with real input and reports minutes and clicks.
6. **Enemy pictures** (Collection): 90 prompts ready in docs/art/bestiary_image_requests.md (art, not code).
7. **Capital walk smoke: one flaky check** (Stability): a strolling citizen can stand nearer than the portrait the smoke walks to (portrait_f1 gets citizen_1's prompt). Make the smoke step closer or wait for the stroller.
8. **One tile style** for hand-styled choice tiles (UI consistency).
9. **Townsfolk strollers in the zone hubs** (NPC life).
10. **Arena tier 2 spells-only (Cardboard Colossus) 17%** for the sim's normal decks: a puzzle that wants a spell deck; check that the arena tells the player so.
