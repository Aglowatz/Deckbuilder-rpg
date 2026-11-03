"""MUS-BEEF-DUN-EXP - House of Gains, exploration. 72 bars 4/4, 126 BPM, E minor. TECHNO HARD ROCK (Gainlands rock Nov 3).
Exuberance turned into compulsory repetitions: the Gainlands riff ground into 16th MACHINE chugs (a gym machine's reps), metallic clank on
the power kit (ride bell, cowbell, side stick), the Crossroads motif stern on lead guitar over brass stabs. A quiet breath section for Flex:
the guitars stop, a clean guitar sings the Gainlands answer over a brass chorale and pad. Then the riff returns heavier with the lick.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import PROG, MOTIF, ANSWER, ANSWER_TAG, LICK, BRASS_HITS


def build():
    s = Song('MUS-BEEF-DUN-EXP', bpm=126, bars=72, key='E minor', seed=311)
    s.jitter = 0.006
    R.band(s)
    s.add('clean', 10, 27, pan=44, rev=90, vol=124)        # clean electric guitar (not in the amp stem): Flex's breath
    for bar, nm in ((0, 'intro machine'), (4, 'machine riff'), (16, 'theme (stern)'), (28, 'breath (Flex)'), (40, 'build'),
                    (44, 'riff + lick'), (60, 'outro riff'), (68, 'outro machine')):
        s.section(bar, nm)
    s.notes.append('House of Gains: the Gainlands riff as 16th machine reps; a guitar-free breath section for Flex.')

    def clank(bar, vel):
        """The gym machine: ride bell on the beats, cowbell on the off-beats, a side-stick 'click' at the end of each rep."""
        for b in range(4):
            s.note('kit', s.B(bar, b), .1, 53, vel - 10, human=False)
        R.clank(s, bar, vel, beats=(1.5, 3.5))
        s.note('kit', s.B(bar, 3.75), .1, 37, vel - 16, human=False)

    def bed(bar, c):
        """Intro and outro (the same, so the seam matches): held power chord, synth sub, pad, kick pulse, the machine clank."""
        R.sustain(s, bar, c, 60)
        R.kick_pulse(s, bar, 104)
        for b in range(4):
            s.note('sub', s.B(bar, b), .9, R.root(c), 86, human=False)
        R.pad_chord(s, bar, c, 66)
        clank(bar, 82)

    for i, c in enumerate(['E', 'E', 'C', 'D']):
        bed(i, c)
    R.snare_roll(s, 3, 1, 44, 90)

    # 4-15 MACHINE RIFF: 16th chugs on E C D B, gallop bass, rock beat, clank
    R.crash(s, 4, 100)
    for i in range(12):
        bar = 4 + i
        c = PROG[(i // 2) % 4]
        R.chug(s, bar, c, 78, pattern='machine')
        R.bassline(s, bar, c, 86, style='gallop')
        R.rock_beat(s, bar, 96, fill=(i == 11))
        clank(bar, 72)

    # 16-27 THEME (stern): the motif on lead guitar, brass stabs, straight chugs lower
    R.crash(s, 16, 104)
    for i in range(12):
        bar = 16 + i
        c = PROG[(i // 2) % 4]
        R.chug(s, bar, c, 70, pattern='straight')
        R.bassline(s, bar, c, 86)
        R.rock_beat(s, bar, 96, fill=(i == 11))
        R.brass_hits(s, bar, c, vels=(86, 74))
        clank(bar, 64)
    s.motif('lead', 16, MOTIF, 100, form='stated (lead guitar, stern)', tr=12)
    s.mel('lead', 18, ANSWER, 96)
    s.motif('lead', 20, MOTIF, 102, form='stated again (lead guitar)', tr=12)
    s.mel('lead', 22, ANSWER_TAG, 104)
    s.motif('brass', 24, R.transpose(MOTIF, -12), 84, form='stated low (brass, the machine answers)')
    s.mel('lead', 26, ANSWER[:5] + [('E5', 3)], 96)

    # 28-39 BREATH (Flex): no distorted guitars; clean guitar on the answer, brass chorale, pad, side-stick and soft kick
    for i in range(12):
        bar = 28 + i
        c = ['E', 'E', 'C', 'C', 'D', 'D', 'B', 'B', 'C', 'C', 'D', 'B'][i]
        if i % 2 == 0 or i >= 8:
            long = i % 2 == 0 and i < 8
            R.pad_chord(s, bar, c, 84, beats=8 if long else 4)
            s.chord('brass', s.B(bar), 7.8 if long else 3.8, BRASS_HITS[c], 76)
        R.bassline(s, bar, c, 70, style='hold')
        s.note('bass', s.B(bar, 2.5), .45, R.root(c) + 7, 74)
        s.note('kit', s.B(bar), .2, 36, 86, human=False)
        s.note('kit', s.B(bar, 2), .1, 37, 76, human=False)
        s.note('kit', s.B(bar, 3.5), .2, 56, 64, human=False)
    s.mel('clean', 28, ANSWER, 116)
    s.motif('clean', 30, MOTIF, 114, form='stated (clean guitar, Flex breathing)')
    s.mel('clean', 32, ANSWER_TAG, 118)
    s.mel('clean', 34, [('B4', 2), ('A4', 1), ('G4', 1), ('F#4', 4)], 112)
    s.mel('clean', 36, [('E5', 1), ('D5', .5), ('B4', .5), ('C5', 2), ('D5', 2), ('D#5', 2), ('F#5', 2), ('B4', 4)], 116)

    # 40-43 BUILD: power chords swell, snare roll, riser, timpani
    for i in range(4):
        bar = 40 + i
        c = ['C', 'D', 'C', 'B'][i]
        R.sustain(s, bar, c, 50 + i * 8)
        R.pad_chord(s, bar, c, 66)
        clank(bar, 56 + i * 6)
    R.snare_roll(s, 40, 4, 30, 108)
    for k in range(32):
        s.note('timp', s.B(42) + k * .25, .2, p('B1'), 40 + k * 2, human=False)
    R.riser(s, 40, 4)

    # 44-59 RIFF + LICK: the machine riff full, the breakdown lick on lead, brass hits, motif 8va
    R.crash(s, 44, 112)
    for i in range(16):
        bar = 44 + i
        c = PROG[(i // 2) % 4]
        R.chug(s, bar, c, 88, pattern='machine' if i % 4 < 2 else 'gallop')
        R.bassline(s, bar, c, 92)
        R.rock_beat(s, bar, 106, fill=(i % 8 == 7))
        R.brass_hits(s, bar, c, vels=(94, 82))
        clank(bar, 74)
        if i % 8 == 0 and i:
            R.crash(s, bar, 108)
    s.mel('lead', 44, LICK, 104)
    s.motif('lead', 52, MOTIF, 112, form='stated 8va (lead guitar, the reps at full weight)', tr=12)
    s.mel('lead', 54, ANSWER, 110, tr=12)
    s.motif('lead', 56, MOTIF, 112, form='stated 8va again', tr=12)
    s.mel('lead', 58, ANSWER_TAG, 112, tr=12)

    # 60-67 OUTRO RIFF: the machine riff thinning
    for i in range(8):
        bar = 60 + i
        c = PROG[(i // 2) % 4]
        R.chug(s, bar, c, 80 - i * 2, pattern='machine')
        R.bassline(s, bar, c, 84, style='gallop')
        R.rock_beat(s, bar, 98 - i * 2, fill=(i == 7))
        clank(bar, 72)

    # 68-71 OUTRO MACHINE: the intro's bed, leading back into bar 0 (E)
    for i, c in enumerate(['C', 'D', 'C', 'B']):
        bed(68 + i, c)

    s.soften_tail(0.8, bars=1)                 # seam: the last bar's B chord rings over bar 0's E
    for a, b in ((0, 16), (40, 44), (60, 72)):
        s.tag_melody('gtrL', a, b)
    return s
