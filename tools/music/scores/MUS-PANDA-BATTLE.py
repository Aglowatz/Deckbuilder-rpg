"""MUS-PANDA-BATTLE - Trash Panda Throne, combat. 80 bars 4/4, 146 BPM, D Dorian. Two contrasting battle phrases: the Dump's jig theme
as a driving reel (zones.DUMP_THEME in D Dorian) on the fiddle, and a pompous court phrase - the regal flourish of the Trash Panda court
in trumpet and horns with the Crossroads motif. Bottle-cap percussion over a kick/snare drive and a moving bass; a chase section tosses
the theme head between fiddle, piccolo and xylophone; a tense passage; the tutti reel. Music Pass 2, Batch 08.
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

FLOURISH = m('D4:.5 G4:.5 B4:.5 D5:1 C#5:.25 D5:.25 | B4:.5 G4:.5 A4:2 r:1')


def build():
    S = Song('MUS-PANDA-BATTLE', bpm=146, bars=80, meter=(4, 4), key='D Dorian', seed=508, jitter=0.01)
    setup(S, 'fid', 'vln', 'fl', 'picc', 'gtr', 'pizz', 'vc', 'cb', 'hn', 'tpt', 'xylo', 'timp', 'pad', 'trem', 'kit')
    for bar, nm in ((0, 'intro'), (4, 'A reel'), (20, 'B court phrase'), (28, 'C chase'), (44, 'D tension'), (52, "A' tutti"),
                    (68, 'B court tutti'), (76, 'outro')):
        S.section(bar, nm)
    TH = reel(transpose(DUMP_THEME, -2))
    PR = [{'Em': 'Dm', 'D': 'C', 'A': 'G', 'G': 'F'}[c] for c in DUMP_PROG]
    CH = ['G', 'D', 'C', 'D', 'G', 'D', 'Bb', 'A']

    def caps(bar, n, v):
        for i in range(n):
            for t in (.5, 1.5, 2.5, 3.5):
                S.note('kit', S.B(bar + i, t), .2, 80, v - 8, human=False)
            if i % 2 == 1:
                S.note('kit', S.B(bar + i, 3.5), .2, 56, v - 12, human=False)

    def groove(bar, sym, nxt, v, snare=True):
        strum(S, bar, sym, v)
        b, n = bass_note(sym, 'E1'), bass_note(nxt, 'E1')
        S.note('cb', S.B(bar), .9, b, v)
        S.note('cb', S.B(bar, 1), .9, b + 7, v - 8)
        S.note('cb', S.B(bar, 2), .9, b + 12 if b + 12 < 48 else b, v - 4)
        S.note('cb', S.B(bar, 3), .9, n - 1 if n - 1 >= 28 else n + 11, v - 8)
        drums(S, bar, 1, v - 12, snare=snare)
        caps(bar, 1, v - 16)

    def intro(bar):
        for i, sym in enumerate(['Dm', 'C', 'Bb', 'A']):
            groove(bar + i, sym, ['C', 'Bb', 'A', 'Dm'][i], 70)
            S.pad('pad', bar + i, sym, 62, low='A3')
            S.pad('hn', bar + i, sym, 56, low='D3', n=2)
        S.mel('tpt', bar, FLOURISH, 86)
        S.mel('tpt', bar + 2, m('D4:.5 G4:.5 Bb4:.5 D5:1 E5:.25 C#5:.25 | D5:1 r:3'), 84)

    intro(0)

    # A 4-19: the reel
    for i in range(16):
        groove(4 + i, PR[i], PR[(i + 1) % 16], 78)
        if i >= 8:
            S.pad('pad', 4 + i, PR[i], 48, low='A3')
    S.mel('fid', 4, TH, 94, legato=.88)
    S.line('fl', 12, bars_of(S, TH, 8, 16), 66, legato=.85)
    S.timp_hit(S.B(4), 'D2', 84)

    # B 20-27: the court phrase - flourish and the Crossroads motif in trumpet and horns over pizzicato
    for i, sym in enumerate(CH):
        bar = 20 + i
        groove(bar, sym, CH[(i + 1) % 8], 74, snare=(i % 2 == 1))
        S.pizz(bar, sym, 60)
    S.motif('tpt', 20, motif('G4', 'mixolydian'), 94, form='stated (trumpet, the court)')
    S.line('hn', 20, motif('G3', 'mixolydian'), 80)
    S.mel('fid', 22, reel(transpose(DUMP_JIG_HEAD, 3)), 86)
    S.mel('tpt', 24, FLOURISH, 92, transpose=5)
    S.motif('hn', 26, motif_head('D4', 'dorian', rhythm=(1, .5, 2.5)), 86, form='head (horns)', lead=False)
    S.mel('fid', 26, reel(transpose(DUMP_JIG_HEAD, -2)), 90)

    # C 28-43: the chase - the jig head tossed between fiddle, piccolo and xylophone
    for i in range(16):
        groove(28 + i, PR[i], PR[(i + 1) % 16], 80)
    for k, bar in enumerate(range(28, 44, 2)):
        ch = ('fid', 'picc', 'fid', 'xylo')[k % 4]
        S.line(ch, bar, reel(transpose(DUMP_JIG_HEAD, -2 + (0, 2, 3, 5)[k % 4])), 92 if ch == 'fid' else 76, role='mel')
    S.line('vln', 28, TH, 70, transpose=-12, legato=.9)
    S.hit(57, S.B(28), 76, dur=2, ch='kit')

    # D 44-51: tension
    DH = ['Dm', 'Dm', 'Bb', 'Bb', 'Gm', 'Gm', 'A', 'A']
    for i, sym in enumerate(DH):
        bar = 44 + i
        S.bass(bar, sym, 72 + i * 2, 'pulse', chs=('cb', None))
        S.pad('trem', bar, sym, 56 + i * 3, low='D4', n=3)
        S.pad('pad', bar, sym, 50, low='A3')
        drums(S, bar, 1, 58 + i * 2, snare=(i >= 4))
    S.mel('vc', 44, reel(transpose(DUMP_JIG_HEAD, -14)), 90)
    S.mel('vc', 46, reel(transpose(DUMP_JIG_HEAD, -16)), 90)
    S.mel('tpt', 48, m('A4:2 Bb4:2 | A4:2 C#5:2 | D5:4 | C#5:4'), 86)
    S.swell('trem', 44, 8, 70, 115)
    S.snare_roll(S.B(50), 8, 40, 100, ch='kit')
    S.timp_roll(S.B(51), 4, 'A1', 50, 110)

    # A' 52-67: tutti reel
    for i in range(16):
        groove(52 + i, PR[i], PR[(i + 1) % 16], 86)
        S.pad('hn', 52 + i, PR[i], 64, low='D3', n=3)
        if i % 2 == 0:
            S.timp_hit(S.B(52 + i), 'D2', 84)
    S.mel('fid', 52, TH, 104, legato=.88)
    S.line('vln', 52, TH, 92, transpose=-12, legato=.88)
    S.line('fl', 52, TH, 78, legato=.85)
    S.hit(57, S.B(52), 90, dur=3, ch='kit')
    S.hit(57, S.B(60), 84, dur=3, ch='kit')

    # B 68-75: the court phrase tutti
    for i, sym in enumerate(CH):
        groove(68 + i, sym, CH[(i + 1) % 8], 82)
        S.pad('trem', 68 + i, sym, 56, low='D4', n=3)
    S.motif('tpt', 68, motif('G4', 'mixolydian'), 100, form='stated (trumpet + violins, tutti)')
    S.line('vln', 68, motif('G5', 'mixolydian'), 88)
    S.line('hn', 68, motif('G3', 'mixolydian'), 86)
    S.mel('fid', 70, reel(transpose(DUMP_JIG_HEAD, 3)), 94)
    S.mel('tpt', 72, FLOURISH, 96, transpose=5)
    S.mel('fid', 74, reel(transpose(DUMP_JIG_HEAD, -2)), 94)

    intro(76)
    S.snare_roll(S.B(79, 2), 2, 44, 88, ch='kit')     # seam: a roll leads back into the flourish
    S.timp_roll(S.B(79, 2), 2, 'A1', 40, 80)
    S.line('tpt', 79, m('r:2 A3:.5 D4:.5 F4:1'), 74)
    S.fade_vel(78, 80, 1.3)                          # seam: the last bars lean in to meet the flourish
    return S
