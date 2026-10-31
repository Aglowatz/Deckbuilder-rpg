"""MUS-NECRO-FREED - The Department of Necrotic Affairs, restored. 72 bars 3/4, 92 BPM, C major -> Eb major -> C major.
The long-postponed melody finally resolves. The D.N.A. waltz theme is taken to C major (Eb/Ab/Bb/Db raised: the same contour, the
questions answered), first by bassoon and clarinet with a dry little tick still in the clock (the humour stays), then by the strings
over a warm organ while the horns sing the Crossroads motif RESOLVED (C G F E D -> C). A calm middle in flute and cello; then the theme
rises to Eb major in organ, choir and strings, every phrase arriving home on time; the ending is calm, not a fanfare.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, to_mode, theme_in

MAJOR = {3: 1, 8: 1, 10: 1, 1: 1}            # C minor -> C major (Eb E, Ab A, Bb B, Db D)
THEME_C = to_mode(DNA_THEME, MAJOR)
THEME_EB = theme_in(THEME_C, 3)
PROG_C = ['C', 'C', 'F', 'F', 'G7', 'G7', 'C', 'Am', 'F', 'Dm', 'C/G', 'G7', 'C', 'Am', 'G7', 'C']
PROG_EB = ['Eb', 'Eb', 'Ab', 'Ab', 'Bb7', 'Bb7', 'Eb', 'Cm', 'Ab', 'Fm', 'Eb/Bb', 'Bb7', 'Eb', 'Cm', 'Bb7', 'Eb']
INTRO = ['C', 'Fmaj7', 'C/G', 'G7']
MID = ['Am', 'F', 'C', 'G', 'Am', 'Dm7', 'Fmaj7', 'G7', 'Am', 'F', 'Dm7', 'G7']
TURN = ['Ab', 'Fm', 'G7', 'G7']


def build():
    s = Score('MUS-NECRO-FREED', bpm=92, bars=72, meter=(3, 4), key='C major -> Eb major', seed=305)
    s.seat('vln', 'pad', 'vc', 'cb', 'pizz', 'harp', 'hn', 'bsn', 'cl', 'fl', 'timp', 'choir', 'cel', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=78)
    for bar, nm in ((0, 'intro'), (4, 'A winds, major'), (20, "A' strings + resolved motif"), (36, 'B calm'),
                    (48, 'C Eb major tutti'), (64, 'turn home'), (68, 'outro')):
        s.section(bar, nm)
    s.notes.append('FREED: the D.N.A. theme in C major then Eb major; the Crossroads motif resolved (C G F E D -> C).')

    def clock(bar, vel=26):
        s.note('perc', bar * 3, .2, 76, vel + 6, human=False)
        s.note('perc', bar * 3 + 2, .2, 77, vel - 4, human=False)

    def waltz(bar, sym, vel, pizz=True):
        s.bass(bar, sym, vel, 'waltz')
        if pizz:
            v = s.voicing(sym, low='G3', n=3)[1]
            for beat in (1, 2):
                for n in v:
                    s.note('pizz', bar * 3 + beat, .4, p(n), vel - 14)

    def organ(bar, sym, vel, beats=3):
        s.pad('organ', bar, sym, vel, beats=beats, low='E3', n=4)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            organ(bar + i, sym, 54)
            waltz(bar + i, sym, 54)
            clock(bar + i)
        s.harp(bar, 'C', 50, beats=3)
        s.harp(bar + 2, 'C/G', 48, beats=3)
        s.motif('cel', bar + 1, motif_tail('C5', 'major', rhythm=(1, .5, 1.5), resolved=True), 50, form='tail resolved (celesta)', lead=False)

    intro(0)

    # A 4-19: the theme in C major, bassoon and clarinet (dry, a little formal), the clock still ticking politely
    for i in range(16):
        bar, sym = 4 + i, PROG_C[i]
        waltz(bar, sym, 62)
        clock(bar)
        if i % 2 == 0:
            organ(bar, sym, 46, beats=6)
    s.mel('cl', 4, THEME_C, 84)
    s.line('bsn', 4, THEME_C[:20], 62, transpose=-12)
    s.line('bsn', 12, THEME_C[20:], 64, transpose=-24)
    s.motif('fl', 18, motif_tail('G5', 'major', rhythm=(1, .5, 1.5), resolved=True), 58, form='tail resolved (flute)', lead=False)

    # A' 20-35: strings take the theme over a warm organ; the horns sing the resolved Crossroads motif as a countermelody
    for i in range(16):
        bar, sym = 20 + i, PROG_C[i]
        waltz(bar, sym, 70)
        organ(bar, sym, 52)
        s.pad('pad', bar, sym, 48, low='G3')
        if i % 4 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 60)
    s.mel('vln', 20, THEME_C, 96)
    s.motif('hn', 24, motif('C4', 'major', resolved=True) + m('r:2'), 76, form='RESOLVED (horns, countermelody)', lead=False)
    s.motif('hn', 30, motif('G3', 'major', resolved=True) + m('r:2'), 76, form='RESOLVED (horns, on G)', lead=False)
    s.line('cel', 28, THEME_C[20:30], 50, transpose=12)
    s.swell('vln', 20, 16, 90, 108, 'arch')

    # B 36-47: calm - flute and cello over harp and soft organ; the phrases stop when they mean to
    for i in range(12):
        bar, sym = 36 + i, MID[i]
        organ(bar, sym, 42)
        s.harp(bar, sym, 46, beats=3)
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), 50)
    s.motif('fl', 36, augment(motif('A4', 'minor'), 1.5) + m('r:1.5'), 80, form='stated slow (flute, in A minor - one last question)')
    s.mel('vc', 41, THEME_C[20:30], 80, transpose=-12)
    s.motif('fl', 44, motif('C5', 'major', resolved=True) + m('r:2'), 82, form='RESOLVED (flute: answered)')
    s.timp_roll(47 * 3, 3, 'G2', 30, 70)

    # C 48-63: Eb major - organ, choir and strings, the whole theme arriving home on time
    for i in range(16):
        bar, sym = 48 + i, PROG_EB[i]
        waltz(bar, sym, 76)
        organ(bar, sym, 58)
        s.pad('choir', bar, sym, 56, low='G3')
        s.pad('pad', bar, sym, 50, low='Bb3')
        if i % 4 == 0:
            s.timp_hit(bar * 3, p(s.voicing(sym)[0]) + 12, 70)
    s.mel('vln', 48, THEME_EB, 100)
    s.line('organ', 48, THEME_EB, 70, transpose=-12)
    s.line('hn', 56, THEME_EB[20:], 78, transpose=-12)
    s.motif('hn', 60, motif('Eb4', 'major', resolved=True) + m('r:2'), 84, form='RESOLVED (horns, Eb)', lead=False)
    s.swell('choir', 48, 16, 70, 104, 'arch')
    s.hit('crash2', 48 * 3, 50, dur=2)

    # 64-67: the turn home to C (Ab, Fm, G7 - the old minor colour, now only a doorway)
    for i, sym in enumerate(TURN):
        bar = 64 + i
        organ(bar, sym, 52)
        waltz(bar, sym, 60)
        s.pad('pad', bar, sym, 44, low='G3')
    s.mel('cl', 64, m('C5:2 Ab4:1 | F4:3 | B4:2 D5:1 | G4:3'), 78)
    s.swell('organ', 64, 4, 96, 84)

    s.expr('organ', 68, 100)
    intro(68)
    # into the loop point: a soft string swell and a timpani breath under the last bar so it meets bar 0 (and the folded tail)
    s.pad('pad', 70, 'C/G', 40, low='G3')
    s.pad('pad', 71, 'G7', 46, low='G3')
    s.swell('pad', 70, 2, 70, 100)
    s.swell('organ', 71, 1, 100, 116)
    s.timp_roll(71 * 3, 3, 'G2', 30, 58)
    return s
