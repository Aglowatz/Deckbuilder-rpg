# Card availability (Cards Oct 27, Part 2)

Who can get which card. Every card carries an **availability** (`CardData.availability`, set in `data/source/card_overrides.csv`,
columns `availability` and `source`; the sheet mirror is `docs/design/sheet_availability_oct27.csv`), read by `CardAvailability`
(`core/data/card_availability.gd`):

| Availability | Meaning | Enforced by |
|---|---|---|
| **GENERAL** | packs, shops, reward picks, the Alchemist: anywhere cards are generated. The default (every card not listed below). | - |
| **REWARD-LOCKED** | never generated until the player has earned one from its named source; after that it may appear in packs, shops and picks at its rarity. | `CardAvailability.allowed(card, earned)` in `PackRoller.pool`, `VendorStocks.sellable` (Sable and every zone shelf), `RewardPicks` (elite / boss / gatekeeper picks), `RewardGenerator` (dungeon picks and the tutorial's), `Alchemy.possible_cards`; `earned` = `Session.earned_cards_map()` (every card owned + `Session.earned_cards`, the ids earned once from their source, saved) |
| **ENEMY-ONLY** | only that encounter's deck uses it; never in packs, shops, rewards, the Alchemist or the player's pool. | the same filters (never allowed); `ZoneDecks.from_recipe` drops the card from any deck whose enemy name is not an owner named in `source`; `EnemyDecks.ARCHETYPES` hold none (test) |

Existing saves: a player who already owns a now-ENEMY-ONLY card keeps it, marked **grandfathered** (`Session.grandfathered_cards`, set on load
by `_grandfather_owned_cards`; nothing is removed). An owned REWARD-LOCKED card counts as earned. The Dev Menu's "Ignore caps" tick is the
dev override: it adds any card, marking an enemy-only one grandfathered.

The Collection Book: ENEMY-ONLY cards sit in their own **"Seen in battle"** section (a silhouette until met, the card once seen, "Grandfathered"
when owned) and never count toward the Path bars or the 100%; a REWARD-LOCKED card shows **"Locked"** with its source as the tooltip and in
the inspect view until earned. `Session.collection_percent()` (the milestones) leaves ENEMY-ONLY cards out too.

## ENEMY-ONLY: the bosses' own cards

| Card | Owner (the only deck that runs it) | Why |
|---|---|---|
| N-33 Mortimer Grimsby, CE-No (L) | Mortimer Grimsby, CE-No (the Hall of Final Approvals boss) | the boss himself (the brief's CEO-No example). Was the Hall's first-clear prize and in the generic `necro_zombies` archetype; the archetype runs an Audit Wraith and a Lich instead, the Lab's Siphon and the Vault Warden a Mass Layoffs / Department. |
| N-30 Betty Bones, Surly Secretary (E) | Betty Bones, Surly Secretary (the Waiting Room of Eternity boss) | the boss herself. Was the Waiting Room's prize and in `necro_zombies`. |
| NB-16 Chancellor Clench, Iron Regent (L) | Chancellor Clench, Iron Regent (the House of Gains boss) | the boss himself; his deck (`beefcake_bruisers`) never ran his own card - it does now (`extra` in `dungeon_content.json`). Was a craftable dual Legendary. |
| P4-03 Mr. Tiggle, Rules Lawyer (L) | Primm (every phase; phase 3 runs it) | Primm's own rules lawyer (a scripted-event card of the final fight). Was a pack / Prismatic Legendary. |

Checked and left GENERAL (no personal card): the gatekeepers (Brick Bronson, Chef Gravois, Moss Mulligan, Prudence Pallor: trimmed
archetypes), the lieutenants (Vivienne Quota, Colonel Crumb, Percival Plume, Hortensia Clipwell: archetypes plus generic Epics such as
Royal Audit), the zone elites (Colonel Casserole, Captain Spotless), the arena champions (the Four Fists champion, Announcer Grand Bellows),
the Restless Dead, Shiro Swindle, the Wellspring's Echo and the Warden of the Four Seals (hand-written decks of generic cards), the Doppelganger
(it plays the real Grand Chef's card, G-33, which the player then earns), Compostella (R-33 is the cured Archdruid, the player's prize), the
Itamae (G-27 Toro Toro is a fish, not the chef), His Majesty the Raccoon (R-27 Raccoon is a generic raccoon). Royal Audit (C-30), Mirrored Hall
(C-32) and the other Capital-regime Epics stay GENERAL: the Black Market sells C-30 and Sable's rare pair holds C-32 (both untouched).

## REWARD-LOCKED: signature cards per dungeon

Each main dungeon pays its leader card on the first clear (as before) and its boss always offers a second chase card in the card pick until
the player has earned it (`DungeonSignatures.BOSS_PICKS`, applied in `Session._complete_dungeon_battle`'s offer). Each side dungeon pays its
one card on the first clear (`reward_first` in the dungeon list). A hidden-chest or quest card is locked to that source.

| Source | Card | Why this one |
|---|---|---|
| D-HOG The House of Gains, first clear | B-32 The Big Unit (L) | the freed Beefcake leader (unchanged) |
| D-HOG, Chancellor Clench's card pick | NB-17 Iron Filing Clerk (U, new) | the Iron Regent's own Necrocrat / Beefcake engine |
| D-HFA The Hall of Final Approvals, first clear | N-29 Mass Layoffs (E) | the Hall's verdict; Necrocrat's only mass removal, granted nowhere before (replaces Mortimer) |
| D-HFA, Mortimer's card pick | N-19 Resting In Peace Clause (U) | the Hall's fine print ("It reads you back.") |
| D-TTK The Test Kitchen, first clear | G-33 Grand Chef Escoffina (L) | the real Grand Chef (unchanged) |
| D-TTK, the Doppelganger's card pick | G-28 Chef de Golem (E) | the golem master of the war-machine kitchen (it was the shelf's after-boss Epic; the shelf sells it once earned, the same moment) |
| D-ROT The Rotheart, first clear | R-33 Archdruid Compostella (L) | the cured Archdruid (unchanged) |
| D-ROT, Compostella's card pick | R-29 Mount Trashmore (E) | the heap under the Rotheart; granted nowhere before |
| D-PC Primm's Castle, first clear | P4-02 Reunion of the Paths (L) | the ending (unchanged) |
| D-PC, Primm's card pick | C-34 The Harmony Engine (L) | the castle's four-Path core (Spotless and the Echo play it) |
| S-IRON The Iron Cave | B-31 The Ultimate Cardio Machine (E) | unchanged (also a Capital chest) |
| S-BEEF Mount Swolympus | B-30 Barbell of the Ancients (E) | unchanged (also the Capital quest The Wheel Never Stops) |
| S-GOUR Omakase | G-27 Toro Toro (E) | unchanged |
| S-NECRO The Waiting Room of Eternity | N-31 Department of Final Approvals (E) | fees and Red Tape for the eternal queue (replaces Betty Bones) |
| S-REF The Trash Panda Throne | R-27 Raccoon (E) | unchanged |
| S-CAP The Old Service Tunnels | C-29 The Wanderer (E) | unchanged (also a Crosspath hidden chest) |
| S-TOWN The Forgotten Vault | C-21 Old Kingdom Banner (C) | unchanged (also the story-challenge pool) |
| S-PASTE The Paste Works | G-30 The Infinite Pantry (E) | the paste factory doubles its output; the Works paid no card before (it was the Buffet shelf's after-boss Epic) |
| D-LAB The Path-ology Lab | P4-01 Champion of the Four Paths (E) | Siphon's hybrid specimen; the Lab paid no card before (it was in packs) |
| The Gainlands hidden chest `chest_delt_2` | B-28 Portal-Ripping Titan (E) | unchanged |
| The Capital quest Form 27-B/6: A Burial Permit | N-28 Lich of Accounts Payable (E) | unchanged |
| The Capital quest The Recipe Box | G-31 Recipe for Wonder (E) | unchanged |
| The Capital quest Untidy | R-30 The Mother Heap (E) | unchanged |

Enemy decks may run REWARD-LOCKED cards (they are what the player chases): the bruisers keep The Big Unit, the golems Toro Toro, the rats
The Mother Heap, Siphon the four leaders' cards.

## Where cards are generated, and what each checks

| Generator | Check |
|---|---|
| Pack opening (`PackRoller.roll`, `Session.open_pack`) | `allowed(card, earned)` in the pool |
| Sable's Card Stall (`VendorStocks.sable_sample`) | `sellable(card, state.earned_cards)` for every rotation and the fixed rare pair |
| The four zone shelves (`VendorStocks.zone_shelf`, `zone_scene`) | the same, with `Session.unlock_state()` |
| The Black Market, the Secret Dealer | untouched (their own lists) |
| Dungeon card picks (`RewardGenerator.card_choices`) and the tutorial's (`card_choices_for_color`) | `allowed(card, earned)` |
| Elite / boss / gatekeeper picks in the world and the dungeons (`RewardPicks.choose`, `_fallback`) | `allowed`, with `owned` (plus the earned set) as the earned map |
| A main dungeon's boss pick | the dungeon's chase card is forced into the three until earned |
| Quest, chest, dungeon first-clear and challenge cards | explicit ids: they ARE the sources |
| The Alchemist (`Alchemy.possible_cards`) | `allowed(card, owned)`: Clench never, the Clerk once earned |
| The Dev Menu "add card" (`DevActions.add_card`) | refused without "Ignore caps"; with it: added, grandfathered |
| Enemy deck builders (`ZoneDecks.from_recipe`, every encounter) | ENEMY-ONLY kept only for the named owner |

## Open points (inbox, "Cards Oct 27")

- Every Gourmand Epic is a prize or the Black Market's now, so the Buffet shelf's Epic tier shows only what the player has earned (Chef de
  Golem after the Doppelganger's pick). Gourmand and Necrocrat Path Packs keep a Legendary (G-32, N-32 stay GENERAL on the postgame shelf).
- The Necrocrat / Beefcake pair has no craftable Legendary at the Alchemist (Clench is ENEMY-ONLY).
