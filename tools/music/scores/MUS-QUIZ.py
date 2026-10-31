"""MUS-QUIZ - Questions in triplicate (the four Path trivia encounters). Loop, 56 bars 3/4, 116 BPM, Bb major (86.9 s).
Curiosity and thinking time: a gentle 3/4 of piano and pizzicato over warm low strings, with question-and-answer figures - a flute asks
(a phrase rising to an open note), the clarinet or bassoon answers (falling home), in threes. A celesta glint and a harp roll now and
then; no ticking, no countdown. The Crossroads motif is the biggest question of all (flute, then cello), left open as always.
"""
from lib import Score, m, motif, motif_head, p
from scores._fork_a import bed, each, root

Q = m('F5:1 G5:1 A5:1 | Bb5:2 C6:1 | D6:3')             # a question, rising to an open note
A = m('C5:1 Bb4:1 A4:1 | G4:1 A4:1 F4:1 | Bb4:3')         # the answer, falling home
H = ['Bb', 'Gm7', 'Cm7', 'F7', 'Bb', 'Ebmaj7', 'Cm7', 'F7sus4']


def build():
    s = Score('MUS-QUIZ', bpm=116, bars=56, meter=(3, 4), key='Bb major', seed=720)
    s.seat('piano', 'pizz', 'vc', 'cb', 'pad', 'fl', 'cl', 'bsn', 'cel', 'harp')
    for bar, nm in ((0, 'intro'), (4, 'A three questions'), (20, 'B thinking'), (36, "A' three more"), (52, 'intro')):
        s.section(bar, nm)
    s.notes.append('3/4 thinking loop, no ticking; question (flute) / answer (clarinet, bassoon) figures in threes.')

    def think(bar, spec, vel):
        for t, d, sym in [(bar * 3 + b, dd, sy) for b, dd, sy in s.parts(spec)]:
            r = root(s, sym, 'Bb1')
            if r >= p('F2'):
                r -= 12
            s.note('cb', t, d - .02, r, vel - 6)
            s.note('vc', t, d - .02, r + 12, vel - 14)
            tn = s.chord_tones(sym, p('D4'), 4)
            s.note('pizz', t + 1, .4, tn[0], vel - 8)
            s.note('pizz', t + 2, .4, tn[1], vel - 10)
            s.note('piano', t, .9, tn[2] + 12, vel - 12)

    def intro(bar):
        for i, spec in enumerate(['Bb', 'Ebmaj7', 'Cm7', 'F7']):
            think(bar + i, spec, 60)
            bed(s, bar + i, spec, 32, ch='pad', low='D3', n=3)
        s.mel('piano', bar, m('D5:1 F5:1 Bb5:1 | G5:2 Eb5:1 | C5:1 Eb5:1 G5:1 | A5:3'), 70)

    intro(0)
    for k, (bar0, voices) in enumerate(((4, ('cl', 'bsn', 'cl')), (36, ('bsn', 'cl', 'bsn')))):
        for rep in range(2):
            for i, spec in enumerate(H):
                bar = bar0 + rep * 8 + i
                think(bar, spec, 60)
                bed(s, bar, spec, 34, ch='pad', low='D3', n=3)
        for j in range(3):
            b = bar0 + j * 5 if j < 2 else bar0 + 10
            s.mel('fl', b, Q, 78)
            s.mel(voices[j], b + 3, A[:3] if j < 2 else A, 76, transpose=-12 if voices[j] == 'bsn' else 0)
        s.line('cel', bar0 + 13, m('r:2 D7:1'), 46)
        s.mel('piano', bar0 + 13, m('Eb5:1 D5:1 C5:1 | F5:3'), 64)
    for i, spec in enumerate(['Gm', 'Ebmaj7', 'Cm7', 'D7', 'Gm', 'Ebmaj7', 'Am7b5', 'D7', 'Ebmaj7', 'Dm7', 'Cm7', 'F7',
                              'Bb', 'Gm7', 'Cm7', 'F7sus4']):
        think(20 + i, spec, 56)
        bed(s, 20 + i, spec, 40, ch='pad', low='D3', n=3)
        if i % 4 == 0:
            s.harp(20 + i, spec, 40, density=8)
    s.motif('fl', 20, motif('G5', 'minor', rhythm=[1.5, .75, .75, 2.25, .75, 3]) + m('r:3'), 78, form='stated in 3/4 (flute: the biggest question)')
    s.motif('vc', 24, motif('G3', 'minor', rhythm=[1.5, .75, .75, 2.25, .75, 3]) + m('r:3'), 80, form='stated (cello answers with the same question)')
    s.mel('cl', 28, m('Bb4:1 C5:1 D5:1 | Eb5:2 D5:1 | C5:1 Bb4:1 A4:1 | Bb4:3 | D5:1 Eb5:1 F5:1 | G5:2 F5:1 | Eb5:1 D5:1 C5:1 | C5:3'), 74)
    s.motif('fl', 34, motif_head('F5', 'major', rhythm=(1, .5, .5)) + m('r:1'), 62, form='head (flute)', lead=False)
    intro(52)
    return s
