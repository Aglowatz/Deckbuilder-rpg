"""Fable Nov 22 night, Part 1: writes the play script that shoots Auntie Alembic's shop (open, two Paths chosen, brewing, brewed) for
a window `width` pixels wide (clicks are in window pixels).  python tools/nov22_alembic_script.py 1280 > script.txt"""
import sys

width = float(sys.argv[1]) if len(sys.argv) > 1 else 1600.0
k = width / 1600.0
HEAD = """# Fable Nov 22 night, Part 1: Auntie Alembic's shop with the Batch 19 jar and brewing scene
wait 3
dev newgame
wait 10
skip_dialogue
dev level 18
dev gold 6000
dev flag trial_cleared
dev flag elder_greeted
dev flag maren_met
dev flag armory_unlocked
dev gate beefcake
dev gate gourmand
dev gate refusemancer
dev gate necrocrat
dev essence Beefcake 18
dev essence Necrocrat 13
dev essence Gourmand 7
dev essence Refusemancer 2
wait 1
dev freed beefcake
dev freed gourmand
dev travel town
wait 10
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
button Continue
wait 1
button Continue
wait 1
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
button Continue
wait 1
button Continue
wait 1
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
key E
wait 0.4
button Continue
wait 1
button Continue
wait 1
dev goto alchemist
wait 1
key E
wait 3
button Brew now
wait 2
skip_dialogue 30
wait 3
button Brew now
wait 3
"""
print(HEAD + 'shot shop_open')
print('click %d %d\nwait 1\nclick %d %d\nwait 1\nmove %d %d\nwait 1\nshot two_paths' % (510 * k, 300 * k, 686 * k, 510 * k, 40 * k, 880 * k))
print('button Brew\nwait 0.9\nshot brewing\nwait 4\nshot brewed\nwait 1')
