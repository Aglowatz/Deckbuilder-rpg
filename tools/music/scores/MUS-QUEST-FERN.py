"""MUS-QUEST-FERN - Old Fern, untidy (Capital Path quest conclusion, Refusemancer). One-shot, 40 bars 6/8 (q = 132, dotted q = 88),
E Dorian -> E major, ~59 s with the ring-out.
Human cost underneath the joke. Scrappy folk strings (a solo violin) and a gentle flute play the Dump jig, slowed to a walking 6/8,
against a clipped regulation pulse - staccato pizzicato and a dry click on every dotted beat, exactly on the grid. At bar 24 the pulse
gives up; harp and warm strings grow underneath, and the jig turns to E major (things are allowed to grow). The Crossroads motif's head in
the flute; an earthy, warm E major close.
"""
from lib import Score, p, voice, motif_head, transpose
from lib.zones import DUMP_JIG_1, DUMP_JIG_2, DUMP_PROG, DUMP_CHORDS, to_mode
from scores._fork_b import MAJ_FROM_EDOR, held


def build():
    s = Score('MUS-QUEST-FERN', bpm=132, bars=40, meter=(6, 8), key='E major', seed=1824, kind='oneshot')
    s.lufs = -20.0
    s.seat('fl', 'pad', 'vc', 'cb', 'pizz', 'harp', 'perc', 'vln', 'cel')
    s.channel('fid', 'violin', pan=30, reverb=85, vol=88)
    s.V.update(DUMP_CHORDS)
    s.V.update({'E': ('E2', ['E3', 'B3', 'E4', 'G#4']), 'B': ('B1', ['F#3', 'B3', 'D#4', 'F#4'])})
    for bar, nm in ((0, 'regulation pulse'), (8, 'flute'), (16, 'pulse tightens'), (24, 'growth'), (36, 'warm close')):
        s.section(bar, nm)
    s.notes.append('Regulation pulse quantised (human=False) until bar 24; the jig turns to E major from bar 24.')

    def pulse(bar, sym, vel=50):
        b = p(s.voicing(sym)[0]) + 12
        for k in (0, 1.5):
            s.note('pizz', bar * 3 + k, .2, b, vel, human=False)
            s.note('perc', bar * 3 + k, .08, 33, vel - 6, human=False)

    # 0-23: the jig (E Dorian) vs the clipped pulse
    for i in range(24):
        sym = DUMP_PROG[i % 16]
        pulse(i, sym, 52 if i < 16 else 56)
        s.note('cb', i * 3, 3.02, p(s.voicing(sym)[0]), 42)
        if i >= 8:
            s.pad('pad', i, sym, 34)
    s.mel('fid', 0, DUMP_JIG_1, 82)
    s.mel('fl', 8, DUMP_JIG_2, 70)
    s.line('fid', 8, transpose(DUMP_JIG_2, -12), 56)
    s.motif('fl', 16, motif_head('E5', 'dorian', rhythm=(1.5, .5, 1)) + [('r', 3)], 66, form='head (flute)')
    s.mel('fid', 18, DUMP_JIG_1[:30], 78)

    # 24-35: growth - the pulse gives up, harp and strings, the jig in E major
    MP = ['E', 'D', 'E', 'A', 'E', 'D', 'B', 'A', 'E', 'A', 'B', 'E']
    for i, sym in enumerate(MP):
        bar = 24 + i
        s.pad('pad', bar, sym, 48)
        s.harp(bar, sym, 44)
        s.note('cb', bar * 3, 3.02, p(s.voicing(sym)[0]), 46)
    s.mel('fid', 24, to_mode(DUMP_JIG_1, MAJ_FROM_EDOR), 84)
    s.line('fl', 28, to_mode(DUMP_JIG_2[:24], MAJ_FROM_EDOR), 60, transpose=12)
    s.line('vc', 24, [('G#3', 6), ('F#3', 6), ('E3', 6), ('A3', 6)], 52)
    s.swell('pad', 24, 12, 80, 104)

    # 36-39: warm close on E
    held(s, 36, 'E', 12, 54, ['pad', 'vln'], low='E3')
    s.harp(36, 'E', 46, density=16)
    s.note('cb', 108, 12, p('E2'), 46)
    s.mel('cel', 36, [('B5', 1.5), ('E6', 1.5), ('G#6', 6)], 50)
    return s
