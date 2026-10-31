"""MUS-PRIMM-MOTIF - For their own good (motif master, one-shot). 14 bars 4/4, 104 BPM, C major, quantised, ~35 s with the ring-out.
The existing Primm melody kept note for note (theory.PRIMM_HEAD + PRIMM_ANSWER, every note a quarter), re-orchestrated in the Capital
palette. First as the sincere early reform theme - music box and harpsichord over pizzicato, graceful and plausible - then again as the city
hears it now: strings and glockenspiel on the tune, block brass on every beat, snare rudiments, the too-perfect pulse made coercive. Ends on
a held C major chord, exactly on time.
"""
from lib import Score, p, voice, motif_head, PRIMM_HEAD, PRIMM_ANSWER
from lib.capital import QUANTISED, rudiment
from scores._fork_b import stack, bed, held

PRIMM = PRIMM_HEAD + PRIMM_ANSWER          # 16 quarters = 4 bars
H = ['C', 'G/B', 'F', 'G', 'F', 'Dm', 'G7', 'G7']          # two chords per bar under the tune


def build():
    s = Score('MUS-PRIMM-MOTIF', bpm=104, bars=14, key='C major', seed=1601, kind='oneshot', human=QUANTISED)
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'pizz', 'glock', 'tpt', 'tbn', 'hn', 'timp', 'perc')
    s.channel('mbox', 'music_box', pan=44, reverb=95, vol=86)
    s.channel('hpsd', 'harpsichord', pan=70, reverb=80, vol=74)
    for bar, nm in ((0, 'chime'), (1, 'sincere: music box'), (6, 'coercive: the city'), (11, 'held')):
        s.section(bar, nm)
    s.notes.append('Motif master: PRIMM_HEAD + PRIMM_ANSWER unchanged (all quarters), Capital palette, quantised.')

    # bar 0: starts instantly on a music-box C + harpsichord chord + soft pizz
    s.note('mbox', 0, 1.0, p('C6'), 80)
    for t in voice('C', 'C4', 3):
        s.note('hpsd', 0, 1.0, t, 64)
    s.note('pizz', 0, 1.0, p('C3'), 60)
    s.line('mbox', 0, [('G5', 1), ('E5', 1), ('D5', 1)], 64, beat=1)

    # 1-5 sincere: music box carries the tune, harpsichord broken chords, pizzicato bass
    stack(s, [('mbox', 12, 0), ('hpsd', 0, -18)], 1, PRIMM, 84)
    for i, sym in enumerate(['C', 'G', 'F', 'G7', 'C']):
        bar = 1 + i
        for k in range(4):
            tn = voice(sym, 'E4', 3)
            s.note('hpsd', bar * 4 + k + .5, .45, tn[k % 3], 50)
        s.pizz(bar, sym, 50, pattern=[(0, 'b'), (2, 'f')])
        s.pad('pad', bar, sym, 40)
    s.line('mbox', 5, [('G5', 1), ('E5', 1), ('C5', 2)], 70)
    s.motif('hn', 5, motif_head('C4', 'minor', rhythm=(1, 1, 1)), 58, form='head (horn) under the music box, cut off by the brass',
            lead=False)

    # 6-10 coercive: strings + glock on the tune, block brass on every beat, rudiments, timpani on downbeats
    stack(s, [('vln', 12, 0), ('glock', 24, -30), ('vln', 0, -16)], 6, PRIMM, 92)
    for i, sym in enumerate(['C', 'G', 'F', 'G7', 'C']):
        bar = 6 + i
        bed(s, bar, sym, 58, bass='march')
        for k in range(4):
            s.brass('tbn', bar, sym, 66 + (8 if k == 0 else 0), beats=.6, beat=k)
            s.brass('hn', bar, sym, 60, beats=.6, beat=k, low='C4')
        s.note('timp', bar * 4, 1.0, p('C2') if sym == 'C' else p(s.voicing(sym)[0]), 80)
        rudiment(s, 'perc', bar, 'march' if i < 4 else 'roll', 66)
    s.line('tpt', 10, [('G4', 1), ('E5', 1), ('C5', 2)], 80)

    # 11-13 the held C major chord
    held(s, 11, 'C', 10, 70, ['tbn', 'hn'])
    held(s, 11, 'C', 10, 62, ['pad'], low='C4')
    s.note('cb', 44, 10, p('C2'), 70)
    s.note('vc', 44, 10, p('C3'), 64)
    s.note('timp', 44, 1.0, p('C2'), 84)
    s.mel('mbox', 11, [('C6', 4), ('G5', 4)], 72)
    s.hit('crash', 44, 60, dur=4)
    return s
