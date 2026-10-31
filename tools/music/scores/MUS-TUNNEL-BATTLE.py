"""MUS-TUNNEL-BATTLE - Old Service Tunnels, combat (BB-S-CAP). Loop, 68 bars 4/4, 138 BPM, D minor, human feel ON.
Battle in the old kingdom under the city: warm core orchestra in a resonant space, not the Capital's grid. A driving string ostinato with a
walking bass that moves by step, crisp snare + timpani, a far harp echoing the strings. Phrase A: the Crossroads motif in full in the
horns; phrase B (contrast): the four zone heads tossed between the sections over a lighter pizzicato drive; then the motif returns
augmented under a violin countermelody - the old harmony fighting back. Open ending, it loops.
"""
from lib import Score, m, motif, motif_head, augment, transpose, p
from lib.zones import DNA_THEME, BUFFET_THEME, DUMP_JIG_HEAD, to_mode
from scores._fork_a import bed, root

DNA_H = transpose(DNA_THEME[:5], 2 - 12)
JIG_H = transpose(DUMP_JIG_HEAD, -2)
BUF_H = to_mode(transpose(BUFFET_THEME[:6], -3), {6: -1, 1: -1})
BEEF_H = to_mode(m('D4:1 A4:.5 G4:.5 F#4:1.5 E4:.5 A4:2'), {6: -1})
A_H = ['Dm', 'Dm', 'Bb', 'C', 'Dm', 'Gm', 'Bb', 'A']
B_H = ['F', 'C', 'Dm', 'Am', 'Bb', 'F', 'Gm', 'A']


def build():
    s = Score('MUS-TUNNEL-BATTLE', bpm=138, bars=68, key='D minor', seed=610)
    s.seat('spic', 'vc', 'cb', 'pad', 'hn', 'tbn', 'tpt', 'vln', 'pizz', 'cl', 'fl', 'timp', 'perc')
    s.channel('echo', 'harp', pan=98, reverb=120, vol=64)
    for bar, nm in ((0, 'intro'), (4, 'A the motif in full'), (20, 'B four voices'), (36, "A' augmented, countermelody"),
                    (52, 'C climax'), (64, 'outro')):
        s.section(bar, nm)
    s.notes.append('Human feel ON (the old kingdom); warm core orchestra; four zone heads in the contrasting phrase.')

    def drive(bar, sym, vel, light=False):
        r = root(s, sym, 'D3')
        cell = [0, 7, 12, 7, 3 if 'm' in sym else 4, 7, 12, 7]
        ch = 'pizz' if light else 'spic'
        for k in range(8):
            s.note(ch, bar * 4 + k * .5, .4, r + cell[k], vel + (8 if k % 4 == 0 else -4))
            if k % 2 == 0:
                s.note('echo', bar * 4 + k * .5 + .75, .4, r + cell[k] + 12, vel - 30)

    def walk(bar, sym, nxt, vel):
        a = root(s, sym, 'E1')
        if a >= p('F2'):
            a -= 12
        b = root(s, nxt, 'E1')
        if b >= p('F2'):
            b -= 12
        step = 1 if b > a else -1
        line = [a, a + 7, a + 12 if a + 12 < p('F3') else a, b - step]
        for k, n in enumerate(line):
            s.note('cb', bar * 4 + k, .8, n, vel + (6 if k == 0 else 0))

    def kit(bar, vel):
        s.drum(bar, [(0, 'bd', 6), (1, 'snare', 0), (2, 'bd', 0), (2.5, 'bd', -10), (3, 'snare', 4), (3.75, 'snare2', -16)], vel)

    def intro(bar):
        spec = ['Dm', 'Dm', 'Bb', 'A']
        for i, sym in enumerate(spec):
            drive(bar + i, sym, 74)
            walk(bar + i, sym, spec[(i + 1) % 4], 72)
            bed(s, bar + i, sym, 60, ch='pad', low='D3', n=4)
            s.brass('tbn', bar + i, sym, 54, low='D3', n=3)
            kit(bar + i, 60)
            if i % 2 == 0:
                s.timp_hit((bar + i) * 4, 'D2', 80)
        s.motif('hn', bar, motif_head('D4', 'minor', rhythm=(1, .5, 2.5)), 82, form='head (horns)')
        s.mel('hn', bar + 1, m('F4:2 E4:2 | D4:4 | C#4:4'), 80)

    intro(0)

    for i in range(16):
        sym = A_H[i % 8]
        drive(4 + i, sym, 76)
        walk(4 + i, sym, A_H[(i + 1) % 8], 74)
        bed(s, 4 + i, sym, 54, ch='pad', low='D3', n=4)
        kit(4 + i, 62)
        if i % 2 == 0:
            s.timp_hit((4 + i) * 4, 'D2' if sym in ('Dm', 'Bb', 'Gm') else 'A1', 80)
    full = motif('D4', 'minor') + m('r:1') + motif('F4', 'major') + m('r:1')
    s.motif('hn', 4, full, 96, form='stated in D then F (horns)')
    s.motif('tpt', 8, motif('A4', 'minor') + m('r:1') + motif('D5', 'minor') + m('r:1'), 92, form='stated higher (trumpets + violins)')
    s.line('vln', 8, motif('A4', 'minor') + m('r:1') + motif('D5', 'minor') + m('r:1'), 82, transpose=12)
    s.mel('hn', 12, m('Bb4:2 A4:1 G4:1 | F4:2 G4:2 | A4:1 Bb4:1 C5:1 D5:1 | E5:4 | D5:2 C5:2 | Bb4:2 A4:2 | G4:2 E4:2 | A4:4'), 94)
    s.hit('crash', 12 * 4, 80, dur=2)

    for i in range(16):
        sym = B_H[i % 8]
        drive(20 + i, sym, 70, light=True)
        walk(20 + i, sym, B_H[(i + 1) % 8], 68)
        bed(s, 20 + i, sym, 50, ch='pad', low='D3', n=4)
        s.drum(20 + i, [(0, 'bd', 0), (2, 'snare', -6), (3.5, 'snare2', -14)], 58)
    s.mel('cl', 20, DNA_H + m('r:1'), 84)
    s.mel('fl', 22, JIG_H + m('r:2'), 82)
    s.mel('tpt', 24, BUF_H + m('r:1'), 84)
    s.mel('hn', 26, BEEF_H + m('r:2'), 88)
    s.mel('vln', 28, m('F5:1 E5:1 D5:1 C5:1 | A4:4 | D5:1 C5:1 Bb4:1 A4:1 | E4:4 | F4:2 A4:2 | D5:4 | Bb4:2 G4:2 | C#5:4'), 86)
    s.motif('cl', 32, motif_head('D5', 'minor', rhythm=(1, .5, .5)) + m('r:2'), 72, form='head (clarinet)', lead=False)

    for i in range(16):
        sym = A_H[i % 8]
        drive(36 + i, sym, 80)
        walk(36 + i, sym, A_H[(i + 1) % 8], 76)
        bed(s, 36 + i, sym, 58, ch='pad', low='D3', n=4)
        kit(36 + i, 66)
        if i % 4 == 0:
            s.timp_hit((36 + i) * 4, 'D2', 86)
    s.motif('tbn', 36, augment(motif('D3', 'minor'), 2) + m('r:2'), 92, form='augmented (trombones + horns)', lead=False)
    s.line('hn', 36, augment(motif('D3', 'minor'), 2) + m('r:2'), 80, transpose=12)
    s.mel('vln', 36, m('A5:1 F5:.5 G5:.5 A5:2 | D6:2 C6:1 Bb5:1 | A5:1 G5:1 F5:1 E5:1 | F5:2 A5:2 '
                       '| G5:1 E5:.5 F5:.5 G5:2 | C6:2 Bb5:1 A5:1 | G5:1 F5:1 E5:1 D5:1 | C#5:4 '
                       '| D5:1 F5:1 A5:1 D6:1 | C6:2 A5:2 | Bb5:1 A5:1 G5:1 F5:1 | E5:4 '
                       '| F5:1 E5:1 D5:1 C5:1 | Bb4:2 D5:2 | E5:2 G5:2 | A5:4'), 92)

    for i in range(12):
        sym = A_H[i % 8]
        drive(52 + i, sym, 86)
        walk(52 + i, sym, A_H[(i + 1) % 8], 82)
        bed(s, 52 + i, sym, 66, ch='pad', low='D3', n=4)
        kit(52 + i, 72)
        s.timp_hit((52 + i) * 4, 'D2' if i % 2 == 0 else 'A1', 92)
        if i % 4 == 0:
            s.hit('crash', (52 + i) * 4, 92, dur=2)
    climax = motif('D5', 'minor') + m('r:1') + motif('F5', 'major') + m('r:1') + motif('Bb4', 'major') + m('r:1')
    s.motif('tpt', 52, climax, 104, form='stated three times (tutti: trumpets, horns, violins 8va)')
    s.line('hn', 52, climax, 94, transpose=-12)
    s.line('vln', 52, climax, 96, transpose=12)
    s.snare_roll(63 * 4, 4, 40, 96)

    intro(64)
    return s
