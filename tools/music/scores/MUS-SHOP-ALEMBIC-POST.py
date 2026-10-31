"""MUS-SHOP-ALEMBIC-POST - Three essences, new possibilities (Crosspath postgame, VS-ALEMBIC after the unlock). Loop, 28 bars 4/4, 80 BPM,
E Lydian (84.0 s). The alchemist's arrangement grown: three and then four distinct voices (flute, oboe, clarinet, cello) in flowing
counterpoint over rolling piano and harp, more colours in the glass layer (bowed glass + crystal), and the raised fourth of Lydian for
the new magic. A warmer, completed royal phrase: the Crossroads motif in four-part harmony with a soft horn, and once, quietly, the first
four notes of the lullaby on the horn. Gentle enough for crafting.
"""
from lib import Score, m, motif, p, LULLABY_HEAD, transpose
from lib.zones import to_mode
from scores._fork_a import bed, each, root, gliss

H = ['E', 'F#/E', 'C#m7', 'Amaj7', 'E', 'F#', 'G#m7', 'B7sus4 B7', 'Amaj7', 'F#/A#', 'G#m7', 'C#m7', 'E', 'F#/E', 'Amaj7', 'B7sus4 B7',
     'E', 'F#/E', 'C#m7', 'Amaj7', 'G#m7', 'F#', 'B7sus4 B7', 'B7', 'E', 'F#/E', 'Amaj7', 'B7']


def build():
    s = Score('MUS-SHOP-ALEMBIC-POST', bpm=80, bars=28, key='E lydian', seed=717)
    s.seat('piano', 'vc', 'cb', 'fl', 'ob', 'cl', 'harp', 'pad', 'hn')
    s.channel('glass', 'bowed_glass', pan=40, reverb=115, vol=44)
    s.channel('cryst', 'crystal', pan=96, reverb=115, vol=46)
    for bar, nm in ((0, 'A three voices'), (8, 'B four voices in counterpoint'), (16, 'C the royal phrase'), (24, 'A again')):
        s.section(bar, nm)
    s.notes.append('E Lydian (F#/E = the raised fourth); three then four voices; motif in four-part harmony; lullaby head (4 notes) once, '
                   'quietly, on horn at bar 21 (the rule allows at most its first four notes).')

    def roll(bar, spec, vel):
        for t, d, sym in each(s, bar, spec):
            r = root(s, sym, 'E2')
            tn = s.chord_tones(sym, r + 12, 6)
            seq = [r, tn[1], tn[2], tn[3], tn[4], tn[3], tn[2], tn[1]]
            for k in range(int(d * 2)):
                s.note('piano', t + k * .5, 1.2, seq[k % 8], vel - (0 if k == 0 else 10))
            s.note('cb', t, d - .02, r if r < p('F2') else r - 12, vel - 14)

    for i, spec in enumerate(H):
        roll(i, spec, 52)
        bed(s, i, spec, 30, ch='pad', low='B3', n=3)
        if i % 4 == 0:
            s.note('glass', i * 4, 7.98, p('A#5'), 38)
        if i % 4 == 2:
            s.note('cryst', i * 4 + 2, 2, p('F#6'), 44)
    s.mel('fl', 0, m('B5:1.5 A#5:.5 G#5:1 E5:1 | F#5:2 A#5:2 | G#5:1.5 F#5:.5 E5:1 C#5:1 | E5:4 | B5:1 C#6:1 D#6:1 E6:1 | C#6:2 A#5:2 | B5:1 G#5:1 F#5:1 D#5:1 | F#5:4'), 78)
    s.line('ob', 2, m('E5:2 D#5:2 | C#5:4 | r:2 E5:1 F#5:1 | G#5:2 F#5:2 | E5:4 | D#5:2 B4:2'), 62)
    s.line('cl', 4, m('G#4:4 | A#4:4 | B4:2 G#4:2 | A4:2 B4:2'), 58)
    gliss(s, 'harp', 7, 'B7', 44, low='B3', beats=1.5, beat=2.5)
    s.mel('ob', 8, m('C#5:1 E5:1 A5:2 | A#5:1 G#5:1 F#5:2 | G#5:1 B5:1 D#6:1.5 C#6:.5 | C#6:4 | B5:1 G#5:1 E5:2 | F#5:1 A#5:1 C#6:2 | C#6:1 B5:1 A5:1 G#5:1 | F#5:4'), 78)
    s.line('fl', 9, m('r:2 E6:1 C#6:1 | D#6:2 A#5:2 | B5:4 | r:2 G#5:1 A5:1 | B5:2 G#5:2 | A#5:4 | E5:2 F#5:2'), 60)
    s.line('cl', 8, m('A4:2 C#5:2 | C#5:2 A#4:2 | B4:4 | G#4:4 | G#4:2 B4:2 | A#4:4 | A4:4 | A#4:4'), 58)
    s.line('vc', 8, m('A3:4 | A#3:4 | G#3:4 | C#3:4 | E3:4 | F#3:4 | A3:4 | B3:4'), 62)
    s.harp(12, 'E', 40, density=8)
    s.harp(14, 'Amaj7', 40, density=8)
    mot = motif('E5', 'lydian') + m('r:1')
    s.motif('fl', 16, mot + motif('G#5', 'minor', degrees=[0, 4, 3, 2, 1, 4]) + m('r:1'), 80, form='stated in four-part harmony (flute lead, oboe, clarinet, horn)')
    s.line('ob', 16, motif('E5', 'lydian', degrees=[-2, 2, 1, 0, -1, 2]) + m('r:1'), 64)
    s.line('cl', 16, motif('E4', 'lydian', degrees=[2, 6, 5, 4, 3, 6]) + m('r:1'), 62)
    s.line('hn', 16, m('E3:4 | D#3:2 B2:2 | C#3:4 | F#3:4'), 56)
    s.line('hn', 21, to_mode(transpose(LULLABY_HEAD[:4], 2 - 12), {7: 1}), 52)   # the lullaby's first four notes (in major), once, quietly
    s.mel('ob', 20, m('G#5:2 F#5:1 E5:1 | F#5:2 A#5:2 | B5:2 A#5:1 F#5:1 | B5:4'), 76)
    s.mel('fl', 24, m('B5:1.5 A#5:.5 G#5:1 E5:1 | F#5:2 A#5:2 | G#5:1 F#5:1 E5:1 C#5:1 | D#5:2 F#5:1 A#5:1'), 74)
    s.line('cl', 25, m('r:2 E4:1 F#4:1 | A4:2 C#5:2 | B4:4'), 58)
    return s
