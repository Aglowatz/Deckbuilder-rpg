# Overnight Oct 17 - scorecard

Scores 1-10 with the evidence behind each. "Start" = after Phase 1 (Parts 1-14); later columns are updated by the Phase 2 cycles
(`docs/overnight/loop_log.md`). Balance is not a category.

| Category | Start | Now | Evidence |
|---|---|---|---|
| Combat feel | 7 | 7 | Part 8: hit pause scaled to damage, recoil, BLOCKED numbers, turn banners, slow-motion final blow, shake scaled + Reduce shake setting; first-battles smoke 57 fps lowest while animating. Missing: card-play arc is the old lift/land, no enemy death "pop" beyond the dissolve, heal numbers only on the portrait. |
| Visuals - starting forest | 6 | 7.5 | Cycle 3: the open floor read purple because the occlusion fader faded the 900 m floor with a blocking prop's group (88 % see-through, the sky showed through). Fixed: painted floor, moss and the worn path everywhere (on17_forest_fixed). Still: the shot camera sees cave stalactites against the sky at the top edge. |
| Visuals - Crosspath (town) | 8 | 8 | Crosspath pass (Oct 17) + vendor shots: square, six storefronts, lake; bark bubbles and fluff now (Part 11/14). |
| Visuals - Gainlands | 8 | 8 | Gainlands v2 (Oct 17): sandstone plateau, three roads, gym hall; dust motes (Part 14). |
| Visuals - D.N.A. | 7 | 7 | D.N.A. slice with its kit; ghost motes (Part 14). Not re-shot tonight. |
| Visuals - Endless Buffet | 7 | 7 | Buffet slice; steam wisps (Part 14). Not re-shot tonight. |
| Visuals - Verdant Dump | 7 | 7 | Dump layout + art pass; gnats (Part 14). Not re-shot tonight. |
| Visuals - Capital | 8 | 8 | Capital correction pass (Oct 17): wall, towers, rim, 60 fps at ten cameras; ash flakes (Part 14). |
| UI consistency | 6 | 6 | Part 13: one input path (UiInput: confirm/back actions), every overlay focusable with a visible gold focus ring and the first control focused, the same open fade, ConfirmDialog focuses the safe choice. Still uneven: several screens build their own button styles; HUD buttons stay mouse-only by design. |
| Onboarding / tutorial | 7 | 7 | Part 9: Resources taught by doing in battle 1 (made -> spend -> why), the spend variant in battle 2, first deck edit quest; smoke shows every tip appears in order. Not yet timed end to end with a bot (the forest/cave flow). |
| Rewards & progression feel | 8 | 8 | Parts 1, 4-7: copy caps, ten-slot Deck Box, level-5 armory quest, 1-30 reward track (every level gives something), full-screen level-up and reward reveals. |
| Collection / bestiary | 7 | 7 | Part 10: Collection Book by Path and rarity with completion bars, filters, sort, zoom; Bestiary of 90 entries with fun lines and milestones. Icons are generic game-icons (no enemy art). |
| NPC life & dialogue | 6 | 7 | Part 11: barks for 44 NPCs, idle flourishes and face-the-hero (existing), one strolling baker; source of truth with 70 NPCs. Only one walker in town; zones have strollers only where sprites allow. |
| Audio mix | 7 | 7 | Part 12: 35 loops seamless (gaps 0.00 s, jumps within ~2 dB), per-track gain, boss-victory stings, music smoke worst crossfade 0.21 dB. 26 tracks with very wide dynamics remain. |
| Performance | 6 | 6.5 | Tour bot (first run): frames over 33 ms during interactions - town 28 (worst 148 ms), Capital 19 (worst 146 ms), zones 2-8 (worst 108-133 ms); battles 0 over 33 ms. Spikes come with opening menus/shops and scene loads. |
| Stability | 7 | 7 | Tour bot: 275 spots used, 9 menus, 5 battles; the only script errors were in the bot itself (fixed). GUT 1792/1794 (pre-existing camera test + one fixed). |
