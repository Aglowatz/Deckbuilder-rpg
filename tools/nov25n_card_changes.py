"""Nov 25 night (Part A.3): the owner's card changes, in the card sheet's CSV and the scripts.
  - Membership Cancellation (NB-06): costs 1 less (1(N)(B)) and reads "Destroy target tool or wonder." (no HP loss).
  - Resting In Peace Clause (N-19): shuffles 5 Clause tokens into the opponent's deck (it was 2).
  - Counterweight (B-19): deals 5 damage (it was 3).
Idempotent.    python tools/nov25n_card_changes.py   then   bash tools/import_cards.sh --write ; --stamp ; generate_content"""
import csv
import io
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
COSTS = {'NB-06': ('2(N)(B)', '1(N)(B)')}
TEXTS = {
    'NB-06': ('Destroy target Tool. Its controller loses 2 HP.', 'Destroy target tool or wonder.'),
    'N-19': ("Shuffle 2 Clause tokens into your opponent's deck. When your opponent draws a Clause, Shred it and create a 2/2 Zombie Rat token under your control.",
             "Shuffle 5 Clause tokens into your opponent's deck. When your opponent draws a Clause, Shred it and create a 2/2 Zombie Rat token under your control."),
    'B-19': ('When an opposing unit attacks, deal 3 damage to it.', 'When an opposing unit attacks, deal 5 damage to it.'),
}
SCRIPTS = [
    ('data/scripts/cards_dual.txt', 'play t=tool => set(c,ctl(t)); destroy(t); lose($c,2)', 'play t=tool|wonder => destroy(t)'),
    ('data/scripts/cards_necrocrat.txt', 'play => shuffle_into(opp,T-12,2)', 'play => shuffle_into(opp,T-12,5)'),
    ('data/scripts/cards_beefcake.txt', 'trap(attacks:opp) => damage(trig,3)', 'trap(attacks:opp) => damage(trig,5)'),
]


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    changed = 0
    for row in rows:
        if len(row) <= 14:
            continue
        cid = row[14]
        if cid in COSTS and row[3] == COSTS[cid][0]:
            row[3] = COSTS[cid][1]
            changed += 1
        if cid in TEXTS and row[5] == TEXTS[cid][0]:
            row[5] = TEXTS[cid][1]
            changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    for rel, old, new in SCRIPTS:
        path = os.path.join(ROOT, rel)
        text = io.open(path, encoding='utf-8', newline='').read()
        crlf = '\r\n' in text
        body = text.replace('\r\n', '\n')
        if old in body:
            body = body.replace(old, new)
            changed += 1
        elif new not in body:
            raise SystemExit('script line not found in %s: %s' % (rel, old))
        io.open(path, 'w', encoding='utf-8', newline='').write(body.replace('\n', '\r\n') if crlf else body)
    print('changed %d fields/lines' % changed)


if __name__ == '__main__':
    main()
