"""Composer fork A helpers (Gainlands rock Nov 3): shared blocks for MUS-BEEF-EXP / -FREED / -RELEASE / MUS-CAP-BEEF-BROKEN / -RESTORED."""
from lib import p
from lib import rock as R


def bed(s, bar, c, vel, arp=True, kick=True, brass=None):
    """The intro/outro bed (bible section 10): a held power chord, the sub on the root, a pad, the saw arp and a kick pulse.
    Intro and outro use the same call so the loop seam matches."""
    R.sustain(s, bar, c, vel)
    s.note('sub', s.B(bar), 3.9, R.root(c), vel + 20, human=False)
    R.pad_chord(s, bar, brass or c, vel + 6)
    if arp:
        R.arp(s, bar, c, vel + 20)
    if kick:
        R.kick_pulse(s, bar, vel + 40)


def riff(s, bar, c, vel, pattern='gallop', beat=None, fill=False, bass='8ths', half=False):
    R.chug(s, bar, c, vel, pattern=pattern)
    R.bassline(s, bar, c, vel + 6, style=bass)
    R.rock_beat(s, bar, beat if beat is not None else vel + 16, fill=fill, half=half)


def augment(mel, f=2.0):
    return [(n, d * f) for n, d in mel]


def cut(mel, keep):
    """The first `keep` beats of a phrase, then silence: the line gives out (broken service)."""
    out, pos = [], 0.0
    for n, d in mel:
        if pos >= keep:
            break
        out.append((n, min(d, keep - pos)))
        pos += d
    return out


def grid_chord(s, ch, bar, notes, vel, beats=(0, 1, 2, 3), dur=.4):
    """The Capital grid: rigid quantised block chords on every beat (human feel off)."""
    for b in beats:
        for n in notes:
            s.note(ch, s.B(bar, b), dur, p(n), vel, human=False)


def grid_snare(s, bar, vel, kind='march'):
    """Capital rudiment on the power kit's snare, quantised (lib/capital.rudiment's 'march' and 'flam')."""
    t0 = s.B(bar)
    if kind == 'march':
        for h in range(2):
            b = t0 + h * 2
            s.note('kit', b, .1, 38, vel + 10, human=False)
            s.note('kit', b + .75, .1, 38, vel - 8, human=False)
            s.note('kit', b + 1, .1, 38, vel - 4, human=False)
            s.note('kit', b + 1.5, .1, 40, vel - 12, human=False)
    else:
        for i in range(4):
            s.note('kit', t0 + i - .04, .05, 40, vel - 24, human=False)
            s.note('kit', t0 + i, .1, 38, vel, human=False)
