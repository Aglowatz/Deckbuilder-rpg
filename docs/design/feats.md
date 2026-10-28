# Feats (achievements)

Overnight Oct 27-28, Part 3. Small, in-world achievements: story milestones, one per zone and side dungeon, collection, fun card moments
per Path and for mixed decks, replay challenges and a few secret jokes. IP-safe (every title is a line or motif of this game). Data:
`data/feats/feats.json`; logic: `core/feats/` (pure, testable); screen: Menu > Feats. Rewards are small (gold, essence); nothing a player needs. (The brief allowed a dye or a title: the game has no dye-unlock or title
system yet, so those two rewards are gold and essence tonight; inbox.) Hidden feats show as "???" until earned.

## Rules

- **Tracked through real events** (a battle ending, a flag being set, a card joining the collection), never by polling text.
- **Saved per campaign slot** (which feats this run earned, when) **plus an account-wide record** (`user://feats_account.json`: the first
  time any slot earned it, and the counters that span runs). The Feats screen shows the account record; the slot's own are marked.
- **Retroactive where data allows:** on load, every "state" feat (flags, zones freed, collection %, dungeon clears) is re-checked against
  the save, so old saves earn what they already did; "moment" feats (a 10-attack unit, a 4-unit Mass Layoffs) cannot be back-filled.
- **Unlock toast** with the UI unlock sound; one toast at a time, queued; never during a cutscene (deferred to its end).
- **Rewards are granted once per account** (the first slot to earn a feat gets the gold / essence; a later slot earning it again gets the
  entry, not the reward), guarded by the account record.
- **Never changes rules or shows enemy intent;** the Black Market is not involved in any feat.

## The feats (40)

| # | Id | Name | Earned by | Hidden | Reward | Group |
|---|---|---|---|---|---|---|
| 1 | `leaves_in_your_hair` | Leaves in Your Hair | Choose your Path in the prologue | no | 10 gold | Story |
| 2 | `old_stone_cold_nights` | Old Stone, Cold Nights | Clear the Forgotten Cave | no | 25 gold | Story |
| 3 | `right_up_to_my_door` | Right Up to My Door | Meet Elder Maren in Crosspath | no | 10 gold | Story |
| 4 | `first_gate` | The Spotter Is Spotted | Free your first gatekeeper | no | 25 gold | Story |
| 5 | `hold_my_coat` | Hold My Coat | Free the Gainlands | no | 50 gold | Zones |
| 6 | `chef_always_tastes` | Chef Always Tastes | Free the Endless Buffet | no | 50 gold | Zones |
| 7 | `take_a_number_mortimer` | Take a Number, Mortimer | Free the D.N.A. | no | 50 gold | Zones |
| 8 | `the_twelfth_tree` | The Twelfth Tree | Free the Verdant Dump | no | 50 gold | Zones |
| 9 | `four_paths_one_kingdom` | Four Paths, One Kingdom | Free all four zones | no | 5 essence of each Path | Zones |
| 10 | `a_name` | A Name | Learn who you are | yes | 50 gold | Story |
| 11 | `sorry_about_the_hats` | Sorry About the Hats | Defeat Primm | no | 100 gold | Story |
| 12 | `home` | Home | See Isla come home | yes | 25 gold | Story |
| 13 | `carry_them_gently` | Carry Them Gently | Attend the royal funeral | yes | 25 gold | Story |
| 14 | `took_you_long_enough` | Took You Long Enough | Clear the Path-ology Lab | yes | 100 gold | Story |
| 15 | `number_4000212` | Number 4,000,212 | Clear the Waiting Room of Eternity | no | 25 gold | Side dungeons |
| 16 | `we_sampled_it` | We Sampled It | Clear the Trash Panda Throne | no | 25 gold | Side dungeons |
| 17 | `one_perfect_word` | One Perfect Word | Clear Omakase | no | 25 gold | Side dungeons |
| 18 | `the_older_way` | The Older Way | Clear the Old Service Tunnels | no | 25 gold | Side dungeons |
| 19 | `four_banners` | Four Banners | Clear the Forgotten Vault | no | 25 gold | Side dungeons |
| 20 | `never_skip_leg_day` | Never Skip Leg Day | Clear the Iron Cave | no | 25 gold | Side dungeons |
| 21 | `yes_chef` | ...Yes, Chef. | Clear the Paste Works | no | 25 gold | Side dungeons |
| 22 | `one_more_rep` | One More Rep | Clear Mount Swolympus | yes | 50 gold | Side dungeons |
| 23 | `gold_sand` | Gold Sand | Beat the Marshal in the Undercroft | no | 50 gold | Challenges |
| 24 | `the_oldest_trick` | The Oldest Trick | Beat Shiro Swindle | yes | 50 gold | Challenges |
| 25 | `four_seals` | The Hardest Duel | Beat the Warden of the Four Seals | yes | 100 gold | Challenges |
| 26 | `the_well_knows_you` | The Well Knows You | Finish the Old Well's secret | yes | 50 gold | Challenges |
| 27 | `shelf_esteem` | Shelf Esteem | Collection 25% | no | 25 gold | Collection |
| 28 | `foil` | Foil! | Collection 50% | no | 50 gold | Collection |
| 29 | `complete_file` | Complete File | Collection 100% | no | 200 gold + 5 essence of each Path | Collection |
| 30 | `mixed_properly` | Mixed Properly | Craft a card at Auntie Alembic's | no | 2 essence of each Path | Collection |
| 31 | `fresh_foil` | Fresh Foil | Open 10 packs | no | 25 gold | Collection |
| 32 | `overhead` | Overhead | A unit of yours reaches 10 attack | no | 25 gold | Beefcake |
| 33 | `three_golems` | Three Golems, One Kitchen | Control three Golems at once | no | 25 gold | Gourmand |
| 34 | `properly_filed` | Properly Filed | Hold five Red Tape at once | no | 25 gold | Necrocrat |
| 35 | `nothing_is_wasted` | Nothing Is Wasted | Eat garbage four times in one turn | no | 25 gold | Refusemancer |
| 36 | `restructuring` | Restructuring | Destroy four or more units with one card | yes | 25 gold | Necrocrat |
| 37 | `mixed_signals` | Mixed Signals | Win a battle with a two-Path deck | no | 25 gold | Dual Path |
| 38 | `the_paths_unbound` | The Paths Unbound | Win a battle with a three-Path deck | yes | 50 gold | Dual Path |
| 39 | `flawless` | Flawless | Win a boss battle without losing life | no | 50 gold | Challenges |
| 40 | `by_a_thread` | By a Thread | Win a battle at 1 life | yes | 25 gold | Challenges |

Icon: each group has one icon sheet (ICON-FEAT-<GROUP>, six icons a sheet; the catalogue lists them); until it exists, the Feats screen
uses an existing icon per group (the Path symbols for the Path groups, the quest icon for Story, the map icon for Zones, the trophy for
Challenges, the Collection Book icon for Collection).
