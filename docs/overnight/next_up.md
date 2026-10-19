# Overnight Oct 18 - next up (ranked)

Kept by the Phase 2 loop; re-ranked at the end of the run (Mon Oct 19 ~05:00). Most player-visible first. Last night's list:
`docs/overnight/oct17/next_up.md`. What was done is in `loop_log.md`.

1. **Early walls left** (Balance / Playtest readiness): the Gainlands for a level-5 Necrocrat (17%: the zone's debuff; players are warned
   since cycle 5), the Rotheart normals (54-63%: an AI limit under Overgrowth + Rot), the Iron Cave and Vault normals (71-75%), Brick
   Bronson and Moss Mulligan (54-58%). The levers are design calls (inbox 2-3).
2. **Late bosses that numbers do not move** (Balance): Shiro (88%, a trap deck), Grand Bellows (75-79%), Primm phase 1 (100%; the three
   phases in a row are ~50%). Inbox 4.
3. **Necrocrat and Gourmand tutorial runs** (Onboarding): 82% and 80% over 50 runs, the lowest two; replays show the AI casting
   resource-only cards instead of developing (cycles 9, 24).
4. **The card vendor's open** (Performance): its opening frame is ~37 ms now (cycle 32) plus the stage art when cold (warmed in Crosspath and, since cycle 29, in the zones).
5. **Onboarding timed end to end**: a bot that plays New Game -> forest -> cave -> Crosspath -> first deck edit with real input and
   reports minutes and clicks.
6. **Enemy pictures** (Collection): 90 prompts in docs/art/bestiary_image_requests.md; bosses already show their portraits (cycle 13).
7. **Check "Own 4/3" in the Collection Book** (Stability): the screenshot profile showed Hamster Wheel Runner over its copy cap (on18_codex_check); probably the tool's debug profile, but confirm a real save cannot hold more than the cap. The character screen's first open (130-180 ms) could take the same build split as the shops (cycles 32-34).
8. **One tile style** for the hand-styled choice tiles (UI consistency).
9. **Townsfolk in the zone hubs** (NPC life): needs a lore call on who strolls in each Path's home before any sprites go in.
10. **A listen pass** (Audio): tonight's new sounds and last night's open audio items (music leveller, boss stings, Gristle's loop step).
