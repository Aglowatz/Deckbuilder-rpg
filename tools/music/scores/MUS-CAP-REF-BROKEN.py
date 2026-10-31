"""MUS-CAP-REF-BROKEN - The Reek, broken service (the Capital's Refusemancer district). 80 bars 6/8 (q = 132, dotted q = 44), E minor,
~109 s. A depleted Verdant Dump: the jig theme (zones.DUMP_THEME, E Aeolian) played thin on a solo violin detuned 25 cents flat against a
second, in-tune violin a little behind it, and interrupted - phrases stop mid-bar and leave holes. Cluttered plucked figures (pizzicato,
harp) that cannot decay: short, dry, repeated, never allowed to ring. A faint rift texture (bowed glass) and a low drone; the harp's
fairy glimmer starts and breaks off. The Crossroads motif drifts by on the flute, unresolved. Human warmth barely audible. Music Pass 2, Batch 08.
"""
from lib import Song, m, motif, motif_head, motif_tail, augment, p, voice, bass_note, transpose, split_beats
from lib.zones import DUMP_THEME, DUMP_JIG_1, DUMP_JIG_2, DUMP_JIG_HEAD, DUMP_PROG, to_mode

# ---------------------------------------------------------------- Verdant Dump kit (shared by the Refusemancer cues, Music Pass 2)
PAL = {  # name: (GM program, pan, reverb, volume) - the approved ZONE-DUMP demo's seating plus a few extras
    'fid': (40, 40, 85, 96), 'vln': (48, 36, 100, 86), 'fl': (73, 52, 90, 82), 'picc': (72, 48, 90, 64),
    'gtr': (24, 70, 70, 84), 'piano': (0, 58, 85, 80), 'harp': (46, 46, 95, 80), 'cel': (8, 44, 105, 72),
    'bells': (14, 60, 110, 60), 'pizz': (45, 74, 80, 82), 'vc': (42, 82, 90, 88), 'cb': (43, 92, 90, 90),
    'hn': (60, 78, 95, 86), 'timp': (47, 64, 80, 92), 'glock': (9, 40, 100, 62), 'pad': (49, 64, 100, 76),
    'trem': (44, 50, 100, 74), 'cl': (71, 60, 85, 78), 'bsn': (70, 70, 85, 80), 'tpt': (56, 70, 90, 72),
    'tbn': (57, 88, 95, 76), 'xylo': (13, 48, 80, 64), 'choir': (52, 64, 110, 62), 'kit': (48, 64, 80, 86),
}
E_MINOR = {1: -1}            # E Dorian -> E Aeolian (C# -> C)
E_HARM = {1: -1, 2: 1}       # -> E harmonic minor (C# -> C, D -> D#)
E_MAJOR = {7: 1, 2: 1}       # E Dorian -> E major (G -> G#, D -> D#)


def setup(S, *names, **over):
    for n in names:
        prog, pan, rev, vol = PAL[n]
        if n in over:
            vol = over[n]
        S.add(n, 9 if n == 'kit' else None, prog, pan=pan, rev=rev, vol=vol)
        if n == 'kit':
            S.ch[n]['drums'] = True       # GS orchestra kit on MIDI channel 10 (kept out of the pitched-note checks)


def six8(S):
    return S.bar_q == 3


def strum(S, bar, sym, vel, low='D3'):
    """The nylon guitar: jig strum in 6/8, a reel chop in 4/4."""
    v = voice(sym, low, 4)
    pat = ((0, 1.0), (1.0, .6), (1.5, .85), (2.5, .6)) if six8(S) else ((0, 1.0), (1, .6), (1.5, .8), (2, .9), (3, .6), (3.5, .8))
    for t, a in pat:
        S.chord('gtr', S.B(bar, t), .45, v, vel * a, spread=.02)


def bassline(S, bar, sym, vel, vc=False):
    b = bass_note(sym, 'E1')
    if six8(S):
        S.note('cb', S.B(bar), 1.4, b, vel)
        S.note('pizz', S.B(bar, 1.5), .5, b + 7, vel - 10)
    else:
        S.note('cb', S.B(bar), 1.4, b, vel)
        S.note('cb', S.B(bar, 2), 1.4, b + 7, vel - 6)
    if vc:
        S.note('vc', S.B(bar), S.bar_q * .9, b + 12, vel - 8)


def tamb(S, bar, bars, vel):
    n = 6 if six8(S) else 8
    for i in range(bars):
        for e in range(n):
            acc = 12 if (e % 3 == 0 if six8(S) else e % 2 == 0) else -6
            S.note('kit', S.B(bar + i, e * .5), .2, 54, vel + acc, human=False)


def drums(S, bar, bars, vel, snare=True):
    for i in range(bars):
        if six8(S):
            S.note('kit', S.B(bar + i), .3, 36, vel + 6, human=False)
            if snare:
                S.note('kit', S.B(bar + i, 1.5), .3, 38, vel - 8, human=False)
        else:
            for t in (0, 2):
                S.note('kit', S.B(bar + i, t), .3, 36, vel + 6, human=False)
            if snare:
                for t in (1, 3):
                    S.note('kit', S.B(bar + i, t), .3, 38, vel - 6, human=False)
    tamb(S, bar, bars, vel - 18)


def fairy(S, bar, sym, vel, low='E3', ch1='cel', ch2='harp'):
    """The demo's fairy glimmer: the chord rippling up two octaves on celesta (8va) and harp."""
    ts = voice(sym, low, 4)
    ts = ts + [t + 12 for t in ts]
    step = S.bar_q / len(ts)
    for i, t in enumerate(ts):
        if ch1:
            S.note(ch1, S.B(bar) + i * step, 1.2, t + 12, vel)
        if ch2:
            S.note(ch2, S.B(bar) + i * step, 1.5, t, vel - 6)


def reel(mel):
    """A 6/8 jig line (eighth slots) recast as 4/4 reel bars: each jig bar a b c d e f -> a b c b d e f e (held notes stay held)."""
    slots = []
    for n, d in mel:
        k = max(1, int(round(d / .5)))
        slots.append((n, True))
        slots += [(n, False)] * (k - 1)
    out = []
    for b in range(len(slots) // 6):
        bs = slots[b * 6:b * 6 + 6]
        for j, i in enumerate((0, 1, 2, 1, 3, 4, 5, 4)):
            n, att = bs[i]
            if j > 0 and not att and out and out[-1][0] == n:
                out[-1] = (n, out[-1][1] + .5)
            else:
                out.append((n, .5))
    return out


def bars_of(S, mel, a, b):
    """Bars a..b (exclusive) of a melody, counted in this score's bar length."""
    return split_beats(mel, a * S.bar_q, b * S.bar_q)


def aug(mel, f=2.0):
    return [(n, d * f) for n, d in mel]

R68 = (1.5, .75, .75, 2.25, .75, 3)


def interrupted(mel, keep_beats, total_beats):
    """The first `keep_beats` of a phrase, then silence to `total_beats` (the phrase breaks off mid-bar)."""
    out, pos = [], 0.0
    for n, d in mel:
        if pos >= keep_beats:
            break
        dd = min(d, keep_beats - pos)
        out.append((n, dd))
        pos += dd
    return out + [('r', total_beats - pos)]


def build():
    S = Song('MUS-CAP-REF-BROKEN', bpm=132, bars=80, meter=(6, 8), key='E minor', seed=512, jitter=0.02)
    setup(S, 'fid', 'vln', 'fl', 'harp', 'pizz', 'vc', 'cb', 'pad', 'cel', 'kit', vln=70)
    S.add('glass', None, 92, pan=64, rev=110, vol=56)
    S.detune('fid', -25)                      # the lead fiddle sits 25 cents flat all through
    for bar, nm in ((0, 'clutter'), (8, 'A thin theme'), (24, 'B holes'), (40, 'flute drift'), (48, "A' thinner"), (64, 'clutter, glimmer'),
                    (72, 'clutter again')):
        S.section(bar, nm)
    TH = to_mode(DUMP_THEME, E_MINOR)
    PR = ['Em', 'D', 'Em', 'Am', 'Em', 'D', 'G', 'Am'] * 2

    def clutter(bar, n, v):
        """Dry plucked figures that cannot decay: very short, repeated, off the beat."""
        for i in range(n):
            sym = PR[i % 16]
            tn = S.chord_tones(sym, 'E4', 4)
            for k, j in enumerate((0, 0, 2, 1, 1, 3)):
                S.note('pizz', S.B(bar + i, k * .5), .12, tn[j], v + (6 if k == 0 else 0))
            for k, j in enumerate((3, 2, 3, 1, 3, 2)):
                if (i + k) % 3 != 2:
                    S.note('harp', S.B(bar + i, k * .5 + .25), .1, tn[j] + 12, v - 14)
            S.note('kit', S.B(bar + i, 1.5), .1, 80, v - 20, human=False)

    def bed(bar, n, v):
        for i in range(n):
            S.note('cb', S.B(bar + i), 3.02, p('E2'), v)
            S.note('glass', S.B(bar + i), 3.02, p('B3') if i % 4 < 2 else p('C4'), v - 12)

    clutter(0, 8, 50)
    bed(0, 8, 50)
    S.mel('vln', 2, m('E5:1.5 B4:1.5 | E5:1.5 r:1.5'), 54)
    S.mel('vln', 6, m('G5:1.5 F#5:1.5 | E5:1 r:2'), 50)

    # A 8-23: the theme thin - the detuned fiddle with the in-tune violin half a beat behind, phrases cut short
    clutter(8, 16, 48)
    bed(8, 16, 52)
    for k, bar in enumerate(range(8, 24, 4)):
        ph = bars_of(S, TH, (k % 4) * 4, (k % 4) * 4 + 4)
        S.mel('fid', bar, interrupted(ph, (8.5, 10, 7, 11)[k], 12), 82, legato=.9)
        S.line('vln', bar, interrupted(ph, (8.5, 10, 7, 11)[k], 12), 50, beat=.5, legato=.85)

    # B 24-39: holes - only the theme's first cells, and long silences the clutter fills
    clutter(24, 16, 54)
    bed(24, 16, 54)
    head = to_mode(DUMP_JIG_HEAD, E_MINOR)
    for k, bar in enumerate((24, 27, 31, 34, 37)):
        S.mel('fid', bar, interrupted(head, (4, 3, 5, 2.5, 4.5)[k], 6), 80)
    S.swell('glass', 24, 16, 100, 120, 'arch')

    # flute drift 40-47: the Crossroads motif drifts by, unresolved; a glimmer starts and breaks off
    clutter(40, 8, 44)
    bed(40, 8, 48)
    S.motif('fl', 40, motif('E5', 'minor', rhythm=R68), 72, form='stated (flute, drifting, unresolved)')
    S.mel('fl', 43, m('G5:3 | F#5:1.5 r:1.5 | E5:3 | r:3'), 62)
    S.mel('fid', 46, interrupted(head, 3.5, 6), 70)
    S.note('cel', S.B(44), 1, p('E6'), 44)
    S.note('cel', S.B(44, .375), 1, p('G6'), 40)
    S.note('cel', S.B(44, .75), 1, p('B6'), 36)

    # A' 48-63: thinner still
    clutter(48, 16, 50)
    bed(48, 16, 50)
    S.detune('fid', -30, 48)
    for k, bar in enumerate(range(48, 64, 4)):
        ph = bars_of(S, TH, ((k + 1) % 4) * 4, ((k + 1) % 4) * 4 + 4)
        S.mel('fid', bar, interrupted(ph, (6.5, 9, 5, 8)[k], 12), 78, legato=.9)
        S.line('vln', bar, interrupted(ph, (6.5, 9, 5, 8)[k], 12), 46, beat=.5, legato=.85)
    S.detune('fid', -25, 64)

    # 64-71: clutter, a glimmer that breaks off, the motif's head unanswered
    clutter(64, 8, 52)
    bed(64, 8, 52)
    for bar in (64, 68):
        ts = voice('Em', 'E4', 4)
        for i, t in enumerate(ts[:3]):
            S.note('cel', S.B(bar) + i * .375, .8, t + 12, 42)
    S.motif('fl', 66, motif_head('E5', 'minor', rhythm=(1.5, .75, .75)), 64, form='head (flute, unanswered)', lead=False)
    S.mel('fid', 65, interrupted(head, 3, 6), 70)
    S.mel('fid', 69, interrupted(head, 4, 6), 70)

    # 72-79: clutter again, as bar 0, into the loop
    clutter(72, 8, 50)
    bed(72, 8, 50)
    S.mel('vln', 74, m('E5:1.5 B4:1.5 | E5:1.5 r:1.5'), 54)
    S.mel('vln', 78, m('G5:1.5 F#5:1.5 | E5:1 r:2'), 50)
    S.fade_vel(77, 80, 1.2, ['pizz', 'harp', 'cb', 'glass'])   # seam: the clutter leans in at the loop point
    return S
