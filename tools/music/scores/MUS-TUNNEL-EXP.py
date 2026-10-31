"""MUS-TUNNEL-EXP - Old Service Tunnels, exploration (S-CAP). Loop, 48 bars 4/4, 86 BPM, D Dorian, human feel ON.
The old kingdom under the city: warmer, echoing, the Crossroads motif in full. A low string drone and plucked echoes (every harp/piano note
answered softly a dotted quarter later, as if by the tunnel walls). Faint heads of the four zone themes answer one another (D.N.A. on
clarinet, the Dump jig on flute, the Buffet welcome on muted horn, the Gainlands call on horn), then find a shared direction: the motif
stated in the piano, sung by cello and violins, and finally a warm tutti that leaves the question open. The Capital's grid is not here.
"""
from lib import Score, m, motif, augment, transpose, p
from lib.zones import DNA_THEME, BUFFET_THEME, DUMP_JIG_HEAD, to_mode
from scores._fork_a import bed, each, root

DNA_H = transpose(DNA_THEME[:5], 2 - 12)
JIG_H = transpose(DUMP_JIG_HEAD, -2)
BUF_H = to_mode(transpose(BUFFET_THEME[:6], -3), {6: -1, 1: -1})
BEEF_H = to_mode(m('D4:1 A4:.5 G4:.5 F#4:1.5 E4:.5 A4:2'), {6: -1})
H = ['Dm', 'Dm', 'C', 'G', 'Dm', 'F', 'C', 'Am']


def build():
    s = Score('MUS-TUNNEL-EXP', bpm=86, bars=48, key='D dorian', seed=609)
    s.seat('pad', 'vc', 'cb', 'harp', 'piano', 'cl', 'fl', 'hn', 'vln', 'timp')
    s.channel('echo', 'harp', pan=96, reverb=120, vol=60)
    s.channel('mhn', 'muted_tpt', pan=60, reverb=110, vol=62)
    for bar, nm in ((0, 'drone'), (4, 'A four voices answer'), (16, 'B a shared direction'), (32, 'C the old harmony'), (44, 'drone')):
        s.section(bar, nm)
    s.notes.append('Human feel ON; echoes = each pluck repeated softer a dotted quarter later on a far harp; Crossroads motif in full.')

    def pluck(ch, bar, mel, vel, beat=0.0):
        s.line(ch, bar, mel, vel, beat=beat)
        s.line('echo', bar, mel, vel - 26, beat=beat + .75)

    def drone(bar, sym, vel):
        r = root(s, sym, 'D2')
        s.note('cb', bar * 4, 3.98, p('D2'), vel)
        s.note('vc', bar * 4, 3.98, r + 12 if r < p('A2') else r, vel - 10)

    def plinks(bar, sym, vel):
        tn = s.chord_tones(sym, p('A4'), 4)
        for k, b in enumerate((0, 1.5, 3)):
            s.note('harp', bar * 4 + b, 1.5, tn[(bar + k) % 4], vel)
            s.note('echo', bar * 4 + b + .75, 1.5, tn[(bar + k) % 4], vel - 24)

    def intro(bar):
        for i, sym in enumerate(['Dm', 'Dm', 'C', 'G']):
            drone(bar + i, sym, 52)
            plinks(bar + i, sym, 56)
            bed(s, bar + i, sym, 36, ch='pad', low='A3', n=3)
        s.mel('vc', bar, m('A3:4 | F3:2 G3:2 | E3:4 | G3:4'), 62)

    intro(0)

    for i in range(12):
        sym = H[i % 8]
        drone(4 + i, sym, 54)
        bed(s, 4 + i, sym, 40, ch='pad', low='A3', n=3)
        if i % 2:
            plinks(4 + i, sym, 50)
    s.motif('piano', 4, motif('D4', 'dorian') + m('r:1'), 76, form='stated (piano, with tunnel echo)')
    s.line('echo', 4, motif('D4', 'dorian'), 50, beat=.75)
    s.mel('cl', 6, DNA_H + m('r:1'), 70)                       # D.N.A.
    s.mel('fl', 8, JIG_H + m('r:2'), 66)                        # the Dump
    s.mel('mhn', 10, BUF_H + m('r:1'), 72)                      # the Buffet
    s.mel('hn', 12, BEEF_H + m('r:2'), 74)                      # the Gainlands
    s.motif('piano', 14, motif('F4', 'major') + m('r:1'), 72, form='stated (piano, the voices listen)')

    for i in range(16):
        sym = H[i % 8]
        drone(16 + i, sym, 58)
        bed(s, 16 + i, sym, 48, ch='pad', low='A3', n=4)
        s.harp(16 + i, sym, 50, density=8)
    s.motif('vc', 16, motif('D3', 'dorian') + m('r:1') + motif('F3', 'major') + m('r:1'), 82, form='stated twice (cello)')
    s.motif('vln', 20, motif('D5', 'dorian') + m('r:1') + motif('A4', 'minor') + m('r:1'), 84, form='stated twice (violins, cello below)')
    s.line('vc', 20, m('D3:4 | C3:4 | Bb2:4 | A2:4'), 60)
    s.motif('hn', 24, augment(motif('D3', 'dorian'), 2) + m('r:2'), 74, form='augmented chorale (horns)', lead=False)
    s.mel('cl', 24, DNA_H + m('r:1') + JIG_H + m('r:2'), 72)
    s.mel('fl', 28, BUF_H + m('r:1') + m('A5:2 G5:2 | F5:4'), 70)

    for i in range(12):
        sym = H[i % 8]
        drone(32 + i, sym, 66)
        bed(s, 32 + i, sym, 58, ch='pad', low='A3', n=4)
        s.harp(32 + i, sym, 56, density=16 if i % 2 else 8)
    s.swell('pad', 32, 8, 80, 118)
    s.swell('pad', 40, 4, 118, 82)
    s.timp_hit(32 * 4, 'D2', 70)
    s.timp_roll(39 * 4, 4, 'D2', 40, 78)
    tune = motif('D5', 'dorian') + m('r:1') + motif('F5', 'major') + m('r:1') + motif('A4', 'minor') + m('r:1')
    s.motif('vln', 32, tune, 92, form='stated three times (violins + horns, piano canon)')
    s.line('hn', 32, tune, 74, transpose=-12)
    s.line('piano', 33, tune[:6], 66, transpose=-12)
    s.mel('vln', 38, m('G5:2 F5:2 | E5:4 | D5:2 E5:2 | A4:4 | E5:4 | r:4'), 82)
    s.line('echo', 40, m('A4:4 | E4:4'), 50)

    intro(44)
    s.swell('pad', 46, 2, 100, 127)
    s.timp_roll(47 * 4 + 1, 3, 'D2', 30, 72)
    return s
