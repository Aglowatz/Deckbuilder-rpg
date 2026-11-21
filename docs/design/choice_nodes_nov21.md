# Dungeon choice rooms (Fable Nov 21, Part 4)

Every option of every choice room, read from `data/dungeons/dungeon_content.json` by `python tools/choice_nodes_nov21.py`. Since Nov 21 the four main-zone dungeons have **no full heal**: each heal room is a choice room, "heal 5 HP for a cost" or "do nothing". A do-nothing option is the only one with no cost. This replaces `choice_nodes_nov19.md`.

| Dungeon | Room | Option | You get | It costs | Lasts |
|---|---|---|---|---|---|
| The House of Gains | 5: Locker Room of Legends | Borrow the lucky towel | 'Lucky Towel': +2 max HP | lose 1 HP | rest of the dungeon |
| The House of Gains | 5: Locker Room of Legends | Raid the gym bag | +60 gold | 'Spotter Knows': the enemy's first unit gets +1/+1 | next fight |
| The House of Gains | 5: Locker Room of Legends | Do a set with the ghost of a champion | heal 3; a card (B-01) | 'Jelly Legs': your first unit enters exhausted | next fight |
| The House of Gains | 7 (story event "hg_descent", built in code) |  |  |  |  |
| The House of Gains | 9 (story event "hg_rescue", built in code) |  |  |  |  |
| The House of Gains | 10: The Meditation Garden **(was a full heal)** | Pay the towel deposit and stretch | heal 5 | pay 30 gold | at once |
| The House of Gains | 10: The Meditation Garden **(was a full heal)** | Skip the fee and nap on the mats | heal 5 | 'Slept on the Mats': the first unit you play gets -2 attack | next fight |
| The House of Gains | 10: The Meditation Garden **(was a full heal)** | Walk on | nothing | nothing | at once |
| The Test Kitchen | 7: The Corrupted Pantry | Eat the glowing stew | 'Corrupted Feast': your units get +1 attack, +3 max HP | lose 2 HP | rest of the dungeon |
| The Test Kitchen | 7: The Corrupted Pantry | Take only the sealed jars | +40 gold | 'Sticky Fingers': the first card you play each turn costs 1 more | next fight |
| The Test Kitchen | 7: The Corrupted Pantry | Ask the ladle to stop | heal 1; a card (G-04) | a random card leaves your deck for this run | rest of the dungeon |
| The Test Kitchen | 9: The Staff Break Room **(was a full heal)** | Buy a staff lunch from the honesty box | heal 5 | pay 40 gold | at once |
| The Test Kitchen | 9: The Staff Break Room **(was a full heal)** | Eat the counted samples | heal 5 | 'Samples Were Counted': the enemy starts with +2 HP | next fight |
| The Test Kitchen | 9: The Staff Break Room **(was a full heal)** | Leave the fridge alone | nothing | nothing | at once |
| The Test Kitchen | 10: R&D Archives | Compare the handwriting | 'Impostor Exposed': your units get +1 attack and +1 defense | 'Watched by the Impostor': the enemy's units get +1 attack | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Photograph the blueprints | +50 gold | 'Flash Burn': your first Infrastructure enters exhausted | next fight |
| The Test Kitchen | 10: R&D Archives | Pocket the recipe marked DO NOT SERVE | a card (G-17) | 'Do Not Serve': -1 card in the opening hand | rest of the dungeon |
| The Test Kitchen | 10: R&D Archives | Leave the archives alone | nothing | nothing | at once |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Take a number and wait | nothing | nothing | at once |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Take every number | +35 gold | 'Lost Your Place': you skip your first card draw | next fight |
| The Hall of Final Approvals | 2: Take-a-Number Kiosk | Skip the queue | 'Cut the Line': your units get +1 attack | 'Security Was Called': the enemy starts with a unit on the field | next fight |
| The Hall of Final Approvals | 8: Form 27-B Office | Fill out the forms | 'Duly Authorized': +3 max HP | pay 20 gold | rest of the dungeon |
| The Hall of Final Approvals | 8: Form 27-B Office | Forge the stamp | +50 gold | 'Flagged for Audit': the enemy starts with +1 card in hand | next fight |
| The Hall of Final Approvals | 8: Form 27-B Office | Ask the clerk what Form 27-C is | a card (N-15); heal 1 | 'Put on Hold': your first unit enters exhausted | next fight |
| The Hall of Final Approvals | 10: The Coffin Breakroom **(was a full heal)** | File one of your cards as Form 9-Z and lie down | heal 5 | a random card leaves your deck for this run | rest of the dungeon |
| The Hall of Final Approvals | 10: The Coffin Breakroom **(was a full heal)** | Nap without an appointment | heal 5 | 'Overslept': you skip your first card draw | next fight |
| The Hall of Final Approvals | 10: The Coffin Breakroom **(was a full heal)** | Keep walking | nothing | nothing | at once |
| The Hall of Final Approvals | 12: The Shredding Room | Shred a spare appeal | +70 gold | 'Paper Cuts': -2 max HP | rest of the dungeon |
| The Hall of Final Approvals | 12: The Shredding Room | Shred your own number | heal 4 | 'No Number': -1 card in the opening hand | rest of the dungeon |
| The Hall of Final Approvals | 12: The Shredding Room | Reach in for what it ate | a card (N-17) | lose 3 HP | at once |
| The Hall of Final Approvals | 12: The Shredding Room | Leave the shredder alone | nothing | nothing | at once |
| The Rotheart | 7: Weeping Compost Pool | Drink from the pool | 'Compost Courage': +3 max HP | lose 2 HP | rest of the dungeon |
| The Rotheart | 7: Weeping Compost Pool | Bottle some of it | +40 gold | 'The Pool's Grudge': the enemy's units get +1 attack | next fight |
| The Rotheart | 7: Weeping Compost Pool | Comfort the pool | heal 2; a card (R-01) | a random card leaves your deck for this run | rest of the dungeon |
| The Rotheart | 9: The Last Clean Spring **(was a full heal)** | Leave an offering and drink | heal 5 | pay 50 gold | at once |
| The Rotheart | 9: The Last Clean Spring **(was a full heal)** | Wade in and soak | heal 5 | 'Waterlogged': your units enter exhausted | next fight |
| The Rotheart | 9: The Last Clean Spring **(was a full heal)** | Leave it clean | nothing | nothing | at once |
| The Rotheart | 12: The Heart Roots | Give blood to distract the Rotheart | (-5 HP; you take the first turn in the fight); 'Blood for the Roots': you take the first turn | lose 5 HP | next fight |
| The Rotheart | 12: The Heart Roots | Walk on | nothing | nothing | at once |
| Primm's Castle | 3: Grand Foyer | Study the portrait | heal 6 | 'His Eyes Follow': -1 max HP | rest of the dungeon |
| Primm's Castle | 3: Grand Foyer | Pocket a gilded candlestick | +80 gold | 'Fingerprints Everywhere': -2 max HP | rest of the dungeon |
| Primm's Castle | 3: Grand Foyer | Count the reflections | 'Seen Him First': your units get +1 defense | 'One Reflection Too Many': the enemy starts with a unit on the field | next fight |
| Primm's Castle | 8 (story event "pc_early_journals", built in code) |  |  |  |  |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Read the notes | 'Lab Notes': your units get +1 attack and +1 defense | 'Too Much Reading': -1 card in the opening hand | rest of the dungeon |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Take the samples | +80 gold | lose 3 HP | at once |
| Primm's Castle | 12: The Doppelganger's Lab Notes | Practise the smile in the mirror | 'Perfect Smile': your units get +1 defense | lose 2 HP | rest of the dungeon |
| Primm's Castle | 16 (story event "pc_corrected_citizens", built in code) |  |  |  |  |
| Primm's Castle | 22: Garden of Uniform Flowers | Pick the odd one out | heal 8 | 'The Gardeners Noticed': the enemy's units get +1 attack | next fight |
| Primm's Castle | 22: Garden of Uniform Flowers | Pick a handful of the rest | +90 gold | 'Uniform Pollen': -2 max HP | rest of the dungeon |
| Primm's Castle | 22: Garden of Uniform Flowers | Plant something crooked | 'Crooked Little Hope': your units get +1 attack and +1 defense | lose 3 HP | rest of the dungeon |
| The Path-ology Lab | 4: The Observation Deck | Read the notes on the Subject | 'Know Your Enemy': your units get +1 attack | lose 2 HP | next fight |
| The Path-ology Lab | 4: The Observation Deck | Drink the Path-ologists' tea | heal 4 | 'Sedated': your first unit enters exhausted | next fight |
| The Path-ology Lab | 4: The Observation Deck | Rifle the lockers | +80 gold | lose 3 HP | at once |
| The Path-ology Lab | 7: The Draining Chamber | Put your hand on the glass | heal 6 | 'Drained': -1 max HP | rest of the dungeon |
| The Path-ology Lab | 7: The Draining Chamber | Read the dials | 'Know the Machine': your units get +1 attack | 'Feedback': the enemy starts with +3 HP | rest of the dungeon |
| The Path-ology Lab | 7: The Draining Chamber | Tear out the straps | 'Never Again': +3 max HP | lose 3 HP | rest of the dungeon |
| The Path-ology Lab | 9: Night Shift Break Room | Feed the vending machine | heal 5 | pay 80 gold | at once |
| The Path-ology Lab | 9: Night Shift Break Room | Drink the night shift's coffee | heal 5 | 'Night-Shift Jitters': the first card you play each turn costs 1 more | next fight |
| The Path-ology Lab | 9: Night Shift Break Room | Leave the room as you found it | nothing | nothing | at once |
| The Path-ology Lab | 11 (story event "lab_cell4", built in code) |  |  |  |  |
| The Path-ology Lab | 12: The Mentor's Study | Take the journal for Wren's true record | 'The True Record': +2 max HP | 'Alarm Raised': the enemy starts with a unit on the field | next fight |
| The Path-ology Lab | 12: The Mentor's Study | Leave it on the desk | nothing | nothing | at once |
| The Shattered Gallery | 3: The Weight of Glass | Lift it anyway | 'Unbroken Reflection': your units get +1 attack | lose 5 HP | rest of the dungeon |
| The Shattered Gallery | 3: The Weight of Glass | Leave it on the rack | nothing | 'Second Thoughts': -2 max HP | rest of the dungeon |
| The Shattered Gallery | 3: The Weight of Glass | Break it for the silver | +150 gold | a random card leaves your deck for this run | rest of the dungeon |
| The Shattered Gallery | 6: The Valid Reflection | Sign it | 'Approved': +3 max HP | 'Filed Away': your units get -1 attack | rest of the dungeon |
| The Shattered Gallery | 6: The Valid Reflection | Refuse to sign | nothing | lose 4 HP | at once |
| The Shattered Gallery | 6: The Valid Reflection | Sign someone else's name | heal 6 | pay 100 gold | at once |
| The Shattered Gallery | 8: The Quiet Frame | Rest (pay 250 gold) | heal 12 | pay 250 gold | at once |
| The Shattered Gallery | 8: The Quiet Frame | Rest, and leave a card as the fee | heal 8 | a random card leaves your deck for this run | rest of the dungeon |
| The Shattered Gallery | 8: The Quiet Frame | Keep moving | +0 gold | nothing | at once |
| The Shattered Gallery | 12: Your Reflection | Look it in the eye | 'Know Yourself': your units get +1 attack | 'Seen Through': -3 max HP | rest of the dungeon |
| The Shattered Gallery | 12: Your Reflection | Turn your back on it | nothing | lose 3 HP | at once |
| The Shattered Gallery | 12: Your Reflection | Smash it | 'Shattered Pride': your units get +1 defense | lose 6 HP | rest of the dungeon |

**Full heals that stay** (not changed; the castle rooms are untouched by the owner's rule): the Forgotten Cave's Whispering Shrine (the tutorial) and Primm's Castle's Resistance Safe Room. Since Nov 20 (the owner's answer) the Path-ology Lab's Night Shift Break Room is a "heal 5 for a cost" room like the four zone dungeons': 80 gold, or the first card you play each turn costs 1 more in the next fight.
