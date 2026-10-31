"""MUS-SHOP-BEETSWORTH - Assistant to the regional merchant (Crosspath, VS-BEETSWORTH). Loop, 36 bars 4/4, 108 BPM, C major (80.0 s).
Stiff but odd: orderly pizzicato and cello quarters, precise dry piano chords on one and three, and a bassoon tune that takes itself very
seriously - with small eccentricities: a bar that hiccups (the downbeat missing), a note a semitone off that the oboe primly corrects, a
pompous three-note oboe fanfare. The Crossroads motif, very solemnly, on the bassoon. Understated comedy, low fatigue.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, shop_bass

TUNE = m('C4:1 E4:1 G4:1 E4:1 | F4:1 D4:1 B3:2 | C4:1 E4:1 A4:1 G4:1 | G4:3 r:1 '
         '| A4:1 G4:1 F4:1 E4:1 | D4:1 E4:1 F4:1 Ab4:1 | G4:1 E4:1 D4:1 B3:1 | C4:3 r:1')
H = ['C', 'G7', 'Am', 'G', 'F', 'Dm7 Fm', 'C G7', 'C']


def build():
    s = Score('MUS-SHOP-BEETSWORTH', bpm=108, bars=36, key='C major', seed=713, human=(0.008, 3))
    s.seat('pizz', 'vc', 'bsn', 'ob', 'piano', 'glock', 'pad', 'cl')
    s.channel('pbass', 'pizz', pan=86, reverb=70, vol=90)
    s.channel('wb', 'woodblock', pan=50, reverb=70, vol=54)
    for bar, nm in ((0, 'intro procedure'), (4, 'A bassoon, seriously'), (12, 'B the oboe corrects'), (20, "A' clarinet joins"),
                    (28, 'C the motif, solemnly'), (32, 'intro procedure')):
        s.section(bar, nm)
    s.notes.append('Orderly quarters + dry piano accents; eccentricities: a hiccup bar (13), a wrong note corrected (bars 9-10), '
                   'pompous oboe fanfares; light woodblock.')

    def order(bar, spec, vel, hiccup=False):
        for t, d, sym in each(s, bar, spec):
            tn = s.chord_tones(sym, p('C4'), 3)
            for b in range(int(round(d))):
                if hiccup and t + b == bar * 4:
                    continue
                s.note('pizz', t + b, .3, tn[b % 3], vel - 4)
            if not (hiccup and t == bar * 4):
                for n in tn:
                    s.note('piano', t, .25, n, vel)
            if d >= 3:
                for n in tn:
                    s.note('piano', t + 2, .25, n, vel - 6)
        s.note('wb', bar * 4 + 3.5, .1, p('E5'), vel - 18)

    def intro(bar):
        for i, spec in enumerate(['C', 'F', 'G7', 'G7']):
            order(bar + i, spec, 58)
            shop_bass(s, bar + i, spec, 64, style='two')
            bed(s, bar + i, spec, 32, ch='pad', low='E3', n=3)
        s.mel('ob', bar, m('G4:.5 C5:.5 E5:1 r:2 | F5:.5 E5:.5 D5:1 r:2 | B4:1 D5:1 G5:1 F5:1 | D5:2 B4:1 G4:1'), 74)

    intro(0)
    for k, bar0 in enumerate((4, 12, 20)):
        for i, spec in enumerate(H):
            order(bar0 + i, spec, 58, hiccup=(bar0 + i == 13))
            shop_bass(s, bar0 + i, spec, 66, style='two' if k != 1 else 'walk')
            bed(s, bar0 + i, spec, 32 + 4 * k, ch='pad', low='E3', n=3)
    s.mel('bsn', 4, TUNE, 84)
    s.mel('ob', 12, m('E5:1 G5:1 C6:1 G5:1 | A5:1 F5:1 D5:2 | E5:1 G5:1 C#6:1 r:1 | C6:3 r:1'), 80)   # C#6 - oops
    s.line('glock', 14, m('r:3 C6:1'), 60)                                                            # corrected
    s.mel('ob', 16, m('C6:1 B5:1 A5:1 G5:1 | F5:1 G5:1 A5:1 Ab5:1 | G5:1 E5:1 D5:1 B4:1 | C5:2 G4:.5 C5:.5 E5:1'), 80)
    s.line('bsn', 13, m('r:1 G3:.5 G3:.5 C4:2'), 64)                                                   # fills the hiccup
    s.mel('bsn', 20, TUNE, 84)
    s.line('cl', 20, TUNE, 62, transpose=12)
    s.line('ob', 23, m('C5:.5 E5:.5 G5:1 r:2'), 60)                                                    # the fanfare
    s.line('ob', 27, m('C5:.5 E5:.5 G5:1 r:2'), 60)
    for i, spec in enumerate(['Am', 'Dm7', 'G7', 'C']):
        order(28 + i, spec, 54)
        shop_bass(s, 28 + i, spec, 62, style='two')
        bed(s, 28 + i, spec, 38, ch='pad', low='E3', n=3)
    s.motif('bsn', 28, motif('A3', 'minor', rhythm=[1, 1, 1, 1.5, .5, 3]) + m('r:1'), 86, form='stated (bassoon, very solemn)')
    s.motif('ob', 30, motif_head('G4', 'major', rhythm=(1, 1, 1)) + m('C5:1 | B4:4'), 72, form='head (oboe, approving)')
    intro(32)
    return s
