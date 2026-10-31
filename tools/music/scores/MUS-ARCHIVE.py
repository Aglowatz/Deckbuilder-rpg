"""MUS-ARCHIVE - Good intentions (reading Primm's early journals). One-shot, 22 bars 4/4, 72 BPM, Eb major, ~78 s with the ring-out.
A gifted reformer becoming a tyrant. The Primm motif simple and sincere on piano with the cello, human and warm, under rich, free harmony
(Ebmaj7, Cm9, Abmaj7, Fm9 ...). On the second statement the freedom drains away: the chords narrow to tonic and dominant, the left hand
becomes even eighths, a small clockwork tick creeps in, timing tightens until it is on the grid - and the last bars are a bare Eb octave.
The Crossroads motif's tail in the cello once, a question the young Primm could still have answered. Empathy without absolution.
"""
from lib import Score, p, voice, motif_tail, PRIMM_HEAD, PRIMM_ANSWER

PRIMM_EB = [(p(n) + 3, d) for n, d in PRIMM_HEAD + PRIMM_ANSWER]    # 16 beats
FREE = ['Ebmaj7', 'Cm9', 'Abmaj7', 'Bb7sus4', 'Gm7', 'Cm9', 'Fm9', 'Bb7sus4']
NARROW = ['Eb', 'Bb', 'Eb', 'Bb', 'Eb', 'Bb', 'Eb', 'Bb']


def build():
    s = Score('MUS-ARCHIVE', bpm=72, bars=22, key='Eb major', seed=1660, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'vc', 'cb', 'pad', 'perc', 'harp', piano={'vol': 88}, vc={'vol': 90}, pad={'vol': 68})
    s.channel('cel', 'celesta', pan=44, reverb=90, vol=58)
    for bar, nm in ((0, 'sincere'), (10, 'narrowing'), (18, 'the grid'), (20, 'bare octave')):
        s.section(bar, nm)
    s.notes.append('Human for the first statement; jitter tightened to the grid during the second (s.jitter changes at bars 10/14/18).')
    for bar, bpm in ((8, 66), (10, 72)):
        s.tempo(bar, bpm)

    def free(bar, sym, vel):
        tn = voice(sym, 'Eb3', 4)
        s.note('piano', bar * 4, 4.0, p(s.voicing(sym)[0]) + 12, vel)
        for k, t in enumerate(tn):
            s.note('piano', bar * 4 + .5 + k * .5, 3.4 - k * .5, t, vel - 6)
        s.pad('pad', bar, sym, vel - 12)

    # 0-1 intro: starts instantly on the Eb chord
    free(0, 'Ebmaj7', 50)
    free(1, 'Abmaj7', 48)
    s.mel('cel', 1, [('G5', 1), ('Bb5', 1), ('Eb6', 2)], 50)

    # 2-9 sincere statement, free harmony, cello countermelody
    for i, sym in enumerate(FREE):
        free(2 + i, sym, 52)
        s.note('cb', (2 + i) * 4, 4.02, p(s.voicing(sym)[0]), 42)
    s.mel('piano', 2, [(n, d * 2) for n, d in PRIMM_EB], 74, transpose=12)          # 32 beats: the tune at half speed, tender
    s.line('vc', 3, [('G3', 4), ('Ab3', 2), ('Bb3', 2), ('C4', 4), ('Bb3', 4), ('Ab3', 4), ('G3', 2), ('F3', 2), ('Eb3', 4)], 60)
    s.motif('vc', 8, motif_tail('Bb3', 'major', rhythm=(1.5, .5, 4)), 66, form='tail (cello), a question')

    # 10-17 narrowing: tonic/dominant only, even eighths, the tick creeps in, timing tightens
    s.jitter = 0.010
    for i, sym in enumerate(NARROW):
        bar = 10 + i
        if i == 4:
            s.jitter, s.vel_spread = 0.004, 2
        tn = voice(sym, 'Eb3', 3)
        for k in range(8):
            s.note('piano', bar * 4 + k * .5, .45, tn[k % 3] if k % 2 else p(s.voicing(sym)[0]) + 12, 46 + (6 if k == 0 else 0))
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 40)
        s.pad('pad', bar, sym, 38)
        if i >= 2:
            for k in range(4):
                s.note('perc', bar * 4 + k, .1, 77, 22 + i * 3, human=False)
    s.mel('piano', 10, PRIMM_EB + PRIMM_EB, 72, transpose=12)
    s.line('vc', 10, [('Eb3', 8), ('D3', 8), ('Eb3', 8), ('D3', 8)], 48, shape=False)

    # 18-19 the grid; 20-21 the bare Eb octave
    s.jitter, s.vel_spread = 0.0, 0
    for i in range(2):
        for k in range(4):
            s.note('perc', (18 + i) * 4 + k, .1, 76 if k == 0 else 77, 40, human=False)
            s.note('piano', (18 + i) * 4 + k, .9, p('Eb3'), 50, human=False)
    s.mel('piano', 18, [(n, 1) for n, _ in PRIMM_EB[:8]], 66, transpose=12)
    s.note('piano', 80, 8, p('Eb3'), 56, human=False)
    s.note('piano', 80, 8, p('Eb4'), 60, human=False)
    s.mel('vc', 20, [('Eb3', 8)], 58)
    s.note('cb', 80, 8, p('Eb2'), 46, human=False)
    s.note('pad', 80, 8, p('Eb4'), 40, human=False)
    return s
