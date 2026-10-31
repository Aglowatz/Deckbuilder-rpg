"""MUS-REUNION - Alive. File complete. (ending reunion: the freed leaders gather; Maren calls him Tessar). One-shot, 24 bars 4/4,
84 BPM, G major, ~72 s with the ring-out.
Belonging, kindness and restored identity: a warm chamber ensemble (string trio, flute, clarinet, bassoon, horn, harp, celesta) with each
Path's colour as affectionate punctuation - a horn call (Gainlands), a clarinet's welcome flourish (Buffet), a bassoon's dry little waltz
step (D.N.A.), a solo violin's jig turn (Dump). The whole lullaby in G, first in the clarinet, then in the violins with the flute above it;
the Crossroads motif RESOLVED in the horn as a gentle royal cadence; the last three bars hold a soft G major chord for Agnes's final line.
"""
from lib import Score, p, voice, motif, motif_head, transpose
from lib.zones import BUFFET_THEME_A, DNA_THEME, DUMP_JIG_HEAD, to_mode
from scores._fork_b import LULLABY, lullaby_bed, GAIN_THEME, held, stack, MAJ_FROM_CMIN

LUL_G = transpose(LULLABY, 5)


def build():
    s = Score('MUS-REUNION', bpm=84, bars=24, key='G major', seed=1700, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'vla', 'vc', 'cb', 'pad', 'harp', 'fl', 'cl', 'bsn', 'hn', 'cel', 'pizz', 'timp', pad={'vol': 66})
    s.channel('fid', 'violin', pan=28, reverb=88, vol=82)
    for bar, nm in ((0, 'gathering'), (4, 'lullaby: clarinet'), (9, 'Path punctuation'), (13, 'lullaby: violins'),
                    (18, 'royal cadence'), (21, 'space for Agnes')):
        s.section(bar, nm)
    s.notes.append('Whole lullaby (after the reveal), in G. Crossroads RESOLVED (homecoming). Last 3 bars held and quiet for dialogue.')

    def walk(bar, sym, vel=50):
        s.pizz(bar, sym, vel, pattern=[(0, 'b'), (1, 1), (2, 'f'), (3, 2)])
        s.pad('pad', bar, sym, vel - 12, low='D3')

    # 0-3: starts instantly - harp + pizz on G, punctuations greet each other
    for t in voice('G', 'D3', 4):
        s.note('harp', 0, 3, t, 64, human=False)
    for i, sym in enumerate(['G', 'Em7', 'Cmaj7', 'D7sus4']):
        walk(i, sym)
        s.note('cb', i * 4, 4.02, p(s.voicing(sym)[0]), 46)
    s.mel('hn', 0, transpose(GAIN_THEME[:3], -3), 70)                   # a horn call
    s.mel('cl', 1, transpose(BUFFET_THEME_A[:5], 2), 66, beat=1)          # the welcome flourish
    s.mel('fid', 2, to_mode(transpose(DUMP_JIG_HEAD[:6], 3), {}), 64, beat=1)   # a jig turn
    s.mel('fl', 3, [('D6', 1), ('B5', 1), ('A5', 2)], 58)

    # 4-8: the whole lullaby in G, clarinet
    lullaby_bed(s, 16, 5, 48, harp=44)
    s.mel('cl', 4, LUL_G, 80)
    s.line('vc', 4, [('Bb3', 4), ('A3', 4), ('G3', 4), ('F3', 4), ('E3', 4)], 50)

    # 9-12: Path punctuation over the walking pizzicato, the Crossroads head passed around
    for i, sym in enumerate(['G', 'C', 'Am7', 'D']):
        walk(9 + i, sym, 54)
        s.note('cb', (9 + i) * 4, 4.02, p(s.voicing(sym)[0]), 50)
    s.motif('fl', 9, motif_head('G5', 'major'), 74, form='head (flute)')
    s.line('bsn', 9, [(p(n) + 7 - 12, d) for n, d in to_mode(DNA_THEME[:4], MAJ_FROM_CMIN)], 60, beat=2)     # a dry waltz step
    s.motif('hn', 10, motif_head('G3', 'major'), 70, form='head (horn)', lead=False)
    s.mel('fid', 11, to_mode(transpose(DUMP_JIG_HEAD, 3), {}), 70)
    s.line('cel', 12, [('B6', .5), ('G6', .5), ('D6', 1)], 48, beat=2)

    # 13-17: the lullaby in the violins, flute above
    lullaby_bed(s, 52, 5, 54, harp=46)
    stack(s, [('vln', 12, 0), ('vla', 0, -14)], 13, LUL_G, 86)
    s.line('fl', 14, [('D6', 4), ('C6', 4), ('Bb5', 4), ('A5', 4)], 52)
    s.swell('vln', 13, 5, 82, 108, 'arch')

    # 18-20: the gentle royal cadence - the motif RESOLVED in the horn
    for i, sym in enumerate(['C', 'D7sus4', 'G']):
        s.pad('pad', 18 + i, sym, 54, low='D3')
        s.harp(18 + i, sym, 48)
        s.note('cb', (18 + i) * 4, 4.02, p(s.voicing(sym)[0]), 52)
    s.motif('hn', 18, motif('G3', 'major', resolved=True, rhythm=[1, .5, .5, 2, 1, 7]), 84, form='RESOLVED (horn): a royal cadence')
    s.line('vln', 18, [('E5', 4), ('F#5', 4), ('G5', 4)], 60)
    s.note('timp', 20 * 4, 1, p('G2'), 60)

    # 21-23: a soft held G major chord, space for Agnes's final line
    held(s, 21, 'G', 13, 46, ['pad'], low='D3')
    s.note('cb', 84, 13, p('G1'), 42)
    s.note('vc', 84, 13, p('G2'), 40)
    s.mel('cel', 21, [('D6', 2), ('G6', 2), ('B6', 8)], 42)
    return s
