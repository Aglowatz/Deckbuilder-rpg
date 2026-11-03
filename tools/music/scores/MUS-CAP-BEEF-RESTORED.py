"""MUS-CAP-BEEF-RESTORED - Transit Yards, service returns (Capital district). 56 bars 4/4, 116 BPM, E major (116 s loop).
TECHNO HARD ROCK palette (Gainlands rock Nov 3): MUS-CAP-BEEF-BROKEN mended. The Gainlands riff whole and double-tracked in E major (E C#m A B),
every hit back, the bass walking 8ths, a full rock beat; the second guitar - flat in the broken cue - now in tune, doubling the lead; the
Gainlands answer in major and the Crossroads motif RESOLVED on lead guitar. The stiff Capital grid (quantised harpsichord chords, march
rudiment) is still underneath, quieter. Intro bed -> A riff -> B theme -> C riff + brass -> A' theme -> the bed again.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import MOTIF_RESOLVED, ANSWER_MAJOR, BRASS_HITS
from scores._rock_a import grid_chord, grid_snare, riff

PROG = ['E', 'C#', 'A', 'B']
HITS = {'E': 'Emaj', 'C#': 'C#m', 'A': 'A', 'B': 'B'}
GRID = {'E': ['E3', 'G#3', 'B3'], 'C#': ['E3', 'G#3', 'C#4'], 'A': ['E3', 'A3', 'C#4'], 'B': ['D#3', 'F#3', 'B3']}


def grid(s, bar, c, vel):
    grid_chord(s, 'harpsi', bar, GRID[c], vel)


def bed(s, bar, c):
    grid(s, bar, c, 62)
    grid_snare(s, bar, 52, 'march' if bar % 2 == 0 else 'flam')
    s.note('kit', s.B(bar), .2, 36, 92, human=False)
    s.note('kit', s.B(bar, 2), .2, 36, 84, human=False)
    s.note('sub', s.B(bar), 3.9, R.root(c), 76, human=False)
    R.pad_chord(s, bar, HITS[c], 62)
    R.sustain(s, bar, c, 52)


def build():
    s = Song('MUS-CAP-BEEF-RESTORED', bpm=116, bars=56, key='E major', seed=817)
    s.jitter = 0.006
    R.band(s, kit_vol=108, gtr_vol=106)
    s.add('gtr2', 10, 30, pan=96, rev=60, vol=90)          # the shadow guitar of the broken cue, in tune now
    s.add('harpsi', 11, 6, pan=40, rev=60, vol=84)         # the Capital grid, still there
    s.stem = s.stem | {'gtr2'}
    for bar, nm in ((0, 'intro bed'), (4, 'A riff'), (16, 'B theme'), (32, 'C riff + brass'), (44, "A' theme"), (52, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('Restored = the broken cue whole and in tune: doubled riff, every hit back, resolved motif; the Capital grid underneath.')

    for i, c in enumerate(PROG):
        bed(s, i, c)

    # 4-15 A riff: the gallop whole, doubled, full beat
    R.crash(s, 4, 104)
    for i in range(12):
        bar = 4 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 52)
        riff(s, bar, c, 82, beat=98, fill=(i % 8 == 7))

    # 16-31 B theme: the motif resolved + major answer on lead, the second guitar doubling in tune; brass stabs
    R.crash(s, 16, 106)
    for i in range(16):
        bar = 16 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 50)
        if i % 2 == 0:
            R.sustain(s, bar, c, 74, beats=8)
        R.bassline(s, bar, c, 86)
        R.rock_beat(s, bar, 98, fill=(i % 8 == 7))
        s.chord('brass', s.B(bar), .5, BRASS_HITS[HITS[c]], 84)
    for k, bar in enumerate((16, 24)):
        s.motif('lead', bar, MOTIF_RESOLVED, 104 + k * 4, form='RESOLVED (lead guitar)', tr=12)
        s.line('gtr2', bar, MOTIF_RESOLVED, 84, tr=12)
        s.mel('lead', bar + 2, ANSWER_MAJOR, 102 + k * 4)
        s.line('gtr2', bar + 2, ANSWER_MAJOR, 82)
        s.motif('lead', bar + 4, MOTIF_RESOLVED, 106 + k * 4, form='RESOLVED again', tr=12)
        s.mel('lead', bar + 6, ANSWER_MAJOR[:6] + [('G#5', 1), ('B5', 1.5)], 108 + k * 4)

    # 32-43 C riff + brass: the peak, straight + gallop chugs, sub, brass on the hits
    R.crash(s, 32, 112)
    for i in range(12):
        bar = 32 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 54)
        riff(s, bar, c, 90, pattern='straight' if i % 4 < 2 else 'gallop', beat=106, fill=(i % 4 == 3))
        R.subdrop(s, bar, c, 88)
        s.chord('brass', s.B(bar), .5, BRASS_HITS[HITS[c]], 96)
        s.chord('brass', s.B(bar, 2.5), .4, BRASS_HITS[HITS[c]], 86)
        if i % 4 == 0 and i:
            R.crash(s, bar, 104)
    s.motif('lead', 36, MOTIF_RESOLVED, 110, form='RESOLVED 8va (peak)', tr=24)
    s.mel('lead', 38, ANSWER_MAJOR, 108, tr=12)

    # 44-51 A' theme, thinning toward the bed
    for i in range(8):
        bar = 44 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 56)
        if i % 2 == 0:
            R.sustain(s, bar, c, 70 - i * 2, beats=8)
        R.bassline(s, bar, c, 82 - i * 2)
        R.rock_beat(s, bar, 92 - i * 3, fill=(i == 7))
    s.mel('lead', 44, ANSWER_MAJOR, 98)
    s.motif('lead', 46, MOTIF_RESOLVED, 96, form='RESOLVED (closing)', tr=12)
    s.line('gtr2', 46, MOTIF_RESOLVED, 78, tr=12)
    s.mel('lead', 48, ANSWER_MAJOR, 92)

    for i, c in enumerate(PROG):
        bed(s, 52 + i, c)

    for a, b in ((4, 16), (32, 36), (40, 44), (50, 52)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('harpsi', 0, 4)
    s.tag_melody('harpsi', 52, 56)
    return s
