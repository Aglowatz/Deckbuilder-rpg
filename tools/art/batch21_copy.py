"""Batch 21 (Fable Nov 25, Part 1): copies the 29 approved pictures of Pending Review/Batch 21 into their Approved folders on
the Drive (the Pending Review copies stay). A same-named file already in an Approved folder moves to Superseded/Batch 21
replaced/ first. Idempotent.
    python tools/art/batch21_copy.py"""
import filecmp
import os
import shutil

DRIVE = 'G:/My Drive/Card Game Art'
SOURCE = DRIVE + '/Pending Review/Batch 21'
OLD = DRIVE + '/Superseded/Batch 21 replaced'
# DR-06 is the Table Captain's card (GN-17); NB-17 is the Iron Filing Clerk's own id
CARDS = {'DR-06': 'GN-17'}
PREFIX = [('BST-', 'Approved_Bestiary'), ('DR-', 'Approved'), ('NB-', 'Approved'), ('TOK-', 'Approved'), ('MAP-', 'Approved_Maps'),
    ('SPR-', 'Approved_Sprites'), ('UI-', 'Approved_UI'), ('SH-', 'Approved_EnvKit')]


def main():
    copied, same, replaced = [], 0, []
    for name in sorted(os.listdir(SOURCE)):
        stem = os.path.splitext(name)[0]
        if not name.lower().endswith('.png'):
            continue
        folder = next(folder for prefix, folder in PREFIX if stem.startswith(prefix))
        target_name = (CARDS[stem] + '.png') if stem in CARDS else name
        target = '%s/%s/%s' % (DRIVE, folder, target_name)
        source = SOURCE + '/' + name
        if os.path.exists(target):
            if filecmp.cmp(source, target, shallow=False):
                same += 1
                continue
            os.makedirs(OLD, exist_ok=True)
            shutil.move(target, OLD + '/' + target_name)
            replaced.append(target_name)
        shutil.copy2(source, target)
        copied.append('%s -> %s/%s' % (name, folder, target_name))
    print('copied %d, already there %d, replaced %s' % (len(copied), same, replaced))
    for line in copied:
        print('  ' + line)


if __name__ == '__main__':
    main()
