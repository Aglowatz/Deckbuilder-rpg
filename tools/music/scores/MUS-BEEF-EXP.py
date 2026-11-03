"""MUS-BEEF-EXP - The Gainlands, exploration. 72 bars 4/4, 120 BPM, E minor (144 s loop). TECHNO HARD ROCK (Gainlands rock Nov 3).
The battle demo's sound at walking pace: the Gainlands riff (gallop chug over E C D B) and its answer phrase on lead guitar, with room to
breathe - no huge drop. Intro bed -> riff -> theme (motif + answer) -> a gentle half-time B section (held chords, the breakdown lick, the
motif augmented in the brass) -> a short lift -> riff + theme at full band (the peak, still a rock beat, not four-on-the-floor) -> thinning
riff -> the intro bed again so the loop lands.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import PROG, MOTIF, ANSWER, ANSWER_TAG, LICK, BRASS_HITS
from scores._rock_a import bed, riff, augment


def build():
    s = Song('MUS-BEEF-EXP', bpm=120, bars=72, key='E minor', seed=121)
    s.jitter = 0.008
    R.band(s, kit_vol=112, gtr_vol=104)
    for bar, nm in ((0, 'intro bed'), (4, 'riff'), (12, 'theme'), (20, 'B gentle'), (36, 'lift'), (40, 'riff + theme'),
                    (56, 'riff thinning'), (68, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('Exploration: the Gainlands riff and answer at 120, no drop; gentle half-time B section with the breakdown lick.')

    # 0-3 intro bed
    for i, c in enumerate(PROG):
        bed(s, i, c, 50)
    s.motif('saw', 2, MOTIF[:3], 70, form='head (saw, over the bed)', tr=12)

    # 4-11 riff
    R.crash(s, 4, 96)
    for i in range(8):
        c = PROG[(i // 2) % 4]
        riff(s, 4 + i, c, 78, beat=90, fill=(i == 7))

    # 12-19 theme: sustained chords, the motif + answer on lead guitar, light brass
    R.crash(s, 12, 100)
    for i in range(8):
        bar = 12 + i
        c = PROG[(i // 2) % 4]
        if i % 2 == 0:
            R.sustain(s, bar, c, 72, beats=8)
        R.bassline(s, bar, c, 84)
        R.rock_beat(s, bar, 92, fill=(i == 7))
        s.chord('brass', s.B(bar), .5, BRASS_HITS[c], 78)
    s.motif('lead', 12, MOTIF, 100, form='stated (lead guitar)', tr=12)
    s.mel('lead', 14, ANSWER, 98)
    s.motif('lead', 16, MOTIF, 102, form='stated again', tr=12)
    s.mel('lead', 18, ANSWER_TAG, 104)

    # 20-35 B gentle: half-time, held chords, pad, the lick softly; then the motif augmented in the brass
    for i in range(16):
        bar = 20 + i
        c = ['E', 'E', 'C', 'C', 'D', 'D', 'B', 'B'][i % 8]
        R.rock_beat(s, bar, 70, half=True)
        if i % 2 == 0:
            R.sustain(s, bar, c, 52, beats=8)
            R.pad_chord(s, bar, c, 66, beats=8)
        R.bassline(s, bar, c, 72, style='hold')
        R.clank(s, bar, 54)
    s.mel('lead', 20, LICK, 84)
    s.motif('brass', 28, augment(MOTIF), 72, form='augmented (brass chorale)')

    # 36-39 lift: straight chugs rising, a short roll + riser (no drop)
    for i in range(4):
        c = ['C', 'D', 'C', 'B'][i]
        R.chug(s, 36 + i, c, 64 + i * 6, pattern='straight')
        R.bassline(s, 36 + i, c, 74 + i * 4)
        R.kick_pulse(s, 36 + i, 80 + i * 6)
    R.snare_roll(s, 38, 2, 40, 96)
    R.riser(s, 37, 3)

    # 40-55 riff + theme at full band: the peak
    R.crash(s, 40, 112)
    for i in range(16):
        bar = 40 + i
        c = PROG[(i // 2) % 4]
        riff(s, bar, c, 88, pattern='gallop' if i % 4 < 2 else 'straight', beat=104, fill=(i % 8 == 7))
        s.chord('brass', s.B(bar), .5, BRASS_HITS[c], 92)
        s.chord('brass', s.B(bar, 2.5), .4, BRASS_HITS[c], 82)
        if i % 8 == 0 and i:
            R.crash(s, bar, 104)
    s.motif('lead', 40, MOTIF, 110, form='stated 8va (lead guitar, peak)', tr=12)
    s.mel('lead', 42, ANSWER, 108, tr=12)
    s.motif('lead', 44, MOTIF, 112, form='stated 8va again', tr=12)
    s.mel('lead', 46, ANSWER_TAG, 112, tr=12)
    s.mel('saw', 48, ANSWER, 80, tr=12)
    s.mel('lead', 52, ANSWER, 104)

    # 56-67 riff thinning
    for i in range(12):
        bar = 56 + i
        c = PROG[(i // 2) % 4]
        riff(s, bar, c, 80 - i * 2, beat=94 - i * 2, fill=(i == 11))

    # 68-71 outro bed (= the intro, so the loop lands)
    for i, c in enumerate(PROG):
        bed(s, 68 + i, c, 50)

    for a, b in ((4, 12), (36, 40), (56, 68)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('saw', 0, 4)
    s.tag_melody('saw', 68, 72)
    return s
