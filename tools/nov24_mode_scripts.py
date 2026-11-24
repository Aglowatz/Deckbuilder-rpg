"""Fable Nov 24 (Part 7.2): writes the play scripts of the four Shuffle House modes (docs/review/play_scripts/nov24/mode_*.txt).
Each one starts a fresh game with three zones free, opens the house, chooses the mode with real clicks, drafts with the Take
buttons, and plays the run through with the fights booked as won (`dev win`), up to the result pop-up.
    python tools/nov24_mode_scripts.py
    bash tools/play.sh docs/review/play_scripts/nov24/mode_classic.txt nov24_mode_classic 1500     (and _high, _mystery, _dungeon)"""
import io
import os

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
OUT = os.path.join(ROOT, 'docs', 'review', 'play_scripts', 'nov24')

HEAD = '''wait 6
dev newgame
wait 9
skip_dialogue 40
dev level 16
dev gold 2500
dev freed beefcake
dev freed gourmand
dev freed necrocrat
dev travel town
wait 16
skip_dialogue 20
''' + 'button Continue\nwait 1.5\n' * 8 + '''skip_dialogue 20
dev draft unlock
dev draft open
wait 3
'''
DRAFT = '''button Start
wait 3
shot %(tag)s_02_first_pick
''' + 'button Take\nwait 0.5\n' * 34 + '''wait 1
shot %(tag)s_03_deck
button Lock the deck
wait 3
shot %(tag)s_04_run_page
dump
'''
FIGHT = '''dev draft fight
wait 9
button Keep Hand
wait 2
shot %(tag)s_fight_%(n)d
dev win
wait 6
button Continue
wait 5
shot %(tag)s_after_fight_%(n)d
'''
ROOM = '''node Room_%(n)d
wait 2
button Continue
wait 2
skip_dialogue 12
wait 6
button Keep Hand
wait 1
dev win
wait 6
skip_dialogue 12
button Continue
wait 6
button Take nothing
wait 2
'''


def table(tag, mode, paths, words):
    text = '# Fable Nov 24 (Part 7.2): %s\n#   bash tools/play.sh docs/review/play_scripts/nov24/mode_%s.txt nov24_mode_%s 1500\n' % (words, tag, tag)
    text += HEAD + 'node Mode_%s\nwait 1\n' % mode
    for path in paths:
        text += 'node PathToggle_%d\nwait 1\n' % path
    text += 'shot %s_01_menu\n' % tag + DRAFT % {'tag': tag}
    for n in range(1, 4):
        text += FIGHT % {'tag': tag, 'n': n}
    # a full win: keep one card of the deck first (a click in the middle of the list), then the result pop-up
    text += 'wait 2\nmove 1700,1000\nwait 1\nshot %(tag)s_05_keep_a_card\nnode KeepGrid\nwait 3\nshot %(tag)s_06_result\ndump\nbutton Finish\nwait 3\nshot %(tag)s_07_after\n' % {'tag': tag}
    if mode == 'high':
        text = text.replace('button Start\n', 'button Pay 200 gold and start\n')
    return text


def dungeon(tag, mode, words, rooms):
    text = '# Fable Nov 24 (Part 7.2): %s\n#   bash tools/play.sh docs/review/play_scripts/nov24/mode_%s.txt nov24_mode_%s 1800\n' % (words, tag, tag)
    text += HEAD + 'node Mode_%s\nwait 1\nshot %s_01_menu\n' % (mode, tag) + DRAFT % {'tag': tag}
    text += 'button Enter\nwait 7\nbutton Got it\nwait 1\nshot %s_05_map\ndump\n' % tag
    for index, n in enumerate(rooms):
        text += ROOM % {'n': n}
        if index in (0, 2):
            text += 'shot %s_06_after_room_%d\n' % (tag, n)
    text += 'wait 3\nmove 1700,1000\nwait 1\nshot %(tag)s_07_end\ndump\nnode KeepGrid\nwait 3\nshot %(tag)s_08_result\ndump\nbutton Finish\nwait 3\n' % {'tag': tag}
    return text


def main():
    files = {
        'classic': table('classic', 'classic', [2], 'a Classic Draft with two Paths (the hero\'s own and a second one), three fights won, the result pop-up.'),
        'high': table('high', 'high', [], 'a High Rollers Draft: the fee, opponents in the best equipment, three fights won, the result pop-up.'),
        # a mini dungeon's rooms are numbered from 1 (its first room); rooms that are not next are simply not found or not clickable
        'mystery': dungeon('mystery', 'mystery', 'a Mystery Mini: a three-encounter dungeon the house picks, with the fights booked as won.', [1, 2, 3, 4]),
        'dungeon': dungeon('dungeon', 'dungeon', 'a Dungeon Draft of a freed zone\'s main dungeon (the first on the list), the first rooms.', [1, 2, 3, 4, 5, 6, 7, 8]),
    }
    for name, text in files.items():
        with io.open(os.path.join(OUT, 'mode_%s.txt' % name), 'w', encoding='utf-8', newline='\n') as handle:
            handle.write(text)
        print('mode_%s.txt: %d lines' % (name, text.count('\n')))


if __name__ == '__main__':
    main()
