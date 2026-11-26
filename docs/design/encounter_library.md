# The encounter library (Nov 25 night, Part G)

Written by `tools/nov25n_encounter_library.py`, which also places them. Each is a choice of an existing event room (no map changes); the button says in brackets what it checks and what is at stake. Run-only changes end with the run. Audit and plan: `encounter_upgrades.md`.

| Id | Type | Where | The choice | What it does |
|---|---|---|---|---|
| L1 | Brittle Troops (curse) | S-GALLERY 3 "The Weight of Glass" | Leave it on the rack | `curse:Brittle Glass|def=-2` |
| L8 | The Reflected Patrol (patrol) | S-GALLERY 6 "The Valid Reflection" | Refuse to sign | `shred_type:wonder` |
| L2 | Silent Glass (curse) | S-GALLERY 12 "Your Reflection" | Look it in the eye | `boon:Know Yourself|atk=1,def=1, curse:Silent Glass|ban_spell=1, hint:your units +1/+1 for the gallery; no spells for the gallery` |
| L6 | The Specimen Trial (check) | D-LAB 4 "The Observation Deck" | Put a unit through the Specimen Trial | `reveal_unit:4|Passed the Trial|atk=1,def=1` |
| L7 | The Hedge-Wizard (boon NPC) | D-LAB 7 "The Draining Chamber" | Free the hedge-wizard strapped in beside it | `boon:The Wizard's Echo|trap_copy=1, damage:3, hint:lose 3 HP; your first Trap each turn is set twice, for the dungeon` |
| L5 | The Head Chef (check) | D-TTK 9 "The Staff Break Room" | Cook for the head chef's tasting | `check_units:gourmand,6,5|Head Chef's Nod|atk=1` |
| L6 | The Specimen Trial (check) | D-TTK 10 "R&D Archives" | Feed a unit to the Taste-Test Rex | `reveal_unit:3|Rex Approved|atk=1` |
| L10 | Roll-call: Beefcake (check) | D-HOG 5 "Locker Room of Legends" | Show the coach your roster | `check_units:beefcake,7,4|Coach's Pick|def=1` |
| L10 | Roll-call: Necrocrat (check) | D-HFA 8 "Form 27-B Office" | Submit your deck for audit | `check_units:necrocrat,6,4|Clean Audit|max_hp=4` |
| L10 | Roll-call: Refusemancer (check) | D-ROT 7 "Weeping Compost Pool" | Sort the pool's junk into bins | `check_units:refusemancer,6,4|Sorted|draw=1` |
| L9 | The Night Patrol (patrol) | D-HFA 12 "The Shredding Room" | Let the night patrol inspect your Tools | `shred_type:tool, gold:120, hint:gain 120 gold; every Tool in your deck is shredded for this run` |
| L3 | No Traps Allowed (curse) | D-PC 6 "Grand Foyer" | Swear the Regime's oath of order | `boon:Oath of Order|max_hp=6, curse:No Traps Allowed|ban_trap=1, hint:+6 max HP; no traps, for the dungeon` |
| L4 | One Thing at a Time (curse) | D-PC 4 "The Doppelganger's Lab Notes" | Follow the Doppelganger's schedule | `boon:On Schedule|draws=1,next=2, curse:One Thing at a Time|one_card=1,next=2, hint:next two fights: draw 1 more each turn, but play only one card a turn` |
| L2 | Vow of Silence (curse) | D-HOG 10 "The Meditation Garden" | Take the vow of the quiet mat | `heal:8, curse:Vow of Silence|ban_spell=1,next=2, hint:heal 8; no spells in the next two fights` |
