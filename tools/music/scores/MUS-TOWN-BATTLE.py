"""MUS-TOWN-BATTLE - Friendly ground, serious cards. 72 bars 4/4, 132 BPM, D Dorian.
The MUS-TOWN v04 tune and harmony turned into controlled momentum: a pizzicato ostinato and light snare under it, the Crossroads motif
(the tune's head) in the horns and trumpets, woodwinds answering in the gaps. The B tune in the clarinet over a lighter pulse, a middle
where the motif head is tossed between sections, a quiet strategic passage with the motif inverted in the bassoon, and a tutti close.
Steady, never frantic.
"""
from lib import Score, m, motif, motif_head, split_beats

MEL_A = m('D4:1 A4:.5 G4:.5 F4:1.5 E4:.5 | A4:3 r:1 | F4:1 G4:.5 A4:.5 C5:1 Bb4:.5 A4:.5 | G4:2 E4:1 A4:1 '
          '| D5:1 C5:.5 Bb4:.5 A4:1.5 G4:.5 | A4:2 C5:1 F5:1 | E5:1 D5:.5 C5:.5 Bb4:1 D5:1 | E5:1 C#5:1 A4:2')
MEL_B = m('F4:1 Bb4:1 D5:2 | C5:1 A4:1 F4:2 | G4:1 Bb4:1 D5:1 C5:1 | C5:1.5 D5:.5 E5:2 '
          '| D5:1 F5:1 E5:1 D5:1 | C5:1 A4:.5 C5:.5 F5:2 | D5:1 C5:1 Bb4:1 G4:1 | A4:2 C#5:1 E5:1')
HORN_COUNTER = m('F4:4 | D4:2 B3:2 | C4:2 D4:2 | E4:2 D4:2 | F4:4 | F4:2 E4:2 | D4:4 | C#4:2 E4:2')
PROG_A = ['Dm', 'G', 'Dm/F', 'A7s', 'Bb', 'F', 'Gm', 'A']
PROG_B = ['Bb', 'F/A', 'Gm', 'C', 'Bb', 'F', 'Gm7', 'A']
TOSS_H = ['Dm', 'C', 'Bb', 'A', 'Dm', 'C', 'Bb', 'A7s']
PIZZ = [(0, 'b', .4, 8), (.5, 1, .4, -6), (1, 2, .4, 0), (1.5, 1, .4, -6), (2, 'b', .4, 4), (2.5, 1, .4, -6), (3, 2, .4, 0), (3.5, 3, .4, -4)]
SNARE = [(1, 'snare', -4), (3, 'snare', 0), (3.5, 'snare', -16)]


def build():
    s = Score('MUS-TOWN-BATTLE', bpm=132, bars=72, key='D dorian', seed=606)
    s.seat('vln', 'spic', 'pad', 'vc', 'cb', 'harp', 'hn', 'tbn', 'tpt', 'fl', 'ob', 'cl', 'bsn', 'timp', 'pizz', 'perc')
    s.V = {
        'Dm': ('D2', ['D3', 'A3', 'D4', 'F4']), 'G': ('G1', ['D3', 'G3', 'B3', 'D4']), 'Dm/F': ('F2', ['F3', 'A3', 'D4', 'F4']),
        'A7s': ('A1', ['E3', 'G3', 'A3', 'D4']), 'Bb': ('Bb1', ['D3', 'F3', 'Bb3', 'D4']), 'F': ('F2', ['C3', 'F3', 'A3', 'C4']),
        'Gm': ('G2', ['D3', 'G3', 'Bb3', 'D4']), 'A': ('A1', ['E3', 'A3', 'C#4', 'E4']), 'F/A': ('A1', ['C3', 'F3', 'A3', 'C4']),
        'C': ('C2', ['C3', 'E3', 'G3', 'C4']), 'Gm7': ('G1', ['D3', 'F3', 'G3', 'Bb3']),
    }
    for bar, nm in ((0, 'pulse'), (4, 'A horns'), (12, "A' strings"), (20, 'B clarinet'), (28, "B' brass"), (36, 'C tossed head'),
                    (44, "A'' tutti"), (52, 'D strategy'), (60, "A''' trumpets"), (68, 'pulse')):
        s.section(bar, nm)

    def pulse(bar, spec, vel, snare=True, bass='half', timp=True):
        s.figure('pizz', bar, spec, PIZZ, vel, low='D4')
        s.bass(bar, spec, vel + 4, bass)
        if snare:
            s.drum(bar, SNARE, vel - 14)
        if timp:
            r = s.voicing(spec)[0]
            from lib import p
            tp = p(r) + 12 if p(r) + 12 <= p('A2') else p(r)
            s.timp_hit(bar * 4, tp, vel)

    def answers(bar0, vel):
        # woodwinds fill the tune's gaps (bar 2 beat 4, bar 4 beat 3-4, bar 8 beat 3-4 of each 8)
        s.line('fl', bar0 + 1, m('r:3 E5:.5 F5:.5'), vel)
        s.line('ob', bar0 + 3, m('r:2 C5:.5 Bb4:.5 A4:1'), vel - 4)
        s.line('cl', bar0 + 7, m('r:2 E4:.5 G4:.5 Bb4:1'), vel)

    # PULSE 0-3
    for i, spec in enumerate(['Dm', 'G', 'Dm/F', 'A7s']):
        pulse(i, spec, 70)
        s.pad('pad', i, spec, 52)
    s.line('hn', 0, m('A3:8 | A3:4 C#4:4'), 60, legato=1.0, shape=False)

    # A 4-11: horns state the tune, woodwinds answer
    for i, spec in enumerate(PROG_A):
        pulse(4 + i, spec, 72)
        s.pad('pad', 4 + i, spec, 54)
    s.motif('hn', 4, MEL_A[:6], 92, form='stated (horns; the town tune head)')
    s.mel('hn', 4, MEL_A[7:], 92, beat=8)
    answers(4, 62)

    # A' 12-19: violins on the tune 8va, horn counter, trombones under
    for i, spec in enumerate(PROG_A):
        bar = 12 + i
        pulse(bar, spec, 76)
        s.figure('spic', bar, spec, [(x * .5, i2, .4, 4 if x % 2 == 0 else -6) for x, i2 in enumerate([0, 2, 1, 2, 0, 2, 1, 3])], 66, low='D4')
    s.motif('vln', 12, MEL_A, 96, form='stated (violins 8va)', transpose=12)
    s.line('vln', 12, MEL_A, 76)
    s.line('hn', 12, HORN_COUNTER, 74, legato=1.0, shape=False)
    s.line('tbn', 18, m('G2:4 | A2:4'), 62)
    s.swell('vln', 12, 8, 88, 116, 'arch')
    s.hit('crash', 12 * 4, 66, dur=3)

    # B 20-27: the B tune in the clarinet over a lighter pulse
    for i, spec in enumerate(PROG_B):
        bar = 20 + i
        pulse(bar, spec, 64, snare=(i % 2 == 1), bass='whole', timp=(i % 4 == 0))
        s.harp(bar, spec, 48)
        s.pad('pad', bar, spec, 50)
    s.mel('cl', 20, MEL_B, 86)
    s.line('fl', 24, m('r:2 F5:2 | r:4 | r:2 D6:2 | r:4'), 50)
    s.motif('bsn', 22, motif_head('D3', rhythm=(1, .5, 2.5)) + m('r:4'), 62, form='head (bassoon, under the B tune)', lead=False)

    # B' 28-35: brass take the B tune, strings drive, build
    for i, spec in enumerate(PROG_B):
        bar = 28 + i
        pulse(bar, spec, 74)
        s.figure('spic', bar, spec, [(x * .5, i2, .4, 4 if x % 2 == 0 else -6) for x, i2 in enumerate([0, 2, 1, 2, 0, 2, 1, 3])], 70, low='D4')
        s.pad('pad', bar, spec, 56)
    s.mel('tpt', 28, MEL_B, 90)
    s.line('hn', 28, MEL_B, 78, transpose=-12)
    s.line('vln', 28, m('D5:8 | C5:8 | D5:8 | E5:4 C#5:4'), 70, legato=1.0)
    s.swell('vln', 28, 8, 80, 112)
    s.snare_roll(35 * 4 + 2, 2, 40, 84)
    s.timp_roll(35 * 4 + 2, 2, 'A1', 50, 90)

    # C 36-43: the motif head tossed between sections over a falling ostinato
    for i, spec in enumerate(TOSS_H):
        bar = 36 + i
        pulse(bar, spec, 74)
        s.figure('spic', bar, spec, [(x * .5, i2, .4, 4 if x % 2 == 0 else -6) for x, i2 in enumerate([0, 1, 2, 1, 0, 1, 2, 3])], 72, low='D4')
    for k, (ch, bar, tonic, mode, v) in enumerate((('hn', 36, 'D4', 'minor', 88), ('ob', 37, 'A4', 'minor', 80), ('tpt', 38, 'F4', 'major', 86),
                                                    ('fl', 39, 'E5', 'minor', 78), ('hn', 40, 'D4', 'minor', 92), ('cl', 41, 'C5', 'major', 82),
                                                    ('tpt', 42, 'Bb4', 'major', 90))):
        s.motif(ch, bar, motif_head(tonic, mode, rhythm=(1, .5, 2.5)), v, form=f'head tossed ({ch})')
    s.mel('vln', 43, m('E5:1 C#5:1 A4:1 E4:1'), 92)
    s.timp_roll(43 * 4 + 2, 2, 'A1', 50, 96)

    # A'' 44-51: tutti on the tune
    for i, spec in enumerate(PROG_A):
        bar = 44 + i
        pulse(bar, spec, 80, bass='half')
        s.figure('spic', bar, spec, [(x * .5, i2, .4, 4 if x % 2 == 0 else -6) for x, i2 in enumerate([0, 2, 1, 2, 0, 2, 1, 3])], 72, low='D4')
        s.pad('pad', bar, spec, 62)
        b = s.voicing(spec)[0]
        from lib import p
        s.note('tbn', bar * 4, 2, p(b) + 12, 74)
        s.note('tbn', bar * 4 + 2, 1.5, p(b) + 19 if spec != 'A7s' else p(b) + 17, 66)
    s.motif('tpt', 44, MEL_A, 94, form='stated (tutti: trumpets, horns, violins 8va)')
    s.line('hn', 44, MEL_A, 90)
    s.line('vln', 44, MEL_A, 98, transpose=12)
    s.line('fl', 48, split_beats(MEL_A, 16, 32), 76, transpose=12)
    s.hit('crash', 44 * 4, 82, dur=4)
    s.hit('crash2', 48 * 4, 70, dur=3)
    s.swell('vln', 44, 8, 100, 120, 'arch')

    # D 52-59: strategy - pizzicato and woodwinds only, the motif inverted in the bassoon
    for i, spec in enumerate(PROG_B):
        bar = 52 + i
        s.figure('pizz', bar, spec, PIZZ[::2], 62, low='D4')
        s.bass(bar, spec, 58, 'whole', chs=('cb', None))
        s.pad('pad', bar, spec, 46)
        if i % 2 == 1:
            s.drum(bar, [(3, 'snare', -10)], 54)
    s.motif('bsn', 52, motif('D4', 'minor', inverted=True) + m('r:1'), 76, form='inverted (bassoon)')
    s.mel('cl', 54, m('C5:1.5 Bb4:.5 A4:1 G4:1 | A4:4'), 74)
    s.motif('bsn', 56, motif('D4', 'minor', inverted=True) + m('r:1'), 78, form='inverted (bassoon)')
    s.mel('ob', 58, m('Bb4:1 A4:.5 G4:.5 F4:1 G4:1 | A4:2 C#5:2'), 74)
    s.swell('pad', 52, 8, 70, 96)
    s.snare_roll(59 * 4 + 2, 2, 36, 80)

    # A''' 60-67: trumpets on the tune, strings counter
    for i, spec in enumerate(PROG_A):
        bar = 60 + i
        pulse(bar, spec, 78)
        s.pad('pad', bar, spec, 58)
    s.motif('tpt', 60, MEL_A, 92, form='stated (trumpets)')
    s.line('hn', 60, HORN_COUNTER, 80, legato=1.0, shape=False)
    s.line('vln', 60, m('F5:8 | D5:8 | D5:8 | C#5:8'), 74, legato=1.0)
    s.hit('crash', 60 * 4, 72, dur=3)

    # PULSE 68-71: as bar 0
    for i, spec in enumerate(['Dm', 'G', 'Dm/F', 'A7s']):
        pulse(68 + i, spec, 70)
        s.pad('pad', 68 + i, spec, 52)
    s.line('hn', 68, m('A3:8 | A3:4 C#4:4'), 60, legato=1.0, shape=False)
    s.swell('pad', 71, 1, 100, 112)
    s.expr('pad', 0, 100)
    return s
