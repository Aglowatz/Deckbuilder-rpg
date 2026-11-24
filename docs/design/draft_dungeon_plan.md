# The draft dungeon: plan for Phase 3 ("The Shuffled Halls")

Written in Draft mode, Phase 1 (Nov 23 2026) from `docs/design/draft_mode.md`, "Dungeon drafts". Nothing here is built yet. The
picture of the layout is `docs/design/draft_dungeon_plan.jpg` (also on the Drive: `Batch 20 Refs/plan-draft-dungeon.jpg`), and
the map to paint is the row `MAP-DRAFT` in `docs/art/batch20.csv`.

## What it is

A node dungeon made for drafts. You draft a deck at the door (the same 25 picks, 5 pieces of equipment, 2 items), then walk
six of its eighteen rooms. **After each real fight you pick one of three cards:** add it, swap it for a card in your deck, or
take nothing. The rooms shape the run more directly than a zone dungeon's: you choose between better cards, safer HP and
bigger prizes.

It is one map used by every dungeon draft, with the fights dealt from the zone whose draft it is (the Gainlands' draft meets
Gainlands foes, Primm's Castle's draft meets the castle's). The zone dungeons themselves stay as they are.

## The layout

Eighteen rooms in six columns: 2, 3, 4, 4, 3, 2. Every link leads right, as in Primm's Castle, and a run walks one room in each
column. From any room you can reach the two or three rooms nearest to it in the next column, so routes cross but never loop.

| Column | Rooms | What the column is for |
|---|---|---|
| 1 | two Gates | The first fight (both the same strength). The choice is only which side of the map you start on. |
| 2 | Trade Counter, Fight, Kettle | The first real choice: a multi-Path card, a card pick from a fight, or HP. |
| 3 | Fight, Champion, Buff room, Fight | The middle. One Champion: harder, with a prize. |
| 4 | Curse vault, Fight, Trade Counter, Champion | The greedy column. |
| 5 | Kettle, Fight, Buff room | The last stop before the boss: heal, one more pick, or a buff. |
| 6 | The House (two doors, one boss) | The boss. Both doors lead to the same fight. |

## The rooms

- **Fight.** An ordinary encounter of the zone. Win: pick one of three cards (add, swap or pass).
- **Champion.** A planned, hard encounter (a hand-made deck with one rule, like the Arena's champions). Win: pick one of three
  cards from the top two rarities, and a piece of equipment from two. Lose and the run is over like any other loss.
- **Trade Counter.** No fight. Three multi-Path cards that fit your Paths are on the counter (two-Path cards from the start of
  the arena, three- and four-Path cards after Primm, the same lock as everywhere). Take one, and give up one card of your deck
  for it. This is the room that makes a dungeon draft a source of multi-Path cards.
- **Kettle.** The heal room, by the rules already in the game (the Garden, the Archivists' Kettle): heal 6 for gold, or heal 6
  for a drawback in the next fight, or walk on.
- **Buff room.** Choose one of three boons for the rest of the run (the castle's boon rules: +1 attack for your units, one
  more card in the opening hand, 4 more max HP, and so on).
- **Curse vault.** A prize on a pedestal (an Epic or Legendary card, or a piece of equipment) and a curse to carry for the rest
  of the run if you take it (the enemy's units get +1 attack; you start each fight with 2 HP less; your first card each fight
  costs 1 more). Walking past costs nothing.
- **The House.** The boss: the zone's own boss with a draft-sized deck, or for the open dungeon draft a rival drafter with a
  full kit (equipment and items too).

## HP, losses and rewards

- **One HP pool for the whole dungeon** (a zone dungeon's rule), so the Kettles matter. This is the one place draft mode
  differs from the host's table, where every fight is at full HP. The run ends at the first loss.
- **Rewards:** cards, packs and essence by how far you got; a first-clear prize per zone; after a full clear, keep one card of
  the deck (the "keep one card" rule applies to dungeon drafts too). **The Primm's Castle draft pays prismatic packs.**
- **Entry:** 100 gold, the first attempt at each dungeon draft free (the same fee as every draft).

## Later (the design's "later option")

Harder levels for replays: more HP for every encounter, stronger units, opponents that start with resources, Infrastructure or
extra cards. One number per level in data, like the rest of draft mode.

## What Phase 3 has to build

1. The map (the painted `MAP-DRAFT`, its landing spots fitted like the castle's) and its layout in `data/dungeons/`.
2. The pick after a fight (add, swap or pass) on the rewards screen, drawing from `DraftEngine`'s pool.
3. The Trade Counter and the Curse vault (two new room kinds); the Kettle, the Buff room and the Champion reuse what exists.
4. The dungeon draft entry on each freed zone's dungeon door, and the Primm's Castle draft.
5. Sims: clear rates by Path and route, like the castle's route table.

## Decided by the owner, Nov 23

- The Shuffled Halls is the Shuffle House's own dungeon (its own map, MAP-DRAFT); each freed zone's draft dungeon uses that zone's own map.
- One HP pool; the run ends at the first loss.
- Trey Pickett is a fight inside and Octavia Eightfold is the final boss.
- Entry is free.

## Open points for the owner (answered above)

- One shared map for every dungeon draft (this plan), or one per zone? One map is one picture; five would be five.
- One HP pool (this plan) or full HP each fight, as at the host's table?
- Is the run over at the first loss (this plan), or at the second, as at the table?
