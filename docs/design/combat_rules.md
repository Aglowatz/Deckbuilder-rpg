# Combat & Deck Rules (Locked Decisions)

Source of truth for game rules. `core/` implements this document; if code and this file
disagree, this file wins (or is deliberately updated first).

## Infrastructure and energy

- **Infrastructure** replaces lands. Infrastructure cards come in 4 types, one per **Path** (Beefcake,
  Gourmand, Refusemancer, Necrocrat - see `Affinity`). Players **activate** an infrastructure to gain **one energy of its
  Path**. Playing a card exhausts the infrastructure that pays for it (chosen automatically, or
  explicitly via `GameState.play`'s `activate_uids`).
- **Energy** (symbols: (B) Beefcake, (N) Necrocrat, (G) Gourmand, (R) Refusemancer; a number is generic): a card costs generic energy (payable by any infrastructure)
  plus one **pip** per colored energy, each of which needs an infrastructure of that exact Path.
  A **multi-Path (dual-Path) card** has pips of two Paths and needs energy from both (Part F).
- Terminology (see `data/source/design_guidance.csv`): Unit, Infrastructure (land), Energy (mana), Exhaust/Refresh
  (tap/untap), Activate (the act of using an ability, never a cost), Play (cast), Deck, Refuse Pile (graveyard), the field,
  Use (sacrifice a token or resource), Destroy, Shred (exile), Toss (discard), Bury X (mill), Reinstate, Send back, Brawl, Peek X,
  HP, Attack/Defense. The engine field for the tapped state is `CardInstance.exhausted`.
- A deck may use at most **2** Paths in the main campaign (a multi-Path card counts as BOTH of its Paths).
  The flag `postgame_unlocked` raises this limit to **4**.
- **Neutral** cards cost generic energy and fit any deck. There is no neutral infrastructure.
- The player starts with the neutral starter deck only, using basic infrastructure of a chosen
  primary Path; see `docs/design/starting_deck_and_affinity.md`.

## Resources (Brief 14)

There are exactly **four resources**: Iron (B), Red Tape (N), Ingredient (G), Garbage (R). They are token permanents kept in
their own zone per player (`PlayerState.resources`), created by basic Infrastructure and by card effects, and shown in the
resource tray in the battle UI. They are `CardType.RESOURCE` tokens; the kinds live in `ResourceKind`.

**Contract is NOT a resource.** It is a non-unit Necrocrat *token* (`CardType.TOKEN`, kept in `PlayerState.tokens` and shown in
its own token area with a counter). Everything else cards create (Contracts, Clauses, unit tokens, Snacks...) is a token, not a
resource. Effects that say "resource" (Hostile Takeover, Rusty Can Opener, Harvest Festival doubling, "whenever you use a
resource") never include Contracts; effects that say "token" (Waste Manager "use a token") do.

| Resource | Path | What it does |
|----------|------|--------------|
| Iron | Beefcake | Pay 1, use an Iron: target unit gets +1 attack permanently. |
| Red Tape | Necrocrat | Pay 1, use a Red Tape: target unit gets -1 attack permanently. |
| Ingredient | Gourmand | Does nothing alone; Gourmand cards spend it (Cook, golems, recipes). |
| Garbage | Refusemancer | Does nothing alone; Refusemancer cards spend it (Eat Garbage). |

| Token (not a resource) | Path | What it does |
|------------------------|------|--------------|
| Contract | Necrocrat | Pay 1, use a Contract: exhaust target unit. It doesn't refresh during its controller's next turn. |

- Playing a BASIC Infrastructure creates its Path's resource (Powerhouse: Iron, Ghost Town: Red Tape, Feastforge: Ingredient,
  Wasteworks: Garbage) - the basic's "When this Infrastructure enters" trigger, so putting a basic onto the field also does it.
  Special and dual-Path infrastructure never create resources. Nothing creates Contracts except cards (they are tokens, not resources).
- Uses of Iron, Red Tape and the Contract token are your-turn-only main-phase abilities, and the target may be any unit that
  you are allowed to target (Untouchable units cannot be targeted by the opponent's resources).
- "Use" a resource = remove it from your zone. "Shred" or "destroy" a resource (cards say which) also removes it.
- **Eat garbage** is a cost: pay 1 energy, lose 1 HP, use a Garbage (Raccoon: no energy, no HP). You cannot eat if it would
  reduce you to 0 HP.
- Floating energy: abilities like "Exhaust: add (R)" put energy in a pool that is spent before infrastructure and empties at the end
  of the turn; "add one energy of any Path" can pay any colored pip.
- Cards can create, use, double (Infinite Pantry, Harvest Festival), steal (Hostile Takeover), Shred and count resources.

## Card types and abilities (Brief 14)

Card types: **Unit, Spell, Trap, Tool, Wonder, Infrastructure**; Resources and Tokens are token permanents (`Resource`, `Token`).

- **Unit** - enters the field with summoning sickness (Hustle: can attack and activate at once). Units with an `Exhaust` ability
  cannot use it while summoning sick unless they have Hustle.
- **Spell** - played on your turn, resolves, goes to your Refuse Pile.
- **Trap** - played face-down on your turn (max 3 set); springs on whichever turn its condition is met, resolves, goes to the Refuse Pile.
- **Tool** - a permanent. "Exhaust: attach to target unit you control" (your turn; it may be moved to another unit later) gives the
  attached unit its bonuses. One-shot Tools: "Destroy this Tool: ...". When the attached unit leaves the field the Tool stays unattached.
- **Wonder** - a permanent with static or repeatable effects.
- **Infrastructure** - one per turn from hand (`Mr. Tiggle`: two). Exhaust for 1 energy of one of its Paths. A basic one creates its
  Path's resource when it enters; special ones carry extra abilities; dual-Path ones produce either Path; any-Path ones any.

**Abilities.** *Activated* abilities (your turn only, main phase) list their real costs: `Exhaust`, `Overexert` (exhaust and don't
refresh next turn), `pay N` / `pay (G)` energy, `use N <resource>`, `use a token`, `eat garbage`, `destroy a unit you control`,
`destroy this Tool`, X costs ("use X Ingredients"); "Do this only once per turn" is tracked per ability. *Triggered* abilities fire
on either turn whenever their event happens: when a unit enters / dies / attacks / blocks, start of turn / beginning of combat /
end of turn, a resource is created or used, a token is created or dies, a player plays a card type, HP drops to a threshold,
an attached unit attacks/dies/damages. "As an additional cost to play this ..." costs are paid when the card is played.
Chosen targets are picked when a card is played or an ability activated (up to N for "any number"); triggered abilities that
name a target pick the best one automatically (the strongest enemy for harmful effects, the best ally for helpful ones).
"May" effects are taken when they help. Scripts are described in `docs/card_pipeline.md`.

**Keywords.** Flying (blocked only by Flying/Swat), Swat (can block Flying), Hustle, Bulldoze (excess damage to the player),
Sucker Punch (damage before others), One-Two Punch (both steps), Toxic (any damage destroys a unit), Nourish (damage heals you),
Overtime (attacking doesn't exhaust), Wallflower (can't attack), Elusive (can't be blocked), Untouchable (the opponent's cards,
abilities and resources can't target it), Unbreakable (can't be destroyed by damage or destroy effects; can still be Shredded,
sent back or reduced to 0 defense). There is no Guard: attackers attack the player.

**Terms.** Destroy (a unit dies and goes to its owner's Refuse Pile), Shred (removed from the game), Toss (discard), Bury X (the top
X cards of a deck go to its owner's Refuse Pile), Reinstate (a unit from a Refuse Pile enters the field, under your control if
you say so), Send back (to its owner's hand; tokens vanish), Plate (becomes a 1/1 Snack token with no abilities), Brawl (two units
deal damage equal to their attack to each other), Peek X (look at the top X, put any on the bottom), Buff (+1/+1 permanently),
Fertilize X (X buffs), Processing X (resolves at the start of your turn X of your turns from now), Gain control (the permanent
moves to your zones; a stolen unit dies into its owner's Refuse Pile), Overexert (see above).

**Order of events.** A permanent entering: the "unit enters" event first (so a Trap can destroy it before its own enter ability),
then its own enter ability. A unit dying: it leaves the field and sits in the Refuse Pile (tokens: nowhere) while its "when this
dies" ability and every "whenever a unit dies" ability resolve, so cards can return it; stats it read are the ones it died with.
Several traps/triggers on one event are all judged against the event as it happened, then resolve in turn order of the field.

## Turn Structure

Start (ready, draw; the first player skips their first draw) → Main 1 → Combat → Main 2 → End.

- One infrastructure may be played per turn.
- Units have summoning sickness.
- Damage on units clears at end of turn.

## Combat

1. The attacker declares attackers.
2. The defender assigns at most one blocker per attacker.
3. Unblocked damage hits the player.

- Attacking units become **exhausted** and stay exhausted until their controller's next ready step,
  so they cannot block on the opponent's turn. **Overtime** units do not exhaust when attacking.
- Each blocker blocks at most one attacker.

## No Interaction Windows

- No instants, no stack, no priority.
- Traps are set face-down on your turn and trigger automatically when their condition is met.
- A player may have at most **3** traps set at a time (a fourth cannot be played until one has
  sprung). This cap is a base stat like max hand size, not a hard limit: dungeon rules, equipment
  or the final dungeon can raise it (`Modifier.Kind.MAX_TRAPS`).

## Win / Lose

- A player loses when their HP reaches 0.
- A player also loses when they must draw from an empty deck.

## Player Stats (PlayerProfile)

Stats come from a `PlayerProfile` resource, never hardcoded.

| Stat | Value |
|------|-------|
| Max HP | 10 at start, 25 at endgame |
| Opening hand | 5 to 8 cards |
| Max hand size | 10 |

Modifiers from equipment, items, and zones apply on top of the profile values.

## Progression (Part E)

HP, opening hand size, max hand size, item slots and equipment slot unlocks all advance with
the player's level (1-30), not fixed values - see `docs/design/progression.md` for the full,
generated level-by-level table and `core/data/progression_table.gd` for the source of truth. Every
encounter grants XP and gold scaled by `DungeonMap.Difficulty` (`EncounterRewards`).

## Deck Construction

- Minimum **45** cards, adjustable by `Modifier.Kind.MIN_DECK_SIZE` (e.g. the tutorial dungeon's
  starter-deck waiver - see "Starting deck" below).
- Maximum **4 copies of every non-infrastructure card, at every level** (rarity no longer matters).
  **Infrastructure is unlimited.** Copies beyond 4 owned convert into Path essence (Part F, see
  "Essence" below). The old rarity-based copy limits and the level-ups that raised them were
  removed; those levels grant other rewards (see `docs/design/progression.md`).

## Starting deck (Part C)

A new campaign's starter deck is **42 cards**: 23 colorless (neutral) non-infrastructure cards + 19 basic
infrastructure of the player's chosen Path - short of the normal 45-card minimum. A `MIN_DECK_SIZE`
modifier waives the minimum down to 42 for the whole tutorial dungeon only
(`TrialOfTheHollow.deck_size_waiver()`); the 3 tutorial reward picks (one per battle, restricted to
the player's own element on this first clear) bring the deck up to a real 45 cards by the time the
dungeon is cleared, at which point the waiver no longer applies. See
`docs/design/starting_deck_and_affinity.md` for the full flow.

## Rarity

Exactly four tiers, in ascending order: **Common, Uncommon, Epic, Legendary**
(`CardEnums.Rarity`). Rarity drives vendor pricing (`CardPricing`), the vendor's graduated
unlock thresholds (`VendorData.graduated`), reward-choice weighting (`RewardGenerator`, rarer
cards appear less often except the boss's table, which skews rarer) and the card frame's rarity
gem color/shape (`CardView.Gem` - a plain circle, diamond, hexagon and four-point sparkle,
respectively, so the tier reads even without the color).

## Dungeons

- HP carries over between encounters within a dungeon.
- The player is fully healed on entering a dungeon.

## Opening Hand: Hand Smoother (option)

When enabled (the default), the opening hand is drawn normally. If its infrastructure count is **more than
1 away** from the deck's infrastructure ratio (infrastructure count ÷ deck size × hand size), a second candidate
hand is generated and the one closer to that target is kept. The tolerance
(`GameOptions.smoother_tolerance`, default 1) is deliberately gentle: the smoother rescues
floods and screws but does not make every hand ideal.

## Mulligan

Each player gets **one free mulligan**.
