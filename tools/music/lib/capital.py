"""The CAPITAL THEME and Capital helpers (Music Pass 3, docs/audio/score_bible.md section 9).

The Capital's own melody, built from the Primm motif (theory.PRIMM_HEAD / PRIMM_ANSWER): bars 1 and 5 ARE the Primm cells (C E G C, C F A C),
every note on the grid, every phrase landing on a perfect cadence - a civic anthem with a too-wide smile. It appears in every Capital cue
(outskirts, facade, enforcer, correction, rift, castle; the tunnel boss), as the zone themes do in their zones. The Crossroads motif keeps
trying to break through it. Human feel only returns in MUS-CAP-RESTORED (and in the Crease and the tunnels, which are not the city's voice).

Melodies are (pitch, beats) lists in C major, 4/4; theory.transpose() moves them, zones.to_mode() re-spells them.
"""
from .theory import transpose  # noqa: F401  (re-exported for scores)

# 16 bars of 4/4 in C major. A = the Primm cells answered by a marching cadence; B = a square sequence falling by steps, then the climb home.
CAPITAL_THEME = [('C5', 1), ('E5', 1), ('G5', 1), ('C6', 1),              # 1  Primm head cell
                 ('B5', 1), ('A5', 1), ('G5', 2),                          # 2
                 ('A5', .5), ('G5', .5), ('F5', .5), ('E5', .5), ('D5', 1), ('G5', 1),   # 3
                 ('E5', 1), ('C5', 1), ('C5', 2),                          # 4  perfect cadence
                 ('C5', 1), ('F5', 1), ('A5', 1), ('C6', 1),               # 5  Primm answer cell
                 ('D6', 1), ('C6', 1), ('B5', 2),                          # 6
                 ('C6', .5), ('B5', .5), ('A5', .5), ('G5', .5), ('F5', 1), ('D5', 1),   # 7
                 ('G5', 1), ('B4', 1), ('C5', 2),                          # 8  perfect cadence
                 ('A5', 1), ('A5', 1), ('F5', 1), ('A5', 1),               # 9  B: the sequence
                 ('G5', 1), ('G5', 1), ('E5', 2),                          # 10
                 ('F5', 1), ('F5', 1), ('D5', 1), ('F5', 1),               # 11
                 ('E5', 1), ('E5', 1), ('C5', 2),                          # 12
                 ('D5', 1), ('E5', 1), ('F5', 1), ('G5', 1),               # 13 the climb
                 ('A5', 1), ('B5', 1), ('C6', 2),                          # 14
                 ('G5', 1), ('E5', 1), ('D5', 1), ('G4', 1),               # 15
                 ('C5', 4)]                                                # 16 home, exactly on time
CAPITAL_THEME_A = CAPITAL_THEME[:32]      # bars 1-8
CAPITAL_THEME_B = CAPITAL_THEME[32:]      # bars 9-16
CAPITAL_HEAD = CAPITAL_THEME[:7]          # bars 1-2 (C E G C B A G): the most recognisable cell
# One chord (or an even split, Score.parts) per bar.
CAPITAL_PROG = ['C', 'G', 'Dm G', 'C', 'F', 'G7', 'Am Dm', 'G7 C',
                'F', 'C', 'Dm', 'Am', 'Dm7 G', 'F G', 'G7', 'C']

# Programs for the Capital palette (instruments.GM names): music_box, harpsichord, glock, celesta, trumpet / trombone / tuba / brass
# (block chords), strings (rigid), orchestra-kit snare (rudiments), timpani. Score(..., human=(0, 0)) = quantised (human feel OFF).
QUANTISED = (0.0, 0)


def rudiment(s, ch, bar, kind, vel, beats=None):
    """A snare rudiment on the orchestra kit (theory.KIT 'snare' 38 / 'snare2' 40), quantised. kind: 'paradiddle' (RLRR LRLL, 16ths),
    'flam' (grace + main on each beat), 'drag' (two grace 32nds + main), 'roll' (32nds), 'march' (16th pickup to each half)."""
    q = s.bar_q
    t0 = bar * q
    span = beats or q
    if kind == 'paradiddle':
        acc = [1, 0, 0, 0, 1, 0, 0, 0]
        for i in range(int(span * 4)):
            s.note(ch, t0 + i * .25, .1, 38 if acc[i % 8] or i % 2 == 0 else 40, vel + (12 if acc[i % 8] else -6), human=False)
    elif kind == 'flam':
        for i in range(int(span)):
            s.note(ch, t0 + i - .04, .05, 40, vel - 24, human=False)
            s.note(ch, t0 + i, .1, 38, vel + (8 if i == 0 else 0), human=False)
    elif kind == 'drag':
        for i in range(int(span)):
            s.note(ch, t0 + i - .125, .05, 40, vel - 22, human=False)
            s.note(ch, t0 + i - .0625, .05, 40, vel - 22, human=False)
            s.note(ch, t0 + i, .1, 38, vel + (8 if i == 0 else 0), human=False)
    elif kind == 'roll':
        n = int(span * 8)
        for i in range(n):
            s.note(ch, t0 + i / 8, .06, 38, vel - 10 + 20 * i / n, human=False)
    elif kind == 'march':
        for h in range(int(span / 2)):
            b = t0 + h * 2
            for k, d in enumerate((0, .75)):
                s.note(ch, b + d, .1, 38, vel + (10 if k == 0 else -8), human=False)
            s.note(ch, b + 1, .1, 38, vel - 4, human=False)
            s.note(ch, b + 1.5, .1, 40, vel - 12, human=False)
    else:
        raise ValueError(kind)


def stumble(s, ch, bar, mel, vel, rush=0.82, wrong=1, beat=0.0):
    """An 'imperfect' burst: `mel` played rushed (durations x rush), humanised hard, one note `wrong` semitones off - the city's mask
    slipping for a moment. Returns the beat it ends on (snap back to the grid there)."""
    t = bar * s.bar_q + beat
    for i, (n, d) in enumerate(mel):
        if n != 'r':
            from .theory import p
            off = wrong if i == len(mel) // 2 else 0
            jit = s.rng.uniform(-.06, .06)
            s.events[ch].append((max(0, t + jit), d * rush * .9, p(n) + off, max(1, min(127, int(vel + s.rng.randint(-14, 14)))), None))
        t += d * rush
    return t
