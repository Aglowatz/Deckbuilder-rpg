"""MUS-REF-DUN-EXP - The Rotheart, exploration. 88 bars 6/8 (q = 120, dotted q = 40), B minor. Darker than the Dump: a cello drone on B,
the jig theme (zones.DUMP_THEME, taken to B Aeolian) slowed to half speed on the solo violin, and ostinatos that keep accumulating - a
pizzicato cell of close steps, a harp cell five eighths long against the six-eighth bar, bassoon seconds - until the growth feels wrong.
The demo's fairy glimmers appear and fade a little more each time. Once, everything drops away for a clean spring glimpse (D major, harp,
celesta, the Crossroads motif on the flute), then the tangle returns with the theme in canon. Music Pass 2, Batch 05.
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
    S = Song('MUS-REF-DUN-EXP', bpm=120, bars=88, meter=(6, 8), key='B minor', seed=502, jitter=0.012)
    setup(S, 'fid', 'vln', 'fl', 'harp', 'cel', 'bells', 'pizz', 'vc', 'cb', 'hn', 'timp', 'pad', 'trem', 'bsn', 'kit')
    for bar, nm in ((0, 'drone'), (8, 'A slow theme'), (24, 'B tangle grows'), (40, 'spring glimpse'), (48, "A' cello theme"),
                    (64, 'C canon, overgrown'), (80, 'drone again')):
        S.section(bar, nm)
    THm = transpose(to_mode(DUMP_THEME, E_MINOR), -5)              # B Aeolian
    SLOW = aug(THm[:46], 2)                                        # the first strain at half speed: 16 bars
    PR = [{'Em': 'Bm', 'D': 'A', 'A': 'Em', 'G': 'D'}[c] for c in DUMP_PROG]

    def drone(bar, bars, v):
        for i in range(bars):
            S.note('vc', S.B(bar + i), 3.02, p('B2'), v)
            S.note('cb', S.B(bar + i), 3.02, p('B1'), v - 4)

    def tangle(bar, bars, v, layers=1):
        """Accumulating ostinatos: 1 = pizz close steps; 2 = + the harp's 5-eighth cell; 3 = + bassoon seconds."""
        end = S.B(bar + bars)
        cell = ['B3', 'C#4', 'D4', 'C#4', 'B3', 'A#3']
        t, k = S.B(bar), 0
        while t < end - 1e-6:
            S.note('pizz', t, .3, cell[k % 6], v + (8 if k % 6 == 0 else 0))
            t += .5
            k += 1
        if layers >= 2:
            hc = ['F#4', 'G4', 'B4', 'G4', 'C5']
            t, k = S.B(bar), 0
            while t < end - 1e-6:
                S.note('harp', t, .9, hc[k % 5], v - 8)
                t += .5
                k += 1
        if layers >= 3:
            for i in range(bars):
                S.note('bsn', S.B(bar + i), 1.4, p('C3') if i % 2 else p('C#3'), v - 4)
                S.note('bsn', S.B(bar + i, 1.5), 1.4, p('D3'), v - 10)

    def glimmer(bar, v):
        fairy(S, bar, 'Bm', v, low='F#3')

    def intro(bar):
        drone(bar, 8, 56)
        for i in range(8):
            S.pad('pad', bar + i, 'Bm' if i % 4 < 2 else 'Gmaj7', 46, low='D3')
        for i, v in ((0, 54), (2, 46), (4, 38), (6, 30)):
            glimmer(bar + i, v)
        S.note('bells', S.B(bar), 3, p('B4'), 50)
        S.mel('fid', bar + 4, m('F#5:3 | E5:1.5 D5:1.5 | C#5:3 | B4:3'), 62)

    intro(0)

    # A 8-23: the theme at half speed on the solo violin over the drone and the first ostinato
    drone(8, 16, 60)
    tangle(8, 16, 46, layers=1)
    for i in range(16):
        S.pad('pad', 8 + i, PR[i % 16], 42, low='D3')
    S.mel('fid', 8, SLOW, 80, legato=.96)
    glimmer(16, 34)

    # B 24-39: the tangle grows (all three cells), canonic theme heads overlap, it swells
    drone(24, 16, 66)
    tangle(24, 8, 54, layers=2)
    tangle(32, 8, 60, layers=3)
    head = transpose(to_mode(DUMP_JIG_HEAD, E_MINOR), -5)
    for k, (ch, bar, tr) in enumerate((('fid', 24, 0), ('fl', 25, 7), ('vln', 28, -5), ('fid', 30, 1), ('fl', 31, 6), ('vln', 34, -4),
                                         ('fid', 36, 0), ('fl', 37, 5))):
        S.line(ch, bar, transpose(head, tr), 70 + k * 3, role='mel' if ch == 'fid' else None)
    S.mel('fid', 32, m('B5:3 | C6:3 | B5:1.5 A#5:1.5 | B5:3'), 82)
    S.pad('trem', 32, 'Bm', 50, low='B3', n=3, beats=24)
    S.swell('trem', 32, 8, 50, 110)
    S.motif('hn', 28, motif('B2', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 70, form='stated low (horns, choked by the tangle)',
            lead=False)
    S.timp_roll(S.B(39), 3, 'B1', 40, 90)

    # SPRING 40-47: everything drops away - a clean D major glimpse, harp and celesta, the Crossroads motif on the flute
    for i, sym in enumerate(['D', 'G', 'D', 'A', 'D', 'G', 'Em', 'F#']):
        fairy(S, 40 + i, sym, 52, low='D3')
        S.pad('pad', 40 + i, sym, 40, low='D3')
        S.note('cb', S.B(40 + i), 3, bass_note(sym, 'E1'), 46)
    S.motif('fl', 40, motif('D5', 'major', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 78, form='stated (flute, the spring glimpse)')
    S.mel('fl', 43, transpose(DUMP_JIG_HEAD, -2), 70)                # the jig head clean, in D
    S.note('bells', S.B(40), 3, p('D5'), 56)
    S.note('bells', S.B(44), 3, p('A4'), 50)
    S.mel('fid', 45, m('F#5:3 | E5:3 | A#4:3'), 64)

    # A' 48-63: the theme in the cello (low), the tangle over it, tremolo
    tangle(48, 16, 52, layers=2)
    for i in range(16):
        S.pad('trem', 48 + i, PR[i], 48, low='D4', n=3)
        S.note('cb', S.B(48 + i), 3, bass_note(PR[i], 'E1'), 58)
    S.mel('vc', 48, transpose(SLOW, -12), 86, legato=.98)
    glimmer(52, 30)
    glimmer(58, 24)

    # C 64-79: overgrown - the theme in canon (violin, then violins a bar later, flute a bar after that), horns in close seconds
    tangle(64, 16, 60, layers=3)
    drone(64, 16, 70)
    S.mel('fid', 64, THm[:46], 90, legato=.9)
    S.line('vln', 65, THm[:46], 76, transpose=-12, legato=.9)
    S.line('fl', 66, THm[:46], 66, legato=.88)
    S.mel('fid', 72, transpose(THm[46:92], 0), 94, legato=.9)
    S.line('vln', 73, THm[46:92], 80, transpose=-12, legato=.9)
    for i in range(16):
        S.chord('hn', S.B(64 + i), 3.02, ['B3', 'C4'] if i % 2 == 0 else ['A#3', 'B3'], 52 + i)
    S.motif('vln', 76, motif_tail('B4', 'minor', rhythm=(1.5, 1.5, 3)), 84, form='tail (violins, caught in the canon)', lead=False)
    S.timp_hit(S.B(64), 'B1', 80)
    S.timp_hit(S.B(72), 'B1', 86)
    S.timp_roll(S.B(78), 6, 'B1', 80, 40)
    S.swell('vln', 76, 4, 110, 80)

    # DRONE 80-87: as bar 0
    intro(80)
    S.tag_melody('fid', 0, 8)
    return S
