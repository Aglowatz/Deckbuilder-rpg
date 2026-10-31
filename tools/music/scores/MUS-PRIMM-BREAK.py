"""MUS-PRIMM-BREAK - Rules between duels (Primm's boss dialogue). Loop, 20 bars 4/4, 60 BPM, C major, quantised, 80 s.
Sparse: the Primm motif on a slowed music box (every note a half note), a clockwork tick on each beat, suspended strings that hold their
chord a little too long. The harmony grows quietly unstable on the second pass (C -> Fm/C -> Ab/C -> Db/C over the same pedal), the
music box keeps its even pulse regardless. The Crossroads motif's head once in a low cello, under the dialogue, and let go. Low and clear
for reading; the last bars hang on a suspended chord that leads straight back to the start (or into the next phase).
"""
from lib import Score, p, voice, motif_head, PRIMM_HEAD, PRIMM_ANSWER
from lib.capital import QUANTISED
from scores._fork_b import scale

PRIMM_SLOW = scale(PRIMM_HEAD + PRIMM_ANSWER, 2)          # 32 beats = 8 bars
H1 = ['Csus2', 'C', 'Fmaj7/C', 'Gsus4', 'Csus2', 'Fmaj7/C', 'Dm7', 'Gsus4']
H2 = ['Csus2', 'Fm/C', 'Ab/C', 'Gsus4', 'Db/C', 'Fm/C', 'Dm7', 'Gsus4']


def build():
    s = Score('MUS-PRIMM-BREAK', bpm=60, bars=20, key='C major', seed=1640, human=QUANTISED)
    s.seat('pad', 'vc', 'cb', 'perc', pad={'vol': 74})
    s.channel('mbox', 'music_box', pan=44, reverb=100, vol=84)
    s.channel('glass', 'bowed_glass', pan=64, reverb=110, vol=44)
    s.V.update({'Fmaj7/C': ('C2', ['C3', 'E3', 'A3', 'F4']), 'Fm/C': ('C2', ['C3', 'F3', 'Ab3', 'C4']),
                'Ab/C': ('C2', ['C3', 'Eb3', 'Ab3', 'C4']), 'Db/C': ('C2', ['Db3', 'F3', 'Ab3', 'C4']),
                'Csus2': ('C2', ['C3', 'G3', 'D4', 'G4']), 'Gsus4': ('G1', ['D3', 'G3', 'C4', 'D4'])})
    for bar, nm in ((0, 'tick'), (2, 'A music box'), (10, 'B unstable'), (18, 'hold')):
        s.section(bar, nm)
    s.notes.append('Quantised, sparse for dialogue; the Primm motif in half notes on the music box.')

    def tick(bar, vel=34):
        for k in range(4):
            s.note('perc', bar * 4 + k, .1, 76 if k == 0 else 77, vel + (6 if k == 0 else 0), human=False)

    def ground(bar, sym, vel=46):
        s.pad('pad', bar, sym, vel, beats=4.2)
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 4, 4.02, b, vel - 4)

    for i, sym in enumerate(['Csus2', 'Gsus4']):
        ground(i, sym)
        tick(i)
    s.pad('glass', 0, 'Csus2', 40, beats=8)
    s.mel('mbox', 0, [('G5', 2), ('C6', 2), ('D6', 4)], 66)

    for i, sym in enumerate(H1):
        ground(2 + i, sym)
        tick(2 + i)
    s.mel('mbox', 2, PRIMM_SLOW, 74, transpose=12)
    s.motif('vc', 6, motif_head('C3', 'major', rhythm=(2, 1, 1)) + [('r', 4)], 48, form='head (low cello), let go', lead=False)

    for i, sym in enumerate(H2):
        ground(10 + i, sym, 48)
        tick(10 + i, 30 + i)
        if i % 4 == 0:
            s.pad('glass', 10 + i, sym, 42, beats=16)
    s.mel('mbox', 10, [(p(n) + 12 + (1 if i in (5, 13) else 0), d) for i, (n, d) in enumerate(PRIMM_SLOW)], 72)
    s.swell('pad', 10, 8, 80, 100, 'arch')

    for i, sym in enumerate(['Csus2', 'Gsus4']):
        ground(18 + i, sym, 54)
        tick(18 + i, 38)
    s.pad('glass', 18, 'Csus2', 46, beats=8)
    s.mel('mbox', 18, [('G5', 2), ('C6', 2), ('D6', 2), ('B5', 2)], 72)
    return s
