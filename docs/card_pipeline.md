# Card pipeline

How a card gets from the designer's Google Sheet into the game: **export -> import -> scripting -> art**.

```
Google Sheet --export CSV--> data/source/*.csv --tools/import_cards--> data/cards/<CardID>.tres, data/tokens/<TokenID>.tres
                                   ^                   ^
                         data/scripts/*.txt (one script per Card ID)        docs/card_import_report.md
art:  _art_inbox/<CardID>.png --"import card art"--> assets/art/cards/<CardID>.webp   docs/art/art_status.md
```

## 1. Export

Export the three tabs as CSV into `data/source/` (overwrite):

| File | Content |
|------|---------|
| `card_list.csv` | Every card. Rows with a value in the **Card ID** column are cards; section header rows ("Gourmand / Necrocrat:", "Colorless:", "Infrastructure:") give the card's Path(s); everything else (side notes, ideas) is ignored. |
| `token_list.csv` | Every token (units, Clause, the Contract and Red Tape resources, Grandmaster Flex...). |
| `design_guidance.csv` | The rules glossary (terms, keywords, resources). Read by humans; the engine implements it. |

`data/source/.gdignore` keeps Godot from importing the CSVs as translations. `data/source/card_overrides.csv` (`Card ID,not_in_packs`)
holds hand-maintained flags that survive a re-import (e.g. reward-only cards are marked `true`).

## 2. Import

```
bash tools/import_cards.sh                  # dry run: parse + validate, write docs/card_import_report.md only
bash tools/import_cards.sh --write          # also write data/cards/<ID>.tres and data/tokens/<ID>.tres
bash tools/import_cards.sh --write --clean  # ... and delete resources of cards no longer in the sheets
bash tools/import_cards.sh --stamp          # record the sheet's current rules-text hash in every script header
```

The importer (`core/data/card_importer.gd`, driven by `tools/import_cards.gd`) builds one `CardData` per Card ID: name, cost
(generic digits then `(B)(N)(G)(R)` pips), Paths (from the sheet section, so a "Gourmand / Necrocrat" card with a single
(N) pip is still both Paths; Infrastructure takes its Paths from its `produce` line), type, rarity (+ Signature flag), attack/defense,
rules text, flavor, image description (metadata for the art step), `not_in_packs` (default false), keywords and the script.
Three resource tokens that only exist in the Design Guidance (`RES-IRON`, `RES-INGREDIENT`, `RES-GARBAGE`) are generated beside the
sheet's tokens (`T-13` Contract and `T-14` Red Tape).

**The report** (`docs/card_import_report.md`) lists, after every run:

- **New cards** - not imported before, or no script yet;
- **Changed cards** - the sheet's rules text hash differs from the hash stored in the card's script header: *re-script the card*, then run `--stamp`;
- **Removed cards** - imported before, not in the sheet any more;
- **Unsupported mechanics** - scripts using an op, value, event or flag the engine does not implement;
- **Script problems** - syntax errors.

The status line says **CLEAN** only when all five lists are empty. A clean report means every card and token is playable.

## 3. Scripting

Each card's rules text is translated into a **script** in `data/scripts/*.txt` (the files are grouped by Path section; the importer reads
them all). The script is structured data, not code: the engine interprets it (`core/script/`), so a new card normally needs only a script.

```
== R-04 @88cad4579e9f  # Rubbish Goat            <- Card ID, hash of the sheet text when scripted, a comment
enter t=tool => may({destroy(t)}); ifdid({create(garbage)})
```

A script has header lines and one ability per line.

### Header lines
`kw swat,bulldoze` - keywords (`flying swat hustle wallflower bulldoze sucker_punch one_two_punch toxic nourish overtime elusive untouchable unbreakable`).
`produce B` / `produce N|B` / `produce any` - the energy an Infrastructure produces (sets its Paths).

### Ability line: `HEAD[(...)] [name=spec ...] [once] [| COSTS] [? COND] => EFFECTS`

| Head | Meaning |
|------|---------|
| `enter` | When this enters (units, wonders, tools, infrastructure). Declared targets are chosen when the card is played. |
| `die` | When this dies. |
| `play` | A Spell's effect (declared targets chosen when played). |
| `act` | An activated ability (your turn only). |
| `attach` | A Tool's "Exhaust: attach to target unit you control" (extra costs allowed: `attach \| pay(1)`). |
| `host` | A static effect on the unit this Tool is attached to (`host => stat(1,2); kw(swat)`). |
| `aura(spec)` | A static effect on every card matching `spec` (relative to the controller). |
| `static` | A static effect on itself or the player (`flag(...)`, `selfstat(a,d)`, `cost_plus(...)`). |
| `sot` `eot` `boc` | Start of your turn / end of your turn / beginning of combat on your turn. |
| `attack` `block` | Whenever this unit attacks / blocks. |
| `when(event:filter,...)` | Whenever the event happens (from the field). |
| `trap(event:filter,...)` | A Trap's condition. |
| `playcost` | An additional cost to play this card. |
| `costmod` | `costmod ? cond => cost_set(0,B)`: this card costs only that while the condition holds. |
| `drawn` | When drawn (Clause). |

`once` = "Do this only once per turn". A `?` condition is `lhs OP rhs` (`count(garbage)==0`, `count(unit.mine)<count(unit.opp)`,
`distinct_atk(unit.mine)>=5`) or a truthy value (`exists(unit.mine.atk>=5)`); `?!` negates.

### Targets and specs
`name=spec` declares a chosen target (`t=unit.opp.atk<=3`, `a=unit.mine b=unit.opp`, `ts=unit*4` = up to 4). A spec is
`zone[|zone].filter.filter...`:

- zones: `unit` `token` (unit tokens) `tool` `wonder` `infra` `resource` `trap` `any` (unit or player) `player` `opp` (the opponent player) `me`, and for piles `refuse` `deck` `hand` with a type (`refuse.unit.mine`, `deck.wonder`);
- filters: `mine` `opp` (side), `other`, `tok` `nontok` `tok:T-02` `golem`, `exhausted` `ready` `fresh` (not yet targeted this turn by this card) `buffed` `multipath` `attacking`, `path=G`, `kw=flying` `nokw=hustle`, `kind=garbage|iron`, and comparisons `atk<=3` `def<2` `cost>=4` `buffs>=1` (the right side may be `$var`).

In effects, selectors are: `self`, `me`, `opp`, `trig` (the card that triggered it), `trig_ctl`, `host`, `creator`, `last` (what the last create/reinstate made),
declared names (`t`, `ts`...), `$var`, and calls: `all(spec)`, `rand(spec)`, `pick(spec)` (best choice at resolution), `top_atk(spec)`, `ctl(sel)`.
Untouchable units and protected units are excluded when a player chooses a target.

### Costs
`exhaust`, `overexert`, `pay(2)` / `pay(G)` / `pay(1G)`, `use(ingredient,2)` / `use(redtape\|contract)` / `use(ingredient,X)` / `use(token)`, `eat` / `eat(2)`,
`destroy(unit.mine)` / `destroy(unit.mine.tok:T-02,2)` / `destroy_self` (this Tool). The permanent that exhausts as part of a cost cannot pay the
energy cost itself. Resource words: `iron redtape contract ingredient garbage`.

### Effects (`;`-separated; `{ ... }` blocks as arguments)
Damage and removal: `damage(sel,n[,source])` `damage_divided(ts,n)` `destroy(sel)` `destroy_self` `shred(sel)` `send_back(sel)` `to_hand(sel)` (Regrow) `edict(opp)` `plate(sel)` `brawl(a,b)` `brawl_each(spec,spec)`.
Control and recursion: `reinstate(sel[,player])` `reinstate_all(spec)` `reinstate_up_to(n,spec)` `reinstate_diff_paths(n)` `reinstate_destroyed(maxcost)` `steal(sel,perm\|eot)` `steal_all(spec)` `put_field(sel)`.
Creation: `create(resource-or-token[,n[,player]])` `create_x(T-08,X)` `copy_token(sel)` `copy_all_tokens()` `morph_tokens()` `shuffle_into(player,T-12,n)` `shuffle_refuse_into_deck(me)`.
Stats: `pump(sel,a,d,eot\|perm)` `pump_kill(sel,a,d)` `buff(sel,n)` `kw_grant(sel,kw,eot\|perm)` `set_def(sel,n)` `set_atk(sel,n)` `cant_block(sel,eot)` `protect(sel,until_next_turn)` `exhaust(sel)` `no_refresh(sel)` `attach(sel)`.
Players and cards: `add(R,R)` / `add(any)` (floating energy) `gain(p,n)` `lose(p,n)` `draw(n)` `peek(n)` `bury(p,n)` `search(infra,n,field\|hand)`.
Resources: `use(kind,n)` `use_any(kind)` (sets `$used`).
Flow: `set(name,value)` `if(cond,{...},{...})` `may({...})` `ifdid({...})` `flip({heads},{tails})` `choose({a},{b},...)` `processing(n,{...})` `delay_start_next_turn({...})`.
Values: numbers, `X`, `$var` (`$used $died $destroyed $buried_units $paid_def $paid_atk $paid_cost`), `atk(sel) def(sel) cost(sel) hp(sel) buffs(sel)`, `count(spec-or-resource)`, `mul plus sub min max ge gt le lt eq`, `distinct_atk(spec) distinct_paths(spec)`, `exists(spec) none(spec) has_buff(sel) host_is(B)`, `played(opp)`.
Static: `stat(a,d)` `selfstat(a,d)` `kw(word,...)` `flag(name)` (`free_eat double_ingredients global_double_resources iron_plus_2 red_tape_minus_2 opp_units_enter_exhausted extra_infra_drop cant_block`) `cost_set(generic,B..)` `cost_plus(me\|opp\|any,spell\|any\|unit...,n)`.

### Events (for `when` / `trap`)
`unit_enters` `unit_dies` `destroyed` `attacks` `blocks` `plays` `infra_enters` `creates_token` `token_created` `resource_created` `resource_used` `eat` `hp_drops`
and, for Tools, `attached_attacks` `attached_dies` `attached_dmg_opp` `attached_combat_dmg_unit`. Aliases: `token_dies` `rat_dies` `schmuck_dies` `golem_created` `attacked`.
Filters (relative to the script's controller): `mine opp other tok tok:ID golem hustle nohustle atk<=3 def<=2 cost>=4 tool|wonder multipath iron le=5`.

### Adding or changing a card
1. Edit the sheet, export the CSV into `data/source/`.
2. `bash tools/import_cards.sh` - read `docs/card_import_report.md`.
3. Script new/changed cards in `data/scripts/`. If a card needs a mechanic the engine lacks, add one op to `AbilityOps` (and `AbilityOps.OP_NAMES`) - that is all it takes.
4. `bash tools/import_cards.sh --stamp`, then `--write`; run the tests (`bash tools/run_tests.sh`): the headless smoke test plays every card.

## 4. Tests

`tests/core/game/test_card_smoke.gd` plays every card on a busy board, activates its abilities and passes turns; every token is created;
`test_card_mechanics*.gd` and `test_card_keywords.gd` check the rules card by card; `tests/core/data/test_card_importer.gd` checks the importer
(round trip, hashes, report cleanliness); `tests/core/sim/test_card_set_ai.gd` has the AI play full games with the set.

## 5. Art

See `docs/art/art_pipeline.md` (added with the art pipeline): art loads by convention from `assets/art/cards/<CardID>.webp`, with the placeholder
as the fallback; `tools/import_art` converts files dropped in `_art_inbox/`.
