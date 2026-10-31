"""MUS-SHOP-GRISTLE - Found, not stolen (Gristle's shop). 56 bars 6/8 (q = 144, dotted q = 48), D major, ~70 s. A relaxed porch
tune: the Dump's jig theme (zones.DUMP_THEME) taken to D major and played easy on the flute over nylon guitar, harp and a plucked bass;
soft salvaged-metal percussion (muted triangle, a quiet cowbell, tambourine); curious little raccoon counterphrases on the xylophone and
piccolo that sneak in at the ends of phrases. The Crossroads motif on the solo violin in the middle. Music Pass 2, Batch 08.
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
    S = Song('MUS-SHOP-GRISTLE', bpm=144, bars=56, meter=(6, 8), key='D major', seed=510, jitter=0.014)
    setup(S, 'fid', 'fl', 'picc', 'gtr', 'harp', 'pizz', 'vc', 'cb', 'xylo', 'pad', 'cel', 'kit', gtr=78)
    for bar, nm in ((0, 'porch'), (4, 'A flute'), (20, 'B fiddle question'), (28, "A' with harp"), (44, 'raccoon coda'), (52, 'porch again')):
        S.section(bar, nm)
    TH = to_mode(transpose(DUMP_THEME, -2), {0: 1, 5: 1})       # E Dorian down a tone = D Dorian -> D major (C -> C#, F -> F#)
    PR = [{'Em': 'D', 'D': 'C', 'A': 'G', 'G': 'F'}[c] for c in DUMP_PROG]
    PR = [{'C': 'A', 'F': 'F#m'}.get(c, c) for c in PR]          # in D major: D A D G | D A F#m G

    def metal(bar, n, v):
        for i in range(n):
            S.note('kit', S.B(bar + i, 1.5), .2, 80, v, human=False)
            S.note('kit', S.B(bar + i, 2.5), .2, 80, v - 10, human=False)
            S.note('kit', S.B(bar + i), .2, 54, v - 6, human=False)
            if i % 4 == 3:
                S.note('kit', S.B(bar + i, 2), .2, 56, v - 16, human=False)

    def porch(bar, n, v):
        for i in range(n):
            sym = PR[i % 16]
            strum(S, bar + i, sym, v)
            bassline(S, bar + i, sym, v - 6)
        metal(bar, n, v - 26)

    def raccoon(bar, ch='xylo'):
        S.line(ch, bar, m('r:1.5 A5:.5 B5:.5 C#6:.5'), 58)

    def intro(bar):
        porch(bar, 4, 60)
        S.pad('pad', bar, 'D', 40, low='F#3', beats=12)
        S.mel('fl', bar, m('A5:1.5 F#5:1.5 | D5:3 | E5:1.5 F#5:1.5 | A5:3'), 66)
        raccoon(bar + 3)

    intro(0)

    # A 4-19: the theme, easy, on the flute
    porch(4, 16, 66)
    S.mel('fl', 4, TH, 80, legato=.85)
    raccoon(11)
    raccoon(19, 'picc')

    # B 20-27: the fiddle asks the Crossroads question; pizzicato and harp under
    for i, sym in enumerate(['G', 'D', 'Em', 'A', 'G', 'D', 'Bm', 'A']):
        bar = 20 + i
        fairy(S, bar, sym, 40, low='D3', ch1=None)
        S.note('cb', S.B(bar), 1.4, bass_note(sym, 'E1'), 54)
        S.note('pizz', S.B(bar, 1.5), .5, bass_note(sym, 'E1') + 7, 46)
        metal(bar, 1, 38)
    S.motif('fid', 20, motif('D5', 'major', rhythm=R68), 78, form='stated (solo violin, the question)')
    S.mel('fid', 23, m('r:1 F#5:.5 G5:.5 A5:1 | B5:3'), 70)
    S.mel('fl', 24, to_mode(transpose(DUMP_JIG_HEAD, -2), {0: 1, 5: 1}) + m('D5:3 | r:3'), 76)
    raccoon(27)

    # A' 28-43: the theme again, the harp rippling, the fiddle an octave below
    porch(28, 16, 70)
    S.mel('fl', 28, TH, 82, legato=.85)
    S.line('fid', 28, TH, 58, transpose=-12, legato=.85)
    for bar in (28, 32, 36, 40):
        fairy(S, bar, PR[bar - 28], 36, low='D3', ch2=None)
    raccoon(35)
    raccoon(43, 'picc')

    # coda 44-51: the raccoon counterphrases take over, the motif's head and the theme head trade
    porch(44, 8, 62)
    for bar in (44, 46, 48, 50):
        S.line('xylo', bar, m('r:1.5 A5:.5 B5:.5 C#6:.5 | D6:1.5 r:1.5'), 88, role='mel')
    S.motif('fid', 45, motif_head('D5', 'major', rhythm=(1.5, .75, .75)), 70, form='head (violin, trading with the xylophone)', lead=False)
    S.line('fl', 49, to_mode(transpose(DUMP_JIG_HEAD, -2), {0: 1, 5: 1})[:6], 66)

    intro(52)
    return S
