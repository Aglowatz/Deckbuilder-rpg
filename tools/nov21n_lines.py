"""Fable Nov 21 review (Part 4.1): the single-line spelling and consistency fixes to dialogue, as one CSV for tools/apply_dialogue_pass.js
(ID, Zone/Area, Speaker, When it's heard, Current line, New line) and the id list for --revert.
   node tools/export_dialogue.js --out=_logs/n21r/dialogue.csv        (the lines as they are)
   python tools/nov21n_lines.py                                        (writes docs/dialogue/nov21n_lines.csv and _ids.txt)
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21n_lines.csv --apply
   node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21n_lines.csv --revert=docs/dialogue/nov21n_lines_ids.txt
The dialogue is written in British spelling (colour 21 times, favour 20, grey 11, moustache, rumour, neighbour ...); these are the lines
that were not. Game terms keep their own spelling (Defense, the Armor slot) and so do names (the Honor Guard, the Extraction Theater,
Culinary Defense). Nothing else in a line changes."""
import csv, os, re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SOURCE = os.path.join(ROOT, '_logs', 'n21r', 'dialogue.csv')
OUT = os.path.join(ROOT, 'docs', 'dialogue', 'nov21n_lines.csv')
IDS = os.path.join(ROOT, 'docs', 'dialogue', 'nov21n_lines_ids.txt')

# word -> word, whole words only; never inside a [color=...] tag
WORDS = {
    'colors': 'colours', 'color': 'colour', 'colored': 'coloured', 'favorite': 'favourite', 'favor': 'favour', 'center': 'centre',
    'recognize': 'recognise', 'recognized': 'recognised', 'apologize': 'apologise', 'gray': 'grey', 'neighbor': 'neighbour',
    'rumor': 'rumour', 'rumors': 'rumours', 'traveler': 'traveller', 'travelers': 'travellers', 'mustache': 'moustache',
}
# hand fixes: (id, old fragment, new fragment)
HAND = [
    # the Deck Station's help line: the game's word is "Path" (the validator already says "Deck uses 3 Paths; limit is 2")
    ('ui/town/deckbuilder_screen.gd::_build::2', 'color%s', 'Path%s'),
]
SKIP_ID_PARTS = ['::STEPS::']  # the battle tutorial's lines carry [color=...] tags and no prose in question


def fix(text):
    def swap(match):
        word = match.group(0)
        new = WORDS[word.lower()]
        return new.capitalize() if word[0].isupper() else new
    pattern = re.compile(r'(?<![\[/=#\w])(' + '|'.join(sorted(WORDS, key=len, reverse=True)) + r')(?![\w=])', re.I)
    return pattern.sub(swap, text)


rows = []
with open(SOURCE, encoding='utf-8-sig', newline='') as f:
    reader = csv.reader(f)
    header = next(reader)
    for row in reader:
        if len(row) < 5 or any(part in row[0] for part in SKIP_ID_PARTS):
            continue
        current = row[4]
        new = current
        for hand_id, old, replacement in HAND:
            if row[0] == hand_id and old in new:
                new = new.replace(old, replacement)
        new = fix(new)
        if new != current:
            rows.append([row[0], row[1], row[2], row[3], current, new])
with open(OUT, 'w', encoding='utf-8', newline='') as f:
    writer = csv.writer(f, quoting=csv.QUOTE_ALL, lineterminator='\n')
    writer.writerow(['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'])
    writer.writerows(rows)
with open(IDS, 'w', encoding='utf-8', newline='\n') as f:
    f.write('# Fable Nov 21 review: single-line spelling fixes (British spelling, as the rest of the dialogue). Revert: node tools/apply_dialogue_pass.js --csv=docs/dialogue/nov21n_lines.csv --revert=docs/dialogue/nov21n_lines_ids.txt\n')
    for row in rows:
        f.write(row[0] + '\n')
print('%d lines' % len(rows))
for row in rows:
    print('-', row[0].split('::', 1)[1][:60], '|', row[4][:90], '=>', ' / '.join(w for w in row[5].split() if w not in row[4].split()))
