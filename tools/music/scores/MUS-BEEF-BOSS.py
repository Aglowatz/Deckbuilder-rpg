"""MUS-BEEF-BOSS - Chancellor Clench, Iron Regent. 80 bars 4/4, 126 BPM, F minor.
Clench's own idea: a pompous brass boast that climbs (F F F Ab C Db) and then deflates chromatically to an unresolved E - strength
without heart, an insecure figurehead. Under it the endless energy wheel: violas turning in a narrow chromatic circle, and Quota's stopwatch
(metronome click, a bell every two bars). The Crossroads motif appears inverted (the question turned upside down), then the hero's own
form fights back in the climax against Clench's theme in the trombones. The phrases constrict (4 bars, 2, 1, half) before a comic
deflation - Clench's theme on a lonely bassoon - and the big climax. Orchestral by the Music Pass 1 brief.
"""
from lib import Score, m, motif, motif_head, p

CLENCH = m('F4:1 F4:.5 F4:.5 Ab4:1 C5:1 | Db5:2 C5:1 B4:1 | C5:1 Bb4:.5 Ab4:.5 G4:1 F4:1 | E4:3 r:1')
CLENCH_H = ['Fm', 'Dbmaj7', 'Bbm6', 'C']
B_LINE = m('F4:1 Bb3:.5 C4:.5 Db4:1.5 Eb4:.5 | Bb3:3 r:1 | Ab4:1 Gb4:1 F4:1 E4:1 | F4:4 '
           '| Bb4:1 Bb4:.5 Bb4:.5 Db5:1 F5:1 | Gb5:2 F5:1 E5:1 | F5:1 Eb5:.5 Db5:.5 C5:1 Bb4:1 | E5:3 r:1')
B_H = ['Fm', 'Gb', 'Fm', 'Fm', 'Bbm', 'Gb', 'Db', 'C']
WHEEL = [0, 1, 0, -1, 0, 3, 2, 1]


def build():
    s = Score('MUS-BEEF-BOSS', bpm=126, bars=80, key='F minor', seed=205)
    s.seat('vla', 'vc', 'cb', 'vln', 'trem', 'hn', 'tpt', 'tbn', 'bsn', 'cl', 'timp', 'xylo', 'pizz', 'perc')
    for bar, nm in ((0, 'intro wheel'), (4, 'A Clench'), (20, 'B drive'), (36, 'C constriction'), (48, 'D deflation'),
                    (56, 'E climax'), (72, 'wind-down'), (76, 'outro wheel')):
        s.section(bar, nm)
    s.notes.append('Villain idea = CLENCH (boast + chromatic deflation) and the wheel ostinato; orchestral by the Music Pass 1 brief '
                   '(the old row asked for metal).')

    def wheel(bar, sym, vel, rate=2):
        r = p(s.voicing(sym)[0])
        while r < p('E3'):
            r += 12
        step = 1 / rate
        for k in range(int(4 * rate)):
            s.note('vla', bar * 4 + k * step, step * 0.85, r + WHEEL[k % 8], vel + (8 if k % 4 == 0 else -4))

    def stopwatch(bar, vel):
        s.drum(bar, [(k * .5, 'click', -6 if k % 2 == 0 else -14) for k in range(8)], vel)
        if bar % 2 == 0:
            s.hit(34, bar * 4, vel + 4)

    def pedal(bar, sym, vel, timp=True):
        b = p(s.voicing(sym)[0])
        for k in range(4):
            s.note('cb', bar * 4 + k, .7, b, vel + (8 if k == 0 else -4))
        if timp:
            s.timp_hit(bar * 4, b if b >= p('D2') else b + 12, vel + 4)

    def stab(bar, sym, vel):
        r = p(s.voicing(sym)[0])
        while r < p('C3'):
            r += 12
        for n in (r, r + 7):
            s.note('tbn', bar * 4, .6, n, vel)

    def intro(bar):
        for i, sym in enumerate(['Fm', 'Fm', 'Fm', 'C']):
            wheel(bar + i, sym, 78)
            stopwatch(bar + i, 62)
            pedal(bar + i, sym, 72, timp=(i % 2 == 1))
            s.pad('trem', bar + i, sym, 74, low='F3')
            s.brass('hn', bar + i, sym, 68, low='C4', n=2)
            s.drum(bar + i, [(0, 'bd', 0), (2, 'bd', -12)], 70)
            stab(bar + i, sym, 58 if i == 0 else 70)
        s.motif('hn', bar + 2, m('F4:1 Bb3:.5 C4:.5 Db4:2'), 72, form='inverted head (horns)')

    intro(0)
    s.snare_roll(3 * 4 + 2, 2, 40, 86)

    # A 4-19: Clench's theme, four times - trombones and horns, then trumpets with tremolo strings
    for i in range(16):
        sym = CLENCH_H[i % 4]
        wheel(4 + i, sym, 72 if i < 8 else 78)
        stopwatch(4 + i, 58)
        pedal(4 + i, sym, 70 if i < 8 else 78, timp=(i % 2 == 0))
        s.drum(4 + i, [(0, 'bd', 0), (2, 'snare', -4), (3, 'snare', -12)], 60)
        if i >= 8:
            s.pad('trem', 4 + i, sym, 58, low='F3')
    s.mel('tbn', 4, CLENCH * 2, 92)
    s.line('hn', 4, CLENCH * 2, 76)
    s.mel('tpt', 12, CLENCH * 2, 94)
    s.line('tbn', 12, CLENCH * 2, 86, transpose=-12)
    s.line('hn', 12, CLENCH * 2, 82)
    s.hit('crash', 12 * 4, 80, dur=2)
    s.motif('hn', 7, m('r:1 F4:1 Bb3:.5 C4:.5 Db4:1'), 64, form='inverted head (horn, answering the boast)', lead=False)
    s.timp_roll(19 * 4, 4, 'C3', 50, 100)

    # B 20-35: drive - the inverted motif in the horns, Clench's head in the trumpets, a drum groove
    for i in range(16):
        sym = B_H[i % 8]
        wheel(20 + i, sym, 76)
        pedal(20 + i, sym, 78, timp=True)
        s.drum(20 + i, [(0, 'bd', 8), (1, 'snare', 0), (1.5, 'bd', -10), (2, 'bd', 0), (3, 'snare', 6), (3.75, 'snare', -14)], 62)
        if i >= 8:
            s.pad('trem', 20 + i, sym, 62, low='F3')
    s.motif('hn', 20, B_LINE, 94, form='inverted, stated (horns)')
    s.line('tbn', 20, B_LINE, 72, transpose=-12)
    s.motif('tpt', 28, B_LINE, 96, form='inverted, stated (trumpets, strings 8va)')
    s.line('hn', 28, B_LINE, 84)
    s.line('vln', 28, B_LINE, 84, transpose=12)
    s.hit('crash', 28 * 4, 84, dur=2)

    # C 36-47: constriction - the phrase shrinks (4 bars, 2, 1, a half) and the wheel spins twice as fast
    spec = ['Fm', 'Dbmaj7', 'Bbm6', 'C', 'Fm', 'Dbmaj7', 'Fm', 'Dbmaj7', 'C7', 'C7', 'C7', 'C7']
    for i, sym in enumerate(spec):
        bar = 36 + i
        wheel(bar, sym, 70 + i * 2, rate=2 if i < 4 else 4)
        pedal(bar, sym, 72 + i, timp=(i < 8))
        stopwatch(bar, 56 + i)
        s.drum(bar, [(0, 'bd', 0), (2, 'snare', -4)], 60 + i)
    s.mel('tpt', 36, CLENCH, 90)
    s.line('tbn', 36, CLENCH, 80, transpose=-12)
    s.mel('tpt', 40, m('F4:1 F4:.5 F4:.5 Ab4:1 C5:1 | Db5:4'), 92)
    s.mel('tpt', 42, m('F4:1 F4:.5 F4:.5 Ab4:2 | F4:1 F4:.5 F4:.5 Ab4:2'), 94)
    s.mel('tpt', 44, [('F4' if k % 2 == 0 else 'Gb4', .5) for k in range(32)], 92, shape=False)
    s.line('tbn', 40, m('F3:4 | F3:4 | F3:4 | F3:4 | E3:4 | E3:4 | E3:4 | E3:4'), 76)
    s.swell('tpt', 44, 4, 90, 127)
    s.swell('vla', 44, 4, 90, 127)
    s.snare_roll(44 * 4, 16, 40, 110)
    s.timp_roll(46 * 4, 8, 'C3', 60, 112)

    # D 48-55: deflation - Clench's boast on a lonely bassoon over pizzicato; a clarinet asks the hero's question
    for i in range(8):
        sym = CLENCH_H[i % 4]
        s.pizz(48 + i, sym, 58)
        s.note('cb', (48 + i) * 4, 1, p(s.voicing(sym)[0]), 56)
        stopwatch(48 + i, 46)
    s.mel('bsn', 48, CLENCH, 86, transpose=-12)
    s.line('xylo', 51, m('r:3 E5:1'), 66)
    s.motif('cl', 52, m('F4:1 C5:.5 Bb4:.5 Ab4:1.5 G4:.5 | C5:3 r:1'), 80, form='stated (clarinet, the hero answers)')
    s.mel('cl', 54, m('Db5:2 C5:2 | E4:4'), 74)
    s.timp_roll(54 * 4, 8, 'C3', 30, 108)
    s.snare_roll(55 * 4, 4, 30, 100)

    # E 56-71: climax - the hero's motif in horns and trumpets against Clench's theme in the trombones
    for i in range(16):
        sym = CLENCH_H[i % 4]
        bar = 56 + i
        wheel(bar, sym, 84)
        pedal(bar, sym, 88)
        s.pad('trem', bar, sym, 70, low='F3')
        s.drum(bar, [(0, 'bd', 8), (1, 'snare', 0), (2, 'bd', 0), (3, 'snare', 6), (3.5, 'snare', -10)], 70)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 96, dur=2)
    hero = m('F4:1 C5:.5 Bb4:.5 Ab4:1.5 G4:.5 | C5:3 r:1 | Bb4:1 F5:.5 Eb5:.5 Db5:1.5 C5:.5 | E5:3 r:1')
    s.motif('hn', 56, hero, 100, form='stated (horns: the hero fights back), then sequenced up a fourth')
    s.line('tpt', 56, hero, 88)
    s.line('tbn', 56, CLENCH, 92, transpose=-12)
    s.motif('tpt', 60, hero, 104, form='stated (tutti, strings 8va)')
    s.line('hn', 60, hero, 100)
    s.line('vln', 60, hero, 100, transpose=12)
    s.line('tbn', 60, CLENCH, 96, transpose=-12)
    s.mel('tpt', 64, CLENCH * 2, 108)
    s.line('hn', 64, CLENCH * 2, 98)
    s.line('vln', 64, CLENCH * 2, 104, transpose=12)
    s.line('tbn', 64, CLENCH * 2, 92, transpose=-12)
    s.motif('hn', 66, motif_head('F4', 'minor', rhythm=(1, .5, 2.5)), 90, form='head (horns, under the theme)', lead=False)
    s.swell('vln', 64, 8, 110, 127)

    # wind-down 72-75: the wheel slows back to the intro texture
    for i, sym in enumerate(['Fm', 'Dbmaj7', 'Bbm6', 'C']):
        wheel(72 + i, sym, 78 - i * 2)
        pedal(72 + i, sym, 74 - i * 2)
        stopwatch(72 + i, 58)
        stab(72 + i, sym, 76 - i * 2)
    s.mel('hn', 72, m('F4:1 Bb3:.5 C4:.5 Db4:2 | C4:4 | Db4:2 C4:2 | B3:2 C4:2'), 82)

    # OUTRO 76-79: as bar 0
    intro(76)
    s.snare_roll(79 * 4 + 2, 2, 40, 86)
    return s
