"""MUS-SWOLY-BATTLE - Mount Swolympus, combat. 80 bars 4/4, 146 BPM, B minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
Mountain rock in combat, the demo's form: intro -> climbing riff -> theme -> build -> drop -> breakdown -> build -> drop 2 -> outro. The
Gainlands riff climbs (gallop chugs on B - D - E - F#, one step a bar), brass calls answered by the lead guitar's Gainlands answer, the
Crossroads motif (B F# E D C# F#, open) stated on the lead and in the drops. Intro and outro share one bed so the loop lands.
"""
from lib import Song, p
from lib import rock as R
from scores._rock_c import brass, pad, bed, gtr_ramp, brass_call

PROG = [('B1', 'Bm'), ('G1', 'G'), ('A1', 'A'), ('F#1', 'F#')]
CLIMB = [('B1', 'Bm'), ('D2', 'D'), ('E2', 'Emaj'), ('F#2', 'F#')]       # the climbing riff (E major chord = B Dorian lift)
DN = -5
MOTIF = R.transpose(R.MOTIF, DN)
ANSWER = R.transpose(R.ANSWER, DN)
ANSWER_TAG = R.transpose(R.ANSWER_TAG, DN)
LICK = R.transpose(R.LICK, DN)


def build():
    s = Song('MUS-SWOLY-BATTLE', bpm=146, bars=80, key='B minor', seed=4202)
    s.jitter = 0.006
    R.band(s)
    for bar, nm in ((0, 'intro'), (4, 'climbing riff'), (16, 'theme + brass calls'), (24, 'build'), (28, 'drop'),
                    (40, 'breakdown'), (48, 'build 2'), (52, 'drop 2'), (72, 'outro riff'), (78, 'outro')):
        s.section(bar, nm)
    s.notes.append('Mountain rock battle: the riff climbs B-D-E-F#, brass calls answered by the lead; demo form at 146.')

    def ch(i, per=2):
        return PROG[(i // per) % 4]

    def arp_bed(bar0, n, lo, hi):
        for i in range(n):
            r, c = CLIMB[(bar0 + i) % 4] if bar0 == 0 else CLIMB[(i + 2) % 4]
            bed(s, bar0 + i, r, c, kick=114, sub=98, padv=70, gtr=60)
            R.arp(s, bar0 + i, r, 92)
        gtr_ramp(s, bar0, n, lo, hi)
        s.ramp('saw', bar0, n, 96, 110)

    # 0-3 INTRO
    arp_bed(0, 4, 78, 100)
    R.snare_roll(s, 3, 1, 50, 108)
    R.riser(s, 2, 2)

    # 4-15 CLIMBING RIFF
    R.crash(s, 4)
    for i in range(12):
        bar = 4 + i
        r, c = CLIMB[i % 4]
        R.chug(s, bar, r, 88)
        R.bassline(s, bar, r, 92, style='gallop' if i % 4 == 3 else '8ths')
        R.rock_beat(s, bar, 106, fill=(i == 11))
        if i % 4 == 3:
            brass(s, bar, c, hits=((0, .5, 88), (2, .5, 92), (3, .9, 98)))

    # 16-23 THEME: brass call -> lead answer, sustained chords, motif on the lead
    R.crash(s, 16)
    for i in range(8):
        bar = 16 + i
        r, c = ch(i)
        if i % 2 == 0:
            R.sustain(s, bar, r, 82, beats=8)
            brass_call(s, bar, c, 98)
        R.bassline(s, bar, r, 90)
        R.rock_beat(s, bar, 104, fill=(i == 7))
    s.motif('lead', 16, MOTIF, 104, form='stated (lead, after the brass call)', tr=12, beat=0)
    s.mel('lead', 18, ANSWER, 104, tr=12)
    s.motif('lead', 20, MOTIF, 108, form='stated again', tr=12)
    s.mel('lead', 22, ANSWER_TAG, 110, tr=12)

    # 24-27 BUILD
    for i in range(4):
        bar = 24 + i
        r, c = [('G1', 'G'), ('A1', 'A'), ('G1', 'G'), ('F#1', 'F#')][i]
        R.sustain(s, bar, r, 48 + i * 10)
        pad(s, bar, c, 70)
    R.snare_roll(s, 24, 4, 30, 114)
    for k in range(32):
        s.note('timp', s.B(26) + k * .25, .2, p('F#2'), 40 + k * 2, human=False)
    R.riser(s, 24, 4)

    # 28-39 DROP: four-floor, sub, straight chug, saw stabs, the climbing riff returns in the second half
    R.crash(s, 28, 120)
    for i in range(12):
        bar = 28 + i
        r, c = ch(i) if i < 8 else CLIMB[i % 4]
        R.four_floor(s, bar, 118)
        R.subdrop(s, bar, r, 104)
        R.chug(s, bar, r, 90, pattern='straight')
        for b in (0, 1.5, 3):
            s.chord('saw', s.B(bar, b), .3, [R.root(r) + 36, R.root(r) + 43], 82)
        pad(s, bar, c, 74)
    s.pump('pad', 28, 12, lo=20, hi=100)
    s.motif('lead', 32, MOTIF, 100, form='stated (drop)', tr=12)
    s.mel('lead', 34, ANSWER, 100, tr=12)

    # 40-47 BREAKDOWN: half-time, the lick on the lead, brass chorale, clank
    for i in range(8):
        bar = 40 + i
        r, c = PROG[i // 2]
        R.rock_beat(s, bar, 94, half=True)
        if i % 2 == 0:
            R.sustain(s, bar, r, 64, beats=8)
            brass(s, bar, c, hits=((0, 7.9, 70),))
        R.bassline(s, bar, r, 82, style='hold')
        R.clank(s, bar, 68)
    s.mel('lead', 40, LICK, 100, tr=12)

    # 48-51 BUILD 2: the climb up, brass calls rising
    for i in range(4):
        bar = 48 + i
        r, c = CLIMB[i]
        R.sustain(s, bar, r, 54 + i * 10)
        brass_call(s, bar, c, 64 + i * 10)
    R.snare_roll(s, 48, 4, 36, 118)
    for k in range(32):
        s.note('timp', s.B(50) + k * .25, .2, p('B1'), 46 + k * 2, human=False)
    R.riser(s, 48, 4)

    # 52-71 DROP 2: everything - the motif 8va, brass on every hit, crashes every 4
    R.crash(s, 52, 124)
    for i in range(20):
        bar = 52 + i
        r, c = ch(i) if i < 16 else CLIMB[i % 4]
        R.four_floor(s, bar, 122)
        R.subdrop(s, bar, r, 108)
        R.chug(s, bar, r, 96, pattern='gallop' if i % 4 < 2 else 'straight')
        brass(s, bar, c, hits=((0, .5, 100), (1.5, .4, 88), (3, .5, 94)))
        pad(s, bar, c, 80)
        if i % 4 == 0 and i:
            R.crash(s, bar, 112)
    s.pump('pad', 52, 20, lo=20, hi=104)
    s.motif('lead', 52, MOTIF, 112, form='stated 8va (drop 2)', tr=24)
    s.mel('lead', 54, ANSWER, 110, tr=12)
    s.motif('lead', 56, MOTIF, 114, form='stated 8va again', tr=24)
    s.mel('lead', 58, ANSWER_TAG, 116, tr=12)
    s.motif('saw', 60, MOTIF, 86, form='saw, 2 octaves up', tr=24)
    s.mel('lead', 62, LICK, 112, tr=12)
    s.mel('lead', 70, [(p('F#5'), 4), (p('A#5'), 4)], 108)

    # 72-77 OUTRO RIFF, 78-79 the intro bed
    for i in range(6):
        bar = 72 + i
        r, c = CLIMB[i % 4]
        R.chug(s, bar, r, 86 - i * 2)
        R.bassline(s, bar, r, 88)
        R.rock_beat(s, bar, 102 - i * 2, fill=(i == 5))
    arp_bed(78, 2, 90, 80)

    for a, b in ((4, 16), (24, 32), (36, 40), (48, 52), (72, 78)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('saw', 0, 4)
    s.tag_melody('saw', 78, 80)
    return s
