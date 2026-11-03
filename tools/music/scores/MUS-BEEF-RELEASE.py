"""MUS-BEEF-RELEASE - Flex's rescue and true strength (story one-shot). 28 bars 4/4, 100 BPM, E major, ~67 s + ring-out.
TECHNO HARD ROCK palette (Gainlands rock Nov 3), but it starts orchestral and hopeful: a held string chord, harp, and a warm horn singing the
Gainlands answer in major, room for dialogue. Then the band swells in for "true strength" - power chords crescendo under a snare roll and
riser, and the full band takes the Crossroads motif RESOLVED on lead guitar (a release cue). It broadens to a brass + strings chorale and
ends on a held E major chord with a crash that rings out. -20 LUFS like the loops (story cue).
"""
from lib import Song, p
from lib import rock as R
from lib.rock import MOTIF_RESOLVED, ANSWER_MAJOR, BRASS_HITS
from scores._rock_a import riff, augment

PROG = ['E', 'C#', 'A', 'B']
HITS = {'E': 'Emaj', 'C#': 'C#m', 'A': 'A', 'B': 'B'}
STR = {'E': ['E3', 'B3', 'E4', 'G#4'], 'C#': ['C#3', 'G#3', 'C#4', 'E4'], 'A': ['A2', 'E3', 'A3', 'C#4'], 'B': ['B2', 'F#3', 'B3', 'D#4']}


def build():
    s = Song('MUS-BEEF-RELEASE', bpm=100, bars=28, key='E major', seed=818, kind='oneshot')
    s.lufs = -20.0                                 # story cue: sits with the loops
    s.jitter = 0.01
    R.band(s, kit_vol=112)
    s.add('strs', 10, 49, pan=50, rev=100, vol=124)     # slow strings
    s.add('hn', 11, 60, pan=78, rev=95, vol=118)        # French horn
    s.add('harp', 12, 46, pan=40, rev=85, vol=110)
    for bar, nm in ((0, 'hope (orchestral)'), (8, 'the band swells in'), (12, 'true strength'), (20, 'chorale'), (24, 'held E major')):
        s.section(bar, nm)
    s.notes.append('Release cue: orchestral opening, the rock band swells in at bar 8; resolved motif; starts instantly; held ending.')

    # 0-7 hope: strings + harp start at once; the horn sings the major answer, then the motif head
    for i in range(8):
        c = PROG[(i // 2) % 4]
        for n in STR[c]:
            s.note('strs', s.B(i), 3.95, p(n), 100 if i else 112, human=(i > 0))
        for k in range(8):
            notes = STR[c][1:] + [p(STR[c][2]) + 12]
            s.note('harp', s.B(i, k * .5), 1.0, p(notes[k % 4]) + 12, 84 - (k % 4) * 3, human=(i > 0 or k > 0))
        s.note('timp', s.B(i), 1.0, R.root(c) + 12, 96 if i == 0 else 70, human=False) if i % 2 == 0 else None
    s.mel('hn', 1, [(n, d * 2) for n, d in ANSWER_MAJOR[:5]], 108)
    s.motif('hn', 5, MOTIF_RESOLVED[:3], 104, form='head (horn, hopeful)')
    s.swell('strs', 0, 8, 100, 120)

    # 8-11 the band swells in: held power chords crescendo, kick pulse, snare roll, riser, strings keep going
    for i in range(4):
        c = ['A', 'B', 'A', 'B'][i]
        R.sustain(s, 8 + i, c, 64 + i * 10)
        for n in STR[c]:
            s.note('strs', s.B(8 + i), 3.95, p(n), 80)
        s.note('bass', s.B(8 + i), 3.9, R.root(c), 80 + i * 6)
        R.kick_pulse(s, 8 + i, 80 + i * 10)
        s.chord('brass', s.B(8 + i), 3.9, BRASS_HITS[HITS[c]], 60 + i * 10)
    R.snare_roll(s, 10, 2, 40, 112)
    R.riser(s, 9, 3)
    s.mel('hn', 8, [('B4', 2), ('C#5', 2), ('D#5', 2), ('F#5', 2), ('E5', 4), ('F#5', 4)], 86)

    # 12-19 true strength: the full band, the motif resolved on lead guitar, strings doubling
    R.crash(s, 12, 118)
    for i in range(8):
        bar = 12 + i
        c = PROG[(i // 2) % 4]
        riff(s, bar, c, 90, pattern='gallop' if i < 4 else 'straight', beat=108, fill=(i == 7))
        s.chord('brass', s.B(bar), .6, BRASS_HITS[HITS[c]], 96)
        s.chord('brass', s.B(bar, 2.5), .4, BRASS_HITS[HITS[c]], 86)
        for n in STR[c]:
            s.note('strs', s.B(bar), 3.95, p(n) + 12, 78)
        if i == 4:
            R.crash(s, bar, 110)
    s.motif('lead', 12, MOTIF_RESOLVED, 110, form='RESOLVED (lead guitar: true strength)', tr=12)
    s.mel('lead', 14, ANSWER_MAJOR, 108)
    s.motif('lead', 16, MOTIF_RESOLVED, 114, form='RESOLVED 8va', tr=12)
    s.mel('lead', 18, ANSWER_MAJOR[:6] + [('G#5', 1), ('B5', 1.5)], 114)

    # 20-23 chorale: half-time, brass + strings take the motif augmented and resolved
    for i in range(4):
        bar = 20 + i
        c = ['A', 'B', 'C#', 'B'][i]
        R.rock_beat(s, bar, 92, half=True)
        R.sustain(s, bar, c, 74)
        R.bassline(s, bar, c, 86, style='hold')
        for n in STR[c]:
            s.note('strs', s.B(bar), 3.95, p(n) + 12, 84)
    s.motif('brass', 20, augment(MOTIF_RESOLVED[:6]), 92, form='RESOLVED augmented (brass chorale)', lead=False)
    s.mel('lead', 20, [('C#6', 4), ('D#6', 4), ('E6', 4), ('F#6', 4)], 96)

    # 24-27 the held E major chord: everything lands on E and rings out
    R.crash(s, 24, 120)
    R.sustain(s, 24, 'E', 92, beats=12)
    s.chord('brass', s.B(24), 12, BRASS_HITS['Emaj'], 92)
    for n in STR['E']:
        s.note('strs', s.B(24), 12, p(n) + 12, 88)
    s.note('lead', s.B(24), 12, p('E5'), 100)
    s.note('bass', s.B(24), 12, R.root('E'), 92)
    s.note('sub', s.B(24), 8, R.root('E'), 84, human=False)
    for k in range(16):
        s.note('timp', s.B(24) + k * .25, .2, p('E2'), 80 - k * 3, human=False)
    for k in range(8):
        s.note('harp', s.B(24, k * .25), 2.0, p(['E4', 'G#4', 'B4', 'E5'][k % 4]) + 12 * (k // 4), 70)

    s.tag_melody('strs', 0, 1)
    s.tag_melody('gtrL', 8, 12)
    s.tag_melody('lead', 24, 28)
    return s
