"""MUS-SWOLY-BOSS - The Ancient Spotter (Mount Swolympus boss). 72 bars 4/4, 138 BPM, F# minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
Its own track. The Spotter's own idea, kept from the orchestral version and given to the band: a stone-heavy COUNT - three hammered reps
on F# and a strained climb ("one more") that sinks to the leading tone E# - as hammered power-chord stops with kick and toms on every
rep (the toms climb with the count: one, two, three, one more). Against it the Gainlands riff and answer in F# minor, a thin-air
breakdown with the lick, and in the climax the hero's Crossroads motif (F# C# B A G# C#, open - not resolved) on lead guitar over the
Spotter's count with double kick and sub. Intro and outro are the count alone on the same bed, so the loop lands.
"""
from lib import Song, p
from lib import rock as R
from scores._rock_c import brass, pad, gtr_ramp

UP = 2                                          # E minor material -> F# minor
MOTIF = R.transpose(R.MOTIF, UP)
ANSWER = R.transpose(R.ANSWER, UP)
ANSWER_TAG = R.transpose(R.ANSWER_TAG, UP)
LICK = R.transpose(R.LICK, UP)
PROG = [('F#1', 'F#m'), ('D2', 'D'), ('E2', 'Emaj'), ('C#2', 'C#')]
# The Spotter's count (4 bars): rep rep rep climb | strain - sink | rep rep rep climb | "one more" - the leading tone
SPOT = [('F#2', 1), ('F#2', 1), ('F#2', 1), ('A2', 1), ('G#2', 2), ('C#2', 2),
        ('F#2', 1), ('F#2', 1), ('F#2', 1), ('B2', 1), ('A2', 1.5), ('G#2', .5), ('F2', 2)]
SPOT_H = ['F#m', 'C#', 'F#m', 'C#']
COUNT_TOMS = [45, 47, 48, 50]


def build():
    s = Song('MUS-SWOLY-BOSS', bpm=138, bars=72, key='F# minor', seed=4303)
    s.jitter = 0.006
    R.band(s, brass=57)                         # trombones: the Spotter's stone voice
    for bar, nm in ((0, 'intro count'), (4, 'A the Spotter'), (20, 'B Gainlands vs the count'), (36, 'C thin air'),
                    (44, 'build'), (48, 'D climax'), (68, 'outro count')):
        s.section(bar, nm)
    s.notes.append("Villain idea = the Spotter's count (three hammered reps + a strained climb to E#) as power-chord stops + toms.")

    def spotter(bar, vel, kit=True, brass_v=0, bass=True):
        t = s.B(bar)
        rep = 0
        for n, d in SPOT:
            for ch, off in (('gtrL', 0.0), ('gtrR', 0.012)):
                s.chord(ch, t + off, d * 0.82, R.power(n), vel)
            if bass:
                s.note('bass', t, d * .9, R.root(n), vel + 4)
            if brass_v:
                s.chord('brass', t, d * .8, [p(n) + 12, p(n) + 19], brass_v)
            if kit:
                s.note('kit', t, .2, 36, vel + 10, human=False)
                if d == 1:
                    s.note('kit', t, .3, COUNT_TOMS[rep % 4], vel, human=False)
                    rep += 1
                else:
                    s.note('kit', t, .3, 38, vel + 6, human=False)
                    rep = 0
            t += d

    # 0-3 INTRO: the count alone (guitars swelling, kick + toms, trombones)
    spotter(0, 82, brass_v=70)
    gtr_ramp(s, 0, 4, 76, 100)
    for i in range(4):
        pad(s, i, SPOT_H[i], 68)

    # 4-19 A THE SPOTTER: the count at full weight, double kick from bar 12
    R.crash(s, 4, 116)
    for k in range(4):
        bar = 4 + 4 * k
        spotter(bar, 86, kit=k < 2, brass_v=76)
        if k >= 2:
            for j in range(4):
                R.double_kick(s, bar + j, 96)
        for j in range(4):
            pad(s, bar + j, SPOT_H[j], 64)
    s.tag_melody('gtrL', 4, 20)

    # 20-35 B GAINLANDS vs THE COUNT: the gallop riff in F# minor, the answer on the lead, the count ticking on cowbell
    R.crash(s, 20, 114)
    for i in range(16):
        bar = 20 + i
        r, c = PROG[(i // 2) % 4]
        R.chug(s, bar, r, 88)
        R.bassline(s, bar, r, 90)
        R.rock_beat(s, bar, 104, fill=(i % 8 == 7))
        for b in range(3):
            s.note('kit', s.B(bar, b), .2, 56, 64 + b * 6, human=False)      # one, two, three...
        if i % 2 == 1:
            brass(s, bar, c, hits=((3, .9, 90),))                            # ...one more
    s.mel('lead', 20, ANSWER, 104, tr=12)
    s.motif('lead', 22, MOTIF, 104, form='stated (lead, against the count)', tr=12)
    s.mel('lead', 24, ANSWER_TAG, 108, tr=12)
    s.motif('lead', 28, R.transpose(R.MOTIF, UP - 12)[:6], 92, form='stated low (under the riff)', tr=12)
    s.mel('lead', 30, ANSWER, 108, tr=12)
    s.mel('lead', 32, ANSWER_TAG, 112, tr=12)
    s.mel('lead', 34, [(p('C#5'), 4), (p('E#5'), 4)], 108)

    # 36-43 C THIN AIR: half-time, the lick, trombone chorale, a far clank
    for i in range(8):
        bar = 36 + i
        r, c = PROG[i // 2]
        R.rock_beat(s, bar, 90, half=True)
        if i % 2 == 0:
            R.sustain(s, bar, r, 62, beats=8)
            brass(s, bar, c, hits=((0, 7.9, 66),))
        R.bassline(s, bar, r, 80, style='hold')
        R.clank(s, bar, 60)
    s.mel('lead', 36, LICK, 98, tr=12)

    # 44-47 BUILD: the count as one long roll, riser, timpani
    for i in range(4):
        bar = 44 + i
        r = ['D2', 'E2', 'D2', 'C#2'][i]
        R.sustain(s, bar, r, 54 + i * 10)
        pad(s, bar, ['D', 'Emaj', 'D', 'C#'][i], 70)
    R.snare_roll(s, 44, 4, 34, 120)
    for k in range(32):
        s.note('timp', s.B(46) + k * .25, .2, p('C#2'), 46 + k * 2, human=False)
    R.riser(s, 44, 4)
    s.tag_melody('gtrL', 44, 48)

    # 48-67 D CLIMAX: the Spotter's count under the hero's motif; double kick, sub, saw; the last 8 bars the biggest
    R.crash(s, 48, 126)
    for k in range(5):
        bar = 48 + 4 * k
        big = k >= 3
        spotter(bar, 100 if big else 94, kit=False, brass_v=96 if big else 88)
        for j in range(4):
            R.double_kick(s, bar + j, 116 if big else 110)
            r = SPOT[[0, 4, 6, 10][j]][0]
            R.subdrop(s, bar + j, r, 104)
            pad(s, bar + j, SPOT_H[j], 80)
            s.chord('saw', s.B(bar + j, 0), .3, [R.root(r) + 36, R.root(r) + 43], 84)
        R.crash(s, bar, 116)
    s.pump('pad', 48, 20, lo=24, hi=104)
    s.motif('lead', 48, MOTIF, 112, form='stated (hero vs the count)', tr=12)
    s.mel('lead', 50, ANSWER, 110, tr=12)
    s.motif('lead', 52, MOTIF, 114, form='stated 8va (fighting back)', tr=24)
    s.mel('lead', 54, ANSWER_TAG, 116, tr=12)
    s.motif('lead', 56, MOTIF, 116, form='stated 8va again', tr=24)
    s.motif('saw', 60, MOTIF, 90, form='saw 2 octaves up (final drop)', tr=24)
    s.mel('lead', 60, ANSWER, 118, tr=24)
    s.mel('lead', 62, ANSWER_TAG, 118, tr=12)
    s.motif('lead', 64, MOTIF, 120, form='stated, open (the question still stands)', tr=24)
    s.mel('lead', 66, [(p('C#6'), 8)], 116)

    # 68-71 OUTRO: the count alone again, swelling back down into bar 0
    spotter(68, 82, brass_v=70)
    gtr_ramp(s, 68, 4, 100, 78)
    for i in range(4):
        pad(s, 68 + i, SPOT_H[i], 68)
    s.tag_melody('gtrL', 0, 4)
    s.tag_melody('gtrL', 68, 72)
    return s
