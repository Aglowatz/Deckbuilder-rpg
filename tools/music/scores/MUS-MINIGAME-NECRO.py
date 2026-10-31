"""MUS-MINIGAME-NECRO - Kyle's memory matching. Loop, 48 bars 3/4, 110 BPM, A minor.
Light puzzle music: pizzicato and woodwinds pass the D.N.A. theme (moved to A minor) in short cells, a soft organ underneath, and a subtle
old-computer square-wave voice that blinks arpeggios like a card turning over. Nostalgic and curious, never abrasive. The B section lets
the flute ask the Crossroads motif; every phrase ends gently unresolved (on the dominant) so the matching can go on.
"""
from lib import Score, m, motif, motif_head, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS, theme_in

UP = -3                                     # C minor -> A minor
THEME = theme_in(DNA_THEME, UP)
INTRO = ['Cm', 'Ab', 'Fm', 'G7']
B_PROG = ['Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Fm', 'Cm/G', 'G7']


def shifted(chords, k):
    out = {}
    for sym, (b, v) in chords.items():
        bb = p(b) + k
        while bb < p('E1'):
            bb += 12
        out[sym] = (bb, [p(x) + k for x in v])
    return out


def build():
    s = Score('MUS-MINIGAME-NECRO', bpm=110, bars=48, meter=(3, 4), key='A minor', seed=316)
    s.V.update(shifted(DNA_CHORDS, UP))
    s.seat('pizz', 'cl', 'fl', 'bsn', 'cb', 'vc', 'cel', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=100, vol=58)
    s.channel('chip', 80, pan=40, reverb=60, vol=44)          # GM square lead: the old computer
    for bar, nm in ((0, 'intro'), (4, 'A cells'), (20, 'B the question'), (28, "A' together"), (44, 'outro')):
        s.section(bar, nm)

    def tick(bar, vel=28):
        s.note('perc', bar * 3, .15, 76, vel + 6, human=False)
        s.note('perc', bar * 3 + 1.5, .15, 77, vel - 4, human=False)

    def pz(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 3, .9, b, vel)
        v = sorted(p(n) for n in s.voicing(sym)[1])
        for beat, n in ((1, v[1]), (1.5, v[2]), (2, v[3])):
            s.note('pizz', bar * 3 + beat, .3, n + 12, vel - 12)

    def chip(bar, sym, vel):
        v = sorted(p(n) for n in s.voicing(sym)[1])
        for k, n in enumerate([v[0], v[2], v[3], v[2] + 12, v[3], v[2]]):
            s.note('chip', bar * 3 + k * .5, .2, n + 24, vel - (6 if k % 2 else 0))

    def intro(bar):
        for i, sym in enumerate(INTRO):
            pz(bar + i, sym, 58)
            tick(bar + i)
            s.pad('organ', bar + i, sym, 40, beats=3)
            chip(bar + i, sym, 46)
        s.motif('cel', bar + 1, motif_head('A5', 'minor', rhythm=(1, .5, 1.5)), 50, form='head (celesta)')

    intro(0)
    cells = [('cl', 4, THEME[:5], 0), ('pizz', 6, THEME[5:10], 0), ('fl', 8, THEME[10:15], 12), ('cel', 10, THEME[15:20], 12),
             ('cl', 12, THEME[20:25], 0), ('pizz', 14, THEME[25:30], 0), ('fl', 16, THEME[30:35], 12), ('cel', 18, THEME[35:], 12)]
    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        pz(bar, sym, 60)
        tick(bar)
        if i % 2 == 0:
            s.pad('organ', bar, sym, 38, beats=6)
        if i % 4 == 2:
            chip(bar, sym, 42)
    for ch, bar, mel, tr in cells:
        s.mel(ch, bar, mel, 86 if ch != 'cel' else 74, transpose=tr)

    for i in range(8):
        bar, sym = 20 + i, B_PROG[i]
        s.pad('organ', bar, sym, 44, beats=3, octave=1)
        s.note('cb', bar * 3, 2.8, p(s.voicing(sym)[0]), 50)
        tick(bar, 24)
        chip(bar, sym, 38)
    s.motif('fl', 20, motif('A4', 'minor') + m('r:2'), 84, form='stated (flute, curious)')
    s.mel('cl', 23, m('F4:2 E4:1 | D4:3 | Bb3:2 D4:1 | C4:2 E4:1 | E4:3'), 80)

    for i in range(16):
        bar, sym = 28 + i, DNA_PROG[i]
        pz(bar, sym, 64)
        tick(bar, 30)
        chip(bar, sym, 40)
        if i % 2 == 0:
            s.pad('organ', bar, sym, 42, beats=6)
    s.mel('fl', 28, THEME[:-1] + [('E5', 3)], 88, transpose=12)      # ends on the dominant: gently unresolved
    s.line('cl', 28, THEME[:-1] + [('E4', 3)], 60)
    s.line('bsn', 36, THEME[20:], 56, transpose=-12)

    intro(44)
    return s
