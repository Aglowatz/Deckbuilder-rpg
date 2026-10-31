"""MUS-PRIMM-01 - Standardization (final boss phase 1). Loop, 68 bars 4/4, 128 BPM, C major, quantised (human feel OFF), ~127 s.
Everyone forced into one shape: the whole orchestra in unison and octaves on the Primm motif, machine-like. A clockwork piano and harpsichord
ticking 8ths, low strings on a C pedal, snare rudiments and timpani on the grid. The Capital theme in block brass, every Path's rhythm
compressed into the same even pulse - the Crossroads motif is forced into even quarters and swallowed by the unison each time it surfaces.
Imposing, sincere and coercive; no human slack anywhere.
"""
from lib import Score, p, voice, motif, motif_head, PRIMM_HEAD, PRIMM_ANSWER, augment
from lib.capital import QUANTISED, rudiment, CAPITAL_THEME_A, CAPITAL_THEME_B
from scores._fork_b import stack, bed, even

PRIMM = PRIMM_HEAD + PRIMM_ANSWER
TUTTI = [('vln', 12, 0), ('fl', 12, -10), ('cl', 0, -8), ('tpt', 0, -6), ('hn', -12, -2), ('vla', -12, -10)]
LOW = [('vc', -12, -6), ('tbn', -12, -12)]
A_H = ['C', 'C', 'F', 'G', 'C', 'C', 'F', 'G']
B_H = ['C', 'G', 'Dm', 'C', 'F', 'G7', 'Am', 'G', 'F', 'C', 'Dm', 'Am', 'Dm', 'G', 'G7', 'C']
C_H = ['Ab', 'Ab', 'Fm', 'G', 'Ab', 'Bb', 'Fm', 'G', 'Cm', 'Ab', 'Db', 'G', 'Ab', 'Fm', 'G', 'G7']


def build():
    s = Score('MUS-PRIMM-01', bpm=128, bars=68, key='C major', seed=1610, human=QUANTISED)
    s.seat('vln', 'vla', 'pad', 'vc', 'cb', 'fl', 'cl', 'tpt', 'hn', 'tbn', 'timp', 'choir', 'perc')
    s.channel('piano', 'piano', pan=58, reverb=70, vol=80)
    s.channel('hpsd', 'harpsichord', pan=70, reverb=75, vol=72)
    for bar, nm in ((0, 'intro clockwork'), (4, 'A unison'), (20, 'B the anthem'), (36, 'C compression'), (52, 'D tutti unison'),
                    (64, 'outro clockwork')):
        s.section(bar, nm)
    s.notes.append('Quantised. The Primm motif in unison/octaves; the Crossroads motif forced into even quarters (form "flattened").')

    def clock(bar, sym, vel=56):
        tn = voice(sym, 'C4', 3) + voice(sym, 'C5', 3)
        for k in range(8):
            s.note('piano', bar * 4 + k * .5, .4, tn[(0, 1, 2, 1, 3, 2, 4, 2)[k] % len(tn)], vel + (8 if k % 2 == 0 else 0))
            s.note('hpsd', bar * 4 + k * .5, .3, tn[(3, 2, 1, 2, 0, 1, 2, 4)[k] % len(tn)], vel - 12)

    def grid(bar, sym, vel, roll=False):
        bed(s, bar, sym, vel, bass='pulse')
        clock(bar, sym)
        rudiment(s, 'perc', bar, 'roll' if roll else 'paradiddle', vel + 2)
        s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, vel + 16)

    # intro 0-3 / outro 64-67: the same clockwork bed (seam), pedal C, a soft unison head
    def clockwork(bar0):
        for i in range(4):
            sym = 'C' if i < 3 else 'G'
            grid(bar0 + i, sym, 66, roll=(i == 3))
            s.pad('choir', bar0 + i, sym, 58, low='C4')
            s.brass('hn', bar0 + i, sym, 64, low='E3')
            s.brass('tbn', bar0 + i, sym, 58, low='E3')
        s.swell('pad', bar0, 4, 84, 96)
        stack(s, [('vln', 12, 0), ('vla', 0, -8), ('fl', 12, -14)], bar0, PRIMM_HEAD, 80)
        stack(s, [('vln', 12, 0), ('vla', 0, -8), ('fl', 12, -14)], bar0 + 2, PRIMM_ANSWER, 82)

    clockwork(0)

    # A 4-19: the motif in unison/octaves, statement, then augmented with the low brass
    for i in range(16):
        grid(4 + i, A_H[i % 8], 62)
    stack(s, TUTTI, 4, PRIMM, 88)
    stack(s, TUTTI, 8, PRIMM, 90)
    stack(s, [('hn', 0, 0), ('tbn', -12, -6), ('vc', -12, -6), ('vln', 12, -4)], 12, augment(PRIMM_HEAD, 2), 90)
    s.motif('cl', 14, even(motif('C5', 'major')), 66, form='flattened into even quarters (clarinet), swallowed', lead=False)

    # B 20-35: the Capital theme in block brass on the beat, strings in octaves, choir on the pedal
    for i, sym in enumerate(B_H):
        bar = 20 + i
        bed(s, bar, sym, 62, bass='march')
        clock(bar, sym, 50)
        rudiment(s, 'perc', bar, 'march', 64)
        for k in range(4):
            s.brass('tbn', bar, sym.split()[0], 60 + (10 if k == 0 else 0), beats=.55, beat=k, low='E3')
        s.pad('choir', bar, sym.split()[0], 50, low='C4')
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, 80)
    stack(s, [('tpt', 0, 0), ('vln', 12, -6), ('hn', -12, -8)], 20, CAPITAL_THEME_A, 86)
    stack(s, [('tpt', 0, 0), ('vln', 12, -6), ('fl', 12, -12)], 28, CAPITAL_THEME_B, 88)

    # C 36-51: compression - darker borrowed chords, every rhythm squeezed into quarters; the Crossroads head surfaces and is cut off
    for i, sym in enumerate(C_H):
        grid(36 + i, sym, 64, roll=(i == 15))
    s.swell('pad', 36, 16, 80, 112)
    stack(s, [('vln', 12, 0), ('fl', 12, -10), ('vla', 0, -8)], 36, even(PRIMM_HEAD[:4] * 2), 84)
    s.motif('hn', 38, even(motif_head('C4', 'minor')), 74, form='head flattened (horn), cut off', lead=False)
    stack(s, [('vln', 12, 0), ('fl', 12, -10), ('vla', 0, -8)], 40, [(p(n) - 4, d) for n, d in PRIMM_HEAD], 86)
    stack(s, [('vln', 12, 0), ('fl', 12, -8), ('vla', 0, -8)], 42, [(p(n) - 4, d) for n, d in PRIMM_ANSWER], 86)
    stack(s, TUTTI, 44, [(p(n) - 4, d) for n, d in PRIMM_HEAD] + [(p(n) - 5, d) for n, d in PRIMM_ANSWER], 90)
    s.motif('cl', 46, even(motif_head('C5', 'minor')), 64, form='head flattened (clarinet), swallowed', lead=False)
    stack(s, TUTTI, 48, [(n, d) for n, d in PRIMM_HEAD[:4]] * 2, 92)
    stack(s, LOW, 48, PRIMM_HEAD[:4] * 2, 80)

    # D 52-63: everything in unison on the motif, fortissimo, the theme's cadence hammered
    for i in range(12):
        sym = (A_H + ['F', 'G', 'C', 'G'])[i]
        grid(52 + i, sym, 70, roll=(i == 11))
        s.pad('choir', 52 + i, sym, 62, low='C4')
    stack(s, TUTTI + LOW, 52, PRIMM, 96)
    stack(s, TUTTI + LOW, 56, PRIMM, 98)
    stack(s, TUTTI, 60, [('C5', 1), ('C5', 1), ('C5', 1), ('C5', 1), ('G4', 1), ('G4', 1), ('G4', 1), ('G4', 1),
                         ('C5', 1), ('E5', 1), ('G5', 1), ('C6', 1), ('G5', 1), ('G5', 1), ('G5', 1), ('G5', 1)], 94)
    s.hit('crash', 52 * 4, 70, dur=4)

    clockwork(64)
    return s
