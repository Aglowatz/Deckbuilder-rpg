"""Fable Nov 24 (Part 2): the numbers of the Shuffle House's four modes, in data/draft/draft_rules.json. Idempotent.
    python tools/nov24_draft_rules.py
  - High Rollers Draft: an entry fee ("entry_fees": 200 gold, the owner's default), its own reward table (more than Classic),
    a Prismatic Pack for three wins (a Gilded Pack until Primm is defeated: the lock on Prismatic Packs stays), opponents who may
    draft every piece of equipment, and two losses like Classic (it was a no-loss "win three" table).
  - Classic Draft: no Prismatic Pack in any of its rewards.
  - Opponents at the tables: a random number of Paths within what the story has opened ("path_count_weights").
  - Dungeon Draft: Mount Swolympus counts as a large dungeon ("large_extra", the owner's list).
  - Mystery Mini: a pack of the dungeon's Path (a General Pack when it has none).
  - The Shuffled Halls: the Counting Halls' cash-out; the old numbers of the drafted dealers are gone (every dealer is hand-made:
    data/dungeons/dungeon_content.json, D-SHUFFLE)."""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'data', 'draft', 'draft_rules.json')
HIGH_FEE = 200
CASH_OUT = {'gold': 120, 'xp': 80, 'pack': 'general_1'}


def main():
    text = io.open(PATH, encoding='utf-8', newline='').read()
    data = json.loads(text)
    data['_about'] = ("Draft mode (docs/design/draft_mode.md). Every number of the mode lives here; core/draft/draft_rules.gd reads it. The owner tunes these; nothing in code repeats them. "
        "Fable big pass Nov 23: free entry, the 35-card minimum with free basics, the equipment removals and variety, the dungeon drafts. "
        "Fable Nov 24: the Shuffle House's four modes (Classic, Dungeon, Mystery Mini, High Rollers with its entry fee) and the static Shuffled Halls.")
    data['entry_fees'] = {'high': HIGH_FEE}
    data['_entry_fees'] = ("A kind of challenge with a fee of its own, charged on every attempt (the general entry_fee and first_attempt_free are not for it). "
        "high = the High Rollers Draft: 200 gold (the owner's default of Nov 24; an owner decision).")
    data['_entry_fee'] = "Every draft is free (the owner, Nov 23; it was 100 gold after the first attempt), except the kinds named in entry_fees."
    rewards = data['rewards']
    rewards['_about'] = ("Gold and XP for a table run by its wins (0 to 3): 'replay', or the kind's own table in 'replay_by_kind' (High Rollers pays more than Classic). "
        "A full win (3 wins) also pays a pack and lets the player keep one drafted card; the first full win of each challenge pays the first-win bonus on top. "
        "Packs: 'path' = the Path Pack of one of the draft's Paths, 'gilded' = a Gilded Pack of one of them, 'prismatic' only after Primm (before that it turns into 'gilded'). "
        "Classic Draft (open) and the Draft of the Day never pay a Prismatic Pack (the owner, Nov 24).")
    rewards['replay_by_kind'] = {'high': {'gold': [60, 140, 260, 480], 'xp': [20, 45, 80, 140]}}
    rewards['_replay_by_kind'] = ("High Rollers against its 200 gold fee: 0 wins 60 gold back, 1 win 140, 2 wins 260, 3 wins 480 and a Prismatic Pack "
        "(Classic: 20 / 45 / 80 / 140 and a Path Pack). Checked with tools/draft_economy.py (docs/design/sim/nov24/modes_economy.md).")
    rewards['full_win_pack'] = {'daily': 'path', 'zone': 'path', 'open': 'path', 'pair': 'path', 'trio': 'path', 'quad': 'path', 'high': 'prismatic'}
    rewards['first_win_pack'] = {'daily': 'gilded', 'zone': '', 'open': 'gilded', 'pair': 'gilded', 'trio': 'gilded', 'quad': 'gilded', 'high': 'gilded'}
    rewards['after_primm_full_win_pack'] = {}
    rewards['_after_primm_full_win_pack'] = "Empty since Nov 24: the kinds that turned to Prismatic Packs after Primm (the two-Path and win-three tables) are gone; High Rollers pays 'prismatic' outright."
    dungeon_pay = rewards['dungeon']
    dungeon_pay['_about'] = ("A dungeon cleared with a drafted deck pays MORE than a normal clear: the dungeon's own repeat-clear rewards (gold and its pack), an extra pack "
        "(a Prismatic Pack after Primm: the Dungeon Draft is the Prismatic mode), and one card of the draft deck to keep. A run that ends early pays consolation gold per room won. "
        "Mystery Mini pays the mini dungeon's gold and a pack of that dungeon's Path instead (mystery_pathless_pack when it has no Path). "
        "halls_cash_out: what cashing out at the Counting Halls pays on top of the gold per fight won (part of the prize; it is not a win).")
    dungeon_pay['halls_cash_out'] = CASH_OUT
    dungeon_pay['mystery_pathless_pack'] = 'general_1'
    rivals = data['rivals']
    rivals['path_count_weights'] = {'1': [100], '2': [50, 50], '4': [35, 45, 20]}
    rivals['_path_count_weights'] = ("How many Paths an opponent at the Shuffle House's tables drafts, by how many the story has opened (1, 2 or 4): the weights of one Path, two, three. "
        "Never the player's own choice (the owner, Nov 24); never four (a four-Path opponent deck stumbles over its Infrastructure).")
    rivals['_random_paths'] = "Each rival drafts random Paths (any Path, the player's included). In a zone draft as many as the player's draft has; at the Shuffle House a random number (path_count_weights)."
    data['high'] = {'losses_to_finish': 2, 'hp_bonus': 0}
    data['_high'] = "The High Rollers Draft (Nov 24): a Classic Draft for higher stakes, so two losses end it like Classic (the win-three tables of Nov 23 ended at one)."
    data['_rival_equipment_cap'] = ("The rarest piece a rival may draft, by the kind of challenge: Uncommon everywhere (the Epic and Legendary pieces are the player's alone), "
        "except the High Rollers Draft (high), where the opponents can get every piece of equipment the player can. The cap alone leaves the rivals too soft: rivals.hp_bonus makes up for it.")
    dungeon = data['dungeon']
    dungeon['large_extra'] = ['S-BEEF']
    dungeon['_large_extra'] = "Dungeons the Dungeon Draft lists although they have three encounters (the owner's list of Nov 24 names Mount Swolympus). Every other three-encounter dungeon is Mystery Mini's."
    dungeon.pop('halls', None)
    dungeon['_halls'] = ("The Shuffled Halls' encounters are hand-made and static since Nov 24 (data/dungeons/dungeon_content.json, D-SHUFFLE; tools/nov24_shuffled_halls.py): "
        "each dealer's deck, equipment, skill and HP (measured from the player's base HP: hp_vs_player) are in its own block.")
    newline = '\r\n' if '\r\n' in text else '\n'
    out = json.dumps(data, indent='\t', ensure_ascii=False).replace('\n', newline) + (newline if text.endswith('\n') else '')
    io.open(PATH, 'w', encoding='utf-8', newline='').write(out)
    print('draft rules: High Rollers fee %d, cash-out %s' % (HIGH_FEE, CASH_OUT))


if __name__ == '__main__':
    main()
