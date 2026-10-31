"""MUS-CASTLE-BATTLE - The mirror parquet (Primm's Castle, BB-PC ordinary and elite battles). Loop, 68 bars 4/4, 140 BPM, G minor,
quantised. A driven Baroque gavotte: low strings in running 8ths, two harpsichords seated hard left and right, violins and violas
answering each other across the stereo field like reflections, precise snare and timpani, a choir. Dissonant synth shadows (a detuned glass
pad and metal pad) hang behind. The Primm motif (in G minor) is mirrored - inverted - by the other side of the room; in the resistance
phrase the hero's Crossroads motif plays against its own mirror image, then against Primm's line in the climax. No organ.
"""
from lib import Score, m, motif, motif_head, transpose, p, PRIMM_HEAD, PRIMM_ANSWER
from lib.capital import QUANTISED, rudiment
from lib.zones import to_mode
from scores._fork_a import cap, prog, bed, each, root

PRIMM_G = to_mode(transpose(PRIMM_HEAD + PRIMM_ANSWER, -5), {11: -1, 4: -1, 9: 0})     # G Bb D G F# Eb D A | G C Eb G A G F# D
PRIMM_G = [(n, .5) for n, _ in PRIMM_G]


def mirror(mel, axis):
    a = p(axis)
    return [(n if n == 'r' else 2 * a - p(n), d) for n, d in mel]


H = ['Gm', 'Cm', 'D7', 'Gm', 'Eb', 'Cm', 'D7', 'Gm']
PROG_GM = prog(-5, minor=True)


def build():
    s = Score('MUS-CASTLE-BATTLE', bpm=140, bars=68, key='G minor', seed=613, human=QUANTISED)
    s.seat('spic', 'vc', 'cb', 'pad', 'vln', 'vla', 'choir', 'hn', 'tbn', 'tpt', 'timp', 'perc', vln={'pan': 20}, vla={'pan': 108, 'vol': 90})
    s.channel('hpL', 'harpsichord', pan=10, reverb=80, vol=80)
    s.channel('hpR', 'harpsichord', pan=118, reverb=80, vol=80)
    s.channel('glass', 'bowed_glass', pan=40, reverb=115, vol=52)
    s.channel('metal', 'metal_pad', pan=90, reverb=115, vol=44)
    s.detune('glass', -20)
    s.detune('metal', 16)
    for bar, nm in ((0, 'intro gavotte'), (4, 'A Primm and his reflection'), (20, 'B the Capital gavotte'),
                    (36, 'C resistance: the motif vs its mirror'), (48, 'D climax'), (64, 'outro gavotte')):
        s.section(bar, nm)
    s.notes.append('Primm motif in G minor answered by its inversion across the stereo field; Capital theme in G minor; '
                   'hero motif vs inverted motif; no organ; quantised.')

    def run(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'G2')
            cell = [0, 12, 7, 12, 3 if 'm' in sym else 4, 12, 7, 12]
            for k in range(int(d * 2)):
                s.note('spic', t + k * .5, .4, r + cell[k % 8] + 12, vel + (8 if k % 4 == 0 else -4))
            b = root(s, sym, 'E1')
            if b >= p('F2'):
                b -= 12
            for k in range(int(d)):
                s.note('cb', t + k, .5, b if k % 2 == 0 else b + 12 if b + 12 < p('C3') else b, vel)
            tn = s.chord_tones(sym, p('G4'), 4)
            s.note('hpL', t, .4, tn[0], vel - 8)
            s.note('hpR', t + .5, .4, tn[1], vel - 8)
            s.note('hpL', t + 1, .4, tn[2], vel - 10)
            s.note('hpR', t + 1.5, .4, tn[1], vel - 10)
        s.drum(bar, [(0, 'bd', 4), (2, 'snare', -4), (3, 'snare', -10), (3.5, 'snare2', -16)], vel - 8)

    def shadow(bar, vel):
        s.note('glass', bar * 4, 3.98, p('Ab4'), vel)
        s.note('metal', bar * 4, 3.98, p('C#5'), vel - 8)

    def intro(bar):
        spec = ['Gm', 'Gm', 'Cm D7', 'D7']
        for i, sy in enumerate(spec):
            run(bar + i, sy, 76)
            bed(s, bar + i, sy, 58, ch='pad', low='D3', n=4)
            shadow(bar + i, 46)
            if i % 2 == 0:
                s.timp_hit((bar + i) * 4, 'G2', 80)
        s.mel('vln', bar, PRIMM_G[:8] + m('r:0'), 88)
        s.mel('vla', bar + 1, mirror(PRIMM_G[:8], 'G4'), 84)
        s.motif('hn', bar + 2, motif_head('G3', 'minor', rhythm=(1, .5, 2.5)) + m('r:4'), 74, form='head (horns, under the dance)', lead=False)
        s.mel('vln', bar + 2, m('r:2 D5:.5 Eb5:.5 F#5:.5 G5:.5 | A5:2 F#5:2'), 86)

    intro(0)

    for i in range(16):
        sy = H[i % 8]
        run(4 + i, sy, 76)
        bed(s, 4 + i, sy, 52, ch='pad', low='D3', n=4)
        if i % 2:
            shadow(4 + i, 42)
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, 'G2', 82)
    for k in range(4):
        b = 4 + 4 * k
        s.mel('vln', b, PRIMM_G, 92)                               # Primm, left
        s.mel('vla', b + 2, mirror(PRIMM_G, 'G4'), 90)             # his reflection, right
    s.motif('choir', 12, motif('G3', 'minor') + m('r:1'), 56, form='stated (choir, low, behind the mirror)', lead=False)

    for i in range(16):
        sy = PROG_GM[i]
        run(20 + i, sy, 80)
        bed(s, 20 + i, sy, 56, ch='choir', low='D4', n=3)
        bed(s, 20 + i, sy, 54, ch='pad', low='D3', n=4)
        if i % 4 == 0:
            s.timp_hit((20 + i) * 4, 'G2', 86)
            s.hit('crash', (20 + i) * 4, 76, dur=2)
    s.mel('vln', 20, cap(0, 16, -5, minor=True), 98)
    s.line('vla', 20, mirror(cap(0, 16, -5, minor=True), 'G5'), 70, transpose=-12)

    # C 36-47: resistance - the hero's motif against its own mirror image
    for i in range(12):
        sy = ['Gm', 'Eb', 'Bb', 'F', 'Gm', 'Eb', 'Cm', 'D7', 'Gm', 'Eb', 'Cm', 'D7'][i]
        run(36 + i, sy, 78)
        bed(s, 36 + i, sy, 58, ch='pad', low='D3', n=4)
        shadow(36 + i, 48)
    hero = motif('G4', 'minor') + m('r:1') + motif('Bb4', 'major') + m('r:1')
    s.motif('hn', 36, hero, 100, form='stated (horns, left)')
    s.motif('tbn', 36, motif('G3', 'minor', inverted=True) + m('r:1') + motif('Bb3', 'major', inverted=True) + m('r:1'), 84,
            form='inverted - the mirror (trombones, right)', lead=False)
    s.motif('vln', 40, motif('D5', 'minor') + m('r:1'), 94, form='stated (violins)')
    s.motif('vla', 40, motif('D5', 'minor', inverted=True) + m('r:1'), 84, form='inverted (violas, the reflection)', lead=False)
    s.mel('hn', 42, m('Eb5:2 D5:2 | C5:2 Bb4:2 | A4:2 C5:2 | D5:4 | G4:2 A4:2 | Bb4:4'), 96)
    s.snare_roll(47 * 4, 4, 40, 100)

    for i in range(16):
        sy = H[i % 8]
        run(48 + i, sy, 86)
        bed(s, 48 + i, sy, 62, ch='pad', low='D3', n=4)
        bed(s, 48 + i, sy, 58, ch='choir', low='D4', n=3)
        if i % 4 == 0:
            s.hit('crash', (48 + i) * 4, 90, dur=2)
            s.timp_hit((48 + i) * 4, 'G2', 92)
    climax = motif('G5', 'minor') + m('r:1') + motif('D5', 'minor') + m('r:1')
    s.motif('vln', 48, climax + climax, 102, form='stated four times (violins + trumpets, against Primm)')
    s.line('tpt', 48, climax + climax, 86, transpose=-12)
    s.line('tbn', 48, [(n, 1) for n, _ in PRIMM_G], 82, transpose=-12)
    s.line('tbn', 56, [(n, 1) for n, _ in mirror(PRIMM_G, 'G4')], 82, transpose=-12)

    intro(64)
    s.snare_roll(67 * 4 + 2, 2, 40, 84)
    return s
