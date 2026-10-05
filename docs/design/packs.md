# Card packs (brief 11)

Source of truth for the pack system. Code: `core/data/pack_*.gd`, `ui/packs/`, data: `data/packs/*.tres`. **Balance is out of scope:**
every weight and price below is a placeholder that lives in the `.tres` files (tune there; `tools/generate_packs.gd` only writes files that
do not exist yet, so it never overwrites your numbers).

## Data
- `PackData` (one `.tres` per pack): name, `kind` (Path / Gilded / Prismatic / General), `path`, `card_count` (default 3), `rarity_weights`
  (Common, Uncommon, Epic, Legendary), `guarantee_epic_or_legendary`, `guarantee_multipath`, pool rules (`pool_paths`, `include_neutral`,
  `include_multipath`, `min_rarity`/`max_rarity`, `vendor_selection_only`), art (`art_color`, `frame_style`, `art_icon`), shop (`price`, `sold_by`,
  `unlock` Condition).
- `PackConfig` (`data/packs/pack_config.tres`): General tier-2 unlock (level / zones), dungeon pack count, first-clear bonuses, Primm's reward.
- `CardData.not_in_packs`: such a card is never in any pool. The list is `PackRules.NOT_IN_PACKS_IDS` (applied by `ContentDefinitions.build`, so it is in the
  generated card `.tres` files): the 4 mini-dungeon uniques, the 4 main-dungeon uniques, the 4 Path-quest rewards, Primm's reward, three chest cards
  (`tasting_menu`, `recycle_bin`, `moss_titan`) and the 12 enemy-only cards (Primm's enforcers/decks).
- Four new pack-eligible Legendaries (one per Path, `PackContent`) exist because every other Legendary is a unique reward.

## Rolling (`PackRoller`)
Per slot: a rarity by weight (only rarities present in the pool compete), then a uniformly random card of that rarity; no repeats inside one pack while the
pool allows. Guarantees re-roll a slot afterwards (the Epic guarantee never destroys the pack's only multi-Path card). Seeded RNG = deterministic.

## Inventory and opening
`PlayerProfile.packs` (pack id -> count, saved). `Session.add_pack / buy_pack / open_pack`. Opening adds the cards like any other (a copy beyond 4 converts into
essence, or gold for a neutral card) and returns a `PackOpening` (per card: new?, converted?, essence/gold) that the opening screen presents. Open packs from the
Character screen ("Card Packs" list), or straight after buying.

## Opening screen (`PackOpeningScreen`)
Pack floats; click tears it (shake, whoosh, flash); the cards fall face-down; each click flips one. Flair by rarity: Common puff; Uncommon green glint + chime;
Epic purple flash + rays + shake + chime/boom; Legendary: the room dims, the card hangs and pulses, golden screen flash, god rays, "LEGENDARY!" banner, fanfare,
heavy shake. NEW badge on first copies; extra copies show what they converted into; a summary lists everything. Esc / Skip reveals the rest quickly. All sounds are
procedural (`MusicSynth`) or from the existing Kenney packs.

## Pack types
| Pack | Pool | Guarantee | Sold by | Stocked when |
|---|---|---|---|---|
| Path Pack x4 | that Path's pack-eligible cards + neutral | none | Pack Vendor | that zone's dungeon was cleared once |
| Gilded Pack x4 | same | an Epic or Legendary | Black Market (Fig Sly, the Capital) | that zone's dungeon was cleared once |
| Prismatic Pack | any Path, neutral and all 24 multi-Path cards | a multi-Path card | Pack Vendor (hidden until then) | postgame unlocked |
| General Pack, tier 1 | the town card vendor's base selection, Commons and Uncommons | none | Card Vendor (Sable) | from the start |
| General Pack, tier 2 | the vendor's whole selection | none | Card Vendor | level 10 OR 2 zones freed |
