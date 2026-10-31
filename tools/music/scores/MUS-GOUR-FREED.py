"""MUS-GOUR-FREED - The Endless Buffet, restored. 80 bars 4/4, 124 BPM, F major -> G major -> F major.
The full festive finale - a real feast. The Buffet theme first breathes on a warm cello with a playful clarinet answering, then the whole
house sings it (strings, choir, oom-pah, brass punches) with the RESOLVED Crossroads motif as the horns' countermelody. A feast drop
(four-on-the-floor, claps, synth bass, pumped pad, the drop hook on the saw lead and the resolved motif) climbs on a D7 into G major for
the theme in full tutti, the resolved motif augmented in the horns, then a turnaround brings it home to F for the sparkle the loop
starts with.
"""
from lib import Song, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_8, BUFFET_HOOK, BUFFET_PROG, BUFFET_DROP_PROG, BUFFET_CHORDS


def cmap(semis):
    out = {}
    for k, (b, v) in BUFFET_CHORDS.items():
        bb = p(b) + semis
        while bb > 42:
            bb -= 12
        while bb < 30:
            bb += 12
        vv = [p(n) + semis for n in v]
        while max(vv) > 69:
            vv = [x - 12 for x in vv]
        out[k] = (bb, vv)
    return out


VF, VG = cmap(0), cmap(2)
SPARKLE = ['F5', 'A5', 'C6', 'F6', 'C6', 'A5', 'F5', 'C5']


def build():
    s = Song('MUS-GOUR-FREED', bpm=124, bars=80, key='F major', seed=405, jitter=0.012)
    s.V = VF
    s.channel('vln', 'strings', 36, 95, 98)
    s.channel('vc', 'cello', 82, 90, 98)
    s.channel('pizz', 'pizz', 74, 75, 80)
    s.channel('cl', 'clarinet', 60, 80, 84)
    s.channel('brass', 'brass', 70, 90, 88)
    s.channel('hn', 'horn', 78, 95, 92)
    s.channel('tuba', 'tuba', 88, 85, 84)
    s.channel('glock', 'glock', 44, 95, 64)
    s.channel('harp', 'harp', 46, 80, 76)
    s.channel('timp', 'timpani', 64, 80, 90)
    s.channel('choir', 'choir', 64, 105, 68)
    s.channel('sbass', 38, 64, 30, 88)
    s.channel('lead', 81, 60, 70, 84)
    s.channel('spad', 'warm_pad', 64, 90, 72)
    s.channel('kit', 'standard_kit', 64, 60, 90)
    for bar, nm in ((0, 'sparkle'), (4, 'A cello'), (20, "A' the house sings"), (36, 'feast drop'), (52, 'climb'),
                    (56, 'G major tutti'), (72, 'home'), (76, 'sparkle again')):
        s.section(bar, nm)

    def oompah(bar, sym, vel):
        b = p(s.V[sym][0])
        s.note('tuba', bar * 4, .8, b, vel)
        s.note('tuba', bar * 4 + 2, .8, b + 7 if sym not in ('C7', 'D7') else b, vel - 8)
        for beat in (1, 3):
            s.chord('pizz', bar * 4 + beat, .4, s.V[sym][1], vel - 14)

    def kick(bar, vel, clap=True, hats=True):
        for b in range(4):
            s.note('kit', bar * 4 + b, .25, 36, vel, human=False)
            if clap and b in (1, 3):
                s.note('kit', bar * 4 + b, .25, 39, vel - 14, human=False)
            if hats:
                s.note('kit', bar * 4 + b + .5, .2, 46, vel - 34, human=False)

    def sparkle(bar):
        for i, sym in enumerate(['F', 'Dm', 'Gm7', 'C7']):
            s.line('glock', bar + i, [(n, .5) for n in SPARKLE], 54, arc=False)
            oompah(bar + i, sym, 66)
            s.chord('choir', (bar + i) * 4, 4.05, s.V[sym][1], 46)
            s.harp(bar + i, sym, 50)
        s.note('kit', bar * 4, .5, 81, 70)
        s.motif('cl', bar + 1, motif_head('F4', 'major', rhythm=(1, .5, 2.5)) + [('r', 4)], 76, form='head (clarinet, sparkle)')
        s.chord('brass', (bar + 3) * 4 + 3, .9, ['C4', 'E4', 'G4', 'Bb4'], 84)
        s.swell('choir', bar + 3, 1, 90, 104)

    sparkle(0)

    # A 4-19: the theme breathes on a warm cello; the clarinet answers in the rests
    for i in range(16):
        sym = BUFFET_PROG[i]
        oompah(4 + i, sym, 66)
        s.harp(4 + i, sym, 46)
    s.mel('vc', 4, BUFFET_THEME, 92, tr=-12)
    for bar, fig in ((7, [('r', 2), ('A5', .5), ('Bb5', .5), ('C6', 1)]), (11, [('r', 2), ('G5', .5), ('A5', .5), ('Bb5', 1)]),
                     (15, [('r', 2), ('D6', .5), ('C6', .5), ('A5', 1)]), (18, [('r', 2), ('C6', .5), ('Bb5', .5), ('G5', 1)])):
        s.line('cl', bar, fig, 70)
    s.timp_hit(4 * 4, 'F2', 70)

    # A' 20-35: the house sings - strings in octaves, choir, brass punches, the resolved motif as the horns' countermelody
    for i in range(16):
        bar = 20 + i
        sym = BUFFET_PROG[i]
        oompah(bar, sym, 80)
        s.chord('choir', bar * 4, 4.05, [x + 12 for x in s.V[sym][1]], 50)
        s.chord('brass', bar * 4 + 1.5, .35, s.V[sym][1], 66)
        s.chord('brass', bar * 4 + 3.5, .35, s.V[sym][1], 62)
    s.mel('vln', 20, BUFFET_THEME, 98, tr=12)
    s.line('vln', 20, BUFFET_THEME, 82)
    s.line('glock', 20, BUFFET_THEME_8, 52, tr=12)
    s.motif('hn', 28, motif('F3', 'major', resolved=True) + [('r', 1)], 80, form='RESOLVED (horns, countermelody)', lead=False)
    s.note('kit', 20 * 4, 2, 49, 74)
    for k in range(8):
        s.note('kit', 35 * 4 + 2 + k * .25, .2, 38, 50 + k * 8, human=False)

    # FEAST DROP 36-51
    for i in range(16):
        bar = 36 + i
        sym = BUFFET_DROP_PROG[i % 4]
        b, v = s.V[sym]
        s.chord('spad', bar * 4, 4.05, v + [v[0] + 12], 80)
        for beat in range(4):
            s.note('sbass', bar * 4 + beat + .5, .4, b + 12, 94, human=False)
            s.note('sbass', bar * 4 + beat, .2, b, 78, human=False)
        if i % 2 == 0:
            s.chord('brass', bar * 4, .6, v, 90)
            s.timp_hit(bar * 4, b + 12, 86)
        s.chord('pizz', bar * 4 + 1, .3, v, 66)
        s.chord('pizz', bar * 4 + 3, .3, v, 66)
        kick(bar, 98)
    s.pump('spad', 36, 16, lo=30, hi=112)
    s.mel('lead', 36, BUFFET_HOOK, 86, tr=-12, legato=.85)
    s.mel('lead', 40, BUFFET_HOOK, 88, legato=.85, tr=-12)
    s.line('glock', 40, BUFFET_HOOK, 56)
    s.motif('lead', 44, motif('F4', 'major', resolved=True) + [('r', 1)], 90, form='RESOLVED (saw lead, the feast)', legato=.9)
    s.line('vln', 44, motif('F5', 'major', resolved=True), 80)
    s.mel('lead', 48, BUFFET_HOOK, 92, tr=-12, legato=.85)
    s.line('vln', 48, BUFFET_HOOK, 80, tr=-24)
    s.note('kit', 36 * 4, 3, 49, 94)
    s.note('kit', 44 * 4, 3, 49, 88)

    # CLIMB 52-55: D7 builds into G major
    for i, sym in enumerate(['Bb', 'C7', 'D7', 'D7']):
        bar = 52 + i
        s.chord('brass', bar * 4, 3.9, s.V[sym][1], 70 + i * 6)
        s.chord('choir', bar * 4, 4.05, [x + 12 for x in s.V[sym][1]], 56 + i * 4)
        s.note('tuba', bar * 4, 3.8, p(s.V[sym][0]), 80)
        kick(bar, 80 + i * 4, clap=False, hats=False)
    s.mel('vln', 52, [(n, .5) for n in ['C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'Bb5', 'C6']] + [('D6', 4)] +
          [(n, .5) for n in ['A5', 'B5', 'C6', 'D6', 'E6', 'F#6', 'G6', 'A6']] + [('F#6', 2), ('D6', 2)], 92, arc=False)
    s.timp_roll(54 * 4, 8, 'D2', 50, 100)

    # G MAJOR 56-71: the theme in full tutti, the resolved motif augmented in the horns
    s.V = VG
    for i in range(16):
        bar = 56 + i
        sym = BUFFET_PROG[i]
        oompah(bar, sym, 90)
        s.chord('choir', bar * 4, 4.05, [x + 12 for x in s.V[sym][1]], 62)
        s.chord('brass', bar * 4 + 1.5, .35, s.V[sym][1], 74)
        s.chord('brass', bar * 4 + 3.5, .35, s.V[sym][1], 70)
        kick(bar, 80, hats=i >= 8)
    s.mel('vln', 56, BUFFET_THEME, 104, tr=14)
    s.line('vln', 56, BUFFET_THEME, 90, tr=2)
    s.line('glock', 56, BUFFET_THEME_8, 58, tr=14)
    s.line('cl', 56, BUFFET_THEME, 70, tr=2)
    s.motif('hn', 64, augment(motif('G3', 'major', resolved=True), 1) + [('r', 1)], 92, form='RESOLVED (horns, G major tutti)', lead=False)
    s.note('kit', 56 * 4, 3, 49, 98)
    s.timp_hit(56 * 4, 'G2', 98)

    # HOME 72-75: turnaround back to F
    s.V = VF
    for i, sym in enumerate(['Gm7', 'C7', 'Gm7', 'C7']):
        bar = 72 + i
        oompah(bar, sym, 74 - i * 2)
        s.chord('choir', bar * 4, 4.05, s.V[sym][1], 54)
        s.harp(bar, sym, 52)
    s.motif('vc', 72, motif('F3', 'major', resolved=True) + [('r', 1)], 84, form='RESOLVED (cello, home)')
    s.line('cl', 74, [('Bb4', 2), ('A4', 2), ('G4', 2), ('E4', 2)], 66)

    sparkle(76)
    s.fade_vel(79, 80, 0.7, ['brass', 'choir', 'tuba'], start_factor=0.8)    # seam: a lighter 'ta-da' into the loop point
    return s
