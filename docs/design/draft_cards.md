# Six new cards for draft pools (designed, not yet in the game)

Draft mode, Phase 1 (Nov 23 2026). The brief asks for 4 to 8 fun, high-impact cards for draft pools, balanced for the main game
too, with stand-in art. **These six are designed and have their art rows (Batch 20, `DR-01` to `DR-06`), but they are not in the
game yet:** every card comes from your card sheet (`data/source/card_list.csv`), and I do not add rows to it without your word.
Each one is written with wording the game already uses, so the importer can read it. Say "add them" and they go in with one
import, a test each and the next free IDs of their Paths.

| # | Name | Path | Type | Cost | Rarity | Text | P/T | Why it is fun in a draft |
|---|---|---|---|---|---|---|---|---|
| DR-01 | First Pick | Pathless | Spell | 1 | Uncommon | Peek at the top three cards of your deck. Put one into your hand and the other two on the bottom. | | The draft itself, played as a card: one of three. Good in any deck, never a dud. |
| DR-02 | Wheel the Table | Pathless | Spell | 3 | Epic | Each player shuffles their hand into their deck, then draws four cards. | | Saves a bad hand and wrecks a good one. A high-rarity pick that changes how you play the fight. |
| DR-03 | Signal Reader | Pathless | Unit | 2 | Common | When this unit enters, look at the opponent's hand. | 2/2 | A fair body with information. Pathless commons are the glue of a draft deck. |
| DR-04 | Bomb in the Pack | Beefcake | Spell | 5 | Epic | Deal 4 damage to each enemy unit. | | The card you first-pick and then build around: a one-sided sweep that punishes swarm rivals. |
| DR-05 | Late-Pick Hero | Refusemancer | Unit | 3 | Uncommon | This unit gets +1/+1 for each card in your Refuse Pile, up to +4/+4. | 1/1 | Looks like a last pick, wins the long game. Fits the Refusemancer's own theme. |
| DR-06 | Table Captain | Gourmand and Necrocrat | Unit | 4 | Epic | When this unit enters, create an Ingredient and a Red Tape. Your other units get +0/+1. | 3/4 | A two-Path card for the Crosspath draft arena (Phase 2): two-Path cards are offered only once all four zones are freed. |

## Notes on balance

- **First Pick** is a cheaper, narrower Peek; one card for one energy and no card advantage.
- **Wheel the Table** is symmetric. The AI will sometimes play it badly (with a full hand); it should be weighed in the sims
  before it is offered to rivals.
- **Bomb in the Pack** at 5 is dearer than the sweepers already in the game, and it spares your side; it is the one to watch.
  If it wins too many drafts it goes on the ban list (`data/draft/draft_rules.json`, `banned_cards`) rather than being changed.
- **Late-Pick Hero** is capped at 5/5 for 3, and needs a full Refuse Pile to get there.
- **Table Captain** follows the multi-Path lock like every two-Path card.

## Where they would come from in the main game

Like every other card: General and Path packs by their rarity (the Pathless ones in General Packs, Bomb in the Pack in Beefcake
Packs, Late-Pick Hero in Refusemancer Packs), and Table Captain in prismatic packs with the other multi-Path cards.
