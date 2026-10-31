"""MUS-REF-DUN-BATTLE - The Rotheart, combat. 156 bars 6/8 (q = 186, dotted q = 124), E minor. The Dump's jig theme (zones.DUMP_THEME
in E Aeolian) at fighting speed on the solo violin, over the nylon guitar, a moving bass line (each bar steps toward the next chord),
deeper drums (concert bass drum on the off-pulse, timpani) and the Rotheart's tangled ostinatos (a close-step pizzicato cell, a harp cell
five eighths long, bassoon seconds). Sustained-tension passages (tremolo, the theme augmented in the horns) alternate with active ones;
the Crossroads motif sounds in the horns through the tangle, and once a clean spring glimpse breaks through. Music Pass 2, Batch 05.
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
    S = Song('MUS-REF-DUN-BATTLE', bpm=186, bars=156, meter=(6, 8), key='E minor', seed=503, jitter=0.01)
    setup(S, 'fid', 'vln', 'fl', 'gtr', 'harp', 'cel', 'bells', 'pizz', 'vc', 'cb', 'hn', 'timp', 'pad', 'trem', 'bsn', 'kit')
    for bar, nm in ((0, 'intro'), (4, 'A jig'), (20, 'B tangle + motif'), (36, 'sustained tension'), (52, 'C fiddle variation'),
                    (68, 'spring glimpse'), (76, 'D cello theme, build'), (92, "A' tutti"), (108, "B' tangle tutti"),
                    (124, 'E climax canon'), (140, 'wind-down'), (152, 'outro')):
        S.section(bar, nm)
    TH = to_mode(DUMP_THEME, E_MINOR)
    PR = ['Em', 'D', 'Em', 'Am', 'Em', 'D', 'G', 'Am'] * 2

    def mbass(bar, sym, nxt, v):
        b = bass_note(sym, 'E1')
        n = bass_note(nxt, 'E1')
        S.note('cb', S.B(bar), 1.4, b, v + 6)
        S.note('cb', S.B(bar, 1.5), 1.4, n - 2 if n - 2 >= p('E1') else b + 7, v - 4)

    def deep(bar, v):
        S.note('kit', S.B(bar), .3, 36, v + 8, human=False)
        S.note('kit', S.B(bar, 2.5), .3, 35, v - 6, human=False)
        S.note('kit', S.B(bar, 1.5), .3, 38, v - 10, human=False)
        tamb(S, bar, 1, v - 24)

    def tangle(bar, bars, v, layers=1):
        end = S.B(bar + bars)
        cell = ['E4', 'F#4', 'G4', 'F#4', 'E4', 'D#4']
        t, k = S.B(bar), 0
        while t < end - 1e-6:
            S.note('pizz', t, .3, cell[k % 6], v + (8 if k % 6 == 0 else 0))
            t, k = t + .5, k + 1
        if layers >= 2:
            hc = ['B4', 'C5', 'E5', 'C5', 'F5']
            t, k = S.B(bar), 0
            while t < end - 1e-6:
                S.note('harp', t, .9, hc[k % 5], v - 8)
                t, k = t + .5, k + 1
        if layers >= 3:
            for i in range(bars):
                S.note('bsn', S.B(bar + i), 1.4, p('F3') if i % 2 else p('F#3'), v - 4)
                S.note('bsn', S.B(bar + i, 1.5), 1.4, p('G3'), v - 10)

    def groove(bar, n, v, drums_on=True, gtr=True):
        for i in range(n):
            sym, nxt = PR[i % 16], PR[(i + 1) % 16]
            if gtr:
                strum(S, bar + i, sym, v)
            mbass(bar + i, sym, nxt, v)
            if drums_on:
                deep(bar + i, v - 10)

    def intro(bar):
        for i, sym in enumerate(['Em', 'C', 'Am', 'B']):
            S.pad('pad', bar + i, sym, 62, low='B3')
            S.pad('hn', bar + i, sym, 56, low='E3', n=2)
            S.note('cb', S.B(bar + i), 1.4, bass_note(sym, 'E1'), 74)
            S.note('cb', S.B(bar + i, 1.5), 1.4, bass_note(sym, 'E1') + 7, 66)
            deep(bar + i, 66)
            strum(S, bar + i, sym, 64)
        tangle(bar, 4, 50)
        S.mel('fid', bar, m('E5:3 | G5:3 | A5:1.5 C6:1.5 | B5:3'), 74)

    intro(0)

    # A 4-19: the jig at fighting speed
    groove(4, 16, 78)
    S.mel('fid', 4, TH, 94, legato=.88)
    S.line('fl', 12, TH[46:], 64, legato=.85)
    S.timp_hit(S.B(4), 'E2', 84)

    # B 20-35: the tangle, the theme head in canon, the Crossroads motif in the horns
    groove(20, 16, 74, gtr=False)
    tangle(20, 8, 56, layers=2)
    tangle(28, 8, 60, layers=3)
    head = to_mode(DUMP_JIG_HEAD, E_MINOR)
    for k, (ch, bar, tr) in enumerate((('fid', 20, 0), ('vln', 21, -5), ('fid', 24, 2), ('vln', 25, -3), ('fid', 30, 0), ('vln', 31, -5),
                                         ('fid', 32, 3), ('vln', 33, -2))):
        S.line(ch, bar, transpose(head, tr), 82 + k, role='mel' if ch == 'fid' else None)
    S.motif('hn', 26, motif('E3', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 94, form='stated (horns through the tangle)', lead=False)
    S.mel('fid', 26, m('B5:3 | C6:3 | B5:3'), 84)
    S.timp_roll(S.B(35), 3, 'E2', 50, 100)

    # sustained tension 36-51: tremolo chords, the theme's first bars augmented in the horns, a low pulse
    TS = ['Em', 'Em', 'C', 'C', 'Am', 'Am', 'B', 'B']
    for i in range(16):
        sym = TS[i % 8]
        S.pad('trem', 36 + i, sym, 58, low='E4', n=3)
        S.pad('pad', 36 + i, sym, 54, low='B3')
        S.note('cb', S.B(36 + i), 3, bass_note(sym, 'E1'), 70)
        S.note('kit', S.B(36 + i), .3, 36, 70, human=False)
        if i % 2 == 1:
            S.timp_hit(S.B(36 + i, 1.5), 'E2' if sym != 'B' else 'B1', 62)
    S.mel('hn', 36, aug(TH[:23], 2), 86)
    S.line('fid', 44, m('E6:6 | D#6:6 | E6:3 F#6:3 | G6:6'), 70)
    S.swell('trem', 36, 16, 60, 115, 'arch')

    # C 52-67: running fiddle variation over the theme in the violins
    groove(52, 16, 82)
    for i in range(16):
        tn = S.chord_tones(PR[i], 'E5' if i % 4 < 2 else 'B4', 6)
        for k, j in enumerate((0, 1, 2, 3, 2, 1)):
            S.note('fid', S.B(52 + i, k * .5), .45, tn[j], 90 + (8 if k % 3 == 0 else 0), role='mel')
    S.line('vln', 52, TH, 80, transpose=-12, legato=.9)
    S.hit(57, S.B(52), 80, dur=2, ch='kit')

    # SPRING 68-75: a clean glimpse - G major, harp and celesta, the jig head on the flute, chimes
    for i, sym in enumerate(['G', 'D', 'C', 'G', 'G', 'D', 'C', 'B']):
        fairy(S, 68 + i, sym, 56, low='D3')
        S.note('cb', S.B(68 + i), 3, bass_note(sym, 'E1'), 54)
        S.pad('pad', 68 + i, sym, 44, low='B3')
        tamb(S, 68 + i, 1, 34)
    S.mel('fl', 68, transpose(DUMP_JIG_HEAD, 3) + transpose(DUMP_JIG_HEAD, 3), 82)
    S.mel('fid', 72, m('B5:3 | A5:3 | G5:3 | F#5:3'), 76)
    S.note('bells', S.B(68), 3, p('G5'), 58)

    # D 76-91: the theme low in the cello, the tangle building, a snare build
    groove(76, 16, 72, gtr=False)
    tangle(76, 16, 54, layers=2)
    S.mel('vc', 76, transpose(TH, -12), 92, legato=.9)
    S.swell('vc', 76, 16, 90, 120)
    S.snare_roll(S.B(88), 12, 36, 104, ch='kit')
    S.timp_roll(S.B(90), 6, 'E2', 50, 108)

    # A' 92-107: tutti jig
    groove(92, 16, 88)
    for i in range(16):
        S.pad('hn', 92 + i, PR[i], 66, low='E3', n=3)
        if i % 2 == 0:
            S.timp_hit(S.B(92 + i), 'E2', 86)
    S.mel('fid', 92, TH, 104, legato=.88)
    S.line('vln', 92, TH, 92, transpose=-12, legato=.88)
    S.line('fl', 92, TH, 78, legato=.85)
    S.hit(57, S.B(92), 90, dur=3, ch='kit')

    # B' 108-123: the tangle tutti, the motif in horns and violins
    groove(108, 16, 80, gtr=False)
    tangle(108, 16, 62, layers=3)
    S.motif('hn', 108, motif('E3', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 100, form='stated (horns, tutti)')
    S.line('vln', 108, motif('E4', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 90)
    S.motif('hn', 116, motif('A3', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 102, form='stated a fourth up (horns)')
    S.line('vln', 116, motif('A4', 'minor', rhythm=(1.5, .75, .75, 2.25, .75, 3)), 92)
    S.mel('fid', 111, head + transpose(head, 2), 90)
    S.mel('fid', 119, transpose(head, 5) + transpose(head, 7), 92)
    S.timp_roll(S.B(123), 3, 'E2', 60, 110)

    # E 124-139: climax - the theme in canon (violin, violins a bar later), horns augmented underneath
    groove(124, 16, 92)
    S.mel('fid', 124, TH, 106, legato=.88)
    S.line('vln', 125, TH, 90, legato=.88)
    S.line('hn', 124, aug(TH[:23], 2) + aug(TH[46:69], 2), 84)
    S.line('fl', 124, TH, 72, transpose=12, legato=.85)
    for bar in (124, 128, 132, 136):
        S.hit(57, S.B(bar), 92, dur=2, ch='kit')

    # wind-down 140-151: sustained again, thinning to the intro
    for i in range(12):
        sym = TS[i % 8]
        S.pad('trem', 140 + i, sym, 60 - i * 2, low='E4', n=3)
        S.pad('pad', 140 + i, sym, 58, low='B3')
        S.note('cb', S.B(140 + i), 1.4, bass_note(sym, 'E1'), 74)
        S.note('cb', S.B(140 + i, 1.5), 1.4, bass_note(sym, 'E1') + 7, 66)
        deep(140 + i, 64)
    S.mel('fid', 140, aug(head, 2), 84)
    S.mel('fid', 144, aug(transpose(head, -2), 2), 80)
    tangle(148, 4, 48)

    # OUTRO 152-155: as the intro
    intro(152)
    return S
