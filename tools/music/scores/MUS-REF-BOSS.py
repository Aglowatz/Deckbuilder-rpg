"""MUS-REF-BOSS - Compostella, the Rotheart. 144 bars 6/8 (q = 156, dotted q = 104), E harmonic minor. A dark fairy tale, grief rather
than a monster. Her own idea is a human lament (COMP: E F E | D# B | C B A G | F# D#), always ending on the leading tone, never home -
first alone on the solo violin, then trapped in ever denser strings and overlapping winds (flute, clarinet, bassoon in canon). Under it the
roots: a contrabass line creeping down by semitones, bassoon and tremolo decay. The Dump's jig theme (zones.DUMP_THEME) appears in minor
(the D's sharpened, so its harmony turns to B7 and G augmented); the Crossroads motif inverted in the horns, then stated against her lament
in the climax. A grief break with fading fairy glimmers precedes it. Music Pass 2, Batch 05.
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

COMP = m('E5:1.5 F5:1 E5:.5 | D#5:2 B4:1 | C5:1 B4:.5 A4:1 G4:.5 | F#4:1.5 D#4:1.5')
R68 = (1.5, .75, .75, 2.25, .75, 3)


def build():
    S = Song('MUS-REF-BOSS', bpm=156, bars=144, meter=(6, 8), key='E harmonic minor', seed=504, jitter=0.012)
    setup(S, 'fid', 'vln', 'fl', 'cl', 'bsn', 'harp', 'cel', 'pizz', 'vc', 'cb', 'hn', 'timp', 'pad', 'trem', 'choir', 'kit')
    for bar, nm in ((0, 'roots'), (8, 'A jig in minor'), (24, 'B lament'), (40, 'C lament trapped'), (56, 'grief break'),
                    (72, 'E drive'), (88, 'F climax'), (112, 'decay'), (128, 'drive again'), (140, 'roots again')):
        S.section(bar, nm)
    THm = to_mode(DUMP_THEME, E_HARM)
    PR = ['Em', 'B7', 'Em', 'Am', 'Em', 'B7', 'Gaug', 'Am'] * 2
    CREEP = ['E2', 'D#2', 'D2', 'C#2', 'C2', 'B1', 'C2', 'B1']
    LH = ['Am', 'B7', 'Am', 'B7', 'C', 'B7', 'Am', 'B7']           # under the lament (4 bars x 2)

    def roots(bar, n, v, k0=0):
        for i in range(n):
            S.note('cb', S.B(bar + i), 3.02, CREEP[(k0 + i) % 8], v)

    def pulse(bar, n, v):
        for i in range(n):
            S.note('kit', S.B(bar + i), .3, 36, v, human=False)
            S.note('kit', S.B(bar + i, 1.5), .3, 35, v - 12, human=False)

    def drive(bar, n, v, theme=True):
        for i in range(n):
            sym = PR[i % 16]
            b = bass_note(sym, 'E1')
            S.note('cb', S.B(bar + i), 1.4, b, v)
            S.note('cb', S.B(bar + i, 1.5), 1.4, b + 7 if sym != 'Gaug' else b + 8, v - 8)
            tn = S.chord_tones(sym, 'E3', 4)
            for k, j in enumerate((0, 1, 2, 1, 2, 3)):
                S.note('pizz', S.B(bar + i, k * .5), .3, tn[j], v - 18 + (8 if k % 3 == 0 else 0))
            S.note('kit', S.B(bar + i), .3, 36, v - 6, human=False)
            S.note('kit', S.B(bar + i, 1.5), .3, 38, v - 20, human=False)
            S.note('kit', S.B(bar + i, 2.5), .3, 35, v - 18, human=False)

    def intro(bar):
        roots(bar, 8, 70)
        pulse(bar, 8, 62)
        for i in range(8):
            S.pad('pad', bar + i, 'Em' if i % 4 < 2 else 'Am', 58, low='B3')
            S.pad('trem', bar + i, 'Em' if i % 4 < 2 else 'B7', 42, low='E4', n=2)
        S.line('bsn', bar, m('E3:3 | D#3:3 | D3:3 | C#3:3 | C3:3 | B2:3 | C3:3 | B2:3'), 60)
        S.mel('fid', bar + 4, m('E5:1.5 F5:1 E5:.5 | D#5:3 | r:3 | r:3'), 70)
        S.motif('hn', bar + 6, motif('E3', 'harmonic', rhythm=R68, inverted=True)[:4], 60, form='inverted head (horns, from the roots)',
                lead=False)

    intro(0)

    # A 8-23: the jig in minor over the drive
    drive(8, 16, 78)
    S.mel('fid', 8, THm, 94, legato=.88)
    for i in range(16):
        if i % 2 == 0:
            S.chord('hn', S.B(8 + i), 1.2, voice(PR[i], 'E3', 3), 66)
    S.timp_hit(S.B(8), 'E2', 86)
    S.timp_roll(S.B(23), 3, 'B1', 50, 96)

    # B 24-39: Compostella's lament on the solo violin, then the flute with denser strings
    for i in range(16):
        sym = LH[i % 8]
        S.pad('pad', 24 + i, sym, 50, low='A3')
        fairy(S, 24 + i, sym, 40 if i < 8 else 30, low='A3', ch1=None)
        roots(24 + i, 1, 62, k0=i)
    S.mel('fid', 24, COMP + COMP, 92)
    S.mel('fl', 32, COMP, 84)
    S.line('vln', 32, transpose(COMP, -12), 66)
    S.mel('fl', 36, transpose(COMP, -2), 86)
    for i in range(8):
        S.pad('trem', 32 + i, LH[i], 50 + i * 3, low='E4', n=3)
    pulse(32, 8, 58)

    # C 40-55: the lament trapped - canon in flute / clarinet / bassoon, string tangle, the motif inverted in the horns
    for i in range(16):
        sym = LH[i % 8]
        S.pad('trem', 40 + i, sym, 62, low='E4', n=4)
        roots(40 + i, 1, 72, k0=i)
        tn = S.chord_tones(sym, 'A3', 5)
        for k in range(6):
            S.note('pizz', S.B(40 + i, k * .5), .3, tn[(0, 1, 0, 2, 1, 3)[k]], 58)
    S.mel('fid', 40, COMP * 4, 96)
    S.line('fl', 41, COMP * 3, 76)
    S.line('cl', 42, transpose(COMP, -12) * 3, 74)
    S.line('bsn', 44, transpose(COMP, -24) * 2, 70)
    S.motif('hn', 48, motif('E4', 'harmonic', rhythm=R68, inverted=True), 92, form='inverted (horns, the question upside down)',
            lead=False)
    S.swell('trem', 40, 16, 60, 118)
    pulse(40, 16, 66)
    S.timp_roll(S.B(54), 6, 'B1', 50, 110)

    # GRIEF 56-71: the cello sings the lament alone, choir breath, celesta glimmers fading; a moment of the jig head in E major
    for i in range(16):
        sym = LH[i % 8] if i < 12 else ['E', 'A', 'E', 'B'][i - 12]
        S.pad('pad', 56 + i, sym, 44, low='A3')
        S.pad('choir', 56 + i, sym, 40, low='E4', n=3)
        S.note('cb', S.B(56 + i), 3, bass_note(sym, 'E1'), 52)
    S.mel('vc', 56, transpose(COMP, -24) + transpose(COMP, -24), 88)
    for bar, v in ((57, 50), (60, 42), (63, 34), (66, 26)):
        fairy(S, bar, 'Am', v, low='A3', ch2=None)
    S.mel('fl', 68, transpose(to_mode(DUMP_JIG_HEAD, E_MAJOR), 0) + m('B5:3 | B5:3'), 66)

    # E 72-87: drive - the jig in minor, the motif's head stabbing in the horns
    drive(72, 16, 84)
    S.mel('fid', 72, THm, 98, legato=.88)
    S.line('vln', 80, THm[46:], 82, transpose=-12, legato=.88)
    for bar in (74, 78, 82, 86):
        S.motif('hn', bar, motif_head('E3', 'harmonic', rhythm=(1.5, .75, .75)), 84, form='head (horns, stabs)', lead=False)
    S.snare_roll(S.B(86), 6, 40, 104, ch='kit')

    # F 88-111: climax - her lament augmented in the horns against the jig; then the Crossroads motif stated against her
    drive(88, 24, 90)
    S.mel('fid', 88, THm, 104, legato=.88)
    S.line('vln', 88, THm, 92, transpose=-12, legato=.88)
    S.line('hn', 88, aug(COMP, 2) + aug(transpose(COMP, -2), 2), 96)
    S.line('choir', 88, aug(COMP, 4), 72)
    for i in range(24):
        S.pad('trem', 88 + i, PR[i % 16], 62, low='E4', n=3)
        if i % 4 == 0:
            S.hit(57, S.B(88 + i), 90, dur=2, ch='kit')
        if i % 2 == 0:
            S.timp_hit(S.B(88 + i), 'E2', 86)
    S.motif('hn', 104, motif('E3', 'harmonic', rhythm=R68), 104, form='stated (horns, the hero answers her)')
    S.line('vln', 104, motif('E4', 'harmonic', rhythm=R68), 96)
    S.mel('fid', 104, COMP + transpose(COMP, -12), 100)
    S.timp_roll(S.B(110), 6, 'E2', 70, 116)

    # DECAY 112-127: thinning - the lament on the solo violin over the creeping roots, one last glimmer
    roots(112, 16, 66)
    for i in range(16):
        S.pad('pad', 112 + i, LH[i % 8], 50 - i, low='A3')
    S.mel('fid', 112, COMP + transpose(COMP, -2) + transpose(COMP, -4) + COMP, 86)
    S.line('bsn', 116, m('E3:3 | D#3:3 | D3:3 | C#3:3 | C3:3 | B2:3 | C3:3 | B2:3'), 56)
    fairy(S, 120, 'Am', 30, low='A3', ch2=None)

    # drive again 128-139
    drive(128, 12, 80)
    S.mel('fid', 128, THm[:46], 96, legato=.88)
    S.line('fl', 136, COMP, 70)

    # ROOTS 140-143: as bar 0 (first half)
    roots(140, 4, 70)
    pulse(140, 4, 62)
    for i in range(4):
        S.pad('pad', 140 + i, 'Em' if i < 2 else 'Am', 58, low='B3')
        S.pad('trem', 140 + i, 'Em' if i < 2 else 'B7', 42, low='E4', n=2)
    S.line('bsn', 140, m('E3:3 | D#3:3 | D3:3 | C#3:3'), 60)
    S.tag_melody('bsn', 140, 144)
    return S
