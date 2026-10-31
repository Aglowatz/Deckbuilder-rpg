"""MUS-CAP-RESTORED - Pathordia, many ways home (postgame city). Loop, 64 bars 4/4, 104 BPM, D major, human feel ON, ~148 s.
Services reconnect, people become themselves. The Capital theme is the city's tune still - but in D, played by people: lifted rhythms
(dotted where it was square), warm strings and horns instead of block brass, its cadences free to breathe. Then the four Path themes weave
rather than flatten: the Gainlands head in the horns, the Buffet welcome in the clarinet, the D.N.A. theme (in major) in the cello, the Dump
jig in a solo violin - each in its own colour over one shared progression, the Capital theme as a restrained countermelody (the city that
healed). The Crossroads motif is RESOLVED at last in the tutti (a restored cue). A gentle B section on harp and flute; the outro returns to
the intro's warm strings so the loop rolls over.
"""
from lib import Score, p, voice, motif, motif_head, augment, transpose
from lib.capital import CAPITAL_THEME_A, CAPITAL_THEME_B, CAPITAL_HEAD
from lib.zones import DNA_THEME, BUFFET_THEME_A, DUMP_JIG_HEAD, to_mode
from scores._fork_b import stack, bed, GAIN_THEME, MAJ_FROM_CMIN

LIFT = {1.0: [(0.75), (0.25)]}


def lifted(mel):
    """The Capital theme played by people: pairs of equal quarters become dotted-quarter + eighth (a lilt, not a grid)."""
    out, i = [], 0
    while i < len(mel):
        n, d = mel[i]
        if d == 1 and i + 1 < len(mel) and mel[i + 1][1] == 1:
            out += [(n, 1.5), (mel[i + 1][0], .5)]
            i += 2
        else:
            out.append((n, d))
            i += 1
    return out


CAP_A = transpose(lifted(CAPITAL_THEME_A), 2 - 12)       # D major, horn/viola range
CAP_B = transpose(lifted(CAPITAL_THEME_B), 2)
PROG_A = ['D', 'A', 'Em A', 'D', 'G', 'A7', 'Bm Em', 'A7 D']
PROG_B = ['G', 'D', 'Em', 'Bm', 'Em7 A', 'G A', 'A7', 'D']
WEAVE = ['D', 'Bm', 'G', 'A', 'D', 'F#m', 'G', 'A', 'Bm', 'G', 'D', 'A', 'G', 'Em', 'Asus4', 'A']
GAIN_D = transpose(GAIN_THEME[:9], 4 - 12)
BUF_D = transpose(BUFFET_THEME_A[:11], -3)
DNA_D = transpose(to_mode(DNA_THEME[:10], MAJ_FROM_CMIN), 2 - 12)
DUMP_D = to_mode(transpose(DUMP_JIG_HEAD, -2), {5: 1, 0: 1})


def build():
    s = Score('MUS-CAP-RESTORED', bpm=104, bars=64, key='D major', seed=1680)
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'tpt', 'fl', 'cl', 'timp', 'choir', 'glock', 'perc', 'pizz')
    s.channel('fid', 'violin', pan=30, reverb=90, vol=86)
    for bar, nm in ((0, 'intro'), (4, 'A the city, human'), (20, 'B four voices weave'), (36, 'C gentle'), (44, 'D resolved tutti'),
                    (60, 'outro')):
        s.section(bar, nm)
    s.notes.append('Human feel ON (the only Capital cue with it). Capital theme lifted to dotted rhythms; Crossroads motif RESOLVED (restored cue).')

    def warm(bar0):
        for i, sym in enumerate(['D', 'G', 'Bm', 'A']):
            bed(s, bar0 + i, sym, 58, harp=50)
        s.swell('pad', bar0, 4, 84, 96)
        s.mel('fl', bar0, transpose(CAPITAL_HEAD, 2) + [('r', 1)], 66)
        s.line('hn', bar0 + 2, [('F#4', 4), ('E4', 4)], 58)

    warm(0)

    # A 4-19: the Capital theme in D, lifted; horns then strings, harp and a soft snare (no rudiments)
    for i in range(16):
        bar = 4 + i
        sym = (PROG_A + PROG_B)[i]
        bed(s, bar, sym, 60, bass='half', harp=46 if i % 2 == 0 else None)
        if i >= 8:
            s.drum(bar, [(1, 'snare', -36), (3, 'snare', -32)], 70)
    s.mel('hn', 4, CAP_A, 84)
    s.line('cl', 6, [('A4', 4), ('B4', 4), ('A4', 4), ('F#4', 4), ('G4', 4), ('A4', 4)], 52)
    stack(s, [('vln', 12, 0), ('vln', 0, -14)], 12, CAP_B, 86)
    s.line('hn', 12, [('B3', 4), ('A3', 4), ('G3', 4), ('F#3', 4), ('E3', 4), ('G3', 4), ('A3', 4), ('A3', 4)], 60)
    s.timp_roll(19 * 4 + 2, 2, 'A2', 30, 72)

    # B 20-35: the four Path voices weave over one progression; the Capital head as a quiet countermelody
    for i, sym in enumerate(WEAVE):
        bar = 20 + i
        bed(s, bar, sym, 58, bass='half')
        s.pizz(bar, sym, 50)
    s.mel('hn', 20, GAIN_D, 86)
    s.line('glock', 22, transpose(CAPITAL_HEAD, 2 + 12), 40)
    s.mel('cl', 24, BUF_D, 84)
    s.mel('vc', 28, DNA_D, 84)
    s.line('fl', 29, [('A5', 2), ('F#5', 2), ('G5', 4)], 52)
    s.mel('fid', 32, DUMP_D + DUMP_D[:4], 88)
    s.line('fid', 34, DUMP_D[4:] + [('D5', 2)], 84)
    s.motif('hn', 33, motif_head('D4', 'major'), 64, form='head (horn) under the jig', lead=False)

    # C 36-43: gentle - harp and flute, the motif's question asked softly (open here, answered at bar 44)
    for i, sym in enumerate(['G', 'D/F#', 'Em', 'A', 'G', 'D/F#', 'Em7', 'Asus4']):
        bed(s, 36 + i, sym, 46, harp=50)
    s.motif('fl', 36, motif('D5', 'major'), 72, form='stated (flute), the question')
    s.mel('cl', 38, [('E5', 1), ('F#5', .5), ('G5', .5), ('A5', 2), ('G5', 2), ('F#5', 2), ('E5', 2), ('C#5', 2)], 66)
    s.mel('fl', 41, transpose(CAPITAL_HEAD, 2) + [('r', 1)], 60)
    s.timp_roll(43 * 4, 4, 'A2', 30, 90)

    # D 44-59: the tutti - the motif RESOLVED, the zone heads woven around it, choir, the Capital theme warm in the trumpets
    TH = ['D', 'G', 'Bm', 'A', 'G', 'D/F#', 'Em', 'A', 'D', 'Bm', 'G', 'A', 'G', 'A', 'D', 'D']
    for i, sym in enumerate(TH):
        bar = 44 + i
        bed(s, bar, sym, 70, bass='half', harp=50 if i % 2 else None)
        s.pad('choir', bar, sym, 56, low='D4')
        s.drum(bar, [(0, 'bd', -10), (1, 'snare', -30), (3, 'snare', -26)], 74)
        if i % 4 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, 80)
    stack(s, [('vln', 12, 0), ('hn', 0, -6)], 44, augment(motif('D4', 'major', resolved=True), 2), 94,
          form='RESOLVED, augmented (strings 8va + horns): many ways home')
    s.line('tpt', 48, CAP_A[:9], 66, transpose=12)
    s.line('cl', 50, BUF_D, 64)
    stack(s, [('vln', 12, 0), ('fl', 12, -10), ('hn', 0, -8)], 52, motif('D4', 'major', resolved=True), 96, form='RESOLVED (tutti)')
    s.line('fid', 54, DUMP_D, 74)
    s.line('vc', 55, DNA_D, 70)
    s.mel('hn', 56, GAIN_D, 80, transpose=12)
    s.hit('crash', 44 * 4, 62, dur=4)
    s.hit('crash', 52 * 4, 64, dur=4)

    warm(60)
    s.line('cl', 62, [('A4', 4), ('C#5', 4)], 62)
    s.line('vln', 62, [('F#5', 4), ('E5', 4)], 58)
    s.timp_roll(63 * 4 + 2, 2, 'A2', 30, 64)
    return s
