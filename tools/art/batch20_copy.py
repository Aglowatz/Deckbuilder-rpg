"""Batch 20 (Fable big pass Nov 23, Part 1): copies the approved pictures of Pending Review/Batch 20 into their Approved folders
on the Drive (the Pending Review copies stay). A same-named file already in an Approved folder moves to Superseded/Batch 20
replaced/ first. The five mock-ups are designs to build from and are not copied. Idempotent.
    python tools/art/batch20_copy.py"""
import filecmp
import os
import shutil

DRIVE = 'G:/My Drive/Card Game Art'
SOURCE = DRIVE + '/Pending Review/Batch 20'
OLD = DRIVE + '/Superseded/Batch 20 replaced'
CARDS = {'DR-01': 'C-37', 'DR-02': 'C-38', 'DR-03': 'C-39', 'DR-04': 'B-38', 'DR-05': 'R-37', 'DR-06': 'GN-17', 'DR-07': 'P4-04', 'DR-08': 'C-40'}
PREFIX = [('BB-', 'Approved_Battleboards'), ('BST-', 'Approved_Bestiary'), ('CAP-', 'Approved_ZoneKits/Capital'), ('DR-', 'Approved'),
    ('ICON-', 'Approved_Icons'), ('MAP-', 'Approved_Maps'), ('NPC-', 'Approved_Characters'), ('SPR-', 'Approved_Sprites'),
    ('TOWN-', 'Approved_EnvKit'), ('UI-', 'Approved_UI'), ('VS-', 'Approved_VendorScreens')]


def main():
    copied, same, skipped, replaced = [], 0, [], []
    for name in sorted(os.listdir(SOURCE)):
        stem = os.path.splitext(name)[0]
        if 'MOCK' in stem or not name.lower().endswith('.png'):
            skipped.append(name)
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
    print('copied %d, already there %d, replaced %s, not copied %s' % (len(copied), same, replaced, skipped))
    for line in copied:
        print('  ' + line)


if __name__ == '__main__':
    main()
