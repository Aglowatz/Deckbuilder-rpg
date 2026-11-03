"""MUS-BEEF-DUN-BATTLE - House of Gains, combat. 96 bars 4/4, 150 BPM, E minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
Faster and heavier than the zone battle: a 16th double kick under the Gainlands riff hammered (gallop and machine chugs), three drops,
each after a build that pulls back first. The Crossroads motif and the Gainlands answer on lead guitar, an octave up in the last drops, saw
stabs and a pumped pad in the drops, heroic brass on every bar, a half-time breakdown with the lick and the gym-clank cowbell.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import PROG, ROOT, MOTIF, ANSWER, ANSWER_TAG, LICK, BRASS_HITS


def build():
    s = Song('MUS-BEEF-DUN-BATTLE', bpm=150, bars=96, key='E minor', seed=412)
    s.jitter = 0.005
    R.band(s)
    for bar, nm in ((0, 'intro'), (4, 'riff hammered'), (16, 'build 1'), (20, 'drop 1'), (36, 'breakdown'), (44, 'build 2'),
                    (48, 'drop 2'), (72, 'build 3'), (76, 'drop 3'), (90, 'outro riff'), (92, 'outro')):
        s.section(bar, nm)
    s.notes.append('House of Gains battle: double kick, three drops, each prepared by a quieter build.')

    def bed(bar, c):
        """Intro / outro (identical, for the seam): held power chord, double kick, sub 8ths, pad, brass hit."""
        R.sustain(s, bar, c, 62)
        R.double_kick(s, bar, 96)
        R.subdrop(s, bar, c, 90)
        R.pad_chord(s, bar, c, 70)
        s.chord('brass', s.B(bar), .5, BRASS_HITS[c], 80)

    def drop(bar, c, vel, pattern='straight', motif_bar=False):
        R.double_kick(s, bar, vel)
        s.note('kit', s.B(bar, 2), .2, 39, vel - 14, human=False)        # clap layered on 3
        R.subdrop(s, bar, c, vel - 12)
        R.chug(s, bar, c, vel - 26, pattern=pattern)
        for b in (0, 1.5, 3):
            s.chord('saw', s.B(bar, b), .3, [p(ROOT[c]) + 36, p(ROOT[c]) + 43], 78)
        R.pad_chord(s, bar, c, 74)
        s.chord('brass', s.B(bar), .5, BRASS_HITS[c], vel - 18)
        s.chord('brass', s.B(bar, 2.5), .4, BRASS_HITS[c], vel - 28)

    def build_up(bar0, chords, roll=(34, 116), timp='B1'):
        for i, c in enumerate(chords):
            R.sustain(s, bar0 + i, c, 46 + i * 9)
            R.pad_chord(s, bar0 + i, c, 62)
            s.chord('brass', s.B(bar0 + i), 3.9, BRASS_HITS[c], 52 + i * 9)
            R.kick_pulse(s, bar0 + i, 70 + i * 8)
        R.snare_roll(s, bar0, len(chords), *roll)
        for k in range(32):
            s.note('timp', s.B(bar0 + len(chords) - 2) + k * .25, .2, p(timp), 40 + k * 2, human=False)
        R.riser(s, bar0, len(chords))

    for i, c in enumerate(['E', 'E', 'C', 'D']):
        bed(i, c)
    R.snare_roll(s, 3, 1, 60, 110)

    # 4-15 RIFF HAMMERED: gallop chugs, double kick, 8th bass, brass on every bar
    R.crash(s, 4, 112)
    for i in range(12):
        bar = 4 + i
        c = PROG[(i // 2) % 4]
        R.chug(s, bar, c, 90, pattern='gallop' if i % 4 < 2 else 'machine')
        R.bassline(s, bar, c, 94)
        R.double_kick(s, bar, 102)
        R.brass_hits(s, bar, c, vels=(90, 78))
        if i == 11:
            R.rock_beat(s, bar, 100, fill=True)
    s.motif('lead', 8, MOTIF, 102, form='stated (lead guitar, over the riff)', tr=12)
    s.mel('lead', 10, ANSWER, 100)
    s.motif('brass', 12, R.transpose(MOTIF, 0), 96, form='stated (brass, hammered)')
    s.mel('lead', 14, ANSWER_TAG, 104)

    # 16-19 BUILD 1
    build_up(16, ['C', 'D', 'C', 'B'])

    # 20-35 DROP 1: double kick, sub, chugs locked, saw stabs, pumped pad; motif + answer on lead
    R.crash(s, 20, 122)
    for i in range(16):
        bar = 20 + i
        drop(bar, PROG[(i // 2) % 4], 116)
        if i % 4 == 0 and i:
            R.crash(s, bar, 108)
    s.pump('pad', 20, 16, lo=20, hi=100)
    s.motif('lead', 20, MOTIF, 106, form='stated (lead guitar, drop 1)', tr=12)
    s.mel('lead', 22, ANSWER, 104)
    s.motif('lead', 24, MOTIF, 108, form='stated again', tr=12)
    s.mel('lead', 26, ANSWER_TAG, 110)
    s.motif('saw', 28, MOTIF, 84, form='stated 2 octaves up (saw)', tr=24)
    s.mel('lead', 30, ANSWER, 108, tr=12)
    s.mel('lead', 32, ANSWER_TAG, 112, tr=12)
    s.mel('lead', 34, [('E5', 2), ('D5', 1), ('B4', 1), ('C5', 2), ('D5', 2)], 104, tr=12)

    # 36-43 BREAKDOWN: half time, cowbell clank, held power chords, brass chorale, the lick
    for i in range(8):
        bar = 36 + i
        c = ['E', 'E', 'C', 'C', 'D', 'D', 'B', 'B'][i]
        R.rock_beat(s, bar, 94, half=True)
        if i % 2 == 0:
            R.sustain(s, bar, c, 64, beats=8)
            s.chord('brass', s.B(bar), 7.9, BRASS_HITS[c], 68)
        R.bassline(s, bar, c, 82, style='hold')
        R.clank(s, bar, 72)
    s.mel('lead', 36, LICK, 100)

    # 44-47 BUILD 2
    build_up(44, ['C', 'D', 'C', 'B'], roll=(36, 120))

    # 48-71 DROP 2: everything; gallop/machine chugs alternate, crashes every 4, motif 8va, saw doubling
    R.crash(s, 48, 124)
    for i in range(24):
        bar = 48 + i
        c = PROG[(i // 2) % 4]
        drop(bar, c, 120, pattern='gallop' if i % 4 < 2 else 'machine')
        s.chord('brass', s.B(bar, 1.5), .4, BRASS_HITS[c], 90)
        if i % 4 == 0 and i:
            R.crash(s, bar, 112)
    s.pump('pad', 48, 24, lo=20, hi=104)
    s.motif('lead', 48, MOTIF, 112, form='stated 8va (lead guitar, drop 2)', tr=12)
    s.mel('lead', 50, ANSWER, 110, tr=12)
    s.motif('lead', 52, MOTIF, 114, form='stated 8va again', tr=12)
    s.mel('lead', 54, ANSWER_TAG, 116, tr=12)
    s.mel('lead', 56, LICK, 108, tr=12)
    s.motif('saw', 64, MOTIF, 88, form='stated 2 octaves up (saw)', tr=24)
    s.mel('lead', 64, ANSWER, 112, tr=12)
    s.mel('lead', 66, ANSWER_TAG, 116, tr=12)
    s.motif('lead', 68, MOTIF, 114, form='stated 8va (lead guitar)', tr=12)
    s.mel('lead', 70, [('B5', 2), ('A5', 1), ('F#5', 1), ('D#5', 4)], 112)

    # 72-75 BUILD 3 (shorter roll, same pull-back)
    build_up(72, ['C', 'D', 'C', 'B'], roll=(40, 122), timp='E2')

    # 76-89 DROP 3: machine chugs, the riff hammered at full weight, answer on lead
    R.crash(s, 76, 126)
    for i in range(14):
        bar = 76 + i
        c = PROG[(i // 2) % 4]
        drop(bar, c, 122, pattern='machine' if i % 2 == 0 else 'gallop')
        if i % 4 == 0 and i:
            R.crash(s, bar, 114)
    s.pump('pad', 76, 14, lo=20, hi=104)
    s.motif('lead', 76, MOTIF, 114, form='stated 8va (lead guitar, drop 3)', tr=12)
    s.mel('lead', 78, ANSWER, 112, tr=12)
    s.motif('lead', 80, MOTIF, 116, form='stated 8va again', tr=12)
    s.mel('lead', 82, ANSWER_TAG, 118, tr=12)
    s.mel('lead', 84, ANSWER, 112, tr=12)
    s.mel('lead', 86, ANSWER_TAG, 114, tr=12)
    s.mel('lead', 88, [('E5', 2), ('D5', 1), ('B4', 1), ('D#5', 4)], 108, tr=12)

    # 90-91 OUTRO RIFF, 92-95 the intro bed (so the loop lands)
    for i, c in enumerate(['C', 'C']):
        bar = 90 + i
        R.chug(s, bar, c, 88, pattern='gallop')
        R.bassline(s, bar, c, 90)
        R.double_kick(s, bar, 100)
        R.brass_hits(s, bar, c, vels=(88, 76))
    for i, c in enumerate(['D', 'D', 'C', 'B']):
        bed(92 + i, c)

    for a, b in ((0, 8), (16, 20), (44, 48), (72, 76), (90, 96)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('lead', 12, 14)
    return s
