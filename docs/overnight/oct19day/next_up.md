# Daytime Oct 19 - next up (ranked)

Re-ranked at the end of the daytime run (Mon Oct 19 ~11:00). Most player-visible first. Last night's list: `docs/overnight/oct18/next_up.md`.
What was done today is in `loop_log.md` and `docs/overnight_report.md`.

1. **Primm, three phases in a row, with the leaders' boons** (Balance): without boons the sequence cleared 4-21% per Path; the sim now
   adds the boons but the re-run was stopped by the low-memory guard (inbox Daytime 1). Measure:
   `--what=sequence --filter=boss:primm --games=12` (~11 min). If under 45%, soften phase 2 (reflection) or 3 first - most runs are lost
   there; phase 1 alone stays at 100% even with Royal Guard.
2. **Cave runs on a third seed** (Onboarding): at 100 runs on two seeds Beefcake ~95, Gourmand ~87, Refusemancer ~87, Necrocrat ~87 (the
   cycle-11 deck on main). Judge any further starter or cave change on two seeds x 100 runs (50 runs on one seed swung +/-10 points).
3. **A level-5 Necrocrat in the Gainlands** (Balance): 25-42% vs the roamers after the softer Processing Time. Replays: the reference deck
   floods (Infrastructure + Red Tape) against the Golem's wall - not an AI stall (cycle 9). Try the L5 Necrocrat reference package
   (`ProgressionModel.UPGRADES`, sim only) or the Golem's basics.
4. **The Path choice's 279 words** (Onboarding, inbox Daytime 2): one-line game plan on the tile, identity on hover - a content call.
5. **v0.4.2 when you want it** (Playtest readiness): since the v0.4.1 build, main has the better Necrocrat starter (~87% cave run, was
   ~79%), "Choose your Path" (was "element"), the hero's Path
   / deck / fights / zones in F8 reports, the boss-rules smoke and the refreshed gatekeeper smoke.
6. **Town slow frames** (Performance): the full tour still counts ~57 frames over 33 ms in Crosspath (worst 128 ms, the Deck Station's
   tile build); zones 63-72 ms.
7. **Enemy pictures** (Collection): 90 prompts in `docs/art/bestiary_image_requests.md`; bosses already show portraits.
8. **Townsfolk in the zone hubs** (NPC life): needs a lore call on who strolls in each Path's home.
9. **A listen pass** (Audio): last night's new sounds and the older audio items (music leveller, boss stings, Gristle's loop step).
10. **Tool-only "Own 4/3" in screenshot runs** (Stability, low): `Session.ensure_game` skips the copy-cap conversion.
