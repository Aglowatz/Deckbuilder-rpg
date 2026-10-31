"""MUS-SWOLY-BOSS - The Ancient Spotter (Mount Swolympus boss). 68 bars 4/4, 128 BPM, D minor. Its own track (no longer
MUS-SWOLY-BATTLE's file).
The Spotter's own idea: a stone-heavy count in the trombones and tuba - three hammered reps on D and a strained climb ("one more") that
sinks back to C# - ancient, patient, immovable. Against it the Gainlands theme (MUS-BEEF-EXP) in D minor in the horns, the Crossroads
motif inverted in the clarinet in the calm, then stated by the horns and trumpets in the climax over the Spotter's count. A clear
contrasting section (flute and harp in thin mountain air) before the big confrontation. Orchestral Beefcake palette + stone drums.
"""
from lib import Score, m, motif, motif_head, augment, transpose, p, split_beats
from lib.zones import to_mode

_BEEF = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME = to_mode(transpose(_BEEF, -8), {6: -1, 11: -1, 1: -1})      # D minor, horn register (D4)
THEME_H = ['Dm', 'Dm', 'Em7b5', 'A', 'Gm', 'Bb', 'A', 'Dm', 'Dm', 'A', 'Gm', 'A', 'C', 'Gm', 'A7', 'Dm']
SPOTTER = m('D3:1 D3:1 D3:1 F3:1 | E3:2 A2:2 | D3:1 D3:1 D3:1 G3:1 | F3:1.5 E3:.5 C#3:2')
SPOTTER_H = ['Dm', 'A', 'Dm', 'A']
AIR_H = ['F', 'C/E', 'Dm', 'Bb', 'F', 'C/E', 'Gm', 'A']
GROOVE = [(0, 'bd', 8), (1, 'snare', 0), (2, 'bd', 0), (2.5, 'bd', -12), (3, 'snare', 6)]


def build():
    s = Score('MUS-SWOLY-BOSS', bpm=128, bars=68, key='D minor', seed=813)
    s.seat('spic', 'vln', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'fl', 'cl', 'harp', 'pad', 'timp', 'perc')
    for bar, nm in ((0, 'intro count'), (4, 'A the Spotter'), (20, 'B Gainlands theme vs the count'), (36, 'C thin air'),
                    (48, 'D climax'), (64, 'outro count')):
        s.section(bar, nm)
    s.notes.append("Villain idea = SPOTTER (three hammered reps and a strained climb) in trombones + tuba; Gainlands theme in D minor.")

    def stones(bar, vel):
        s.hit('bd2', bar * 4, vel)
        s.hit('bd2', bar * 4 + 2, vel - 10)
        s.hit('bd2', bar * 4 + 3.5, vel - 18)

    def ost(bar, sym, vel):
        r = p(s.voicing(sym)[0])
        while r < p('D4'):
            r += 12
        third = r + (3 if sym.startswith(('Dm', 'Gm', 'Em')) else 4)
        for k, n in enumerate([r, r - 12, third, r - 12, r + 7, r - 12, third, r - 12]):
            s.note('spic', bar * 4 + k * .5, .35, n, vel + (8 if k % 4 == 0 else -4))

    def count(bar, vel, lead=True):
        """the Spotter's theme on trombones (tuba an octave down) with its own harmony, 4 bars"""
        (s.mel if lead else s.line)('tbn', bar, SPOTTER, vel)
        s.line('tuba', bar, SPOTTER, vel - 8, transpose=-12)

    def intro(bar):
        for i, sym in enumerate(SPOTTER_H):
            s.pad('pad', bar + i, sym, 64)
            s.brass('hn', bar + i, sym, 60, low='A3', n=3)
            stones(bar + i, 74)
            ost(bar + i, sym, 66)
            s.timp_hit((bar + i) * 4, 'D2' if sym == 'Dm' else 'A1', 76)
        s.line('tbn', bar, m('r:4 | D3:1 D3:1 D3:1 r:1 | r:4 | D3:1 D3:1 D3:1 A2:1'), 74)
        s.motif('cl', bar + 1, motif_head('D5', 'minor', rhythm=(1, .5, 2.5)), 64, form='head (clarinet, far)')
        s.swell('pad', bar + 3, 1, 90, 100)

    intro(0)

    # A 4-19: the Spotter's count, four times, growing; strings ostinato, stone drums
    for i in range(16):
        sym = SPOTTER_H[i % 4]
        bar = 4 + i
        ost(bar, sym, 70 + i)
        s.pad('pad', bar, sym, 54 + i)
        stones(bar, 70)
        s.drum(bar, GROOVE, 58 + i)
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'D2', 90)
            s.hit('crash', bar * 4, 72, dur=2)
    for k in range(4):
        count(4 + 4 * k, 86 + 4 * k)
    s.line('hn', 12, SPOTTER, 70, transpose=12)
    s.line('vln', 16, SPOTTER, 80, transpose=24)
    s.snare_roll(19 * 4, 4, 40, 96)

    # B 20-35: the Gainlands theme in D minor on the horns, then trumpets; the Spotter's count stays in the bass
    for i, sym in enumerate(THEME_H):
        bar = 20 + i
        ost(bar, sym, 74)
        s.pad('pad', bar, sym, 58)
        s.drum(bar, GROOVE, 64)
        s.note('cb', bar * 4, 3.9, p(s.voicing(sym)[0]), 70)
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'D2' if sym == 'Dm' else 'A1', 88)
    s.mel('hn', 20, THEME, 96)
    s.line('tbn', 20, m('D3:1 D3:1 D3:1 r:1') * 8, 64)
    s.line('tpt', 28, split_beats(THEME, 32, 64), 92, transpose=12)
    s.line('vln', 28, split_beats(THEME, 32, 64), 80, transpose=12)
    s.timp_roll(35 * 4, 4, 'A1', 50, 100)

    # C 36-47: contrast - thin air: flute and harp, sustained strings; the Crossroads motif inverted in the clarinet
    for i, sym in enumerate(AIR_H + AIR_H[:4]):
        bar = 36 + i
        s.harp(bar, sym, 52)
        s.pad('pad', bar, sym, 46)
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 50)
    s.motif('cl', 36, motif('D5', 'minor', inverted=True) + m('r:1'), 80, form='inverted (clarinet: the question upside down)')
    s.mel('fl', 38, augment(split_beats(THEME, 0, 7), 2) + m('r:2'), 74, transpose=12)
    s.motif('fl', 42, motif('F5', 'major') + m('r:1'), 76, form='stated (flute, in F major - the vista)')
    s.mel('cl', 44, m('A4:2 G4:2 | F4:2 E4:2 | D4:3 r:1 | C#4:4'), 70)
    s.timp_roll(46 * 4, 8, 'A1', 30, 104)
    s.snare_roll(47 * 4, 4, 30, 100)

    # D 48-63: climax - the hero's Crossroads motif in horns + trumpets against the Spotter's count in the trombones
    for i in range(16):
        sym = SPOTTER_H[i % 4]
        bar = 48 + i
        ost(bar, sym, 84)
        s.pad('pad', bar, sym, 68)
        stones(bar, 82)
        s.drum(bar, GROOVE, 72)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 92, dur=2)
            s.timp_hit(bar * 4, 'D2', 100)
    hero = motif('D4', 'minor') + m('r:1') + motif('F4', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1')
    s.motif('hn', 48, hero, 100, form='stated (horns: the hero holds the bar), sequenced up a third')
    s.line('tpt', 48, hero, 90, transpose=12)
    count(48, 92, lead=False)
    count(52, 96, lead=False)
    s.mel('tpt', 56, split_beats(THEME, 0, 32), 104, transpose=12)
    s.line('vln', 56, split_beats(THEME, 0, 32), 104, transpose=12)
    s.line('hn', 56, split_beats(THEME, 0, 32), 94)
    count(56, 100, lead=False)
    count(60, 100, lead=False)
    s.swell('vln', 56, 8, 110, 127)

    # OUTRO 64-67: the intro count again
    intro(64)
    return s
