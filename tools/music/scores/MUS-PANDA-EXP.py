"""MUS-PANDA-EXP - Trash Panda Throne, exploration. 56 bars 4/4, 112 BPM (swung eighths), G Mixolydian. A scrappy royal court: a
small swaggering folk procession on the Dump's jig theme (zones.DUMP_THEME recast as a swung reel in G Mixolydian), bottle-cap
percussion (muted triangle, sticks, cowbell, tambourine), and a nervous regal flourish on a lone trumpet that trips over its top note.
A court-dance B section on flute and pizzicato with the Crossroads motif on the xylophone, an adventurous chase section in straight
eighths, then the procession again. Music Pass 2, Batch 08.
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

FLOURISH = m('G4:.5 C5:.5 E5:.5 G5:1 F#5:.25 G5:.25 | E5:.5 C5:.5 D5:2 r:1')


def build():
    S = Song('MUS-PANDA-EXP', bpm=112, bars=56, meter=(4, 4), key='G Mixolydian', seed=507, jitter=0.012)
    setup(S, 'fid', 'vln', 'fl', 'picc', 'gtr', 'pizz', 'vc', 'cb', 'hn', 'tpt', 'xylo', 'bsn', 'timp', 'pad', 'kit')
    S.swing = 0.12
    for bar, nm in ((0, 'fanfare'), (4, 'A procession'), (20, 'B court dance'), (28, 'C chase'), (44, "A' procession tutti"),
                    (52, 'outro fanfare')):
        S.section(bar, nm)
    TH = reel(to_mode(transpose(DUMP_THEME, 3), {10: 1}))       # G Dorian -> G Mixolydian (Bb -> B)
    PR = [{'Em': 'G', 'D': 'F', 'A': 'C', 'G': 'G7'}[c] for c in DUMP_PROG]

    def caps(bar, n, v):
        """Bottle-cap percussion: muted triangle on the off-beats, sticks, a cowbell, tambourine."""
        for i in range(n):
            for t in (.5, 1.5, 2.5, 3.5):
                S.note('kit', S.B(bar + i, t), .2, 80, v - 6, human=False)
            S.note('kit', S.B(bar + i), .2, 31, v, human=False)
            S.note('kit', S.B(bar + i, 2), .2, 31, v - 6, human=False)
            if i % 2 == 1:
                S.note('kit', S.B(bar + i, 3), .2, 56, v - 12, human=False)
            S.note('kit', S.B(bar + i, 1), .3, 54, v - 10, human=False)
            S.note('kit', S.B(bar + i, 3), .3, 54, v - 10, human=False)

    def march(bar, sym, v):
        b = bass_note(sym, 'E1')
        S.note('cb', S.B(bar), .9, b, v)
        S.note('cb', S.B(bar, 2), .9, b + 7, v - 6)
        vv = voice(sym, 'D3', 4)
        for t in (1, 3):
            S.chord('gtr', S.B(bar, t), .4, vv, v - 8, spread=.02)
        S.chord('gtr', S.B(bar, 3.5), .3, vv, v - 18, spread=.02)

    def fanfare(bar):
        for i, sym in enumerate(['G', 'C', 'G', 'D']):
            march(bar + i, sym, 66)
            S.pad('pad', bar + i, sym, 54, low='B3')
        caps(bar, 4, 60)
        S.mel('tpt', bar, FLOURISH, 84)
        S.mel('tpt', bar + 2, m('G4:.5 C5:.5 E5:.5 G5:1 A5:.25 F#5:.25 | G5:1 r:3'), 82)
        S.line('xylo', bar + 3, m('r:2 D5:.5 E5:.5 F#5:.5 G5:.5'), 60)
        S.timp_hit(S.B(bar), 'G2', 66)

    fanfare(0)

    # A 4-19: the procession - the jig theme as a swaggering swung reel on the fiddle
    for i in range(16):
        march(4 + i, PR[i], 72)
    caps(4, 16, 58)
    S.mel('fid', 4, TH, 90, legato=.85)
    S.line('fl', 12, bars_of(S, TH, 8, 16), 66, legato=.8)
    S.line('bsn', 4, m('G2:4 | F2:4 | G2:4 | C3:4 | G2:4 | F2:4 | B2:4 | C3:4'), 54)
    S.mel('tpt', 11, m('r:2 G4:.5 C5:.5 D5:1'), 70)

    # B 20-27: a court dance - flute over pizzicato, the Crossroads motif on the xylophone
    for i, sym in enumerate(['C', 'G', 'F', 'G', 'C', 'G', 'Am', 'D']):
        bar = 20 + i
        S.pizz(bar, sym, 60)
        S.note('cb', S.B(bar), 1, bass_note(sym, 'E1'), 58)
        S.pad('pad', bar, sym, 44, low='B3')
        caps(bar, 1, 50)
    S.mel('fl', 20, reel(transpose(DUMP_JIG_HEAD, 3))[:12] + m('G5:2 F5:2'), 80)
    S.motif('xylo', 22, motif('G5', 'mixolydian'), 76, form='stated (xylophone, the court dance)')
    S.mel('fl', 24, reel(transpose(DUMP_JIG_HEAD, 5))[:12] + m('A5:2 F#5:2'), 82)
    S.motif('hn', 26, motif_head('D4', 'mixolydian', rhythm=(1, 1, 2)), 66, form='head (horns, answering)', lead=False)

    # C 28-43: the chase - straight eighths, running fiddle, theme heads tossed between fiddle and piccolo, snare drive
    S.swing = 0.0
    for i in range(16):
        sym = PR[i]
        bar = 28 + i
        strum(S, bar, sym, 74)
        bassline(S, bar, sym, 74)
        drums(S, bar, 1, 64)
        S.pad('hn', bar, sym, 50, low='D3', n=2)
    for k, bar in enumerate(range(28, 44, 2)):
        ch = 'fid' if k % 2 == 0 else 'fl'
        S.line(ch, bar, reel(transpose(DUMP_JIG_HEAD, 3 + (k % 4))), 90, role='mel')
        if ch == 'fl':
            S.line('picc', bar, reel(transpose(DUMP_JIG_HEAD, 3 + (k % 4))), 60)
    S.snare_roll(S.B(42), 8, 40, 96, ch='kit')
    S.timp_roll(S.B(43), 4, 'D2', 50, 100)
    S.swing = 0.12

    # A' 44-51: the procession tutti
    for i in range(8):
        march(44 + i, PR[i], 82)
        S.pad('hn', 44 + i, PR[i], 60, low='D3', n=3)
    caps(44, 8, 66)
    S.mel('fid', 44, bars_of(S, TH, 0, 8), 100, legato=.85)
    S.line('vln', 44, bars_of(S, TH, 0, 8), 86, transpose=-12, legato=.85)
    S.line('fl', 44, bars_of(S, TH, 0, 8), 72, legato=.8)
    S.hit(57, S.B(44), 80, dur=2, ch='kit')

    # OUTRO 52-55: the fanfare again, into the loop
    fanfare(52)
    S.snare_roll(S.B(55, 2), 2, 44, 84, ch='kit')     # seam: a little roll leads back into the fanfare
    S.timp_roll(S.B(55, 2), 2, 'D2', 40, 76)
    S.line('tpt', 55, m('r:2 D4:.5 G4:.5 B4:1'), 70)
    S.fade_vel(54, 56, 1.3)                          # seam: the last bars lean in to meet the fanfare
    return S
