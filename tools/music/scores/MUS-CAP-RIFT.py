"""MUS-CAP-RIFT - A seam in reality (Capital rifts: Rift Wretches, Shard Swarms, major rift combat). Loop, 80 bars 4/4, 152 BPM, D minor,
quantised. A steady low-string 8th pulse holds the fight readable while the four zone themes glitch over each other, all bent into D:
the D.N.A. waltz in 3-beat cells across the 4/4 bar, the Buffet showtune on muted trumpet, the Dump jig on violin, the Gainlands march in
the horns. Glass-like synth harmonics (bowed glass, crystal), irregular 3+3+2 accents and stutters (rapidly retriggered notes) crack the
surface. The Capital theme on music box and block brass keeps trying to put everything back on the grid; the Crossroads motif breaks in.
"""
from lib import Score, m, motif, motif_head, transpose, p
from lib.capital import QUANTISED
from lib.zones import DNA_THEME, BUFFET_THEME, DUMP_JIG_1, to_mode
from scores._fork_a import cap, bed, root

BEEF = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
         '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1')
D_MIN = {6: -1, 11: -1, 1: -1}               # D major -> D natural minor (F#->F, B->Bb, C#->C)
DNA_D = transpose(DNA_THEME[:20], 2 - 12)    # the waltz in D minor, an octave down (D4...)
BUF_D = to_mode(transpose(BUFFET_THEME[:21], -3), D_MIN)
JIG_D = transpose(DUMP_JIG_1, -2)            # D dorian
BEEF_D = to_mode(transpose(BEEF, 4 - 12), D_MIN)
H = ['Dm', 'Dm', 'Bb', 'A7', 'Dm', 'Gm', 'Bb', 'A7']


def build():
    s = Score('MUS-CAP-RIFT', bpm=152, bars=80, key='D minor', seed=608, human=QUANTISED)
    s.seat('spic', 'vc', 'cb', 'pad', 'cel', 'vln', 'hn', 'brass', 'tpt', 'timp', 'perc', cel={'vol': 100}, tpt={'vol': 92})
    s.channel('glass', 'bowed_glass', pan=30, reverb=115, vol=62)
    s.channel('cryst', 'crystal', pan=98, reverb=110, vol=60)
    s.channel('mtpt', 'muted_tpt', pan=84, reverb=90, vol=86)
    s.channel('mbox', 'music_box', pan=40, reverb=90, vol=96)
    s.detune('glass', 22)
    s.detune('cryst', -18)
    for bar, nm in ((0, 'intro pulse'), (4, 'A D.N.A. waltz cracks'), (20, 'B Buffet + Dump collide'), (36, 'C Gainlands vs the grid'),
                    (52, 'D all four'), (68, 'E dissolve'), (76, 'outro pulse')):
        s.section(bar, nm)
    s.notes.append('All four zone themes (lib/zones.py + the Gainlands theme) bent into D minor, glitched; Capital theme on music box '
                   'and block brass trying to hold the grid.')

    def pulse(bar, sym, vel, accents=True):
        r = root(s, sym, 'D3')
        for k in range(8):
            acc = 12 if k in (0, 3, 6) else -4            # 3+3+2
            s.note('spic', bar * 4 + k * .5, .35, r + (12 if k == 6 else 0), vel + acc)
        b = root(s, sym, 'E1')
        if b >= p('F2'):
            b -= 12
        for k in (0, 1.5, 3):
            s.note('cb', bar * 4 + k, .5, b, vel + 4)
        if accents:
            s.drum(bar, [(0, 'bd', 8), (1.5, 'bd', 0), (3, 'bd', 0), (2, 'snare', -2)], vel - 6)

    def stutter(ch, beat, pitch, n, vel, step=.125):
        for k in range(n):
            s.note(ch, beat + k * step, step * .8, p(pitch), vel - k * 3)

    def shards(bar, vel):
        s.note('glass', bar * 4, 3.98, p('A5'), vel)
        s.note('glass', bar * 4, 3.98, p('Eb6'), vel - 8)       # a tritone ghost
        stutter('cryst', bar * 4 + 2.5, 'D6' if bar % 2 else 'Ab6', 6, vel + 10)

    def intro(bar):
        for i, sym in enumerate(['Dm', 'Dm', 'Bb', 'A7']):
            pulse(bar + i, sym, 76)
            bed(s, bar + i, sym, 56, ch='pad', low='D3', n=4)
            shards(bar + i, 52)
            s.timp_hit((bar + i) * 4, 'D2' if i < 3 else 'A1', 76)
        s.motif('hn', bar, motif_head('D4', 'minor', rhythm=(1, .5, 2.5)), 80, form='head (horns, breaking in)')
        s.mel('hn', bar + 1, m('G4:2 F4:2'), 78)
        s.mel('hn', bar + 2, m('F4:2 E4:2 | A3:4'), 78)

    intro(0)

    # A 4-19: the D.N.A. waltz theme in 3-beat cells across the bar (celesta), cracking; the music box tries the Capital theme at 12
    for i in range(16):
        sym = H[i % 8]
        pulse(4 + i, sym, 76)
        bed(s, 4 + i, sym, 50, ch='pad', low='D3', n=4)
        if i % 2 == 0:
            shards(4 + i, 48)
    s.mel('cel', 4, DNA_D, 92, transpose=12)
    s.line('vc', 4, DNA_D, 60, transpose=-12)
    for b in (6, 9, 11):
        stutter('cel', b * 4 + 3, 'Eb6', 8, 80)
    s.mel('cel', 10, DNA_D[:10], 88, transpose=12)
    s.mel('mbox', 13, cap(0, 4, 2, minor=True), 86)
    s.mel('cel', 17, m('D6:4'), 80)
    s.mel('mbox', 18, cap(4, 6, 2, minor=True), 84)

    # B 20-35: the Buffet showtune on muted trumpet, then the Dump jig on violin over it; glitches between
    for i in range(16):
        sym = H[i % 8]
        pulse(20 + i, sym, 78)
        bed(s, 20 + i, sym, 52, ch='pad', low='D3', n=4)
        shards(20 + i, 46 + (i % 4) * 3)
    s.mel('mtpt', 20, BUF_D, 94)
    s.mel('mtpt', 24, BUF_D[:9], 90)
    s.mel('vln', 26, JIG_D[:24], 90)
    s.mel('mtpt', 28, BUF_D[:9], 86, beat=1)
    s.mel('vln', 30, JIG_D, 92)
    for b in (23, 27, 33):
        stutter('mtpt', b * 4 + 2, 'A4', 8, 82)

    # C 36-51: the Gainlands march in the horns against the Capital theme in block brass + music box; the motif breaks in at 44
    for i in range(16):
        sym = H[i % 8]
        pulse(36 + i, sym, 80)
        bed(s, 36 + i, sym, 56, ch='pad', low='D3', n=4)
        if i % 2:
            shards(36 + i, 50)
        if i % 4 == 0:
            s.timp_hit((36 + i) * 4, 'D2', 84)
    s.mel('hn', 36, BEEF_D, 96)
    s.line('brass', 36, cap(0, 8, 2 - 12, minor=True), 72)
    s.line('mbox', 40, cap(0, 4, 2, minor=True), 70)
    s.motif('tpt', 44, motif('D5', 'minor') + m('r:1') + motif('F5', 'major') + m('r:1'), 98, form='stated twice (trumpets, breaks in)')
    s.mel('hn', 48, BEEF_D[:10] + m('r:.5 A4:4'), 90)

    # D 52-67: all four at once, the grid failing
    for i in range(16):
        sym = H[i % 8]
        pulse(52 + i, sym, 86)
        bed(s, 52 + i, sym, 62, ch='pad', low='D3', n=4)
        shards(52 + i, 56)
        if i % 4 == 0:
            s.hit('crash', (52 + i) * 4, 88, dur=2)
            s.timp_hit((52 + i) * 4, 'D2', 92)
    s.mel('tpt', 52, cap(0, 8, 2 - 12, minor=True), 98)
    s.line('cel', 52, DNA_D, 76, transpose=12)
    s.line('vln', 54, JIG_D[:24], 80)
    s.line('mtpt', 56, BUF_D, 82)
    s.line('hn', 60, BEEF_D, 88)
    s.motif('vln', 60, motif('D5', 'minor') + m('r:1') + motif('A5', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1'), 98,
            form='stated + sequenced (violins, over the collision)')
    s.mel('tpt', 64, cap(12, 16, 2 - 12, minor=True), 96)
    for b in (55, 59, 63, 66):
        stutter('cryst', b * 4, 'D6', 12, 92, step=1 / 12)

    # E 68-75: dissolve - pulse and glass; the motif head in the cello; the Capital head, broken, on the music box
    for i in range(8):
        sym = ['Dm', 'Bb', 'Gm', 'A7'][i % 4]
        pulse(68 + i, sym, 70, accents=i >= 4)
        bed(s, 68 + i, sym, 52, ch='pad', low='D3', n=4)
        shards(68 + i, 54)
    s.motif('vc', 68, motif('D3', 'minor') + m('r:1'), 82, form='stated (cello, alone in the glass)')
    s.mel('vc', 70, m('F3:4 | E3:4'), 76)
    s.mel('mbox', 72, cap(0, 2, 2, minor=True) + m('r:2') + cap(0, 1, 2, minor=True) + m('r:4'), 82)

    intro(76)
    s.snare_roll(79 * 4 + 2, 2, 40, 80)
    return s
