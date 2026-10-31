"""MUS-REF-FREED - The Verdant Dump, restored. 120 bars 6/8 (q = 168, dotted q = 112), E major. Spring returning: the Dump's jig theme
(zones.DUMP_THEME) taken to E major (G -> G#, D -> D#), first on a clear flute over the nylon guitar and harp, then the fiddle and the
violins. Chimes (tubular bells), harp and celesta glimmers, rests that breathe. The Crossroads motif comes RESOLVED (it falls home to E),
and Compostella's lament from the boss returns in major on the cello, now landing on the tonic: the ending accepts loss rather than
erasing it. Music Pass 2, Batch 05.
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
COMP_MAJ = m('E5:1.5 F#5:1 E5:.5 | D#5:2 B4:1 | C#5:1 B4:.5 A4:1 G#4:.5 | F#4:1.5 D#4:1.5 | E4:3 | r:3')


def build():
    S = Song('MUS-REF-FREED', bpm=168, bars=120, meter=(6, 8), key='E major', seed=505, jitter=0.012)
    setup(S, 'fid', 'vln', 'fl', 'picc', 'gtr', 'piano', 'harp', 'cel', 'bells', 'pizz', 'vc', 'cb', 'hn', 'timp', 'glock', 'kit')
    for bar, nm in ((0, 'spring glimmer'), (8, 'A flute jig'), (24, "A' fiddle"), (40, 'B resolved motif'), (56, 'C fiddle variation'),
                    (72, 'D the lament in major'), (88, "A'' tutti"), (112, 'outro glimmer')):
        S.section(bar, nm)
    TH = to_mode(DUMP_THEME, E_MAJOR)
    PR = ['E', 'B', 'E', 'A', 'E', 'B', 'E', 'A'] * 2       # bar 7 of the theme (G# D# B G# B D#) sits on G#m: kept on E for warmth

    def groove(bar, n, v, tam=True, piano=False):
        for i in range(n):
            sym = PR[i % 16]
            strum(S, bar + i, sym, v)
            bassline(S, bar + i, sym, v)
            if piano:
                vv = voice(sym, 'B3', 3)
                S.chord('piano', S.B(bar + i, .5), .4, [t + 12 for t in vv], v - 20)
                S.chord('piano', S.B(bar + i, 2), .4, [t + 12 for t in vv], v - 24)
        if tam:
            tamb(S, bar, n, v - 30)

    def intro(bar):
        for i, sym in enumerate(['E', 'A', 'E', 'B', 'E', 'A', 'C#m', 'B']):
            if i % 2 == 0:
                fairy(S, bar + i, sym, 52, low='E3')
            if i >= 4:
                strum(S, bar + i, sym, 58)
                bassline(S, bar + i, sym, 56)
        S.note('bells', S.B(bar), 4, p('E5'), 58)
        S.note('bells', S.B(bar + 4), 4, p('B4'), 52)
        S.mel('fl', bar + 2, m('B5:1.5 G#5:1.5 | E5:3'), 58)
        S.mel('fl', bar + 6, m('B5:1.5 A5:1.5 | G#5:1.5 F#5:1.5'), 56)

    intro(0)

    # A 8-23: the jig in major on a clear flute
    groove(8, 16, 68)
    S.mel('fl', 8, TH, 88, legato=.85)
    S.chord('vln', S.B(8), 24, ['E4', 'B4'], 34)
    fairy(S, 15, 'A', 40, low='E3')

    # A' 24-39: fiddle and violins, piano off-beats, horns
    groove(24, 16, 74, piano=True)
    for i in range(16):
        S.chord('hn', S.B(24 + i), 3.02, voice(PR[i], 'G#3', 2), 50)
    S.mel('fid', 24, TH, 94, legato=.88)
    S.line('vln', 24, TH, 80, transpose=-12, legato=.88)
    S.timp_hit(S.B(24), 'E2', 70)
    S.note('glock', S.B(39, 1.5), 1.5, p('E6'), 58)

    # B 40-55: the resolved Crossroads motif - slow on the flute, strings sweep, chimes, the cello answers, rests
    BH = ['A', 'E', 'F#m', 'B', 'A', 'E', 'C#m', 'B', 'A', 'B', 'G#m', 'C#m', 'A', 'B', 'E', 'E']
    for i, sym in enumerate(BH):
        bar = 40 + i
        ts = voice(sym, 'E3', 4)
        for e, t in enumerate([ts[0], ts[1], ts[2], ts[3], ts[2], ts[1]]):
            S.note('harp', S.B(bar, e * .5), .9, t + 12, 50 + (8 if e == 0 else 0))
        S.note('cb', S.B(bar), 3, bass_note(sym, 'E1'), 54)
        S.chord('vln', S.B(bar), 3.02, voice(sym, 'E4', 3), 44)
        if i % 4 == 0:
            S.note('bells', S.B(bar), 3, ts[-1] + 12, 50)
    S.motif('fl', 40, aug(motif('E5', 'major', rhythm=R68, resolved=True), 1.0) + m('r:6'), 84, form='RESOLVED (flute)')
    S.mel('vc', 44, transpose(COMP_MAJ[:9], -12), 74)
    S.motif('fl', 48, motif('E5', 'major', rhythm=R68, resolved=True), 88, form='RESOLVED again (flute + fiddle 8vb)')
    S.line('fid', 48, motif('E4', 'major', rhythm=R68, resolved=True), 70)
    S.mel('fid', 52, transpose(DUMP_JIG_HEAD, 0)[:6] + m('E5:3 | r:3'), 72)
    S.swell('vln', 40, 16, 60, 108, 'arch')

    # C 56-71: the fiddle variation in major, the theme in the violins
    groove(56, 16, 78)
    for i in range(16):
        tn = S.chord_tones(PR[i], 'E5' if i % 4 < 2 else 'B4', 6)
        for k, j in enumerate((0, 1, 2, 3, 2, 1)):
            S.note('fid', S.B(56 + i, k * .5), .45, tn[j], 88 + (8 if k % 3 == 0 else 0), role='mel')
        S.chord('pizz', S.B(56 + i, 1), .3, voice(PR[i], 'G#3', 3), 54)
    S.line('vln', 56, TH, 78, transpose=-12, legato=.9)
    S.line('glock', 64, TH[46:70], 50)
    S.hit(57, S.B(56), 64, dur=2, ch='kit')

    # D 72-87: Compostella's lament in major, landing home on the cello; harp, celesta, a breath of rest
    DH = ['A', 'B', 'A', 'B', 'E', 'E', 'A', 'B', 'C#m', 'B', 'A', 'E', 'A', 'B', 'E', 'E']
    for i, sym in enumerate(DH):
        S.note('cb', S.B(72 + i), 3, bass_note(sym, 'E1'), 50)
        S.chord('vln', S.B(72 + i), 3.02, voice(sym, 'G#3', 3), 40)
        if i % 2 == 0:
            fairy(S, 72 + i, sym, 40, low='E3', ch2=None)
    S.mel('vc', 72, transpose(COMP_MAJ, -12), 86)
    S.mel('fl', 78, COMP_MAJ, 80)
    S.mel('fid', 84, m('B5:3 | G#5:1.5 E5:1.5 | F#5:3 | E5:3'), 74)
    S.note('bells', S.B(77), 3, p('E5'), 54)
    S.timp_roll(S.B(87), 3, 'B1', 34, 80)

    # A'' 88-111: tutti - the whole jig in major, glock, piccolo, chimes; the resolved motif in the horns to finish
    groove(88, 24, 84, piano=True)
    for i in range(24):
        S.chord('hn', S.B(88 + i), 3.02, voice(PR[i % 16], 'G#3', 3), 64)
        S.note('vc', S.B(88 + i), 1.4, bass_note(PR[i % 16], 'E1') + 12, 70)
        if i % 2 == 0:
            S.timp_hit(S.B(88 + i), 'E2' if PR[i % 16] != 'B' else 'B1', 80)
    S.mel('fid', 88, TH, 104, legato=.88)
    S.line('vln', 88, TH, 94, transpose=-12, legato=.88)
    S.line('fl', 88, TH, 78, legato=.85)
    S.line('picc', 96, TH[46:], 56, transpose=12)
    S.line('glock', 88, TH[:24], 54, transpose=12)
    S.hit(57, S.B(88), 84, dur=3, ch='kit')
    S.note('bells', S.B(88), 3, p('E5'), 66)
    S.note('bells', S.B(96), 3, p('B4'), 62)
    S.motif('hn', 104, motif('E3', 'major', rhythm=R68, resolved=True), 96, form='RESOLVED (horns, tutti)', lead=False)
    S.mel('fid', 104, motif('E5', 'major', rhythm=R68, resolved=True) + m('r:6'), 100)
    S.line('vln', 104, motif('E4', 'major', rhythm=R68, resolved=True), 88)

    # OUTRO 112-119: the glimmer, the guitar keeps the pulse into the loop
    intro(112)
    S.fade_vel(116, 120, 0.88, ['gtr', 'cb', 'pizz', 'fl'])   # the guitar falls away into the glimmer at the loop point
    return S
