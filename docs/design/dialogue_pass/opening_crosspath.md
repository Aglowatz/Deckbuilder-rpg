# Dialogue pass Oct 19: opening and Crosspath

Writer area: `opening_crosspath`. I changed text only. Every key, array, `[tag]`, `%s`/`%d` and `{token}` is kept. Godot was not run. A
node check (in the scratchpad) confirmed that `intro_story.tres` still has the same 256 `texts` keys and every array, that the file
parses, that no box goes over 240 characters after the tokens are filled, and that no banned name or literal Primm/Tessar/Crosspath
is left in the lines I touched.

## Files and key groups rewritten

| File | Group | Keys changed |
|---|---|---|
| `data/story/intro_story.tres` | `awakening_lines` | 1 array (5 lines down to 4) |
| | stills: `still.wake`, `still.flex`, `still.primm` | 3 |
| | prologue: `start.gate_prompt`, `prologue.rescuer.1-4`, `prologue.wanderer.1/.3`, `prologue.self_talk` | 8 |
| | the Warden: `tutorial.warden.before/.after` | 2 |
| | the cave arrival: `cave_mouth.maren/.wanderer/.maren_end` | 3 |
| | Maren: `town.elder.first/.return/.progress.1-4/.stage.0-4/.known_early/.postgame` | 13 |
| | memories: `memory.1.after`, `memory.2.after`, `memory.3.after`, `memory.4.fragment/.after/.intro_known/.after_known` | 7 |
| | Brannoch: `town.guard`, `.capital_offer/.capital_active/.capital_done` | 4 |
| | vendors: Sable `town.vendor.first/.return`; Tilly `town.item_vendor.first`; Bertram `equipment_vendor_intro/_return_lines`, `quest.armory.done`; Fenwick `town.pack_vendor.first/.return`; Pip `town.tailor.first/.return`, `tailor.poor` | 11 |
| | gatekeepers: the four `*_npc_victory_lines` arrays | 4 |
| | Undercroft: `town.arena.intro/.return`, `arena.arena_marshal.blurb` | 3 |
| | Alchemist: `town.alchemist.locked/.intro/.return` | 3 |
| | Rip: `travel.intro.town`, `travel.intro.zone`, `travel.station.final.name`, `travel.unlock.forest` | 4 |
| `ui/battle/tutorial_layer.gd` | one string in `STEPS` (the infrastructure tip) | 1 |
| `core/dungeon/trial_of_the_hollow.gd` | the six Forgotten Cave node blurbs | 6 |

Total: 66 keys/arrays (about 175 lines) in the story file, plus 7 code strings.

I reviewed these and left them alone: `still.doppel/.approval/.rotheart/.reunion`, `memory.*.intro`, `memory.1-3.fragment`, `memory.4.reply/.after2`,
`gate.*`, the corrupted intro and defeat arrays, the graveyard arrays, `zone.complete.*`, `town.objective*`, `pack.*`, the arena tiers
and rules, `travel.*` shouts, arrivals and the forest tip, and `postgame.rescuer.*`. They already work, or they are mechanics text.
I also left the Path choice screen (`element_choice_screen.gd` / `element_choice.gd`) alone. Its intro line is already good, and
`tools/playtest_smoke.gd` checks for the words "resonates the strongest within you". The Path descriptions are mechanics text.
The other tutorial tips already sound right and are exact, so I did not change them.

## Notable fixes

- **The first words of the game** (`awakening_lines`) no longer describe the old cave wake ("Light, through the rocks"). They no longer
  remember "a kingdom. Four Paths" or "a great, bright city" either, which broke the amnesia. Now: cold, leaves, no name, "I'll start with
  the other one", "...And I'm not alone." This leads straight into the Rescuer.
- `still.wake` no longer ends on "...Who are you?". The Wanderer now asks that himself in `prologue.wanderer.1`, so the question is
  asked once and `prologue.rescuer.2` ("A friend...") answers it.
- `prologue.rescuer.1`: the "sack of feathers" cliche is gone. She now checks him like a medic (pulse, cold hands, his weight).
- **Banned name**: the Alchemist's note is now signed "- A." (Auntie Alembic). "THE USURPER" is now `{villain}`. "TWO PATHS" is now
  "TWO ZONES", to match the toast.
- **Pronoun**: `arena.arena_marshal.blurb`: Bellows is "he".
- **Tokens**: `still.primm`, `memory.4.intro_known` and `town.elder.known_early` now use `{villain}` instead of "Primm".
  `memory.4.fragment` and `memory.4.after` use `{prince}` / `{royal_house}` instead of "Tessar" / "Wayweaver". `travel.station.final.name`
  uses `{capital}`, and `travel.unlock.forest` uses `{town}`.
- **Lesson contradiction**: `still.flex` no longer says "They had not taken his muscles". It is now about him being thin and breathing
  slowly.
- **The exposition wall**: `town.elder.first` went from six boxes to four. It keeps the four Paths and their services, `{villain}` and his
  rulers, the four gatekeeper obstacles, and Sable plus the Deck Station. The test needs "Primm" and "Patchwork"; both still appear
  through the tokens.
- **Gatekeeper arrays that replay after a zone is freed**: the four victory arrays are now past tense or timeless. Brick says Clench
  "locked" Flex (no more "runs the Gainlands now"). Moss says the Rot "took" Compostella first. "Please, save us" and "Please free her"
  are gone.
- **Lines over 200 characters** are now split into separate boxes: `memory.1.after` box 3, `memory.2.after` box 2, `memory.3.after` box 2,
  `memory.4.after_known`, `town.guard.capital_offer` boxes 2-3, `town.arena.intro` box 3, `quest.armory.done` box 3,
  `town.elder.postgame` box 1, `town.alchemist.intro` box 2.
- **Return lines that played every box on every visit** are shorter. Fenwick's return went from 4 boxes to 2, Pip's from 4 to 2,
  Bertram's from 3 to 2, and his intro from 7 to 4. The code plays these whole arrays, not one picked line.
- Voices made distinct: Sable no longer gives a plain shop greeting (now "The past. Next question."). Tilly's skin changes colour.
  Bertram gets a "Fact:" about bears. Pip lost "goblin" (no goblins in Patchwork) and Sable's "darling". Rip gets his "HNNNGH". Bellows
  now shouts in capitals and then adds a small aside.
- The cave node "The trial begins." is gone. Canon calls the cave a passage, not a trial.
- Tutorial: "Like coffee, but legal" is now "Think of it as breakfast". The mechanics text is unchanged.

## Callbacks planted (A -> B)

- **C10 kettle**: `tutorial.warden.after` "Someone is waiting at the far end with a kettle on." -> `cave_mouth.maren` "Kettle's been on
  since noon."
- **Dry spring / Wellspring (4.2)**: `start.gate_prompt` "older water" -> cave blurb `The Hollow Well` "a spring that ran dry long ago"
  -> `tutorial.warden.after` "The spring at the end ran once. You would not remember." -> `cave_mouth.maren` "past the dry spring and
  that grumpy Warden" -> `town.alchemist.intro` "one spring once, the Wellspring, that fed all four Paths". These are told as legend
  only. No line says where it is, why it dried, or that the Old Well drew from it.
- **4.1 crest on the stick**: `town.elder.stage.0` "stop staring at my stick. Four little carvings in a ring" -> `memory.4.fragment`
  "the crest on every door: four signs in a ring" -> `memory.4.after` "The same as on my stick."
- **C14 handwriting**: `town.elder.stage.1` "the pie recipe, written out in my own hand. Round letters, careful loops." -> capital
  `dungeon.pc_ward.before` "You have seen that handwriting on a pie recipe."
- **4.3 "That's no prince"**: `cave_mouth.maren` "Certainly not this damp." -> `town.elder.stage.2` "That is no prince... That is a damp
  young man with good posture."
- **4.3 "I knew"**: `tutorial.warden.*` (it opens only for him) -> `memory.4.after` / `memory.4.after_known` "The Warden opens that
  tunnel for one family only. I knew..." The reply "There is nothing to forgive..." still follows "Forgive me".
- **4.3 Siphon hint (unnamed)**: `memory.3.after` "My best student kept the lab running for him." -> dungeon_content
  `dungeon.dg_lab_boss.after` "Maren said so".
- **4.3 Maren distrusts the Rescuer (unnamed)**: `cave_mouth.maren` "whoever pushed you into that tunnel is reckless, and I don't like
  reckless."
- **4.5 the Rescuer knew him**: `prologue.rescuer.2` "You always used to... Never mind. Your hand." -> dungeon_content
  `dungeon.dg_lab_rescue.before`.
- **C16 Isla interim**: `town.guard` (postgame) and `town.guard.capital_done` "I'm still watching the road."
- **C24 Flex**: `beefcake_npc_victory_lines` "People whispered the old man never broke." -> Flex freed.

## Could not do (needs code, or is outside my files)

- `world/town_scene.gd` is not mine: `BAKER_LINES[2]` ("the bridge to the Capital") and the arena prompt "Enter the Grand Clashatorium"
  (a banned name) are still there.
- Real freed-zone variants for the gatekeepers (`town_scene.gd:1269`). I made the existing arrays timeless instead.
- `town.guard` only plays when no offer is waiting and Free the Four Zones is not active, which in practice means the postgame. I wrote
  it so it also reads well on an early visit ("You came back").
- The Crosspath fountain has no "E to read" text, so the crest cannot be placed there yet.
- In `town_scene.gd` `_talk_equipment_vendor`, `lines.append_array` can append to the shared exported array
  (`equipment_vendor_intro_lines`) on the first visit before level 5. That is a code bug, so I did not touch it.

## Ten best before -> after

1. `awakening_lines`
   - Before: "Where am I?" / "What happened?" / "My head... I remember a kingdom. Four Paths." / "A great, bright city where they all met.
     And then... nothing." / "...There. Light, through the rocks. That must be the way out."
   - After: "...Cold. Leaves in my mouth. Great start." / "I reach for my name and there's nothing there. Not even the shape of one." /
     "No name. Two hands. One of them is shaking. I'll start with the other one." / "...And I'm not alone."
2. `prologue.rescuer.1` box 2
   - Before: "...You're awake. Good. You're also cold, and lighter than a sack of feathers. How long has it been since you ate?"
   - After: "...You're awake. Good. Pulse too fast, hands like ice, and you weigh less than you should. How long since you ate?"
3. `prologue.rescuer.2` box 2
   - Before: "Can you still fight? Can you still pull energy from the Paths? Hold out your hand."
   - After: "Can you still fight? Can you still pull from the Paths? Hold out your hand. You always used to... Never mind. Your hand."
4. `tutorial.warden.after`
   - Before: "...Yes. You may pass. I had my doubts, but the old walls do not lie." / "Go on, then. There is daylight at the end. Someone
     is waiting there with a kettle on."
   - After: "...Yes. The old walls do not lie. The spring at the end ran once. You would not remember." / "Go. The house is yours to
     leave. Someone is waiting at the far end with a kettle on."
5. `cave_mouth.maren` boxes 1-3
   - Before: "So. You're the one they sent through the old tunnel." / "I was told someone would come out of there. Not who. Not what you
     would look like." / "You look like you haven't slept in years."
   - After: "So. You're the one they sent through the old tunnel. Kettle's been on since noon." / "I was told someone would come out of
     there, past the dry spring and that grumpy Warden. Not who. Certainly not this damp." / "Don't mistake this for trust, dearie. You
     could be anyone's spy. And whoever pushed you into that tunnel is reckless, and I don't like reckless."
6. `town.elder.first` (6 boxes -> 4)
   - Before: "...Ten years ago the Kingdom of {kingdom} was whole. Beefcakes made the energy, Gourmands fed us, Necrocrats minded the dead
     and their paperwork, Refusemancers hauled the waste and tended the farms." / "Then {villain} came and took them..." / "Every road
     out of town has a gatekeeper on it..." / "Free the zones. Free the kingdom..."
   - After: "Up and walking. Good. I am Elder Maren, dearie, and this is {town}, where the four Paths used to meet, and argue, and borrow
     each other's pans." / "...Then {villain} took the Paths, one by one, and set his rulers over them. Every road out of town has a
     gatekeeper now: a bridge, a barrier, a pantry door, a wall of thorns." / "Beat a gatekeeper and its road opens. Buy cards from Sable,
     fix your deck at the Deck Station, and come back to me for pie. Not answers. Pie."
7. `town.elder.stage.2`
   - Before: "The resistance has ears in every Path. If you meet Wren, tell her my pie is still the best thing in the kingdom."
   - After: "Somebody in the square says you have a look of the old court about you. That is no prince, I told them. That is a damp young
     man with good posture." / "And if you meet Wren in the Capital, tell her my pie is still the best thing in the kingdom. She'll argue.
     She'll be wrong."
8. `memory.4.after` (new boxes 3-4)
   - Before: "Tessar. Tessar Wayweaver. I met a boy once at court..." / "I told him, 'So we are never far from home.'" / "And my lab, ten
     years of my life's work, was used on that boy. Forgive me, if you ever can."
   - After: ...then "And I knew. The Warden opens that tunnel for one family only. I knew the moment you walked out of it, and I was too
     frightened to say so." / "Four signs in a ring. The same as on my stick. I have carried it for ten years and told nobody why." /
     "And my lab, my life's work, was used on that boy. Forgive me, if you ever can."
9. `town.alchemist.locked` box 2
   - Before: "'CLOSED UNTIL TWO PATHS ARE FREE. THE USURPER CONFISCATED MY CAULDRON. I AM STILL BREWING IN THE SINK. - Z.V.'"
   - After: "'CLOSED UNTIL TWO ZONES ARE FREE. {villain} TOOK MY CAULDRON. I AM BREWING IN THE SINK. THE SINK IS COPING. - A.'"
     (box 1 adds: "in what looks like four handwritings at once")
10. `beefcake_npc_victory_lines` box 2
    - Before: "Chancellor Clench runs the Gainlands now. He locked Grandmaster Flex in the House of Gains."
    - After: "Chancellor Clench locked Grandmaster Flex in the House of Gains. People whispered the old man never broke. I didn't
      whisper. I yelled. Sorry again."

Runners-up: `town.elder.stage.4` "{prince}. I keep wanting to curtsy. My knees have voted against it." / `town.guard` "Hm. You came back.
Wrote it in the notebook: 'came back.' Best two words I know." / `still.flex` "Ten years without iron had left him thin. He breathed in,
slow and even, and it was the loudest thing in the room."
