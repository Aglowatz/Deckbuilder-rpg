"""MUS-DECK - A plan in the cards. 36 bars 4/4, 72 BPM, F major (the town's relative major).
Thoughtful possibility for long planning screens: warm suspended chords on the piano, a soft cello, a quiet pad and a few pizzicato
notes. The piano asks the Crossroads motif as a question now and then (it ends open, on the fifth); the cello answers with the town's
B tune slowed down. Low busyness throughout so reading is comfortable.
"""
from lib import Score, m, motif, motif_head, motif_tail

A_H = ['Fadd9', 'Bbmaj7', 'Gm7', 'C7sus4', 'Fadd9', 'Dm7', 'Bbmaj9', 'C7sus4']
B_H = ['Bbmaj7', 'Am7', 'Gm7', 'C7sus4', 'Bbmaj7', 'Am7', 'Dm7', 'Gm7 C7sus4']
C_H = ['Dm7', 'Bbmaj7', 'Fadd9', 'C7sus4', 'Dm7', 'Bbmaj7', 'Gm7', 'Asus4']
BROKEN = [(0, 0, 2.2, 4), (1, 2, 1.9, -8), (2, 1, 1.9, -6), (3, 3, 1.1, -10)]


def build():
    s = Score('MUS-DECK', bpm=72, bars=36, key='F major', seed=707)
    s.seat('piano', 'pizz', 'vc', 'cb', 'pad', piano={'vol': 80}, pizz={'vol': 70})
    s.channel('pmel', 'piano', pan=70, reverb=85, vol=90)
    s.channel('cel', 'celesta', pan=44, reverb=95, vol=54)
    for bar, nm in ((0, 'A chords'), (8, 'B question'), (16, 'C cello'), (24, "A' chords"), (32, 'A again')):
        s.section(bar, nm)

    def chords(bar, spec, vel, pad_v=40, pizz=False):
        for off, beats, sym in s.parts(spec):
            s.figure('piano', bar, sym, [x for x in BROKEN if off <= x[0] < off + beats], vel, low='F3')
            s.pad('pad', bar, sym, pad_v, beats=beats, beat=off, low='A3')
            s.bass_at(bar * 4 + off, beats, sym, 46, chs=('cb', None))
        if pizz:
            from lib import p
            s.note('pizz', bar * 4 + 2.5, .4, p(s.voicing(spec.split()[0])[1][-1]) + 12, 50)

    def a_section(bar, vel):
        for i, spec in enumerate(A_H):
            chords(bar + i, spec, vel, pizz=(i % 4 == 3))
        s.swell('pad', bar, 8, 70, 88, 'arch')

    # A 0-7: chords and space; a fragment of the question
    a_section(0, 54)
    s.motif('pmel', 2, motif_head('F5', 'major', rhythm=(1, .5, 2.5)), 58, form='head (piano), a question')
    s.line('pmel', 6, m('A5:1 G5:1 F5:1 C5:1 | D5:4'), 52)

    # B 8-15: the piano asks the whole motif, the cello answers
    for i, spec in enumerate(B_H):
        chords(8 + i, spec, 52, pizz=(i % 2 == 1))
    s.motif('pmel', 8, motif('F5', 'major') + m('r:1'), 68, form='stated (piano), open')
    s.mel('vc', 10, m('D4:1.5 C4:.5 Bb3:1 A3:1 | G3:3 r:1'), 72)
    s.motif('pmel', 12, motif('D5', 'minor') + m('r:1'), 64, form='stated in D minor (piano), open')
    s.mel('vc', 14, m('F3:1.5 G3:.5 A3:1 C4:1 | Bb3:2 C4:2'), 70)
    s.swell('vc', 8, 8, 80, 100, 'arch')

    # C 16-23: the cello sings the town's B tune slowly over pizzicato and soft piano
    # (Music Pass 2: flattened ~3 LU so long reading stays even - cello, its swell, the pizzicato and the piano all a step softer)
    for i, spec in enumerate(C_H):
        bar = 16 + i
        for off, beats, sym in s.parts(spec):
            s.figure('piano', bar, sym, [(0, 0, 3.8, 0), (2, 2, 1.9, -8)], 42, low='F3')
            s.pad('pad', bar, sym, 44, beats=beats, beat=off, low='A3')
            s.bass_at(bar * 4 + off, beats, sym, 48, chs=('cb', None))
        s.figure('pizz', bar, spec, [(0, 'b', .4, 4), (1.5, 1, .4, -6), (3, 2, .4, -8)], 48, low='F3')
    s.mel('vc', 16, m('F3:2 A3:2 | D4:4 | C4:2 A3:2 | G3:4 | F3:2 A3:2 | D4:3 E4:1 | D4:2 Bb3:2 | A3:4'), 66)
    s.motif('cel', 19, motif_tail('F5', 'major', rhythm=(1.5, .5, 2)), 50, form='tail (celesta, a glint)', lead=False)
    s.swell('vc', 16, 8, 70, 84, 'arch')

    # A' 24-31: chords again, the piano's question higher, cello under
    for i, spec in enumerate(A_H):
        chords(24 + i, spec, 56, pad_v=46, pizz=(i % 4 == 3))
    s.motif('pmel', 24, motif('C5', 'major') + m('r:1'), 62, form='stated on C (piano), open')
    s.line('vc', 24, m('F3:4 | D3:4 | G3:4 | C3:4 | F3:4 | D3:4 | Bb2:4 | C3:4'), 58, legato=1.0, shape=False)
    s.line('pmel', 28, m('A5:1 G5:1 F5:1 C5:1 | D5:2 F5:2 | E5:4 | r:4'), 56)
    s.swell('pad', 24, 8, 70, 92, 'arch')

    # A AGAIN 32-35: as bar 0 so the loop lands
    for i, spec in enumerate(A_H[:4]):
        chords(32 + i, spec, 54, pizz=(i == 3))
    s.motif('pmel', 34, motif_head('F5', 'major', rhythm=(1, .5, 2.5)) + m('r:4'), 56, form='head (piano), a question')
    s.expr('pad', 32, 80)
    s.line('pmel', 35, m('r:3 C5:1'), 50)
    s.swell('pad', 35, 1, 80, 100)
    s.expr('pad', 0, 80)
    return s
