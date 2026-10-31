"""MUS-NECRO-DUN-BATTLE - Hall of Final Approvals, combat. 128 bars 3/4, 146 BPM, F minor.
The Hall's desk-to-desk phrases tightened into a fight: a moving bass line (cello and contrabass walking in quarters and eighths), concert
bass drum and timpani under the clock, and sections that alternate sustained tension (tremolo, held organ, the choir) with active
passages (string and harpsichord ostinato, brass). The D.N.A. theme in F minor is in every section - horns, violins, organ, brass tutti,
or split into fragments - and the Crossroads motif guests in the trombones, augmented in the choir, and in the tutti climax.
"""
from lib import Score, m, motif, motif_head, motif_tail, augment, p
from lib.zones import DNA_THEME, DNA_PROG, DNA_CHORDS, theme_in

UP = 5
THEME = theme_in(DNA_THEME, UP - 12)
THEME_A, THEME_B = THEME[:20], THEME[20:]
INTRO = ['Cm', 'Cm', 'Db', 'G7']
TENSE = ['Ab', 'Ab', 'Fm', 'Fm', 'Db', 'Db', 'Gs', 'G7'] * 2
ACT = ['Cm', 'Bdim', 'Cm', 'G7', 'Ab', 'Fm', 'Db', 'G7'] * 2


def shifted(chords, k):
    out = {}
    for sym, (b, v) in chords.items():
        bb = p(b) + k
        while bb > p('F#2'):
            bb -= 12
        out[sym] = (bb, [p(x) + k for x in v])
    return out


def build():
    s = Score('MUS-NECRO-DUN-BATTLE', bpm=146, bars=128, meter=(3, 4), key='F minor', seed=303)
    s.V.update(shifted(DNA_CHORDS, UP))
    s.seat('vln', 'spic', 'trem', 'vc', 'cb', 'hn', 'tbn', 'tuba', 'bsn', 'timp', 'choir', 'cel', 'perc')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=84)
    s.channel('hpsd', 'harpsichord', pan=30, reverb=80, vol=68)
    for bar, nm in ((0, 'intro'), (4, 'A walking theme'), (20, 'B held tension'), (36, 'C active motif'), (52, 'D violins'),
                    (68, 'E choir'), (84, 'F brass tutti'), (100, 'G fragments'), (116, 'H climax'), (124, 'outro')):
        s.section(bar, nm)

    def clock(bar, vel=40, eighths=False):
        for k in range(6 if eighths else 3):
            t = bar * 3 + k * (.5 if eighths else 1)
            s.note('perc', t, .2, 76 if k == 0 else 77, vel + (8 if k == 0 else -4), human=False)

    def walk(bar, sym, vel, nxt=None):
        """Moving bass: root, fifth, approach to the next root (cb), cello an octave up on the beat."""
        b = p(s.voicing(sym)[0])
        n = p(s.voicing(nxt or sym)[0])
        appr = n - 1 if n > b else n + 1
        for k, (t, nn, d) in enumerate(((0, b, .9), (1, b + 7 if b + 7 < 48 else b - 5, .9), (2, b + 12 if b < 36 else b, .4),
                                         (2.5, appr if appr >= 28 else appr + 12, .4))):
            s.note('cb', bar * 3 + t, d, nn, vel + (8 if k == 0 else -2))
        s.note('vc', bar * 3, 1.0, b + 12, vel - 8)

    def ost(bar, sym, vel, ch='spic'):
        tn = sorted(p(x) for x in s.voicing(sym)[1])
        for k in range(6):
            s.note(ch, bar * 3 + k * .5, .35, tn[[0, 2, 1, 3, 2, 1][k]] + (0 if ch == 'spic' else 12), vel + (10 if k in (0, 3) else -4))

    def drums(bar, vel):
        s.hit('bd', bar * 3, vel + 6)
        s.hit('bd2', bar * 3 + 1.5, vel - 12)
        s.hit('snare2', bar * 3 + 2, vel - 18)

    def timp(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.timp_hit(bar * 3, b + 12 if b + 12 <= p('A2') else b, vel)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            ost(bar + i, sym, 70)
            clock(bar + i, 42, eighths=True)
            walk(bar + i, sym, 72, INTRO[(i + 1) % 4])
            s.pad('organ', bar + i, sym, 54, beats=3)
            s.pad('trem', bar + i, sym, 60)
            drums(bar + i, 66)
        s.motif('hn', bar + 1, motif_head('F3', 'minor', rhythm=(1, .5, 3.5)), 76, form='head (horns)')
        s.timp_roll((bar + 3) * 3 + 1, 2, 'C2', 46, 86)

    intro(0)

    # A 4-19: the theme in the horns over the walking bass
    for i in range(16):
        bar, sym = 4 + i, DNA_PROG[i]
        walk(bar, sym, 78, DNA_PROG[(i + 1) % 16])
        clock(bar, 38)
        ost(bar, sym, 60)
        drums(bar, 62)
        if i % 4 == 0:
            timp(bar, sym, 80)
    s.mel('hn', 4, THEME, 98, transpose=12)
    s.line('bsn', 4, THEME_A, 66)
    s.line('tbn', 12, THEME_B, 72)
    s.timp_roll(19 * 3, 3, 'C2', 50, 96)

    # B 20-35: held tension - tremolo, organ, theme fragments in the choir and organ, timpani rolls; the bass keeps walking softly
    for i in range(16):
        bar, sym = 20 + i, TENSE[i]
        s.pad('trem', bar, sym, 64)
        if i % 2 == 0:
            s.pad('organ', bar, sym, 58, beats=6)
        walk(bar, sym, 64, TENSE[(i + 1) % 16])
        clock(bar, 34)
        if i % 4 == 3:
            s.timp_roll(bar * 3, 3, p(s.voicing(sym)[0]) + 12, 40, 80)
    s.mel('choir', 20, THEME_A[:10], 90, transpose=12)
    s.mel('organ', 24, THEME_A[10:], 92, transpose=12)
    s.mel('choir', 28, THEME_B[:10], 92, transpose=12)
    s.mel('organ', 32, THEME_B[10:], 96, transpose=12)
    s.motif('cel', 30, motif_head('F5', 'minor'), 54, form='head (celesta glint)', lead=False)

    # C 36-51: active - ostinato + harpsichord, the Crossroads motif in trombones and horns
    for i in range(16):
        bar, sym = 36 + i, ACT[i]
        ost(bar, sym, 70)
        ost(bar, sym, 52, ch='hpsd')
        walk(bar, sym, 82, ACT[(i + 1) % 16])
        clock(bar, 40, eighths=True)
        drums(bar, 70)
        if i % 2 == 0:
            timp(bar, sym, 84)
    s.motif('tbn', 36, motif('F3', 'minor') + m('r:2'), 98, form='stated (trombones)')
    s.motif('hn', 39, motif('Ab3', 'minor') + m('r:2'), 98, form='stated (horns, up a third)')
    s.mel('hn', 42, THEME_A[:10], 96, transpose=12)
    s.motif('tbn', 44, motif('F3', 'minor') + m('r:2'), 100, form='stated (trombones + tuba)')
    s.line('tuba', 44, motif('F3', 'minor') + m('r:2'), 66, transpose=-12)
    s.mel('hn', 47, THEME_B[10:], 98, transpose=12)
    s.hit('crash', 52 * 3, 74, dur=2)

    # D 52-67: the theme's answer in the violins 8va with the organ, deeper drums
    for i in range(16):
        bar, sym = 52 + i, DNA_PROG[i]
        ost(bar, sym, 66)
        walk(bar, sym, 80, DNA_PROG[(i + 1) % 16])
        clock(bar, 40)
        drums(bar, 72)
        s.pad('organ', bar, sym, 50, beats=3)
        if i % 2 == 0:
            timp(bar, sym, 82)
    s.mel('vln', 52, THEME, 100, transpose=12)
    s.line('organ', 52, THEME, 74)
    s.swell('vln', 52, 16, 96, 116, 'arch')

    # E 68-83: held again - the choir sings the motif augmented over an organ pedal; the clock alone keeps time
    for i in range(16):
        bar, sym = 68 + i, TENSE[i]
        s.pad('organ', bar, sym, 56, beats=3)
        s.pad('trem', bar, sym, 52)
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), 62)
        clock(bar, 36)
        if i % 4 == 0:
            s.hit('bd', bar * 3, 70)
    s.motif('choir', 68, augment(motif('F4', 'minor'), 2) + m('r:2'), 92, form='augmented (choir)')
    s.mel('bsn', 76, THEME_A[:10], 84)
    s.mel('cel', 80, THEME_A[10:15], 70, transpose=24)
    s.timp_roll(83 * 3, 3, 'C2', 40, 100)

    # F 84-99: brass tutti on the whole theme
    for i in range(16):
        bar, sym = 84 + i, DNA_PROG[i]
        ost(bar, sym, 74)
        walk(bar, sym, 88, DNA_PROG[(i + 1) % 16])
        clock(bar, 44, eighths=True)
        drums(bar, 78)
        s.pad('trem', bar, sym, 62)
        timp(bar, sym, 86 if i % 2 == 0 else 70)
        if i % 4 == 0:
            s.hit('crash', bar * 3, 80, dur=2)
    s.mel('hn', 84, THEME, 104, transpose=12)
    s.line('tbn', 84, THEME, 86)
    s.line('vln', 84, THEME, 90, transpose=24)

    # G 100-115: fragments passed between desks over the ostinato, building
    for i in range(16):
        bar, sym = 100 + i, ACT[i]
        ost(bar, sym, 62 + i)
        ost(bar, sym, 44 + i, ch='hpsd')
        walk(bar, sym, 72 + i, ACT[(i + 1) % 16])
        clock(bar, 38 + i // 2)
        drums(bar, 60 + i)
    for ch, bar, mel, tr in (('cel', 100, THEME_A[:5], 24), ('bsn', 102, THEME_A[5:10], 0), ('hn', 104, THEME_A[10:15], 12),
                             ('vln', 106, THEME_A[15:], 12), ('cel', 108, THEME_B[:5], 24), ('bsn', 110, THEME_B[5:10], 0),
                             ('hn', 112, THEME_B[10:15], 12), ('vln', 114, THEME_B[15:], 12)):
        s.mel(ch, bar, mel, 92 if ch != 'cel' else 78, transpose=tr)
    s.snare_roll(115 * 3, 3, 30, 100, inst='bd2', rate=6)

    # H 116-123: climax - the motif stated tutti, then the theme's head in the organ
    for i, sym in enumerate(['Cm', 'Cm', 'Ab', 'Ab', 'Db', 'Db', 'G7', 'G7']):
        bar = 116 + i
        ost(bar, sym, 80)
        walk(bar, sym, 92)
        clock(bar, 46, eighths=True)
        drums(bar, 82)
        s.pad('choir', bar, sym, 70, low='G3')
        s.pad('trem', bar, sym, 66)
        timp(bar, sym, 90)
    s.motif('hn', 116, motif('F4', 'minor') + m('r:2'), 108, form='stated (tutti: horns, trombones, violins 8va)')
    s.line('tbn', 116, motif('F3', 'minor') + m('r:2'), 92)
    s.line('vln', 116, motif('F5', 'minor') + m('r:2'), 98)
    s.mel('organ', 119, THEME_A[:10], 98, transpose=12)
    s.hit('crash', 116 * 3, 90, dur=2)

    intro(124)
    return s
