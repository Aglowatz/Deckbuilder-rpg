"""MUS-LULLABY - Concordia's lullaby (motif master, one-shot). 10 bars 4/4, 70 BPM, D minor, ~38 s with the ring-out.
The melody is kept exactly as transcribed (theory.LULLABY_HEAD + LULLABY_ANSWER, 19 beats: D A F E A E - G E D F A F C G B A E);
only the orchestration is new: a solo flute sings it over harp arpeggios and soft strings, a celesta shadows the answer an octave up, a
cello hums below. Its last note (E over A) is answered by the harmony alone - the strings and harp fall to D (a gentle Picardy D major) -
so the tune stays unchanged and still resolves.
"""
from lib import Score, p, voice, LULLABY_HEAD, LULLABY_ANSWER
from scores._fork_b import held

MEL = LULLABY_HEAD + LULLABY_ANSWER                 # 19 beats, unchanged
CH = [(0, 4, 'Dm'), (4, 3, 'A'), (7, 2, 'Em7'), (9, 4, 'Dm'), (13, 2, 'C'), (15, 2, 'G'), (17, 2, 'A')]


def build():
    s = Score('MUS-LULLABY', bpm=70, bars=10, key='D minor', seed=1801, kind='oneshot')
    s.lufs = -20.0
    s.seat('fl', 'harp', 'pad', 'vc', 'cb', 'cel', pad={'vol': 70}, fl={'vol': 86})
    for bar, nm in ((0, 'harp'), (1, 'the lullaby'), (6, 'resolution')):
        s.section(bar, nm)
    s.notes.append('Motif master: melody unchanged (transcription), re-orchestrated; the harmony resolves to D after the last E.')

    # bar 0: harp + strings start at once
    for t in voice('Dm', 'D3', 4):
        s.note('harp', 0, 3, t, 62, human=False)
    s.pad('pad', 0, 'Dm', 48)
    s.note('cb', 0, 4.02, p('D2'), 44)
    s.harp(0, 'Dm', 46)

    # 1-5: the lullaby (starts at beat 4)
    for b, d, sym in CH:
        st = 4 + b
        s.pad('pad', 0, sym, 50, beats=d, beat=st)
        s.harp(0, sym, 44, beats=d, beat=st)
        s.bass_at(st, d, sym, 46, chs=('cb', None))
    s.mel('fl', 1, MEL, 80, transpose=12)
    s.line('cel', 1, MEL[6:], 44, transpose=24, beat=3)
    s.line('vc', 1, [('F3', 4), ('E3', 3), ('G3', 2), ('F3', 4), ('E3', 2), ('D3', 2), ('C#3', 2)], 50)

    # 6-9: the harmony answers the open E: A -> D (Picardy), held
    s.pad('pad', 5, 'A7sus4', 52, beats=1, beat=3)
    held(s, 6, 'D', 14, 54, ['pad'], low='D3')
    s.harp(6, 'D', 48, density=16)
    s.note('cb', 24, 14, p('D2'), 46)
    s.note('vc', 24, 14, p('A3'), 44)
    s.note('cel', 24, 6, p('F#6'), 40)
    return s
