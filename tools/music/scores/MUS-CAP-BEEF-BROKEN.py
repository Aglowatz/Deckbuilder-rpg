"""MUS-CAP-BEEF-BROKEN - Transit Yards, broken service (Capital district). 56 bars 4/4, 116 BPM, E minor (116 s loop).
TECHNO HARD ROCK palette (Gainlands rock Nov 3), run down: the Gainlands riff on ONE guitar only (no double), hits missing, whole bars gone;
a shadow guitar on its own channel 15 cents flat (Score.detune) echoes the answer and the Crossroads motif's head and gives out mid-phrase;
the bass on beat one only. Under it the stiff Capital grid: quantised harpsichord block chords on every beat and a march rudiment on the
snare (human feel off). Intro bed -> A thin riff -> B fragments -> C stalling -> A' thin -> the bed again.
"""
from lib import Song, p
from lib import rock as R
from lib.rock import PROG, MOTIF, ANSWER, GALLOP
from scores._rock_a import cut, grid_chord, grid_snare

GRID = {'E': ['E3', 'G3', 'B3'], 'C': ['E3', 'G3', 'C4'], 'D': ['D3', 'F#3', 'A3'], 'B': ['D#3', 'F#3', 'B3']}
THIN = tuple(h for i, h in enumerate(GALLOP) if i not in (2, 6, 7))          # the gallop with hits missing


def grid(s, bar, c, vel):
    grid_chord(s, 'harpsi', bar, GRID[c], vel)
    s.note('kit', s.B(bar), .2, 36, vel + 30, human=False)
    s.note('kit', s.B(bar, 2), .2, 36, vel + 22, human=False)


def bed(s, bar, c):
    grid(s, bar, c, 62)
    grid_snare(s, bar, 52, 'march' if bar % 2 == 0 else 'flam')
    s.note('sub', s.B(bar), 3.9, R.root(c), 76, human=False)
    R.pad_chord(s, bar, c, 60)
    R.sustain(s, bar, c, 50, chs=('gtrL',))


def build():
    s = Song('MUS-CAP-BEEF-BROKEN', bpm=116, bars=56, key='E minor', seed=816)
    s.jitter = 0.004
    R.band(s, kit_vol=104, gtr_vol=104)
    s.add('gtr2', 10, 30, pan=96, rev=60, vol=96)          # the shadow guitar, flat for the whole cue
    s.add('harpsi', 11, 6, pan=40, rev=60, vol=92)         # the Capital grid
    s.stem = s.stem | {'gtr2'}
    s.detune('gtr2', -15)
    for bar, nm in ((0, 'intro bed'), (4, 'A thin'), (16, 'B fragments'), (32, 'C stalling'), (44, "A' thin"), (52, 'outro bed')):
        s.section(bar, nm)
    s.notes.append('Broken = the Gainlands riff on one guitar with hits and bars missing, a shadow guitar 15 cents flat, the Capital grid underneath.')

    for i, c in enumerate(PROG):
        bed(s, i, c)

    # 4-15 A thin: one guitar, the gallop with holes, bars 7, 11 and 14 gone; bass on one
    missing = {7, 11, 14}
    for i in range(12):
        bar = 4 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 58)
        if bar % 4 == 0:
            grid_snare(s, bar, 56)
        if bar in missing:
            continue
        R.chug(s, bar, c, 82, pattern=THIN, chs=('gtrL',))
        s.note('bass', s.B(bar), 1.5, R.root(c), 86)
        s.note('kit', s.B(bar, 1), .2, 38, 84, human=False)
        s.note('kit', s.B(bar, 3), .2, 38, 78, human=False)

    # 16-31 B fragments: the answer on lead guitar cut short; the flat shadow guitar echoes the motif head and stops
    for i in range(16):
        bar = 16 + i
        c = ['E', 'E', 'C', 'C', 'D', 'D', 'B', 'B'][i % 8]
        grid(s, bar, c, 56)
        if i % 2 == 0:
            R.sustain(s, bar, c, 58, beats=6, chs=('gtrL',))
            s.note('bass', s.B(bar), 3, R.root(c), 80)
        if i % 4 == 2:
            grid_snare(s, bar, 54, 'flam')
    for k, bar in enumerate((16, 20, 24, 28)):
        s.mel('lead', bar, cut(ANSWER, 4.5 if k % 2 == 0 else 3), 98)
        s.motif('gtr2', bar + 2, cut(MOTIF, 2 + k % 2), 92, form='head (shadow guitar, 15 cents flat, cut off)', tr=12)
    s.motif('lead', 30, cut(MOTIF, 5), 96, form='stated, gives out mid-phrase', tr=12)

    # 32-43 C stalling: the riff starts and stops (two beats, then nothing); the grid carries on regardless
    for i in range(12):
        bar = 32 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 60)
        grid_snare(s, bar, 50 + (i % 3) * 4, 'march' if i % 2 == 0 else 'flam')
        if i % 3 != 2:
            R.chug(s, bar, c, 80, pattern=tuple(h for h in GALLOP if h[0] < (2 if i % 3 == 0 else 1)), chs=('gtrL',))
            s.note('bass', s.B(bar), 1, R.root(c), 82)
        if i % 4 == 1:
            s.chord('brass', s.B(bar, 2), .5, R.BRASS_HITS[c], 74)
    s.mel('gtr2', 36, cut(ANSWER, 3.5), 90, tr=12)
    s.mel('lead', 40, cut(ANSWER, 5), 94)

    # 44-51 A' thin
    for i in range(8):
        bar = 44 + i
        c = PROG[(i // 2) % 4]
        grid(s, bar, c, 58)
        if bar in (47, 50):
            continue
        R.chug(s, bar, c, 80, pattern=THIN, chs=('gtrL',))
        s.note('bass', s.B(bar), 1.5, R.root(c), 84)
        s.note('kit', s.B(bar, 1), .2, 38, 80, human=False)
        s.note('kit', s.B(bar, 3), .2, 38, 74, human=False)
    s.motif('gtr2', 48, cut(MOTIF, 2), 88, form='head (shadow, flat)', tr=12)

    for i, c in enumerate(PROG):
        bed(s, 52 + i, c)

    for a, b in ((4, 16), (32, 36), (44, 52)):
        s.tag_melody('gtrL', a, b)
    s.tag_melody('harpsi', 0, 4)
    s.tag_melody('harpsi', 52, 56)
    return s
