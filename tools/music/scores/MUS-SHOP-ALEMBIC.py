"""MUS-SHOP-ALEMBIC - Essences together (Crosspath, VS-ALEMBIC, the alchemist). Loop, 24 bars 4/4, 76 BPM, E minor (75.8 s).
Calm mystical blending: two contrasting voices - an airy flute and an earthy clarinet - converse over rolling piano and a warm cello, each
with its own little phrase, until they meet and sing the Crossroads motif together in thirds (two essences, one card). A tiny glass synth
layer and harp shimmer suggest alchemy. Curious, nurturing, never frantic.
"""
from lib import Score, m, motif, p
from scores._fork_a import bed, each, root, gliss

H = ['Em', 'Cmaj7', 'Am7', 'B7sus4 B7', 'Em', 'Cmaj7', 'Am7 D', 'Gmaj7', 'Cmaj7', 'Am7', 'F#m7b5', 'B7', 'Em', 'Cmaj7', 'Am7', 'B7sus4 B7',
     'Em', 'G', 'Cmaj7', 'Am7', 'Em', 'Cmaj7', 'Am7', 'B7']


def build():
    s = Score('MUS-SHOP-ALEMBIC', bpm=76, bars=24, key='E minor', seed=716)
    s.seat('piano', 'vc', 'cb', 'fl', 'cl', 'harp', 'pad')
    s.channel('glass', 'bowed_glass', pan=64, reverb=115, vol=44)
    for bar, nm in ((0, 'A the flute speaks'), (4, 'the clarinet answers'), (8, 'B conversation'), (16, 'C blended: the motif in thirds'),
                    (20, 'A again')):
        s.section(bar, nm)
    s.notes.append('Two voices (flute = air, clarinet = earth) converse, then blend in thirds on the Crossroads motif; glass layer.')

    def roll(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'E2')
            tn = s.chord_tones(sym, r + 12, 6)
            seq = [r, tn[1], tn[2], tn[3], tn[4], tn[3], tn[2], tn[1]]
            n = int(d * 2)
            for k in range(n):
                s.note('piano', t + k * .5, 1.2, seq[k % 8], vel - (0 if k == 0 else 10))
            s.note('vc', t, d - .02, r + 12 if r < p('C3') else r, vel - 8)
            s.note('cb', t, d - .02, r if r < p('F2') else r - 12, vel - 14)

    for i, spec in enumerate(H):
        roll(i, spec, 54)
        bed(s, i, spec, 30, ch='pad', low='B3', n=3)
        if i % 4 == 0:
            s.note('glass', i * 4, 7.98, p('B5'), 40)
    s.mel('fl', 0, m('B5:1.5 A5:.5 G5:1 E5:1 | G5:2 F#5:1 E5:1 | C6:1.5 B5:.5 A5:1 G5:1 | F#5:4'), 78)
    s.mel('cl', 4, m('E4:1 G4:1 B4:2 | C5:1 B4:.5 A4:.5 G4:2 | A4:1 B4:1 C5:1 D5:1 | B4:4'), 80)
    s.mel('fl', 8, m('G5:1 A5:1 B5:2 | r:2 E6:1 D6:1 | C6:2 A5:2 | r:4'), 74)
    s.mel('cl', 9, m('r:2 E4:.5 F#4:.5 G4:1 | B4:2 r:2 | r:2 A4:1 C5:1 | D#5:2 F#5:2'), 76)
    s.mel('fl', 12, m('G5:1 F#5:1 E5:2 | E5:1 D5:1 C5:2 | C5:1 B4:1 A4:2 | B4:4'), 74)
    s.line('cl', 12, m('E4:4 | A4:4 | A4:2 F#4:2 | D#4:4'), 62)
    gliss(s, 'harp', 15, 'B7', 46, low='B3', beats=1.5, beat=2.5)
    mot = motif('E5', 'minor') + m('r:1')
    s.motif('fl', 16, mot, 82, form='stated (flute + clarinet in thirds below: blended)')
    s.line('cl', 16, motif('E5', 'minor', degrees=[-2, 2, 1, 0, -1, 2]) + m('r:1'), 70)
    s.motif('cl', 18, motif('G4', 'major') + m('r:1'), 78, form='stated in G (clarinet, flute a sixth above)')
    s.line('fl', 18, motif('G4', 'major', degrees=[5, 9, 8, 7, 6, 9]) + m('r:1'), 64)
    s.harp(17, 'G', 40, density=8)
    s.harp(19, 'Am7', 40, density=8)
    s.mel('fl', 20, m('B5:1.5 A5:.5 G5:1 E5:1 | G5:2 F#5:1 E5:1 | C6:1.5 B5:.5 A5:1 G5:1 | F#5:2 D#5:1 B4:1'), 72)
    s.line('cl', 21, m('r:2 E4:1 G4:1 | A4:2 C5:2 | B4:4'), 60)
    return s
