"""MUS-REF-RELEASE - Compostella: let the seed return. One-shot story cue, 40 bars 6/8 (q = 108, dotted q = 36), E major, ~70 s plus
the ring. Low busyness under dialogue: harp and a soft cello pedal, a celesta "seed" glimmer. Compostella's lament (from MUS-REF-BOSS) comes
back in major on the solo violin and lands home; the Crossroads motif, RESOLVED and slowed, on the flute; the Dump's jig head (zones.DUMP_JIG_HEAD)
slowed to a hymn in the cello under chimes; a held E major chord rings out. Music Pass 2, Batch 08 (story one-shot, -20 LUFS like the loops).
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
COMP_MAJ = m('E5:1.5 F#5:1 E5:.5 | D#5:2 B4:1 | C#5:1 B4:.5 A4:1 G#4:.5 | F#4:1.5 D#4:1.5 | E4:6')


def build():
    S = Song('MUS-REF-RELEASE', bpm=108, bars=40, meter=(6, 8), key='E major', seed=506, kind='oneshot', jitter=0.012)
    S.lufs = -20
    setup(S, 'fid', 'vln', 'fl', 'harp', 'cel', 'bells', 'vc', 'cb', 'hn', 'pad', 'timp')
    for bar, nm in ((0, 'seed'), (8, 'the lament, home'), (16, 'resolved motif'), (24, 'the jig as a hymn'), (32, 'held ending')):
        S.section(bar, nm)
    H1 = ['E', 'A', 'E', 'B', 'C#m', 'A', 'B', 'E']

    S.note('bells', 0, 6, p('E5'), 62, human=False)
    S.note('harp', 0, 2, p('E3'), 70, human=False)
    for i, sym in enumerate(H1):
        bar = i
        S.note('cb', S.B(bar), 3.02, bass_note(sym, 'E1'), 46)
        S.pad('pad', bar, sym, 38, low='G#3')
        ts = voice(sym, 'E3', 4)
        for e, t in enumerate([ts[0], ts[1], ts[2], ts[3], ts[2], ts[1]]):
            S.note('harp', S.B(bar, e * .5), 1.2, t + 12, 48 + (6 if e == 0 else 0))
    for bar in (1, 4, 6):
        S.mel('cel', bar, m('B5:1.5 E6:1.5'), 46)

    # 8-15: Compostella's lament in major on the solo violin, landing home
    for i, sym in enumerate(['A', 'B', 'A', 'B', 'E', 'E', 'A', 'B']):
        bar = 8 + i
        S.note('cb', S.B(bar), 3.02, bass_note(sym, 'E1'), 50)
        S.chord('vln', S.B(bar), 3.02, voice(sym, 'G#3', 3), 40)
        fairy(S, bar, sym, 34, low='E3', ch1=None)
    S.mel('fid', 8, COMP_MAJ, 78)
    S.mel('fid', 13, m('r:3 | B4:3 | C#5:1.5 B4:1.5'), 66)

    # 16-23: the Crossroads motif, resolved and slowed, on the flute; strings warm under it
    for i, sym in enumerate(['E', 'B', 'C#m', 'A', 'E', 'B', 'A', 'E']):
        bar = 16 + i
        S.note('cb', S.B(bar), 3.02, bass_note(sym, 'E1'), 52)
        S.pad('pad', bar, sym, 50, low='G#3')
        S.chord('hn', S.B(bar), 3.02, voice(sym, 'G#3', 2), 40)
    S.motif('fl', 16, aug(motif('E5', 'major', rhythm=R68, resolved=True), 2), 80, form='RESOLVED, augmented (flute)')
    S.mel('fid', 21, m('G#5:3 | F#5:1.5 E5:1.5 | B5:3'), 62)
    S.swell('pad', 16, 8, 70, 100, 'arch')

    # 24-31: the jig head slowed to a hymn in the cello, chimes, the harp rippling
    for i, sym in enumerate(['E', 'B', 'E', 'A', 'E', 'B', 'A', 'E']):
        bar = 24 + i
        S.note('cb', S.B(bar), 3.02, bass_note(sym, 'E1'), 50)
        fairy(S, bar, sym, 40, low='E3', ch1='cel' if i % 2 == 0 else None)
        S.chord('vln', S.B(bar), 3.02, voice(sym, 'B3', 3), 44)
    S.mel('vc', 24, aug(transpose(to_mode(DUMP_JIG_HEAD, E_MAJOR), -12), 2), 80)
    S.mel('vc', 28, aug(transpose(to_mode(DUMP_JIG_HEAD, E_MAJOR), -12)[:6], 2) + m('E3:6'), 76)
    S.note('bells', S.B(24), 4, p('B4'), 52)
    S.note('bells', S.B(28), 4, p('E5'), 50)

    # 32-39: the seed returns - motif tail resolved on the violin, a held E major chord that rings out
    S.mel('fid', 32, motif_tail('E5', 'major', rhythm=(3, 1.5, 4.5), resolved=True), 72)
    S.motif('fl', 34, motif_tail('E5', 'major', rhythm=(3, 1.5, 7.5), resolved=True), 60, form='RESOLVED tail (flute, the seed)', lead=False)
    S.pad('pad', 32, 'A', 46, low='G#3', beats=6)
    S.pad('pad', 34, 'E', 50, low='G#3', beats=18)
    S.chord('vln', S.B(34), 18, voice('E', 'G#3', 4), 46)
    S.chord('hn', S.B(34), 16, voice('E', 'G#3', 3), 42)
    S.note('cb', S.B(32), 6, p('A1'), 48)
    S.note('cb', S.B(34), 18, p('E2'), 52)
    S.note('vc', S.B(34), 18, p('E3'), 46)
    S.mel('fid', 36, m('E5:12'), 60)
    fairy(S, 34, 'E', 40, low='E3')
    S.note('bells', S.B(34), 8, p('E5'), 58)
    S.timp_roll(S.B(33, 1.5), 1.5, 'E2', 20, 44)
    S.swell('pad', 34, 6, 100, 60)
    S.swell('vln', 34, 6, 100, 60)
    S.tag_melody('harp', 0, 8)          # the harp's arpeggio is the foreground under the opening dialogue
    return S
