"""Techno hard rock: the Beefcake palette since Gainlands rock Nov 3 (score_bible.md section 3 / 10).

The helpers of the approved demo (Music_Source/zone_demos/ZONE-GAINLANDS_demo_score.py) made reusable: the same notes in the same order
(so a port draws the same humanising), with any root instead of the demo's fixed chord names. Use them on a `Song` (lib/song.py) whose
channels come from `band()`; set `s.profile = 'rock'` (band() does) so render.rock_chain sends the guitars through the amp sim.

Roots: a chord name in ROOT ('E', 'C', 'D', 'B', 'G', 'A' as the demo voices them, plus the E-major / other-key names below), or any
pitch ('F#2', 40).
"""
from .theory import p

GTR = ('gtrL', 'gtrR', 'lead')      # the guitar stem (render.amp_sim)

# The demo's power-chord roots (low E string range), extended for E major and the other Beefcake keys.
ROOT = {'E': 'E2', 'C': 'C2', 'D': 'D2', 'B': 'B1', 'G': 'G2', 'A': 'A2',
        'F#': 'F#2', 'C#': 'C#2', 'G#': 'G#1', 'F': 'F2', 'Bb': 'Bb1', 'Eb': 'Eb2', 'Ab': 'Ab1', 'Db': 'Db2'}

# The Gainlands progression (i - VI - VII - V) and the demo's heroic brass voicings.
PROG = ['E', 'C', 'D', 'B']
BRASS_HITS = {'E': ['E3', 'B3', 'E4', 'G4'], 'C': ['C3', 'G3', 'C4', 'E4'],
              'D': ['D3', 'A3', 'D4', 'F#4'], 'B': ['B2', 'F#3', 'B3', 'D#4'],
              # E major (FREED) and the other keys
              'Emaj': ['E3', 'B3', 'E4', 'G#4'], 'A': ['A2', 'E3', 'A3', 'C#4'], 'C#m': ['C#3', 'G#3', 'C#4', 'E4'],
              'G': ['G3', 'D4', 'G4', 'B4'], 'Am': ['A2', 'E3', 'A3', 'C4'], 'F#m': ['F#3', 'C#4', 'F#4', 'A4'],
              'G#m': ['G#2', 'D#3', 'G#3', 'B3'], 'F#': ['F#3', 'C#4', 'F#4', 'A#4'], 'Bm': ['B2', 'F#3', 'B3', 'D4'],
              'Cm': ['C3', 'G3', 'C4', 'Eb4'], 'Ab': ['Ab2', 'Eb3', 'Ab3', 'C4'], 'Bb': ['Bb2', 'F3', 'Bb3', 'D4'],
              'Gm': ['G2', 'D3', 'G3', 'Bb3'], 'Fm': ['F2', 'C3', 'F3', 'Ab3'], 'Eb': ['Eb3', 'Bb3', 'Eb4', 'G4'],
              'Dm': ['D3', 'A3', 'D4', 'F4'], 'F': ['F2', 'C3', 'F3', 'A3']}

# The Crossroads motif in E minor (E B A G F# B: q e e dq e dh) and the Gainlands answer phrase - the Gainlands theme since Nov 3.
MOTIF = [('E4', 1), ('B4', .5), ('A4', .5), ('G4', 1.5), ('F#4', .5), ('B4', 3), ('r', 1)]
MOTIF_RESOLVED = [('E4', 1), ('B4', .5), ('A4', .5), ('G#4', 1.5), ('F#4', .5), ('E4', 3), ('r', 1)]   # E major, falls home
ANSWER = [('G4', .5), ('A4', .5), ('B4', 1), ('D5', 1), ('E5', 1),
          ('F#5', 1.5), ('E5', .5), ('D5', 1), ('B4', 1)]
ANSWER_TAG = ANSWER[:6] + [('G5', 1), ('B5', 1.5)]          # the climbing ending of the second answer
ANSWER_MAJOR = [('G#4', .5), ('A4', .5), ('B4', 1), ('C#5', 1), ('E5', 1),
                ('F#5', 1.5), ('E5', .5), ('C#5', 1), ('B4', 1)]
# The breakdown lick (demo bars 32-39): the long lead-guitar line over E - C - D - B.
LICK = [('B4', 1), ('D5', .5), ('E5', .5), ('G5', 2), ('F#5', 1), ('E5', 1), ('D5', 1), ('B4', 1),
        ('C5', 1), ('E5', .5), ('G5', .5), ('A5', 2), ('G5', 1), ('E5', 1), ('C5', 2),
        ('D5', 1), ('F#5', .5), ('A5', .5), ('B5', 2), ('A5', 1), ('F#5', 1), ('D5', 2),
        ('D#5', 2), ('F#5', 2), ('B5', 4)]


def root(x):
    return p(ROOT[x]) if isinstance(x, str) and x in ROOT else p(x)


def transpose(mel, semis):
    return [(n if n == 'r' else (p(n) + semis), d) for n, d in mel]


def band(s, kit_vol=122, lead_vol=112, gtr_vol=110, brass=61, saw=81, pad=89, sub=38):
    """The demo's seating: double-tracked rhythm guitars hard L/R, lead centre, finger bass, synth sub, saw, pad, brass, GS power kit,
    timpani. Sets the rock render profile (guitar stem = GTR)."""
    s.add('gtrL', 0, 30, pan=20, rev=40, vol=gtr_vol)
    s.add('gtrR', 1, 30, pan=108, rev=40, vol=gtr_vol)
    s.add('lead', 2, 29, pan=64, rev=80, vol=lead_vol)
    s.add('bass', 3, 33, pan=64, rev=20, vol=118)
    s.add('sub', 4, sub, pan=64, rev=10, vol=108)
    s.add('saw', 5, saw, pan=54, rev=60, vol=78)
    s.add('pad', 6, pad, pan=64, rev=90, vol=72)
    s.add('brass', 7, brass, pan=74, rev=85, vol=96)
    s.channel('kit', 'power_kit', pan=64, reverb=50, vol=kit_vol, chan=9)
    s.add('timp', 8, 47, pan=64, rev=70, vol=92)
    s.profile = 'rock'
    s.stem = set(GTR)
    s.stack_drums = True
    return s


def power(r, octave_up=0):
    r = root(r) + 12 * octave_up
    return [r, r + 7, r + 12]


GALLOP = [(0, .5, 1), (.5, .25, 0), (.75, .25, 0), (1, .5, 0), (1.5, .5, 1),
          (2, .5, 1), (2.5, .25, 0), (2.75, .25, 0), (3, .5, 0), (3.5, .5, 1)]
STRAIGHT = [(i * .5, .5, 1 if i in (0, 3, 6) else 0) for i in range(8)]
# 'machine' (House of Gains): 16th chugs, accents on the press beats - a gym machine's reps
MACHINE = [(i * .25, .25, 1 if i in (0, 6, 8, 14) else 0) for i in range(16)]


def chug(s, bar, r, vel, pattern='gallop', chs=('gtrL', 'gtrR')):
    """Palm-muted chugs on the root with power-chord accents, doubled L/R (12 ms apart)."""
    hits = {'gallop': GALLOP, 'straight': STRAIGHT, 'machine': MACHINE}[pattern] if isinstance(pattern, str) else pattern
    rr = root(r)
    for t, d, acc in hits:
        notes = power(r) if acc else [rr, rr + 7]
        for ch, off in zip(chs, (0.0, 0.012)):
            s.chord(ch, s.B(bar, t) + off, d * (0.95 if acc else 0.45), notes, vel + (14 if acc else -6))


def sustain(s, bar, r, vel, beats=4, chs=('gtrL', 'gtrR')):
    for ch, off in zip(chs, (0.0, 0.015)):
        s.chord(ch, s.B(bar) + off, beats - 0.05, power(r), vel)


def bassline(s, bar, r, vel, style='8ths'):
    rr = root(r)
    if style == '8ths':
        for i in range(8):
            s.note('bass', s.B(bar, i * .5), .45, rr + (12 if i in (3, 7) else 0), vel + (8 if i % 2 == 0 else 0))
    elif style == 'gallop':
        for t, d, _ in GALLOP:
            s.note('bass', s.B(bar, t), d * .9, rr, vel)
    else:
        s.note('bass', s.B(bar), 3.9, rr, vel)


def subdrop(s, bar, r, vel):
    rr = root(r)
    for i in range(8):
        s.note('sub', s.B(bar, i * .5 + .25), .22, rr + 12, vel, human=False)
        s.note('sub', s.B(bar, i * .5), .2, rr, vel - 10, human=False)


def rock_beat(s, bar, vel, fill=False, half=False):
    for b in range(4):
        t = s.B(bar, b)
        if half:
            if b == 0:
                s.note('kit', t, .2, 36, vel, human=False)
            if b == 2:
                s.note('kit', t, .2, 38, vel, human=False)
        else:
            if b in (0, 2):
                s.note('kit', t, .2, 36, vel, human=False)
            if b == 2:
                s.note('kit', t + .5, .2, 36, vel - 14, human=False)
            if b in (1, 3):
                s.note('kit', t, .2, 38, vel, human=False)
        for e in (0, .5):
            s.note('kit', t + e, .1, 42, vel - 30 + (8 if e == 0 else 0), human=False)
    if fill:
        for i in range(8):
            s.note('kit', s.B(bar, 2) + i * .25, .2, [50, 48, 47, 45][i // 2], vel - 6 + i, human=False)


def double_kick(s, bar, vel):
    """Relentless 16th double kick under a backbeat (dungeon battle, boss)."""
    for k in range(16):
        s.note('kit', s.B(bar, k * .25), .1, 36, vel - (0 if k % 4 == 0 else 16), human=False)
    for b in (1, 3):
        s.note('kit', s.B(bar, b), .2, 38, vel, human=False)
    for b in range(4):
        s.note('kit', s.B(bar, b), .1, 51, vel - 34, human=False)     # ride


def four_floor(s, bar, vel):
    for b in range(4):
        t = s.B(bar, b)
        s.note('kit', t, .2, 36, vel, human=False)
        if b in (1, 3):
            s.note('kit', t, .2, 39, vel - 10, human=False)
            s.note('kit', t, .2, 38, vel - 20, human=False)
        s.note('kit', t + .5, .15, 46, vel - 24, human=False)
        for e in (.25, .75):
            s.note('kit', t + e, .1, 42, vel - 40, human=False)


def snare_roll(s, bar, bars, v0, v1):
    """8ths -> 16ths -> 32nds over `bars` bars, crescendo v0 -> v1."""
    t = s.B(bar)
    end = s.B(bar + bars)
    while t < end - 0.01:
        frac = (t - s.B(bar)) / (end - s.B(bar))
        s.note('kit', t, .1, 38, int(v0 + (v1 - v0) * frac), human=False)
        t += .5 if frac < .25 else (.25 if frac < .6 else .125)


def crash(s, bar, vel=110, beat=0.0):
    s.note('kit', s.B(bar, beat), 2, 49, vel, human=False)
    s.note('kit', s.B(bar, beat), .3, 36, vel, human=False)


def clank(s, bar, vel=70, beats=(1.5, 3.5)):
    """Gym clank: cowbell on the off-beats (the demo's breakdown)."""
    for i, b in enumerate(beats):
        s.note('kit', s.B(bar, b), .2, 56, vel - 10 * (i % 2), human=False)


def arp(s, bar, r, vel, up=24):
    """The intro saw arp: 16ths root-fifth-octave-fifth."""
    rr = root(r) + up
    for k in range(16):
        s.note('saw', s.B(bar, k * .25), .2, rr + [0, 7, 12, 7][k % 4], vel, human=False)


def kick_pulse(s, bar, vel):
    for b in range(4):
        s.note('kit', s.B(bar, b), .2, 36, vel, human=False)


def brass_hits(s, bar, c, vels=(92, 80), beats=(0, 2.5), durs=(.6, .4)):
    for b, v, d in zip(beats, vels, durs):
        s.chord('brass', s.B(bar, b), d, BRASS_HITS[c], v)


def pad_chord(s, bar, c, vel, beats=4):
    s.chord('pad', s.B(bar), beats, [p(n) + 12 for n in BRASS_HITS[c][1:]], vel)


def riser(s, bar, bars):
    """A white-noise riser from `bar` for `bars` bars (rendered by render.add_risers)."""
    s.risers.append((s.B(bar), bars * s.bar_q))
