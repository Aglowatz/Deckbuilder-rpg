"""MUS-GOUR-EXP - ported from the approved zone demo ZONE-BUFFET_demo_score.py (Music_Source/zone_demos, Oct 31). Notes unchanged;
only the loop seam is fixed (see PORT FIXES at the end).
"""
# Demo header: Endless Buffet - zone main theme demo. Festive Broadway/Disney showtune + modern EDM drop. F major, 132 BPM.
from lib import Song, p

S = Song('MUS-GOUR-EXP', bpm=132, bars=64, meter=(4, 4), key='F major', seed=23)
S.jitter = 0.012
S.add('vln', 0, 48, pan=36, rev=95, vol=92)
S.add('pizz', 1, 45, pan=74, rev=75, vol=84)
S.add('cl', 2, 71, pan=60, rev=80, vol=84)
S.add('mtpt', 3, 59, pan=56, rev=85, vol=84)          # muted trumpet
S.add('brass', 4, 61, pan=70, rev=90, vol=92)         # brass section
S.add('tuba', 5, 58, pan=88, rev=85, vol=88)
S.add('glock', 6, 9, pan=44, rev=95, vol=70)
S.add('xylo', 7, 13, pan=52, rev=80, vol=72)
S.add('kit', 9, 0, pan=64, rev=60, vol=96)            # standard kit for the modern drums
S.add('sbass', 10, 38, pan=64, rev=30, vol=96)        # synth bass 1
S.add('lead', 11, 81, pan=60, rev=70, vol=74)         # saw lead
S.add('spad', 12, 89, pan=64, rev=90, vol=80)         # warm pad (pumped)
S.add('hn', 13, 60, pan=78, rev=95, vol=88)
S.add('choir', 14, 52, pan=64, rev=105, vol=70)
S.add('piano', 15, 0, pan=58, rev=85, vol=78)
S.add('timp', 8, 47, pan=64, rev=80, vol=90)

CH = {
    'F': ('F2', ['A3', 'C4', 'F4']), 'Dm': ('D2', ['A3', 'D4', 'F4']), 'Gm7': ('G2', ['Bb3', 'D4', 'F4']),
    'C7': ('C2', ['Bb3', 'E4', 'G4']), 'D7': ('D2', ['A3', 'C4', 'F#4']), 'Gm': ('G2', ['Bb3', 'D4', 'G4']),
    'Bb': ('Bb1', ['Bb3', 'D4', 'F4']), 'Bbm': ('Bb1', ['Bb3', 'Db4', 'F4']), 'F/A': ('A1', ['A3', 'C4', 'F4']),
    'C': ('C2', ['G3', 'C4', 'E4']),
}
prog = ['F', 'Dm', 'Gm7', 'C7', 'F', 'D7', 'Gm', 'C7', 'Bb', 'Bbm', 'F/A', 'D7', 'Gm7', 'C7', 'F', 'C7']
theme = [('C5', .5), ('A4', .5), ('C5', .5), ('F5', 1), ('E5', .5), ('F5', 1),
         ('D5', .5), ('C5', .5), ('A4', 1), ('F4', 1), ('A4', 1),
         ('Bb4', .5), ('A4', .5), ('Bb4', .5), ('D5', 1), ('C5', .5), ('Bb4', 1),
         ('A4', 1), ('G4', 1), ('E4', 1), ('G4', 1),
         ('C5', .5), ('A4', .5), ('C5', .5), ('F5', 1), ('E5', .5), ('F5', 1),
         ('F#5', 1), ('D5', .5), ('E5', .5), ('F#5', 1), ('A5', 1),
         ('G5', 1.5), ('F5', .5), ('D5', 1), ('Bb4', 1),
         ('C5', 1), ('D5', .5), ('E5', .5), ('G5', 2),
         ('F5', 1), ('D5', .5), ('F5', .5), ('Bb5', 2),
         ('F5', 2), ('Db5', 2),
         ('C5', 1), ('A4', .5), ('C5', .5), ('F5', 2),
         ('F#5', 1), ('E5', .5), ('D5', .5), ('C5', 2),
         ('Bb4', 1), ('D5', 1), ('F5', 1), ('E5', 1),
         ('G5', 2), ('E5', 1), ('C5', 1),
         ('F5', 3), ('r', 1),
         ('r', 4)]
fill = [(n, .5) for n in ['C5', 'D5', 'E5', 'F5', 'G5', 'A5', 'Bb5', 'B5']]
motif = [('F5', 1), ('C6', .5), ('Bb5', .5), ('A5', 1.5), ('G5', .5), ('C6', 3), ('r', 1)]   # Crossroads in F major


def oompah(bar, c, vel):
    b, v = CH[c]
    root = p(b)
    fifth = root + 7
    S.note('tuba', S.B(bar, 0), 0.8, root, vel)
    S.note('tuba', S.B(bar, 2), 0.8, fifth if c not in ('C7', 'D7') else root, vel - 8)
    for beat in (1, 3):
        S.chord('pizz', S.B(bar, beat), 0.4, v, vel - 12)


def stabs(bar, c, vel):
    for beat in (1.5, 3.5):
        S.chord('brass', S.B(bar, beat), 0.35, CH[c][1], vel)


def drums(bar, bars, kick=True, clap=True, hats=True, vel=90):
    for b in range(bars):
        for beat in range(4):
            t = S.B(bar + b, beat)
            if kick:
                S.note('kit', t, 0.25, 36, vel, human=False)
            if clap and beat in (1, 3):
                S.note('kit', t, 0.25, 39, vel - 14, human=False)
                S.note('kit', t, 0.25, 38, vel - 34, human=False)
            if hats:
                S.note('kit', t + 0.5, 0.2, 46, vel - 32, human=False)
                S.note('kit', t, 0.1, 42, vel - 44, human=False)


# INTRO 0-3: sparkle, dinner bell, cymbal swell, "ta-da!" brass
for i in range(4):
    S.line('glock', i, [(n, .5) for n in ['F5', 'A5', 'C6', 'F6', 'C6', 'A5', 'F5', 'C5']], 54, arc=False)
    S.chord('pizz', S.B(i), 0.4, CH['F'][1], 50)
    oompah(i, ['F', 'Dm', 'Gm7', 'C7'][i], 58)
S.note('kit', S.B(0), 0.5, 81, 70)
S.note('kit', S.B(2), 0.5, 81, 64)
for i in range(16):
    S.note('timp', S.B(2) + i * 0.5, 0.3, p('C2'), 30 + i * 4, human=False)
S.chord('brass', S.B(3, 3), 0.9, ['C4', 'E4', 'G4', 'Bb4'], 96)
S.note('kit', S.B(3, 3), 1, 49, 80)

# A 4-19: showtune verse - clarinet + muted trumpet sing the Buffet theme, oom-pah under
for i in range(16):
    bar = 4 + i
    oompah(bar, prog[i], 72)
S.line('cl', 4, theme, 82)
S.line('mtpt', 4, theme[:21], 70, tr=-12)
S.line('mtpt', 12, theme[40:], 72)
S.line('xylo', 10, [('F5', .5), ('A5', .5), ('C6', 1), ('r', 2)], 60)
S.line('brass', 19, fill, 84, arc=False)
S.note('kit', S.B(4), 1, 81, 54)
S.note('kit', S.B(12), 1, 81, 54)

# A' 20-35: big band + orchestra - strings take the tune in octaves, brass off-beat punches, kick sneaks in
for i in range(16):
    bar = 20 + i
    oompah(bar, prog[i], 84)
    stabs(bar, prog[i], 74)
    S.chord('choir', S.B(bar), 4.05, [p(n) for n in CH[prog[i]][1]], 40)
S.line('vln', 20, theme, 96, tr=12)
S.line('vln', 20, theme, 84)
S.line('glock', 20, theme[:21], 54, tr=12)
S.line('hn', 24, motif, 72, tr=-12)
S.line('hn', 32, [('A4', 4), ('Bb4', 4), ('A4', 2), ('G4', 2)], 70)
drums(20, 16, hats=False, clap=True, vel=70)
S.note('kit', S.B(20), 2, 49, 76)
for i in range(8):
    S.note('kit', S.B(35, 2) + i * 0.25, 0.2, 38, 50 + i * 8, human=False)   # snare build

# B 36-51: THE DROP - four-on-the-floor, pumping pad, synth bass, saw lead on the hook + Crossroads motif, orchestra hits
drop = ['Dm', 'Bb', 'F', 'C'] * 4
for i, c in enumerate(drop):
    bar = 36 + i
    b, v = CH[c]
    S.chord('spad', S.B(bar), 4.05, [p(n) for n in v] + [p(v[0]) + 12], 80)
    for beat in range(4):
        S.note('sbass', S.B(bar, beat + 0.5), 0.4, p(b) + 12, 96, human=False)
        S.note('sbass', S.B(bar, beat), 0.2, p(b), 80, human=False)
    if i % 2 == 0:
        S.chord('brass', S.B(bar), 0.6, [p(n) - 12 for n in v] + [p(n) for n in v], 96)
        S.note('timp', S.B(bar), 0.8, p(b) + 12 if p(b) + 12 <= p('A2') else p(b), 90)
    S.chord('pizz', S.B(bar, 1), 0.3, v, 70)
    S.chord('pizz', S.B(bar, 3), 0.3, v, 70)
S.pump('spad', 36, 16, lo=30, hi=112)
drums(36, 16, vel=100)
hook = [('A5', .75), ('A5', .75), ('G5', .5), ('F5', 1), ('D5', 1),
        ('D5', .75), ('F5', .75), ('Bb5', .5), ('A5', 1), ('F5', 1),
        ('C6', .75), ('A5', .75), ('F5', .5), ('G5', 1), ('A5', 1),
        ('G5', 1.5), ('E5', .5), ('C5', 2)]
S.line('lead', 36, hook, 84, legato=0.85)
S.line('lead', 40, motif, 84, legato=0.9)
S.line('lead', 44, hook, 88, legato=0.85)
S.line('vln', 44, hook, 80, tr=-12)
S.line('lead', 48, motif, 90, legato=0.9)
S.line('vln', 48, motif, 90)
S.line('glock', 48, motif, 60, tr=12)
S.note('kit', S.B(36), 3, 49, 96)
S.note('kit', S.B(44), 3, 49, 90)
for i in range(16):
    S.note('kit', S.B(51) + i * 0.25, 0.2, 38, 46 + i * 5, human=False)

# FINALE 52-59: grand showtune tutti with the kick still under it
for i in range(8):
    bar = 52 + i
    oompah(bar, prog[i], 94)
    stabs(bar, prog[i], 86)
    S.chord('choir', S.B(bar), 4.05, [p(n) + 12 for n in CH[prog[i]][1]], 66)
S.line('vln', 52, theme[:40], 108, tr=12)
S.line('brass', 52, theme[:40], 96)
S.line('glock', 52, theme[:40], 64, tr=12)
S.line('piano', 52, theme[:40], 70, tr=12)
drums(52, 8, hats=True, vel=86)
S.note('kit', S.B(52), 3, 49, 100)
S.chord('brass', S.B(59, 2), 1.5, ['C4', 'E4', 'G4', 'Bb4', 'C5'], 100)
S.note('timp', S.B(59, 2), 1, p('C2'), 100)

# OUTRO 60-63: back to the sparkle + oom-pah so it loops into the intro
for i in range(4):
    S.line('glock', 60 + i, [(n, .5) for n in ['F5', 'A5', 'C6', 'F6', 'C6', 'A5', 'F5', 'C5']], 52, arc=False)
    oompah(60 + i, ['F', 'Dm', 'Gm7', 'C7'][i], 56)
S.line('cl', 60, [('A4', 2), ('C5', 2), ('D5', 2), ('F5', 2), ('Bb4', 2), ('D5', 2), ('E5', 2), ('G5', 2)], 52)


# ---------------------------------------------------------------- PORT FIXES (Music Pass 2)

def build():
    for bar, nm in ((0, 'intro'), (4, 'A verse'), (20, "A' big band"), (36, 'drop'), (52, 'finale'), (60, 'outro')):
        S.section(bar, nm)
    for bar, form, ch in ((24, 'stated (horns, F major)', 'hn'), (40, 'stated (saw lead, the drop)', 'lead'),
                          (48, 'stated (saw lead + violins + glock)', 'lead')):
        S.motifs.append((bar, form, ch))
    for ch, a, b in (('cl', 4, 20), ('vln', 20, 36), ('lead', 36, 52), ('vln', 52, 60)):
        S.tag_melody(ch, a, b)
    # seam: the outro ended ~2.6 dB over the intro
    S.fade_vel(62, 64, SEAM_END)
    S.notes.append('Ported from the approved ZONE-BUFFET demo: notes unchanged, last two bars eased for the loop seam.')
    return S


SEAM_END = 0.8
