"""MUS-BEEF-FREED - The Gainlands, restored. 64 bars 4/4, 108 BPM, Bb major, swung 8ths.
The BEEF-EXP march, slowed, swung and reharmonised warmer (maj7, 6th and 9th chords), the Beefcake brass joined by the core strings, harp
and woodwinds. The Crossroads motif is RESOLVED here (Bb F Eb D C -> Bb): the question answered. Warm horns lead; in the middle every
section of the band takes the resolved motif in turn - strength shared willingly - before a full, unhurried tutti.
"""
from lib import Score, m, motif, motif_head, voice, p, split_beats

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | Bb4:3 D5:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | Bb4:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME_H = ['Bbmaj7', 'Gm7', 'Cm7', 'F7sus4', 'Ebmaj7', 'Gm7', 'F7', 'Bb6',
           'Bbmaj7', 'Gm7', 'Ebmaj7', 'F7sus4', 'Abmaj7', 'Ebmaj7', 'Cm7 F7', 'Bb6']
GENTLE = m('G4:1.5 Bb4:.5 Eb5:2 | D5:1.5 C5:.5 Bb4:2 | C5:1 Eb5:1 G5:1 F5:1 | F5:3 r:1 '
           '| Eb5:1.5 D5:.5 C5:1 Bb4:1 | F4:1 Bb4:1 D5:2 | D5:1 C5:1 Bb4:1 G4:1 | A4:2 C5:2')
GENTLE_H = ['Ebmaj7', 'Bb/D', 'Cm9', 'F7sus4', 'Ebmaj7', 'Bb/D', 'Gm7', 'F7']
SHARE_H = ['Bbmaj7', 'Gm7', 'Ebmaj7', 'F7sus4', 'Bbmaj7', 'Gm7', 'Ebmaj7', 'F7']
RESOLVED = motif('Bb4', 'major', resolved=True)


def build():
    s = Score('MUS-BEEF-FREED', bpm=108, bars=64, key='Bb major', seed=206)
    s.swing = 0.16
    s.seat('hn', 'tpt', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'harp', 'fl', 'cl', 'pizz', 'timp', 'xylo', 'perc')
    for bar, nm in ((0, 'intro swing'), (4, 'A theme'), (20, 'B gentle'), (36, 'C shared'), (44, "A' tutti"), (60, 'outro swing')):
        s.section(bar, nm)
    s.notes.append('Resolved motif (Bb F Eb D C Bb) - FREED only. Orchestral by the Music Pass 1 brief (old row: open guitar rock + brass).')

    def swing_bar(bar, spec, vel, chords='pizz', drums=True):
        for off, beats, sym in s.parts(spec):
            b = p(s.voicing(sym)[0])
            t = bar * 4 + off
            s.note('tuba', t, 0.9, b, vel)
            if beats >= 2:
                s.note('tuba', t + 2, 0.9, b + 7 if b + 7 < p('C3') else b - 5, vel - 8)
            for k in range(1, int(beats), 2):
                for n in voice(sym, 'F3', 4):
                    s.note(chords, t + k, 0.4, n, vel - 16)
                    if k == 3 or beats == 2:
                        s.note(chords, t + k + .5, 0.3, n, vel - 26)
        if drums:
            s.drum(bar, [(0, 'bd', 0), (1, 'snare', -14), (2, 'bd', -8), (3, 'snare', -10), (3.5, 'snare', -24)], vel - 18)

    def vamp(bar):
        for i, spec in enumerate(['Bbmaj7', 'Gm7', 'Cm7', 'F7sus4']):
            swing_bar(bar + i, spec, 68)
            s.pad('pad', bar + i, spec, 44)
        s.expr('pad', bar, 74)
        s.motif('hn', bar + 1, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 70, form='head (horn, relaxed)')

    vamp(0)

    # A 4-19: the theme on warm horns; the motif resolves to Bb in bars 5 and 13
    for i, spec in enumerate(THEME_H):
        bar = 4 + i
        swing_bar(bar, spec, 72 if i < 8 else 76)
        s.pad('pad', bar, spec.split()[0], 50 if i < 8 else 56)
        if i >= 8:
            s.harp(bar, spec.split()[0], 46)
    s.motif('hn', 4, THEME, 90, form='RESOLVED (horns, bars 4-5 and 12-13)')
    s.line('cl', 4, THEME, 56, transpose=-12)
    s.line('vln', 4, THEME, 64, transpose=12)
    s.expr('vln', 4, 30)
    s.swell('vln', 4, 8, 30, 70)
    s.swell('vln', 12, 8, 70, 100, 'arch')
    s.timp_hit(4 * 4, 'Bb2', 70)
    s.timp_hit(12 * 4, 'Bb2', 74)
    s.hit('crash2', 12 * 4, 50, dur=2)

    # B 20-35: gentle - clarinet then flute, harp and pizzicato, the swing on brushes only
    for k in range(2):
        for i, spec in enumerate(GENTLE_H):
            bar = 20 + k * 8 + i
            s.pad('pad', bar, spec, 36 + 4 * k)
            s.harp(bar, spec, 40)
            s.bass(bar, spec, 50, 'half', chs=('cb', None))
            s.drum(bar, [(1, 'snare', -10), (3, 'snare', -8)], 40)
    s.expr('pad', 20, 62)
    s.mel('cl', 20, GENTLE, 74)
    s.line('hn', 24, m('Bb3:4 | F3:4 | G3:2 F3:2 | Eb3:2 F3:2'), 52, legato=1.0, shape=False)
    s.mel('fl', 28, GENTLE, 68, transpose=12)
    s.line('cl', 28, GENTLE, 44)
    s.line('xylo', 31, m('r:2 F5:.5 G5:.5 A5:1'), 54)
    s.motif('hn', 32, motif('Bb3', 'major', resolved=True), 66, form='RESOLVED (horn, countermelody)', lead=False)

    # C 36-43: strength shared - every section takes the resolved motif in turn
    for i, spec in enumerate(SHARE_H):
        swing_bar(36 + i, spec, 78, chords='harp')
        s.pad('pad', 36 + i, spec, 58)
    s.motif('hn', 36, RESOLVED, 92, form='RESOLVED (horns)')
    s.motif('tpt', 38, motif('Eb5', 'major', resolved=True), 90, form='RESOLVED on Eb (trumpets)', transpose=-12)
    s.motif('vln', 40, RESOLVED, 92, form='RESOLVED (strings)', transpose=12)
    s.motif('fl', 42, motif('Eb5', 'major', resolved=True), 86, form='RESOLVED on Eb (flute + clarinet)')
    s.line('cl', 42, motif('Eb5', 'major', resolved=True), 60, transpose=-12)
    s.line('tbn', 43, [(n, .125) for n in range(p('F3'), p('Bb3'))] + [('Bb3', .5)], 64, shape=False)
    s.timp_roll(43 * 4 + 2, 2, 'F2', 40, 80)

    # A' 44-59: tutti - unhurried, warm; strings on top, horns in the middle, trumpets only on the second half
    for i, spec in enumerate(THEME_H):
        bar = 44 + i
        swing_bar(bar, spec, 80, chords='pizz')
        s.pad('pad', bar, spec.split()[0], 62)
        s.harp(bar, spec.split()[0], 48)
    s.motif('vln', 44, THEME, 94, form='RESOLVED (tutti, strings 8va + horns)', transpose=12)
    s.line('hn', 44, THEME, 86)
    s.line('vc', 44, THEME, 64, transpose=-12)
    s.line('tpt', 52, split_beats(THEME, 32, 64), 72)
    s.expr('vln', 44, 96)
    s.swell('vln', 52, 8, 96, 116, 'arch')
    s.timp_hit(44 * 4, 'Bb2', 82)
    s.hit('crash2', 44 * 4, 70, dur=2)
    s.timp_hit(52 * 4, 'Bb2', 84)
    s.swell('pad', 58, 2, 100, 74)

    # OUTRO 60-63: the swing vamp, as bar 0
    vamp(60)
    return s
