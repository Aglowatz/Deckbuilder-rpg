"""Fable Nov 24: the lines this pass rewrote in data/dungeons/dungeon_content.json's `text` (Octavia Eightfold presents the four
modes; Trey Pickett points at the house's new spot). Idempotent. The record for --revert (docs/dialogue/nov24_lines.csv and
nov24_lines_ids.txt) is written by tools/nov24_dialogue_record.py from the difference to the start tag.
    python tools/nov24_dialogue.py"""
import io
import json
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
PATH = os.path.join(ROOT, 'data', 'dungeons', 'dungeon_content.json')

LINES = {
    'drafthouse.intro': [
        "DARLING! Welcome, welcome, welcome to the Shuffle House, where the lights are bright, the cards are fresh, and the house always DEALS! Octavia Eightfold. Showwoman, dealer, proprietor, and aunt to a very loud shark.",
        "My Trey taught you to pick one of three? Sweetie, I taught HIM. Tonight's bill is FOUR games! Classic: you choose your Paths, I choose your trouble. Dungeon Draft: a borrowed deck in a dungeon you already know. Mystery Mini: the wheel decides, and nobody argues with the wheel. And High Rollers, for people with gold and no sense whatsoever!",
        "And behind the stage, through a door all of its own: the Shuffled Halls. Everyone who is anyone has been lost in there at least once. On the one arm, glory. On the other seven, also glory! Now, what will it be? Don't be shy, darling, I have hands to spare.",
    ],
    'drafthouse.return': [
        "Places, everyone! That means you, darling, you're the everyone. Four games on the bill, one door behind the stage, and I have eight arms and nothing to do with six of them. What are we playing?",
    ],
    'drafthouse.mainquest_done': [
        "You went in! You came out! Applause, applause, eight hands of it! Whatever happened in there, darling, it happened with STYLE. The halls are yours whenever you want them, and so are my four games. Beat the halls properly one day, and we shall talk about a very special card.",
    ],
}


def main():
    text = io.open(PATH, encoding='utf-8', newline='').read()
    newline = '\r\n' if '\r\n' in text else '\n'
    data = json.loads(text)
    changed = 0
    for key, lines in LINES.items():
        if data['text'].get(key) != lines:
            data['text'][key] = lines
            changed += 1
    out = json.dumps(data, indent='\t', ensure_ascii=False)
    io.open(PATH, 'w', encoding='utf-8', newline='').write(out.replace('\n', newline) + (newline if text.endswith('\n') else ''))
    print('dialogue keys rewritten: %d' % changed)


if __name__ == '__main__':
    main()
