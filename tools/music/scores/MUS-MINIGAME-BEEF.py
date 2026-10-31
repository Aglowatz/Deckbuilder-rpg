"""MUS-MINIGAME-BEEF - Chet's revolutionary routine (aerobics bravado). 36 bars 4/4, 128 BPM, Bb major (67.5 s loop).
A four-on-the-floor orchestral workout: concert bass drum on every beat, claps on 2 and 4, a bouncing octave bass, string stabs on the
off-beats. The Gainlands theme (MUS-BEEF-EXP) as a trumpet show-off, then the strings with xylophone, a restrained retro square-wave wink
doubling a counterline, a "stretch" breakdown with the Crossroads motif on the horns, and a tutti rep before the count-in comes round.
"""
from lib import Score, m, motif, motif_head, voice, p, split_beats

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
HALF1, HALF2 = split_beats(THEME, 0, 32), split_beats(THEME, 32, 64)
H1 = ['Bb', 'Bb', 'Cm7', 'F', 'Eb', 'Gm', 'F', 'Bb']
H2 = ['Bb', 'F', 'Eb', 'F', 'Ab', 'Eb', 'F7', 'Bb']
COUNTER = m('D5:1 F5:1 Bb5:1 F5:1 | C5:1 F5:1 A5:1 F5:1 | Bb4:1 Eb5:1 G5:1 Eb5:1 | C5:1 F5:1 A5:1 C6:1 '
            '| C5:1 Eb5:1 Ab5:1 Eb5:1 | Bb4:1 Eb5:1 G5:1 Bb5:1 | A4:1 C5:1 Eb5:1 F5:1 | D5:2 Bb4:2')


def build():
    s = Score('MUS-MINIGAME-BEEF', bpm=128, bars=36, key='Bb major', seed=815)
    s.seat('tpt', 'hn', 'tbn', 'vln', 'spic', 'cb', 'vc', 'pad', 'xylo', 'timp', 'perc')
    s.channel('wink', 80, pan=40, reverb=60, vol=46)          # GM square lead: the restrained retro wink
    for bar, nm in ((0, 'count-in'), (4, 'A trumpet rep'), (12, 'B strings + xylophone'), (20, 'C stretch'), (28, 'D tutti rep'),
                    (32, 'count-in again')):
        s.section(bar, nm)
    s.notes.append('Four-on-the-floor on the orchestra kit; the only synth is a quiet GM square-lead wink in section B.')

    def workout(bar, sym, vel, stabs=True):
        b = p(s.voicing(sym)[0])
        for k in range(8):
            s.note('cb', bar * 4 + k * .5, .35, b + (12 if k % 2 else 0), vel + (6 if k % 2 == 0 else -6))
        s.drum(bar, [(0, 'bd', 6), (1, 'bd', 0), (1, 'clap', -6), (2, 'bd', 2), (3, 'bd', 0), (3, 'clap', -2)], vel)
        s.drum(bar, [(k + .5, 'tamb', -26) for k in range(4)], vel)
        if stabs:
            for t in (.5, 1.5, 2.5, 3.5):
                for n in voice(sym, 'F4', 3):
                    s.note('spic', bar * 4 + t, .25, n, vel - 14)

    def count_in(bar):
        for i, sym in enumerate(['Bb', 'Eb', 'Bb', 'F']):
            workout(bar + i, sym, 70)
            s.pad('pad', bar + i, sym, 56)
            s.brass('hn', bar + i, sym, 58, low='F3', n=3)
        for k, n in enumerate(['F4', 'G4', 'A4', 'Bb4']):          # "five, six, seven, eight" on the trumpet
            s.note('tpt', (bar + 3) * 4 + k, .4, n, 76)
        s.motif('hn', bar + 1, motif_head('Bb3', 'major', rhythm=(1, .5, 2.5)), 70, form='head (horns, warming up)')
        s.tag_melody('tpt', bar + 3, bar + 4)
        s.mel('xylo', bar, m('Bb5:.5 F5:.5 Bb5:.5 D6:.5 r:2'), 66)

    count_in(0)

    # A 4-11: the trumpet shows off the first half of the theme
    for i, sym in enumerate(H1):
        workout(4 + i, sym, 76)
        s.pad('pad', 4 + i, sym, 50)
    s.motif('tpt', 4, HALF1[:6], 96, form='stated (trumpet: the Gainlands fanfare, showing off)')
    s.mel('tpt', 4, HALF1[6:], 96, beat=7)
    s.line('tbn', 4, HALF1, 66, transpose=-12)
    s.hit('crash', 4 * 4, 74, dur=2)

    # B 12-19: strings + xylophone on the second half; the square-wave wink doubles a counterline, quietly
    for i, sym in enumerate(H2):
        workout(12 + i, sym, 78)
        s.brass('hn', 12 + i, sym, 54, low='F3', n=3)
    s.mel('vln', 12, HALF2, 92, transpose=12)
    s.line('xylo', 12, HALF2, 66, transpose=12)
    s.line('wink', 12, COUNTER, 60)
    s.hit('crash', 12 * 4, 76, dur=2)

    # C 20-27: the stretch - drums thin to claps, held chords, the Crossroads motif on the horns
    for i, sym in enumerate(['Eb', 'Eb', 'Bb/D', 'Bb/D', 'Cm7', 'Cm7', 'F', 'F']):
        bar = 20 + i
        s.pad('pad', bar, sym, 62)
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 62)
        s.drum(bar, [(1, 'clap', -4), (3, 'clap', 0)], 70)
        s.drum(bar, [(0, 'bd', 0), (2, 'bd', -8)], 60 + i * 2)
    s.motif('hn', 20, motif('Bb3', 'major') + m('r:1'), 88, form='stated (horns, the stretch)')
    s.motif('tpt', 24, motif('Eb4', 'major') + m('r:1'), 86, form='stated on Eb (trumpet)')
    s.line('vln', 22, m('G5:4 | F5:4 | Eb5:4 | F5:4 | G5:4 | A5:4'), 64)
    s.snare_roll(27 * 4, 4, 40, 100)

    # D 28-31: tutti rep on the first half (compressed), then into the count-in
    for i, sym in enumerate(['Bb', 'Cm7', 'Eb', 'F']):
        workout(28 + i, sym, 84)
        s.pad('pad', 28 + i, sym, 62)
        s.timp_hit((28 + i) * 4, 'Bb2' if sym == 'Bb' else 'F2', 84)
    rep = split_beats(HALF1, 0, 16)
    s.mel('tpt', 28, rep, 100)
    s.line('vln', 28, rep, 96, transpose=12)
    s.line('hn', 28, rep, 84, transpose=-12)
    s.hit('crash', 28 * 4, 86, dur=2)

    count_in(32)
    return s
