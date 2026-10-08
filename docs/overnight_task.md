# Overnight task: Story v2 + Crosspath town layout

You are running UNATTENDED overnight in headless mode. Nobody will answer questions. This task may be split across several sessions: each session is a fresh start that reads this file.

## How to work

1. FIRST, every session: read `docs/overnight_progress.md` (create it on the first run with a checklist of Parts A to I below), then `git status` and `git log -5`. Continue from the first unchecked part. Never redo a checked part. If a part was half-done, finish it from where the code and commits show it stopped.
2. After EACH part: run all GUT tests (including the compile-every-script test), fix failures, update `docs/progress.md`, check the part off in `docs/overnight_progress.md`, commit, and push.
3. Make judgment calls yourself. Log each one in `docs/design/open_questions.md` under a new section "Story v2" and keep going. Never stop to ask.
4. Keep ALL dialogue/story text in the story data files. Names that may change (villain, royal family, the rescuer, place names) live in ONE data location each and are referenced by token.
5. BALANCE IS OUT OF SCOPE. Functionality only. Placeholder enemy decks are fine.
6. Follow the E2E testing budget in CLAUDE.md. This PC runs low on memory: run only ONE Godot process at a time, and never leave Godot processes running in the background.
7. If something is blocked after 3 honest attempts, log it in `docs/overnight_progress.md` with what you tried, and move on to the next part.
8. ASSETS: you are authorized to find, download, and use free assets without asking (overrides the CLAUDE.md "ask me first" rule). Strict licenses: CC0 preferred, CC BY with attribution, never NC/ND/unclear; verify on the source page. Downloads go in `_asset_library/`, copy only used files to `assets/`, log everything in CREDITS.md. itch.io or login-only packs go in `docs/assets_wanted.md` with the link while you use the best alternative.
9. When EVERY part is checked off (or logged as blocked), and only then, create `docs/OVERNIGHT_DONE.md` containing: a summary of what changed, anything blocked, questions for me, and what I should playtest first. Commit and push it. Creating that file is the signal that ends the overnight loop, so never create it early.

## Sources of truth (read fully before Part A)

- `docs/design/story_source_v2.md`: the designer-approved story v2. It wins over `story_source.md`, `story_bible.md`, and all existing content where they conflict.
- `data/source/npc_list.csv` and `data/source/dungeon_list.csv`: exported from my Google Sheet. Canonical character names, roles, portrait image IDs, and dungeon node layouts. Rows 1-3 are notes, row 4 is the header, and rows with only a first column are section headers. If either file is missing, use story_source_v2.md and log it.
- `data/source/design_guidance.csv`: card rules, Paths, Resources, and terminology.

## PART A: Story bible and global renames

- Rewrite `docs/design/story_bible.md` from story_source_v2.md. Keep implementation notes that still hold; delete anything contradicted. Update every other affected design doc (including secrets.md and the placeholder-name sections of open_questions.md, marking them resolved).
- Apply every rename in the "Canon cast and renames" and "Places" tables of story_source_v2.md everywhere: story data, dialogue, NPC data, scene labels, signs, zone portal labels, quest log, codex, tooltips, UI, tests, and docs. Watch for these traps:
  - "Primm's Perfection" used to be the facade town. It is now the name of the whole Capital (shown as "Pathordia" after Primm falls). The facade district is now "the Showcase Quarter".
  - NPC-GUS becomes NPC-ROLLO (Rollo Spokes), including its portrait image ID. The old build's Gus Peelings is replaced by Old Fern.
  - Elder Maren is a female tortoise: she/her everywhere.
  - Mortimer Grimsby and Undersecretary Vellum swap roles (Mortimer is now the Hall boss, Vellum the Appeals Court elite).
  - The Necrocrat freed leader is now Agnes Overdue; the Gourmand freed leader is displayed as "The Grand Chef".
- Put the royal family and prince names in one data file next to the villain data, with tokens (for example `{prince}`, `{royal_house}`).
- Do NOT change the card list or card names (log the open card questions instead).
- Finish with a project-wide search for every old name in those tables. Zero hits allowed outside docs history/changelogs.

## PART B: Crosspath town layout (make the main town feel like a town)

- Bring ALL vendor buildings and cosmetic/service buildings into the town center and arrange them in an organized, town-like layout: Sable (cards), Tilly Tonic (items), Bertram Beetsworth (equipment), Pip Threadwell (clothing), Foil Fenwick (packs), Auntie Alembic (Alchemist), the deck station, Elder Maren's home, and the quest/notice board. Place the Grand Clashatorium (Arena) as a large landmark at the edge of the center, connected by a main road.
- Layout: a central plaza with a landmark (a fountain or statue bearing the royal crest: the four Path symbols in a ring), shop-lined market streets with storefronts facing the paths, and clear, easy-to-follow walking paths connecting the plaza to every shop entrance and out to each zone exit at the map edges. Add signposts at junctions, consistent spacing, street lighting, and readable sightlines. No vendor should be hidden or require hunting for.
- Keep the map's overall size and the outskirts for exploration. Keep the hidden chests, secrets, the graveyard (Old Hob), the Forgotten Vault entrance, the remote giant ninja chest, and the zone exits in place unless they collide with the new layout; if anything moves, update secrets.md.
- Verify collisions, navigation, interaction prompts, NPC wander areas, and the minimap/fog of war. Screenshot a top-down overview and several street-level views, critique them (readability, spacing, path clarity), and do at least one polish pass.

## PART C: Prologue (forest, rescuer, starting deck, the Forgotten Cave)

- New opening: the Wanderer wakes in a small forest outside Crosspath. The Rescuer (NPC-RESCUER: hooded, placeholder portrait until art exists) kneels beside him. Dialogue follows story_source_v2.md: "can you still fight and pull energy from the Paths?", notes how weak he is, asks which Path he walked the most. The STARTING DECK CHOICE happens in this conversation (reuse the existing deck-selection screen; move it here and remove it from any old location; log it).
- The Rescuer points him to the Forgotten Cave, then walks into the trees and vanishes (fade out).
- The forest is a small bounded area. If the player walks too far from the path to the cave, the Wanderer says a self-talk line (for example "I have to go through that cave. The town must be on the other side.") and is gently stopped or turned back. No exploration yet.
- Place the hidden Path-ology Lab entrance in this forest, invisible and inaccessible until the postgame flag (Part H).
- Rename the tutorial dungeon to "The Forgotten Cave" everywhere (internal IDs may stay; all display text changes). Update the Hollow Warden's dialogue (an Old Kingdom guardian of the royal escape tunnel who grumbles that the Wanderer "smells familiar").
- The Forgotten Cave must contain NO Beefcake or Necrocrat infrastructure or Resources: check the tutorial deck, enemy decks, rewards, and any node effects.
- When the player exits the cave, Elder Maren is waiting at the cave mouth: a short scene where she takes him in, guarded and kind, then the player arrives in Crosspath.
- Starting decks: update each Path's starting deck to include more Resource synergy cards (cards that generate and/or spend that Path's Resource, per design_guidance.csv and card_list.csv). Use only existing designed cards, keep each deck legal, and record the final lists in docs/design/starting_deck_and_affinity.md.

## PART D: Path progression lock

- Decks may use only ONE Path until the player completes their first zone, two Paths after that, and 3+ Paths after Primm is defeated (the existing postgame_unlocked flag).
- Dual-path cards can't go in a deck until two Paths are allowed (log this).
- Deck builder and validator: clear, themed messages (for example "You're still too weak to walk more than one Path."). Show a popup when the second Path unlocks, tied to Maren's first memory scene (Part E).
- Old saves: keep decks that become illegal but mark them invalid and prompt the player to fix them. Enemy decks and AI are unaffected. Tests.

## PART E: Elder Maren and the memory fragments

- Update Maren's in-game character to a female tortoise (portrait reference NPC-ELDER; for the world model use a stylized tortoise from available packs if one exists, otherwise the best stand-in, and log what you want in assets_wanted.md).
- After each zone completion, the next time the player talks to Maren, a memory scene plays. Memories follow the NUMBER of zones completed (1 to 4), using the text in story_source_v2.md. Present each one cheaply but atmospherically (dimmed screen, soft four-color vignette, text lines). Memory 1 also announces the second Path. Add a "Fragments" quest log entry that tracks memories recovered.
- Maren's default dialogue changes by stage: guarded at first; admits the resistance at memory 2; admits her Path-ologist past and her part in building the lab at memory 3; recognizes the prince at memory 4. If Primm has already revealed the prince's identity (flag from Part G), her memory 4 scene adapts.
- After the reveal, the player's display name in dialogue changes from "The Wanderer" to the prince's name token. Save/load all of this. Tests.

## PART F: Zone story updates

- The Gainlands / House of Gains: per dungeon_list.csv, node 9 is now "The Iron-less Prison" (where Grandmaster Flex is held) and node 7 is "Stairs Down". Update dialogue: Clench as Flex's former star pupil, Flex's lines to Clench and to the Wanderer, and if Flex wasn't rescued, he walks out of the prison on his own after the boss.
- The Endless Buffet / Test Kitchen: after the boss, the true chef is found in the deep freezer, returns to her kitchen, and bakes a wonder-filled dish that breaks the corrupted-food enchantment (visibly restore corrupted signage and NPCs). Then she gives her name to the Doppelganger ("What you're called doesn't matter. It's what you do that matters."). Afterward she is "The Grand Chef" in UI, and a new NPC named Escoffina (the former Doppelganger) stays in the kitchen as an apprentice with a few postgame lines.
- The D.N.A. / Hall of Final Approvals: Mortimer Grimsby, CE-No, is the boss at the Office of Final Approval; Vellum is the elite at the Appeals Court (update enemy decks and node data). Agnes Overdue is the zone's heart: she gives the dungeon hook, appears with lines at several nodes, and after Mortimer falls, the vacancy scene makes her the new head of the D.N.A. with her speech from the story. The Records Labyrinth shows the transfer document, including the heir clause line. Freed state: Prudence Pallor is her deputy, Gerald's number is called, and Mortimer is placed in the Waiting Room of Eternity right behind Gerald with a few lines.
- The Verdant Dump / Rotheart: add the grief-seed backstory, the "let it rot" cure, and Compostella's lines on the new theme (death as a new beginning; to grow, let things go).
- Each freed leader gets their line to the Wanderer from story_source_v2.md.

## PART G: The Capital, the Castle, and the finale

- The Capital's display name is "Primm's Perfection" (switching to "Pathordia" after Primm falls); the facade district is "the Showcase Quarter". Rollo Spokes gives the Beefcake quest. Wren references Maren as the resistance's contact in Crosspath. Add "escaped Royal Asset" lost-property posters (defaceable like the other propaganda). Add rift dialogue explaining Primm's failing hold.
- Castle: update Primm's Private Gallery (the painted-over royal portrait, only the boy's face left), the Path-ologist records (some in Maren's handwriting), and the Archive of Good Intentions.
- Final boss: if fewer than 4 zones are completed, Primm reveals the prince's identity in his dialogue ("You don't even know, do you? I kept your face.") and sets a flag. Add his Reflection phase line. Freed-leader boons are now Grandmaster Flex, the Grand Chef, Agnes Overdue, and Archdruid Compostella.
- Ending: the Pathwork Throne scene (memory and power fully restored), the Capital renamed Pathordia, Primm realizing the damage he caused, Agnes stamping "HEIR: ALIVE. FILE COMPLETE.", and Maren calling him by name. Primm's fate: in postgame Pathordia, Primm works under guard in a locked workshop on infrastructure and technology, kept away from all Path workings, with a few lines.

## PART H: Postgame (Rip's forest portal and the Path-ology Lab)

- After Primm's defeat, Rip Tearson tells the player he was exploring the forest and saw some interesting things, and has opened a portal station there. Add the forest to the portal network, and reveal the hidden lab entrance.
- Build The Path-ology Lab as a postgame node-map dungeon: 12-16 nodes with branching, extremely challenging placeholder encounters (clearly harder than the castle; no balance tuning). Story nodes: the prince's old cell (ten years of tally marks, a child's drawing of four colors), the draining chamber, and freeing the captured Rescuer (hood down; the name stays a placeholder token). Boss: Dr. Ambrose Siphon, Chief Path-ologist (NPC-SIPHON). Placeholder map art and battleboard in the existing style; use IDs MAP-LAB and BB-LAB so my art pipeline can replace them. Rewards: placeholder unique card(s) or equipment, gold, and XP.

## PART I: Final verification

- Run e2e flows with human-style input (use debug helpers to set flags): new game → forest → Rescuer conversation and deck choice → walk too far (self-talk) → the Forgotten Cave (confirm no Beefcake/Necrocrat infrastructure) → Maren at the cave mouth → Crosspath (walk from the plaza to every vendor) → the deck builder rejects a 2-Path deck → complete a zone → Maren's memory 1 and the 2-Path unlock → House of Gains through the Iron-less Prison node → Hall of Final Approvals with Mortimer as boss and Agnes's vacancy scene → fight Primm with fewer than 4 zones (identity reveal) → ending → Rip's forest portal → the lab entrance.
- Re-run the existing zone e2e flows to confirm nothing broke.
- Screenshot every new or changed screen and area (including the town overview), critique, and polish anything that looks off.
- Repeat the old-name search from Part A.
- Update README.md if the opening flow or controls changed. Then write docs/OVERNIGHT_DONE.md as described above, commit, and push.
