"""MUS-TUT-BATTLE - Forgotten Cave, first trials. 64 bars 4/4, 124 BPM, E minor.
A modest rhythmic lift of the cave theme: a string ostinato in 3+3+2 and timpani drive it, the horns state the Crossroads motif in
clear 8-bar phrases, the pan flute of the cave answers. A quieter suspense section (pizzicato echoes, tremolo) leaves room to think,
then the full brass, a lift into G major, and the motif turned upside down in the trombones before the ostinato alone takes it round.
"""
from lib import Score, m, motif, motif_head, augment, tones, p

TUNE = m('E4:1 B4:.5 A4:.5 G4:1.5 F#4:.5 | B4:3 r:1 | A4:1 B4:.5 C5:.5 D5:1.5 C5:.5 | B4:2 F#4:1 A4:1 '
         '| G4:1 D5:.5 C5:.5 B4:1.5 A4:.5 | D5:3 r:1 | E5:1 D5:.5 C5:.5 B4:1 A4:1 | G4:1 A4:1 B4:2 '
         '| E4:1 B4:.5 A4:.5 G4:1.5 F#4:.5 | B4:3 r:1 | A4:1 B4:.5 C5:.5 E5:1.5 D5:.5 | C5:1 B4:1 A4:1 G4:1 '
         '| F#4:1 G4:.5 A4:.5 B4:1.5 C5:.5 | D5:2 B4:2 | C5:1 B4:.5 A4:.5 G4:1 F#4:1 | E4:4')
TUNE_H = ['Em', 'Cmaj7', 'Am', 'Bm', 'G', 'D', 'C', 'Bsus4 B', 'Em', 'C', 'Am', 'Em/G', 'D', 'Bm', 'Am7 D', 'Em']
SUSP_H = ['Am', 'Em/G', 'F', 'B7', 'Am', 'Em/G', 'F', 'Bsus4 B']
LIFT_H = ['G', 'D/F#', 'Em', 'C', 'G', 'D/F#', 'C', 'B']
LIFT = m('B4:2 D5:2 | A4:2 F#4:2 | G4:1 A4:1 B4:2 | E4:4 | B4:2 D5:2 | F#5:2 A5:2 | G5:1 F#5:1 E5:1 D5:1 | D#5:4')
OST = [(0, 0, .45, 10), (.5, 0, .45, -6), (1, 2, .45, 0), (1.5, 0, .45, 6), (2, 1, .45, -6), (2.5, 0, .45, -4), (3, 2, .45, 8), (3.5, 3, .45, -2)]


def build():
    s = Score('MUS-TUT-BATTLE', bpm=124, bars=64, key='E minor', seed=404)
    s.seat('spic', 'vln', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'fl', 'cl', 'harp', 'pizz', 'timp', 'trem', 'perc',
           fl=('pan_flute', 52, 95, 80))
    for bar, nm in ((0, 'ostinato'), (4, 'A horns'), (20, 'B suspense'), (28, "A' brass"), (44, 'C lift'), (52, "A'' inverted"), (60, 'ostinato')):
        s.section(bar, nm)

    def drive(bar, spec, vel, timp=True, bass=True, off8=False):
        for off, beats, sym in s.parts(spec):
            sub = [x for x in OST if off <= x[0] < off + beats]
            s.figure('spic', bar, sym, sub, vel, low='E3')
            if bass:
                b = p(s.voicing(sym)[0])
                for k in range(int(beats * 2)):
                    s.note('cb', bar * 4 + off + k * .5, .4, b, vel - 8 + (8 if k % 4 == 0 else 0))
        if timp:
            root = p(s.voicing(spec.split()[0])[0])
            tp = root + 12 if root + 12 <= p('A2') else root
            s.timp_hit(bar * 4, tp, vel + 6)
            if off8:
                s.timp_hit(bar * 4 + 2.5, tp, vel - 10)

    def ost_only(bar, n):
        for i in range(n):
            spec = ['Em', 'Em', 'Cmaj7', 'Bsus4'][i % 4]
            drive(bar + i, spec, 80, off8=True)
            s.pad('pad', bar + i, spec, 56)
            s.drum(bar + i, [(0, 'bd', 0), (2.5, 'bd', -14), (3, 'snare', -16)], 60)
        s.line('hn', bar, m('E4:8 | E4:4 F#4:4'), 62, legato=1.0, shape=False)
        s.expr('spic', bar, 110)
        s.expr('spic', bar + n, 96)

    # OSTINATO 0-3
    ost_only(0, 4)
    s.timp_roll(3 * 4 + 2, 2, 'B1', 40, 76)

    # A 4-19: horns state the theme over the drive; pan flute echoes the phrase ends
    for i, spec in enumerate(TUNE_H):
        drive(4 + i, spec, 66)
        s.pad('pad', 4 + i, spec.split()[-1], 50)
    s.motif('hn', 4, TUNE[:6], 92, form='stated (horns)')
    s.mel('hn', 4, TUNE[6:], 90, beat=7)
    s.line('fl', 5, m('r:3 B5:.5 A5:.5'), 54)
    s.line('fl', 9, m('r:3 D6:.5 C6:.5'), 54)
    s.line('fl', 13, m('r:3 B5:.5 A5:.5'), 54)
    s.swell('pad', 4, 16, 70, 96, 'arch')

    # B 20-27: suspense - drive drops out; pizzicato echoes, tremolo, clarinet, horn fragments on the head
    for i, spec in enumerate(SUSP_H):
        bar = 20 + i
        for off, beats, sym in s.parts(spec):
            s.pad('trem', bar, sym, 46, beats=beats, beat=off, low='E3')
            s.bass_at(bar * 4 + off, beats, sym, 54, chs=('cb', None))
        for k, beat in enumerate((0, 1.5, 3)):
            t = tones(spec.split()[0], low='E4', count=4)[k % 3]
            for e in range(3):
                s.note('pizz', bar * 4 + beat + e * .5, .3, t, 62 * (.55 ** e))
        if i % 2 == 0:
            s.timp_hit(bar * 4, p('A2') if spec == 'Am' else p('F2'), 48)
    s.swell('trem', 20, 8, 60, 100)
    s.line('cl', 20, m('C4:4 | B3:4 | A3:4 | B3:2 A3:2 | C4:4 | B3:4 | C4:4 | B3:4'), 58, legato=1.0)
    s.motif('hn', 21, motif_head('A4', rhythm=(1, .5, 2.5)), 70, form='head (horn), suspense')
    s.motif('hn', 25, motif_head('A4', rhythm=(1, .5, 2.5)), 74, form='head (horn), suspense')
    s.mel('fl', 22, m('A5:1 E5:.5 D5:.5 C5:2 | B4:4'), 60)
    s.mel('fl', 26, m('A5:1 E5:.5 D5:.5 C5:2 | D#5:4'), 64)
    s.snare_roll(27 * 4, 4, 30, 80)
    s.timp_roll(27 * 4 + 2, 2, 'B1', 40, 90)

    # A' 28-43: full brass - trumpets + horns on the tune, strings sustain a counter, snare, trombone stabs
    for i, spec in enumerate(TUNE_H):
        bar = 28 + i
        drive(bar, spec, 72, off8=True)
        s.pad('pad', bar, spec.split()[-1], 56)
        for off, beats, sym in s.parts(spec):
            s.brass('tbn', bar, sym, 70, beats=0.6, low='E3', beat=off)
        s.drum(bar, [(0, 'snare', 6), (1.5, 'snare', -8), (2, 'snare', 0), (3, 'snare', -4), (3.5, 'snare', -10)], 50)
    s.motif('tpt', 28, TUNE[:6], 90, form='stated (trumpets + horns)')
    s.mel('tpt', 28, TUNE[6:], 90, beat=7)
    s.line('hn', 28, TUNE, 80)
    s.line('vln', 28, m('G4:8 | E4:8 | D4:8 | F#4:4 D#4:4 | G4:8 | E4:8 | D4:8 | E4:8'), 70, transpose=12, legato=1.0)
    s.swell('vln', 28, 16, 80, 108, 'arch')
    s.hit('crash', 28 * 4, 74, dur=3)
    s.hit('crash2', 36 * 4, 66, dur=3)
    s.timp_roll(43 * 4 + 2, 2, 'D2', 50, 90)

    # C 44-51: a lift into G major - strings sing, horns answer with the head, brass chords
    for i, spec in enumerate(LIFT_H):
        bar = 44 + i
        drive(bar, spec, 66)
        s.brass('hn', bar, spec, 58, beats=4, low='D4')
    s.mel('vln', 44, LIFT, 92, transpose=0)
    s.line('vln', 44, LIFT, 72, transpose=-12)
    s.motif('tpt', 45, motif_head('G4', 'major', rhythm=(1, .5, 2.5)), 70, form='head in G major (trumpet answer)', lead=False)
    s.motif('tpt', 49, motif_head('B4', 'minor', rhythm=(1, .5, 2.5)), 70, form='head (trumpet answer)', lead=False)
    s.swell('vln', 44, 8, 90, 118)
    s.hit('crash', 44 * 4, 70, dur=3)
    s.snare_roll(51 * 4 + 2, 2, 40, 86)

    # A'' 52-59: the first phrase again in the horns, the motif inverted in the trombones underneath
    for i, spec in enumerate(TUNE_H[:8]):
        bar = 52 + i
        drive(bar, spec, 68, off8=True)
        s.pad('pad', bar, spec.split()[-1], 54)
    s.motif('hn', 52, TUNE[:6], 90, form='stated (horns)')
    s.mel('hn', 52, TUNE[6:16], 88, beat=7)
    s.motif('tbn', 52, motif('E4', 'minor', inverted=True), 72, form='inverted (trombones, counter)', lead=False)
    s.line('tbn', 54, m('A3:4 | B3:4 | B3:4 | A3:4 | G3:4 | F#3:4'), 66)
    s.swell('hn', 56, 4, 110, 96)

    # OSTINATO 60-63: the drive alone, as at bar 0
    ost_only(60, 4)
    s.timp_roll(63 * 4 + 2, 2, 'B1', 40, 76)
    s.swell('spic', 63, 1, 96, 120)
    s.swell('pad', 63, 1, 90, 120)
    s.swell('hn', 63, 1, 96, 124)
    s.expr('hn', 0, 100)
    s.expr('pad', 0, 100)
    return s
