"""MUS-SWOLY-EXP - Mount Swolympus, exploration. 64 bars 4/4, 118 BPM, B minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
Epic mountain rock: wide half-time power chords held for two bars (Bm G A F#, the Gainlands i - VI - VII - V a fifth up), a soaring lead
guitar climbing the Gainlands answer phrase, the Crossroads motif stated on the lead. A gentle B section in thin mountain air (pad, brass
chorale, the answer quietly on the lead, no chugs), then the climb (straight chugs, full rock beat) and a broad summit - no drop, room
to breathe for long play. Intro and outro share the same bed so the loop lands.
"""
from lib import Song, p
from lib import rock as R
from scores._rock_c import brass, pad, bed, gtr_ramp

PROG = [('B1', 'Bm'), ('G1', 'G'), ('A1', 'A'), ('F#1', 'F#')]
DN = -5                                         # E minor material -> B minor
MOTIF = R.transpose(R.MOTIF, DN)
ANSWER = R.transpose(R.ANSWER, DN)
ANSWER_TAG = R.transpose(R.ANSWER_TAG, DN)
LICK = R.transpose(R.LICK, DN)


def build():
    s = Song('MUS-SWOLY-EXP', bpm=118, bars=64, key='B minor', seed=4101)
    s.jitter = 0.008
    R.band(s, lead_vol=114)
    for bar, nm in ((0, 'intro'), (4, 'A wide'), (20, 'B thin air'), (32, 'C the climb'), (48, 'D summit'), (60, 'outro')):
        s.section(bar, nm)
    s.notes.append('Mount Swolympus: half-time mountain rock, two-bar power chords, the Gainlands answer climbing on the lead.')

    def ch(i, per=2):
        return PROG[(i // per) % 4]

    # 0-3 INTRO bed (the outro repeats it)
    def intro(bar0, lo=84, hi=100):
        for i in range(4):
            r, c = ch(i, 1)
            bed(s, bar0 + i, r, c, kick=96, sub=0, padv=72, gtr=62)
            R.bassline(s, bar0 + i, r, 80, style='hold')
            s.note('kit', s.B(bar0 + i, 2), .2, 38, 78, human=False)
        gtr_ramp(s, bar0, 4, lo, hi)
    intro(0)
    R.crash(s, 4, 104)

    # 4-19 A: wide half-time, two-bar chords, the answer climbing on the lead
    for i in range(16):
        bar = 4 + i
        r, c = ch(i)
        if i % 2 == 0:
            R.sustain(s, bar, r, 82, beats=8)
            brass(s, bar, c, hits=((0, 1.5, 78),))
        R.bassline(s, bar, r, 84)
        R.rock_beat(s, bar, 92, half=True, fill=(i == 15))
        pad(s, bar, c, 58)
    s.motif('lead', 4, MOTIF, 100, form='stated (lead guitar)', tr=12)
    s.mel('lead', 6, ANSWER, 98, tr=12)
    s.motif('lead', 8, MOTIF, 102, form='stated again, climbing', tr=12)
    s.mel('lead', 10, ANSWER_TAG, 104, tr=12)
    s.mel('lead', 12, LICK, 98, tr=12)

    # 20-31 B THIN AIR: pad, brass chorale, held bass, the answer soft on the lead; kick and rim only
    s.ramp('lead', 20, 1, 100, 78)
    for i in range(12):
        bar = 20 + i
        r, c = ch(i)
        pad(s, bar, c, 66)
        if i % 2 == 0:
            brass(s, bar, c, hits=((0, 7.8, 62),))
        R.bassline(s, bar, r, 70, style='hold')
        s.note('kit', s.B(bar), .2, 36, 74, human=False)
        s.note('kit', s.B(bar, 2), .2, 37, 60, human=False)
        s.note('kit', s.B(bar, 3.5), .2, 56, 44, human=False)            # far-off gym clank
    s.mel('lead', 20, ANSWER, 84)
    s.motif('lead', 24, MOTIF, 86, form='stated low (thin air)', tr=0)
    s.mel('lead', 26, ANSWER_TAG, 86)
    s.motif('saw', 28, MOTIF, 60, form='echo (saw, high)', tr=24)
    s.mel('lead', 30, [(p('F#4'), 4), (p('A#4'), 4)], 84)
    gtr_ramp(s, 30, 2, 70, 100)
    for i in (30, 31):
        R.sustain(s, i, 'F#1', 52 + (i - 30) * 10)
    R.snare_roll(s, 31, 1, 40, 96)
    R.riser(s, 30, 2)

    # 32-47 C THE CLIMB: straight chugs, full beat, brass hits, the motif an octave up
    s.ramp('lead', 32, 1, 90, 110)
    R.crash(s, 32, 110)
    for i in range(16):
        bar = 32 + i
        r, c = ch(i)
        R.chug(s, bar, r, 82, pattern='straight' if i % 4 < 3 else 'gallop')
        R.bassline(s, bar, r, 90)
        R.rock_beat(s, bar, 100, fill=(i % 8 == 7))
        brass(s, bar, c)
    s.motif('lead', 32, MOTIF, 106, form='stated 8va (the climb)', tr=24)
    s.mel('lead', 34, ANSWER, 104, tr=12)
    s.mel('lead', 36, ANSWER_TAG, 108, tr=12)
    s.mel('lead', 38, [(p('B5'), 2), (p('A5'), 1), (p('F#5'), 1), (p('G5'), 4)], 106)
    s.mel('lead', 40, LICK, 104, tr=12)

    # 48-59 D SUMMIT: broad - held chords, brass chorale, the answer 8va, crashes; still no drop
    for i in range(12):
        bar = 48 + i
        r, c = ch(i)
        if i % 2 == 0:
            R.sustain(s, bar, r, 92, beats=8)
            brass(s, bar, c, hits=((0, 7.8, 92),))
            R.crash(s, bar, 106)
        R.bassline(s, bar, r, 92)
        R.rock_beat(s, bar, 104, fill=(i == 11))
        pad(s, bar, c, 70)
    s.mel('lead', 48, ANSWER, 112, tr=12)
    s.motif('lead', 50, MOTIF, 112, form='stated (summit)', tr=24)
    s.mel('lead', 52, ANSWER_TAG, 114, tr=12)
    s.motif('saw', 54, MOTIF, 78, form='saw doubling, 2 octaves up', tr=24)
    s.mel('lead', 54, MOTIF, 110, tr=24)
    s.mel('lead', 56, [(p('B5'), 3), (p('C#6'), 1), (p('D6'), 2), (p('C#6'), 2), (p('B5'), 4), (p('A#5'), 4)], 108)

    # 60-63 OUTRO: the intro bed again
    s.ramp('lead', 60, 1, 110, 100)
    intro(60, 96, 80)
    s.tag_melody('gtrL', 0, 4)
    s.tag_melody('gtrL', 60, 64)
    return s
