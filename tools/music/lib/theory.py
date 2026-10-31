"""Pitches, scales, chords and the game's motifs (docs/audio/score_bible.md).

A pitch is a MIDI number or a name like 'D4', 'Bb1', 'C#5' (C4 = 60). A melody is a list of (pitch, beats) pairs; 'r' is a rest.
Beats are quarter notes everywhere, whatever the meter.
"""

NAMES = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
SHARP_NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
REST = 'r'

# GS orchestra kit (bank 128 program 48) as FluidR3_GM maps it. NB: 41-53 are timpani in this kit, NOT the GM toms/crash on 49.
KIT = {
    'stick': 31, 'click': 33, 'bd': 36, 'bd2': 35, 'rim': 37, 'snare': 38, 'snare2': 40, 'clap': 39,
    'tamb': 54, 'splash': 55, 'cowbell': 56, 'crash': 57, 'crash2': 59, 'vibraslap': 58,
    'bongo_rim': 60, 'hihat': 42, 'cym_roll': 57,
}


def p(n):
    """'D4' -> 62. Ints pass through."""
    if isinstance(n, int):
        return n
    acc = 0
    name = n[0]
    rest = n[1:]
    while rest and rest[0] in '#b':
        acc += 1 if rest[0] == '#' else -1
        rest = rest[1:]
    return 12 * (int(rest) + 1) + NAMES[name] + acc


def name(m):
    return f'{SHARP_NAMES[m % 12]}{m // 12 - 1}'


# ---------------------------------------------------------------- scales
MODES = {
    'major': [0, 2, 4, 5, 7, 9, 11], 'ionian': [0, 2, 4, 5, 7, 9, 11],
    'dorian': [0, 2, 3, 5, 7, 9, 10], 'phrygian': [0, 1, 3, 5, 7, 8, 10],
    'lydian': [0, 2, 4, 6, 7, 9, 11], 'mixolydian': [0, 2, 4, 5, 7, 9, 10],
    'minor': [0, 2, 3, 5, 7, 8, 10], 'aeolian': [0, 2, 3, 5, 7, 8, 10],
    'harmonic': [0, 2, 3, 5, 7, 8, 11], 'locrian': [0, 1, 3, 5, 6, 8, 10],
}


class Scale:
    """Scale('D3', 'dorian').deg(4) -> A3; negative and >6 degrees wrap octaves."""

    def __init__(self, tonic, mode='major'):
        self.tonic = p(tonic)
        self.mode = mode
        self.steps = MODES[mode]

    def deg(self, d, octave=0):
        o, i = divmod(d, 7)
        return self.tonic + 12 * (o + octave) + self.steps[i]

    def degree_of(self, pitch):
        """Nearest scale degree index at or below `pitch` (for runs)."""
        pitch = p(pitch)
        best = None
        for d in range(-21, 36):
            if self.deg(d) <= pitch:
                best = d
        return best

    def run(self, start, end, ):
        """Scale tones from `start` to `end` inclusive (either direction)."""
        a, b = self.degree_of(start), self.degree_of(end)
        step = 1 if b >= a else -1
        return [self.deg(d) for d in range(a, b + step, step)]


# ---------------------------------------------------------------- chords
QUALITIES = {
    '': [0, 4, 7], 'm': [0, 3, 7], 'dim': [0, 3, 6], 'aug': [0, 4, 8], '5': [0, 7],
    '7': [0, 4, 7, 10], 'maj7': [0, 4, 7, 11], 'm7': [0, 3, 7, 10], 'm7b5': [0, 3, 6, 10], 'dim7': [0, 3, 6, 9],
    'mMaj7': [0, 3, 7, 11], '6': [0, 4, 7, 9], 'm6': [0, 3, 7, 9], 'sus2': [0, 2, 7], 'sus4': [0, 5, 7],
    '7sus4': [0, 5, 7, 10], 'add9': [0, 4, 7, 14], 'madd9': [0, 3, 7, 14], '9': [0, 4, 7, 10, 14],
    'maj9': [0, 4, 7, 11, 14], 'm9': [0, 3, 7, 10, 14], '6/9': [0, 4, 7, 9, 14],
}


def parse_chord(sym):
    """'Bbmaj7/D' -> (root pc, intervals, bass pc or None)."""
    bass = None
    if '/' in sym and not sym.endswith('6/9'):
        sym, b = sym.split('/')
        bass = (NAMES[b[0]] + b[1:].count('#') - b[1:].count('b')) % 12
    root = NAMES[sym[0]]
    i = 1
    while i < len(sym) and sym[i] in '#b':
        root += 1 if sym[i] == '#' else -1
        i += 1
    q = sym[i:]
    if q not in QUALITIES:
        raise ValueError(f'unknown chord quality {q!r} in {sym!r}')
    return root % 12, QUALITIES[q], bass


def voice(sym, low='C3', n=4, spread=False):
    """Close voicing of `sym` with its lowest tone at or above `low`; `n` tones (root doubled on top when short).
    spread=True opens it (drops the 2nd voice an octave) for a wider string/brass sound."""
    root, ints, _ = parse_chord(sym)
    lo = p(low)
    base = lo + ((root - lo) % 12)
    tones = sorted(base + i for i in ints)
    # rotate so the lowest tone sits just above `low`
    while tones[0] - 12 >= lo:
        tones = [t - 12 for t in tones]
    out = [t for t in tones]
    k = 0
    while len(out) < n:
        out.append(tones[k % len(tones)] + 12 * (1 + k // len(tones)))
        k += 1
    out = sorted(out[:n])
    if spread and len(out) >= 3:
        out[1] -= 12
        out = sorted(out)
    return out


def bass_note(sym, low='F#1'):
    """The chord's bass (slash bass if given) in the octave starting at `low` (default F#1..F2, as MUS-TOWN v04)."""
    root, _, b = parse_chord(sym)
    pc = root if b is None else b
    lo = p(low)
    return lo + ((pc - lo) % 12)


def tones(sym, low='C3', count=8):
    """Ascending chord tones from `low` (for arpeggios)."""
    root, ints, _ = parse_chord(sym)
    pcs = sorted({(root + i) % 12 for i in ints})
    out = []
    m = p(low)
    while len(out) < count:
        if m % 12 in pcs:
            out.append(m)
        m += 1
    return out


# ---------------------------------------------------------------- melodies
def m(text):
    """'D4:1 A4:.5 G4:.5 | F4:1.5 r:.5' -> [('D4', 1.0), ...]. '|' marks bars (ignored); a bare duration repeats the last pitch."""
    out = []
    for tok in text.replace('|', ' ').split():
        n, d = tok.split(':')
        out.append((n, float(d)))
    return out


def transpose(mel, semis):
    return [(n if n == REST else p(n) + semis, d) for n, d in mel]


def augment(mel, factor=2.0):
    return [(n, d * factor) for n, d in mel]


def length(mel):
    return sum(d for _, d in mel)


def retrograde(mel):
    return list(reversed(mel))


def split_beats(mel, a, b):
    """Notes of `mel` that start in beats [a, b)."""
    out, pos = [], 0
    for n, d in mel:
        if a <= pos < b:
            out.append((n, d))
        pos += d
    return out


def with_rhythm(pitches, rhythm):
    return list(zip(pitches, rhythm))


# ---------------------------------------------------------------- the Crossroads motif
# D4 A4 G4 F4 E4 A4, rhythm q e e dq e dh (7 beats). Scale degrees 1 5 4 3 2 5 of the home key.
CROSSROADS = [('D4', 1), ('A4', .5), ('G4', .5), ('F4', 1.5), ('E4', .5), ('A4', 3)]
CROSSROADS_RHYTHM = [1, .5, .5, 1.5, .5, 3]
CROSSROADS_DEGREES = [0, 4, 3, 2, 1, 4]
RESOLVED_DEGREES = [0, 4, 3, 2, 1, 0]


def motif(tonic='D4', mode='minor', rhythm=None, resolved=False, inverted=False, degrees=None):
    """The Crossroads motif in any key and mode, by scale degree (so a major key gets a major third).
    resolved=True: the last note falls to the tonic - ONLY for FREED / restored / homecoming tracks.
    inverted=True: the intervals mirrored downward around the first note."""
    sc = Scale(tonic, mode)
    degs = list(degrees or (RESOLVED_DEGREES if resolved else CROSSROADS_DEGREES))
    if inverted:
        degs = [-d for d in degs]
    return with_rhythm([sc.deg(d) for d in degs], rhythm or CROSSROADS_RHYTHM)


def motif_head(tonic='D4', mode='minor', rhythm=(1, .5, .5)):
    """First three notes (D A G): the rising fifth and the step back."""
    return motif(tonic, mode, list(rhythm), degrees=CROSSROADS_DEGREES[:3])


def motif_tail(tonic='D4', mode='minor', rhythm=(1.5, .5, 3), resolved=False):
    """Last three notes (F E A), or (F E D) resolved."""
    degs = (RESOLVED_DEGREES if resolved else CROSSROADS_DEGREES)[3:]
    return motif(tonic, mode, list(rhythm), degrees=degs)


# ---------------------------------------------------------------- story themes (transcribed from the motif masters, Oct 31)
# MUS-LULLABY.wav opening phrase (approximate transcription by pitch tracking; the master is audio only). Rising fifth then a fall
# through the third: it is the Crossroads motif's parent. NEVER state the whole lullaby before the story reveals it (music_list).
LULLABY_HEAD = [('D4', 1), ('A4', 1), ('F4', 1), ('E4', 1), ('A4', 1), ('E4', 2)]
LULLABY_ANSWER = [('G4', 1), ('E4', 1), ('D4', 1), ('F4', 1), ('A4', 1), ('F4', 1), ('C5', 1), ('G4', 1), ('B4', 1), ('A4', 1), ('E4', 2)]
# MUS-PRIMM-MOTIF.wav: a narrow, too-even civic line in C major (all equal values).
PRIMM_HEAD = [('C4', 1), ('E4', 1), ('G4', 1), ('C5', 1), ('B4', 1), ('A4', 1), ('G4', 1), ('D4', 1)]
PRIMM_ANSWER = [('C4', 1), ('F4', 1), ('A4', 1), ('C5', 1), ('D5', 1), ('C5', 1), ('B4', 1), ('G4', 1)]
