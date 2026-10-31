"""MUS-CREASE - Tea of dissent (the Crease, the resistance hideout; Wren and Nurse Hesper Dray). Loop, 48 bars 4/4, 84 BPM, F major.
The one warm, human place in the Capital: chamber piano, clarinet, warm cello and a few strings, human feel ON (the only Capital cue
besides the tunnels and the restored city). A guarded clarinet tune, the Crossroads motif gentle in the cello, and a few Path colours
passing through like people sharing tea - a muted horn (Gainlands), a pizzicato waltz step (D.N.A.), a glockenspiel wink (Buffet), a
flute turn (the Dump). Outside, the Capital's grid is far away: no snare, no music box, no rigid pulse.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, root

TUNE = m('C5:1.5 A4:.5 F4:1 G4:1 | A4:1 Bb4:.5 A4:.5 G4:2 | F4:1 A4:1 D5:1.5 C5:.5 | C5:3 r:1 '
         '| D5:1.5 C5:.5 Bb4:1 A4:1 | G4:1 A4:.5 Bb4:.5 C5:2 | A4:1 G4:1 F4:1 E4:1 | F4:3 r:1')
H = ['F', 'Gm7 C7', 'Dm7', 'C7sus4 C7', 'Bbmaj7', 'Gm7', 'F/C C7', 'F']
B_H = ['Dm', 'Bb', 'F', 'C', 'Dm', 'Bb', 'Gm7', 'C7', 'Am', 'Dm', 'Bbmaj7', 'C7sus4 C7']


def build():
    s = Score('MUS-CREASE', bpm=84, bars=48, key='F major', seed=606)
    s.seat('piano', 'cl', 'vc', 'cb', 'pad', 'vln', 'hn', 'pizz', 'glock', 'fl')
    for bar, nm in ((0, 'intro piano'), (4, 'A clarinet tune'), (20, 'B the motif, Path colours'), (32, "A' strings join"),
                    (44, 'outro piano')):
        s.section(bar, nm)
    s.notes.append('Human feel ON (the Crease is the resistance); no Capital theme - warmth instead; Path colours as cameos.')

    def piano(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'F2')
            tn = s.chord_tones(sym, r + 12, 6)
            seq = [r, tn[0], tn[1], tn[2], tn[3], tn[2], tn[1], tn[0]]
            step = d / len(seq) if d < 4 else .5
            for k in range(int(round(d / step))):
                s.note('piano', t + k * step, step * 1.8, seq[k % len(seq)], vel - (0 if k == 0 else 8))

    def low(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            s.bass_at(t, d, sym, vel, chs=('cb', None))

    def intro(bar):
        for i, spec in enumerate(['F', 'Bbmaj7', 'Gm7', 'C7sus4 C7']):
            piano(bar + i, spec, 58)
            low(bar + i, spec, 50)
            bed(s, bar + i, spec, 36, ch='pad', low='A3', n=3)
        s.mel('vc', bar, m('A3:3 C4:1 | D4:2 F4:2 | Bb3:3 A3:1 | G3:4'), 66)

    intro(0)

    for k in range(2):
        for i, spec in enumerate(H):
            bar = 4 + 8 * k + i
            piano(bar, spec, 56)
            low(bar, spec, 52)
            bed(s, bar, spec, 38 + 6 * k, ch='pad', low='A3', n=3)
    s.mel('cl', 4, TUNE, 82)
    s.mel('cl', 12, TUNE[:12], 84)
    s.motif('cl', 15, motif_head('F4', 'major', rhythm=(1, .5, .5)) + m('A4:2'), 80, form='head (clarinet, guarded)')
    s.mel('cl', 16, TUNE[16:], 80)
    s.line('vc', 12, m('F3:4 | E3:2 C3:2 | D3:4 | C3:4'), 54)

    for i, spec in enumerate(B_H):
        bar = 20 + i
        piano(bar, spec, 52)
        low(bar, spec, 50)
        bed(s, bar, spec, 42, ch='pad', low='A3', n=3)
    s.motif('vc', 20, motif('D3', 'minor') + m('r:1'), 78, form='stated (cello, gentle)')
    s.motif('cl', 22, motif('F4', 'major') + m('r:1'), 72, form='stated (clarinet answers in F)')
    s.mel('hn', 24, m('C4:2 D4:1 F4:1 | E4:4'), 64)                                        # Gainlands: a muted horn call
    s.pizz(26, 'Gm7', 50, pattern=[(0, 'b'), (1, 1), (2, 2)])                               # D.N.A.: a waltz step
    s.mel('pizz', 27, m('C4:1 E4:1 G4:1 Bb4:1'), 56)
    s.mel('glock', 28, m('A5:.5 C6:.5 F6:1 E6:2'), 50)                                     # Buffet: a wink
    s.mel('fl', 29, m('F5:.5 E5:.5 D5:.5 F5:.5 A5:2'), 64)                                  # Dump: a flute turn
    s.mel('cl', 30, m('Bb4:2 A4:1 G4:1 | G4:3 r:1'), 74)

    for k in range(1):
        for i, spec in enumerate(H + H[:4]):
            bar = 32 + i
            piano(bar, spec, 54)
            low(bar, spec, 56)
            bed(s, bar, spec, 52, ch='pad', low='A3', n=4)
    s.swell('pad', 32, 8, 80, 110)
    s.swell('pad', 40, 4, 110, 84)
    s.mel('vln', 32, TUNE, 86)
    s.line('cl', 32, TUNE, 66, transpose=-12)
    s.motif('vc', 36, motif('F3', 'major') + m('r:1'), 64, form='countermelody (cello under the violins)', lead=False)
    s.mel('cl', 40, m('D5:1.5 C5:.5 Bb4:1 A4:1 | G4:1 A4:.5 Bb4:.5 C5:2 | A4:2 G4:2 | G4:4'), 78)

    intro(44)
    return s
