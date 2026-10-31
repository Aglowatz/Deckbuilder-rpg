"""MUS-PANDA-BOSS - His Majesty the Raccoon. 76 bars 4/4, 134 BPM, B minor. His own idea is KING: a pompous little dotted fanfare that
climbs to its top note and then slinks down chromatically (B B F# E D C# | D C# B A#) - grandeur with nothing behind it, a nervous regal
flourish blown up to a royal anthem. Trash-can drums (concert bass drum, snare, cowbell, sticks, muted triangle). The Dump's jig theme
(zones.DUMP_THEME, in B minor) drives the B section on the fiddle; a comic collapse puts KING on a lone bassoon and xylophone; in the
climax the hero's Crossroads motif in the horns fights KING in the trumpets and trombones. Music Pass 2, Batch 08 (its own boss track,
no longer MUS-PANDA-BATTLE's file).
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

KING = m('B4:.75 B4:.25 F#5:1 E5:.5 D5:.5 C#5:1 | D5:.75 C#5:.25 B4:1 A#4:2 | B4:.75 B4:.25 G5:1 F#5:.5 E5:.5 D5:1 | C#5:1.5 D5:.5 E5:1 F#5:1')
KING_H = ['Bm', 'F#', 'Em', 'F#']


def build():
    S = Song('MUS-PANDA-BOSS', bpm=134, bars=76, meter=(4, 4), key='B minor', seed=509, jitter=0.01)
    setup(S, 'fid', 'vln', 'fl', 'tpt', 'tbn', 'hn', 'bsn', 'xylo', 'pizz', 'vc', 'cb', 'timp', 'pad', 'trem', 'gtr', 'kit')
    for bar, nm in ((0, 'intro'), (4, 'A KING'), (20, 'B jig drive'), (36, 'C comic collapse'), (44, 'D climax'), (60, 'E drive'),
                    (68, 'wind-down'), (72, 'outro')):
        S.section(bar, nm)
    THm = reel(transpose(to_mode(DUMP_THEME, E_MINOR), -5))         # B Aeolian
    PR = [{'Em': 'Bm', 'D': 'A', 'A': 'Em', 'G': 'D'}[c] for c in DUMP_PROG]
    S.notes.append('Villain idea = KING (dotted fanfare + chromatic slink); own boss track since Music Pass 2.')

    def cans(bar, n, v, busy=False):
        for i in range(n):
            S.note('kit', S.B(bar + i), .3, 36, v + 6, human=False)
            S.note('kit', S.B(bar + i, 2), .3, 36, v - 4, human=False)
            S.note('kit', S.B(bar + i, 1), .3, 38, v - 6, human=False)
            S.note('kit', S.B(bar + i, 3), .3, 38, v, human=False)
            for t in (.5, 1.5, 2.5, 3.5):
                S.note('kit', S.B(bar + i, t), .2, 80, v - 14, human=False)
            if busy:
                S.note('kit', S.B(bar + i, 3.5), .2, 56, v - 8, human=False)
                S.note('kit', S.B(bar + i, 1.75), .2, 31, v - 10, human=False)

    def low(bar, sym, v):
        b = bass_note(sym, 'E1')
        for k in range(4):
            S.note('cb', S.B(bar, k), .7, b if k % 2 == 0 else b + 7, v + (6 if k == 0 else -4))

    def intro(bar):
        for i, sym in enumerate(['Bm', 'Bm', 'G', 'F#']):
            low(bar + i, sym, 72)
            S.pad('pad', bar + i, sym, 62, low='B3')
            S.pad('trem', bar + i, sym, 50, low='F#4', n=2)
            S.chord('tbn', S.B(bar + i), .6, voice(sym, 'B2', 2), 70)
        cans(bar, 4, 64)
        S.mel('tpt', bar, m('B4:.75 B4:.25 F#5:2 r:1 | B4:.75 B4:.25 G5:1 F#5:1 E#5:1'), 86)
        S.motif('hn', bar + 2, motif('B3', 'minor')[:3], 70, form='head (horns, under the fanfare)', lead=False)

    intro(0)

    # A 4-19: KING four times - trombones, then trumpets with the strings
    for i in range(16):
        sym = KING_H[i % 4]
        low(4 + i, sym, 76)
        cans(4 + i, 1, 64, busy=(i >= 8))
        S.pad('trem', 4 + i, sym, 54 if i < 8 else 62, low='F#4', n=3)
        if i % 2 == 0:
            S.timp_hit(S.B(4 + i), 'B1' if sym == 'Bm' else 'F#2', 80)
    S.mel('tbn', 4, transpose(KING, -12) * 2, 94)
    S.line('hn', 4, transpose(KING, -12) * 2, 74)
    S.mel('tpt', 12, KING * 2, 96)
    S.line('vln', 12, KING * 2, 84)
    S.line('tbn', 12, transpose(KING, -12) * 2, 82)
    S.hit(57, S.B(12), 84, dur=2, ch='kit')
    S.timp_roll(S.B(19), 4, 'F#2', 50, 100)

    # B 20-35: the jig in B minor drives on the fiddle; KING's head stabs in the trumpet
    for i in range(16):
        sym = PR[i]
        strum(S, 20 + i, sym, 76)
        low(20 + i, sym, 78)
        cans(20 + i, 1, 62, busy=True)
        if i >= 8:
            S.pad('pad', 20 + i, sym, 52, low='B3')
    S.mel('fid', 20, THm, 96, legato=.88)
    S.line('fl', 28, bars_of(S, THm, 8, 16), 70, legato=.85)
    for bar in (23, 27, 31, 35):
        S.line('tpt', bar, m('r:2 B4:.75 B4:.25 F#5:1'), 86)
    S.motif('hn', 28, motif('B3', 'minor', inverted=True), 84, form='inverted (horns, the court mocks)', lead=False)

    # C 36-43: comic collapse - KING on a lone bassoon and the xylophone over pizzicato; the hero's question on the flute
    for i in range(8):
        sym = KING_H[i % 4]
        S.pizz(36 + i, sym, 56)
        S.note('cb', S.B(36 + i), 1, bass_note(sym, 'E1'), 54)
        S.note('kit', S.B(36 + i, 3.5), .2, 80, 50, human=False)
    S.mel('bsn', 36, transpose(KING, -12), 86)
    S.line('xylo', 38, m('r:3 A#5:1'), 70)
    S.motif('fl', 40, motif('B4', 'minor'), 84, form='stated (flute, the hero asks)')
    S.line('xylo', 42, m('r:2 B5:.75 B5:.25 F#6:1'), 66)
    S.timp_roll(S.B(42), 8, 'F#2', 30, 108)
    S.snare_roll(S.B(43), 4, 30, 100, ch='kit')

    # D 44-59: climax - the hero's motif in the horns against KING in trumpets and trombones
    hero = motif('B3', 'minor') + m('r:1') + motif('E4', 'minor') + m('r:1')
    for i in range(16):
        sym = KING_H[i % 4]
        low(44 + i, sym, 88)
        cans(44 + i, 1, 72, busy=True)
        S.pad('trem', 44 + i, sym, 68, low='F#4', n=3)
        strum(S, 44 + i, sym, 70)
        if i % 4 == 0:
            S.hit(57, S.B(44 + i), 94, dur=2, ch='kit')
        if i % 2 == 0:
            S.timp_hit(S.B(44 + i), 'B1' if sym == 'Bm' else 'F#2', 90)
    S.motif('hn', 44, hero, 104, form='stated (horns, the hero fights back), then a fourth up')
    S.line('tbn', 44, transpose(KING, -12) * 2, 92)
    S.mel('tpt', 52, KING * 2, 106)
    S.line('vln', 52, KING * 2, 98)
    S.motif('hn', 52, hero, 100, form='stated (horns against the trumpets)', lead=False)
    S.mel('fid', 48, reel(transpose(to_mode(DUMP_JIG_HEAD, E_MINOR), -5)) * 2, 98)

    # E 60-67: the jig drive again
    for i in range(8):
        sym = PR[i]
        strum(S, 60 + i, sym, 80)
        low(60 + i, sym, 80)
        cans(60 + i, 1, 66, busy=True)
    S.mel('fid', 60, bars_of(S, THm, 0, 8), 98, legato=.88)
    S.line('vln', 60, bars_of(S, THm, 0, 8), 84, transpose=-12, legato=.88)

    # wind-down 68-71, outro 72-75 as the intro
    for i, sym in enumerate(['Bm', 'G', 'Em', 'F#']):
        low(68 + i, sym, 76 - i * 2)
        cans(68 + i, 1, 64)
        S.pad('pad', 68 + i, sym, 58, low='B3')
    S.mel('tbn', 68, m('B3:1 F#3:1 E3:1 D3:1 | C#3:2 D3:2 | E3:2 C#3:2 | A#2:4'), 84)
    intro(72)
    S.timp_roll(S.B(75, 2), 2, 'F#2', 40, 80)        # seam: a roll back into the fanfare
    S.snare_roll(S.B(75, 3), 1, 40, 76, ch='kit')
    return S
