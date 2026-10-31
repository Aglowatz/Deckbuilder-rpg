"""MUS-SWOLY-EXP - Mount Swolympus, exploration. 56 bars 4/4, 100 BPM, Eb major.
The Gainlands march theme (MUS-BEEF-EXP) carried up a mountain: a lone flute on the wind over open fifths and stone-like drums (concert
bass drum, low timpani), then the theme climbs in the horns phrase by phrase, a broad string vista with the theme 8va over warm brass
chords, a high thin-air passage (flute, harp, the Crossroads motif on the flute) and the summit tutti. Orchestral Beefcake palette.
"""
from lib import Score, m, motif, motif_head, augment, transpose, voice, p, split_beats

# The Gainlands zone theme (MUS-BEEF-EXP THEME, Bb major) moved up a fourth to Eb major.
_BEEF = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME = transpose(_BEEF, -7)          # Eb4 ... (horn/string register)
THEME_H = ['Eb', 'Eb', 'Fm7', 'Bb', 'Ab', 'Cm', 'Bb', 'Eb', 'Eb', 'Bb', 'Ab', 'Bb', 'Db', 'Ab', 'Bb7', 'Eb']
AIR_H = ['Ab', 'Eb/G', 'Fm7', 'Bbsus4', 'Ab', 'Eb/G', 'Cm', 'Bb']
WIND = m('r:1 Bb5:2 G5:1 | Ab5:2 F5:2 | Eb5:3 F5:1 | Bb4:4')


def build():
    s = Score('MUS-SWOLY-EXP', bpm=100, bars=56, key='Eb major', seed=811)
    s.seat('hn', 'tpt', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'fl', 'harp', 'cl', 'timp', 'perc')
    for bar, nm in ((0, 'intro wind'), (4, 'A climb'), (20, 'B vista'), (36, 'C thin air'), (44, 'D summit'), (52, 'outro wind')):
        s.section(bar, nm)
    s.notes.append('Gainlands theme (BEEF-EXP) in Eb; stone percussion = concert bass drum + low timpani; orchestral.')

    def stone(bar, vel, full=False):
        s.hit('bd2', bar * 4, vel)
        s.hit('bd2', bar * 4 + 2.5, vel - 14)
        if full:
            s.hit('bd', bar * 4 + 3, vel - 10)

    def fifths(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 4, 4.02, b, vel)
        s.note('vc', bar * 4, 4.02, b + 7 + 12, vel - 10)

    def wind(bar):
        for i, sym in enumerate(['Eb', 'Ab', 'Eb', 'Bb']):
            s.pad('pad', bar + i, sym, 50, low='Bb3', n=3)
            fifths(bar + i, sym, 54)
            stone(bar + i, 58)
        s.expr('pad', bar, 78)
        s.mel('fl', bar, WIND, 70)
        s.timp_roll((bar + 3) * 4 + 2, 2, 'Bb1', 30, 62)       # rolls into the next bar (the loop point at the outro)
        s.swell('pad', bar + 3, 1, 78, 84)

    wind(0)

    # A 4-19: the theme climbs in the horns, phrase by phrase; strings join for the second half
    for i, sym in enumerate(THEME_H):
        bar = 4 + i
        s.pad('pad', bar, sym, 52 if i < 8 else 58)
        s.bass(bar, sym, 60, 'half', chs=('cb', 'vc'))
        stone(bar, 62, full=i >= 8)
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'Eb2' if sym.startswith('Eb') else 'Bb1', 74)
        if i >= 8:
            s.harp(bar, sym, 50)
    s.motif('hn', 4, THEME[:6], 86, form='stated (horns: the Gainlands fanfare, climbing)')
    s.mel('hn', 4, THEME[6:], 86, beat=7)
    s.line('vln', 12, split_beats(THEME, 32, 64), 70, transpose=12)
    s.swell('vln', 12, 8, 60, 100)

    # B 20-35: the vista - strings 8va on the theme over warm brass chords, tuba roots
    for i, sym in enumerate(THEME_H):
        bar = 20 + i
        s.brass('tbn', bar, sym, 58, low='Eb3', n=3)
        s.note('tuba', bar * 4, 3.8, p(s.voicing(sym)[0]), 64)
        s.pad('pad', bar, sym, 60)
        s.harp(bar, sym, 52, density=16)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 62, dur=2)
            s.timp_roll(bar * 4 - 1, 1, 'Bb1', 40, 70)
    s.mel('vln', 20, THEME, 92, transpose=12)
    s.line('hn', 20, THEME, 74)
    s.motif('tpt', 28, motif_head('Eb4', 'major', rhythm=(2, 1, 5)), 70, form='head (trumpet, distant, augmented)', lead=False)
    s.swell('vln', 20, 16, 90, 116, 'arch')

    # C 36-43: thin air - flute and harp only, the Crossroads motif on the flute, clarinet answers
    for i, sym in enumerate(AIR_H):
        bar = 36 + i
        s.harp(bar, sym, 48)
        s.pad('pad', bar, sym, 40, low='Bb3', n=3)
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 46)
    s.motif('fl', 36, motif('Eb5', 'major') + m('r:1'), 78, form='stated (flute, thin air)')
    s.mel('cl', 38, m('Ab4:2 G4:2 | F4:3 r:1'), 66)
    s.motif('fl', 40, motif('Ab5', 'major', rhythm=[1, .5, .5, 1.5, .5, 3]) + m('r:1'), 74, form='stated a fourth higher (flute)')
    s.mel('cl', 42, m('Eb5:2 D5:2 | C5:2 D5:2'), 66)
    s.timp_roll(43 * 4, 4, 'Bb1', 36, 96)

    # D 44-51: the summit - tutti on the first half of the theme, trumpets on top
    for i, sym in enumerate(THEME_H[:8]):
        bar = 44 + i
        s.brass('tbn', bar, sym, 70, low='Eb3', n=3)
        s.note('tuba', bar * 4, 1.8, p(s.voicing(sym)[0]), 76)
        s.note('tuba', bar * 4 + 2, 1.8, p(s.voicing(sym)[0]), 70)
        s.pad('pad', bar, sym, 66)
        s.harp(bar, sym, 56, density=16)
        stone(bar, 72, full=True)
        if i % 2 == 0:
            s.hit('crash', bar * 4, 76, dur=2)
            s.timp_hit(bar * 4, 'Eb2', 90)
    half = split_beats(THEME, 0, 32)
    s.mel('tpt', 44, half, 96, transpose=12)
    s.line('hn', 44, half, 90)
    s.line('vln', 44, half, 96, transpose=12)
    s.line('fl', 44, half, 70, transpose=24)
    s.swell('vln', 44, 8, 110, 96)
    s.timp_roll(51 * 4 + 2, 2, 'Bb1', 70, 40)

    # OUTRO 52-55: the wind again (bar 0's voices and level)
    wind(52)
    return s
