"""The three approved ZONE THEMES (Music Pass 2, docs/audio/score_bible.md section 8).

Each zone's main melody, copied note for note from its approved demo (Music_Source/zone_demos, ported as MUS-NECRO-EXP / MUS-GOUR-EXP /
MUS-REF-EXP). Every cue of a zone quotes its theme (whole, a phrase, augmented, in minor/major, corrupted...); the Crossroads motif guests.
Melodies are (pitch, beats) lists in the demo's key; use theory.transpose() to move them. Chord maps are {symbol: (bass, voicing)}, the
demos' own voicings, ready for Score.V.
"""
from .theory import transpose  # noqa: F401  (re-exported for scores)

# ---------------------------------------------------------------- D.N.A. (Necrocrat): C minor, dark 3/4 waltz, 100 BPM
# 16 bars of 3/4: a rising minor arpeggio that leans on the sixth and keeps postponing its cadence (bars 4 and 16 land on C).
DNA_THEME = [('G4', 1), ('C5', 1), ('Eb5', 1), ('D5', 2), ('C5', 1),
             ('Ab4', 1), ('C5', 1), ('F5', 1), ('Eb5', 2), ('C5', 1),
             ('B4', 1), ('D5', 1), ('F5', 1), ('Ab5', 2), ('G5', 1),
             ('Eb5', 1), ('D5', .5), ('C5', .5), ('G4', 1), ('C5', 3),
             ('F5', 1), ('Ab5', 1), ('G5', 1), ('F5', 2), ('Db5', 1),
             ('Eb5', 1), ('C5', 1), ('G4', 1), ('B4', 2), ('D5', 1),
             ('C5', 1), ('Eb5', 1), ('G5', 1), ('Ab5', 2), ('Eb5', 1),
             ('D5', 1), ('F5', 1), ('B4', 1), ('C5', 3)]
DNA_THEME_A = DNA_THEME[:20]        # first 8 bars (the question)
DNA_THEME_B = DNA_THEME[20:]        # last 8 bars (the answer that arrives late)
DNA_PROG = ['Cm', 'Cm', 'Fm', 'Fm', 'G7', 'G7', 'Cm', 'Ab', 'Fm', 'Db', 'Cm/G', 'G7', 'Cm', 'Ab', 'G7', 'Cm']
DNA_CHORDS = {
    'Cm': ('C2', ['C3', 'G3', 'C4', 'Eb4']), 'Fm': ('F1', ['C3', 'F3', 'Ab3', 'C4']),
    'G7': ('G1', ['D3', 'F3', 'G3', 'B3']), 'Ab': ('Ab1', ['C3', 'Eb3', 'Ab3', 'C4']),
    'Db': ('Db2', ['Db3', 'F3', 'Ab3', 'Db4']), 'Cm/G': ('G1', ['C3', 'G3', 'C4', 'Eb4']),
    'Gs': ('G1', ['C3', 'D3', 'G3', 'C4']), 'Bdim': ('B1', ['D3', 'F3', 'Ab3', 'B3']),
    'Eb': ('Eb2', ['Eb3', 'G3', 'Bb3', 'Eb4']),
}
# Palette (GM programs as the demo): organ 19, strings 48, tremolo 44, cello 42, contrabass 43, pizz 45, bassoon 70, clarinet 71,
# horn 60, trombone 57, tuba 58, timpani 47, choir 52, celesta 8, harpsichord 6, orchestra kit (ch 10, prog 48): ticking clock =
# woodblocks 76 (accent) / 77, crash 57, timpani 41-53.
DNA_TICK_HI, DNA_TICK_LO = 76, 77

# ---------------------------------------------------------------- Endless Buffet (Gourmand): F major showtune + EDM drop, 132 BPM 4/4
# 16 bars: a bouncing "welcome" pickup figure (C A C F), a chromatic Broadway lift (F#), and a big held F. Original - quotes no song.
BUFFET_THEME = [('C5', .5), ('A4', .5), ('C5', .5), ('F5', 1), ('E5', .5), ('F5', 1),
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
BUFFET_THEME_A = BUFFET_THEME[:21]      # bars 1-4 (the welcome)
BUFFET_THEME_8 = BUFFET_THEME[:40]      # bars 1-8
BUFFET_HOOK = [('A5', .75), ('A5', .75), ('G5', .5), ('F5', 1), ('D5', 1),     # the drop hook (4 bars, over Dm Bb F C)
               ('D5', .75), ('F5', .75), ('Bb5', .5), ('A5', 1), ('F5', 1),
               ('C6', .75), ('A5', .75), ('F5', .5), ('G5', 1), ('A5', 1),
               ('G5', 1.5), ('E5', .5), ('C5', 2)]
BUFFET_PROG = ['F', 'Dm', 'Gm7', 'C7', 'F', 'D7', 'Gm', 'C7', 'Bb', 'Bbm', 'F/A', 'D7', 'Gm7', 'C7', 'F', 'C7']
BUFFET_DROP_PROG = ['Dm', 'Bb', 'F', 'C']
BUFFET_CHORDS = {
    'F': ('F2', ['A3', 'C4', 'F4']), 'Dm': ('D2', ['A3', 'D4', 'F4']), 'Gm7': ('G2', ['Bb3', 'D4', 'F4']),
    'C7': ('C2', ['Bb3', 'E4', 'G4']), 'D7': ('D2', ['A3', 'C4', 'F#4']), 'Gm': ('G2', ['Bb3', 'D4', 'G4']),
    'Bb': ('Bb1', ['Bb3', 'D4', 'F4']), 'Bbm': ('Bb1', ['Bb3', 'Db4', 'F4']), 'F/A': ('A1', ['A3', 'C4', 'F4']),
    'C': ('C2', ['G3', 'C4', 'E4']),
}
# Palette (GM as the demo): strings 48, pizz 45, clarinet 71, muted trumpet 59, brass 61, tuba 58 (oom-pah), glock 9, xylophone 13,
# horn 60, choir 52, piano 0, timpani 47; EDM layer: STANDARD kit (ch 10 prog 0: kick 36, clap 39, snare 38, closed hat 42, open hat 46,
# crash 49, triangle 81), synth bass 38, saw lead 81, warm pad 89 pumped with Song.pump(). No accordion/mandolin/folk here.

# ---------------------------------------------------------------- Verdant Dump (Refusemancer): E Dorian jig, 6/8 (dotted q = 116)
# 8 bars of running jig eighths (the A strain), repeated with a second-time ending; the fiddle's tune.
_E8 = .5
DUMP_JIG_1 = [(n, _E8) for n in ['E5', 'B4', 'E5', 'G5', 'F#5', 'E5', 'F#5', 'D5', 'A4', 'D5', 'E5', 'F#5',
                                 'G5', 'F#5', 'E5', 'B4', 'E5', 'G5', 'A5', 'G5', 'F#5', 'E5', 'C#5', 'A4',
                                 'B4', 'E5', 'G5', 'B5', 'A5', 'G5', 'F#5', 'A5', 'F#5', 'D5', 'E5', 'F#5',
                                 'G5', 'D5', 'B4', 'G4', 'B4', 'D5']] + [('E5', .5), ('C#5', .5), ('A4', .5), ('E5', 1.5)]
DUMP_JIG_2 = DUMP_JIG_1[:42] + [('B4', .5), ('D5', .5), ('F#5', .5), ('E5', 1.5)]
DUMP_THEME = DUMP_JIG_1 + DUMP_JIG_2       # 16 bars of 6/8
DUMP_JIG_HEAD = DUMP_JIG_1[:12]            # first 2 bars (E B E G F# E | F# D A D E F#): the most recognisable cell
DUMP_PROG = ['Em', 'D', 'Em', 'A', 'Em', 'D', 'G', 'A'] * 2
DUMP_CHORDS = {
    'Em': ('E2', ['E3', 'B3', 'E4', 'G4']), 'D': ('D2', ['D3', 'A3', 'D4', 'F#4']),
    'A': ('A1', ['E3', 'A3', 'C#4', 'E4']), 'G': ('G2', ['D3', 'G3', 'B3', 'D4']),
    'Bm': ('B1', ['F#3', 'B3', 'D4', 'F#4']), 'C': ('C2', ['C3', 'G3', 'C4', 'E4']),
}
# Palette (GM as the demo): solo violin 40 (the fiddle), strings 48, flute 73, piccolo 72, nylon guitar 24 (strummed), piano 0,
# harp 46, celesta 8, tubular bells 14 (chimes), glock 9, pizz 45, cello 42, contrabass 43, horn 60, timpani 47, orchestra kit
# (tambourine 54, triangle 81, crash 57). Folk instruments belong to the Dump ONLY.


def theme_in(mel, semis):
    """A zone theme moved by `semis` semitones (rests kept)."""
    return transpose(mel, semis)


def to_mode(mel, mapping):
    """Re-spell a theme into another mode by pitch class: mapping {pc_from: semitone shift}, e.g. {3: +1, 8: +1, 10: +1} turns C minor
    into C major (Eb->E, Ab->A, Bb->B). Used by FREED tracks (the theme in major) and bosses (the theme in minor)."""
    from .theory import p
    out = []
    for n, d in mel:
        if n == 'r':
            out.append((n, d))
            continue
        k = p(n)
        out.append((k + mapping.get(k % 12, 0), d))
    return out
