"""Fable Nov 24 (Part 7): the Shuffle House's rewards against the economy. A model, not a simulation of fights: it reads the
numbers of data/draft/draft_rules.json and the pack prices, takes a win rate per fight for each mode (measured by the draft
sims: docs/design/sim/nov24/), and works out what a run is worth on average and per hour, beside what the main game pays for
the same time (a replayed main dungeon, a replayed side dungeon).
    python tools/draft_economy.py [--classic=0.60] [--high=0.50] [--halls=0.35] [--halls_cash=0.5] [--dungeon=0.6] [--mini=0.7] [--out=docs/design/sim/nov24/modes_economy.md]
A pack is counted at its shop price (Path 150, Gilded 400, Prismatic 350, General 100): that is what the player would
otherwise pay Foil Fenwick. A kept card is not counted (its worth depends on the card)."""
import io
import json
import os
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
RULES = json.load(io.open(os.path.join(ROOT, 'data', 'draft', 'draft_rules.json'), encoding='utf-8'))
PACK_PRICE = {'path': 150, 'gilded': 400, 'prismatic': 350, 'general_1': 100, 'gilded_general': 400}
MAIN_REPEAT_GOLD = 300
SIDE_REPEAT_GOLD = 200
# minutes: a draft (25 picks, 5 pieces, 2 items, the deck), a table fight, a dungeon fight (shorter decks of foes), an event room
DRAFT_MIN = 7.0
FIGHT_MIN = 4.5
ROOM_MIN = 0.7


def arg(name, fallback):
    for raw in sys.argv[1:]:
        if raw.startswith('--%s=' % name):
            return raw.split('=', 1)[1]
    return fallback


def outcomes(p, wins_needed, losses_allowed):
    """{(wins, losses): probability} of a table run that ends at wins_needed wins or losses_allowed losses."""
    result = {}

    def walk(wins, losses, prob):
        if wins >= wins_needed or losses >= losses_allowed:
            result[(wins, losses)] = result.get((wins, losses), 0.0) + prob
            return
        walk(wins + 1, losses, prob * p)
        walk(wins, losses + 1, prob * (1.0 - p))

    walk(0, 0, 1.0)
    return result


def pack_value(word, after_primm):
    if word == 'prismatic':
        return PACK_PRICE['prismatic'] if after_primm else PACK_PRICE['gilded']
    return PACK_PRICE.get(word, 0)


def table_run(kind, p, after_primm, first):
    rewards = RULES['rewards']
    table = rewards.get('replay_by_kind', {}).get(kind, rewards['replay'])
    losses = RULES.get('high', {}).get('losses_to_finish', 2) if kind == 'high' else RULES['losses_to_finish']
    fee = RULES.get('entry_fees', {}).get(kind, 0)
    gold = 0.0
    xp = 0.0
    packs = 0.0
    fights = 0.0
    full = 0.0
    for (wins, lost), prob in outcomes(p, RULES['wins_to_finish'], losses).items():
        fights += prob * (wins + lost)
        gold += prob * table['gold'][min(wins, len(table['gold']) - 1)]
        xp += prob * table['xp'][min(wins, len(table['xp']) - 1)]
        if wins >= RULES['wins_to_finish']:
            full += prob
            packs += prob * pack_value(rewards['full_win_pack'].get(kind, ''), after_primm)
            if first:
                gold += prob * rewards['first_win_bonus']['gold']
                xp += prob * rewards['first_win_bonus']['xp']
                packs += prob * pack_value(rewards['first_win_pack'].get(kind, ''), after_primm)
    minutes = DRAFT_MIN + fights * FIGHT_MIN
    return {'gold': gold, 'xp': xp, 'packs': packs, 'fee': fee, 'full': full, 'minutes': minutes, 'fights': fights}


def dungeon_run(kind, clear_rate, fights, rooms, after_primm, first=False, cash_rate=0.0):
    """A dungeon draft: `clear_rate` of the runs are cleared; the others end, on average, after half the fights."""
    table = RULES['rewards']['dungeon']
    won_when_lost = fights * 0.45
    avg_fights_won = clear_rate * fights + (1.0 - clear_rate) * won_when_lost
    gold = avg_fights_won * table['gold_per_fight_won']
    xp = avg_fights_won * table['xp_per_fight_won']
    packs = 0.0
    extra = pack_value(table['extra_pack_after_primm'] if after_primm else 'gilded', after_primm)
    if kind == 'halls':
        gold += clear_rate * table['halls_clear_gold']
        xp += clear_rate * table['halls_clear_xp']
        packs += clear_rate * (PACK_PRICE['general_1'] + extra)
        if first:
            gold += clear_rate * table['halls_first_clear_gold']
            xp += clear_rate * table['halls_first_clear_xp']
            packs += clear_rate * PACK_PRICE['gilded']
        cash = table.get('halls_cash_out', {})
        gold += cash_rate * cash.get('gold', 0)
        xp += cash_rate * cash.get('xp', 0)
        packs += cash_rate * PACK_PRICE.get(cash.get('pack', ''), 0)
    elif kind == 'mystery':
        gold += clear_rate * SIDE_REPEAT_GOLD
        packs += clear_rate * PACK_PRICE['path']
    elif kind == 'main':
        gold += clear_rate * MAIN_REPEAT_GOLD
        packs += clear_rate * (PACK_PRICE['path'] + extra)
    minutes = DRAFT_MIN + (clear_rate * fights + (1.0 - clear_rate) * (won_when_lost + 1.0)) * FIGHT_MIN + rooms * ROOM_MIN
    return {'gold': gold, 'xp': xp, 'packs': packs, 'fee': 0, 'full': clear_rate, 'minutes': minutes, 'fights': fights}


def line(name, run, note=''):
    net = run['gold'] - run['fee']
    total = net + run['packs']
    per_hour = total * 60.0 / run['minutes']
    return '| %s | %d | %d | %d | %d | **%d** | %d | %d | **%d** | %s |' % (name, round(run['gold']), run['fee'], round(net), round(run['packs']), round(total), round(run['xp']), round(run['minutes']), round(per_hour), note)


def main():
    classic = float(arg('classic', '0.60'))
    high = float(arg('high', '0.50'))
    halls = float(arg('halls', '0.35'))
    halls_cash = float(arg('halls_cash', '0.50'))
    dungeon = float(arg('dungeon', '0.60'))
    mini = float(arg('mini', '0.70'))
    out = arg('out', 'docs/design/sim/nov24/modes_economy.md')
    lines = ['# The Shuffle House against the economy (Fable Nov 24; rerun Nov 25)', '',
        'Generated by `python tools/draft_economy.py` from `data/draft/draft_rules.json`. A model: a win rate per fight for each mode (from the draft sims of this folder), '
        'the reward tables as they are in the data, a pack at its shop price (Path 150, Gilded 400, Prismatic 350, General 100), '
        'a draft at %.0f minutes and a fight at %.1f. A kept card is not counted.' % (DRAFT_MIN, FIGHT_MIN), '']
    for after_primm in [False, True]:
        lines.append('## %s' % ('After Primm (Prismatic Packs are real)' if after_primm else 'Before Primm (a "Prismatic Pack" is paid as a Gilded Pack)'))
        lines.append('')
        lines.append('| A run of | Gold | Fee | Net gold | Packs (shop price) | Worth | XP | Minutes | Worth per hour | Note |')
        lines.append('|---|---:|---:|---:|---:|---:|---:|---:|---:|---|')
        lines.append(line('Classic Draft (replay)', table_run('open', classic, after_primm, False), '%d %% a fight; %d %% of runs are full wins' % (classic * 100, table_run('open', classic, after_primm, False)['full'] * 100)))
        lines.append(line('High Rollers Draft (replay)', table_run('high', high, after_primm, False), '%d %% a fight; %d %% full wins; the fee is %d' % (high * 100, table_run('high', high, after_primm, False)['full'] * 100, RULES.get('entry_fees', {}).get('high', 0))))
        lines.append(line('High Rollers at Classic\'s win rate', table_run('high', classic, after_primm, False), 'if the better equipment did not matter'))
        lines.append(line('Dungeon Draft: a zone dungeon', dungeon_run('main', dungeon, 9, 6, after_primm), '%d %% of runs cleared, 9 fights' % (dungeon * 100)))
        lines.append(line('Mystery Mini', dungeon_run('mystery', mini, 3, 0, after_primm), '%d %% cleared, 3 fights' % (mini * 100)))
        lines.append(line('The Shuffled Halls (replay)', dungeon_run('halls', halls, 4, 2, after_primm), '%d %% cleared, about 4 fights' % (halls * 100)))
        lines.append(line('The Halls, cashing out', dungeon_run('halls', 0.0, 3, 3, after_primm, False, halls_cash), '%d %% of runs reach the cashier, 3 fights' % (halls_cash * 100)))
        lines.append('| *The main game, for scale:* a replayed main dungeon with your own deck | %d | 0 | %d | 150 | **%d** | | 40 | **%d** | 9 fights at 4.5 minutes; its gold and its Path Pack (fight gold on a replay not counted) |' % (MAIN_REPEAT_GOLD, MAIN_REPEAT_GOLD, MAIN_REPEAT_GOLD + 150, (MAIN_REPEAT_GOLD + 150) * 60 / 40))
        lines.append('| *a replayed side dungeon* | %d | 0 | %d | 150 | **%d** | | 14 | **%d** | 3 fights |' % (SIDE_REPEAT_GOLD, SIDE_REPEAT_GOLD, SIDE_REPEAT_GOLD + 150, (SIDE_REPEAT_GOLD + 150) * 60 / 14))
        lines.append('')
    first_classic = table_run('open', classic, True, True)
    first_high = table_run('high', high, True, True)
    first_halls = dungeon_run('halls', halls, 4, 2, True, True)
    lines.append('## The first win of each (once per save)')
    lines.append('')
    lines.append('A first full win adds 300 gold, 200 XP and a Gilded Pack at a table (Classic and High Rollers each once); the Halls\' first clear adds 300 gold, 300 XP, a Gilded Pack and a piece of draft equipment. '
        'Weighted by the chance of a full win, a first Classic run is worth about %d, a first High Rollers run about %d (after its fee), a first Halls run about %d.' % (
        round(first_classic['gold'] + first_classic['packs']), round(first_high['gold'] - first_high['fee'] + first_high['packs']), round(first_halls['gold'] + first_halls['packs'])))
    lines.append('')
    lines.append('## Reading it')
    lines.append('')
    even = None
    for step in range(20, 81):
        run = table_run('high', step / 100.0, True, False)
        if run['gold'] - run['fee'] >= 0 and even is None:
            even = step
    lines.append('- **High Rollers against Classic:** the fee is paid back in gold alone from about %d %% a fight; under that it is a gold sink that pays in Prismatic Packs. At the same win rate it is worth more than Classic at every result; the opponents\' better equipment is what the fee buys.' % (even or 0))
    lines.append('- **No mode out-earns the main game\'s own replays by much** per hour once the draft\'s seven minutes are counted, so drafting is a different way to play for packs, not a faster farm. The side dungeon replay stays the gold farm of the game.')
    lines.append('- **Prismatic Packs** come from three places only (the Dungeon Draft, High Rollers, the Halls) and only after Primm; before Primm those rewards are Gilded Packs, which the shop prices higher (400 against 350): nothing is lost by the lock.')
    lines.append('- **Cashing out** of the Halls is worth less than half a clear and has no pack beyond a General Pack: a consolation for a run that would not survive Octavia, not a strategy.')
    path = os.path.join(ROOT, out)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    io.open(path, 'w', encoding='utf-8', newline='\n').write('\n'.join(lines) + '\n')
    print('\n'.join(lines))


if __name__ == '__main__':
    main()
