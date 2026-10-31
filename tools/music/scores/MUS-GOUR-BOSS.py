"""MUS-GOUR-BOSS - The Doppelganger. 80 bars 4/4, 128 BPM, F minor.
The Doppelganger's own idea is the MASK: it begins exactly like the Buffet's welcome (C A C F E F) and then slides chromatically down -
a copy that goes wrong. It first borrows the Gourmand's elegance: the Buffet theme in F major on the clarinet, imitated a bar later in
strict canon by the muted trumpet (an impersonation), the copy drifting a semitone flat in the second half. Then the warmth peels away:
the theme in F minor, the mask in the brass, and the hero's Crossroads motif against its MIRROR (the inversion) in the trombones. The darker
middle is the disguise's loss: half-time, choir and tremolo, the mirrored motif augmented, faceless echoes on a celesta bent 40 cents
flat. The climax is a warped EDM drop (the drop hook in minor, the theme in canon a beat apart), hero motif and mirror together. Intro and
outro: a pad bed with a heartbeat and the mask's head.
"""
from lib import Song, m, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_A, BUFFET_HOOK, BUFFET_PROG, BUFFET_CHORDS, to_mode

MINOR = {9: -1, 2: -1, 4: -1}
THEME_M = to_mode(BUFFET_THEME, MINOR)
HOOK_M = to_mode(BUFFET_HOOK, MINOR)
MASK = m('C5:.5 A4:.5 C5:.5 F5:1 E5:.5 F5:1 | F#5:1.5 F5:.5 E5:1 Eb5:1 | D5:.5 Db5:.5 C5:1 B4:1.5 Bb4:.5 | A4:3 r:1')
MASK_M = m('C5:.5 Ab4:.5 C5:.5 F5:1 E5:.5 F5:1 | Gb5:1.5 F5:.5 E5:1 Eb5:1 | D5:.5 Db5:.5 C5:1 B4:1.5 Bb4:.5 | Ab4:3 r:1')
PROG_M = ['Fm', 'Dbmaj7', 'Bbm7', 'C7', 'Fm', 'Db', 'Bbm', 'C7', 'Dbmaj7', 'Gb', 'Fm/C', 'C7', 'Bbm7', 'C7', 'Fm', 'C7']
MASK_H = ['F', 'Gbmaj7', 'Bbm6', 'E7']
DARK = ['Fm', 'Gb', 'Ebm', 'C7sus4', 'Fm', 'Dbmaj7', 'Bdim7', 'C7']
DROP = ['Fm', 'Db', 'Ab', 'Eb']


def build():
    s = Song('MUS-GOUR-BOSS', bpm=128, bars=80, key='F minor', seed=404, jitter=0.01)
    s.V = dict(BUFFET_CHORDS)
    s.channel('vln', 'strings', 36, 95, 98)
    s.channel('trem', 'tremolo', 50, 95, 76)
    s.channel('cl', 'clarinet', 60, 80, 96)
    s.channel('mtpt', 'muted_tpt', 56, 85, 90)
    s.channel('brass', 'brass', 70, 90, 96)
    s.channel('tbn', 'trombone', 88, 95, 88)
    s.channel('hn', 'horn', 78, 95, 92)
    s.channel('tuba', 'tuba', 88, 85, 84)
    s.channel('cel', 'celesta', 44, 100, 74)
    s.channel('glock', 'glock', 40, 95, 60)
    s.channel('timp', 'timpani', 64, 80, 94)
    s.channel('choir', 'choir', 64, 110, 72)
    s.channel('sbass', 38, 64, 30, 88)
    s.channel('lead', 81, 60, 70, 86)
    s.channel('pad', 'warm_pad', 64, 95, 76)
    s.channel('kit', 'standard_kit', 64, 60, 92)
    for bar, nm in ((0, 'intro mask'), (4, 'A borrowed elegance'), (20, 'B warmth peels'), (36, 'C disguise lost'),
                    (52, 'D warped drop'), (72, 'wind-down'), (76, 'outro mask')):
        s.section(bar, nm)
    s.notes.append('Villain idea = MASK (the welcome figure sliding chromatically down); imitation by strict canon; hero motif vs its inversion.')

    def heart(bar, vel):
        s.note('kit', bar * 4, .25, 36, vel, human=False)
        s.note('kit', bar * 4 + .75, .25, 36, vel - 16, human=False)
        s.note('kit', bar * 4 + 2, .25, 36, vel - 6, human=False)
        s.note('kit', bar * 4 + 2.75, .25, 36, vel - 20, human=False)

    def groove(bar, vel):
        for b in range(4):
            s.note('kit', bar * 4 + b, .25, 36 if b % 2 == 0 else 38, vel - (0 if b % 2 == 0 else 8), human=False)
            s.note('kit', bar * 4 + b + .5, .2, 42, vel - 36, human=False)
        s.note('kit', bar * 4 + 3.5, .25, 36, vel - 14, human=False)

    def echo(ch1, ch2, bar, mel, vel, delay, semis=0, tr=0):
        """A line and its imitation `delay` beats later (`semis` off: the copy that drifts)."""
        s.mel(ch1, bar, mel, vel, tr=tr)
        s.line(ch2, bar, mel, vel - 10, tr=tr + semis, beat=delay)

    def bed(bar):
        for i, sym in enumerate(['Fm', 'Fm', 'Gb', 'C7']):
            s.pad('pad', bar + i, sym, 82, low='F3')
            s.pad('trem', bar + i, sym, 60, low='C4', n=3)
            s.note('tuba', (bar + i) * 4, 4, p(s.voicing(sym)[0]), 74)
            heart(bar + i, 94)
            s.timp_hit((bar + i) * 4, 'F2' if sym != 'C7' else 'C2', 80)
            s.chord('brass', (bar + i) * 4, 3.8, s.chord_tones(sym, 'C4', 3), 72)
        s.mel('cel', bar, MASK[:6] + [('r', 3)], 76)
        s.line('glock', bar, MASK[:6] + [('r', 3)], 54, tr=-1, beat=.5)
        s.motif('hn', bar + 2, motif_head('F3', 'minor', rhythm=(1, .5, 2.5)) + [('r', 4)], 82, form='head (horns, in the bed)')
        s.swell('pad', bar + 3, 1, 90, 104)

    bed(0)

    # A 4-19: borrowed elegance - the Buffet theme in F major, imitated in strict canon; the copy drifts flat in bars 12-19
    for i in range(16):
        bar = 4 + i
        sym = BUFFET_PROG[i]
        b = p(s.V[sym][0])
        s.note('tuba', bar * 4, .7, b, 76)
        s.note('tuba', bar * 4 + 2, .7, b + 7 if sym not in ('C7', 'D7') else b, 68)
        s.chord('pad', bar * 4 + 1, .4, s.V[sym][1], 46)
        s.chord('pad', bar * 4 + 3, .4, s.V[sym][1], 46)
        heart(bar, 66)
    s.mel('cl', 4, BUFFET_THEME[:21], 94)
    s.line('mtpt', 5, BUFFET_THEME[:21], 78)
    echo('cl', 'mtpt', 8, BUFFET_THEME[21:40], 94, 4, semis=0)
    echo('cl', 'mtpt', 12, BUFFET_THEME[40:], 94, 2, semis=-1)
    s.line('glock', 16, MASK, 52, tr=12)
    s.motif('hn', 14, motif('F3', 'major') + [('r', 1)], 70, form='stated (horns, borrowed - the hero in the Gourmand key)', lead=False)
    s.timp_roll(19 * 4, 4, 'C2', 44, 96)

    # B 20-35: the warmth peels away - the theme in F minor, the mask in the brass, the hero's motif against its mirror
    for i in range(16):
        bar = 20 + i
        sym = PROG_M[i] if i < 8 else MASK_H[i % 4]
        s.pad('trem', bar, sym, 64, low='F3')
        s.note('tuba', bar * 4, 1.8, p(s.voicing(sym)[0]), 80)
        s.note('tuba', bar * 4 + 2, 1.8, p(s.voicing(sym)[0]), 72)
        groove(bar, 82)
        if i % 4 == 0:
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 88)
    echo('vln', 'cl', 20, THEME_M[:21], 98, 1)
    s.motif('hn', 24, motif('F4', 'minor') + [('r', 1)], 96, form='stated (horns: the hero)')
    s.motif('tbn', 24, motif('F4', 'minor', inverted=True) + [('r', 1)], 90, form='inverted - the MIRROR (trombones, against the hero)', lead=False)
    s.mel('brass', 28, MASK_M * 2, 98)
    s.line('mtpt', 28, MASK_M * 2, 74, beat=1, tr=-1)
    s.note('kit', 28 * 4, 2, 49, 90)
    for k in range(16):
        s.note('kit', 35 * 4 + k * .25, .2, 38, 40 + k * 5, human=False)

    # C 36-51: the disguise is lost - half-time, choir, the mirror augmented, faceless echoes on a bent celesta
    s.detune('cel', -40, 36)
    for i in range(16):
        bar = 36 + i
        sym = DARK[i % 8]
        s.pad('choir', bar, sym, 62, low='C4', n=3)
        s.pad('pad', bar, sym, 58, low='F3')
        s.note('tuba', bar * 4, 4, p(s.voicing(sym)[0]), 66)
        heart(bar, 70)
    s.motif('tbn', 36, augment(motif('F3', 'minor', inverted=True), 2) + [('r', 2)], 88, form='inverted, augmented (trombones, the mirror)')
    s.line('cel', 38, THEME_M[:6] + [('r', 4)], 62)
    s.line('cel', 39, THEME_M[:6] + [('r', 4)], 50, tr=-1, beat=2)
    s.mel('vln', 44, augment(THEME_M[21:31], 2)[:8], 84)
    s.motif('hn', 48, augment(motif_head('C4', 'minor'), 2) + [('r', 3)], 80, form='head augmented (horns, alone)', lead=False)
    s.swell('choir', 36, 16, 70, 112)
    s.detune('cel', 0, 52)
    s.timp_roll(51 * 4, 4, 'C2', 40, 104)

    # D 52-71: the warped drop - four-on-the-floor, the hook in minor, the theme in canon a beat apart, hero and mirror together
    for i in range(20):
        bar = 52 + i
        sym = DROP[i % 4]
        b = p(s.voicing(sym)[0])
        s.pad('pad', bar, sym, 84, low='F3')
        for beat in range(4):
            s.note('sbass', bar * 4 + beat + .5, .4, b + 12, 94, human=False)
            s.note('sbass', bar * 4 + beat, .2, b, 80, human=False)
            s.note('kit', bar * 4 + beat, .25, 36, 102, human=False)
            if beat in (1, 3):
                s.note('kit', bar * 4 + beat, .25, 39, 88, human=False)
            s.note('kit', bar * 4 + beat + .5, .2, 46, 64, human=False)
        if i % 2 == 0:
            s.chord('brass', bar * 4, .6, s.chord_tones(sym, 'F3', 4), 90)
            s.timp_hit(bar * 4, b + 12, 90)
        if i % 4 == 0:
            s.note('kit', bar * 4, 2, 49, 92)
    s.pump('pad', 52, 20, lo=34, hi=112)
    s.mel('lead', 52, HOOK_M, 90, tr=-12, legato=.85)
    s.line('lead', 52, HOOK_M, 62, tr=-13, beat=.5, legato=.85)
    echo('vln', 'brass', 56, THEME_M[:21], 104, 1)
    s.mel('lead', 60, HOOK_M, 94, tr=-12, legato=.85)
    s.motif('hn', 64, motif('F4', 'minor') + [('r', 1)], 104, form='stated (horns, the hero, climax)')
    s.motif('tbn', 64, motif('F4', 'minor', inverted=True) + [('r', 1)], 96, form='inverted (trombones, the mirror, climax)', lead=False)
    s.mel('vln', 64, MASK_M * 2, 100, tr=12)
    s.line('brass', 66, MASK_M[:6], 88)

    # wind-down 72-75: the mask slides down into the bed
    for i, sym in enumerate(['Fm', 'Gb', 'Bbm6', 'C7']):
        s.pad('pad', 72 + i, sym, 76 - i * 2, low='F3')
        s.note('tuba', (72 + i) * 4, 4, p(s.voicing(sym)[0]), 76)
        heart(72 + i, 80)
    s.mel('brass', 72, MASK_M, 88)
    s.line('cl', 72, MASK_M, 70, tr=-1, beat=1)

    bed(76)
    return s
