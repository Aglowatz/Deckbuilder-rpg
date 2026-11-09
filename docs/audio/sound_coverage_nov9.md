# Sound coverage of common actions (Overnight Nov 9, Part 2.2)

Every common action checked against the code (who calls `Audio.sfx`) and the bank (`data/audio/sfx_bank.json`, 145 events). Loudness was
re-measured with both tools (`node tools/sfx_mix_report.js`, `node tools/sfx_loudness.js`): 121/145 events sit within 2 dB of their role's
target and nothing is louder than its role by more than 3 dB; the two tools disagree on `ui_back` (+2.9 dB by RMS, -6 LU by loudness), so it was
left alone. Nothing jumps out over the music.

| Action | Sound event | Where | State |
|---|---|---|---|
| Card hover | `card_hover` | battle hand, Deck Station | had |
| Card draw | `card_draw` | battle board | had |
| Card play | `card_play`, `card_play_cheap/heavy`, `spell_cast(_big)`, `summon_<path>` | battle board (`BattleSounds`) | had |
| Attack | `attack_declare`, `attack_lunge` | battle board | had |
| Hit | `hit_light/medium/heavy`, `hit_player` | battle board | had |
| Block | `block` | battle board | had |
| Death | `death_<path>` | battle board | had |
| Buff / debuff | `buff`, `debuff`, `keyword_gain` | battle board | had (+ new glow and pop) |
| Heal | `heal` | battle board, shrines, items | had (+ new green glow) |
| Gold | `coins` | rewards, shops, chests | **filled**: the HUD purse now chinks softly (at most every 0.5 s) and pops whenever gold rises in the world |
| Button | `ui_click` / `ui_hover` | every button (`UiSounds` hook) | had |
| Menu open / close | `ui_open` / `ui_close` | pause menu, town and zone overlays | had; **fixed**: opening an overlay also played the close sound (it "closed" nothing first) |
| Sub-panels (Settings, Glossary, Feats, Credits, save slots) | `ui_open` / `ui_back` | pause menu, title | **filled**: they opened with only the click and closed silently |
| Quest update | `quest_accept`, `quest_complete`, `goal_update` | quest notice layer, markers | had |
| Level up | `level_up_layer` | level-up screen | had |
| Pack open | `pack_tear`, `pack_whoosh`, `pack_flip`, `pack_reveal_*` | packs screen | had |
| Map pin | `ui_select` | full map "where to" ping | had |
| Autosave | (silent by design) | new corner Saving... indicator | new |
| Dex's table miss | `card_discard` | card match screen | **filled** (a pair already had `ui_confirm`) |

Ducking: the music dips 4.5 dB under any open dialogue box (`DialogueBox` -> `Audio.set_dialogue_duck`) and 9 dB (13 for story stings)
under stings (`MusicManager.STING_DUCK_DB`); both ease in and out. Default sliders (dB taper): master 0.95, music 0.90, effects 0.95, UI 0.95,
ambience 0.95, voice 0.95 - music sits about 2 dB under the effects, which is the balance the Oct 26 volume fix measured as even. Unchanged.
