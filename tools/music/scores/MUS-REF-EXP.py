"""MUS-REF-EXP - ported from the approved zone demo ZONE-DUMP_demo_score.py (Music_Source/zone_demos, Oct 31). Notes unchanged;
only the loop seam is fixed (see PORT FIXES at the end).
"""
# Demo header: Verdant Dump - zone main theme demo. Fairy-folk orchestral jig, fast violin. E Dorian, 6/8 (dotted quarter = 116).
from lib import Song, p

S = Song('MUS-REF-EXP', bpm=174, bars=96, meter=(6, 8), key='E Dorian', seed=37)   # 6/8, dotted quarter = 116
S.jitter = 0.01
S.add('fid', 0, 40, pan=40, rev=85, vol=96)           # solo violin
S.add('vln', 1, 48, pan=36, rev=100, vol=86)
S.add('fl', 2, 73, pan=52, rev=90, vol=82)
S.add('picc', 3, 72, pan=48, rev=90, vol=64)
S.add('gtr', 4, 24, pan=70, rev=70, vol=84)           # nylon guitar
S.add('piano', 5, 0, pan=58, rev=85, vol=80)
S.add('harp', 6, 46, pan=46, rev=95, vol=80)
S.add('celesta', 7, 8, pan=44, rev=105, vol=72)
S.add('bells', 8, 14, pan=60, rev=110, vol=60)        # tubular bells (chimes)
S.add('kit', 9, 48, pan=64, rev=80, vol=86)           # orchestra kit: tambourine, triangle
S.add('pizz', 10, 45, pan=74, rev=80, vol=82)
S.add('vc', 11, 42, pan=82, rev=90, vol=88)
S.add('cb', 12, 43, pan=92, rev=90, vol=90)
S.add('hn', 13, 60, pan=78, rev=95, vol=86)
S.add('timp', 14, 47, pan=64, rev=80, vol=92)
S.add('glock', 15, 9, pan=40, rev=100, vol=62)

CH = {
    'Em': ('E2', ['E3', 'B3', 'E4', 'G4']), 'D': ('D2', ['D3', 'A3', 'D4', 'F#4']),
    'A': ('A1', ['E3', 'A3', 'C#4', 'E4']), 'G': ('G2', ['D3', 'G3', 'B3', 'D4']),
    'Bm': ('B1', ['F#3', 'B3', 'D4', 'F#4']), 'C': ('C2', ['C3', 'G3', 'C4', 'E4']),
}
progJ = ['Em', 'D', 'Em', 'A', 'Em', 'D', 'G', 'A'] * 2
E8 = .5
jig1 = [(n, E8) for n in ['E5', 'B4', 'E5', 'G5', 'F#5', 'E5', 'F#5', 'D5', 'A4', 'D5', 'E5', 'F#5',
                          'G5', 'F#5', 'E5', 'B4', 'E5', 'G5', 'A5', 'G5', 'F#5', 'E5', 'C#5', 'A4',
                          'B4', 'E5', 'G5', 'B5', 'A5', 'G5', 'F#5', 'A5', 'F#5', 'D5', 'E5', 'F#5',
                          'G5', 'D5', 'B4', 'G4', 'B4', 'D5']] + [('E5', .5), ('C#5', .5), ('A4', .5), ('E5', 1.5)]
jig2 = jig1[:42] + [('B4', .5), ('D5', .5), ('F#5', .5), ('E5', 1.5)]
theme = jig1 + jig2          # 16 bars
# fast variation: running eighths, higher
var = [(n, E8) for n in ['B5', 'G5', 'E5', 'G5', 'B5', 'E6', 'A5', 'F#5', 'D5', 'F#5', 'A5', 'D6',
                         'B5', 'G5', 'E5', 'B5', 'G5', 'E5', 'C#6', 'A5', 'E5', 'A5', 'C#6', 'E6',
                         'B5', 'G5', 'E5', 'G5', 'B5', 'E6', 'D6', 'A5', 'F#5', 'A5', 'D6', 'F#6',
                         'G6', 'D6', 'B5', 'D6', 'B5', 'G5', 'E6', 'C#6', 'A5', 'E6', 'C#6', 'A5']]
var = var + var[:42] + [('C#6', .5), ('A5', .5), ('F#5', .5), ('E5', 1.5)]
# Crossroads motif in E Dorian (E B A G F# B), stretched for the lyrical section (q e e dq e dh doubled)
motif_slow = [('E5', 2), ('B5', 1), ('A5', 1), ('G5', 3), ('F#5', 1), ('B5', 4), ('r', 0)]


def strum(bar, c, vel):
    v = CH[c][1]
    for e, accent in ((0, 1.0), (2, 0.6), (3, 0.85), (5, 0.6)):
        S.chord('gtr', S.B(bar, e * .5), 0.45, v, vel * accent, spread=0.02)


def bassline(bar, c, vel):
    b = p(CH[c][0])
    S.note('cb', S.B(bar), 1.4, b, vel)
    S.note('pizz', S.B(bar, 1.5), 0.5, b + 7 if c != 'A' else b + 12, vel - 10)


def tamb(bar, bars, vel=50):
    for i in range(bars):
        for e in range(6):
            S.note('kit', S.B(bar + i, e * .5), 0.2, 54, vel + (12 if e in (0, 3) else -6), human=False)


def fairy(bar, c, vel):
    tones = sorted(p(n) for n in CH[c][1]) + [p(n) + 12 for n in CH[c][1]]
    tones = sorted(tones)
    for i, t in enumerate(tones):
        S.note('celesta', S.B(bar) + i * 0.375, 1.2, t + 12, vel)
        S.note('harp', S.B(bar) + i * 0.375, 1.5, t, vel - 6)


form = (['Em', 'D', 'G', 'A', 'Em', 'D', 'G', 'A']         # 0-7 intro
        + progJ                                            # 8-23 A
        + progJ                                            # 24-39 A'
        + ['G', 'D', 'Em', 'A', 'G', 'D', 'C', 'A'] * 2    # 40-55 B (lyrical)
        + progJ                                            # 56-71 C fast variation
        + progJ                                            # 72-87 A'' tutti
        + ['Em', 'D', 'G', 'A', 'Em', 'D', 'G', 'A'])      # 88-95 outro
assert len(form) == 96

# INTRO: fairy glimmer, chimes, then the guitar starts the jig
for i in range(8):
    bar = i
    if i % 2 == 0:
        fairy(bar, form[bar], 50)
    if i >= 4:
        strum(bar, form[bar], 60)
        bassline(bar, form[bar], 56)
S.note('bells', S.B(0), 4, p('E5'), 56)
S.note('bells', S.B(4), 4, p('B4'), 50)
S.note('kit', S.B(0), 1, 81, 40)
S.line('fl', 6, [('B5', 1.5), ('A5', 1.5), ('G5', 1.5), ('A5', 1.5)], 54)

# A: the fiddle jig
for i in range(16):
    bar = 8 + i
    strum(bar, form[bar], 70)
    bassline(bar, form[bar], 70)
S.line('fid', 8, theme, 92, legato=0.88)
tamb(8, 16, 44)
S.chord('vln', S.B(8), 24, CH['Em'][1][:2], 36)

# A': violins tutti + flute an octave up, piano countermelody, horns pad
for i in range(16):
    bar = 24 + i
    c = form[bar]
    strum(bar, c, 74)
    bassline(bar, c, 78)
    S.chord('hn', S.B(bar), 3.02, CH[c][1][1:3], 50)
    # piano: off-beat chords like a dance band
    S.chord('piano', S.B(bar, .5), 0.4, [p(n) + 12 for n in CH[c][1][1:]], 54)
    S.chord('piano', S.B(bar, 2), 0.4, [p(n) + 12 for n in CH[c][1][1:]], 50)
S.line('fid', 24, theme, 96, legato=0.88)
S.line('vln', 24, theme, 84, legato=0.88)
S.line('fl', 24, theme, 70, tr=12, legato=0.85)
tamb(24, 16, 50)
S.note('timp', S.B(24), 1, p('E2'), 76)
S.note('timp', S.B(32), 1, p('E2'), 70)
S.note('glock', S.B(39, 1.5), 1.5, p('E6'), 60)

# B: lyrical - piano and flute, chimes, strings sweep; the Crossroads motif on flute
for i in range(16):
    bar = 40 + i
    c = form[bar]
    tones = sorted(p(n) for n in CH[c][1])
    for e, t in enumerate([tones[0], tones[1], tones[2], tones[3], tones[2], tones[1]]):
        S.note('piano', S.B(bar, e * .5), 0.9, t + 12, 52 + (8 if e == 0 else 0))
    S.note('cb', S.B(bar), 3, p(CH[c][0]), 54)
    S.chord('vln', S.B(bar), 3.02, CH[c][1], 46)
    if i % 4 == 0:
        S.note('bells', S.B(bar), 3, tones[-1] + 12, 50)
S.line('fl', 40, motif_slow, 76)
S.line('fid', 44, [('G5', 3), ('F#5', 1.5), ('E5', 1.5), ('A5', 3), ('C#5', 3)], 72)
S.line('fl', 48, motif_slow, 82)
S.line('fid', 48, [('B5', 3), ('A5', 1.5), ('G5', 1.5), ('E6', 3), ('C#6', 3), ('B5', 3), ('A5', 3), ('G5', 3), ('A5', 3)], 76)
S.ramp('vln', 40, 16, 60, 110)
for i in range(4):
    fairy(52 + i, form[52 + i], 52)
for i in range(12):
    S.note('timp', S.B(55) + i * 0.25, 0.2, p('A1'), 34 + i * 7, human=False)

# C: the fast fiddle variation, full orchestra
for i in range(16):
    bar = 56 + i
    c = form[bar]
    strum(bar, c, 78)
    bassline(bar, c, 84)
    S.chord('hn', S.B(bar), 3.02, CH[c][1][1:3], 60)
    S.chord('pizz', S.B(bar, 1), 0.3, CH[c][1][1:], 60)
    S.chord('pizz', S.B(bar, 2.5), 0.3, CH[c][1][1:], 56)
S.line('fid', 56, var, 100, legato=0.85)
S.line('vln', 56, theme, 78, legato=0.88)
S.line('glock', 64, var[:24], 52)
tamb(56, 16, 56)
for bar in (56, 60, 64, 68):
    S.note('timp', S.B(bar), 1, p('E2'), 82)
S.note('kit', S.B(56), 2, 49, 70)

# A'': tutti climax - everyone on the jig
for i in range(16):
    bar = 72 + i
    c = form[bar]
    strum(bar, c, 84)
    bassline(bar, c, 92)
    S.chord('hn', S.B(bar), 3.02, CH[c][1][1:], 72)
    S.note('vc', S.B(bar), 1.4, p(CH[c][0]) + 12, 80)
    S.chord('piano', S.B(bar, .5), 0.4, [p(n) + 12 for n in CH[c][1][1:]], 60)
    S.chord('piano', S.B(bar, 2), 0.4, [p(n) + 12 for n in CH[c][1][1:]], 56)
    S.note('timp', S.B(bar), 0.8, p('E2') if c == 'Em' else p(CH[c][0]) + (12 if p(CH[c][0]) < p('E2') else 0), 86 if i % 2 == 0 else 66)
S.line('fid', 72, theme, 104, legato=0.88)
S.line('vln', 72, theme, 96, tr=12, legato=0.88)
S.line('vln', 72, theme, 90, legato=0.88)
S.line('fl', 72, theme, 76, tr=12, legato=0.85)
S.line('picc', 80, theme[46:], 60, tr=12)
S.line('glock', 72, theme[:24], 56, tr=12)
tamb(72, 16, 62)
S.note('kit', S.B(72), 3, 49, 90)
S.note('bells', S.B(72), 3, p('E5'), 70)
S.note('bells', S.B(80), 3, p('B4'), 66)

# OUTRO: fairy glimmer, guitar keeps the pulse into the loop
for i in range(8):
    bar = 88 + i
    if i % 2 == 0:
        fairy(bar, form[bar], 50)
    strum(bar, form[bar], 62)
    bassline(bar, form[bar], 60)
S.line('fl', 92, [('B5', 1.5), ('A5', 1.5), ('G5', 1.5), ('A5', 1.5)], 52)


# ---------------------------------------------------------------- PORT FIXES (Music Pass 2)

def build():
    for bar, nm in ((0, 'intro glimmer'), (8, 'A jig'), (24, "A' tutti"), (40, 'B lyrical'), (56, 'C fast variation'),
                    (72, "A'' climax"), (88, 'outro')):
        S.section(bar, nm)
    for bar, form, ch in ((40, 'augmented (flute, E Dorian)', 'fl'), (48, 'augmented (flute)', 'fl')):
        S.motifs.append((bar, form, ch))
    for ch, a, b in (('fid', 8, 40), ('fl', 40, 56), ('fid', 56, 88)):
        S.tag_melody(ch, a, b)
    # seam: the guitar pulse ended ~2.3 dB over the fairy-glimmer intro; let it fall away into the glimmer
    S.fade_vel(92, 96, SEAM_END, ['gtr', 'cb', 'pizz', 'fl'])
    S.notes.append('Ported from the approved ZONE-DUMP demo: notes unchanged, the last bars of guitar eased into the intro glimmer.')
    return S


SEAM_END = 0.8
