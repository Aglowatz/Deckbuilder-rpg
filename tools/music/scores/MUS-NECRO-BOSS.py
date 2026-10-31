"""MUS-NECRO-BOSS - Mortimer Grimsby, CE-No. 88 bars 4/4, 126 BPM, C minor (harmonic).
Calm, immovable procedural pressure - no screaming villain music: he believes the authorization is valid.
Mortimer's own theme is a stamp: a repeated note, a half-step correction and a cadence filed exactly on time (C C C | B C | Ab G Ab B | C),
on the organ with trombones and tuba, over emphatic low-string crotchets and a clock ticking precise eighths. The D.N.A. waltz theme is
corrupted - forced into 4/4 (the long note of each 3/4 bar is held one beat too long, so the dance limps into a march). The Crossroads
motif meets him inverted, then fights back in the horns and violins at the climax against his theme in the low brass. A quiet middle has
him alone at the organ with the choir: he is sure.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS

MORT = m('C4:2 C4:1 C4:1 | B3:2 C4:2 | Ab3:1 G3:1 Ab3:1 B3:1 | C4:4 '
         '| Eb4:2 Eb4:1 Eb4:1 | D4:2 Eb4:2 | F4:1 Eb4:1 D4:1 B3:1 | C4:4')
MORT_H = ['Cm', 'G7', 'Fm', 'Cm', 'Cm', 'Bdim', 'Fm', 'G7']
INTRO = ['Cm', 'Cm', 'Fm', 'G7']
C_PROG = ['Cm', 'Ab', 'Fm', 'G7', 'Cm', 'Db', 'Bdim', 'G7'] * 2


def to_four(mel):
    """The waltz forced into 4/4: in each 3-beat bar the longest note (first on a tie) is held one beat longer."""
    out, bar, acc = [], [], 0.0
    for n, d in mel:
        bar.append([n, d])
        acc += d
        if acc >= 3 - 1e-6:
            k = max(range(len(bar)), key=lambda i: (bar[i][1], -i))
            bar[k][1] += 1
            out += [tuple(x) for x in bar]
            bar, acc = [], 0.0
    return out


THEME4 = to_four(DNA_THEME)          # 16 bars of 4/4
THEME4_A, THEME4_B = THEME4[:20], THEME4[20:]


def build():
    s = Score('MUS-NECRO-BOSS', bpm=126, bars=88, key='C minor (harmonic)', seed=304)
    s.V.update(DNA_CHORDS)
    s.seat('vln', 'trem', 'vc', 'cb', 'hn', 'tbn', 'tuba', 'bsn', 'timp', 'choir', 'cel', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=86)
    s.channel('hpsd', 'harpsichord', pan=30, reverb=80, vol=66)
    for bar, nm in ((0, 'intro'), (4, 'A Mortimer'), (20, 'B the waltz in 4/4'), (36, 'C the question inverted'),
                    (52, 'D he is sure'), (60, 'E climax'), (76, 'F filing'), (84, 'outro')):
        s.section(bar, nm)

    def clock(bar, vel=40):
        for k in range(8):
            s.note('perc', bar * 4 + k * .5, .2, 76 if k % 2 == 0 else 77, vel + (8 if k == 0 else (0 if k % 2 == 0 else -10)), human=False)

    def strings(bar, sym, vel):
        """Emphatic low strings: crotchets on the root, the first one leaned on."""
        b = p(s.voicing(sym)[0])
        for k in range(4):
            s.note('cb', bar * 4 + k, .8, b, vel + (10 if k == 0 else -4))
            s.note('vc', bar * 4 + k, .8, b + 12, vel - 6 + (8 if k == 0 else -4))

    def organ(bar, sym, vel, pedal=True, beats=4):
        s.pad('organ', bar, sym, vel, beats=beats)
        if pedal:
            b = p(s.voicing(sym)[0])
            s.note('organ', bar * 4, beats + .05, b + (12 if b < p('C2') else 0), vel - 4)

    def stamp(bar, sym, vel):
        v = s.voicing(sym)[1]
        for beat in (0, 2):
            for n in v[1:3]:
                s.note('tbn', bar * 4 + beat, .9, p(n), vel)

    def timp(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.timp_hit(bar * 4, b + 12 if b + 12 <= p('A2') else b, vel)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            clock(bar + i, 44)
            strings(bar + i, sym, 74)
            organ(bar + i, sym, 56)
            s.pad('trem', bar + i, sym, 58)
            if i % 2 == 0:
                timp(bar + i, sym, 78)
        s.motif('hn', bar + 2, motif_head('C4', 'minor', rhythm=(1, 1, 2)), 72, form='head (horns, entering the office)', lead=False)
        s.mel('organ', bar, m('C5:4 | C5:4 | C5:2 B4:2 | C5:4'), 74)
        s.swell('organ', bar + 3, 1, 90, 100)

    intro(0)

    # A 4-19: Mortimer's theme on the organ with trombones and tuba, twice; harpsichord files the off-beats
    for i in range(16):
        bar, sym = 4 + i, MORT_H[i % 8]
        clock(bar, 40)
        strings(bar, sym, 78)
        organ(bar, sym, 52, pedal=False)
        if i % 2 == 0:
            timp(bar, sym, 80)
        v = sorted(p(n) for n in s.voicing(sym)[1])
        for k in (1, 3):
            s.note('hpsd', bar * 4 + k, .4, v[2] + 12, 54)
    s.mel('organ', 4, MORT * 2, 100, transpose=12)
    s.line('tbn', 4, MORT * 2, 84)
    s.line('tuba', 12, MORT, 74)
    s.line('trem', 12, MORT, 62, transpose=12)
    s.timp_roll(19 * 4, 4, 'G2', 50, 96)

    # B 20-35: the D.N.A. theme corrupted into 4/4 in the horns, Mortimer's stamp in the trombones
    for i in range(16):
        bar, sym = 20 + i, DNA_PROG[i]
        clock(bar, 42)
        strings(bar, sym, 80)
        stamp(bar, sym, 62)
        s.pad('trem', bar, sym, 56)
        if i % 4 == 0:
            timp(bar, sym, 84)
    s.mel('hn', 20, THEME4, 100)
    s.line('bsn', 20, THEME4_A, 70, transpose=-12)
    s.line('vln', 28, THEME4_B, 84)
    s.hit('crash', 20 * 4, 70, dur=2)

    # C 36-51: the Crossroads motif inverted (the question turned upside down) in cello and horn, against Mortimer in the organ
    for i in range(16):
        bar, sym = 36 + i, C_PROG[i]
        clock(bar, 40)
        strings(bar, sym, 72)
        organ(bar, sym, 48, pedal=False)
        if i % 4 == 0:
            timp(bar, sym, 76)
    s.motif('vc', 36, motif('C4', 'harmonic', inverted=True) + m('r:1'), 92, form='inverted (cello)')
    s.line('organ', 38, MORT[:4], 76, transpose=12)
    s.motif('hn', 40, motif('G4', 'minor', inverted=True) + m('r:1'), 94, form='inverted (horn)')
    s.line('organ', 42, MORT[8:12], 76, transpose=12)
    s.mel('vln', 44, THEME4_A[:10], 92, transpose=12)
    s.motif('hn', 48, motif_head('C4', 'minor'), 90, form='head (horn, upright again)', lead=False)
    s.mel('vln', 48, THEME4_A[10:], 94, transpose=12)
    s.timp_roll(51 * 4, 4, 'G2', 44, 100)

    # D 52-59: he is sure - organ and choir, Mortimer's theme slow and calm, the clock in the open
    for i in range(8):
        bar, sym = 52 + i, MORT_H[i]
        organ(bar, sym, 54)
        s.pad('choir', bar, sym, 52, low='G3')
        clock(bar, 46)
        s.note('cb', bar * 4, 3.9, p(s.voicing(sym)[0]), 58)
    s.mel('organ', 52, MORT, 92, transpose=12)
    s.mel('cel', 56, THEME4_A[:10], 72, transpose=12)
    s.timp_roll(59 * 4, 4, 'G2', 36, 104)
    s.snare_roll(59 * 4 + 2, 2, 30, 90, inst='bd2', rate=6)

    # E 60-75: climax - the hero's motif in horns and violins against Mortimer's theme in the low brass, the corrupted theme in the organ
    for i in range(16):
        bar, sym = 60 + i, MORT_H[i % 8]
        clock(bar, 46)
        strings(bar, sym, 88)
        s.pad('trem', bar, sym, 66)
        s.pad('choir', bar, sym, 60, low='G3')
        timp(bar, sym, 90 if i % 2 == 0 else 74)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 84, dur=2)
    hero = motif('C4', 'minor') + m('r:1') + motif('Eb4', 'minor') + m('r:1')
    s.motif('hn', 60, hero, 106, form='stated (horns: the hero fights back), sequenced up a third')
    s.line('vln', 60, hero, 98, transpose=12)
    s.line('tbn', 60, MORT * 2, 90)
    s.line('tuba', 60, MORT * 2, 76)
    s.mel('organ', 68, THEME4_B, 100, transpose=12)
    s.line('hn', 68, THEME4_B, 92)
    s.swell('vln', 60, 16, 100, 122, 'arch')

    # F 76-83: filing - the corrupted theme's opening once more, the stamp, winding down to the intro
    for i, sym in enumerate(['Cm', 'Cm', 'Fm', 'Fm', 'G7', 'G7', 'Cm', 'G7']):
        bar = 76 + i
        clock(bar, 44)
        strings(bar, sym, 80 - i)
        stamp(bar, sym, 60)
        s.pad('trem', bar, sym, 58)
        if i % 2 == 0:
            timp(bar, sym, 80)
    s.mel('hn', 76, THEME4_A[:10], 94)
    s.mel('organ', 80, MORT[:8], 92, transpose=12)

    intro(84)
    return s
