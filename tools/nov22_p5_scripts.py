"""Fable Nov 22 night, Part 5: writes the play scripts of the focused playthrough into docs/review/play_scripts/nov22/ (window 1600x900).
    python tools/nov22_p5_scripts.py
Each script starts a late game (level 22, the four zones freed), walks a prefix of a castle route by decree (`dev travel route`) and
then enters the next room for real, with a click on its painted landing spot: the scene before, the fight (the built-in pilot plays a
while, then it is won by decree), the scene after and whatever the room gives.
    p5_a1 the Gilded Pantry: the Grand Chef, the Pantry Mimic, the hoard          p5_a2 the Beefcake wing: Grandmaster Flex
    p5_a3 the Necrocrat wing: Agnes, then the Archivists' Kettle (the new heal)   p5_a4 the Refusemancer wing: Compostella
    p5_a5 the all-allies route to Primm with four leaders                        p5_b  the quiet south to Primm with nobody
    p5_c  the middle road: the Safe Room, then the Royal Stair"""
import os

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
OUT = os.path.join(ROOT, 'docs', 'review', 'play_scripts', 'nov22')
# room number -> (x, y) of its landing spot as a fraction of the painting (data/dungeons/map_layout.json, D-PC)
SPOT = {2: (0.183, 0.287), 3: (0.178, 0.635), 5: (0.303, 0.442), 6: (0.307, 0.651), 7: (0.305, 0.844), 8: (0.433, 0.264), 9: (0.426, 0.468),
        10: (0.433, 0.666), 11: (0.561, 0.263), 12: (0.556, 0.474), 13: (0.555, 0.669), 14: (0.686, 0.235), 16: (0.686, 0.650),
        17: (0.677, 0.846), 18: (0.808, 0.234), 19: (0.811, 0.451), 21: (0.810, 0.853), 22: (0.948, 0.488)}

START = """wait 6
dev newgame
wait 9
skip_dialogue 40
dev level 22
dev gold 400
dev freed beefcake
dev freed gourmand
dev freed necrocrat
dev freed refusemancer
"""


def click(room):
    x, y = SPOT[room]
    return 'click %d %d' % (125 + x * 1350, y * 900)


def travel(prefix):
    rooms = ','.join(str(r) for r in prefix)
    line = 'dev travel route D-PC %s' % rooms if prefix else 'dev travel dungeon D-PC'
    # the Archivists' Kettle opens after room 11, by decree too: walk on
    kettle = 'button Leave the kettle\nwait 2\nskip_dialogue 10\nbutton Continue\nwait 2\n' if 11 in prefix else ''
    return '%s\nwait 8\nskip_dialogue 30\nwait 1\nbutton Got it\nwait 1\nskip_dialogue 10\n%smove 40 880\nwait 1\n' % (line, kettle)


def fight(room, name, pilot=25):
    """Enter `room` for real: the scene before, the brief, the fight, then won by decree; the scene after."""
    lines = [click(room), 'wait 3', 'shot %s_1_before' % name, 'skip_dialogue 60', 'wait 2', 'shot %s_2_brief' % name, 'button Continue', 'wait 4',
             'skip_dialogue 80', 'wait 6', 'skip_dialogue 40', 'button Keep', 'wait 5', 'button Got it', 'wait 1', 'shot %s_3_fight' % name]
    if pilot > 0:
        lines += ['pilot %d' % pilot, 'shot %s_4_fight_later' % name]
    lines += ['click 1180 520', 'wait 1', 'dev win', 'wait 2', 'click 1180 520', 'wait 4', 'shot %s_4b_won' % name, 'button Continue', 'wait 3', 'shot %s_4c_reward' % name, 'button Skip card', 'wait 3', 'button Continue', 'wait 3', 'button Continue', 'wait 3',
              'shot %s_5_after' % name, 'skip_dialogue 60', 'wait 2', 'shot %s_6_then' % name, 'dump']
    return '\n'.join(lines) + '\n'


def write(name, title, body):
    with open(os.path.join(OUT, name + '.txt'), 'w', encoding='utf-8', newline='\n') as handle:
        handle.write('# Fable Nov 22 night, Part 5: %s\n' % title + START + body)


def main():
    os.makedirs(OUT, exist_ok=True)
    write('p5_a1', 'the Gilded Pantry - the Grand Chef, the Pantry Mimic, the hoard',
          travel([]) + 'shot a1_0_gate\n' + fight(2, 'a1', 8) + 'button second helping\nwait 3\nshot a1_7_hoard_taken\nskip_dialogue 10\nbutton Continue\nwait 2\nshot a1_8_map\n')
    write('p5_a2', 'the Beefcake wing - Grandmaster Flex and the Captured Trainees', travel([2, 5]) + 'shot a2_0_map\n' + fight(8, 'a2', 8) + 'button Continue\nwait 2\nshot a2_7_map\n')
    write('p5_a3', "the Necrocrat wing - Agnes, then the Archivists' Kettle (heal 6 for a cost)",
          travel([2, 5, 8]) + 'dev hp 9\nmove %d %d\nwait 2\nshot a3_0_tooltip\nmove 40 880\n' % (125 + SPOT[11][0] * 1350, SPOT[11][1] * 900) + fight(11, 'a3', 3)
          + 'shot a3_7_kettle\nbutton Pay the honesty\nwait 3\nshot a3_8_kettle_paid\nskip_dialogue 10\nbutton Continue\nwait 2\nscene\nshot a3_9_map\n')
    write('p5_a4', 'the Refusemancer wing - Compostella and the Spotless Statues', travel([2, 5, 8, 11]) + 'shot a4_0_map\n' + fight(14, 'a4', 8) + 'button Continue\nwait 2\nshot a4_7_map\n')
    write('p5_a5', 'the all-allies route to Primm, four leaders at your side',
          travel([2, 5, 8, 11, 14, 18]) + 'move %d %d\nwait 2\nshot a5_0_primm_tooltip\nmove 40 880\n' % (125 + SPOT[22][0] * 1350, SPOT[22][1] * 900)
          + click(22) + '\nwait 3\nskip_dialogue 60\nwait 2\nshot a5_1_brief\nbutton Continue\nwait 4\nskip_dialogue 80\nwait 6\nskip_dialogue 40\nbutton Keep\nwait 5\nshot a5_2_fight\n'
          + 'pilot 60\nshot a5_3_turns_later\npilot 90\nshot a5_4_later\ndump\n')
    write('p5_b', 'the quiet south to Primm, nobody at your side',
          travel([3, 7, 10, 13, 17, 21]) + 'shot b_0_map\n' + click(22) + '\nwait 3\nskip_dialogue 60\nwait 2\nshot b_1_brief\nbutton Continue\nwait 4\nskip_dialogue 80\nwait 6\n'
          + 'skip_dialogue 40\nbutton Keep\nwait 5\nshot b_2_fight\npilot 60\nshot b_3_turns_later\npilot 90\nshot b_4_later\ndump\n')
    write('p5_c', 'the middle road - the Safe Room, then the Royal Stair',
          travel([3, 6, 9, 12]) + 'dev hp 7\nshot c_0_map\n' + click(16) + '\nwait 3\nshot c_1_safe_room\nskip_dialogue 30\nbutton Continue\nwait 2\nbutton Rest\nwait 2\nskip_dialogue 20\n'
          + 'button Continue\nwait 2\nscene\nshot c_2_after_rest\n' + fight(19, 'c', 8) + 'button Continue\nwait 2\nshot c_7_map\n')
    print('7 scripts in', os.path.relpath(OUT, ROOT))


if __name__ == '__main__':
    main()
