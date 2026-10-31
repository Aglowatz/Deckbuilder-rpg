"""MUS-ARENA-ELITE - The championship card (arena boss / high-tier). Loop, 68 bars 4/4, 148 BPM, Ab major.
The arena tune developed, not just louder: it enters in the horns with a running violin countersubject and the cellos in canon one
bar behind; a modulating fugato sequences its head up through C minor and E major; the climactic middle (choir, timpani, the tune
augmented in the full brass over string 16ths, the Crossroads motif in the trumpets) is the peak; a quiet strategic canon for
pizzicato and woodwinds gives the duel room; the tune returns in tutti with its own countermelody, and the fanfare bed closes the loop.
"""
from lib import Score, motif, motif_head, motif_tail, augment, m, p, transpose, voice
from scores._fork_c import ARENA_THEME, ARENA_PROG

T = 5                                    # Eb -> Ab
PROG = ['Ab', 'Ab', 'Fm', 'Db Eb', 'Ab', 'Db', 'Bbm7 Eb', 'Ab']
COUNTER = m('C5:.5 Bb4:.5 Ab4:.5 Bb4:.5 C5:.5 Db5:.5 Eb5:.5 F5:.5 | Eb5:.5 Db5:.5 C5:.5 Db5:.5 Eb5:1 Ab4:1 | '
            'F4:.5 G4:.5 Ab4:.5 Bb4:.5 C5:.5 Bb4:.5 Ab4:.5 G4:.5 | Ab4:.5 Bb4:.5 C5:.5 Eb5:.5 Db5:1 G4:1')


def chords_of(prog, bar0):
    out = []
    for bar, spec in enumerate(prog):
        syms = spec.split()
        for k, sym in enumerate(syms):
            out.append((bar0 + bar, k * 4 / len(syms), 4 / len(syms), sym))
    return out


def build():
    s = Score('MUS-ARENA-ELITE', bpm=148, bars=68, key='Ab major', seed=967)
    s.seat('vln', 'spic', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'cl', 'fl', 'ob', 'pizz', 'timp', 'perc', 'choir')
    for bar, nm in ((0, 'fanfare'), (4, 'A tune + countersubject + canon'), (20, 'B fugato'), (28, 'C climax'), (44, 'D strategy canon'),
                    (56, 'E tutti return'), (64, 'fanfare')):
        s.section(bar, nm)

    def harmony(bar0, vel, strings=True, n=8):
        for bar, beat, dur, sym in chords_of(PROG[:n], bar0):
            s.bass_at(bar * 4 + beat, dur, sym, vel, chs=('cb', None))
            if strings:
                tn = voice(sym, 'C4', 3)
                for k in range(int(dur * 4)):
                    s.note('spic', bar * 4 + beat + k * .25, .2, tn[k % 3], vel - 10 + (10 if k % 4 == 0 else 0))

    def kit(bar, vel):
        s.drum(bar, [(0, 'bd', 8), (1, 'snare', -4), (2, 'bd', 2), (2.5, 'bd', -6), (3, 'snare', 0), (3.75, 'snare2', -12)], vel)

    def fanfare(bar):
        for i, sym in enumerate(['Ab', 'Db', 'Eb', 'Eb7']):
            s.brass('tbn', bar + i, sym, 78, beats=1.5, low='Eb3')
            s.brass('tbn', bar + i, sym, 72, beats=2, low='Eb3', beat=2)
            s.pad('pad', bar + i, sym, 62, low='Ab3')
            s.bass(bar + i, sym, 72, 'half', chs=('cb', None))
            kit(bar + i, 72)
        s.mel('tpt', bar, m('Eb5:.5 Eb5:.25 Eb5:.25 Ab5:1 C6:1 Eb6:1 | Db6:2 F6:2 | Eb6:1 Bb5:1 G5:1 Bb5:1 | Eb6:4'), 90)
        s.line('hn', bar, m('C5:.5 C5:.25 C5:.25 Eb5:1 Ab5:1 C6:1 | Ab5:2 Db6:2 | Bb5:1 G5:1 Eb5:1 G5:1 | Bb5:4'), 62, transpose=-12)
        s.timp_hit(bar * 4, 'Ab2', 86)
        s.snare_roll((bar + 3) * 4, 4, 40, 86)

    fanfare(0)

    # A 4-19: tune in the horns, violin countersubject, cellos in canon a bar later
    harmony(4, 72)
    harmony(12, 74)
    for b in range(4, 20):
        kit(b, 72)
    th = transpose(ARENA_THEME, T - 12)
    s.mel('hn', 4, th, 94)
    s.line('vln', 4, COUNTER * 2, 80)
    s.line('vc', 5, transpose(ARENA_THEME[:20], T - 24), 70)
    s.mel('tpt', 12, transpose(ARENA_THEME, T), 92)
    s.line('vln', 12, transpose(COUNTER * 2, 12), 64)
    s.line('vc', 13, transpose(ARENA_THEME[:20], T - 24), 72)
    s.motif('fl', 10, motif('Ab5', 'major') + [('r', 1)], 72, form='stated (flute, above the canon)', lead=False)
    s.hit('crash', 12 * 4, 84)

    # B 20-27: fugato - the tune's head sequenced Ab -> C minor -> E major -> back, voices entering
    head = transpose(ARENA_THEME[:8], T)            # bars 1-2 of the tune
    entries = [(20, 'vln', 0, 'Ab'), (22, 'cl', 3, 'Cm'), (24, 'hn', 8, 'E'), (26, 'tpt', 0, 'Eb7')]
    syms = ['Ab', 'Fm', 'Cm', 'G', 'E', 'C#m', 'Eb', 'Eb7']
    for i, sym in enumerate(syms):
        s.pad('pad', 20 + i, sym, 56, low='Ab3')
        s.bass(20 + i, sym, 66, 'march', chs=('cb', None))
        kit(20 + i, 66)
    for bar, ch, semi, nm in entries:
        s.mel(ch, bar, transpose(head, semi - (12 if ch in ('hn',) else 0)), 90)
    s.motif('tbn', 24, motif('E3', 'major') + [('r', 1)], 82, form='stated (trombones, E major, in the fugato)', lead=False)
    s.timp_roll(27 * 4, 4, 'Eb3', 50, 92)

    # C 28-43: climax - choir, the tune augmented in the full brass over string 16ths, the motif in the trumpets
    harmony(28, 82, n=8)
    harmony(36, 84, n=8)
    for b in range(28, 44):
        kit(b, 82)
        s.pad('choir', b, PROG[(b - 28) % 8].split()[0], 66, low='Ab3', n=3)
        if (b - 28) % 4 == 0:
            s.hit('crash', b * 4, 88)
            s.timp_hit(b * 4, 'Ab2' if (b - 28) % 8 == 0 else 'Eb3', 94)
    s.mel('tbn', 28, augment(transpose(ARENA_THEME[:15], T - 12), 2), 92)
    s.line('tuba', 28, augment(transpose(ARENA_THEME[:15], T - 24), 2), 74)
    s.mel('vln', 28, transpose(ARENA_THEME, T + 12)[:15], 100)
    s.motif('tpt', 32, motif('Ab4', 'major') + [('r', 1)], 96, form='stated (trumpets, climax)')
    s.motif('tpt', 36, motif('C5', 'minor') + [('r', 1)], 98, form='stated (trumpets, C minor, climax)')
    s.mel('vln', 38, m('Eb6:1 Db6:1 C6:1 Bb5:1 | Ab5:2 C6:2 | Bb5:1 Ab5:1 G5:1 Bb5:1 | Eb6:4'), 100)
    s.motif('hn', 40, augment(motif_head('Ab3', 'major'), 2) + [('r', 4)], 92, form='head augmented (horns)', lead=False)
    s.snare_roll(43 * 4, 4, 50, 96)

    # D 44-55: strategy canon - pizzicato and woodwinds, quiet
    dprog = ['Fm', 'Db', 'Ab/C', 'Eb', 'Fm', 'Bbm', 'Eb7sus4', 'Eb7', 'Db', 'Ab/C', 'Bbm7', 'Eb7']
    for i, sym in enumerate(dprog):
        bar = 44 + i
        s.pizz(bar, sym, 60)
        s.pad('pad', bar, sym, 44, low='Ab3')
        s.bass(bar, sym, 54, 'whole', chs=('cb', None))
        s.drum(bar, [(0, 'bd', 0), (2, 'snare2', -12)], 56)
    canon = m('F5:1 Eb5:1 Db5:1 C5:1 | Bb4:1.5 C5:.5 Db5:2 | C5:1 Bb4:1 Ab4:1 G4:1 | Ab4:4')
    s.mel('ob', 44, canon, 78)
    s.line('cl', 45, transpose(canon, -12), 66)
    s.line('fl', 46, transpose(canon, 12), 60)
    s.motif('hn', 50, motif('F3', 'minor') + [('r', 1)], 80, form='stated (horn, the strategy canon)')
    s.mel('ob', 52, m('Db5:2 C5:2 | Bb4:4 | C5:1 Db5:1 Eb5:2 | G4:4'), 76)

    # E 56-63: the tune tutti with its countersubject
    harmony(56, 80)
    for b in range(56, 64):
        kit(b, 80)
    s.mel('vln', 56, transpose(ARENA_THEME, T), 100)
    s.line('tpt', 56, transpose(ARENA_THEME, T), 84)
    s.line('hn', 56, transpose(COUNTER * 2, -12), 80)
    s.hit('crash', 56 * 4, 88)

    fanfare(64)
    return s
