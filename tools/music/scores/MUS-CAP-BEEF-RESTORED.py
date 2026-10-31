"""MUS-CAP-BEEF-RESTORED - Transit Yards, service returns (Capital district). 48 bars 4/4, 112 BPM, Bb major (102.9 s loop).
The same Gainlands theme (MUS-BEEF-EXP) the broken cue could not finish, now full and in tune: tuba oompah back on every beat, horns and
trumpets on the whole theme, flowing strings - movement and lights returning. The Crossroads motif resolves (Bb F Eb D C -> Bb) in the
horns. The wider Capital's tension stays underneath: a stiff, on-the-grid snare and a passage over minor chords before the tutti.
"""
from lib import Score, m, motif, motif_head, voice, p, split_beats

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME_H = ['Bb', 'Bb', 'Cm7', 'F', 'Eb', 'Gm', 'F', 'Bb', 'Bb', 'F', 'Eb', 'F', 'Ab', 'Eb', 'F7', 'Bb']
TENSE_H = ['Gm', 'Ebmaj7', 'Cm7', 'D7', 'Gm', 'Ebm6', 'Bb/F', 'F7']
GRID = [(0, 'snare', 4), (1, 'snare', -8), (2, 'snare', 0), (3, 'snare', -8)]


def build():
    s = Score('MUS-CAP-BEEF-RESTORED', bpm=112, bars=48, key='Bb major', seed=817)
    s.seat('tpt', 'hn', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'harp', 'cl', 'fl', 'timp', 'perc')
    for bar, nm in ((0, 'intro vamp'), (4, 'A full theme'), (20, 'B Capital shadow'), (28, "A' tutti"), (44, 'outro vamp')):
        s.section(bar, nm)
    s.notes.append('Restored = the BROKEN cue\'s theme full and in tune; resolved motif (restored cue). Grid snare = the Capital tension.')

    def oompah(bar, sym, vel, chord_ch='hn', chord_v=None):
        b = p(s.voicing(sym)[0])
        s.note('tuba', bar * 4, .8, b, vel)
        s.note('tuba', bar * 4 + 2, .8, b + 7 if b + 7 < p('C3') else b, vel - 8)
        for k in (1, 3):
            for n in voice(sym, 'F3', 3):
                s.note(chord_ch, bar * 4 + k, .45, n, chord_v or vel - 14)

    def vamp(bar):
        for i, sym in enumerate(['Bb', 'Gm', 'Cm7', 'F']):
            oompah(bar + i, sym, 70, chord_v=54)
            s.pad('pad', bar + i, sym, 50)
            s.harp(bar + i, sym, 46)
            s.drum(bar + i, GRID, 50)
        s.mel('fl', bar, m('r:1 D6:1 C6:1 Bb5:1 | G5:4 | Eb6:2 D6:1 C6:1 | A5:4'), 74)
        s.motif('hn', bar + 1, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 70, form='head (horn)', lead=False)
        s.expr('pad', bar, 92)
        s.swell('pad', bar + 3, 1, 92, 100)

    vamp(0)

    # A 4-19: the whole theme, in tune - trumpets, horns an octave down, flowing strings
    for i, sym in enumerate(THEME_H):
        bar = 4 + i
        oompah(bar, sym, 78 if i < 8 else 84, chord_v=58)
        s.pad('pad', bar, sym, 54 if i < 8 else 60)
        s.harp(bar, sym, 50, density=16)
        s.drum(bar, GRID, 54)
        s.drum(bar, [(0, 'bd', 0), (2, 'bd', -10)], 58)
    s.motif('tpt', 4, THEME[:6], 92, form='stated (trumpets: the theme the broken cue could not finish)')
    s.mel('tpt', 4, THEME[6:], 92, beat=7)
    s.line('hn', 4, THEME, 64, transpose=-12)
    s.mel('vln', 12, split_beats(THEME, 32, 64), 88, transpose=12)
    s.timp_hit(4 * 4, 'Bb2', 82)
    s.hit('crash', 12 * 4, 76, dur=2)

    # B 20-27: the Capital's shadow - minor chords, grid snare alone, clarinet on the theme's second phrase in G minor colour
    for i, sym in enumerate(TENSE_H):
        bar = 20 + i
        s.pad('pad', bar, sym, 58)
        s.bass(bar, sym, 60, 'half', chs=('cb', 'vc'))
        s.drum(bar, GRID, 58)
    s.mel('cl', 20, m('G4:1.5 F4:.5 Eb4:1 C4:1 | D4:1.5 C4:.5 Bb3:1 G3:1 | Eb4:1 G4:1 Bb4:1 G4:1 | A4:3 r:1'), 80)
    s.motif('hn', 24, motif('Bb3', 'major', resolved=True) + m('r:1'), 88, form='RESOLVED (horns: the service returns)')
    s.mel('vln', 25, m('Db5:4 | D5:4 | C5:4'), 70)
    s.line('vln', 24, m('D5:4'), 66)
    s.timp_roll(27 * 4, 4, 'F2', 40, 96)

    # A' 28-43: tutti - strings 8va, trumpets, horns, trombone off-beats; resolved motif again at the end of the phrase
    for i, sym in enumerate(THEME_H):
        bar = 28 + i
        oompah(bar, sym, 86, chord_ch='tbn', chord_v=64)
        s.pad('pad', bar, sym, 62)
        s.harp(bar, sym, 54, density=16)
        s.drum(bar, GRID, 58)
        s.drum(bar, [(0, 'bd', 0), (2, 'bd', -10)], 64)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 82, dur=2)
            s.timp_hit(bar * 4, 'Bb2', 88)
    s.mel('tpt', 28, THEME, 98)
    s.line('vln', 28, THEME, 98, transpose=12)
    s.line('hn', 28, THEME, 84)
    s.motif('hn', 40, motif('Bb4', 'major', resolved=True, rhythm=[.5, .25, .25, .75, .25, 2]), 70,
            form='RESOLVED, quick (horns under the last phrase)', lead=False)
    s.timp_roll(43 * 4, 4, 'F2', 70, 40)

    vamp(44)
    s.timp_roll(47 * 4 + 2, 2, 'F2', 30, 66)
    return s
