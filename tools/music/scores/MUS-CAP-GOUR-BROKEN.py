"""MUS-CAP-GOUR-BROKEN - Hungry Quarter, broken service. 48 bars 4/4, 96 BPM, F minor (~120 s loop).
The Buffet theme played thin, detuned and interrupted: in F minor on a lone celesta, shadowed by a clarinet bent 25 cents flat (two
voices that never quite agree), each phrase cut off mid-bar as if the kitchen lost power. Hollow recipe phrases in sparse pizzicato, a
cold low cello pedal, and a faint rift texture (bowed glass) underneath. The Crossroads motif's head on a flute, unanswered. Human
warmth barely audible: one bar of the theme in F major on the cello, once, before it slips back.
"""
from lib import Song, motif_head, transpose, p
from lib.zones import BUFFET_THEME, to_mode

THEME = to_mode(BUFFET_THEME, {9: -1, 2: -1, 4: -1})
COLD = ['Fm', 'Dbmaj7', 'Bbm', 'C7sus4']


def frag(mel, start, beats):
    """The notes of `mel` from beat `start` lasting `beats` (cut mid-phrase)."""
    out, pos = [], 0
    for n, d in mel:
        if start <= pos < start + beats:
            out.append((n, min(d, start + beats - pos)))
        pos += d
    return out


def build():
    s = Song('MUS-CAP-GOUR-BROKEN', bpm=96, bars=48, key='F minor', seed=412, jitter=0.02)
    s.channel('cel', 'celesta', 44, 100, 96)
    s.channel('cl2', 'clarinet', 70, 90, 74)
    s.channel('fl', 'flute', 52, 95, 80)
    s.channel('vc', 'cello', 82, 90, 84)
    s.channel('cb', 'contrabass', 92, 90, 72)
    s.channel('pizz', 'pizz', 74, 75, 70)
    s.channel('glass', 'bowed_glass', 64, 110, 62)
    s.channel('pad', 'slow_strings', 64, 100, 64)
    s.channel('kit', 'standard_kit', 64, 80, 64)
    s.detune('cl2', -25, 0)
    for bar, nm in ((0, 'rift'), (8, 'broken theme'), (24, 'hollow recipe'), (36, 'broken theme again'), (44, 'rift again')):
        s.section(bar, nm)

    def ground(bar, sym, vel):
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), vel)
        s.pad('glass', bar, sym, vel - 6, low='C4', n=3)

    def rift(bar, bars):
        for i in range(bars):
            sym = COLD[i % 4]
            ground(bar + i, sym, 58)
            s.pad('pad', bar + i, sym, 44, low='F3')
            s.note('kit', (bar + i) * 4 + 3, .1, 77, 40, human=False)
        s.motif('fl', bar + 1, motif_head('F5', 'minor', rhythm=(2, 1, 3)) + [('r', 2)], 70, form='head (flute, unanswered)')
        s.swell('glass', bar, bars, 70, 96)

    rift(0, 8)

    # 8-23: the theme in pieces - celesta, a clarinet 25 cents flat behind it, phrases cut mid-bar
    for i in range(16):
        ground(8 + i, COLD[i % 4], 54)
    cuts = [(0, 6), (8, 5), (16, 7), (24, 4), (32, 6), (40, 5), (48, 7), (56, 3)]
    for k, (st, ln) in enumerate(cuts):
        piece = frag(THEME, st, ln)
        s.mel('cel', 8 + k * 2, piece, 90)
        s.line('cl2', 8 + k * 2, piece, 64, tr=-12, beat=.25)

    # 24-35: hollow recipe - sparse pizzicato fragments; one bar of warmth on the cello, then it slips back
    for i in range(12):
        bar = 24 + i
        sym = COLD[i % 4]
        ground(bar, sym, 52)
        tn = s.chord_tones(sym, 'C4', 3)
        for beat in (0, 1.5) if i % 2 == 0 else (2.5,):
            s.note('pizz', bar * 4 + beat, .3, tn[int(beat) % 3], 58)
    s.mel('cel', 25, frag(THEME, 0, 3) + [('r', 5)], 82)
    s.mel('vc', 28, transpose(BUFFET_THEME[:6], -12) + [('r', 1)], 76)
    s.mel('vc', 30, transpose(frag(THEME, 0, 4), -12) + [('r', 4)], 70)
    s.motif('fl', 32, motif_head('C5', 'minor', rhythm=(1.5, .5, 2)) + [('r', 4)], 66, form='head (flute, fading)')
    s.mel('cel', 34, frag(THEME, 21, 3) + [('r', 5)], 80)

    # 36-43: broken theme again, shorter pieces
    for i in range(8):
        ground(36 + i, COLD[i % 4], 54)
    for k, (st, ln) in enumerate([(0, 4), (21, 4), (40, 3), (48, 2)]):
        piece = frag(THEME, st, ln)
        s.mel('cel', 36 + k * 2, piece, 88)
        s.line('cl2', 36 + k * 2, piece, 62, tr=-12, beat=.25)

    rift(44, 4)
    return s
