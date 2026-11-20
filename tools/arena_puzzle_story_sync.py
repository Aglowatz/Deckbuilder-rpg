"""Fable Nov 20 (Part 7): copies each Arena puzzle's title and brief from data/arena/arena_puzzles.json into the story file's old
keys (arena.<id>.title / .blurb / .rules in data/story/intro_story.tres), so the dialogue exports show the puzzles as they are. The
game itself reads the puzzle file (ArenaEncounter.title() / blurb() / rules()).   python tools/arena_puzzle_story_sync.py"""
import json, os, re

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
RULES = "PUZZLE: win THIS turn. Everything you need is on the table. If the turn ends and your opponent still stands, you lose."
BACKSLASH = chr(92)
QUOTE = chr(34)


def escaped(text):
    return text.replace(BACKSLASH, BACKSLASH * 2).replace(QUOTE, BACKSLASH + QUOTE)


if __name__ == '__main__':
    puzzles = json.load(open(os.path.join(ROOT, 'data', 'arena', 'arena_puzzles.json'), encoding='utf-8'))['puzzles']
    path = os.path.join(ROOT, 'data', 'story', 'intro_story.tres')
    text = open(path, encoding='utf-8', newline='').read()
    changed = 0
    for puzzle_id, row in puzzles.items():
        for key, value in [('title', row['title']), ('blurb', row['brief']), ('rules', RULES)]:
            pattern = re.compile('(%sarena.%s.%s%s: [[]%s)(.*?)(%s[]],?\r?\n)' % (QUOTE, re.escape(puzzle_id), key, QUOTE, QUOTE, QUOTE))
            match = pattern.search(text)
            assert match, (puzzle_id, key)
            text = text[:match.start()] + match.group(1) + escaped(value) + match.group(3) + text[match.end():]
            changed += 1
    open(path, 'w', encoding='utf-8', newline='').write(text)
    print('%d story lines written' % changed)
