"""MUS-BEEF-BATTLE - The Gainlands, combat. 72 bars 4/4, 138 BPM, Bb Mixolydian.
A driving string ostinato and timpani under the Crossroads motif in the brass (Bb F Eb D C F, then sequenced onto Ab - the Mixolydian
flat seven gives it the sports-anthem swagger). Sections: A brass fanfare, B tense horn stabs over G minor, C a broad string tune with the
motif augmented in the horns, D tutti, then the ostinato alone so the loop lands. Orchestral by the Music Pass 1 brief.
"""
from lib import Score, m, motif, motif_head, augment, p

TUNE = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:3 r:1 | Ab5:1.5 G5:.5 F5:1 Eb5:1 | F5:2 D5:2 '
         '| Ab4:1 Eb5:.5 Db5:.5 C5:1.5 Bb4:.5 | Eb5:3 r:1 | C5:1 Eb5:1 G5:1 F5:1 | F5:2 G5:1 A5:1')
TUNE_H = ['Bb', 'Bb', 'Ab', 'Bb', 'Ab', 'Ab', 'Cm', 'F']
STABS = m('G4:1 D5:.5 C5:.5 D5:2 | r:2 Bb4:.5 C5:.5 D5:1 | Eb4:1 Bb4:.5 Ab4:.5 Bb4:2 | r:2 G4:.5 Ab4:.5 Bb4:1 '
          '| C5:1 G5:.5 F5:.5 Eb5:1.5 D5:.5 | G5:3 r:1 | F5:1 Eb5:1 D5:1 C5:1 | A4:2 C5:2')
STABS_H = ['Gm', 'Gm', 'Eb', 'Eb', 'Cm', 'Cm', 'F', 'F']
BROAD = m('G5:2 F5:1 Eb5:1 | D5:2 Bb4:2 | C5:1 D5:1 Eb5:1 G5:1 | Ab5:3 G5:1 '
          '| G5:2 F5:1 Eb5:1 | F5:2 D5:2 | Eb5:1 F5:1 Ab5:1 C6:1 | A5:4')
BROAD_H = ['Eb', 'Bb/D', 'Cm', 'Ab', 'Eb', 'Bb/D', 'Ab', 'F']
GROOVE = [(0, 'bd', 8), (1, 'snare', 0), (1.5, 'bd', -10), (2, 'bd', 0), (3, 'snare', 4), (3.75, 'snare', -16)]


def build():
    s = Score('MUS-BEEF-BATTLE', bpm=138, bars=72, key='Bb mixolydian', seed=202)
    s.seat('spic', 'vln', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'brass', 'fl', 'picc', 'timp', 'pad', 'perc')
    for bar, nm in ((0, 'intro ostinato'), (4, 'A brass'), (20, 'B stabs'), (36, 'C broad'), (52, 'D tutti'), (68, 'outro ostinato')):
        s.section(bar, nm)
    s.notes.append('Orchestral by the Music Pass 1 brief (the old music_list row asked for riff-led metal).')

    def ost(bar, sym, vel):
        """8th-note string ostinato on the chord's root/third/fifth, accents on 1, the and of 2, and 4."""
        r = p(s.voicing(sym)[0])
        while r < p('F4'):
            r += 12
        third = r + (3 if sym.startswith(('Cm', 'Gm')) else 4)
        cell = [r, r, r + 7, r, third, r, r + 7, r + 12]
        acc = [10, -6, 0, 6, -4, -6, 4, -2]
        for k, (n, a) in enumerate(zip(cell, acc)):
            s.note('spic', bar * 4 + k * .5, .35, n - 12, vel + a)

    def drive(bar, sym, vel, drums=True, timp=True):
        ost(bar, sym, vel)
        s.bass(bar, sym, vel - 4, 'pulse', chs=('cb', None))
        if timp:
            r = p(s.voicing(sym)[0]) + 12
            s.timp_hit(bar * 4, r, vel + 6)
            s.timp_hit(bar * 4 + 2.5, r, vel - 10)
        if drums:
            s.drum(bar, GROOVE, vel - 6)

    def intro(bar):
        for i, sym in enumerate(['Bb', 'Bb', 'Ab', 'Bb']):
            drive(bar + i, sym, 82)
            s.pad('brass', bar + i, sym, 46, low='F3', n=3, beats=1, beat=3)
            s.pad('pad', bar + i, sym, 64)
            s.brass('tbn', bar + i, sym, 62, low='F3', n=2)
        s.motif('hn', bar + 2, motif_head('Bb3', 'mixolydian', rhythm=(1, .5, 2.5)), 70, form='head (horns, call to arms)')

    intro(0)
    s.snare_roll(3 * 4 + 2, 2, 40, 80)

    # A 4-19: the motif in the brass over the drive
    for i in range(16):
        sym = TUNE_H[i % 8]
        drive(4 + i, sym, 72 if i < 8 else 78)
        s.pad('brass', 4 + i, sym, 50, low='F3', n=3) if i % 2 == 1 else None
    s.motif('tpt', 4, TUNE, 92, form='stated (trumpets + horns)')
    s.line('hn', 4, TUNE, 80, transpose=-12)
    s.motif('tpt', 12, TUNE, 96, form='stated again (strings join 8va)')
    s.line('hn', 12, TUNE, 84, transpose=-12)
    s.line('vln', 12, TUNE, 84, transpose=12)
    s.hit('crash', 4 * 4, 80, dur=2)
    s.hit('crash', 12 * 4, 86, dur=2)
    s.snare_roll(19 * 4 + 2, 2, 50, 90)

    # B 20-35: tension - G minor, horn stabs on the motif head, lighter drums, the ostinato drops an octave
    for i in range(16):
        sym = STABS_H[i % 8]
        drive(20 + i, sym, 62 if i < 8 else 70, drums=False, timp=(i % 2 == 0))
        s.drum(20 + i, [(0, 'bd', 0), (2.5, 'bd', -8), (3, 'rim', -10)], 56)
    s.motif('hn', 20, STABS, 90, form='head in sequence (horn stabs on G, Eb, C)')
    s.mel('tpt', 28, STABS, 84)
    s.line('hn', 28, STABS, 78, transpose=-12)
    s.swell('spic', 20, 16, 80, 110)
    s.timp_roll(35 * 4, 4, 'F2', 50, 100)

    # C 36-51: the broad string tune; the motif augmented in the horns beneath
    for i in range(16):
        sym = BROAD_H[i % 8]
        ost(36 + i, sym, 58)
        s.bass_at((36 + i) * 4, 4, sym, 66, chs=('cb', 'vc'))
        s.pad('pad', 36 + i, sym, 56)
        s.drum(36 + i, [(0, 'bd', 0), (3, 'snare', -8)], 52)
        if i % 4 == 0:
            s.timp_hit((36 + i) * 4, p(s.voicing(sym)[0]) + 12, 76)
    s.mel('vln', 36, BROAD, 92, transpose=0)
    s.line('vln', 36, BROAD, 74, transpose=-12)
    s.motif('hn', 36, augment(motif('Bb3', 'mixolydian'), 2), 70, form='augmented (horns, under the strings)', lead=False)
    s.mel('vln', 44, BROAD, 98, transpose=0)
    s.line('fl', 44, BROAD, 70, transpose=12)
    s.motif('hn', 44, augment(motif('Eb4', 'major'), 2), 76, form='augmented on Eb (horns)', lead=False)
    s.swell('vln', 36, 16, 84, 118)
    s.snare_roll(51 * 4, 4, 40, 100)

    # D 52-67: tutti - motif in trumpets, trombones and horns, strings on top, cymbals every 4 bars
    for i in range(16):
        sym = TUNE_H[i % 8]
        drive(52 + i, sym, 84)
        s.pad('brass', 52 + i, sym, 62, low='F3', n=3)
        if i % 4 == 0:
            s.hit('crash', (52 + i) * 4, 92, dur=2)
    s.motif('tpt', 52, TUNE, 100, form='stated (tutti)')
    s.line('hn', 52, TUNE, 92, transpose=-12)
    s.line('vln', 52, TUNE, 100, transpose=12)
    s.motif('tbn', 60, augment(motif('Bb3', 'mixolydian'), 2), 84, form='augmented (trombones)', lead=False)
    s.mel('tpt', 60, TUNE, 100)
    s.line('vln', 60, TUNE, 104, transpose=12)
    s.line('picc', 60, TUNE, 64, transpose=24)
    s.swell('vln', 64, 4, 120, 100)

    # OUTRO 68-71: the ostinato alone again, same voices and level as bar 0
    intro(68)
    return s
