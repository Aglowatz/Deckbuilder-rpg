"""MUS-MINIGAME-REF - Rhonda's sorting ribbons (a county fair). 48 bars 4/4, 150 BPM, A major, ~77 s. A nimble pluck-and-flute loop:
the Dump's jig theme (zones.DUMP_THEME) as a bright reel in A major, flute and fiddle taking turns, banjo-bright nylon guitar chop, light
hand drums (tambourine, sticks), little scavenged-metal accents (muted triangle, cowbell) and a bright answering phrase on the xylophone -
the Crossroads motif's head turned into the fair's "ding!". Music Pass 2, Batch 08.
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

def build():
    S = Song('MUS-MINIGAME-REF', bpm=150, bars=48, meter=(4, 4), key='A major', seed=511, jitter=0.01)
    setup(S, 'fid', 'fl', 'picc', 'gtr', 'pizz', 'cb', 'xylo', 'harp', 'pad', 'hn', 'kit')
    S.add('banjo', None, 105, pan=30, rev=70, vol=70)
    for bar, nm in ((0, 'intro'), (4, 'A flute reel'), (20, 'B fiddle reel'), (36, 'C answers'), (44, 'outro')):
        S.section(bar, nm)
    TH = to_mode(reel(transpose(DUMP_THEME, 5)), {0: 1, 7: 1})  # A Dorian -> A major (C -> C#, G -> G#)
    PR = [{'Em': 'A', 'D': 'G', 'A': 'D', 'G': 'C'}[c] for c in DUMP_PROG]
    PR = [{'G': 'E', 'C': 'C#m'}.get(c, c) for c in PR]          # bar 2 sits on E, bar 7 on C#m in A major

    def fair(bar, n, v):
        for i in range(n):
            sym = PR[i % 16]
            strum(S, bar + i, sym, v)
            b = bass_note(sym, 'E1')
            S.note('cb', S.B(bar + i), .8, b, v)
            S.note('cb', S.B(bar + i, 2), .8, b + 7, v - 8)
            vv = voice(sym, 'A3', 3)
            for t in (.5, 1.5, 2.5, 3.5):
                S.chord('banjo', S.B(bar + i, t), .3, [x + 12 for x in vv], v - 22)
            S.note('kit', S.B(bar + i), .2, 31, v - 10, human=False)
            S.note('kit', S.B(bar + i, 2), .2, 31, v - 16, human=False)
            S.note('kit', S.B(bar + i, 3.5), .2, 80, v - 18, human=False)
            if i % 4 == 3:
                S.note('kit', S.B(bar + i, 3), .2, 56, v - 14, human=False)
        tamb(S, bar, n, v - 28)

    def ding(bar, v=72):
        S.motif('xylo', bar, motif_head('A5', 'major', rhythm=(.5, .5, 1)), v, form='head (xylophone, the fair\'s ding)', lead=False)

    def intro(bar):
        fair(bar, 4, 66)
        S.pad('pad', bar, 'A', 46, low='C#4', beats=16)
        S.mel('fl', bar, m('E5:1 A5:1 C#6:1 A5:1 | B5:2 G#5:2 | A5:1 E5:1 C#5:1 E5:1 | F#5:2 E5:2'), 72)
        ding(bar + 3, 64)

    intro(0)

    # A 4-19: the reel on the flute
    fair(4, 16, 72)
    S.mel('fl', 4, TH, 88, legato=.85)
    for bar in (7, 11, 15, 19):
        S.line('xylo', bar, m('r:3 E6:.5 A6:.5'), 60)

    # B 20-35: the fiddle takes it, flute an octave up for the second half, the motif stated in the horns
    fair(20, 16, 76)
    S.mel('fid', 20, TH, 94, legato=.88)
    S.line('picc', 28, bars_of(S, TH, 8, 16), 58, legato=.85)
    S.motif('hn', 24, motif('A3', 'major'), 72, form='stated (horns, under the fiddle)', lead=False)
    S.hit(57, S.B(20), 70, dur=2, ch='kit')

    # C 36-43: answers - fiddle and flute trade the jig head, the xylophone dings back
    fair(36, 8, 74)
    head = to_mode(reel(transpose(DUMP_JIG_HEAD, 5)), {0: 1, 7: 1})
    for k, bar in enumerate(range(36, 44, 2)):
        S.mel('fid' if k % 2 == 0 else 'fl', bar, head, 90)
        ding(bar + 1, 70)
    S.motif('fl', 42, motif('A5', 'major')[:4], 84, form='head + turn (flute, closing the answers)', lead=False)

    intro(44)
    return S
