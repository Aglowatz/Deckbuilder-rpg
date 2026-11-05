"""Shared helpers for the Music Pass 3 Primm / ending / story scores (composer fork B).

Theme copies (so a score does not import another score module): the Crosspath theme (MUS-TOWN melA/melB, D Dorian) and the Gainlands theme
(MUS-BEEF-EXP THEME, Bb major). Everything else comes from lib (theory, zones, capital).
"""
from lib import p, m, voice, transpose, augment, length, REST
from lib.capital import QUANTISED  # noqa: F401

# Crosspath (MUS-TOWN), D Dorian, 8 bars each
CROSSPATH_A = [('D4', 1), ('A4', .5), ('G4', .5), ('F4', 1.5), ('E4', .5), ('A4', 3), ('r', 1),
               ('F4', 1), ('G4', .5), ('A4', .5), ('C5', 1), ('Bb4', .5), ('A4', .5), ('G4', 2), ('E4', 1), ('A4', 1),
               ('D5', 1), ('C5', .5), ('Bb4', .5), ('A4', 1.5), ('G4', .5), ('A4', 2), ('C5', 1), ('F5', 1),
               ('E5', 1), ('D5', .5), ('C5', .5), ('Bb4', 1), ('D5', 1), ('E5', 1), ('C#5', 1), ('A4', 2)]
CROSSPATH_PROG = ['Dm', 'G', 'Dm/F', 'A7sus4', 'Bb', 'F', 'Gm', 'A']

# Gainlands (MUS-BEEF-EXP THEME), Bb major, 16 bars
# Overnight Nov 4-5 (Part 6): the Gainlands theme is the ROCK riff and answer now (lib/rock.py MOTIF_RESOLVED / ANSWER_MAJOR, Nov 3), up a
# tritone into the old march's Bb major and its 16 bars (GAIN_H): riff, answer, riff to the fifth, climbing answer; riff, answer, the riff
# in Ab, cadence. Every quote below keeps its key, length and instruments; only the tune is the rock one.
GAIN_THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | Bb4:3 r:1 '
               '| D5:.5 Eb5:.5 F5:1 G5:1 Bb5:1 | C6:1.5 Bb5:.5 G5:1 F5:1 '
               '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:3 r:1 '
               '| D5:.5 Eb5:.5 F5:1 G5:1 Bb5:1 | C6:1.5 D6:.5 Bb5:2 '
               '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | Bb4:3 r:1 '
               '| D5:.5 Eb5:.5 F5:1 G5:1 Bb5:1 | C6:1.5 Bb5:.5 G5:1 F5:1 '
               '| Ab4:1 Eb5:.5 Db5:.5 C5:1.5 Bb4:.5 | Ab4:3 r:1 '
               '| C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
GAIN_H = ['Bb', 'Bb', 'Cm7', 'F', 'Eb', 'Gm', 'F', 'Bb', 'Bb', 'F', 'Eb', 'F', 'Ab', 'Eb', 'F7', 'Bb']

# C minor -> C major, E Dorian -> E major (zones.to_mode maps)
MAJ_FROM_CMIN = {3: 1, 8: 1, 10: 1}
MAJ_FROM_EDOR = {7: 1, 2: 1}


def cut(mel, beats):
    """The first `beats` beats of a melody (a note crossing the cut is shortened)."""
    out, pos = [], 0.0
    for n, d in mel:
        if pos >= beats - 1e-6:
            break
        out.append((n, min(d, beats - pos)))
        pos += d
    return out


def even(mel, d=1.0):
    """The same pitches, every note the same length (Primm's grid)."""
    return [(n, d) for n, d0 in mel if n != REST]


def scale(mel, f):
    return [(n, d * f) for n, d in mel]


def stack(s, parts, bar, mel, vel, beat=0.0, lead=True, form=None, legato=0.96):
    """Unison/octave doubling: parts = [(channel, transpose, vel_offset)]. The first part is the lead (logged as a motif if `form`)."""
    for i, (ch, tr, dv) in enumerate(parts):
        if i == 0 and form:
            s.motif(ch, bar, mel, vel + dv, form=form, transpose=tr, beat=beat, legato=legato, lead=lead)
        elif i == 0 and lead:
            s.mel(ch, bar, mel, vel + dv, transpose=tr, beat=beat, legato=legato)
        else:
            s.line(ch, bar, mel, vel + dv, transpose=tr, beat=beat, legato=legato)


def bed(s, bar, spec, vel, pad='pad', bass='whole', chs=('cb', 'vc'), low='C3', n=4, harp=None, pad_oct=0):
    """Pad chord(s) for one bar (spec may split the bar: 'F G') + bass."""
    q = s.bar_q
    for off, beats, sym in s.parts(spec):
        if pad:
            s.pad(pad, bar, sym, vel, beats=beats, beat=off, low=low, n=n, octave=pad_oct)
        if harp:
            s.harp(bar, sym, harp, beats=beats, beat=off)
        if bass == 'whole' or len(spec.split()) > 1:
            s.bass_at(bar * q + off, beats, sym, vel + 4, chs=chs)
    if bass != 'whole' and len(spec.split()) == 1 and bass:
        s.bass(bar, spec, vel + 4, bass, chs=chs)


def held(s, bar, sym, beats, vel, chs, low='F3', n=4):
    """A held final chord across several channels (one-shot endings)."""
    for ch in chs:
        for t in voice(sym, low, n):
            s.note(ch, bar * s.bar_q, beats, t, vel)


def first_four_lullaby(tonic_semis=0, durs=(1, 1, 1, 1)):
    """The lullaby's first four notes ONLY (D A F E), moved by `tonic_semis`: the most a pre-reveal cue may quote, once."""
    return [(p(n) + tonic_semis, d) for n, d in zip(['D4', 'A4', 'F4', 'E4'], durs)]


# ---------------------------------------------------------------- the whole lullaby (after the reveal only: MEM-04, THRONE, REUNION, CREDITS)
from lib import LULLABY_HEAD, LULLABY_ANSWER  # noqa: E402
LULLABY = LULLABY_HEAD + LULLABY_ANSWER[:-1] + [('E4', 3)]     # 20 beats (the last E held one beat longer to fill 5 bars), D Dorian colour
# (beat, beats, chord) under the lullaby in D; the phrase ends on A (the dominant), ready for a cadence
LULLABY_CHORDS = [(0, 4, 'Dm'), (4, 3, 'A'), (7, 2, 'Em7'), (9, 4, 'Dm'), (13, 2, 'C'), (15, 2, 'G'), (17, 3, 'A')]
_PCS = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
_NAT = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}


def tchord(sym, semis):
    """Transpose a chord symbol ('F#m7', 'Bb/D') by `semis` semitones."""
    def one(x):
        r = _NAT[x[0]]
        i = 1
        while i < len(x) and x[i] in '#b':
            r += 1 if x[i] == '#' else -1
            i += 1
        return _PCS[(r + semis) % 12] + x[i:]
    if '/' in sym:
        a, b = sym.split('/')
        return one(a) + '/' + one(b)
    return one(sym)


def lullaby_bed(s, beat0, semis, vel, pad='pad', harp=None, chs=('cb', 'vc'), stretch=1.0, low='C3'):
    """Pads + bass (+ harp) under one statement of the whole lullaby starting at absolute beat `beat0`."""
    for b, d, sym in LULLABY_CHORDS:
        c = tchord(sym, semis)
        st, du = beat0 + b * stretch, d * stretch
        s.pad(pad, 0, c, vel, beats=du, beat=st, low=low)
        s.bass_at(st, du, c, vel + 2, chs=chs)
        if harp:
            s.harp(0, c, harp, beats=du, beat=st)
