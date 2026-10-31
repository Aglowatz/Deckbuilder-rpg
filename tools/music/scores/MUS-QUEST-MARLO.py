"""MUS-QUEST-MARLO - Chef Marlo, the recipe box (Capital Path quest conclusion, Gourmand). One-shot, 22 bars 4/4, 80 BPM, F major,
~70 s with the ring-out.
Human cost underneath the joke. The Buffet welcome tune, slowed and warm, on clarinet and piano - struggling against a uniform mechanical
accompaniment (harpsichord eighths and a woodblock, exactly on the grid, the Capital's kitchen). At bar 10 he remembers a real recipe: the
machine stops, a human pizzicato bounce and warm strings come in, the oboe sings the tune's second phrase with real flavour, and the
Crossroads motif's head turns up in the flute. Ends on a full, warm F chord.
"""
from lib import Score, p, voice, motif_head, transpose
from lib.zones import BUFFET_THEME
from scores._fork_b import scale, held

SLOW = BUFFET_THEME[:40]          # bars 1-8 of the welcome tune


def build():
    s = Score('MUS-QUEST-MARLO', bpm=80, bars=22, key='F major', seed=1823, kind='oneshot')
    s.lufs = -20.0
    s.seat('cl', 'ob', 'fl', 'piano', 'pad', 'vc', 'cb', 'pizz', 'harp', 'perc', 'vln')
    s.channel('hpsd', 'harpsichord', pan=70, reverb=70, vol=64)
    for bar, nm in ((0, 'the machine kitchen'), (10, 'a real recipe'), (18, 'flavour')):
        s.section(bar, nm)
    s.notes.append('Mechanical accompaniment quantised (human=False notes) under a human tune; the machine stops at bar 10.')
    H1 = ['F', 'Dm', 'Gm7', 'C7', 'F', 'D7', 'Gm', 'C7', 'Bb', 'C7']

    # 0-9: the tune vs the machine
    for i, sym in enumerate(H1):
        tn = voice(sym, 'F3', 3)
        for k in range(8):
            s.note('hpsd', i * 4 + k * .5, .3, tn[k % 3], 48, human=False)
        for k in range(4):
            s.note('perc', i * 4 + k, .1, 77, 40, human=False)
        s.note('cb', i * 4, 4.02, p(s.voicing(sym)[0]), 44)
    s.mel('cl', 0, transpose(SLOW[:21], -12), 78)
    s.line('piano', 4, transpose(SLOW[11:21], -12), 50)
    s.mel('cl', 5, transpose(SLOW[21:30], -12), 74)

    # 10-17: the recipe - human bounce, warm strings, the oboe with real flavour
    H2 = ['Bb', 'Bbm', 'F/A', 'D7', 'Gm7', 'C7', 'F', 'C7']
    for i, sym in enumerate(H2):
        bar = 10 + i
        s.pizz(bar, sym, 52)
        s.pad('pad', bar, sym, 50)
        s.harp(bar, sym, 42)
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 50)
    s.mel('ob', 10, SLOW[21:40] + [('F5', 2), ('A5', 2), ('C6', 4)], 80)
    s.line('vc', 10, [('D4', 4), ('Db4', 4), ('C4', 4), ('C4', 4), ('Bb3', 4), ('Bb3', 4), ('A3', 4), ('G3', 4)], 56)
    s.motif('fl', 14, motif_head('F5', 'major', rhythm=(1, .5, 1.5)), 60, form='head (flute)', lead=False)
    s.swell('pad', 10, 8, 80, 104, 'arch')

    # 18-21: flavour - the full warm F chord
    held(s, 18, 'F', 14, 54, ['pad', 'vln'], low='F3')
    s.harp(18, 'F', 48, density=16)
    s.note('cb', 72, 14, p('F2'), 48)
    s.mel('cl', 18, [('C5', 1), ('A4', .5), ('C5', .5), ('F5', 6)], 66)
    return s
