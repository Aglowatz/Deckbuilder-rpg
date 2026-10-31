"""MUS-CAP-REF-RESTORED - The Reek, service returns. 96 bars 6/8 (q = 150, dotted q = 50), E Dorian, ~115 s. The same Verdant Dump jig
theme that MUS-CAP-REF-BROKEN broke (zones.DUMP_THEME), now whole and in tune: the solo violin with the violins, then a clear flute over
the harp, nylon guitar and plucked bass, with rests to breathe (flowers, honest compost). The Crossroads motif is RESOLVED on the flute
with chimes. The wider Capital's tension stays until Primm falls: a stiff, quiet orchestra-snare tick and a held pedal under the cello's
statement of the jig head, and the harmony never quite settles into a final cadence. Music Pass 2, Batch 08.
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


def build():
    S = Song('MUS-CAP-REF-RESTORED', bpm=150, bars=96, meter=(6, 8), key='E Dorian', seed=513, jitter=0.012)
    setup(S, 'fid', 'vln', 'fl', 'gtr', 'piano', 'harp', 'cel', 'bells', 'pizz', 'vc', 'cb', 'hn', 'pad', 'timp', 'kit')
    for bar, nm in ((0, 'glimmer'), (8, 'A theme whole'), (24, 'B flute, breathing'), (40, 'Capital tension'), (48, 'C resolved motif'),
                    (64, "A' tutti"), (88, 'outro glimmer')):
        S.section(bar, nm)
    PR = DUMP_PROG

    def groove(bar, n, v):
        for i in range(n):
            strum(S, bar + i, PR[i % 16], v)
            bassline(S, bar + i, PR[i % 16], v)
        tamb(S, bar, n, v - 30)

    def tick(bar, n, v):
        for i in range(n):
            S.note('kit', S.B(bar + i), .1, 38, v, human=False)
            S.note('kit', S.B(bar + i, 1.5), .1, 38, v - 8, human=False)

    def intro(bar):
        for i, sym in enumerate(['Em', 'D', 'G', 'A', 'Em', 'D', 'G', 'A']):
            if i % 2 == 0:
                fairy(S, bar + i, sym, 50)
            strum(S, bar + i, sym, 56)
            bassline(S, bar + i, sym, 54)
        S.note('bells', S.B(bar), 4, p('E5'), 54)
        S.mel('fl', bar + 4, m('B5:1.5 A5:1.5 | G5:1.5 A5:1.5 | B5:3 | A5:3'), 58)

    intro(0)

    # A 8-23: the theme whole and in tune
    groove(8, 16, 70)
    S.mel('fid', 8, DUMP_THEME, 92, legato=.88)
    S.line('vln', 16, DUMP_THEME[46:], 78, transpose=-12, legato=.88)
    S.chord('pad', S.B(8), 24, ['E4', 'B4'], 40)

    # B 24-39: a clear flute over harp, with breathing rests
    for i in range(16):
        sym = PR[i]
        ts = voice(sym, 'E3', 4)
        for e, t in enumerate([ts[0], ts[1], ts[2], ts[3], ts[2], ts[1]]):
            S.note('harp', S.B(24 + i, e * .5), .9, t + 12, 48 + (8 if e == 0 else 0))
        S.note('cb', S.B(24 + i), 1.4, bass_note(sym, 'E1'), 54)
        S.note('pizz', S.B(24 + i, 1.5), .5, bass_note(sym, 'E1') + 7, 44)
    S.mel('fl', 24, DUMP_JIG_1[:24] + m('r:3 | r:3') + DUMP_JIG_1[24:], 84, legato=.85)
    S.mel('fl', 34, m('E5:3 | r:3 | B5:3 | A5:1.5 G5:1.5 | F#5:3 | E5:3'), 74)

    # Capital tension 40-47: a stiff snare tick, a held pedal, the jig head low in the cello; nothing cadences
    for i in range(8):
        S.note('cb', S.B(40 + i), 3.02, p('B1'), 58)
        S.pad('pad', 40 + i, 'Em' if i % 2 == 0 else 'C', 48, low='G3')
    tick(40, 8, 44)
    S.mel('vc', 40, transpose(DUMP_JIG_HEAD, -12) * 2, 84)
    S.mel('vc', 44, transpose(DUMP_JIG_HEAD, -10) + m('F#4:3 | F#4:3'), 82)
    S.line('hn', 42, m('B3:6 | C4:6'), 50)

    # C 48-63: the Crossroads motif resolved on the flute, chimes, strings warm; the fiddle answers with the theme's second strain
    BH = ['G', 'D', 'Em', 'A', 'G', 'D', 'C', 'A', 'G', 'D', 'Em', 'Bm', 'C', 'D', 'Em', 'A']
    for i, sym in enumerate(BH):
        bar = 48 + i
        ts = voice(sym, 'E3', 4)
        for e, t in enumerate([ts[0], ts[1], ts[2], ts[3], ts[2], ts[1]]):
            S.note('piano', S.B(bar, e * .5), .9, t + 12, 46 + (8 if e == 0 else 0))
        S.note('cb', S.B(bar), 3, bass_note(sym, 'E1'), 52)
        S.chord('vln', S.B(bar), 3.02, voice(sym, 'E4', 3), 44)
        if i % 4 == 0:
            S.note('bells', S.B(bar), 3, ts[-1] + 12, 50)
    S.motif('fl', 48, motif('E5', 'dorian', rhythm=R68, resolved=True) + m('r:3 | r:3'), 82, form='RESOLVED (flute, chimes)')
    S.mel('fid', 52, DUMP_THEME[46:], 80, legato=.9)
    S.swell('vln', 48, 16, 60, 104, 'arch')

    # A' 64-87: tutti, the whole theme, horns; a Capital tick stays faintly underneath
    groove(64, 24, 80)
    tick(64, 24, 34)
    for i in range(24):
        S.chord('hn', S.B(64 + i), 3.02, voice(PR[i % 16], 'G3', 3), 60)
        if i % 4 == 0:
            S.timp_hit(S.B(64 + i), 'E2', 74)
    S.mel('fid', 64, DUMP_THEME, 100, legato=.88)
    S.line('vln', 64, DUMP_THEME, 90, transpose=-12, legato=.88)
    S.line('fl', 64, DUMP_THEME, 74, legato=.85)
    S.motif('hn', 80, motif('E3', 'dorian', rhythm=R68, resolved=True), 84, form='RESOLVED (horns)', lead=False)
    S.mel('fid', 80, DUMP_JIG_1, 98, legato=.88)
    S.hit(57, S.B(64), 74, dur=3, ch='kit')

    intro(88)
    return S
