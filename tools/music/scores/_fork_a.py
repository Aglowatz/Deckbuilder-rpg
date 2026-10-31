"""Shared helpers for the Music Pass 3 Capital and shop scores (composer fork A). Not a score: build.py never loads it by ID."""
from lib import p, m, voice, transpose, length
from lib.theory import parse_chord
from lib.capital import CAPITAL_THEME, CAPITAL_PROG
from lib.zones import to_mode

FLATS = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B']
HARM_MINOR = {4: -1, 9: -1}                 # C major -> C harmonic minor (E->Eb, A->Ab; B stays)
CAPITAL_PROG_MINOR = ['Cm', 'G7', 'Fm G', 'Cm', 'Fm', 'G7', 'Ab Fm', 'G7 Cm',
                      'Fm', 'Cm', 'Dm7b5', 'Ab', 'Dm7b5 G', 'Fm G', 'G7', 'Cm']


def bars_of(mel, q=4.0):
    out, cur, acc = [], [], 0.0
    for n, d in mel:
        cur.append((n, d))
        acc += d
        if acc >= q - 1e-6:
            out.append(cur)
            cur, acc = [], 0.0
    if cur:
        out.append(cur)
    return out


CAP_BARS = bars_of(CAPITAL_THEME)


def cap(i, j, semis=0, minor=False):
    """Bars i..j-1 (0-based) of the Capital theme, optionally in harmonic minor, moved by `semis`."""
    mel = [x for b in CAP_BARS[i:j] for x in b]
    if minor:
        mel = to_mode(mel, HARM_MINOR)
    return transpose(mel, semis) if semis else mel


def tr(sym, semis):
    """Transpose a chord symbol (and slash bass) by `semis`."""
    if not semis:
        return sym
    def one(s):
        i = 1
        while i < len(s) and s[i] in '#b':
            i += 1
        root = p(s[:i] + '4') % 12
        return FLATS[(root + semis) % 12] + s[i:]
    if '/' in sym:
        a, b = sym.split('/')
        return one(a) + '/' + one(b)
    return one(sym)


def prog(semis=0, minor=False):
    return [' '.join(tr(x, semis) for x in spec.split()) for spec in (CAPITAL_PROG_MINOR if minor else CAPITAL_PROG)]


def each(s, bar, spec):
    """[(abs_beat, beats, sym)] for a bar spec like 'Dm G'."""
    return [(bar * s.bar_q + b, d, sym) for b, d, sym in s.parts(spec)]


def bed(s, bar, spec, vel, ch='pad', low='C3', n=4, bass=None, bvel=None, octave=0):
    """Sustained chord pad for the bar spec; bass=('cb','vc') or ('cb', None) adds the root."""
    for t, d, sym in each(s, bar, spec):
        for k in voice(sym, low, n):
            s.note(ch, t, d - 0.02, k + 12 * octave, vel)
        if bass:
            s.bass_at(t, d, sym, bvel or vel, chs=bass)


def block(s, ch, bar, spec, vel, low='F3', n=3, rhythm=((0, 1),)):
    """Rigid block chords on the given beats [(beat_in_chord, dur)] of each chord of the bar."""
    for t, d, sym in each(s, bar, spec):
        for b, dd in rhythm:
            if b < d - 1e-6:
                for k in voice(sym, low, n):
                    s.note(ch, t + b, dd, k, vel)


def root(s, sym, low='E2'):
    r = p(s.voicing(sym)[0])
    while r < p(low):
        r += 12
    return r


def arp(s, ch, bar, spec, vel, low='C5', step=0.5, pattern=(0, 1, 2, 1), dur=None):
    """Even arpeggio (music box / harpsichord / synth) over each chord of the bar."""
    for t, d, sym in each(s, bar, spec):
        tn = s.chord_tones(sym, p(low), 6)
        k = 0
        x = 0.0
        while x < d - 1e-6:
            s.note(ch, t + x, dur or step * 0.9, tn[pattern[k % len(pattern)]], vel + (6 if k == 0 else 0))
            x += step
            k += 1


def walk_bass(s, bar, spec, vel, ch='cb', pattern='q'):
    """Root on every beat ('q') or root-fifth halves ('h'); octave above on vc if present."""
    for t, d, sym in each(s, bar, spec):
        r = root(s, sym, 'E1')
        if r > p('D2'):
            r -= 12
        if pattern == 'q':
            for i in range(int(round(d))):
                s.note(ch, t + i, .8, r if i % 2 == 0 else r + 7, vel + (6 if i == 0 else 0))
        else:
            s.note(ch, t, d * .95, r, vel)


def pump(s, ch, bar, bars, lo=40, hi=100, per_bar=4):
    """Sidechain-like CC11 dip on every beat."""
    q = s.bar_q / per_bar
    for b in range(int(bars * per_bar)):
        t = bar * s.bar_q + b * q
        s.cc11[ch].append((t, lo))
        s.cc11[ch].append((t + q * 0.45, hi))


def m_(text):
    return m(text)


# ---------------------------------------------------------------- shop helpers (Part 5)
def low_root(s, sym, top='F2'):
    b = root(s, sym, 'E1')
    if b >= p(top):
        b -= 12
    return b


def shop_bass(s, bar, spec, vel, ch='pbass', style='two'):
    """Plucked bass: 'two' (root on 1, fifth on 3), 'walk' (root, third/fifth, approach), 'skip' (root, off-beat octave)."""
    for t, d, sym in each(s, bar, spec):
        b = low_root(s, sym, 'A2')
        tn = s.chord_tones(sym, b, 4)
        if style == 'two':
            s.note(ch, t, min(d, 2) * .8, b, vel + 4)
            if d >= 3:
                s.note(ch, t + 2, .8, tn[2], vel - 4)
        elif style == 'walk':
            for k in range(int(round(d))):
                s.note(ch, t + k, .85, [b, tn[1], tn[2], tn[1]][k % 4], vel + (4 if k == 0 else -2))
        elif style == 'skip':
            for k in range(int(round(d))):
                s.note(ch, t + k, .45, b, vel + (4 if k == 0 else -4))
                s.note(ch, t + k + .5, .3, b + 12, vel - 12)


def brushes(s, bar, vel, ch='perc', hat=True):
    s.drum(bar, [(0, 'bd', -4), (1, 'snare', -14), (2.5, 'bd', -12), (3, 'snare', -12)], vel, ch=ch)
    if hat:
        s.drum(bar, [(k * .5, 'hihat', -20 if k % 2 else -14) for k in range(int(s.bar_q * 2))], vel, ch=ch)


def gliss(s, ch, bar, sym, vel, low='C4', up=True, beats=1.0, beat=0.0):
    """Harp glissando through the chord tones over `beats`."""
    tn = s.chord_tones(sym, p(low), 12)
    seq = tn if up else tn[::-1]
    step = beats / len(seq)
    for k, n in enumerate(seq):
        s.note(ch, bar * s.bar_q + beat + k * step, .8, n, vel - 10 + int(20 * k / len(seq)))
