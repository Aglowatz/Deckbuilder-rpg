"""Fable Nov 24 (Part 2): the draft feats follow the four modes. The separate two-, three- and four-Path tables and the
"win three" tables are gone; a Classic or High Rollers win with a set of Paths sets that set's flag (the old tables' flags), so
the triggers stay and only the words change - and "High Roller" also takes a win at the new High Rollers Draft. Idempotent.
    python tools/nov24_draft_feats.py"""
import io
import json
import os
import re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'data', 'feats', 'feats.json')
WORDS = {
    'draft_first': "Finish a draft at Trey Pickett's cart or the Shuffle House.",
    'draft_all_pairs': 'Win a Classic or High Rollers Draft with each of the six pairs of Paths.',
    'draft_high_roller': 'Win a High Rollers Draft at the Shuffle House.',
    'draft_every_table': 'Win a Classic or High Rollers Draft with every pair of Paths, every set of three, and all four.',
}


def main():
    text = io.open(PATH, encoding='utf-8', newline='').read()
    changed = 0
    for feat_id, words in WORDS.items():
        pattern = re.compile(r'(\{"id": "%s".*?"earned_by": )"((?:[^"\\]|\\.)*)"' % re.escape(feat_id))
        match = pattern.search(text)
        assert match, feat_id
        if json.loads('"%s"' % match.group(2)) != words:
            text = text[:match.start()] + match.group(1) + json.dumps(words, ensure_ascii=False) + text[match.end():]
            changed += 1
    old = '"any_of": ["draft_won:high:1", "draft_won:high:2", "draft_won:high:4"]'
    if old in text:
        text = text.replace(old, '"any_of": ["draft_won:high", "draft_won:high:1", "draft_won:high:2", "draft_won:high:4"]', 1)
        changed += 1
    json.loads(text)
    io.open(PATH, 'w', encoding='utf-8', newline='').write(text)
    print('draft feats updated: %d' % changed)


if __name__ == '__main__':
    main()
