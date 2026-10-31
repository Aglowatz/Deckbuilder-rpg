"""MUS-SHOP-BENCHLEY - The gym pro shop. 32 bars 4/4, 104 BPM, F major (73.8 s loop).
A relaxed Beefcake groove: plucked acoustic bass, soft brush drums, warm horn chords on the off-beats. The Gainlands theme (MUS-BEEF-EXP)
strolls through in F with maj7/6 harmony: warm horn, then clarinet, then a muted trumpet with xylophone winks (the Crossroads motif's head
as a little joke), then horn and flute together. Motivational bounce without combat intensity.
"""
import re

from lib import Score, m, motif, motif_head, transpose, voice, p, split_beats

_BEEF = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
THEME = transpose(_BEEF, -5)                     # F4 ...
HALF1, HALF2 = split_beats(THEME, 0, 32), split_beats(THEME, 32, 64)
H = ['Fmaj7', 'F6', 'Gm7', 'C7', 'Bbmaj7', 'Dm7', 'C7', 'F6', 'Fmaj7', 'C7', 'Bbmaj7', 'C7', 'Ebmaj7', 'Bbmaj7', 'C7', 'F6']


def build():
    s = Score('MUS-SHOP-BENCHLEY', bpm=104, bars=32, key='F major', seed=814)
    s.swing = 0.1
    s.seat('hn', 'tpt', 'cl', 'fl', 'pad', 'pizz', 'xylo', tpt={'inst': 'muted_tpt', 'vol': 80})
    s.channel('pbass', 'ac_bass', pan=70, reverb=60, vol=96)
    s.channel('perc', 'brush_kit', pan=64, reverb=70, vol=84)
    s.channel('hnc', 'horn', pan=84, reverb=95, vol=78)
    for bar, nm in ((0, 'A horn'), (8, 'B clarinet'), (16, 'C muted trumpet + xylophone'), (24, "A' horn + flute")):
        s.section(bar, nm)
    s.notes.append('Gainlands theme in F, relaxed (swing 0.1); acoustic bass + brush kit for the shop groove; no guitars.')

    def groove(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        if b < p('A1'):
            b += 12
        for t, n, d, a in ((0, b, .8, 6), (1.5, b + 7, .4, -8), (2, b, .8, 0), (3.5, b + (3 if re.match(r'^[A-G][b#]?m(?!aj)', sym) else 4) + 12, .4, -10)):
            s.note('pbass', bar * 4 + t, d, n, vel + a)
        s.drum(bar, [(0, 'bd', 0), (1, 'snare', -16), (2.5, 'bd', -10), (3, 'snare', -12)], vel - 14)
        s.drum(bar, [(k * .5, 'hihat', -24 if k % 2 else -18) for k in range(8)], vel - 6)
        for t in (1, 3):
            for n in voice(sym, 'A3', 3):
                s.note('hnc', bar * 4 + t, .5, n, vel - 22)

    for k in range(2):
        for i, sym in enumerate(H):
            bar = 16 * k + i
            groove(bar, sym, 70 if not (k == 1 and i < 8) else 74)
            s.pad('pad', bar, sym, 40, low='A3', n=3)
    s.expr('pad', 0, 70)

    # A 0-7: warm horn on the first half of the theme
    s.motif('hn', 0, HALF1[:6], 82, form='stated (horn: the Gainlands fanfare, relaxed)')
    s.mel('hn', 0, HALF1[6:], 82, beat=7)
    # B 8-15: clarinet takes the second half; the horn hums the Crossroads motif under it
    s.mel('cl', 8, HALF2, 80)
    s.motif('hn', 10, motif('F3', 'major') + m('r:1'), 58, form='stated (horn, low countermelody)', lead=False)
    # C 16-23: muted trumpet, xylophone winks
    s.mel('tpt', 16, HALF1, 84)
    s.motif('xylo', 19, m('r:3') + [(n, .25) for n, _ in motif_head('C6', 'major')] + m('r:.25'), 70, form='head (xylophone wink)',
            lead=False)
    s.line('xylo', 23, m('r:2 C6:.25 r:.25 C6:.25 r:.25 F6:1'), 70)
    s.pizz(16, 'Fmaj7', 46)
    s.pizz(20, 'Bbmaj7', 46)
    # A' 24-31: horn + flute 8va on the second half, and the loop strolls back to bar 0
    s.mel('hn', 24, HALF2, 80)
    s.line('fl', 24, HALF2, 64, transpose=12)
    s.line('hn', 31, m('r:3 C4:.5 E4:.5'), 74)          # a pickup back into bar 0
    s.line('fl', 31, m('r:3 C5:.5 E5:.5'), 58)
    return s
