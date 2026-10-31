# Sound-effect loudness by category (Overnight Oct 30-31, Part 8)

Measured offline by `node tools/sfx_loudness.js` (ffmpeg ebur128): each event's loudest momentary loudness (M, LUFS, 400 ms window) as the game
plays it at rest (its loudest layer, every variant averaged, plus the layer gain and the event level; before the bus sliders). The target of a
category is its own median; events more than 5 LU away from it are pulled toward it (at most 4 dB per run).

| Category | Events | Median LUFS | p10 | p90 | Spread p10-p90 | Outliers moved |
|---|---:|---:|---:|---:|---:|---|
| Battle | 49 | -26.3 | -29.5 | -22.2 | 7.3 | - |
| Dialogue voice | 2 | -35.9 | -36.1 | -35.6 | 0.5 | - |
| Footsteps | 15 | -30.0 | -31.3 | -28.1 | 3.2 | - |
| Previews | 2 | -32.3 | -34.3 | -30.3 | 4.0 | - |
| Resources | 13 | -25.6 | -29.7 | -21.8 | 7.9 | - |
| UI | 37 | -28.7 | -32.5 | -24.9 | 7.6 | - |
| World | 27 | -22.9 | -27.1 | -19.5 | 7.6 | - |

## Every event

| Event | Category | LUFS (M max) | Level dB | New level |
|---|---|---:|---:|---:|
| summon_necrocrat | Battle | -21.6 | 4 |  |
| hit_heavy | Battle | -22.1 | -2 |  |
| hit_medium | Battle | -22.1 | 2 |  |
| spell_cast | Battle | -22.1 | 0.5 |  |
| spell_cast_big | Battle | -22.1 | -0.5 |  |
| death_neutral | Battle | -22.2 | -1 |  |
| death_beefcake | Battle | -22.2 | -1 |  |
| death_necrocrat | Battle | -22.2 | -1 |  |
| death_gourmand | Battle | -22.2 | -1 |  |
| death_refusemancer | Battle | -22.2 | -1 |  |
| trap_spring | Battle | -22.3 | -3.5 |  |
| summon_gourmand | Battle | -22.5 | 0.5 |  |
| block | Battle | -23.7 | 0 |  |
| wonder_play | Battle | -23.9 | -1.5 |  |
| card_shred | Battle | -24.2 | -1 |  |
| trap_set | Battle | -24.8 | 0 |  |
| card_play_heavy | Battle | -25.0 | 0 |  |
| card_shuffle | Battle | -25.0 | -1 |  |
| attack_declare | Battle | -25.1 | 8.5 |  |
| hit_player | Battle | -25.5 | -0.5 |  |
| battle_start | Battle | -25.5 | 1 |  |
| card_pickup | Battle | -25.6 | 2 |  |
| defeat_layer | Battle | -26.0 | -7 |  |
| summon_refusemancer | Battle | -26.0 | 0 |  |
| tool_attach | Battle | -26.3 | -1 |  |
| heal | Battle | -26.4 | 2 |  |
| victory_layer | Battle | -26.5 | 3 |  |
| coin_flip | Battle | -26.6 | 6 |  |
| turn_start | Battle | -26.8 | -2 |  |
| attack_lunge | Battle | -26.8 | 2 |  |
| hit_light | Battle | -26.9 | -0.5 |  |
| turn_start_enemy | Battle | -27.3 | 7.5 |  |
| summon_neutral | Battle | -27.5 | 2 |  |
| hit_metal | Battle | -27.6 | -3.5 |  |
| buff | Battle | -27.9 | 0.5 |  |
| card_discard | Battle | -27.9 | 2 |  |
| card_play_cheap | Battle | -28.0 | 1 |  |
| token_create | Battle | -28.0 | 4 |  |
| card_play | Battle | -28.5 | -0.5 |  |
| debuff | Battle | -28.9 | -0.5 |  |
| summon_beefcake | Battle | -29.0 | -3 |  |
| turn_start_player | Battle | -29.3 | 3.5 |  |
| turn_end | Battle | -29.3 | -3 |  |
| land_play | Battle | -29.5 | 0 |  |
| low_hp | Battle | -30.1 | -2 |  |
| card_return | Battle | -30.3 | 2.5 |  |
| energy_tick | Battle | -30.4 | 8 |  |
| card_draw | Battle | -30.8 | 2 |  |
| card_hover | Battle | -37.0 | -2 |  |
| dialogue_airy | Dialogue voice | -35.6 | -1 |  |
| dialogue | Dialogue voice | -36.1 | -1 |  |
| step_mashed | Footsteps | -26.3 | 0 |  |
| step_dirt | Footsteps | -28.1 | 0 |  |
| footstep | Footsteps | -28.1 | 0 |  |
| step_junk | Footsteps | -29.3 | 0 |  |
| step_gravel | Footsteps | -29.3 | 0 |  |
| step_pastel | Footsteps | -29.5 | 0.5 |  |
| step_tile | Footsteps | -30.0 | 0 |  |
| step_metal | Footsteps | -30.0 | 0 |  |
| step_grass | Footsteps | -30.5 | 0 |  |
| step_stone | Footsteps | -30.6 | 0 |  |
| step_ash | Footsteps | -30.8 | 0 |  |
| step_carpet | Footsteps | -30.9 | 0 |  |
| step_cobble | Footsteps | -30.9 | 0 |  |
| step_marble | Footsteps | -31.3 | 0 |  |
| step_wood | Footsteps | -31.5 | 0 |  |
| preview_lethal | Previews | -30.3 | -4 |  |
| preview_tick | Previews | -34.3 | 4 |  |
| ingredient_gain | Resources | -20.6 | -1 |  |
| contract_gain | Resources | -21.8 | 3 |  |
| ingredient_spend | Resources | -23.6 | 2 |  |
| contract_spend | Resources | -24.8 | 4 |  |
| garbage_gain | Resources | -24.8 | -1.5 |  |
| keyword_gain | Resources | -25.4 | 7 |  |
| resource_gain | Resources | -25.6 | 7 |  |
| redtape_spend | Resources | -25.7 | 2 |  |
| redtape_gain | Resources | -26.1 | -1 |  |
| energy_gain | Resources | -26.4 | 2 |  |
| iron_gain | Resources | -26.7 | -1 |  |
| iron_spend | Resources | -29.7 | 2 |  |
| garbage_spend | Resources | -29.8 | 4 |  |
| tool_unequip | UI | -23.8 | 3.5 |  |
| level_up_layer | UI | -24.5 | 3 |  |
| arena_cheer | UI | -24.6 | 1 |  |
| craft_brew | UI | -24.9 | 1.5 |  |
| pack_reveal_uncommon | UI | -24.9 | 3.5 |  |
| pack_reveal_rare | UI | -24.9 | 3.5 |  |
| ding | UI | -24.9 | 3.5 |  |
| deck_sort | UI | -25.0 | 3 |  |
| pack_tear | UI | -25.6 | 0 |  |
| game_save | UI | -25.8 | 3 |  |
| tool_equip | UI | -25.8 | -0.5 |  |
| pack_reveal_legend | UI | -25.9 | -3.5 |  |
| coins | UI | -26.1 | 2.5 |  |
| quest_complete | UI | -26.9 | 1.5 |  |
| pack_whoosh | UI | -27.3 | 3.5 |  |
| quest_accept | UI | -27.8 | 3 |  |
| deck_remove | UI | -27.9 | 4 |  |
| pack_flip | UI | -28.0 | 0 |  |
| shop_buy | UI | -28.7 | -0.5 |  |
| refuse_open | UI | -28.9 | 1 |  |
| book | UI | -29.0 | -1 |  |
| ui_tab | UI | -29.0 | 1 |  |
| ui_toggle | UI | -29.4 | -1 |  |
| notify | UI | -29.8 | 6.5 |  |
| deck_add | UI | -30.0 | 0 |  |
| game_load | UI | -30.0 | 2 |  |
| ui_select | UI | -31.0 | 0 |  |
| ui_error | UI | -31.5 | 0 |  |
| ui_open | UI | -31.8 | 1 |  |
| ui_click | UI | -32.0 | -1 |  |
| ui_confirm | UI | -32.0 | -1 |  |
| ui_tick | UI | -32.3 | 4 |  |
| ui_close | UI | -32.5 | 1 |  |
| goal_update | UI | -32.8 | 3.5 |  |
| ui_back | UI | -32.8 | 1.5 |  |
| ui_slider | UI | -33.3 | 7 |  |
| ui_hover | UI | -37.3 | -2 |  |
| chest_giant | World | -18.8 | -1.5 |  |
| gate_big | World | -18.9 | -4.5 |  |
| portal_enter | World | -19.4 | -2 |  |
| vault_grind | World | -19.5 | -1 |  |
| death | World | -20.2 | 1 |  |
| spell | World | -20.6 | 2 |  |
| thrower_launch | World | -20.9 | 4.5 |  |
| boing | World | -21.3 | 1 |  |
| rift_open | World | -21.8 | 1 |  |
| rift_seal | World | -22.0 | -3 |  |
| lever_clunk | World | -22.1 | 1 |  |
| dungeon_enter | World | -22.5 | -1 |  |
| gate_cross | World | -22.8 | 1 |  |
| splash | World | -22.9 | 1.5 |  |
| door_close | World | -23.2 | 1.5 |  |
| pickup | World | -23.4 | 5 |  |
| chest_iron | World | -24.7 | 1 |  |
| enemy_alert | World | -24.8 | 1.5 |  |
| chest_open | World | -25.0 | -0.5 |  |
| door | World | -25.1 | 1 |  |
| zone_transition | World | -25.4 | -8 |  |
| thrower_land | World | -26.5 | -1.5 |  |
| attack | World | -26.8 | 2 |  |
| hero_hurt | World | -27.1 | -1 |  |
| smoke_bomb | World | -27.8 | 1 |  |
| sign_read | World | -28.0 | 4 |  |
| sprint_start | World | -36.8 | -2 |  |
