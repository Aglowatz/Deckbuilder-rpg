"""Nov 25 night (Part F): health for every Path. Before this pass Beefcake had no way to restore the player's HP, Necrocrat one (Notary
Wraith, 1 HP when it dies) and Refusemancer one (a trap at 5 HP or less); Gourmand had four and the Pathless cards five.
  1. Reworks: the weakest and least-used cards of those three Paths (no deck, recipe or dungeon list used them: `use=0` in the card
     survey of docs/design/health_by_path.md), turned toward the player's HP, each keeping its Path's identity.
  2. New cards: one per Path and one Pathless (C-41), with temporary art copied from a related card (assets/art/cards/<id>.webp) and an
     art row each in docs/art/batch22.csv. They are GENERAL cards: packs, shops, rewards and drafts.
Idempotent.    python tools/nov25n_health_cards.py   then   bash tools/import_cards.sh --write ; --stamp ; generate_content"""
import csv
import io
import os
import shutil

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
SHEET = os.path.join(ROOT, 'data', 'source', 'card_list.csv')
ART = os.path.join(ROOT, 'assets', 'art', 'cards')
BATCH22 = os.path.join(ROOT, 'docs', 'art', 'batch22.csv')

# id: (old text, new text, old script, new script, file)
REWORKS = {
    'B-13': ('Hustle.', 'Hustle.\n\nWhen this unit enters, gain 3 HP.', '# Hulking Hauler\nkw hustle\n', '# Hulking Hauler\nkw hustle\nenter => gain(me,3)\n', 'cards_beefcake.txt'),
    'B-23': ('Pay 1: target unit gets +2/+0 until the end of your turn. Each unit can be targeted only once per turn.', 'Pay 1: gain 2 HP. Do this only once per turn.',
             'act t=unit.fresh | pay(1) => pump(t,2,0,eot)', 'act once | pay(1) => gain(me,2)', 'cards_beefcake.txt'),
    'N-20': None,  # filled from the sheet (the old text is read, the new one written)
    'N-10': None,
    'R-10': ('At the start of your turn, if you control no Garbage, create a Garbage.', 'At the start of your turn, if you control no Garbage, create a Garbage.\n\nEat garbage: gain 2 HP. Do this only once per turn.',
             'sot ? count(garbage)==0 => create(garbage)', 'sot ? count(garbage)==0 => create(garbage)\nact once | eat => gain(me,2)', 'cards_refusemancer.txt'),
    'R-01': ('Exhaust: add (R).', 'Exhaust: add (R).\n\nEat garbage: gain 1 HP. Do this only once per turn.', 'act | exhaust => add(R)', 'act | exhaust => add(R)\nact once | eat => gain(me,1)', 'cards_refusemancer.txt'),
}
NEW_TEXT = {
    'N-20': ('As an additional cost to play this, destroy a unit you control.\n\nDraw two cards and gain HP equal to the destroyed unit\'s defense.',
             'playcost | destroy(unit.mine)\nplay => draw(2); create(redtape)', 'playcost | destroy(unit.mine)\nplay => draw(2); gain(me,$paid_def)', 'cards_necrocrat.txt'),
    'N-10': ('Exhaust: attach to target unit you control. Attached unit gets +0/+1 and Nourish. Whenever attached unit attacks, destroy up to two target resources your opponent controls.',
             'host => stat(0,1)', 'host => stat(0,1); kw(nourish)', 'cards_necrocrat.txt'),
}
# new cards: id, after id, path section number, rarity, name, cost, type, text, stats, flavor, art description, script file, script, art from
NEW = [
    ('B-39', 'B-38', '39', '(C)', 'Cool-Down Stretch', '(B)', 'Spell', 'Gain 4 HP. Create an Iron.', '',
     'Stretch it out. Hydrate. Then go again.', 'A Beefcake lifter in a sweatband stretching on a mat beside a rack, a towel round the neck and a water flask glowing faintly, steam rising off the shoulders.',
     'cards_beefcake.txt', 'play => gain(me,4); create(iron)', 'B-35'),
    ('N-39', 'N-38', '39', '(C)', 'Soul Collector', '3(N)', 'Unit', 'Flying.\n\nWhen this unit enters, your opponent loses 2 HP and you gain 2 HP.', '2/3',
     'Every soul is filed in triplicate. One copy is for you.', 'A hooded skeletal clerk with a ledger and a lantern, drifting over a desk, a thin ribbon of light flowing from a startled adventurer into the ledger.',
     'cards_necrocrat.txt', 'kw flying\nenter => lose(opp,2); gain(me,2)', 'N-06'),
    ('R-38', 'R-37', '38', '(C)', 'Compost Tea', '(R)', 'Spell', 'As an additional cost to play this, use two Garbage.\n\nGain 5 HP.', '',
     'Smells like a landfill. Tastes like a second chance.', 'A dented tin mug of dark steaming tea brewed from a bucket of compost, a raccoon in an apron pouring it with great ceremony, flies politely waiting.',
     'cards_refusemancer.txt', 'playcost | use(garbage,2)\nplay => gain(me,5)', 'R-10'),
    ('G-36', 'G-35', '36', '(C)', 'Bone Broth Cook', '2(G)', 'Unit', 'Nourish.\n\nWhen this unit enters, create an Ingredient.', '1/3',
     'Simmered for three days. Do not ask whose bones.', 'A cheerful round cook stirring a huge copper pot of golden broth over a fire, ladle raised, a bundle of herbs tucked behind one ear.',
     'cards_gourmand.txt', 'kw nourish\nenter => create(ingredient)', 'G-06'),
    ('C-41', 'C-40', '41', '(C)', 'Field Bandages', '1', 'Tool', 'Destroy this Tool: gain 3 HP and draw a card.', '',
     'Wrap, tie, keep walking.', 'A travel-worn roll of linen bandages and a small tin of salve on a mossy stone, a satchel strap and a road map half visible behind.',
     'cards_colorless.txt', 'act | destroy_self => gain(me,3); draw(1)', 'C-12'),
]


def script_path(name):
    return os.path.join(ROOT, 'data', 'scripts', name)


def edit_script(name, old, new):
    path = script_path(name)
    text = io.open(path, encoding='utf-8', newline='').read()
    crlf = '\r\n' in text
    body = text.replace('\r\n', '\n')
    if new in body:
        return 0
    if old not in body:
        raise SystemExit('not found in %s: %r' % (name, old))
    body = body.replace(old, new, 1)
    io.open(path, 'w', encoding='utf-8', newline='').write(body.replace('\n', '\r\n') if crlf else body)
    return 1


def add_script(name, card_id, card_name, after_id, script):
    path = script_path(name)
    text = io.open(path, encoding='utf-8', newline='').read()
    crlf = '\r\n' in text
    body = text.replace('\r\n', '\n')
    if ('== %s ' % card_id) in body:
        return 0
    block = '== %s @000000000000  # %s\n%s\n\n' % (card_id, card_name, script)
    marker = '== %s ' % after_id
    start = body.find(marker)
    if start < 0:
        body = body.rstrip('\n') + '\n\n' + block
    else:
        nxt = body.find('\n== ', start + 3)
        body = body[:nxt + 1] + block + body[nxt + 1:] if nxt >= 0 else body.rstrip('\n') + '\n\n' + block
    io.open(path, 'w', encoding='utf-8', newline='').write(body.replace('\n', '\r\n') if crlf else body)
    return 1


def main():
    rows = list(csv.reader(io.open(SHEET, encoding='utf-8-sig', newline='')))
    changed = 0
    by_id = {r[14]: r for r in rows if len(r) > 14 and r[14]}
    for cid, spec in REWORKS.items():
        row = by_id[cid]
        if spec is None:
            new_text, old_script, new_script, file_name = NEW_TEXT[cid]
            if row[5] != new_text:
                row[5] = new_text
                changed += 1
            changed += edit_script(file_name, old_script, new_script)
            continue
        old_text, new_text, old_script, new_script, file_name = spec
        if row[5] == old_text:
            row[5] = new_text
            changed += 1
        elif row[5] != new_text:
            raise SystemExit('%s text is neither old nor new: %r' % (cid, row[5]))
        changed += edit_script(file_name, old_script, new_script)
    for (cid, after, number, rarity, name, cost, kind, text, stats, flavor, art, file_name, script, art_from) in NEW:
        if cid not in by_id:
            new_row = [number, rarity, name, cost, kind, text, stats, flavor, art, 'Nov 25 night (Part F: health for every Path); temporary art', '', '', '', 'AI-new', cid]
            index = next(i for i, r in enumerate(rows) if len(r) > 14 and r[14] == after)
            rows.insert(index + 1, new_row)
            by_id[cid] = new_row
            changed += 1
        changed += add_script(file_name, cid, name, after, script)
        target = os.path.join(ART, cid + '.webp')
        if not os.path.exists(target):
            shutil.copyfile(os.path.join(ART, art_from + '.webp'), target)
            changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(rows)
    io.open(SHEET, 'w', encoding='utf-8', newline='').write(out.getvalue())
    # the art rows
    art_rows = list(csv.reader(io.open(BATCH22, encoding='utf-8', newline='')))
    have = {r[0] for r in art_rows if r}
    for (cid, after, number, rarity, name, cost, kind, text, stats, flavor, art, file_name, script, art_from) in NEW:
        if cid in have:
            continue
        art_rows.append([cid, 'Card art: %s (%s %s)' % (name, rarity.strip('()'), kind), 'Approved_Cards/%s.png' % cid, '1024x1536 PNG',
                         'The card %s (%s, %s): every card face' % (name, cid, cost), 'temporary: the art of %s, copied' % art_from, 'Needed',
                         art, 'Card style as the rest of the set; %s for the temporary art' % art_from])
        changed += 1
    out = io.StringIO()
    csv.writer(out, lineterminator='\n').writerows(art_rows)
    io.open(BATCH22, 'w', encoding='utf-8', newline='').write(out.getvalue())
    print('changed %d' % changed)


if __name__ == '__main__':
    main()
