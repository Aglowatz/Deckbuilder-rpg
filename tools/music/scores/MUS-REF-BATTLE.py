"""MUS-REF-BATTLE - The Verdant Dump, combat. 72 bars 4/4, 144 BPM, A Dorian. A fast reel: the Dump's jig theme (zones.DUMP_THEME)
recast in straight reel eighths (jig bar a b c d e f -> a b c b d e f e) and driven by the solo fiddle over chopped nylon guitar, a
root-fifth bass, tambourine, kick and snare. The Crossroads motif comes as a horn call in the B section; a running fiddle variation over
the theme in the violins; a tense low-string passage with the jig head in the cello; then the tutti reel. Music Pass 2, Batch 05.
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
    S = Song('MUS-REF-BATTLE', bpm=144, bars=72, meter=(4, 4), key='A Dorian', seed=501, jitter=0.01)
    setup(S, 'fid', 'vln', 'fl', 'gtr', 'pad', 'harp', 'bells', 'pizz', 'vc', 'cb', 'hn', 'timp', 'cel', 'trem', 'kit')
    for bar, nm in ((0, 'intro'), (4, 'A reel'), (20, 'B horn call'), (28, 'C fiddle variation'), (44, 'D tension'),
                    (52, "A' tutti"), (68, 'outro')):
        S.section(bar, nm)
    TH = reel(transpose(DUMP_THEME, 5))                          # 16 reel bars in A Dorian
    PR = [{'Em': 'Am', 'D': 'G', 'A': 'D', 'G': 'C'}[c] for c in DUMP_PROG]
    INTRO = ['Am', 'G', 'C', 'D']

    def groove(bar, sym, v, snare=True):
        strum(S, bar, sym, v)
        bassline(S, bar, sym, v)
        drums(S, bar, 1, v - 14, snare=snare)

    def intro(bar):
        for i, sym in enumerate(INTRO):
            groove(bar + i, sym, 70)
            S.pad('pad', bar + i, sym, 60, low='A3')
            S.pad('trem', bar + i, sym, 44, low='E4', n=2)
        S.mel('fid', bar, m('A4:2 E5:2 | D5:2 B4:2 | C5:2 G5:2 | F#5:2 A5:2'), 76)
        S.motif('hn', bar + 2, motif_head('A3', 'dorian', rhythm=(2, 1, 1)), 70, form='head (horns, the call)', lead=False)

    intro(0)
    S.swell('pad', 0, 4, 90, 100)

    # A 4-19: the fiddle reel
    for i in range(16):
        groove(4 + i, PR[i], 76)
        if i >= 8:
            S.pad('pad', 4 + i, PR[i], 48, low='A3')
    S.mel('fid', 4, TH, 94, legato=.88)
    S.line('fl', 12, bars_of(S, TH, 8, 16), 66, legato=.85)
    S.timp_hit(S.B(4), 'A2', 80)
    S.timp_hit(S.B(12), 'A2', 74)

    # B 20-27: the Crossroads call in the horns, pizzicato chop, the fiddle answers with the jig head
    BH = ['Am', 'G', 'F', 'E', 'Am', 'G', 'D', 'E']
    for i, sym in enumerate(BH):
        bar = 20 + i
        bassline(S, bar, sym, 80)
        drums(S, bar, 1, 64)
        S.pad('pad', bar, sym, 58, low='A3')
        tn = S.chord_tones(sym, 'A3', 4)
        for k in range(8):
            S.note('pizz', S.B(bar, k * .5), .3, tn[(0, 1, 2, 3, 2, 1, 2, 1)[k]], 60 + (8 if k % 2 == 0 else 0))
    S.motif('hn', 20, motif('A3', 'dorian'), 92, form='stated (horns, A Dorian)')
    S.mel('fid', 22, reel(transpose(DUMP_JIG_HEAD, 5)), 86)
    S.motif('hn', 24, motif('A3', 'dorian'), 96, form='stated (horns + violins 8va)')
    S.line('vln', 24, motif('A4', 'dorian'), 82)
    S.mel('fid', 26, reel(transpose(DUMP_JIG_HEAD, 5)), 90)
    S.timp_roll(S.B(27, 2), 2, 'E2', 50, 96)

    # C 28-43: a running fiddle variation over the theme in the violins
    for i in range(16):
        sym = PR[i]
        bar = 28 + i
        groove(bar, sym, 80)
        S.pad('hn', bar, sym, 54, low='E3', n=2)
        tn = S.chord_tones(sym, 'A4' if i % 4 < 2 else 'E4', 6)
        for k, j in enumerate((0, 1, 2, 3, 4, 3, 2, 1)):
            S.note('fid', S.B(bar, k * .5), .45, tn[j], 90 + (8 if k % 4 == 0 else 0), role='mel')
        if i % 4 == 0:
            S.timp_hit(S.B(bar), 'A2', 84)
    S.line('vln', 28, TH, 80, legato=.9)
    S.line('cel', 28, bars_of(S, TH, 0, 4), 50, transpose=12)
    S.hit(57, S.B(28), 74, dur=2, ch='kit')

    # D 44-51: tension - low strings drive, the jig head in the cello, tremolo, a snare build
    DH = ['Am', 'Am', 'F', 'F', 'Dm', 'Dm', 'E', 'E']
    for i, sym in enumerate(DH):
        bar = 44 + i
        S.bass(bar, sym, 72 + i * 2, 'pulse', chs=('cb', None))
        S.pad('trem', bar, sym, 56 + i * 3, low='E4', n=3)
        S.pad('pad', bar, sym, 50, low='A3')
        drums(S, bar, 1, 58 + i * 2, snare=(i >= 4))
    S.mel('vc', 44, reel(transpose(DUMP_JIG_HEAD, -19)), 90)
    S.mel('vc', 46, reel(transpose(DUMP_JIG_HEAD, -20)), 90)
    S.mel('fid', 48, m('E5:4 | F5:4 | E5:2 F5:2 | G#5:4'), 90)
    S.motif('hn', 48, motif_tail('A3', 'dorian', rhythm=(2, 1, 5)), 80, form='tail (horns, under the fiddle)', lead=False)
    S.swell('trem', 44, 8, 70, 115)
    S.snare_roll(S.B(50), 8, 40, 100, ch='kit')
    S.timp_roll(S.B(51), 4, 'E2', 50, 110)

    # A' 52-67: the tutti reel
    for i in range(16):
        sym = PR[i]
        bar = 52 + i
        groove(bar, sym, 86)
        S.pad('hn', bar, sym, 66, low='E3', n=3)
        S.pad('pad', bar, sym, 54, low='A3')
        S.note('vc', S.B(bar), 3.6, bass_note(sym, 'E1') + 12, 70)
        if i % 2 == 0:
            S.timp_hit(S.B(bar), 'A2' if sym == 'Am' else 'E2', 86)
    S.mel('fid', 52, TH, 104, legato=.88)
    S.line('vln', 52, TH, 92, transpose=-12, legato=.88)
    S.line('fl', 52, TH, 78, legato=.85)
    S.line('bells', 52, m('A5:8'), 66)
    S.line('bells', 60, m('E5:8'), 62)
    S.hit(57, S.B(52), 90, dur=3, ch='kit')
    S.hit(57, S.B(60), 84, dur=3, ch='kit')

    # OUTRO 68-71: as the intro, so the loop rolls round
    intro(68)
    S.swell('pad', 68, 4, 100, 92)
    return S
