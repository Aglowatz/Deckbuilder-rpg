# On-screen texture sizes (tools/texfit_run.sh, design pixels at 1080p)

| Folder | Textures seen | Native max side | Largest drawn (1080p) | 1440p | Max ratio | Suggested size_limit | Largest case |
|---|---:|---:|---:|---:|---:|---:|---|
| (runtime) | 73 | 1600 | 1920x1080 | 2560 | 16.88 | 1600 | (runtime)@Shade on ending (Ending/@Control@95/StillBackdrop/Shade) |
| assets/art/battleboards | 1 | 1536 | 1920x1080 | 2560 | 1.25 | 1536 | BB-TUT.webp on battle (Battle/Battleboard) |
| assets/art/bestiary | 3 | 512 | 180x180 | 240 | 0.35 | 320 | BST-CAVE-SCAVENGER.webp on battle (Town/@CanvasLayer@802/@Control@803/@Control@1282/@MarginContainer@1286/@VBoxContainer@1285/@VBoxContainer@1294/@HBoxContainer@1345/@PanelContainer@1482/@MarginContainer@1484/@VBoxContainer@1483/@TextureRect@1492) |
| assets/art/cards | 10 | 768 | 232x352 | 469 | 0.46 | 640 | C-04.webp#atlas on battle (Rewards/@CenterContainer@94/@PanelContainer@95/@VBoxContainer@96/@HBoxContainer@103/@Control@177/@Control@176/@TextureRect@179) |
| assets/art/cards_thumb | 24 | 384 | 180x273 | 364 | 0.71 | 384 | B-12.webp#atlas on town_codex (Town/@CanvasLayer@802/@Control@803/RewardPopup/PopupFrame/@CenterContainer@895/@PanelContainer@896/@MarginContainer@898/@VBoxContainer@897/@VBoxContainer@905/PickRow/Pick_0/@Control@916/@TextureRect@922) |
| assets/art/icons | 129 | 256 | 250x250 | 333 | 1.95 | 256 | ICON-UI-COLLECTION_128.webp on town_vendor (Town/@CanvasLayer@802/@Control@803/@Control@882/@MarginContainer@886/@VBoxContainer@885/@VBoxContainer@893/CategoryPicker/@VBoxContainer@926/@HBoxContainer@928/CategoryCards) |
| assets/art/keyart | 3 | 1792 | 2079x1170 | 2772 | 1.24 | 1792 | TITLE-KEYART.webp on title (Title/TitleArt/KeyArt) |
| assets/art/maps | 1 | 1536 | 1920x1280 | 2560 | 1.25 | 1536 | MAP-S-NECRO.webp on dungeon_map (DungeonMap/MapBackdrop) |
| assets/art/portraits | 6 | 768 | 648x972 | 1296 | 1.27 | 768 | V-BEETSWORTH.webp on town_equipment_vendor (Town/@CanvasLayer@802/@Control@803/@Control@882/VendorStage/VendorPortrait) |
| assets/art/ui | 14 | 1536 | 1920x1280 | 2560 | 1.25 | 1536 | UI-BG-DECKBUILDER.webp on town_bestiary (Town/@CanvasLayer@802/@Control@803/@Control@1282/ScreenBackground/@TextureRect@1283) |
| assets/art/vendors | 5 | 1672 | 1920x1081 | 2560 | 1.15 | 1672 | VS-BEETSWORTH.webp on town_equipment_vendor (Town/@CanvasLayer@802/@Control@803/@Control@882/VendorStage/ShopBackground) |
| assets/icons/game-icons/delapouite | 2 | 512 | 72x72 | 96 | 0.14 | 128 | backpack.svg on battle (Battle/@Control@95/@Control@153/@PanelContainer@154/@TextureRect@155) |
| assets/icons/game-icons/lorc | 3 | 512 | 72x72 | 96 | 0.14 | 128 | gem-pendant.svg on town_codex_gear (Town/@CanvasLayer@802/@Control@803/@Control@882/@MarginContainer@886/@VBoxContainer@885/@VBoxContainer@894/@HBoxContainer@946/@ScrollContainer@950/@VBoxContainer@951/GearGrid_Weapon/Gear_earned_blade/GearIcon) |

## Every texture (largest drawn size)

| Texture | Native | Drawn | Ratio | Screens |
|---|---:|---:|---:|---|
| (runtime)@MapEdgeShadow0 | 64x4 | 56x1080 | 16.88 | dungeon_map |
| (runtime)@MapEdgeShadow1 | 64x4 | 56x1080 | 16.88 | dungeon_map |
| (runtime)@Shade | 8x256 | 1920x1080 | 7.50 | ending |
| (runtime)@LightShimmer | 256x256 | 1075x832 | 4.20 | title |
| (runtime)@@TextureRect@108 | 64x64 | 232x148 | 3.63 | rewards |
| (runtime)@@TextureRect@146 | 64x64 | 232x148 | 3.63 | rewards |
| (runtime)@@TextureRect@180 | 64x64 | 232x148 | 3.63 | rewards |
| (runtime)@@TextureRect@923 | 64x64 | 180x115 | 2.81 | town_pick |
| (runtime)@@TextureRect@961 | 64x64 | 180x115 | 2.81 | town_pick |
| (runtime)@@TextureRect@993 | 64x64 | 180x115 | 2.81 | town_pick |
| (runtime)@@TextureRect@208 | 64x64 | 168x107 | 2.63 | battle battle_lights |
| (runtime)@@TextureRect@249 | 64x64 | 168x107 | 2.63 | battle |
| (runtime)@@TextureRect@290 | 64x64 | 168x107 | 2.63 | battle |
| (runtime)@@TextureRect@324 | 64x64 | 168x107 | 2.63 | battle |
| (runtime)@@TextureRect@363 | 64x64 | 168x107 | 2.63 | battle |
| (runtime)@@TextureRect@242 | 64x64 | 168x107 | 2.63 | battle_lights |
| (runtime)@@TextureRect@281 | 64x64 | 168x107 | 2.63 | battle_lights |
| (runtime)@@TextureRect@316 | 64x64 | 168x107 | 2.63 | battle_lights |
| (runtime)@@TextureRect@351 | 64x64 | 168x107 | 2.63 | battle_lights |
| (runtime)@@TextureRect@1061 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@1104 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@1196 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@1749 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2457 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2518 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2555 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2623 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2681 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2734 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2807 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2874 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@2926 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@3044 | 64x64 | 162x104 | 2.54 | town_codex |
| (runtime)@@TextureRect@1186 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1227 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1262 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1394 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1433 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1468 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1509 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1550 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1585 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1673 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1708 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1743 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1896 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1935 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1976 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@2128 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@2162 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@2196 | 64x64 | 160x102 | 2.49 | town_deck |
| (runtime)@@TextureRect@1177 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1218 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1253 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1404 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1443 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1478 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1519 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1560 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1595 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1683 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1718 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1753 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1906 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1945 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@1986 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@2140 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@2174 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@2208 | 64x64 | 160x102 | 2.49 | town_deck_slots |
| (runtime)@@TextureRect@86 | 512x4 | 820x1080 | 2.11 | title |
| (runtime)@@TextureRect@937 | 64x64 | 133x85 | 2.08 | town_reward_pack |
| (runtime)@WorldCoverStill | 1600x900 | 1920x1080 | 1.20 | town_bestiary town_bestiary_boss town_character town_character_gear town_codex town_codex_gear town_deck town_deck_slots town_equipment_vendor town_item_vendor town_pack_vendor town_tailor town_vendor town_wardrobe |
| (runtime)@TrayArt | 280x79 | 280x79 | 1.00 | battle battle_lights |
| assets/art/battleboards/BB-TUT.webp | 1536x864 | 1920x1080 | 1.25 | battle battle_lights rewards |
| assets/art/bestiary/BST-CAVE-SCAVENGER.webp | 512x512 | 180x180 | 0.35 | battle battle_lights town_bestiary |
| assets/art/bestiary/BST-CHANCELLOR-CLENCH-IRON-REGENT.webp | 512x512 | 180x180 | 0.35 | town_bestiary_boss |
| assets/art/bestiary/BST-TIDY-BOT.webp | 512x512 | 84x84 | 0.16 | town_bestiary town_bestiary_boss |
| assets/art/cards/C-04.webp#atlas | 506x768 | 232x352 | 0.46 | battle rewards |
| assets/art/cards/B-08.webp#atlas | 506x768 | 232x352 | 0.46 | rewards |
| assets/art/cards/R-34.webp#atlas | 506x768 | 232x352 | 0.46 | rewards |
| assets/art/cards/C-06.webp#atlas | 506x768 | 168x255 | 0.33 | battle |
| assets/art/cards/BAS-B.webp#atlas | 506x768 | 168x255 | 0.33 | battle battle_lights |
| assets/art/cards/C-02.webp#atlas | 506x768 | 168x255 | 0.33 | battle |
| assets/art/cards/B-09.webp#atlas | 506x768 | 168x255 | 0.33 | battle battle_lights |
| assets/art/cards/C-11.webp#atlas | 506x768 | 168x255 | 0.33 | battle_lights |
| assets/art/cards/B-03.webp#atlas | 506x768 | 168x255 | 0.33 | battle_lights |
| assets/art/cards/C-08.webp#atlas | 506x768 | 168x255 | 0.33 | battle_lights |
| assets/art/cards_thumb/B-12.webp#atlas | 253x384 | 180x273 | 0.71 | town_codex town_deck town_deck_slots town_pick |
| assets/art/cards_thumb/B-14.webp#atlas | 253x384 | 180x273 | 0.71 | town_pick |
| assets/art/cards_thumb/B-15.webp#atlas | 253x384 | 180x273 | 0.71 | town_pick |
| assets/art/cards_thumb/C-04.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-03.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-05.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-16.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-35.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-11.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-02.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-21.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-09.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-13.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-06.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/C-08.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/B-24.webp#atlas | 253x384 | 162x246 | 0.64 | town_codex town_deck town_deck_slots |
| assets/art/cards_thumb/N-23.webp#atlas | 256x248 | 163x158 | 0.64 | town_deck_slots |
| assets/art/cards_thumb/G-23.webp#atlas | 256x248 | 163x158 | 0.64 | town_deck_slots |
| assets/art/cards_thumb/BAS-B.webp#atlas | 253x384 | 160x242 | 0.63 | town_deck town_deck_slots |
| assets/art/cards_thumb/BAS-G.webp#atlas | 253x384 | 160x242 | 0.63 | town_deck town_deck_slots |
| assets/art/cards_thumb/BAS-R.webp#atlas | 253x384 | 160x242 | 0.63 | town_deck town_deck_slots |
| assets/art/cards_thumb/BAS-N.webp#atlas | 253x384 | 160x242 | 0.63 | town_deck town_deck_slots |
| assets/art/cards_thumb/R-22.webp#atlas | 256x264 | 153x158 | 0.60 | town_deck_slots |
| assets/art/cards_thumb/B-01.webp#atlas | 253x384 | 133x202 | 0.53 | town_reward_pack |
| assets/art/icons/ICON-UI-COLLECTION_128.webp | 128x128 | 250x250 | 1.95 | town_vendor |
| assets/art/icons/ICON-UI-PACKS_128.webp | 128x128 | 250x250 | 1.95 | town_vendor |
| assets/art/icons/ICON-TYPE-UNIT_24.webp | 24x24 | 24x24 | 1.00 | battle battle_lights rewards town_codex town_deck town_deck_slots town_pick town_reward_pack |
| assets/art/icons/ICON-TYPE-TOOL_24.webp | 24x24 | 24x24 | 1.00 | battle_lights town_codex town_deck town_deck_slots town_pick |
| assets/art/icons/ICON-TYPE-SPELL_24.webp | 24x24 | 24x24 | 1.00 | battle_lights rewards town_codex town_deck town_deck_slots |
| assets/art/icons/ICON-TYPE-TRAP_24.webp | 24x24 | 24x24 | 1.00 | town_codex town_deck town_deck_slots |
| assets/art/icons/ICON-ENERGY-GENERIC_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-ENERGY-B_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-ENERGY-G_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-ENERGY-R_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-ENERGY-N_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-TYPE-WONDER_24.webp | 24x24 | 24x24 | 1.00 | town_deck town_deck_slots |
| assets/art/icons/ICON-GEAR-SAUCEPANHELMET_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-GEAR-XRAYGOGGLES_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-PADLOCK_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor town_item_vendor |
| assets/art/icons/ICON-GEAR-WICKEDDAGGER_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-GEAR-CARDBOARDCUIRASS_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-GEAR-SOLIDPLATE_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-GEAR-TRAVELERSBOOTS_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-GEAR-EXTRAPOCKET_64.webp | 64x64 | 64x64 | 1.00 | town_equipment_vendor |
| assets/art/icons/ICON-ITEM-VITALITYCHARM_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-RECKLESSTONIC_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-HEALINGDRAUGHT_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-SCROLLOFINSIGHT_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-FIREBRANDCHARM_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-SHARPENINGSTONE_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-ITEM-HEALINGSALVE_64.webp | 64x64 | 64x64 | 1.00 | town_item_vendor |
| assets/art/icons/ICON-NODE-LOCKED_96.webp | 96x96 | 93x93 | 0.96 | dungeon_map |
| assets/art/icons/ICON-XP_32.webp | 32x32 | 30x30 | 0.94 | town_character town_character_gear |
| assets/art/icons/ICON-GOLD_48.webp | 48x48 | 44x44 | 0.92 | rewards town_bestiary town_bestiary_boss town_character town_character_gear town_codex town_codex_gear town_deck town_deck_slots town_dialogue town_equipment_vendor town_gate town_item_vendor town_pack_vendor town_pick town_reward_gold town_reward_pack town_tailor town_vendor town_wardrobe town_well |
| assets/art/icons/ICON-XP_48.webp | 48x48 | 44x44 | 0.92 | town_reward_gold town_reward_pack |
| assets/art/icons/ICON-CHECK_48.webp | 48x48 | 44x44 | 0.92 | town_reward_pack |
| assets/art/icons/ICON-UI-COLLECTION_64.webp | 64x64 | 56x56 | 0.88 | town_bestiary town_bestiary_boss town_codex town_codex_gear |
| assets/art/icons/ICON-UI-CHARACTER_64.webp | 64x64 | 56x56 | 0.88 | town_character town_character_gear |
| assets/art/icons/ICON-UI-DECK_64.webp | 64x64 | 56x56 | 0.88 | town_deck town_deck_slots |
| assets/art/icons/ICON-UI-WARDROBE_64.webp | 64x64 | 56x56 | 0.88 | town_wardrobe |
| assets/art/icons/ICON-LEVEL_48.webp | 48x48 | 40x40 | 0.83 | town_character town_character_gear |
| assets/art/icons/ICON-UI-INVENTORY_48.webp | 48x48 | 40x40 | 0.83 | town_character town_character_gear |
| assets/art/icons/ICON-UI-PACKS_48.webp | 48x48 | 40x40 | 0.83 | town_character town_character_gear |
| assets/art/icons/ICON-PADLOCK_48.webp | 48x48 | 40x40 | 0.83 | town_deck town_deck_slots |
| assets/art/icons/ICON-GOLD_32.webp | 32x32 | 26x26 | 0.81 | dungeon_map town_equipment_vendor town_item_vendor |
| assets/art/icons/ICON-NODE-BATTLE_128.webp | 128x128 | 104x104 | 0.81 | dungeon_map |
| assets/art/icons/ICON-ENERGY-B_32.webp | 32x32 | 26x26 | 0.81 | town_character town_character_gear |
| assets/art/icons/ICON-DECKBOX_32.webp | 32x32 | 26x26 | 0.81 | town_character town_character_gear |
| assets/art/icons/ICON-STAT-HP_32.webp | 32x32 | 26x26 | 0.81 | town_character town_character_gear |
| assets/art/icons/ICON-COS-WIDEBRIM_64.webp | 64x64 | 52x52 | 0.81 | town_tailor |
| assets/art/icons/ICON-COS-CHEF_64.webp | 64x64 | 52x52 | 0.81 | town_tailor |
| assets/art/icons/ICON-COS-BOWLER_64.webp | 64x64 | 52x52 | 0.81 | town_tailor |
| assets/art/icons/ICON-PADLOCK_96.webp | 96x96 | 77x77 | 0.80 | town_character |
| assets/art/icons/ICON-EQUIP-HELM_96.webp | 96x96 | 77x77 | 0.80 | town_character_gear |
| assets/art/icons/ICON-GEAR-WICKEDDAGGER_96.webp | 96x96 | 77x77 | 0.80 | town_character_gear town_codex_gear |
| assets/art/icons/ICON-GEAR-SOLIDPLATE_96.webp | 96x96 | 77x77 | 0.80 | town_character_gear town_codex_gear |
| assets/art/icons/ICON-EQUIP-BOOTS_96.webp | 96x96 | 77x77 | 0.80 | town_character_gear |
| assets/art/icons/ICON-EQUIP-RELIC_96.webp | 96x96 | 77x77 | 0.80 | town_character_gear |
| assets/art/icons/ICON-FEAT-STORY_48.webp | 48x48 | 38x38 | 0.79 | battle battle_lights dungeon_map ending town_bestiary town_bestiary_boss town_character town_character_gear town_codex town_codex_gear town_deck town_deck_slots town_dialogue town_equipment_vendor town_gate town_item_vendor town_pack_vendor town_pick town_reward_gold town_reward_pack town_tailor town_vendor town_wardrobe town_well |
| assets/art/icons/ICON-ITEM-HEALINGDRAUGHT_96.webp | 96x96 | 74x74 | 0.77 | town_reward_pack |
| assets/art/icons/ICON-KW-FLYING_32.webp | 32x32 | 24x24 | 0.75 | battle rewards town_codex town_deck town_deck_slots |
| assets/art/icons/ICON-GEAR-SAUCEPANHELMET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-BINLID_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CHAMPIONSLAURELS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-HEADCHEFTOQUE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-HUSTLEHEADBAND_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-RACCOONCROWN_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-XRAYGOGGLES_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-BIGBRAINBERET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-HUBRISCROWN_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-POINTYSTICK_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-STARTERBLADE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-DUMPSTERGLOVES_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-HEADCHEFLADLE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-IRONKNUCKLES_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-SUCKERPUNCHMITTS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CLIPWELLSSHEARS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-FLAMETHROWER_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-GLADIATORSNET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-GLASSJAWGAUNTLETS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-ROLLINGPIN_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-SPOTTERSBARBELL_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-COLONELSLADLE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CARDBOARDCUIRASS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CROWDPLEASERSCAPE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-DOGGYBAG_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-SWOLEBELT_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-MYSTERYSTAINBIB_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-PAPERPLANECAPE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-PROTEINBANDOLIER_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-THORNEDLOINCLOTH_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-ELASTICWAISTBAND_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-PANTRYAPRON_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-FLIPFLOPS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-GOTTAGOGALOSHES_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-TRAVELERSBOOTS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-BLOODSANDBOOTS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-COMPOSTBOOTS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-HOVERBOOTS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-EXTRAPOCKET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-LUCKYSOCK_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-PARTICIPATIONTROPHY_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CHEATERSDICE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-CLERKSSTAMP_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-DOGEAREDBOOKMARK_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-KETTLEBELLLOCKET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-NOTARYSEAL_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-REDTAPEDISPENSER_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-COURIERLANYARD_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-VELVETROPE_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-COMPLIANCECLIPBOARD_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-OVERDUELIBRARYBOOK_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-PLUMESQUILL_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-QUOTASSTOPWATCH_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-SEEDSATCHEL_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-SIPHONSLENS_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-FOURSEALSIGNET_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-GEAR-FIRSTWATERPHIAL_96.webp | 96x96 | 72x72 | 0.75 | town_codex_gear |
| assets/art/icons/ICON-STAT-ATTACK_24.webp | 24x24 | 18x18 | 0.73 | battle battle_lights rewards town_codex town_deck town_deck_slots town_pick town_reward_pack |
| assets/art/icons/ICON-STAT-DEFENSE_24.webp | 24x24 | 18x18 | 0.73 | battle battle_lights rewards town_codex town_deck town_deck_slots town_pick town_reward_pack |
| assets/art/icons/ICON-RES-IRON_48.webp | 48x48 | 34x34 | 0.71 | battle battle_lights |
| assets/art/icons/ICON-RES-REDTAPE_48.webp | 48x48 | 34x34 | 0.71 | battle battle_lights |
| assets/art/icons/ICON-RES-INGREDIENT_48.webp | 48x48 | 34x34 | 0.71 | battle battle_lights |
| assets/art/icons/ICON-RES-GARBAGE_48.webp | 48x48 | 34x34 | 0.71 | battle battle_lights |
| assets/art/icons/ICON-ESSENCE-B_48.webp | 48x48 | 34x34 | 0.71 | town_character town_character_gear |
| assets/art/icons/ICON-ESSENCE-G_48.webp | 48x48 | 34x34 | 0.71 | town_character town_character_gear |
| assets/art/icons/ICON-ESSENCE-R_48.webp | 48x48 | 34x34 | 0.71 | town_character town_character_gear |
| assets/art/icons/ICON-ESSENCE-N_48.webp | 48x48 | 34x34 | 0.71 | town_character town_character_gear |
| assets/art/icons/ICON-KW-HUSTLE_32.webp | 32x32 | 19x19 | 0.58 | town_codex town_deck town_deck_slots town_pick town_reward_pack |
| assets/art/icons/ICON-TYPE-INFRA_24.webp | 24x24 | 14x14 | 0.58 | battle battle_lights town_deck town_deck_slots |
| assets/art/icons/ICON-NODE-BOSS.webp | 256x256 | 140x140 | 0.55 | dungeon_map |
| assets/art/icons/ICON-KW-SUCKERPUNCH_32.webp | 32x32 | 17x17 | 0.54 | battle town_codex town_deck town_deck_slots |
| assets/art/icons/ICON-KW-OVERTIME_32.webp | 32x32 | 17x17 | 0.54 | battle_lights town_codex town_deck town_deck_slots |
| assets/art/keyart/TITLE-KEYART.webp | 1672x941 | 2079x1170 | 1.24 | title |
| assets/art/keyart/STORY-EPI-MODEL-FALLS.webp | 1792x1008 | 1920x1080 | 1.07 | ending |
| assets/art/keyart/LOGO-WORDMARK.webp | 1280x640 | 760x380 | 0.59 | title |
| assets/art/maps/MAP-S-NECRO.webp | 1536x1024 | 1920x1280 | 1.25 | dungeon_map |
| assets/art/portraits/V-BEETSWORTH.webp | 512x768 | 648x972 | 1.27 | town_equipment_vendor |
| assets/art/portraits/V-TONIC.webp | 512x768 | 648x972 | 1.27 | town_item_vendor |
| assets/art/portraits/V-FENWICK.webp | 512x768 | 648x972 | 1.27 | town_pack_vendor |
| assets/art/portraits/V-SABLE.webp | 512x768 | 648x972 | 1.27 | town_vendor |
| assets/art/portraits/V-THREADWELL.webp | 512x768 | 500x750 | 0.98 | town_tailor |
| assets/art/portraits/NPC-ELDER.webp | 512x768 | 461x691 | 0.90 | town_dialogue |
| assets/art/ui/UI-BG-DECKBUILDER.webp | 1536x1024 | 1920x1280 | 1.25 | town_bestiary town_bestiary_boss town_codex town_codex_gear town_deck town_deck_slots |
| assets/art/ui/UI-BG-CHARACTER.webp | 1536x864 | 1920x1080 | 1.25 | town_character town_character_gear |
| assets/art/ui/UI-HUD-PLAYERPLATE.webp | 1024x392 | 330x126 | 0.32 | battle battle_lights |
| assets/art/ui/UI-NAMEPLATE.webp | 1024x226 | 300x66 | 0.29 | town_dialogue |
| assets/art/ui/UI-CARDBACK-B.webp | 683x1024 | 168x252 | 0.25 | battle battle_lights town_codex |
| assets/art/ui/UI-MINIMAP-FRAME.webp | 1024x1013 | 250x250 | 0.24 | town_bestiary town_bestiary_boss town_character town_character_gear town_codex town_codex_gear town_deck town_deck_slots town_dialogue town_equipment_vendor town_gate town_item_vendor town_pack_vendor town_pick town_reward_gold town_reward_pack town_tailor town_vendor town_wardrobe town_well |
| assets/art/ui/UI-PACK-B.webp | 683x1024 | 168x246 | 0.24 | town_pack_vendor |
| assets/art/ui/UI-PACK-G.webp | 683x1024 | 168x246 | 0.24 | town_pack_vendor |
| assets/art/ui/UI-PACK-R.webp | 683x1024 | 168x246 | 0.24 | town_pack_vendor |
| assets/art/ui/UI-PACK-N.webp | 683x1024 | 168x246 | 0.24 | town_pack_vendor |
| assets/art/ui/UI-HUD-DECK.webp | 1024x516 | 150x76 | 0.15 | battle battle_lights |
| assets/art/ui/UI-PACK-GENERAL-1.webp | 683x1024 | 102x150 | 0.15 | town_reward_pack |
| assets/art/ui/UI-CARDBACK-C.webp | 683x1024 | 90x135 | 0.13 | battle battle_lights |
| assets/art/ui/UI-BTN-CLOSE.webp | 761x753 | 65x65 | 0.09 | town_bestiary town_bestiary_boss town_character town_character_gear town_codex town_codex_gear town_deck town_deck_slots town_equipment_vendor town_item_vendor town_pack_vendor town_tailor town_vendor town_wardrobe |
| assets/art/vendors/VS-BEETSWORTH.webp | 1672x941 | 1920x1081 | 1.15 | town_equipment_vendor |
| assets/art/vendors/VS-TONIC.webp | 1672x941 | 1920x1081 | 1.15 | town_item_vendor |
| assets/art/vendors/VS-FENWICK.webp | 1672x941 | 1920x1081 | 1.15 | town_pack_vendor |
| assets/art/vendors/VS-THREADWELL.webp | 1672x941 | 1920x1081 | 1.15 | town_tailor |
| assets/art/vendors/VS-SABLE.webp | 1672x941 | 1920x1081 | 1.15 | town_vendor |
| assets/icons/game-icons/delapouite/backpack.svg | 512x512 | 72x72 | 0.14 | battle battle_lights |
| assets/icons/game-icons/delapouite/hand-bandage.svg | 512x512 | 64x64 | 0.13 | town_item_vendor |
| assets/icons/game-icons/lorc/gem-pendant.svg | 512x512 | 72x72 | 0.14 | town_codex_gear |
| assets/icons/game-icons/lorc/pointy-hat.svg | 512x512 | 50x50 | 0.10 | battle battle_lights |
| assets/icons/game-icons/lorc/magic-swirl.svg | 512x512 | 43x43 | 0.08 | dungeon_map |
