# Dialogue pass Oct 19: opening and Crosspath, editor review

Editor area: `opening_crosspath`. Files: `data/story/intro_story.tres`, plus the player-facing strings in `core/dungeon/trial_of_the_hollow.gd`
and `ui/battle/tutorial_layer.gd`. Writer's report: `docs/design/dialogue_pass/opening_crosspath.md`. Old = `pre-overnight-oct19`, new = the
writer's committed version (93cb6207), final = after this review. Godot was not run. Nothing was committed.

Left alone on purpose: the Secret Dealer (`town.hidden_vendor`), Fig Sly (`pack.black_market.*`, `pack.hint.gilded_*`), and the Old Well (no
Old Well lines live in these files). Labels and mechanics text are not scored as conversations: titles and names, arena tiers, rules and
result toasts, `arena.screen.*`, pack hints and reward toasts, `zone.complete.*`, `town.objective*`, `memory.title_format/.hint`,
`travel.title/.subtitle/.operator.*/.sign.*/.warning/.button`.

Scores are 1-5 for: in character / funny (fit, not volume: sincere beats score 5 for no joke) / story beat landed / brevity / clarity of what to do
next. A conversation's score is the lowest of the five.

## Averages

| | Old | New (writer) | Final |
|---|---|---|---|
| Average minimum (68 conversations) | 3.01 | 3.97 | **4.01** |
| Average of all five scores | 4.05 | 4.51 | **4.53** |
| Conversations under 4 | 49 | 3 | **0** |

I edited 4 conversations: the 3 still under 4 after the writer's pass (the first-duel tip, Sable's pack lines, Tilly's return line), plus one
fix to Maren's `stage.1`, where a line that replays on every visit acted as if she were handing over the recipe for the first time.

## Checks (node script, scratchpad `ed_oc/scan.js`)

- 274 keys, the same as the old file. Every array kept. Every `%s`/`%d`, `[tag]` and `{token}` kept. No unknown tokens.
- No box over 240 characters once the tokens are filled. Only one box is over 200: `zone.complete.necrocrat.body` (222, a toast, not
  touched).
- No banned old name (canon.md list) in any of the three files. No literal Primm, Tessar, Crosspath, Patchwork or Elowen in the text.
  No real brands. No mean-spirited jokes.
- Code strings: the six cave blurbs and the STEPS text only. No ids, numbers or logic changed.

### Opening

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `awakening_lines` | 1 | 4 | **4** | 5 / 4 / 5 / 5 / 4 | Writer rewrite kept as is. Old broke the amnesia and described the old cave wake. |
| `still.wake` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 4 | Writer rewrite kept as is. The question now lives in `prologue.wanderer.1`. |
| `prologue.rescuer.1-4`, `prologue.wanderer.1-3` | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. Medic check, guarded slip ("You always used to..."). |
| `prologue.self_talk` (random pick) | 2 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Writer rewrite kept as is. |
| `start.gate_prompt`, `start.gate_title`, `start.tunnel` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 5 | Writer rewrite kept as is. "older water" seeds the dry spring. |
| Forgotten Cave node blurbs (`trial_of_the_hollow.gd`, 6) | 2 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. "The trial begins." gone (canon: a passage). |
| `tutorial.warden.before/.after` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 4 | Writer rewrite kept as is. Dry spring, "the house", kettle. |
| First-duel tips (`tutorial_layer.gd` STEPS) | 3 | 3 | **4** | 4 / 4 / 5 / 5 / 5 | Infrastructure tip: "Think of it as breakfast." -> "The most important card of the day." (sets up the next tip's "orb on your plate"). |
| `cave_mouth.maren/.wanderer/.maren_end` | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. Kettle (C10), dry spring, distrust of the Rescuer. |

### Maren

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `town.elder.first` | 2 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. Six boxes to four, all facts kept. |
| `town.elder.stage.0` + `.return` (before any zone) | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. Stick carvings (4.1). |
| `town.elder.progress.1` + `.stage.1` | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | stage.1 box 2 replays every visit, so "Here: the pie recipe..." (handed over again each time) -> "My pie recipe is pinned by the door, in my own hand. Round letters, careful loops. Copy it if you like. Smudge it and I will know." Keeps the C14 handwriting set-up. |
| `town.elder.progress.2` + `.stage.2` | 3 | 4 | **4** | 5 / 5 / 5 / 4 / 4 | Writer rewrite kept as is. "That is no prince... a damp young man with good posture." |
| `town.elder.progress.3` + `.stage.3` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. |
| `town.elder.progress.4` + `.stage.4` | 3 | 4 | **4** | 5 / 5 / 4 / 5 / 4 | Writer rewrite kept as is. "up in his castle" points at the Capital. |
| `town.elder.known_early` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 4 | Writer rewrite kept as is. Literal "Primm" -> `{villain}`. |
| `town.elder.postgame` | 2 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. Over-200 box split. |

### Memories

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| Memory 1 (`memory.1.intro/.fragment/.after`, `.announce_*`) | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. Second Path box split; names the Deck Station. |
| Memory 2 (`memory.2.*`) | 2 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. Over-200 box split. |
| Memory 3 (`memory.3.*`) | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. Unnamed Siphon hint ("My best student"). |
| Memory 4 (`memory.4.intro/.fragment/.after/.reply/.after2`) | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. "I knew", the stick ring, `{prince}`/`{royal_house}` tokens; reply still follows "Forgive me". |
| Memory 4, told by Primm first (`memory.4.intro_known/.after_known`) | 2 | 4 | **4** | 5 / 4 / 5 / 4 / 4 | Writer rewrite kept as is. 230-char box split; "I knew" added. |

### Stills

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `still.flex` | 2 | 4 | **4** | 5 / 4 / 5 / 5 / 5 | Writer rewrite kept as is. No longer contradicts the lesson ("They had not taken his muscles"). |
| `still.doppel` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| `still.approval` | 4 | 4 | **4** | 5 / 5 / 4 / 5 / 5 | Unchanged by writer; kept. |
| `still.rotheart` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| `still.primm` | 3 | 5 | **5** | 5 / 5 / 5 / 5 / 5 | Writer rewrite kept as is. Literal "Primm" -> `{villain}`. Sincere beat; no joke is the right fit. |
| `still.reunion` | 4 | 4 | **4** | 5 / 4 / 5 / 5 / 5 | Unchanged by writer; kept. |

### Brannoch

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `town.guard.capital_offer` | 2 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. Over-200 boxes split. |
| `town.guard.capital_active` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Writer rewrite kept as is. |
| `town.guard.capital_done` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 5 | Writer rewrite kept as is. Isla interim (C16). |
| `town.guard` | 3 | 4 | **4** | 5 / 4 / 5 / 5 / 4 | Writer rewrite kept as is. Notebook, Isla. |

### Vendors

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| Sable `town.vendor.first` | 3 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. "The past. Next question." |
| Sable `town.vendor.return` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. |
| Sable packs `pack.card_vendor.line/.tier2` | 3 | 3 | **4** | 5 / 4 / 4 / 5 / 4 | Sable sounded like a plain clerk. Now "Surprise packs, darling... I never ask a crate where it has been." / "What's inside? Even the crate won't say. I respect that in a crate." and tier 2 "Do faint at the good ones. Quietly." Quote marks and box count kept. |
| Tilly `town.item_vendor.first` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Writer rewrite kept as is. Skin colour tic. |
| Tilly `town.item_vendor.return` | 3 | 3 | **4** | 5 / 4 / 4 / 5 / 5 | "Potions! Charms! One good tonic if you're feeling reckless!..." -> "Back! Potions! Charms! I'm a bit orange today, so maybe not the orange one! Equip them on your Character screen..." (her tic; instruction kept). |
| Bertram `town.equipment_vendor.too_early` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| Bertram `equipment_vendor_intro_lines` | 2 | 4 | **4** | 5 / 4 / 4 / 4 / 4 | Writer rewrite kept as is. Seven boxes to four. |
| Bertram `equipment_vendor_return_lines` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. "Fact:" bear line. |
| Armory quest `quest.armory.start/.waiting` | 4 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Unchanged by writer; kept. |
| Armory quest `quest.armory.done` | 3 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. Over-200 box split. |
| Fenwick `town.pack_vendor.first` | 2 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. Six boxes to four. |
| Fenwick `town.pack_vendor.return` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. Four boxes (all played every visit) to two. |
| Fenwick shop (`pack.vendor.*`, `.prismatic_reveal`) | 4 | 4 | **4** | 4 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| Pip `town.tailor.first` | 2 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. "goblin" gone; six boxes to four. |
| Pip `town.tailor.return` | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. Four boxes to two. |
| Pip shop (`town.tailor.line/.progress/.secrets`, `tailor.*`) | 3 | 4 | **4** | 4 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. `tailor.poor` lost Sable's "darling". |

### Gatekeepers

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| Brick Bronson (beefcake intro/victory/defeat, `gate.beefcake.*`) | 3 | 4 | **4** | 5 / 5 / 5 / 4 / 4 | Writer rewrite kept as is. Victory is true after Flex is freed; C24 rumour. |
| Chef Gravois (gourmand arrays, `gate.gourmand.*`) | 3 | 4 | **4** | 5 / 4 / 4 / 4 / 4 | Writer rewrite kept as is. "Please, save us" gone (replays after the zone is free). |
| Prudence Pallor (necrocrat arrays, `gate.necrocrat.*`) | 4 | 4 | **4** | 5 / 5 / 4 / 5 / 5 | Writer rewrite kept as is. |
| Moss Mulligan (refusemancer arrays, `gate.refusemancer.*`) | 3 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. "Please free her" gone. |
| The Restless Cairn (`graveyard_*_lines`) | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Unchanged by writer; kept. |

### Undercroft

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `town.arena.locked/.announce/.unlock_line` | 4 | 4 | **4** | 4 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| `town.arena.intro` | 2 | 4 | **4** | 5 / 4 / 4 / 4 / 5 | Writer rewrite kept as is. Caps voice; over-200 box split. |
| `town.arena.return` | 3 | 4 | **4** | 5 / 5 / 4 / 5 / 4 | Writer rewrite kept as is. "THE CROWD IS... mostly me". |
| Arena bout blurbs (`arena.*.blurb`) | 2 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Writer rewrite kept as is. Bellows is "he". |

### Alchemist

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `town.alchemist.locked` | 1 | 4 | **4** | 5 / 5 / 4 / 5 / 5 | Writer rewrite kept as is. Banned "Z.V." -> "- A."; `{villain}`; "TWO ZONES". |
| `town.alchemist.intro` | 3 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Writer rewrite kept as is. The one Wellspring legend line (4.2). |
| `town.alchemist.return/.need_more/.announce/.unlock_line` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Writer rewrite kept as is. The red flask. |

### Rip

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `travel.intro.town` | 2 | 4 | **4** | 5 / 5 / 4 / 4 / 5 | Writer rewrite kept as is. Seven boxes to five; HNNNGH. |
| `travel.intro.zone` + `.return.zone` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Writer rewrite kept as is. |
| `travel.return.town` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Unchanged by writer; kept. |
| `travel.intro.final` (Cousin #7) | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 4 | Unchanged by writer; kept. |
| Forest station (`travel.intro.forest/.return.forest/.forest_tip`) | 4 | 4 | **4** | 5 / 4 / 5 / 4 / 5 | Unchanged by writer; kept. |
| Rips, arrivals and unlock toasts (`travel.rip.*`, `.arrive.*`, `.unlock.*`) | 4 | 4 | **4** | 5 / 5 / 4 / 5 / 5 | Writer rewrite kept as is. `travel.unlock.forest` uses `{town}`, `travel.station.final.name` uses `{capital}`. |

### Other

| Conversation | Old min | New min | Final min | Final (char / funny / beat / brev / clear) | Change |
|---|---|---|---|---|---|
| `capital.castle.warning` | 4 | 4 | **4** | 5 / 4 / 4 / 5 / 5 | Unchanged by writer; kept. |
| `postgame.rescuer.freed/.cleared` | 4 | 4 | **4** | 4 / 4 / 5 / 4 / 4 | Unchanged by writer; kept. |

## Needs code or a decision from the user

1. `world/town_scene.gd` is outside this area. `BAKER_LINES[2]` still says "the bridge to the Capital" (the road has an arch), and the arena
   prompt "Enter the Grand Clashatorium" is a banned name.
2. The gatekeepers have no real freed-zone variants (`town_scene.gd` around line 1269). Their victory arrays now read true both before and
   after a zone is freed, but real variants need code.
3. `town_scene.gd` `_talk_equipment_vendor`: `lines.append_array` can append to the shared exported `equipment_vendor_intro_lines` on the
   first visit before level 5. This is a code bug that the writer reported.
4. The crest has no place at the Crosspath fountain yet: the fountain needs an "E to read" text (code/data).
5. `town.tailor.title` is "Thimble's Hats & Hems", but the tailor is Pip Threadwell. "Thimble" is not banned. Is it the shop's name, or a
   leftover? This needs a decision from the user, so I did not change it.
6. `town.alchemist.locked` is an all-caps note, but `{villain}` renders as "Primm", so the note reads "Primm TOOK MY CAULDRON". An
   upper-case token would need code. I think it is fine as it is.
7. `town.guard` only plays after "Free the Four Zones" is handed in, so in practice it is postgame-only. Isla's homecoming (C16) needs
   code.
8. Maren's lines before the first zone (`stage.0` + `return`) are 4 boxes that replay on every visit. They are short, but a "one random line
   per return visit" option would need code.

## Five best, before -> after (final text)

1. `awakening_lines`
   - Before: "Where am I?" / "What happened?" / "My head... I remember a kingdom. Four Paths." / "A great, bright city where they all met.
     And then... nothing." / "...There. Light, through the rocks. That must be the way out."
   - After: "...Cold. Leaves in my mouth. Great start." / "I reach for my name and there's nothing there. Not even the shape of one." /
     "No name. Two hands. One of them is shaking. I'll start with the other one." / "...And I'm not alone."
2. `cave_mouth.maren` boxes 1-3
   - Before: "So. You're the one they sent through the old tunnel." / "I was told someone would come out of there. Not who. Not what you
     would look like." / "You look like you haven't slept in years."
   - After: "So. You're the one they sent through the old tunnel. Kettle's been on since noon." / "I was told someone would come out of
     there, past the dry spring and that grumpy Warden. Not who. Certainly not this damp." / "Don't mistake this for trust, dearie. You
     could be anyone's spy. And whoever pushed you into that tunnel is reckless, and I don't like reckless."
3. `town.elder.stage.2`
   - Before: "The resistance has ears in every Path. If you meet Wren, tell her my pie is still the best thing in the kingdom."
   - After: "Somebody in the square says you have a look of the old court about you. That is no prince, I told them. That is a damp young
     man with good posture." / "And if you meet Wren in the Capital, tell her my pie is still the best thing in the kingdom. She'll argue.
     She'll be wrong."
4. `memory.4.after` (boxes 3-4)
   - Before: (nothing between the court memory and) "And my lab, ten years of my life's work, was used on that boy. Forgive me, if you
     ever can."
   - After: "And I knew. The Warden opens that tunnel for one family only. I knew the moment you walked out of it, and I was too frightened
     to say so." / "Four signs in a ring. The same as on my stick. I have carried it for ten years and told nobody why."
5. `pack.card_vendor.line` (my edit)
   - Before: "Sable pats a stack of wrapped bundles. "Surprise packs. Fresh from the crates." / "I do not know what is inside. Neither does
     the crate.""
   - After: "Sable pats a stack of wrapped bundles. "Surprise packs, darling. Fresh from the crates, and I never ask a crate where it has
     been." / "What's inside? Even the crate won't say. I respect that in a crate.""

My other edits: the tutorial tip "One per turn. Think of it as breakfast." -> "One per turn. The most important card of the day."; Tilly's return
line "Back! Potions! Charms! I'm a bit orange today, so maybe not the orange one! Equip them on your Character screen to carry them into a
fight!"; Maren's `stage.1` "My pie recipe is pinned by the door, in my own hand. Round letters, careful loops. Copy it if you like. Smudge it
and I will know." (the C14 set-up still pays off with `dungeon.pc_ward.before`); Sable's tier 2 line "...Do faint at the good ones.
Quietly."
