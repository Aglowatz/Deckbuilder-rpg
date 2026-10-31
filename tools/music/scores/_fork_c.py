"""Shared helpers for the Music Pass 3 Lab (techno) and side-area scores (fork C).

The Lab is quantised techno on GM synths + one GS drum kit (standard GM drum map: kick 36, snare 38, clap 39, closed hat 42, open hat 46,
crash 49, ride 51, toms 45/47/50), with cold orchestral stabs. LAB_RIFF is the Lab's own clinical lead idea (original), in A minor.
"""
from lib import p, voice, bass_note, REST

KICK, SNARE, CLAP, HAT, OHAT, CRASH, RIDE = 36, 38, 39, 42, 46, 49, 51

# The Lab riff (A minor, two bars of 16ths/8ths): a needle-sharp octave figure that steps down through the harmonic minor's G#.
LAB_RIFF = [('A4', .5), ('A4', .25), ('E5', .25), ('A4', .5), ('D5', .5), ('C5', .5), ('B4', .25), ('A4', .25), ('E4', .5), ('G#4', .5),
            ('A4', .5), ('A4', .25), ('E5', .25), ('A4', .5), ('F5', .5), ('E5', .75), ('D5', .25), ('C5', .5), ('B4', .5)]


def tr(mel, semis):
    return [(n if n == REST else p(n) + semis, d) for n, d in mel]


def chord(s, ch, beat, dur, notes, vel):
    for n in notes:
        s.note(ch, beat, dur, p(n), vel, human=False)


def drums(s, bar, bars, vel, kick=True, clap=True, hats=True, ohat=True, snare=False, half=False, ch='kit'):
    """Four-on-the-floor (half=True: kick on 1 and 3 only), claps on 2/4, closed 16th hats, open hat on the off-beats."""
    q = s.bar_q
    for k in range(bars):
        t0 = (bar + k) * q
        for b in range(int(q)):
            t = t0 + b
            if kick and (not half or b % 2 == 0):
                s.note(ch, t, .2, KICK, vel, human=False)
            if clap and b % 2 == 1:
                s.note(ch, t, .2, CLAP, vel - 12, human=False)
            if snare and b % 2 == 1:
                s.note(ch, t, .2, SNARE, vel - 16, human=False)
            if ohat:
                s.note(ch, t + .5, .2, OHAT, vel - 30, human=False)
            if hats:
                for i in range(4):
                    if i != 2 or not ohat:
                        s.note(ch, t + i * .25, .1, HAT, vel - (34 if i else 26), human=False)


def snare_build(s, bar, bars, v0, v1, ch='kit', inst=SNARE):
    """A build: 8ths, then 16ths, then 32nds in the last bar, rising in velocity."""
    q = s.bar_q
    start = bar * q
    total = bars * q
    t = 0.0
    while t < total - 1e-6:
        frac = t / total
        rate = 2 if frac < .5 else (4 if t < total - q else 8)
        s.note(ch, start + t, .08, inst, int(v0 + (v1 - v0) * frac), human=False)
        t += 1.0 / rate


def pump(s, ch, bar, bars, lo=36, hi=112):
    """Sidechain duck on every beat (CC11)."""
    for b in range(int(bars * s.bar_q)):
        t = bar * s.bar_q + b
        s.cc11[ch].append((t, lo))
        s.cc11[ch].append((t + .3, int(lo + (hi - lo) * .7)))
        s.cc11[ch].append((t + .75, hi))


def roll_bass(s, chs, bar, sym, vel, pattern='roll', octave=0):
    """Techno bass: 'roll' = three 16ths after each kick, 'off' = off-beat 8ths, 'gallop' = 8th + two 16ths."""
    b = bass_note(sym) + 12 * octave
    q = s.bar_q
    for beat in range(int(q)):
        t = bar * q + beat
        if pattern == 'roll':
            hits = [(.25, 0), (.5, 0), (.75, 12)]
        elif pattern == 'off':
            hits = [(.5, 0)]
        else:
            hits = [(0, 0), (.5, 0), (.75, 12)]
        for off, o in hits:
            for i, ch in enumerate(chs):
                s.note(ch, t + off, .2, b + o, vel - i * 10 + (6 if off == .5 else 0), human=False)


def arp(s, ch, bar, bars, sym, vel, step=.25, low='A4', order=(0, 1, 2, 3, 2, 1, 3, 4), n=5):
    tones = voice(sym, low, n)
    q = s.bar_q
    t, end, i = bar * q, (bar + bars) * q, 0
    while t < end - 1e-6:
        s.note(ch, t, step * .8, tones[order[i % len(order)] % len(tones)], vel + (8 if i % 4 == 0 else 0), human=False)
        t += step
        i += 1


def stutter(s, ch, beat, pitch, vel, beats=.5, rate=8):
    """Glitch: one note retriggered at 32nds (rate 8 per beat)."""
    for i in range(int(beats * rate)):
        s.note(ch, beat + i / rate, .9 / rate, p(pitch), vel - (i % 2) * 10, human=False)


def glitch(mel, cuts=(0, 3)):
    """A melody with its chosen notes broken into 32nd stutters for their first half (the glitched synth lead)."""
    out = []
    for i, (n, d) in enumerate(mel):
        if i in cuts and n != REST and d >= .5:
            k = int(d / 2 * 8)
            out += [(n, .125)] * k + [(n, d - k * .125)]
        else:
            out.append((n, d))
    return out


def riser(s, ch, bar, bars, start_pitch, vel=60, step=.5):
    """Rising chromatic line + CC11 ramp up (the riser before a drop)."""
    q = s.bar_q
    t, k = bar * q, 0
    while t < (bar + bars) * q - 1e-6:
        s.note(ch, t, step * .9, p(start_pitch) + k, vel + k, human=False)
        t += step
        k += 1
    s.swell(ch, bar, bars, 40, 120)


def human(s, amount=(0.022, 7)):
    """Context: humanise the notes written inside it (cello / orchestral lines inside a quantised track)."""
    class _H:
        def __enter__(self_):
            self_.old = (s.jitter, s.vel_spread)
            s.jitter, s.vel_spread = amount

        def __exit__(self_, *a):
            s.jitter, s.vel_spread = self_.old
    return _H()


# ---------------------------------------------------------------- Part 6 side areas: their own themes (original)
# Forgotten Vault: a quiet royal phrase in F# minor (8 bars of 4/4), stately, passed between four Path colours.
VAULT_ROYAL = [('F#4', 2), ('C#5', 2), ('B4', 1), ('A4', 1), ('G#4', 2), ('A4', 1.5), ('B4', .5), ('C#5', 1), ('E5', 1), ('D5', 4),
               ('D5', 2), ('C#5', 1), ('B4', 1), ('A4', 1), ('G#4', 1), ('F#4', 1), ('E#4', 1), ('F#4', 1.5), ('G#4', .5), ('A4', 1),
               ('C#5', 1), ('F#4', 4)]
VAULT_PROG = ['F#m', 'E', 'F#m', 'D', 'Bm', 'C#7', 'D', 'F#m']
# The Vault Guardian / Warden of the Four Seals: four heavy seal strokes (one per Path) and a grinding answer.
SEALS = [('F#3', 1), ('C4', 1), ('B3', 1), ('F#3', 1), ('G3', 1.5), ('F#3', .5), ('E#3', 2)]

# Crosspath graveyard: Old Hob's crooked funeral hum, G minor 3/4 (8 bars).
GRAVE_HUM = [('G3', 1), ('Bb3', 1), ('A3', 1), ('D3', 3), ('Eb3', 1), ('D3', 1), ('C#3', 1), ('D3', 3),
             ('G3', 1), ('A3', 1), ('Bb3', 1), ('C4', 1.5), ('Bb3', .5), ('A3', 1), ('Bb3', 1), ('G3', 1), ('F#3', 1), ('G3', 3)]
GRAVE_PROG = ['Gm', 'D', 'Cm/Eb', 'D', 'Gm', 'Cm', 'D7', 'Gm']

# The Grand Clashatorium: Grand Bellows' broad showbiz fanfare-tune, Eb major (8 bars of 4/4).
ARENA_THEME = [('Bb4', .5), ('Eb5', .5), ('F5', .5), ('G5', 2.5), ('Bb5', 1), ('Ab5', 1), ('G5', 1), ('F5', 1),
               ('Eb5', 1), ('F5', .5), ('G5', .5), ('C5', 2), ('Ab5', 1), ('G5', 1), ('F5', 2),
               ('Bb4', .5), ('Eb5', .5), ('F5', .5), ('G5', 2.5), ('C6', 1), ('Bb5', 1), ('Ab5', 1), ('G5', 1),
               ('F5', 1), ('G5', .5), ('Ab5', .5), ('Bb5', 1), ('D5', 1), ('Eb5', 4)]
ARENA_PROG = ['Eb', 'Eb', 'Cm', 'Ab Bb', 'Eb', 'Ab', 'Fm7 Bb', 'Eb']
