"""MUS-NECRO-EXP - ported from the approved zone demo ZONE-DNA_demo_score.py (Music_Source/zone_demos, Oct 31). Notes unchanged;
only the loop seam is fixed (see PORT FIXES at the end).
"""
# Demo header: D.N.A. (Department of Necrotic Affairs) - zone main theme demo. Dark orchestral + organ, C minor, 3/4 dark waltz.
from lib import Song, p

S = Song('MUS-NECRO-EXP', bpm=100, bars=64, meter=(3, 4), key='C minor', seed=11)
S.add('organ', 0, 19, pan=64, rev=105, vol=86)        # Church organ
S.add('vln', 1, 48, pan=36, rev=100, vol=92)          # strings
S.add('trem', 2, 44, pan=50, rev=100, vol=78)         # tremolo strings
S.add('vc', 3, 42, pan=82, rev=90, vol=90)
S.add('cb', 4, 43, pan=92, rev=90, vol=94)
S.add('pizz', 5, 45, pan=74, rev=80, vol=84)
S.add('bsn', 6, 70, pan=70, rev=85, vol=88)           # bassoon
S.add('cl', 7, 71, pan=60, rev=85, vol=80)            # (bass) clarinet colour
S.add('hn', 8, 60, pan=78, rev=95, vol=92)
S.add('tbn', 10, 57, pan=88, rev=95, vol=86)
S.add('tuba', 11, 58, pan=90, rev=90, vol=84)
S.add('timp', 12, 47, pan=64, rev=80, vol=98)
S.add('choir', 13, 52, pan=64, rev=110, vol=74)       # choir aahs
S.add('celesta', 14, 8, pan=44, rev=100, vol=70)
S.add('hpsd', 15, 6, pan=30, rev=80, vol=66)          # harpsichord
S.add('kit', 9, 48, pan=64, rev=85, vol=84)           # orchestra kit (bank 128 auto on ch 10)

CH = {  # bass, voicing
    'Cm': ('C2', ['C3', 'G3', 'C4', 'Eb4']), 'Fm': ('F1', ['C3', 'F3', 'Ab3', 'C4']),
    'G7': ('G1', ['D3', 'F3', 'G3', 'B3']), 'Ab': ('Ab1', ['C3', 'Eb3', 'Ab3', 'C4']),
    'Db': ('Db2', ['Db3', 'F3', 'Ab3', 'Db4']), 'Cm/G': ('G1', ['C3', 'G3', 'C4', 'Eb4']),
    'Gs': ('G1', ['C3', 'D3', 'G3', 'C4']), 'Bdim': ('B1', ['D3', 'F3', 'Ab3', 'B3']),
    'Eb': ('Eb2', ['Eb3', 'G3', 'Bb3', 'Eb4']),
}
progA = ['Cm', 'Cm', 'Fm', 'Fm', 'G7', 'G7', 'Cm', 'Ab', 'Fm', 'Db', 'Cm/G', 'G7', 'Cm', 'Ab', 'G7', 'Cm']
themeA = [('G4', 1), ('C5', 1), ('Eb5', 1), ('D5', 2), ('C5', 1),
          ('Ab4', 1), ('C5', 1), ('F5', 1), ('Eb5', 2), ('C5', 1),
          ('B4', 1), ('D5', 1), ('F5', 1), ('Ab5', 2), ('G5', 1),
          ('Eb5', 1), ('D5', .5), ('C5', .5), ('G4', 1), ('C5', 3),
          ('F5', 1), ('Ab5', 1), ('G5', 1), ('F5', 2), ('Db5', 1),
          ('Eb5', 1), ('C5', 1), ('G4', 1), ('B4', 2), ('D5', 1),
          ('C5', 1), ('Eb5', 1), ('G5', 1), ('Ab5', 2), ('Eb5', 1),
          ('D5', 1), ('F5', 1), ('B4', 1), ('C5', 3)]
# Crossroads motif in C minor (C G F Eb D G), q e e dq e dh
motif = [('C5', 1), ('G5', .5), ('F5', .5), ('Eb5', 1.5), ('D5', .5), ('G5', 3)]


def waltz(bar, c, vel, pizz=True):
    b, v = CH[c]
    S.note('cb', S.B(bar), 1.6, p(b), vel)
    S.note('vc', S.B(bar), 1.6, p(b) + 12, vel - 8)
    if pizz:
        for beat in (1, 2):
            S.chord('pizz', S.B(bar, beat), 0.4, v[1:], vel - 10)


def organ(bar, c, vel, bars=1, pedal=True):
    b, v = CH[c]
    S.chord('organ', S.B(bar), 3 * bars + 0.05, v, vel)
    if pedal:
        S.note('organ', S.B(bar), 3 * bars + 0.05, p(b) + (12 if p(b) < p('C2') else 0), vel - 6)


def tick(bar, bars, vel=34):
    for i in range(bars * 3):
        S.note('kit', S.B(bar) + i, 0.2, 76 if i % 3 == 0 else 77, vel + (8 if i % 3 == 0 else 0), human=False)


form = (['Cm', 'Cm', 'Ab', 'G7']             # 0-3 intro
        + progA                              # 4-19 A
        + progA                              # 20-35 A'
        + ['Ab', 'Fm', 'Db', 'Gs', 'Ab', 'Fm', 'Db', 'G7']   # 36-43 B
        + progA                              # 44-59 climax
        + ['Cm', 'Ab', 'Fm', 'G7'])          # 60-63 outro
assert len(form) == 64

# INTRO: organ pedal, ticking clock, celesta tritone glints, low choir
for i in range(4):
    organ(i, form[i], 48, pedal=True)
tick(0, 4)
S.line('celesta', 1, [('F#6', 1), ('C6', 2)], 40)
S.line('celesta', 3, [('B5', 1), ('F5', 2)], 38)
S.ramp('organ', 0, 4, 74, 92)
S.line('bsn', 2, [('G2', 3), ('B1', 3)], 50)

# A: dark waltz - bassoon + clarinet state the D.N.A. theme, harpsichord shadows it
for i in range(16):
    bar = 4 + i
    waltz(bar, form[bar], 64)
    if i % 2 == 0:
        organ(bar, form[bar], 40, bars=2, pedal=False)
S.line('bsn', 4, themeA, 80, tr=-12)
S.line('cl', 4, themeA, 62, tr=-12)
S.line('hpsd', 12, themeA[20:], 50)
S.ramp('organ', 4, 16, 64, 84, 'arch')
tick(4, 8, 26)
S.note('timp', S.B(4), 1, p('C2'), 70)
S.note('timp', S.B(12), 1, p('C2'), 64)

# A': organ takes the theme, strings tremolo, choir, horns sound the Crossroads motif in minor
for i in range(16):
    bar = 20 + i
    waltz(bar, form[bar], 82)
    S.chord('trem', S.B(bar), 3.05, CH[form[bar]][1], 56)
    S.chord('choir', S.B(bar), 3.05, [p(n) + 12 for n in CH[form[bar]][1][1:]], 50)
S.line('organ', 20, themeA, 96)
S.line('organ', 20, themeA, 80, tr=-12)
S.line('vln', 28, themeA[20:], 70)
S.line('hn', 22, motif, 70, tr=-12)
S.line('hn', 30, motif, 74, tr=-12)
S.ramp('trem', 20, 16, 70, 110, 'arch')
S.ramp('choir', 20, 16, 60, 100, 'arch')
for bar in (20, 24, 28, 32):
    S.note('timp', S.B(bar), 1, p('C2') if form[bar] in ('Cm',) else p(CH[form[bar]][0]) + 12, 78)
for i in range(6):
    S.note('timp', S.B(35, 1) + i / 3, 0.2, p('G1'), 40 + i * 9, human=False)

# B: the eerie calm - music box/celesta plays the Crossroads motif over a held organ, string harmonics
for i in range(8):
    bar = 36 + i
    organ(bar, form[bar], 44)
    S.note('cb', S.B(bar), 3, p(CH[form[bar]][0]), 46)
tick(36, 8, 30)
S.line('celesta', 36, motif, 66, tr=12)
S.line('celesta', 40, motif, 62, tr=12)
S.line('vln', 38, [('Eb6', 6), ('Db6', 6)], 40)
S.line('vln', 42, [('C6', 3), ('B5', 3)], 42)
S.line('vc', 36, [('C4', 3), ('Ab3', 3), ('Db4', 3), ('B3', 3), ('C4', 3), ('Ab3', 3), ('Db4', 3), ('D4', 3)], 52)
S.ramp('vln', 36, 8, 50, 100)
for i in range(12):
    S.note('timp', S.B(43) + i / 4, 0.2, p('G1'), 34 + i * 7, human=False)
S.note('kit', S.B(43, 2), 1, 57, 40)

# CLIMAX: full dark tutti - organ, brass, choir, timpani; theme in octaves
for i in range(16):
    bar = 44 + i
    c = form[bar]
    b, v = CH[c]
    waltz(bar, c, 92)
    organ(bar, c, 74)
    S.chord('choir', S.B(bar), 3.05, [p(n) + 12 for n in v], 70)
    S.chord('trem', S.B(bar), 3.05, v, 66)
    S.note('tuba', S.B(bar), 1.4, p(b) + 12, 84)
    S.chord('tbn', S.B(bar, 1), 0.7, [p(v[1]), p(v[2])], 64)
    S.chord('tbn', S.B(bar, 2), 0.7, [p(v[1]), p(v[2])], 58)
    S.note('timp', S.B(bar), 1, p(b) + 12 if p(b) + 12 <= p('A2') else p(b), 92 if i % 4 == 0 else 72)
S.line('vln', 44, themeA, 104, tr=12)
S.line('vln', 44, themeA, 92)
S.line('hn', 44, themeA, 92)
S.line('organ', 44, themeA, 84, tr=12)
S.line('tbn', 52, [('C3', 6), ('Ab2', 6), ('Db3', 6), ('G2', 6)], 80)
S.line('hpsd', 44, themeA, 54, tr=12)
S.note('kit', S.B(44), 4, 49, 92)
S.note('kit', S.B(52), 4, 57, 76)
S.ramp('choir', 44, 16, 80, 120, 'arch')
S.ramp('trem', 44, 16, 90, 120, 'arch')

# OUTRO: thin back to organ + clock so the loop rolls into the intro
for i in range(4):
    organ(60 + i, form[60 + i], 52)
tick(60, 4, 30)
S.line('bsn', 60, [('C3', 3), ('Ab2', 3), ('F2', 3), ('G2', 3)], 54)
S.line('celesta', 62, [('B5', 1), ('F6', 2)], 40)
S.ramp('organ', 60, 4, 92, 74)


# ---------------------------------------------------------------- PORT FIXES (Music Pass 2)

def build():
    for bar, nm in ((0, 'intro'), (4, 'A waltz'), (20, "A' organ"), (36, 'B calm'), (44, 'climax'), (60, 'outro')):
        S.section(bar, nm)
    for bar, form, ch in ((22, 'stated (horns, low, minor)', 'hn'), (30, 'stated (horns, low, minor)', 'hn'),
                          (36, 'stated (celesta 8va, the calm)', 'celesta'), (40, 'stated (celesta 8va)', 'celesta')):
        S.motifs.append((bar, form, ch))
    for ch, a, b in (('bsn', 4, 20), ('organ', 20, 36), ('celesta', 36, 44), ('vln', 44, 60)):
        S.tag_melody(ch, a, b)
    # seam: the outro ended ~4 dB over the intro; let its last two bars settle to the intro's level
    S.fade_vel(62, 64, SEAM_END, ['organ', 'bsn', 'celesta', 'kit'])
    S.recc11('organ', 60, 64, 90, SEAM_CC)
    S.notes.append('Ported from the approved ZONE-DNA demo: notes unchanged, last two bars eased to the intro level for the loop seam.')
    return S


SEAM_END, SEAM_CC = 0.66, 60
