# Lead editorial pass (Oct 31)

Changes the lead made to the chunk agents' suggestions before the merge, and the lead's own rows (`suggestions_09.csv`).

## Changed or dropped

- suggestions_01.csv `scenes/hob_town/steps/2::1`: dropped (it removed Old Hob's canon "Not for a good long while.", a story bible running gag)
- suggestions_01.csv `NPC-BELLOWS.barks::1`: dropped (it replaced the voice bible's own sample bark, the soup, and used "eleven", a story clue, as a throwaway)
- suggestions_03.csv `order.shouts::1`: dropped (it assumes the shout order matches the dish order, which nobody verified)
- suggestions_05.csv `freed_npc.compostella::0`: suggested line edited (keeps her promise "I will help put it right"; the barn gag goes before it)

## Own rows (suggestions_09.csv, 4)

- `prologue.rescuer.4::1` (High, Clarity): the earlier review's farewell line naming Elder Maren ("Elder Maren will be waiting for you. Find
  her first."); no chunk agent picked it up.
- `town.elder.idle.4::1` (Low, Voice): the earlier Oct 28 note (Maren is a tortoise, so "the tortoises use them" reads oddly), refined.
- `scenes/lab_siphon_after/steps/2::1` and `scenes/lab_siphon_after_alone/steps/5::1` (Low, Fix): literal "Crosspath" in a story file ->
  `{town}` (renders the same; found by the chunk 06 agent).

## The six earlier review suggestions

| Earlier suggestion | Where it went |
|---|---|
| `prologue.self_talk::0` (name the cave's direction) | chunk 01, High, refined |
| `prologue.self_talk::1` (the glowing arch) | chunk 01, High, refined |
| `prologue.rescuer.4::1` (name Maren in the farewell) | lead row, High |
| `town.elder.idle.4::1` (Maren the tortoise) | lead row, Low, refined |
| `awakening_lines::*` (cut to about six) | already done: the game has three awakening lines now; nothing to cut |
| defeat panel "why I lost" | not dialogue; the defeat recap shipped in Fresh eyes round 2 (Oct 31) |
