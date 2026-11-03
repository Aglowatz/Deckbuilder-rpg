"""Composer fork C helpers (Gainlands rock Nov 3): Mount Swolympus, Chet's aerobics, the gym pro shop. On top of lib/rock.py."""
from lib import p
from lib import rock as R

HITS = dict(R.BRASS_HITS)
HITS.update({'C#': ['C#3', 'G#3', 'C#4', 'F4'], 'Emaj': ['E3', 'B3', 'E4', 'G#4']})


def brass(s, bar, c, hits=((0, .6, 92), (2.5, .4, 80)), ch='brass'):
    for b, d, v in hits:
        s.chord(ch, s.B(bar, b), d, HITS[c], v)


def pad(s, bar, c, vel, beats=4, ch='pad'):
    s.chord(ch, s.B(bar), beats, [p(n) + 12 for n in HITS[c][1:]], vel)


def bed(s, bar, r, c, kick=112, sub=96, padv=68, gtr=58):
    """The intro/outro bed (bible section 10): kick pulse, synth-sub 8ths, pad, a held power chord. Use the same at both ends."""
    R.kick_pulse(s, bar, kick)
    if sub:
        R.subdrop(s, bar, r, sub)
    pad(s, bar, c, padv)
    if gtr:
        R.sustain(s, bar, r, gtr)


def gtr_ramp(s, bar, bars, lo, hi):
    for ch in ('gtrL', 'gtrR'):
        s.ramp(ch, bar, bars, lo, hi)


def brass_call(s, bar, c, vel=96):
    """A brass call on beats 1 and the and-of-2 (answered by the lead in the next bar)."""
    brass(s, bar, c, hits=((0, .45, vel), (1.5, .45, vel - 8), (2, 1.8, vel - 4)))
