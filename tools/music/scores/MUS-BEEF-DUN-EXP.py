"""MUS-BEEF-DUN-EXP - House of Gains, exploration. 64 bars 4/4, 108 BPM, G minor.
Compulsory repetitions: a cello "rep" figure that never stops counting, a clank of weights (cowbell + sticks) and a metronome click, the
Crossroads motif in the horns stated twice like a set of reps (G D C Bb A D). A quiet B section breathes - string swells that inhale and
exhale over Eb major, a flute line and the motif augmented - for Grandmaster Flex's meditation. Then the fortress tightens (snare, brass,
the motif climbing through G, Bb and C) before the reps return. Orchestral by the Music Pass 1 brief.
"""
from lib import Score, m, motif, augment, p

REPS = m('G4:1 D5:.5 C5:.5 Bb4:1.5 A4:.5 | D5:3 r:1 | Eb5:1.5 D5:.5 C5:1 Bb4:1 | A4:2 F#4:2 '
         '| G4:1 D5:.5 C5:.5 Bb4:1.5 A4:.5 | D5:3 r:1 | Eb5:1 G5:1 F5:1 Eb5:1 | D5:4')
REPS_H = ['Gm', 'Gm', 'Eb', 'D', 'Gm', 'Gm', 'Cm', 'D']
BREATH = m('G5:3 Bb5:1 | G5:2 F5:2 | Eb5:3 C5:1 | D5:4 | G5:3 Bb5:1 | C6:2 Bb5:2 | Ab5:2 G5:2 | F5:4')
BREATH_H = ['Ebmaj7', 'Cm7', 'Abmaj7', 'Bbsus4', 'Ebmaj7', 'Cm7', 'Abmaj7', 'Bbsus4']
FORT = m('G4:1 D5:.5 C5:.5 Bb4:1.5 A4:.5 | D5:3 r:1 | Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | G5:3 r:1 '
         '| C5:1 G5:.5 F5:.5 Eb5:1.5 D5:.5 | Ab5:3 r:1 | G5:1 F#5:1 A5:1 C6:1 | D6:3 r:1')
FORT_H = ['Gm', 'Eb', 'Gm', 'Eb', 'Cm', 'Ab', 'D', 'D7']
CLANK = [(0, 'cowbell', -18), (1, 'stick', -12), (2, 'bd', -6), (3, 'stick', -12), (3.5, 'stick', -20)]


def build():
    s = Score('MUS-BEEF-DUN-EXP', bpm=108, bars=64, key='G minor', seed=203)
    s.seat('vln', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'fl', 'cl', 'harp', 'pad', 'timp', 'perc')
    for bar, nm in ((0, 'intro reps'), (4, 'A reps'), (20, 'B breath'), (36, 'C fortress'), (52, "A' reps tutti"), (60, 'outro reps')):
        s.section(bar, nm)
    s.notes.append('Orchestral by the Music Pass 1 brief (the old music_list row asked for guitar rock).')

    def rep(bar, sym, vel, cb=True):
        """The rep figure: cello 8ths on the chord, counted, with the contrabass on the downbeats."""
        r = p(s.voicing(sym)[0])
        while r < p('C2'):
            r += 12
        third = r + (3 if sym.startswith(('Gm', 'Cm')) else 4)
        cell = [r, r, third, r, r + 7, r, r + 5 if not sym.startswith('D') else r + 3, third]
        for k, n in enumerate(cell):
            s.note('vc', bar * 4 + k * .5, .4, n, vel + (10 if k % 4 == 0 else -4))
        if cb:
            s.note('cb', bar * 4, 1.8, p(s.voicing(sym)[0]), vel)
            s.note('cb', bar * 4 + 2, 1.8, p(s.voicing(sym)[0]), vel - 8)

    def gym(bar, vel):
        s.drum(bar, CLANK, vel)
        s.drum(bar, [(0, 'click', -4), (1, 'click', -14), (2, 'click', -10), (3, 'click', -14)], vel - 18)

    def intro(bar):
        for i, sym in enumerate(['Gm', 'Gm', 'Eb', 'D']):
            rep(bar + i, sym, 66)
            gym(bar + i, 60)
            s.pad('pad', bar + i, sym, 44)
        s.expr('pad', bar, 70)
        s.motif('hn', bar + 2, m('G3:1 D4:.5 C4:.5 D4:2'), 64, form='head (horn, counting in)')

    intro(0)

    # A 4-19: reps - horns state the motif twice, the strings answer; the second time trumpets and violins add weight
    for i in range(16):
        sym = REPS_H[i % 8]
        rep(4 + i, sym, 70 if i < 8 else 78)
        gym(4 + i, 62 if i < 8 else 68)
        s.pad('pad', 4 + i, sym, 50 if i < 8 else 58)
    s.motif('hn', 4, REPS, 86, form='stated twice (horns: rep 1, rep 2)')
    s.mel('tpt', 12, REPS, 90)
    s.line('hn', 12, REPS, 80, transpose=-12)
    s.line('vln', 12, REPS, 70, transpose=12)
    s.motifs.append((12, 'stated (trumpets, rep 3)', 'tpt'))
    s.timp_hit(4 * 4, 'G2', 76)
    s.timp_hit(12 * 4, 'G2', 84)
    s.swell('vln', 12, 8, 70, 104)
    s.line('tbn', 18, m('C3:4 | D3:4'), 62)

    # B 20-35: breath - the reps stop; string pads inhale and exhale every two bars, flute sings, the motif is augmented and slow
    for i in range(16):
        sym = BREATH_H[i % 8]
        bar = 20 + i
        s.pad('pad', bar, sym, 44)
        s.bass_at(bar * 4, 4, sym, 44, chs=('cb', None))
        s.harp(bar, sym, 40 if i < 8 else 46)
        s.swell('pad', bar, 1, 50 if i % 2 == 0 else 86, 86 if i % 2 == 0 else 50)
    s.mel('fl', 20, BREATH, 72, legato=1.0)
    s.motif('cl', 28, augment(motif('Eb4', 'major'), 2), 72, form='augmented (clarinet, the breath)')
    s.mel('fl', 28, BREATH, 66, legato=1.0)
    s.line('hn', 32, m('Eb4:4 | Eb4:2 D4:2'), 50, legato=1.0)
    # the reps creep back in, very soft, under the last bars of the breath
    for bar, sym in ((34, 'Ab'), (35, 'Bb')):
        rep(bar, sym, 48, cb=False)
    s.timp_roll(35 * 4, 4, 'D3', 30, 84)

    # C 36-51: the fortress tightens - snare, trombone/trumpet motif climbing through G, Bb and C
    for i in range(16):
        sym = FORT_H[i % 8]
        bar = 36 + i
        s.bass_at(bar * 4, 4, sym, 76, chs=('cb', 'vc'))
        s.pad('pad', bar, sym, 60)
        s.drum(bar, [(0, 'snare', 8), (1, 'snare', -8), (1.5, 'snare', -12), (2, 'snare', 0), (2.5, 'snare', -12), (3, 'snare', -6),
                     (0, 'bd', 0), (2, 'bd', -6)], 56 if i < 8 else 64)
        if i % 2 == 0:
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 80)
        for k in range(4):
            s.note('vln', bar * 4 + k, .5, s.voicing(sym)[1][2] + 12, 58 + (8 if k == 0 else 0))
    s.motif('tpt', 36, FORT, 88, form='stated, climbing G - Bb - C (trumpets)')
    s.line('tbn', 36, FORT, 76, transpose=-12)
    s.motif('hn', 44, FORT, 92, form='stated (horns + trumpets 8va)')
    s.mel('tpt', 44, FORT, 92, transpose=0)
    s.line('tbn', 44, FORT, 80, transpose=-12)
    s.hit('crash', 44 * 4, 84, dur=2)
    s.swell('vln', 36, 16, 70, 110)
    s.timp_roll(51 * 4, 4, 'D2', 60, 104)

    # A' 52-59: reps tutti
    for i in range(8):
        sym = REPS_H[i]
        rep(52 + i, sym, 82)
        gym(52 + i, 70)
        s.pad('pad', 52 + i, sym, 64)
    s.motif('tpt', 52, REPS, 94, form='stated (tutti)')
    s.line('hn', 52, REPS, 88, transpose=-12)
    s.line('vln', 52, REPS, 90, transpose=12)
    s.hit('crash', 52 * 4, 90, dur=2)
    s.timp_hit(52 * 4, 'G2', 92)
    s.swell('vln', 56, 4, 110, 80)

    # OUTRO 60-63: the reps alone, as bar 0
    intro(60)
    return s
