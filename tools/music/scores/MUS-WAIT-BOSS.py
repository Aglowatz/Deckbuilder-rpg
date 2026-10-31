"""MUS-WAIT-BOSS - Betty Bones. 96 bars 3/4, 124 BPM, Eb minor. Its own track (was an alias of MUS-WAIT-BATTLE until Music Pass 2).
Betty's own idea: a sugary receptionist's phrase that curtsies down and stops on the leading note, answered by a desk bell (glockenspiel,
"ding") - politeness with no end. Under it a waltz that grows heavier (organ, trombones, timpani on every downbeat). The D.N.A. theme in
Eb minor is her paperwork, in the organ and horns; the contrasting middle is the waiting-room tune turned into a slow music box over
diminished harmony (harmonic suspense), with the Crossroads motif trying to get past the desk. The climax sets the hero's motif in the
horns against Betty's phrase in the trombones; the intro's bell and pizzicato carry the loop.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS, theme_in, to_mode

BETTY = m('Bb4:1 Gb4:.5 F4:.5 Eb4:1 | Gb4:2 r:1 | Ab4:1 Gb4:.5 F4:.5 Eb4:1 | D4:3 '
          '| Cb5:1 Bb4:.5 Ab4:.5 Gb4:1 | Bb4:2 r:1 | Ab4:1 F4:.5 D4:.5 Eb4:1 | F4:3')
BETTY_H = ['Ebm', 'Cb', 'Abm', 'Bb7', 'Cb', 'Gb', 'Fdim7', 'Bb7']
THEME = theme_in(DNA_THEME, 3 - 12)                                     # C minor -> Eb minor
WAIT = theme_in(to_mode(DNA_THEME, {3: 1, 8: 1, 10: 1, 1: 1}), 6 - 12)  # the waiting-room tune, Gb major
DNA_EB = [('Ebm' if c.startswith('Cm') else {'Fm': 'Abm', 'G7': 'Bb7', 'Ab': 'Cb', 'Db': 'E', 'Gs': 'Bbsus4'}[c]) for c in DNA_PROG]
MID = ['Gb', 'Edim7', 'Ebm', 'Adim7', 'Gb', 'Cdim7', 'Db', 'Bb7'] * 2
INTRO = ['Ebm', 'Ebm', 'Cb', 'Bb7']


def build():
    s = Score('MUS-WAIT-BOSS', bpm=124, bars=96, meter=(3, 4), key='Eb minor', seed=314)
    s.seat('vln', 'trem', 'vc', 'cb', 'pizz', 'hn', 'tbn', 'tuba', 'cl', 'timp', 'choir', 'cel', 'glock', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=108, vol=80)
    for bar, nm in ((0, 'intro bell'), (4, 'A Betty'), (20, 'B the paperwork'), (36, 'C music box'), (52, 'D the desk'),
                    (68, 'E climax'), (84, 'F please wait'), (92, 'outro bell')):
        s.section(bar, nm)
    s.notes.append('Own boss track (was an alias of MUS-WAIT-BATTLE). Villain idea: BETTY + the desk bell (glock).')

    def bell(bar, beat=0.0, vel=76):
        s.note('glock', bar * 3 + beat, 1.5, p('Bb6'), vel)

    def clock(bar, vel=36):
        for k in range(3):
            s.note('perc', bar * 3 + k, .2, 76 if k == 0 else 77, vel + (8 if k == 0 else 0), human=False)

    def waltz(bar, sym, vel, heavy=False):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, 1.2, b, vel + 4)
        s.note('vc', bar * 3, 1.2, b + 12, vel - 6)
        v = s.voicing(sym, low='Bb3', n=3)[1]
        for beat in (1, 2):
            for n in v:
                s.note('pizz' if not heavy else 'tbn', bar * 3 + beat, .4 if not heavy else .6, p(n) - (12 if heavy else 0), vel - (12 if not heavy else 20))
        if heavy:
            s.timp_hit(bar * 3, b + 12 if b + 12 <= p('A2') else b, vel)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            waltz(bar + i, sym, 64)
            clock(bar + i)
            s.pad('organ', bar + i, sym, 50, beats=3)
            s.pad('trem', bar + i, sym, 54)
        bell(bar, 0, 70)
        bell(bar + 2, 0, 62)
        s.motif('cel', bar + 1, motif_head('Eb5', 'minor', rhythm=(1, .5, 1.5)), 54, form='head (celesta)', lead=False)
        s.timp_roll((bar + 3) * 3 + 1, 2, 'Bb1', 40, 80)

    intro(0)

    for i in range(16):
        bar, sym = 4 + i, BETTY_H[i % 8]
        waltz(bar, sym, 68 + (i >= 8) * 10, heavy=(i >= 8))
        clock(bar, 32)
        s.pad('organ', bar, sym, 44, beats=3)
    s.mel('cl', 4, BETTY, 92, transpose=12)
    s.mel('vln', 12, BETTY, 96, transpose=12)
    s.line('hn', 12, BETTY, 72)
    for bar in (7, 11, 15, 19):
        bell(bar, 2, 80)
    s.timp_roll(19 * 3, 3, 'Bb1', 50, 96)

    for i in range(16):
        bar, sym = 20 + i, DNA_EB[i]
        waltz(bar, sym, 78, heavy=True)
        clock(bar, 40)
        s.pad('trem', bar, sym, 58)
        if i % 4 == 0:
            s.hit('crash', bar * 3, 64, dur=2)
    s.mel('organ', 20, THEME, 102, transpose=12)
    s.line('hn', 20, THEME, 82)
    s.motif('tbn', 28, motif_head('Eb3', 'minor', rhythm=(1, .5, 1.5)) * 2, 80, form='head twice (trombones, stamping)', lead=False)

    for i in range(16):
        bar, sym = 36 + i, MID[i]
        s.pad('organ', bar, sym, 42, beats=3)
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), 52)
        v = sorted(p(n) for n in s.voicing(sym, low='Eb4', n=3)[1])
        for k in range(3):
            s.note('cel', bar * 3 + k, .9, v[k] + 12, 44)
        clock(bar, 30)
    s.mel('glock', 36, WAIT[:20], 70, transpose=12)
    s.motif('cl', 42, motif('Eb4', 'minor') + m('r:2'), 86, form='stated (clarinet, past the desk?)')
    s.mel('glock', 44, WAIT[20:], 68, transpose=12)
    s.motif('vc', 48, motif('Bb2', 'minor') + m('r:2'), 82, form='stated (cello, lower)')
    s.timp_roll(51 * 3, 3, 'Bb1', 36, 100)

    for i in range(16):
        bar, sym = 52 + i, BETTY_H[i % 8]
        waltz(bar, sym, 84, heavy=True)
        clock(bar, 42)
        s.pad('trem', bar, sym, 62)
        s.pad('choir', bar, sym, 54, low='Bb3')
    s.mel('tbn', 52, BETTY, 96)
    s.line('tuba', 52, BETTY, 70)
    s.mel('vln', 60, BETTY, 100, transpose=12)
    s.line('organ', 60, THEME[20:], 76, transpose=12)
    for bar in (55, 59, 63, 67):
        bell(bar, 2, 90)
    s.snare_roll(67 * 3, 3, 30, 96, inst='bd2', rate=6)

    for i in range(16):
        bar, sym = 68 + i, BETTY_H[i % 8]
        waltz(bar, sym, 90, heavy=True)
        clock(bar, 46)
        s.pad('trem', bar, sym, 68)
        s.pad('choir', bar, sym, 62, low='Bb3')
        if i % 4 == 0:
            s.hit('crash', bar * 3, 84, dur=2)
    hero = motif('Eb4', 'minor') + m('r:2') + motif('Gb4', 'minor') + m('r:2')
    s.motif('hn', 68, hero, 106, form='stated (horns: the hero insists), sequenced up a third')
    s.line('vln', 68, hero, 96, transpose=12)
    s.line('tbn', 68, BETTY[:9] + m('r:3'), 88)
    s.mel('organ', 76, THEME[:20], 100, transpose=12)
    s.line('hn', 76, THEME[:20], 92)
    s.swell('vln', 68, 16, 100, 122, 'arch')

    for i, sym in enumerate(['Ebm', 'Cb', 'Abm', 'Bb7', 'Ebm', 'Cb', 'Fdim7', 'Bb7']):
        bar = 84 + i
        waltz(bar, sym, 70)
        clock(bar, 36)
        s.pad('organ', bar, sym, 48, beats=3)
    s.mel('cl', 84, BETTY, 88, transpose=12)
    bell(87, 2, 80)

    intro(92)
    return s
