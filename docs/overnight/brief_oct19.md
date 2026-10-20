# Overnight brief - Oct 19-20 (9 hours, autonomous)

Saved copy of the brief so a resumed session can re-read it. Rules: STOP_OVERNIGHT check per part/cycle; one Godot at a time; keep all
dialogue keys / quest ids / flags stable; no art generation (don't touch Pending Review); no build export; never show enemy intent, touch
the black market vendors, add chapters / explorable sub-areas / walkable dungeons, put readable text in the 3D world, or make monetization
decisions. Kingdom: Patchwork. Every part ends with GUT + walkability + relevant smoke + commit + push; revert what can't pass.

1. D.N.A. visibility (~90 min): remove the overhead fixtures/panels/beams; light with wall fixtures/emissives; walls full interior height;
   camera occlusion fade for anything between camera and hero (all presets V/F, swivel Z/X, corridors, cubicles, doorways, dungeon entrance);
   then the same check + fade in Crosspath, Gainlands, Buffet, Dump, Capital, starting forest. Before/after shots, Medium 60 fps, walk smokes.
2. Card ability text never hidden (~45 min): one tooltip box on the top UI layer beside the hovered card (flip near edges), never covering
   the card; same for hand, field, traps, tokens. Before/after shots. Test.
3. Art import prep (~60 min): drop-in imports for card art, portraits + SPR- sheets, ICON-GEAR-*, ICON-ITEM-<ID no underscores> (fallback),
   ICON-COS-<art_name>, Gainlands kit, MAP-S-IRON / BB-S-IRON, DUMP-* kit, BST-* bestiary (new Drive folder Approved_Bestiary ->
   assets/art/bestiary), redone UI-BG-CHARACTER with no painted slots. Equipment screen: only 5 slots around the figure (helmet head, weapon
   right hand, armor chest, boots feet, relic left hand); item slots in their own labelled section; works with old and new background.
   Fix docs/art/*.csv imported as translations (.gdignore, delete stray .translation). Write docs/art/import_oct20.md.
4. Story bible (~90 min): docs/design/story_bible.md as THE reference (older docs archived with a pointer); full contents list in the
   brief; authority order: user's locked decisions > design sheet canon > game data > old docs; contradictions resolved listed,
   ones needing the user in the inbox; update canon.md.
5. Dialogue pass to AAA (~3 h): voice sheets (voice_bible.md), beat map (dialogue_beats.md), rewrite in priority order (opening/tutorial,
   Crosspath, main beats + bosses, Path zones, Capital, barks), separate editor subagent scoring 1-5 (in character, funny, beat landed,
   brevity, clarity of next step), rewrite <4. Keep keys/ids/flags; tests: box overflow for every line, banned old names, every quest step
   has instruction text. Report docs/design/dialogue_pass_oct19.md with scores before/after per zone and the 30 best before -> after.
6. Old Well secret quest (~2 h): well -> eerie vision starts quest; task in the Verdant Dump + task in the Endless Buffet (small themed
   secrets); return -> hard node-based challenge battle vs a Wellspring guardian/echo with a one-sided rule shown with rule icons; unique
   reward (card or relic + lore reveal), sim-balanced, logged. Fit with The Forgotten Vault under the well. Subtle markers, quest log,
   save-safe, tests, story bible updated.
7. Music (~60 min, no generation): tracks rated 1-2 in docs/audio/music_audit.md + Crosspath's: fix (loops, length, starts/ends,
   loudness, gentle EQ) with ffmpeg or replace with a better existing track; re-rate. Drop-in music import pipeline (Approved_Audio ->
   loop points, loudness, OGG, register, assign). docs/audio/music_generation_prompts.md (shared main motif, file IDs, Crosspath first).

Phase 2: scorecard loop (add "Dialogue & story"), 45-60 min cycles, lowest category first, never the same category 3x in a row; every 4
cycles run tour + story bots. Morning report docs/overnight_report.md (archive last night's).
