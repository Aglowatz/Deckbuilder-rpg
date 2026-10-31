"""MUS-GOUR-DUN-BATTLE - Test Kitchen, combat. 72 bars 4/4, 140 BPM, G minor.
The assembly line at full speed: a walking contrabass in 8ths, string 8ths, claves and woodblocks on the grid, kick and snare, timpani.
The Buffet theme in G minor goes to the brass in A; B is sustained tension (tremolo, choir, the Crossroads motif augmented in the horns
over a heartbeat timpani); C is the kitchen's machine drop (four-on-the-floor, synth bass, pumped pad, the drop hook in minor on the saw
lead, xylophone clockwork); D is the tutti, the theme in the strings with the motif in the horns. Intro/outro: a pad + horn bed over the
drive.
"""
from lib import Song, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_A, BUFFET_HOOK, to_mode

MINOR = {11: -1, 4: -1, 6: -1}
THEME = to_mode(transpose(BUFFET_THEME, 2), MINOR)
HOOK = to_mode(transpose(BUFFET_HOOK, 2), MINOR)
PROG = ['Gm', 'Ebmaj7', 'Cm7', 'D7', 'Gm', 'Eb', 'Cm', 'D7', 'Ebmaj7', 'Ebm6', 'Gm/D', 'A7', 'Cm7', 'D7', 'Gm', 'D7']
DROP = ['Gm', 'Eb', 'Bb', 'F']
TENSE = ['Gm', 'Ab', 'Fm', 'D7sus4', 'Gm', 'Ebmaj7', 'Am7b5', 'D7']


def build():
    s = Song('MUS-GOUR-DUN-BATTLE', bpm=140, bars=72, key='G minor', seed=403, jitter=0.006)
    s.channel('vln', 'strings', 36, 95, 98)
    s.channel('spic', 'strings', 30, 85, 76)
    s.channel('trem', 'tremolo', 50, 95, 74)
    s.channel('brass', 'brass', 70, 90, 96)
    s.channel('mtpt', 'muted_tpt', 56, 85, 84)
    s.channel('hn', 'horn', 78, 95, 92)
    s.channel('cb', 'contrabass', 92, 90, 92)
    s.channel('xylo', 'xylophone', 52, 80, 64)
    s.channel('timp', 'timpani', 64, 80, 94)
    s.channel('choir', 'choir', 64, 105, 66)
    s.channel('sbass', 38, 64, 30, 90)
    s.channel('lead', 81, 60, 70, 86)
    s.channel('spad', 'warm_pad', 64, 90, 72)
    s.channel('pad', 'slow_strings', 64, 100, 76)
    s.channel('kit', 'standard_kit', 64, 60, 92)
    for bar, nm in ((0, 'intro bed'), (4, 'A brass theme'), (20, 'B tension'), (36, 'C machine drop'), (52, 'D tutti'),
                    (68, 'outro bed')):
        s.section(bar, nm)

    def line_perc(bar, vel, kick=True):
        for k in range(8):
            s.note('kit', bar * 4 + k * .5, .1, 75 if k % 2 == 0 else 76, vel - 20 + (8 if k % 4 == 0 else 0), human=False)
        if kick:
            for b in range(4):
                s.note('kit', bar * 4 + b, .25, 36 if b in (0, 2) else 38, vel - (0 if b in (0, 2) else 10), human=False)
            s.note('kit', bar * 4 + 2.5, .25, 36, vel - 14, human=False)

    def walk(bar, sym, vel):
        tn = s.chord_tones(sym, s.voicing(sym)[0], 4)
        seq = [tn[0], tn[0] + 12 if tn[0] + 12 < 48 else tn[0], tn[1], tn[2], tn[0], tn[2], tn[1], tn[3] if tn[3] < 48 else tn[1]]
        for k, n in enumerate(seq):
            s.note('cb', bar * 4 + k * .5, .4, n, vel + (8 if k % 4 == 0 else -2), human=False)

    def drive(bar, sym, vel):
        tn = s.chord_tones(sym, 'G3', 4)
        cell = [tn[0], tn[0], tn[2], tn[0], tn[1], tn[0], tn[2], tn[3]]
        for k, n in enumerate(cell):
            s.note('spic', bar * 4 + k * .5, .3, n, vel + (10 if k % 4 == 0 else -4))

    def bed(bar):
        for i, sym in enumerate(['Gm', 'Gm', 'Eb', 'D7']):
            walk(bar + i, sym, 76)
            drive(bar + i, sym, 70)
            line_perc(bar + i, 80)
            s.pad('pad', bar + i, sym, 70, low='G3')
            s.chord('hn', (bar + i) * 4, 3.9, s.chord_tones(sym, 'D4', 3), 66)
            s.timp_hit((bar + i) * 4, p(s.voicing(sym)[0]) + 12, 84 if i % 2 == 0 else 70)
        s.motif('brass', bar + 1, motif_head('G4', 'minor', rhythm=(1, .5, 2.5)), 84, form='head (brass, over the bed)')
        s.swell('pad', bar + 3, 1, 84, 100)

    bed(0)

    # A 4-19: the theme in the brass, the line running underneath
    for i in range(16):
        sym = PROG[i]
        walk(4 + i, sym, 82)
        drive(4 + i, sym, 66)
        line_perc(4 + i, 84)
        s.pad('pad', 4 + i, sym, 52, low='G3')
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, p(s.voicing(sym)[0]) + 12, 86)
    s.mel('brass', 4, THEME, 96, transpose=-12)
    s.line('mtpt', 12, THEME[21:], 70, tr=-12)
    s.motif('hn', 8, motif('G3', 'minor') + [('r', 1)], 72, form='stated (horns, under the brass)', lead=False)

    # B 20-35: sustained tension - tremolo, choir, the motif augmented over a heartbeat
    for i in range(16):
        bar = 20 + i
        sym = TENSE[i % 8]
        s.pad('trem', bar, sym, 62, low='G3')
        s.pad('choir', bar, sym, 50, low='D4', n=3)
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 72)
        s.timp_hit(bar * 4, 'G2', 70)
        s.timp_hit(bar * 4 + .75, 'G2', 56)
        for k in range(4):
            s.note('kit', bar * 4 + k, .1, 75, 52, human=False)
    s.motif('hn', 20, augment(motif('G3', 'minor'), 2) + [('r', 2)], 92, form='augmented (horns, tension)')
    s.mel('vln', 24, augment(to_mode(transpose(BUFFET_THEME_A[:11], 2), MINOR), 2)[:8] + [('r', 1)], 82)
    s.motif('hn', 28, augment(motif('D4', 'minor'), 2) + [('r', 2)], 96, form='augmented, a fifth up (horns)')
    s.mel('vln', 32, [('Bb5', 4), ('A5', 4), ('G5', 4), ('F#5', 4)], 86)
    s.swell('trem', 20, 16, 70, 110)
    for k in range(16):
        s.note('kit', 35 * 4 + k * .25, .2, 38, 44 + k * 5, human=False)

    # C 36-51: the machine drop
    for i in range(16):
        bar = 36 + i
        sym = DROP[i % 4]
        b = p(s.voicing(sym)[0])
        s.pad('spad', bar, sym, 82, low='G3', n=4)
        for beat in range(4):
            s.note('sbass', bar * 4 + beat + .5, .4, b + 12, 94, human=False)
            s.note('sbass', bar * 4 + beat, .2, b, 80, human=False)
            s.note('kit', bar * 4 + beat, .25, 36, 100, human=False)
            if beat in (1, 3):
                s.note('kit', bar * 4 + beat, .25, 39, 86, human=False)
            s.note('kit', bar * 4 + beat + .5, .2, 46, 64, human=False)
        tn = s.chord_tones(sym, 'G5', 4)
        for k in range(16):
            s.note('xylo', bar * 4 + k * .25, .2, tn[(0, 2, 1, 3)[k % 4]], 50, human=False)
        if i % 2 == 0:
            s.chord('brass', bar * 4, .6, s.chord_tones(sym, 'G3', 4), 88)
    s.pump('spad', 36, 16, lo=30, hi=112)
    s.mel('lead', 36, HOOK, 90, tr=-12, legato=.85)
    s.motif('lead', 40, motif('G4', 'minor') + [('r', 1)], 90, form='stated (saw lead, machine drop)', legato=.9)
    s.mel('lead', 44, HOOK, 94, tr=-12, legato=.85)
    s.line('vln', 44, HOOK, 74, tr=-24)
    s.mel('lead', 48, THEME[:11] + [('r', 4)], 92, legato=.8)
    s.note('kit', 36 * 4, 3, 49, 96)
    s.note('kit', 44 * 4, 3, 49, 90)

    # D 52-67: the tutti - theme in the strings, brass stabs, the motif in the horns
    for i in range(16):
        bar = 52 + i
        sym = PROG[i]
        walk(bar, sym, 86)
        drive(bar, sym, 70)
        line_perc(bar, 90)
        s.pad('choir', bar, sym, 56, low='D4', n=3)
        s.chord('brass', bar * 4 + 1.5, .35, s.chord_tones(sym, 'G3', 3), 74)
        s.chord('brass', bar * 4 + 3.5, .35, s.chord_tones(sym, 'G3', 3), 70)
        if i % 4 == 0:
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 92)
            s.note('kit', bar * 4, 2, 49, 86)
    s.mel('vln', 52, THEME, 104)
    s.motif('hn', 60, motif('G3', 'minor') + [('r', 1)], 94, form='stated (horns, tutti)', lead=False)
    s.timp_roll(67 * 4, 4, 'D2', 50, 92)

    bed(68)
    s.fade_vel(70, 72, 1.15, ['cb', 'spic', 'kit', 'hn'])     # seam: a small lift into the loop point
    return s
