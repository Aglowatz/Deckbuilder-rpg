"""MUS-TOWN v05 (v04 + the bar 0 pad seam fix, Music Pass 2) - Crosspath, roads converge. 48 bars 4/4, 88 BPM, D Dorian.
Port of G:/My Drive/Card Game Art/Music_Source/MUS-TOWN_v04_score.py (Oct 31) onto the shared toolkit: same calls in the same order with
the same seed, so the notes match the original MIDI exactly. Do not "improve" it here; it is the reference for the house sound.
"""
from lib import Score, split_beats


def build():
    s = Score('MUS-TOWN', bpm=88, bars=48, key='D dorian', seed=7)
    for name, (chan, inst, pan, rev, vol) in {
        'vln': (0, 'strings', 36, 100, 92), 'pad': (1, 'slow_strings', 64, 100, 84), 'vc': (2, 'cello', 82, 90, 88),
        'cb': (3, 'contrabass', 92, 90, 92), 'harp': (4, 'harp', 46, 80, 82), 'hn': (5, 'horn', 78, 95, 92),
        'tbn': (6, 'trombone', 88, 95, 80), 'tpt': (7, 'trumpet', 70, 90, 74), 'fl': (8, 'flute', 52, 85, 80),
        'ob': (10, 'oboe', 60, 85, 76), 'cl': (11, 'clarinet', 72, 85, 84), 'timp': (12, 'timpani', 64, 75, 96),
        'choir': (13, 'choir', 64, 110, 70), 'pizz': (14, 'pizz', 74, 70, 84), 'glock': (15, 'glock', 44, 90, 60),
        'perc': (9, 'orch_kit', 64, 80, 90),
    }.items():
        s.channel(name, inst, pan=pan, reverb=rev, vol=vol, chan=chan)
    s.V = {
        'Dm': ('D2', ['D3', 'A3', 'D4', 'F4']), 'G': ('G1', ['D3', 'G3', 'B3', 'D4']), 'Dm/F': ('F2', ['F3', 'A3', 'D4', 'F4']),
        'A7s': ('A1', ['E3', 'G3', 'A3', 'D4']), 'Bb': ('Bb1', ['D3', 'F3', 'Bb3', 'D4']), 'F': ('F2', ['C3', 'F3', 'A3', 'C4']),
        'Gm': ('G2', ['D3', 'G3', 'Bb3', 'D4']), 'A': ('A1', ['E3', 'A3', 'C#4', 'E4']), 'F/A': ('A1', ['C3', 'F3', 'A3', 'C4']),
        'C': ('C2', ['C3', 'E3', 'G3', 'C4']), 'Gm7': ('G1', ['D3', 'F3', 'G3', 'Bb3']), 'Bb/D': ('D2', ['D3', 'F3', 'Bb3', 'D4']),
    }
    for bar, nm in ((0, 'intro'), (4, 'A'), (12, "A'"), (20, 'B'), (28, "B'"), (36, 'climax'), (44, 'outro')):
        s.section(bar, nm)
    s.notes.append('v05 = v04 with the bar 0 pad starting at CC11 75 (seam fix); v04 port; perc note 49 is an orchestra-kit timpani in FluidR3 (the sketch meant a crash) - kept for fidelity.')
    progA = ['Dm', 'G', 'Dm/F', 'A7s', 'Bb', 'F', 'Gm', 'A']
    progB = ['Bb', 'F/A', 'Gm', 'C', 'Bb', 'F', 'Gm7', 'A']
    form = ['Dm', 'G', 'Dm/F', 'A7s'] + progA + progA + progB + progB + progA + ['Bb', 'F/A', 'Gm', 'A7s']
    melA = [('D4', 1), ('A4', .5), ('G4', .5), ('F4', 1.5), ('E4', .5), ('A4', 3), ('r', 1),
            ('F4', 1), ('G4', .5), ('A4', .5), ('C5', 1), ('Bb4', .5), ('A4', .5), ('G4', 2), ('E4', 1), ('A4', 1),
            ('D5', 1), ('C5', .5), ('Bb4', .5), ('A4', 1.5), ('G4', .5), ('A4', 2), ('C5', 1), ('F5', 1),
            ('E5', 1), ('D5', .5), ('C5', .5), ('Bb4', 1), ('D5', 1), ('E5', 1), ('C#5', 1), ('A4', 2)]
    melB = [('F4', 1), ('Bb4', 1), ('D5', 2), ('C5', 1), ('A4', 1), ('F4', 2), ('G4', 1), ('Bb4', 1), ('D5', 1), ('C5', 1),
            ('C5', 1.5), ('D5', .5), ('E5', 2), ('D5', 1), ('F5', 1), ('E5', 1), ('D5', 1), ('C5', 1), ('A4', .5), ('C5', .5), ('F5', 2),
            ('D5', 1), ('C5', 1), ('Bb4', 1), ('G4', 1), ('A4', 2), ('C#5', 1), ('E5', 1)]
    hornCounterA = [('F4', 4), ('D4', 2), ('B3', 2), ('C4', 2), ('D4', 2), ('E4', 2), ('D4', 2),
                    ('F4', 4), ('F4', 2), ('E4', 2), ('D4', 4), ('C#4', 2), ('E4', 2)]
    sp = lambda mel, a, b: split_beats(mel, a * 4, b * 4)
    note, line, swell, pad, bass, harp, pizz = s.note, s.line, s.swell, s.pad, s.bass, s.harp, s.pizz
    p = lambda n: __import__('lib').p(n)
    V = s.V

    # INTRO 0-3
    for i in range(4):
        pad('pad', i, form[i], 52)
        harp(i, form[i], 58)
        note('cb', i * 4, 4.02, p(V[form[i]][0]), 50)
    swell('pad', 0, 4, 75, 92)       # v05 (Music Pass 2): bar 0 pad from ~75, not 40, so the loop seam no longer drops 5.5 dB
    line('fl', 2, [('D5', 1), ('A5', 3)], 50)
    line('fl', 3, [('G5', 2), ('E5', 2)], 46)
    s.timp_roll(3 * 4 + 2, 2, p('A1'), 30, 70)
    # A 4-11
    for i in range(8):
        bar = 4 + i
        pad('pad', bar, form[bar], 58)
        harp(bar, form[bar], 54)
        bass(bar, form[bar], 66)
    swell('pad', 4, 4, 70, 96, 'arch')
    swell('pad', 8, 4, 70, 104, 'arch')
    s.motif('hn', 4, sp(melA, 0, 4), 84, form='stated (horn)')
    s.mel('fl', 8, sp(melA, 4, 8), 70, transpose=12)
    line('ob', 8, sp(melA, 4, 8), 68)
    line('cl', 8, [('A3', 4), ('A3', 4), ('G3', 4), ('E3', 2), ('C#4', 2)], 52)
    s.timp_hit(4 * 4, p('D2'), 64)
    s.timp_roll(11 * 4 + 2, 2, p('A1'), 36, 84)
    # A' 12-19
    for i in range(8):
        bar = 12 + i
        pad('pad', bar, form[bar], 62)
        bass(bar, form[bar], 78, 'half')
        harp(bar, form[bar], 50, 16)
    s.motif('vln', 12, melA, 92, form='stated (strings 8va)', transpose=12)
    line('vln', 12, melA, 74)
    line('hn', 12, hornCounterA, 72, legato=1.0, shape=False)
    swell('vln', 12, 4, 80, 112, 'arch')
    swell('vln', 16, 4, 84, 120, 'arch')
    for bar in (12, 16):
        s.timp_hit(bar * 4, p('D2'), 80)
    s.timp_hit(15 * 4, p('A1'), 70)
    s.timp_hit(19 * 4, p('A1'), 74)
    note('perc', 12 * 4, 3, 57, 48)
    line('tbn', 18, [('G2', 4), ('A2', 4)], 58)
    # B 20-27
    for i in range(8):
        bar = 20 + i
        pad('pad', bar, form[bar], 48)
        pizz(bar, form[bar], 60)
        note('cb', bar * 4, 4.02, p(V[form[bar]][0]), 54)
        if i % 2 == 0:
            harp(bar, form[bar], 46)
    swell('pad', 20, 8, 60, 84, 'arch')
    s.mel('cl', 20, melB, 80)
    line('glock', 24, sp(melB, 4, 6), 46, transpose=12)
    line('fl', 26, [('F5', 4), ('E5', 4)], 44)
    # B' 28-35
    for i in range(8):
        bar = 28 + i
        pad('pad', bar, form[bar], 60)
        bass(bar, form[bar], 72, 'half')
        harp(bar, form[bar], 48)
    s.mel('vln', 28, sp(melB, 0, 7), 88, transpose=12)
    line('vln', 28, sp(melB, 0, 7), 70)
    line('hn', 28, [('D4', 4), ('C4', 4), ('Bb3', 4), ('C4', 4), ('D4', 4), ('C4', 4), ('Bb3', 4)], 66, legato=1.0, shape=False)
    swell('vln', 28, 7, 84, 122)
    swell('hn', 28, 7, 70, 120)
    run = ['D4', 'E4', 'F4', 'G4', 'A4', 'B4', 'C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'B5', 'C#6', 'D6', 'E6']
    line('vln', 35, [(n, .25) for n in run], 84, legato=0.9, shape=False)
    line('tbn', 34, [('G2', 4), ('A2', 4)], 66)
    s.timp_roll(35 * 4, 4, p('A1'), 40, 112)
    note('perc', 35 * 4 + 2, 2, 49, 40)
    # CLIMAX 36-43
    for i in range(8):
        bar = 36 + i
        ch = form[bar]
        pad('pad', bar, ch, 78)
        pad('choir', bar, ch, 62, octave=1)
        bass(bar, ch, 94, 'half')
        b = p(V[ch][0])
        note('tbn', bar * 4, 2, b + 12, 80)
        note('tbn', bar * 4, 2, b + 19 if ch != 'A7s' else b + 17, 74)
        note('tbn', bar * 4 + 2, 2, b + 12, 72)
        s.timp_hit(bar * 4, b + 12 if b + 12 <= p('A2') else b, 96 if i % 4 == 0 else 78)
        s.timp_hit(bar * 4 + 2.5, b + 12 if b + 12 <= p('A2') else b, 58)
    s.motif('tpt', 36, melA, 90, form='stated (tutti brass)')
    line('hn', 36, melA, 96)
    line('hn', 36, melA, 80, transpose=-12)
    line('vln', 36, melA, 110, transpose=24)
    line('vln', 36, melA, 96, transpose=12)
    line('fl', 40, sp(melA, 4, 8), 78, transpose=12)
    note('perc', 36 * 4, 4, 49, 92)
    note('perc', 36 * 4, 1, 36, 70)
    note('perc', 40 * 4, 4, 57, 74)
    swell('vln', 36, 8, 112, 124, 'arch')
    swell('choir', 36, 8, 70, 110, 'arch')
    s.timp_roll(43 * 4 + 2, 2, p('A1'), 70, 50)
    # OUTRO 44-47
    for i in range(4):
        bar = 44 + i
        pad('pad', bar, form[bar], 56)
        harp(bar, form[bar], 54)
        note('cb', bar * 4, 4.02, p(V[form[bar]][0]), 56)
    swell('pad', 44, 4, 100, 46)
    s.motif('hn', 44, [('D4', 2), ('F4', 2), ('E4', 4), ('D4', 2), ('Bb3', 2), ('A3', 4)], 62, form='fragment (augmented, horn)', legato=1.0)
    line('ob', 46, [('G4', 4), ('A4', 3), ('r', 1)], 52)
    # v05 seam: the held horn and oboe made the last second ~4.5 dB louder than bar 0; ease them (velocity only, notes unchanged)
    s.fade_vel(46, 48, 0.55, ['hn', 'ob', 'harp'], start_factor=0.85)
    return s
