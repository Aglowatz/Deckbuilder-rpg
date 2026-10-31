"""MUS-SHOP-FENWICK - Foil, whispered reverently (Crosspath, VS-FENWICK, the card collector). Loop, 28 bars 4/4, 84 BPM, Eb major (80.0 s).
Expectant collector wonder: sparkling celesta, music box and glockenspiel above warm slow strings and a soft harp, with little anticipatory
pauses - a bar where everything holds its breath on a suspended chord and a single chime - and rare crystal synth glints (foil catching
the light). The Crossroads motif on the celesta, as if found in a binder. Bigger reveals are left to the pack stings.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, gliss

TUNE = m('Bb4:1 Eb5:1 G5:1.5 F5:.5 | Eb5:1 Bb4:1 C5:2 | Ab4:1 C5:1 F5:1.5 Eb5:.5 | D5:3 r:1 '
         '| G5:1 Bb5:1 Eb6:1.5 D6:.5 | C6:1 Ab5:1 F5:2 | G5:1 Eb5:1 F5:1 D5:1 | Eb5:3 r:1')
H = ['Eb', 'Cm7', 'Abmaj7', 'Bb7sus4 Bb7', 'Eb', 'Abmaj7', 'Fm7 Bb7', 'Eb']


def build():
    s = Score('MUS-SHOP-FENWICK', bpm=84, bars=28, key='Eb major', seed=715)
    s.seat('cel', 'glock', 'pad', 'harp', 'vc', 'cb', 'fl', 'pizz')
    s.channel('mbox', 'music_box', pan=34, reverb=95, vol=80)
    s.channel('cryst', 'crystal', pan=96, reverb=115, vol=48)
    s.channel('bell', 'bells', pan=60, reverb=110, vol=54)
    for bar, nm in ((0, 'A celesta'), (8, 'hold (anticipation)'), (10, 'B music box + flute'), (18, 'hold'), (20, "A' the motif in the binder")):
        s.section(bar, nm)
    s.notes.append('Wonder: celesta/music box/glock over warm strings; held-breath bars 8-9 and 18-19; crystal glints sparingly.')

    def ground(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            s.bass_at(t, d - .02, sym, vel, chs=('cb', 'vc'))
            tn = s.chord_tones(sym, p('Eb4'), 4)
            for k, b in enumerate((0, 1, 2, 3)):
                if b < d - 1e-6:
                    s.note('pizz', t + b + .5, .3, tn[k % 4], vel - 18)

    def hold(bar):
        bed(s, bar, 'Bb7sus4', 46, ch='pad', low='Bb3', n=4)
        bed(s, bar + 1, 'Bb7sus4 Bb7', 46, ch='pad', low='Bb3', n=4)
        s.note('cb', bar * 4, 7.98, p('Bb1'), 48)
        s.note('bell', bar * 4, 4, p('Bb5'), 58)
        s.note('cryst', bar * 4 + 4, 3, p('F6'), 54)
        s.mel('cel', bar, m('r:2 F5:.5 G5:.5 Ab5:1 | Bb5:2 D6:2'), 70)

    for i, spec in enumerate(H):
        ground(i, spec, 56)
        bed(s, i, spec, 44, ch='pad', low='Bb3', n=4)
    s.mel('cel', 0, TUNE, 84)
    s.line('glock', 4, TUNE[16:20], 50, transpose=0)
    s.note('cryst', 3 * 4 + 2, 2, p('D6'), 52)
    hold(8)
    for i, spec in enumerate(H):
        ground(10 + i, spec, 56)
        bed(s, 10 + i, spec, 46, ch='pad', low='Bb3', n=4)
        if i % 2 == 0:
            s.harp(10 + i, spec.split()[0], 40, density=8)
    s.mel('mbox', 10, TUNE[:8], 86)
    s.mel('fl', 14, TUNE[16:], 74)
    gliss(s, 'harp', 13, 'Bb7', 46, low='Bb3', beats=1, beat=3)
    hold(18)
    for i, spec in enumerate(H):
        ground(20 + i, spec, 56)
        bed(s, 20 + i, spec, 44, ch='pad', low='Bb3', n=4)
    s.motif('cel', 20, motif('Eb5', 'major') + m('r:1'), 82, form='stated (celesta: found in the binder)')
    s.motif('fl', 22, motif('G5', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1'), 70, form='stated on G (flute, the answer)')
    s.mel('cel', 24, TUNE[16:], 82)
    s.line('mbox', 24, TUNE[16:], 56, transpose=12)
    s.note('cryst', 26 * 4 + 2, 2, p('G6'), 50)
    s.line('cel', 27, m('r:2.5 F5:.5 G5:.5 Ab5:.5'), 66)
    s.swell('pad', 26, 2, 100, 124)
    return s
