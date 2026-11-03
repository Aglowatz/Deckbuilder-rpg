"""MUS-BEEF-FREED - The Gainlands restored. 68 bars 4/4, 128 BPM, E major (127.5 s loop). TECHNO HARD ROCK (Gainlands rock Nov 3).
Triumphant arena rock: the Gainlands riff in E major (I - vi - IV - V: E C#m A B), straight bright chugs, big brass, the Gainlands answer in
major (ANSWER_MAJOR) and the Crossroads motif RESOLVED on lead guitar (E B A G# F# E - a FREED cue). Celebratory, not aggressive: rock beat
with crashes, no double kick, no four-on-the-floor; the sub only in the anthem chorus. Intro bed -> riff -> theme -> half-time anthem B
(brass chorale, the motif augmented) -> build -> arena chorus (the peak) -> riff -> outro bed = the intro.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import MOTIF_RESOLVED, ANSWER_MAJOR, BRASS_HITS
from scores._rock_a import bed, riff, augment

PROG = ['E', 'C#', 'A', 'B']
HITS = {'E': 'Emaj', 'C#': 'C#m', 'A': 'A', 'B': 'B'}
# a major-key lick for the anthem section (E major pentatonic climbing to the octave)
LICK_MAJOR = [('B4', 1), ('C#5', .5), ('E5', .5), ('G#5', 2), ('F#5', 1), ('E5', 1), ('C#5', 1), ('B4', 1),
              ('A4', 1), ('C#5', .5), ('E5', .5), ('A5', 2), ('G#5', 1), ('F#5', 1), ('E5', 2),
              ('F#5', 1), ('G#5', .5), ('A5', .5), ('B5', 2), ('A5', 1), ('G#5', 1), ('F#5', 2),
              ('D#5', 2), ('F#5', 2), ('B5', 4)]


def build():
    s = Song('MUS-BEEF-FREED', bpm=128, bars=68, key='E major', seed=128)
    s.jitter = 0.007
    R.band(s, kit_vol=116)
    for bar, nm in ((0, 'intro bed'), (4, 'riff'), (12, 'theme'), (20, 'B anthem half-time'), (28, 'build'), (32, 'arena chorus'),
                    (48, 'riff'), (56, 'theme 2'), (64, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('FREED: resolved motif on lead guitar, E major, big brass; celebratory (rock beat + crashes, no drop machinery).')

    # 0-3 intro bed
    for i, c in enumerate(PROG):
        bed(s, i, c, 52, brass=HITS[c])
    s.motif('brass', 2, MOTIF_RESOLVED[:3], 76, form='head (brass, over the bed)', tr=0)

    # 4-11 riff: straight bright chugs
    R.crash(s, 4, 104)
    for i in range(8):
        c = PROG[(i // 2) % 4]
        riff(s, 4 + i, c, 82, pattern='straight', beat=98, fill=(i == 7))
        s.chord('brass', s.B(4 + i), .5, BRASS_HITS[HITS[c]], 80)

    # 12-19 theme: resolved motif + major answer, sustained chords, brass stabs
    R.crash(s, 12, 108)
    for i in range(8):
        bar = 12 + i
        c = PROG[(i // 2) % 4]
        if i % 2 == 0:
            R.sustain(s, bar, c, 78, beats=8)
        R.bassline(s, bar, c, 88)
        R.rock_beat(s, bar, 100, fill=(i == 7))
        s.chord('brass', s.B(bar), .6, BRASS_HITS[HITS[c]], 92)
        s.chord('brass', s.B(bar, 2.5), .4, BRASS_HITS[HITS[c]], 82)
    s.motif('lead', 12, MOTIF_RESOLVED, 104, form='RESOLVED (lead guitar)', tr=12)
    s.mel('lead', 14, ANSWER_MAJOR, 102)
    s.motif('lead', 16, MOTIF_RESOLVED, 108, form='RESOLVED again', tr=12)
    s.mel('lead', 18, ANSWER_MAJOR[:6] + [('G#5', 1), ('B5', 1.5)], 110)

    # 20-27 B anthem: half-time, brass chorale, the motif augmented in the brass, the major lick on lead
    for i in range(8):
        bar = 20 + i
        c = ['E', 'E', 'C#', 'C#', 'A', 'A', 'B', 'B'][i]
        R.rock_beat(s, bar, 84, half=True)
        if i % 2 == 0:
            R.sustain(s, bar, c, 60, beats=8)
            R.pad_chord(s, bar, HITS[c], 70, beats=8)
        R.bassline(s, bar, c, 78, style='hold')
        R.clank(s, bar, 56)
    s.mel('lead', 20, LICK_MAJOR, 92)
    s.motif('brass', 24, augment(MOTIF_RESOLVED), 70, form='RESOLVED augmented (brass chorale)', lead=False)

    # 28-31 build
    for i in range(4):
        c = ['A', 'B', 'A', 'B'][i]
        R.sustain(s, 28 + i, c, 54 + i * 8)
        s.chord('brass', s.B(28 + i), 3.9, BRASS_HITS[HITS[c]], 58 + i * 8)
    R.snare_roll(s, 28, 4, 34, 108)
    for k in range(32):
        s.note('timp', s.B(30) + k * .25, .2, p('B1'), 44 + k * 2, human=False)
    R.riser(s, 28, 4)

    # 32-47 arena chorus: the peak - gallop and straight chugs, crashes every 4 bars, big brass, sub, motif 8va, saw doubling
    R.crash(s, 32, 118)
    for i in range(16):
        bar = 32 + i
        c = PROG[(i // 2) % 4]
        riff(s, bar, c, 92, pattern='gallop' if i % 4 < 2 else 'straight', beat=110, fill=(i % 8 == 7))
        R.subdrop(s, bar, c, 92)
        s.chord('brass', s.B(bar), .5, BRASS_HITS[HITS[c]], 100)
        s.chord('brass', s.B(bar, 1.5), .4, BRASS_HITS[HITS[c]], 86)
        s.chord('brass', s.B(bar, 3), .5, BRASS_HITS[HITS[c]], 92)
        if i % 4 == 0 and i:
            R.crash(s, bar, 108)
    s.pump('pad', 32, 16, lo=30, hi=100)
    for i in range(16):
        R.pad_chord(s, 32 + i, HITS[PROG[(i // 2) % 4]], 74)
    s.motif('lead', 32, MOTIF_RESOLVED, 112, form='RESOLVED 8va (arena chorus)', tr=12)
    s.mel('lead', 34, ANSWER_MAJOR, 110, tr=12)
    s.motif('lead', 36, MOTIF_RESOLVED, 114, form='RESOLVED 8va again', tr=12)
    s.mel('lead', 38, ANSWER_MAJOR[:6] + [('G#5', 1), ('B5', 1.5)], 116, tr=12)
    s.motif('saw', 40, MOTIF_RESOLVED, 84, form='RESOLVED (saw, 2 octaves up)', tr=24)
    s.mel('lead', 42, ANSWER_MAJOR, 110, tr=12)
    s.motif('lead', 44, MOTIF_RESOLVED, 112, form='RESOLVED 8va (chorus end)', tr=12)
    s.mel('lead', 46, ANSWER_MAJOR, 108)

    # 48-55 riff
    for i in range(8):
        c = PROG[(i // 2) % 4]
        riff(s, 48 + i, c, 84, beat=100, fill=(i == 7))
        s.chord('brass', s.B(48 + i), .5, BRASS_HITS[HITS[c]], 82)

    # 56-63 theme 2: the answer on lead, sustained chords, thinning toward the bed
    for i in range(8):
        bar = 56 + i
        c = PROG[(i // 2) % 4]
        if i % 2 == 0:
            R.sustain(s, bar, c, 72 - i * 2, beats=8)
        R.bassline(s, bar, c, 82 - i * 2)
        R.rock_beat(s, bar, 94 - i * 3, fill=(i == 7))
    s.mel('lead', 56, ANSWER_MAJOR, 100)
    s.motif('lead', 58, MOTIF_RESOLVED, 98, form='RESOLVED (theme 2)', tr=12)
    s.mel('lead', 60, ANSWER_MAJOR, 92)

    # 64-67 outro bed = the intro
    for i, c in enumerate(PROG):
        bed(s, 64 + i, c, 52, brass=HITS[c])

    for a, b in ((4, 12), (28, 32), (48, 56), (62, 64)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('saw', 0, 4)
    s.tag_melody('saw', 64, 68)
    return s
