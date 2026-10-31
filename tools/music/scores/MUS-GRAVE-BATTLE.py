"""MUS-GRAVE-BATTLE - Something beneath the stones (Crosspath graveyard scripted challenge). Loop, 64 bars 4/4, 144 BPM, Bb minor.
Old Hob's hum (_fork_c.GRAVE_HUM, re-barred into 4/4 and moved to Bb minor) built into a battle: a low cello/bass 8th ostinato that
creeps chromatically, dry percussion (stick clicks, castanets, a dry snare - no organ, no clock: distinct from the D.N.A. sound),
restless woodwind echoes that repeat each phrase end a beat late (flute, oboe, clarinet), the hum in bassoon + horns, then in the
violins with xylophone bones. A contrasting B phrase states the Crossroads motif in the trumpets over tremolo with a Gb-major lift;
a tense D passage inverts it in the low brass. Intro/outro is a low brass bed over the ostinato.
"""
from lib import Score, motif, motif_head, augment, m, p, transpose, voice

HUM4 = m('Bb3:1 Db4:1 C4:1 F3:1 | F3:2 Gb3:1 F3:1 | E3:1 F3:1 Bb3:1 C4:1 | Db4:1.5 C4:.5 Bb3:1 A3:1 | '
         'Bb3:1 Db4:1 C4:1 F3:1 | Gb3:1 F3:1 E3:1 F3:1 | Bb3:1 C4:1 Db4:1 Eb4:1 | C4:2 Bb3:2')
PROG = ['Bbm', 'Gb', 'C7', 'F7', 'Bbm', 'Gb', 'Ebm', 'F7']


def build():
    s = Score('MUS-GRAVE-BATTLE', bpm=144, bars=64, key='Bb minor', seed=965)
    s.seat('vln', 'trem', 'pad', 'vc', 'cb', 'bsn', 'hn', 'tpt', 'tbn', 'fl', 'ob', 'cl', 'xylo', 'timp', 'perc')
    for bar, nm in ((0, 'bed'), (4, 'A the hum'), (20, 'B motif'), (36, 'C bones'), (52, 'D tension'), (60, 'bed')):
        s.section(bar, nm)

    def creep(bar, sym, vel):
        b = s.voicing(sym)[0] + 12
        cell = [b, b, b + 1, b, b + 7, b, b + 6, b + 1]
        for k in range(8):
            s.note('vc', bar * 4 + k * .5, .4, cell[k], vel + (10 if k % 4 == 0 else 0))
        s.note('cb', bar * 4, 1.8, b - 12, vel)
        s.note('cb', bar * 4 + 2, 1.8, b - 12, vel - 6)

    def dry(bar, vel, full=True):
        s.drum(bar, [(0, 'stick', 4), (.5, 'click', -10), (1, 'snare', -8), (2, 'stick', 0), (2.75, 'click', -10), (3, 'snare', -4)]
               + ([(3.5, 'tamb', -16)] if full else []), vel)
        s.note('perc', bar * 4 + 1.5, .2, 54 if full else 33, vel - 18)

    def echo(bar, beat, notes, chs=('fl', 'ob', 'cl'), vel=62):
        for k, ch in enumerate(chs):
            s.line(ch, bar, notes, vel - k * 4, beat=beat + k + 1, transpose=12 if ch == 'fl' else 0)

    def bed(bar):
        for i, sym in enumerate(['Bbm', 'Gb', 'Ebm', 'F7']):
            s.brass('tbn', bar + i, sym, 62, low='Db3')
            s.pad('pad', bar + i, sym, 58, low='F3')
            creep(bar + i, sym, 66)
            dry(bar + i, 66, full=False)
        s.motif('hn', bar + 1, motif_head('Bb3', 'minor', rhythm=(1, .5, 2.5)), 84, form='head (horns, over the bed)')
        s.mel('ob', bar + 2, m('Db5:1 C5:1 Bb4:1 A4:1 | A4:4'), 72)
        s.timp_hit(bar * 4, 'Bb2', 82)
        s.timp_roll((bar + 3) * 4 + 2, 2, 'F3', 46, 70)

    bed(0)

    # A 4-19: the hum in bassoon + horns over the creep, echoed by the woodwinds
    for i in range(16):
        bar, sym = 4 + i, PROG[i % 8]
        creep(bar, sym, 72)
        dry(bar, 70)
        s.pad('pad', bar, sym, 44, low='F3')
        if i % 4 == 0:
            s.timp_hit(bar * 4, 'Bb2' if sym == 'Bbm' else 'F3', 82)
    s.mel('bsn', 4, HUM4, 90)
    s.line('hn', 4, HUM4, 78)
    s.mel('hn', 12, HUM4, 92, transpose=12)
    s.line('bsn', 12, HUM4, 74)
    for b in (7, 11, 15, 19):
        echo(b, 1, m('Bb4:.5 A4:.5'))

    # B 20-35: the Crossroads motif in the trumpets over tremolo; a Gb major lift at 28
    bprog = ['Gb', 'Db', 'Ebm', 'F', 'Gb', 'Db', 'Cdim', 'F7', 'Gb', 'Ab', 'Db', 'Bbm', 'Gb', 'Ab', 'F', 'F7']
    for i, sym in enumerate(bprog):
        bar = 20 + i
        s.pad('trem', bar, sym, 58, low='F3')
        creep(bar, sym, 68)
        dry(bar, 66, full=i % 2 == 0)
    for k in (20, 28):
        s.motif('tpt', k, motif('Bb4', 'minor') + [('r', 1)], 90, form='stated (trumpets)')
        s.line('hn', k, motif('Bb3', 'minor'), 72)
        s.mel('vln', k + 2, m('Gb5:1.5 F5:.5 Eb5:1 Db5:1 | C5:4') if k == 20 else m('Ab5:1.5 Gb5:.5 F5:1 Eb5:1 | Db5:2 F5:2'), 86)
        s.mel('vln', k + 4, m('Db5:1 Eb5:1 F5:1 Gb5:1 | F5:4') if k == 20 else m('Gb5:1 Ab5:1 Bb5:1 Db6:1 | C6:4'), 88)
        echo(k + 5, 2, m('F5:.5 E5:.5'))
    s.timp_roll(35 * 4, 4, 'F3', 50, 88)

    # C 36-51: the hum in the violins, xylophone bones, full dry kit
    for i in range(16):
        bar, sym = 36 + i, PROG[i % 8]
        creep(bar, sym, 76)
        dry(bar, 76)
        s.brass('tbn', bar, sym, 70, beats=.5, low='Db3')
        s.brass('tbn', bar, sym, 66, beats=.5, low='Db3', beat=2.5)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 70)
    s.mel('vln', 36, HUM4, 96, transpose=12)
    s.line('xylo', 36, HUM4, 62, transpose=24)
    s.mel('vln', 44, HUM4, 98, transpose=12)
    s.line('cl', 44, HUM4, 66)
    s.motif('hn', 44, augment(motif_head('Bb3', 'minor'), 2) + [('r', 4)], 84, form='head augmented (horns, under the hum)', lead=False)

    # D 52-59: tension - the motif inverted in the low brass, tremolo rising, snare roll
    for i, sym in enumerate(['Bbm', 'Bbm', 'Gb', 'Gb', 'Ebm', 'Ebm', 'F7', 'F7']):
        bar = 52 + i
        s.pad('trem', bar, sym, 56 + i * 3, low='F3')
        creep(bar, sym, 70)
        dry(bar, 64, full=False)
    s.motif('tbn', 52, augment(motif('Bb3', 'minor', inverted=True), 1) + [('r', 1)], 88, form='inverted (trombones, tension)')
    s.mel('vln', 54, m('Gb5:2 F5:2 | Fb5:2 Eb5:2 | Db5:4 | C5:4 | Db5:2 C5:2 | A4:4'), 88)
    echo(57, 2, m('Bb4:.5 A4:.5'))
    s.snare_roll(58 * 4, 8, 40, 96)
    s.timp_roll(59 * 4, 4, 'F3', 50, 92)

    bed(60)
    s.fade_vel(62, 64, 0.8, start_factor=1.0)     # seam: the held oboe + roll ease into the loop point
    return s
