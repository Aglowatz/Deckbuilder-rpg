"""MUS-BEEF-EXP - The Gainlands, exploration. 64 bars 4/4, 116 BPM, Bb major.
A sunny gym-kingdom march: tuba oompah and snare, the Crossroads motif as a trumpet fanfare in Bb (degrees 1 5 4 3 2 5: Bb F Eb D C F),
a gentle clarinet/flute B section over pizzicato, a comic interlude (xylophone motif, a trombone "flex", a piccolo trill) and a tutti
return. Orchestral by the Music Pass 1 brief; the old music_list row asked for electric guitars.
"""
from lib import Score, m, motif, motif_head, voice, p, split_beats

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME_H = ['Bb', 'Bb', 'Cm7', 'F', 'Eb', 'Gm', 'F', 'Bb', 'Bb', 'F', 'Eb', 'F', 'Ab', 'Eb', 'F7', 'Bb']
GENTLE = m('G4:1.5 Bb4:.5 Eb5:2 | D5:1.5 C5:.5 Bb4:2 | C5:1 Eb5:1 G5:1 F5:1 | F5:3 r:1 '
           '| Eb5:1.5 D5:.5 C5:1 Bb4:1 | F4:1 Bb4:1 D5:2 | D5:1 C5:1 Bb4:1 G4:1 | A4:2 C5:2')
GENTLE_H = ['Eb', 'Bb/D', 'Cm7', 'F', 'Eb', 'Bb/D', 'Gm', 'F']
FUNNY_H = ['Bb', 'Bb', 'Eb', 'Eb', 'Bb', 'Bb', 'C7', 'F7']
MARCH = [(0, 'snare', 10), (1, 'snare', -6), (1.5, 'snare', -12), (2, 'snare', 4), (3, 'snare', -6), (3.5, 'snare', -10), (3.75, 'snare', -14)]


def build():
    s = Score('MUS-BEEF-EXP', bpm=116, bars=64, key='Bb major', seed=201)
    s.seat('tpt', 'hn', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'fl', 'picc', 'cl', 'timp', 'xylo', 'pizz', 'perc')
    for bar, nm in ((0, 'intro vamp'), (4, 'A march'), (20, 'B gentle'), (36, 'C comic'), (44, "A' tutti"), (60, 'outro vamp')):
        s.section(bar, nm)
    s.notes.append('Orchestral march by the Music Pass 1 brief (the old music_list row asked for electric guitar rock).')

    def oompah(bar, spec, vel, chord_ch='hn', chord_v=None):
        for off, beats, sym in s.parts(spec):
            b = p(s.voicing(sym)[0])
            t = bar * 4 + off
            s.note('tuba', t, 0.8, b, vel)
            if beats >= 2:
                s.note('tuba', t + 2, 0.8, b + 7 if b + 7 < p('C3') else b, vel - 8)
            for k in range(1, int(beats), 2):
                for n in voice(sym, 'F3', 3):
                    s.note(chord_ch, t + k, 0.45, n, chord_v or vel - 14)

    def vamp(bar, bars):
        for i in range(bars):
            oompah(bar + i, 'Bb' if i % 2 == 0 else 'F7', 70, chord_v=54)
            s.drum(bar + i, MARCH, 52)
            s.drum(bar + i, [(0, 'bd', 0), (2, 'bd', -10)], 54)

    # INTRO 0-3: the band warms up; horns float the motif head
    vamp(0, 4)
    s.motif('hn', 1, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 76, form='head (horn fanfare)')
    s.line('tpt', 3, m('r:2 F4:.5 F4:.5 F4:1'), 70)

    # A 4-19: the march - trumpets on the tune, horns an octave down, then strings join
    for i, spec in enumerate(THEME_H):
        bar = 4 + i
        oompah(bar, spec, 78 if i < 8 else 84, chord_v=58)
        s.drum(bar, MARCH, 60 if i < 8 else 66)
        s.drum(bar, [(0, 'bd', 0), (2, 'bd', -10)], 58)
        if i >= 8:
            s.pad('pad', bar, spec, 52)
    s.motif('tpt', 4, THEME[:6], 90, form='stated (trumpet fanfare)')
    s.mel('tpt', 4, THEME[6:], 90, beat=7)
    s.line('hn', 4, THEME, 72, transpose=-12)
    s.line('vln', 4, THEME, 70, transpose=12)
    s.expr('vln', 4, 40)
    s.swell('vln', 4, 8, 40, 60)
    s.swell('vln', 12, 8, 80, 104)
    s.timp_hit(4 * 4, 'Bb2', 80)
    s.hit('crash', 4 * 4, 70, dur=2)
    s.timp_hit(12 * 4, 'Bb2', 84)
    s.hit('crash', 12 * 4, 76, dur=2)
    s.snare_roll(19 * 4 + 2, 2, 50, 30)

    # B 20-35: gentle - clarinet, then flute; pizzicato and a soft string bed; no snare
    for k in range(2):
        for i, spec in enumerate(GENTLE_H):
            bar = 20 + k * 8 + i
            s.pad('pad', bar, spec, 40 + 4 * k)
            s.pizz(bar, spec, 50)
            s.bass(bar, spec, 52, 'whole', chs=('cb', None))
    s.expr('pad', 20, 64)
    s.mel('cl', 20, GENTLE, 78)
    s.line('hn', 24, m('Bb3:4 | F3:4 | G3:2 F3:2 | F3:2 Eb3:2'), 50, legato=1.0, shape=False)
    s.mel('fl', 28, GENTLE, 72, transpose=12)
    s.line('cl', 28, GENTLE, 48)
    s.motif('hn', 32, motif('Bb3', 'major'), 64, form='stated (horn, warm countermelody)', lead=False)
    s.swell('pad', 28, 8, 64, 84, 'arch')

    # C 36-43: comic interlude - tuba solo oompah, xylophone motif, a trombone flex, a piccolo trill
    for i, spec in enumerate(FUNNY_H):
        bar = 36 + i
        oompah(bar, spec, 78, chord_ch='pizz', chord_v=60)
        s.drum(bar, [(0, 'bd', 0), (2, 'rim', -20)], 56)
    s.motif('xylo', 36, motif('Bb4', 'major', rhythm=[.5, .25, .25, .75, .25, 2]), 84, form='diminished (xylophone joke)')
    s.mel('xylo', 37, m('r:2 F5:.25 r:.25 F5:.25 r:.25 F5:1'), 84)
    # the flex: a chromatic heave up, a held note that swells
    s.line('tbn', 38, [(n, .125) for n in range(p('D3'), p('Bb3'))] + [('Bb3', 3)], 80, shape=False, legato=1.0)
    s.swell('tbn', 38, 2, 80, 127)
    s.mel('tbn', 39, m('r:3 Bb3:1'), 70)
    s.motif('xylo', 40, motif('Bb4', 'major', rhythm=[.5, .25, .25, .75, .25, 2]), 86, form='diminished (xylophone again)')
    s.line('picc', 41, [('D6' if k % 2 == 0 else 'Eb6', .125) for k in range(16)] + [('F6', 2)], 52, shape=False)
    s.mel('tpt', 42, m('C5:1 D5:1 E5:1 F5:1 | G5:1 A5:1 Bb5:1 C6:1'), 74)
    s.snare_roll(42 * 4, 8, 30, 90)
    s.timp_roll(43 * 4, 4, 'F2', 40, 100)

    # A' 44-59: tutti return - strings 8va, trumpets, horns, trombone chords, cymbals
    for i, spec in enumerate(THEME_H):
        bar = 44 + i
        oompah(bar, spec, 86, chord_ch='tbn', chord_v=64)
        s.pad('pad', bar, spec, 62)
        s.drum(bar, MARCH, 66)
        s.drum(bar, [(0, 'bd', 0), (2, 'bd', -10)], 64)
    s.motif('tpt', 44, THEME, 96, form='stated (tutti)')
    s.line('vln', 44, THEME, 96, transpose=12)
    s.line('hn', 44, THEME, 84)
    s.line('fl', 52, split_beats(THEME, 32, 64), 70, transpose=12)
    s.expr('vln', 44, 100)
    s.swell('vln', 52, 8, 100, 120, 'arch')
    for bar in (44, 48, 52, 56):
        s.hit('crash', bar * 4, 84, dur=2)
        s.timp_hit(bar * 4, 'Bb2', 92)
    s.timp_roll(59 * 4, 4, 'F2', 70, 40)

    # OUTRO 60-63: the vamp again (same voices and level as bar 0), horn head floating
    vamp(60, 4)
    s.motif('hn', 61, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 76, form='head (horn fanfare)')
    s.line('tpt', 63, m('r:2 F4:.5 F4:.5 F4:1'), 70)
    return s
