"""MUS-SHOP-BELLOWS - Browsing the prizes (Grand Clashatorium, VS-BELLOWS). Loop, 32 bars 4/4, 100 BPM, F major (76.8 s).
Showmanship at rest: a restrained fanfare (muted trumpet and horn, a flourish of flute) over light strings - then long calm stretches of
pizzicato, harp and a lazy clarinet for choosing encounters, the showman leaning on the counter. The Crossroads motif dressed as a little
fanfare on the horn. The loud spectacle is saved for the arena battle.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, shop_bass, gliss

FANFARE = m('C5:.5 C5:.25 C5:.25 F5:1 A5:1 G5:.5 F5:.5 | G5:3 r:1 | A5:.5 A5:.25 A5:.25 Bb5:1 G5:1 E5:.5 C5:.5 | F5:3 r:1')
CALM = m('A4:2 C5:1 F5:1 | E5:2 D5:2 | Bb4:2 D5:1 G5:1 | F5:2 E5:2 | D5:1 E5:1 F5:1 A5:1 | G5:2 C5:2 | Bb4:1 A4:1 G4:1 E4:1 | F4:4')
H = ['F', 'C7', 'Bb C7', 'F']
CALM_H = ['F', 'Am7', 'Gm7', 'C7', 'Dm7', 'Gm7', 'C7sus4 C7', 'F']


def build():
    s = Score('MUS-SHOP-BELLOWS', bpm=100, bars=32, key='F major', seed=719)
    s.seat('hn', 'fl', 'cl', 'pad', 'harp', 'pizz', 'vc', 'cb', 'timp', 'glock')
    s.channel('mtpt', 'muted_tpt', pan=70, reverb=90, vol=82)
    for bar, nm in ((0, 'fanfare (restrained)'), (4, 'A calm: clarinet'), (12, 'fanfare'), (16, 'B calm: flute and harp'),
                    (24, 'C the motif as a fanfare'), (28, 'calm')):
        s.section(bar, nm)
    s.notes.append('Showman at rest: two short restrained fanfares, long calm pizz/harp stretches; no snare, no loud spectacle.')

    def calm(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            tn = s.chord_tones(sym, p('A3'), 4)
            for k, b in enumerate((0, 1, 2, 3)):
                if b < d - 1e-6:
                    s.note('pizz', t + b, .4, tn[k % 4] if k else tn[0] - 12, vel - (0 if k == 0 else 8))
        shop_bass(s, bar, spec, vel, ch='cb', style='two')

    def fanfare(bar):
        for i, spec in enumerate(H):
            calm(bar + i, spec, 58)
            bed(s, bar + i, spec, 46, ch='pad', low='A3', n=4)
            s.brass('hn', bar + i, spec.split()[0], 52, low='C4', n=2, beats=.5)
        s.mel('mtpt', bar, FANFARE, 82)
        s.line('fl', bar + 1, m('r:3 C6:.25 D6:.25 E6:.25 F6:.25'), 56)
        if bar:
            s.timp_hit(bar * 4, 'F2', 56)
        s.timp_hit((bar + 3) * 4, 'F2', 50)

    fanfare(0)
    for i, spec in enumerate(CALM_H):
        calm(4 + i, spec, 54)
        bed(s, 4 + i, spec, 34, ch='pad', low='A3', n=3)
    s.mel('cl', 4, CALM, 78)
    fanfare(12)
    for i, spec in enumerate(CALM_H):
        calm(16 + i, spec, 54)
        bed(s, 16 + i, spec, 34, ch='pad', low='A3', n=3)
        if i % 2 == 0:
            s.harp(16 + i, spec.split()[0], 42, density=8)
    s.mel('fl', 16, CALM, 76, transpose=12)
    s.line('glock', 19, m('r:3 C6:1'), 44)
    for i, spec in enumerate(['F', 'Dm7', 'Bb', 'C7']):
        calm(24 + i, spec, 56)
        bed(s, 24 + i, spec, 40, ch='pad', low='A3', n=4)
    s.motif('hn', 24, motif('F4', 'major', rhythm=[.5, .25, .25, 1.5, .5, 3]) + m('r:2'), 80, form='stated as a little fanfare (horn)')
    s.motif('mtpt', 26, motif_head('C5', 'major', rhythm=(.5, .25, .25)) + m('E5:3 | r:4'), 72, form='head (muted trumpet answers)')
    for i, spec in enumerate(['F', 'Gm7', 'C7sus4', 'C7']):
        calm(28 + i, spec, 54)
        bed(s, 28 + i, spec, 40, ch='pad', low='A3', n=4)
    s.mel('cl', 28, m('A4:2 G4:1 F4:1 | Bb4:2 D5:2 | C5:2 G4:2 | E4:2 G4:1 Bb4:1'), 82)
    gliss(s, 'harp', 31, 'C7', 40, low='C4', beats=1, beat=3)
    s.timp_roll(31 * 4 + 1, 3, 'C2', 30, 66)
    s.swell('pad', 30, 2, 100, 127)
    return s
