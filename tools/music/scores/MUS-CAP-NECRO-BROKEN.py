"""MUS-CAP-NECRO-BROKEN - Grave Row, broken service. Loop, 52 bars 3/4, 80 BPM, C minor.
The D.N.A. theme played thin, detuned and interrupted: a celesta carries it with a second celesta 15 cents flat (Music Pass 3: was 25) beside it (the rift),
each phrase stops a bar or two early as if the clerk walked away, and the clock ticks, stalls and starts again. A faint glass pad (the
rift synth) and a barely audible low cello are all the warmth left. The Crossroads motif's head appears once in the clarinet and is cut
off. Restless, unresolved, endless procedure - but quiet; never horror.
"""
from lib import Score, m, motif_head, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS


def bars_of(mel, q=3):
    out, cur, acc = [], [], 0.0
    for n, d in mel:
        cur.append((n, d))
        acc += d
        if acc >= q - 1e-6:
            out.append(cur)
            cur, acc = [], 0.0
    return out


TB = bars_of(DNA_THEME)          # 16 one-bar cells


def build():
    s = Score('MUS-CAP-NECRO-BROKEN', bpm=80, bars=52, meter=(3, 4), key='C minor', seed=317)
    s.V.update(DNA_CHORDS)
    s.seat('cel', 'vc', 'cb', 'cl', 'perc', 'pizz')
    s.channel('cel2', 'celesta', pan=84, reverb=100, vol=54)
    s.channel('glass', 'bowed_glass', pan=64, reverb=110, vol=46)
    s.channel('organ', 'organ', pan=58, reverb=110, vol=48)
    s.detune('cel2', -15)
    for bar, nm in ((0, 'stall'), (4, 'A thin theme'), (20, 'B interrupted'), (36, 'C the clerk returns'), (48, 'stall')):
        s.section(bar, nm)
    s.notes.append('Broken district: the D.N.A. theme on a celesta doubled 15 cents flat (Music Pass 3: was 25) (Score.detune), phrases cut off.')

    def clock(bar, beats=(0, 1, 2), vel=30):
        for k in beats:
            s.note('perc', bar * 3 + k, .15, 76 if k == 0 else 77, vel + (6 if k == 0 else 0), human=False)

    def cell(bar, idxs, vel, cut_last=False):
        mel = [x for i in idxs for x in TB[i]]
        if cut_last:
            mel = mel[:-1] + [(mel[-1][0], .5), ('r', mel[-1][1] - .5)]
        s.mel('cel', bar, mel, vel, transpose=12)
        s.line('cel2', bar, mel, vel - 18, transpose=12)

    def ground(bar, sym, vel, organ=False):
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), vel)
        s.note('vc', bar * 3, 2.9, p(s.voicing(sym)[0]) + 12, vel - 12)
        if organ:
            v = s.voicing(sym)[1]
            s.note('organ', bar * 3, 2.95, p(v[2]), vel - 10)

    def stall(bar):
        for i, sym in enumerate(['Cm', 'Cm', 'Ab', 'G7']):
            ground(bar + i, sym, 40, organ=True)
            clock(bar + i, beats=(0, 1, 2) if i != 2 else (0,))
        s.pad('glass', bar, 'Cm', 40, beats=12)
        s.line('cel', bar + 1, m('B5:1 r:2'), 40)

    stall(0)

    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        ground(bar, sym, 42, organ=(i % 4 == 0))
        clock(bar, beats=(0, 1, 2) if i % 5 != 4 else (0, 1))
        if i % 4 == 0:
            s.pad('glass', bar, sym, 36, beats=12)
    cell(4, [0, 1, 2], 72, cut_last=True)            # three bars, then the clerk walks away
    cell(8, [3, 4, 5, 6], 70, cut_last=True)
    cell(13, [8, 9], 66, cut_last=True)
    cell(16, [12, 13, 14], 70, cut_last=True)

    for i in range(16):
        bar, sym = 20 + i, (['Ab', 'Fm', 'Db', 'Gs'] * 4)[i]
        ground(bar, sym, 38)
        if i % 3 != 2:
            clock(bar, vel=26)
        if i % 4 == 0:
            s.pad('glass', bar, sym, 40, beats=12)
    s.motif('cl', 21, motif_head('C4', 'minor', rhythm=(1, .5, .5)) + m('r:1'), 62, form='head (clarinet, cut off)')
    cell(24, [4, 5], 64, cut_last=True)
    s.mel('pizz', 27, m('G4:1 r:2 | Ab4:1 r:2'), 50)
    cell(29, [10, 11], 62, cut_last=True)
    cell(33, [6, 7], 60, cut_last=True)

    for i in range(12):
        bar, sym = 36 + i, DNA_PROG[i]
        ground(bar, sym, 44, organ=True)
        clock(bar)
        if i % 4 == 0:
            s.pad('glass', bar, sym, 38, beats=12)
    cell(36, [0, 1, 2, 3, 4, 5], 74, cut_last=True)
    s.mel('vc', 42, m('Ab3:3 | G3:3 | F3:6'), 50)
    cell(44, [9, 10, 11], 66, cut_last=True)

    stall(48)
    return s
