"""MUS-BEEF-DUN-BATTLE - House of Gains, combat. 80 bars 4/4, 144 BPM, C Dorian.
Deeper than the field battle: a moving bass riff (contrabass, cellos an octave up), taiko and concert bass drum, the Crossroads motif in
the horns (C G F Eb D G; the Dorian A natural over F major is the Beefcake brightness). Active and sustained passages alternate: a drive,
a tremolo hold with the motif augmented, a second drive with a new trumpet tune, a quiet breath (Flex) and a tutti. Orchestral by the
Music Pass 1 brief.
"""
from lib import Score, m, motif, motif_head, augment, p

TUNE = m('C4:1 G4:.5 F4:.5 Eb4:1.5 D4:.5 | G4:3 r:1 | Bb4:1.5 A4:.5 G4:1 F4:1 | G4:2 Eb4:2 '
         '| C5:1 G5:.5 F5:.5 Eb5:1.5 D5:.5 | G5:3 F5:.5 G5:.5 | A5:1.5 G5:.5 F5:1 D5:1 | G5:4')
TUNE_H = ['Cm', 'Cm', 'F', 'Cm', 'Cm', 'Eb', 'F', 'Gm']
HOLD_H = ['Cm', 'Abmaj7', 'Fm', 'G7']
DRIVE2 = m('G5:1.5 Eb5:.5 C5:1 D5:1 | F5:1.5 C5:.5 A4:1 C5:1 | D5:1.5 Bb4:.5 F4:1 Bb4:1 | Eb5:2 G5:2 '
           '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | F5:1.5 Eb5:.5 C5:1 A4:1 | Bb4:1 C5:1 D5:1 F5:1 | G5:4')
DRIVE2_H = ['Cm', 'F', 'Bb', 'Eb', 'Ab', 'F', 'Gm7', 'G']
BREATH_H = ['Ebmaj7', 'Bb/D', 'Cm7', 'F', 'Ebmaj7', 'Bb/D', 'Cm7', 'F', 'Ab', 'Bb', 'Gsus4', 'G']
GROOVE = [(0, 'bd', 10), (0.5, 'bd2', -14), (1, 'snare', 0), (2, 'bd', 0), (2.75, 'bd2', -12), (3, 'snare', 6), (3.5, 'snare', -14)]


def build():
    s = Score('MUS-BEEF-DUN-BATTLE', bpm=144, bars=80, key='C dorian', seed=204)
    s.seat('spic', 'vln', 'trem', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'fl', 'timp', 'pad', 'perc')
    s.channel('taiko', 'taiko', pan=58, reverb=70, vol=86)
    for bar, nm in ((0, 'intro riff'), (4, 'A drive'), (20, 'B hold'), (32, 'C drive 2'), (48, 'D breath'), (60, 'E tutti'),
                    (76, 'outro riff')):
        s.section(bar, nm)
    s.notes.append('Orchestral by the Music Pass 1 brief (the old music_list row asked for riff-led metal).')

    def riff(bar, sym, vel, strings=True):
        r = p(s.voicing(sym)[0])
        if r > p('E2'):
            r -= 12
        if r < p('F#1'):
            r += 12
        third = 3 if sym.startswith(('Cm', 'Fm', 'Gm')) else 4
        cell = [r, r, r + third, r, r + 7, r, r - 2 if r - 2 >= p('E1') else r + 10, r]
        for k, n in enumerate(cell):
            s.note('cb', bar * 4 + k * .5, .42, n, vel + (10 if k in (0, 3, 6) else -6))
            s.note('vc', bar * 4 + k * .5, .42, n + 12 if n + 12 >= p('C3') else n + 24, vel - 8 + (8 if k in (0, 3, 6) else 0))
        if strings:
            top = s.voicing(sym)[1]
            for k in range(8):
                s.note('spic', bar * 4 + k * .5, .3, top[[1, 2, 3, 2][k % 4]] + 12, vel - 12 + (8 if k % 2 == 0 else 0))

    def drums(bar, vel, taiko=True):
        s.drum(bar, GROOVE, vel)
        if taiko:
            s.note('taiko', bar * 4, .8, p('C3'), vel + 4)
            s.note('taiko', bar * 4 + 1.5, .8, p('C3'), vel - 10)
            s.note('taiko', bar * 4 + 3, .8, p('C3'), vel - 4)

    def intro(bar):
        for i, sym in enumerate(['Cm', 'Cm', 'F', 'Gm']):
            riff(bar + i, sym, 80)
            drums(bar + i, 66)
            s.pad('pad', bar + i, sym, 62)
            s.brass('hn', bar + i, sym, 56, low='G3', n=2)
        s.motif('hn', bar + 2, motif_head('C4', 'dorian', rhythm=(1, .5, 2.5)), 76, form='head (horns, call)')

    intro(0)
    s.timp_roll(3 * 4 + 2, 2, 'G2', 50, 90)

    # A 4-19: drive - motif in the horns, trombones beneath, the riff moving
    for i in range(16):
        sym = TUNE_H[i % 8]
        riff(4 + i, sym, 78 if i < 8 else 84)
        drums(4 + i, 62 if i < 8 else 70)
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, 'C3', 86)
    s.motif('hn', 4, TUNE, 94, form='stated (horns + trombones)')
    s.line('tbn', 4, TUNE, 74, transpose=-12)
    s.motif('tpt', 12, TUNE, 92, form='stated (trumpets, strings 8va)')
    s.line('hn', 12, TUNE, 88)
    s.line('vln', 12, TUNE, 84, transpose=12)
    s.hit('crash', 12 * 4, 86, dur=2)
    s.timp_roll(19 * 4, 4, 'G2', 60, 100)

    # B 20-31: hold - tremolo strings, held brass, the motif augmented, timpani swells; half-time drums
    for i in range(12):
        sym = HOLD_H[i % 4]
        bar = 20 + i
        s.pad('trem', bar, sym, 64, low='G3')
        s.bass_at(bar * 4, 4, sym, 70, chs=('cb', None))
        s.drum(bar, [(0, 'bd', 6), (2, 'snare', 0), (3.5, 'bd2', -10)], 58)
        s.note('taiko', bar * 4, 1.5, p('C3'), 70)
        if i % 4 == 3:
            s.timp_roll(bar * 4, 4, 'G2', 40, 92)
    s.swell('trem', 20, 4, 70, 110)
    s.swell('trem', 24, 4, 70, 110)
    s.swell('trem', 28, 4, 80, 120)
    s.motif('hn', 20, augment(motif('C4', 'dorian'), 2), 90, form='augmented (horns, under the tremolo)')
    s.mel('tpt', 24, m('Eb5:4 | Eb5:2 F5:2 | Ab5:4 | G5:4'), 86)
    s.line('tbn', 24, m('C4:4 | C4:4 | C4:4 | B3:4'), 70)
    s.motif('hn', 28, m('C4:2 G4:1 F4:1 | Eb4:4 | C4:4 | D4:2 G4:2'), 92, form='head augmented (horns)')
    s.line('tbn', 28, m('C3:4 | Ab3:4 | F3:4 | G3:4'), 72)
    s.snare_roll(31 * 4 + 2, 2, 50, 96)

    # C 32-47: drive 2 - the trumpet tune; the horns answer with the motif
    for i in range(16):
        sym = DRIVE2_H[i % 8]
        riff(32 + i, sym, 78 if i < 8 else 84)
        drums(32 + i, 64 if i < 8 else 70)
        if i % 2 == 0:
            s.timp_hit((32 + i) * 4, p(s.voicing(sym)[0]) + 12 if p(s.voicing(sym)[0]) + 12 >= p('C3') else p(s.voicing(sym)[0]) + 24, 80)
    s.mel('tpt', 32, DRIVE2, 100)
    s.line('hn', 32, DRIVE2, 74, transpose=-12)
    s.mel('tpt', 40, DRIVE2, 106)
    s.line('vln', 40, DRIVE2, 88, transpose=12)
    s.motif('hn', 40, motif('C4', 'dorian'), 64, form='stated (horn countermelody)', lead=False)
    s.motif('hn', 44, motif_head('C4', 'dorian', rhythm=(1, .5, 2.5)), 64, form='head (horn answer)', lead=False)
    s.hit('crash', 40 * 4, 88, dur=2)
    s.swell('vln', 44, 4, 110, 80)

    # D 48-59: breath - Eb major, flute, a heartbeat bass drum; then the build
    for i, sym in enumerate(BREATH_H):
        bar = 48 + i
        s.pad('pad', bar, sym, 52 if i < 8 else 60)
        s.bass_at(bar * 4, 4, sym, 52 if i < 8 else 66, chs=('cb', 'vc'))
        s.drum(bar, [(0, 'bd', 0), (1.5, 'bd2', -12)], 50)
        s.swell('pad', bar, 1, 60 if i % 2 == 0 else 90, 90 if i % 2 == 0 else 60) if i < 8 else None
    s.motif('fl', 48, augment(motif('Eb4', 'major'), 2), 76, form='augmented (flute, the breath)')
    s.mel('fl', 52, m('G5:3 F5:1 | D5:4 | Eb5:2 G5:2 | F5:4'), 74)
    s.mel('tpt', 56, m('Eb5:4 | F5:4 | G5:4 | B4:2 D5:2'), 98)
    s.line('hn', 56, m('C4:4 | D4:4 | D4:4 | D4:4'), 60)
    s.swell('pad', 56, 4, 70, 118)
    s.snare_roll(56 * 4, 16, 24, 96)
    s.timp_roll(59 * 4, 4, 'G2', 60, 108)

    # E 60-75: tutti
    for i in range(16):
        sym = TUNE_H[i % 8]
        riff(60 + i, sym, 88)
        drums(60 + i, 74)
        s.pad('pad', 60 + i, sym, 62)
        if i % 4 == 0:
            s.hit('crash', (60 + i) * 4, 92, dur=2)
            s.timp_hit((60 + i) * 4, 'C3', 96)
    s.motif('tpt', 60, TUNE, 100, form='stated (tutti)')
    s.line('hn', 60, TUNE, 94)
    s.line('tbn', 60, TUNE, 80, transpose=-12)
    s.line('vln', 60, TUNE, 100, transpose=12)
    s.mel('tpt', 68, TUNE, 102)
    s.line('hn', 68, TUNE, 96)
    s.line('vln', 68, TUNE, 104, transpose=12)
    s.motif('tbn', 68, augment(motif('C3', 'dorian'), 2), 86, form='augmented (trombones)', lead=False)
    s.swell('vln', 72, 4, 120, 90)
    s.swell('pad', 72, 4, 110, 70)

    # OUTRO 76-79: the riff, as bar 0
    intro(76)
    return s
