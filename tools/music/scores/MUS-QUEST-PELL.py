"""MUS-QUEST-PELL - Widow Pell, a burial permit (Capital Path quest conclusion, Necrocrat). One-shot, 24 bars 3/4, 72 BPM, Ab major,
~66 s with the ring-out.
Human cost underneath the joke. The D.N.A. waltz theme, gently in major (the department's tune finally doing its job for someone), on a
subdued organ and then the cello; a piano keeps a soft waltz step; a bassoon adds one tired, kindly wink (a stamp that finally lands). The
Crossroads motif's head in the piano. Warm grief that moves toward rest: a plagal Db -> Ab close, held.
"""
from lib import Score, p, voice, motif_head, transpose
from lib.zones import DNA_THEME, to_mode
from scores._fork_b import MAJ_FROM_CMIN, held

THEME_AB = transpose(to_mode(DNA_THEME, MAJ_FROM_CMIN), -4)       # 16 waltz bars in Ab major
PROG = ['Ab', 'Ab', 'Db', 'Db', 'Eb7', 'Eb7', 'Ab', 'Fm', 'Db', 'Bbm7', 'Ab/Eb', 'Eb7', 'Ab', 'Fm', 'Eb7', 'Ab']


def build():
    s = Score('MUS-QUEST-PELL', bpm=72, bars=24, meter=(3, 4), key='Ab major', seed=1821, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'vc', 'cb', 'pad', 'bsn', 'cl', piano={'vol': 80}, vc={'vol': 92}, pad={'vol': 60})
    s.channel('organ', 'organ', pan=58, reverb=110, vol=62)
    for bar, nm in ((0, 'organ'), (8, 'cello'), (16, 'toward rest'), (20, 'held')):
        s.section(bar, nm)
    s.notes.append('D.N.A. theme in major (to_mode), waltz kept; a single bassoon wink at bar 12.')

    def step(bar, sym, vel=44):
        s.note('piano', bar * 3, 1, p(s.voicing(sym)[0]) + 12, vel + 4)
        for off in (1, 2):
            for t in voice(sym, 'Ab3', 3):
                s.note('piano', bar * 3 + off, .7, t, vel - 8)

    # 0-7: organ on the first half of the theme; starts instantly with the first chord
    for i in range(8):
        step(i, PROG[i])
        s.note('cb', i * 3, 3.02, p(s.voicing(PROG[i])[0]), 40)
    s.mel('organ', 0, THEME_AB[:20], 66)

    # 8-15: the cello takes the second half, the organ holds chords
    for i in range(8):
        bar = 8 + i
        step(bar, PROG[8 + i], 42)
        s.pad('organ', bar, PROG[8 + i], 40, low='Ab3', n=3)
        s.note('cb', bar * 3, 3.02, p(s.voicing(PROG[8 + i])[0]), 42)
    s.mel('vc', 8, transpose(THEME_AB[20:], -12), 80)
    s.line('bsn', 12, [('Eb3', .5), ('Eb3', .5), ('r', 2)], 58)          # the wink: a stamp that finally lands
    s.motif('piano', 14, motif_head('Ab5', 'major', rhythm=(1, .5, 1.5)), 50, form='head (piano), gentle', lead=False)

    # 16-19: toward rest - Db -> Ab, the clarinet's soft answer
    for i, sym in enumerate(['Db', 'Bbm7', 'Db', 'Eb7sus4']):
        step(16 + i, sym, 40)
        s.pad('pad', 16 + i, sym, 40)
        s.note('cb', (16 + i) * 3, 3.02, p(s.voicing(sym)[0]), 40)
    s.mel('cl', 16, [('F5', 2), ('Eb5', 1), ('Db5', 3), ('C5', 2), ('Bb4', 1), ('Bb4', 3)], 66)

    # 20-23: plagal close, held
    held(s, 20, 'Db', 3, 46, ['pad'], low='Ab3')
    held(s, 21, 'Ab', 9, 48, ['pad', 'organ'], low='Ab3', n=3)
    s.note('cb', 60, 3, p('Db2'), 42)
    s.note('cb', 63, 9, p('Ab1'), 42)
    s.mel('vc', 20, [('F3', 3), ('Eb3', 9)], 62)
    s.note('piano', 63, 9, p('C5'), 44)
    return s
