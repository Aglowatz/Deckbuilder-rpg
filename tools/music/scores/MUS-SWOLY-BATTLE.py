"""MUS-SWOLY-BATTLE - Mount Swolympus, combat. 72 bars 4/4, 142 BPM, C minor.
The Gainlands theme (MUS-BEEF-EXP) turned to C minor and set on a climbing string ostinato with stone drums (concert bass drum, low
timpani). Two contrasting battle phrases: A the theme in the horns over the ostinato, B the Crossroads motif as a trumpet call answered by
a flute climbing on the wind; C a broad passage with the theme in the trombones and strings 8va; D a breakdown on stone drums that builds
back. Intro and outro have a brass/pad bed so the loop never thins to the ostinato alone.
"""
from lib import Score, m, motif, motif_head, augment, transpose, p, split_beats
from lib.zones import to_mode

_BEEF = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
# Bb major -> C major (+2) -> C minor (E, A, B flattened); horn register
THEME = to_mode(transpose(_BEEF, -10), {4: -1, 9: -1, 11: -1})
THEME_H = ['Cm', 'Cm', 'Dm7b5', 'G', 'Fm', 'Ab', 'G', 'Cm', 'Cm', 'G', 'Fm', 'G', 'Bb', 'Fm', 'G7', 'Cm']
CALL_H = ['Ab', 'Ab', 'Fm', 'G', 'Ab', 'Bb', 'Eb', 'G']
BREAK_H = ['Cm', 'Bb', 'Ab', 'G'] * 2
GROOVE = [(0, 'bd', 8), (1, 'snare', 0), (1.5, 'bd', -10), (2, 'bd', 0), (3, 'snare', 4), (3.75, 'snare', -16)]


def build():
    s = Score('MUS-SWOLY-BATTLE', bpm=142, bars=72, key='C minor', seed=812)
    s.seat('spic', 'vln', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'fl', 'pad', 'timp', 'perc')
    for bar, nm in ((0, 'intro bed'), (4, 'A theme'), (20, 'B call and climb'), (36, 'C broad'), (52, 'D stone breakdown'),
                    (68, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('Gainlands theme in C minor; climbing string ostinato; stone drums; orchestral.')

    def ost(bar, sym, vel):
        r = p(s.voicing(sym)[0])
        while r < p('C4'):
            r += 12
        third = r + (3 if 'm' in sym.split('/')[0][1:] or sym.startswith('Dm') else 4)
        cell = [r, r + 7, r + 12, r + 7, third + 12, r + 7, r + 12, r + 14]
        acc = [10, -6, 2, -6, 6, -6, 2, -4]
        for k, (n, a) in enumerate(zip(cell, acc)):
            s.note('spic', bar * 4 + k * .5, .35, n - 12, vel + a)

    def drive(bar, sym, vel, drums=True):
        ost(bar, sym, vel)
        s.bass(bar, sym, vel - 6, 'pulse', chs=('cb', None))
        if drums:
            s.drum(bar, GROOVE, vel - 8)
            s.hit('bd2', bar * 4, vel - 4)

    def bed(bar):
        for i, sym in enumerate(['Cm', 'Cm', 'Ab', 'G']):
            drive(bar + i, sym, 72)
            s.pad('pad', bar + i, sym, 62)
            s.brass('hn', bar + i, sym, 64, low='G3', n=3)
            s.timp_hit((bar + i) * 4, 'C2' if sym == 'Cm' else 'G1', 70)
        s.motif('tpt', bar + 1, motif_head('C4', 'minor', rhythm=(1, .5, 2.5)), 76, form='head (trumpet call)')
        s.swell('pad', bar + 3, 1, 90, 100)

    bed(0)

    # A 4-19: the theme in the horns over the ostinato
    for i, sym in enumerate(THEME_H):
        bar = 4 + i
        drive(bar, sym, 74 if i < 8 else 80)
        s.pad('pad', bar, sym, 50)
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'C2', 86)
            s.hit('crash', bar * 4, 70, dur=2)
    s.mel('hn', 4, THEME, 96)
    s.line('tbn', 12, split_beats(THEME, 32, 64), 72, transpose=-12)
    s.line('vln', 12, split_beats(THEME, 32, 64), 82, transpose=12)

    # B 20-35: phrase two - the Crossroads motif as a trumpet call, a flute climbing on the wind in answer
    for k in range(2):
        for i, sym in enumerate(CALL_H):
            bar = 20 + 8 * k + i
            drive(bar, sym, 70 + 4 * k, drums=(i % 2 == 0 or k == 1))
            s.pad('pad', bar, sym, 58)
            s.brass('tbn', bar, sym, 56, low='F3', n=3)
    s.motif('tpt', 20, motif('C5', 'minor') + m('r:1'), 94, form='stated (trumpets)')
    s.mel('fl', 22, m('G5:.5 Ab5:.5 Bb5:.5 C6:.5 D6:1 Eb6:1 | F6:2 Eb6:1 D6:1'), 78)
    s.motif('tpt', 24, motif('Ab4', 'major') + m('r:1'), 92, form='stated on Ab (trumpets)')
    s.mel('fl', 26, m('Bb5:.5 C6:.5 D6:.5 Eb6:.5 F6:1 G6:1 | G6:2 F6:1 D6:1'), 80)
    s.motif('hn', 28, motif('C4', 'minor', rhythm=[2, 1, 1, 3, 1, 8]), 90, form='augmented (horns), trumpets answer with the theme head')
    s.mel('tpt', 30, split_beats(THEME, 0, 8), 88, transpose=12)
    s.swell('pad', 28, 8, 70, 110)
    s.timp_roll(35 * 4, 4, 'G1', 50, 104)

    # C 36-51: broad - theme in the trombones, strings 8va, horns chords
    for i, sym in enumerate(THEME_H):
        bar = 36 + i
        drive(bar, sym, 80)
        s.brass('hn', bar, sym, 66, low='G3', n=3)
        s.pad('pad', bar, sym, 62)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 82, dur=2)
            s.timp_hit(bar * 4, 'C2', 94)
    s.mel('vln', 36, THEME, 98, transpose=12)
    s.line('tbn', 36, THEME, 86, transpose=-12)
    s.line('tpt', 44, split_beats(THEME, 32, 64), 86, transpose=12)

    # D 52-67: stone breakdown - drums and low strings, the theme head on the horns, then the climb back
    for i, sym in enumerate(BREAK_H * 2):
        bar = 52 + i
        s.hit('bd2', bar * 4, 84)
        s.hit('bd2', bar * 4 + 1.5, 66)
        s.hit('bd2', bar * 4 + 2.5, 74)
        if sym in ('Cm', 'G'):
            s.timp_hit(bar * 4, 'C2' if sym == 'Cm' else 'G1', 70 + i)
        s.bass(bar, sym, 60 + i, 'march', chs=('cb', None))
        s.note('vc', bar * 4, 3.9, p(s.voicing(sym)[0]) + 12, 54 + i)
        s.pad('pad', bar, sym, 52 + i * 2)
        if i >= 8:
            ost(bar, sym, 60 + (i - 8) * 3)
    s.mel('hn', 52, split_beats(THEME, 0, 16), 84)
    s.mel('hn', 56, split_beats(THEME, 0, 16), 88, transpose=2)
    s.mel('tpt', 60, split_beats(THEME, 0, 16), 90, transpose=12)
    s.motif('tpt', 64, motif_head('C5', 'minor', rhythm=(1, 1, 2)) + motif_head('Eb5', 'minor', rhythm=(1, 1, 2)), 96,
            form='head twice, climbing (trumpets)')
    s.snare_roll(66 * 4, 8, 40, 100)
    s.timp_roll(67 * 4 + 2, 2, 'G2', 60, 100)

    # OUTRO 68-71: the bed (bar 0's voices)
    bed(68)
    return s
