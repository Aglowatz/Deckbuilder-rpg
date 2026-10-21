BUILD THE MISSING STORY CONTENT + BALANCE FIXES (user brief, Oct 21 2026; copy)

Read CLAUDE.md, docs/design/story_bible.md (incl. its "[canon, not built]" items and contradictions section), docs/design/canon.md,
docs/design/voice_bible.md, docs/overnight_inbox.md (Oct 19-20 items 1-5, 10), the Dungeon List rows in data/source/dungeon_list.csv (S-PASTE,
D-HOG node 6, D-PC nodes 1 and 14, D-LAB nodes 11 and 16), docs/design/balance_state.md and balance_log.md first.

DECISIONS (user's): the lieutenants and Isla are humanoid animals as in their new art (Quota ferret, Crumb badger, Plume peacock, Clipwell
hare, Isla bear - update npcs.json, the story bible and canon to match; Isla needs one line establishing she takes after her mother's side or
similar, keep it light). Elowen stays "The Rescuer" ({rescuer}) until Percival Plume has her seized at the castle gate on the Wanderer's first
entry - Plume names her there ("Miss Elowen Vey, I presume"), and from then on her name is used. Log any other judgment call in
docs/overnight_inbox.md.

RULES: one Godot process at a time, close Godot between runs, max 10-12 screenshots per part; STOP_TASK check per part; GUT + relevant smokes
+ commit + push per part; old saves keep loading (new content must trigger sensibly for saves already past those points - e.g. a save past the
castle gate gets the capture as a story note/memory, not a broken state); keep ids/flags stable; all dialogue to the voice bible standard
(funny where it should be, sincere at reveals, short lines, no spoilers in quest text, objectives revealed one at a time); every new encounter
uses the one-sided rule icons and is sim-tested; no new art generation (portraits and world sprites for the lieutenants, Elowen, Isla, the
King and Queen now exist - use them; list missing pictures such as bestiary entries in docs/art/art_backlog.md); no enemy intent; don't touch
the black market vendors.

PART 1 - The four lieutenants as real encounters (each with intro/defeat dialogue, a one-sided rule, a sim-tested deck, a reward, a bestiary
entry, and their "flees to the Capital" beat where the sheet says so)
- Vivienne Quota (Beefcake): the Regime Checkpoint elite in the House of Gains (D-HOG node 6) - she "measures" the Wanderer; flees to the
  Capital when the zone falls; appears later in the Capital as the sheet describes (or a short scene if no node exists).
- Colonel Cornelius Crumb (Gourmand): inspects the prototypes in the Test Kitchen (a scene at the Prototype Bay elite), flees when the Buffet
  is freed; build S-PASTE "The Paste Works" side dungeon in the Capital (3 battles: Ration Line, The Vat Floor, The Colonel's Kitchen; rules
  Bland Diet: healing does nothing; Real Food: Gourmand cards cost 1 less for the player), reached through Chef Marlo's quest (create or
  extend it); reward per the sheet or a fitting unique card/relic.
- Percival Plume (Necrocrat): has the Rescuer seized at the Castle Gate (D-PC node 1 story beat - the capture scene and the name reveal);
  the Necrocrat Wing: Notarized Archives elite (D-PC node 14) with his memo revealing where she was sent; the NPC everyone loves to hate.
- Hortensia Clipwell (Refusemancer): the one who outlawed composting and brought Compostella the deathless seed; a one-off encounter (pick a
  fitting node/moment in the Verdant Dump's story or the Rotheart approach), flees to the Capital when the zone falls.

PART 2 - Elowen's arc
- Cave Mouth scenes: after each freed zone, a short scene with the Rescuer at the forest cave mouth (or wherever the bible places them) that
  builds the relationship and hints at who she is without spoiling it; 4 scenes total, each a little warmer, the last one before the Capital.
- The capture at the castle gate and the follow-up: the resistance/Maren react; the Path-ology Lab postgame rescue in Cell 4 (D-LAB node 11,
  optional branch) plays as the sheet describes ("Took you long enough, Tess."); if rescued she fights beside the Wanderer against Siphon as
  ally token T-24 (build the token if missing) and can disable one of Siphon's Boss Protocols per turn as written in the Dungeon List; if not
  rescued, she confronts her father after the fight as the sheet says. Siphon/Elowen confrontation dialogue to the reveal standard.
- Replace the Lab's "Rescuer boon" with this real arc (save-safe).

PART 3 - Smaller canon beats
- Isla's homecoming (Brannoch's daughter): a scene when the conditions in the bible are met, with Brannoch; her barks afterwards.
- The royal funeral (after Primm falls, per the bible): a short, sincere scene in the Capital, the King and Queen's portraits used where
  fitting.
- Old Hob as Death (per the bible): build what the bible describes, keeping the tone gentle and funny.
- Update the story bible: move each built item from "[canon, not built]" to built, with where/how it triggers.

PART 4 - Balance
- Level-5 Necrocrat in the Gainlands: the starter deck plays no unit before turn 8 against the roamers (slow curve). Fix the curve (cheaper
  early units in the Necrocrat starter or the L5 reference package, or a small Gainlands roamer tweak for that matchup) so the L5 Necrocrat
  Gainlands win rate is in band (normal battles 80%+) without pushing the other three Paths or the tutorial runs out of band. Two seeds x 25
  games per check.
- The Old Well's Echo: Gourmand wins only 36-44% (target 40-60% for every Path, closer to 50%). Bring Gourmand into band without making the
  others trivial (adjust the rule, the Echo's deck, or a counterplay window), two seeds.
- Sim every new encounter from Parts 1-3 at its intended level for all four Paths (elites 60-75%, bosses 40-60%, normals 80%+, side dungeon
  battles in band); fix outliers. Log everything in balance_log.md and sheet_changes.md.

PART 5 - Verify
- Full GUT, story playthrough bot (extend it through the new beats), quest smoke, dungeons smoke, Old Well smoke, Capital walk smoke, release
  smoke. Commit + push.
- Summary: what was built and where each beat triggers, the balance tables before/after, judgment calls, the art still needed (bestiary
  pictures for the new encounters, etc.). Don't export a build.
