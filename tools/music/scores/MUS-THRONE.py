"""MUS-THRONE - The Pathwork Throne (ending: full memory and power return). One-shot, 20 bars 4/4, 76 BPM, D major, ~70 s with the ring-out.
Many different voices held together. The COMPLETE lullaby for the first time (head + answer), flute and piano over warm strings and harp.
Then again, broader, in the strings with the horn, the four Path voices woven around it as counterlines (Gainlands horn, Buffet clarinet,
D.N.A. bassoon, Dump solo violin) - an arrangement, not a medley. The lullaby ends on its dominant and the Crossroads motif answers it,
RESOLVED in D major, augmented, with choir and timpani: the earned resolution. A long D major chord rings out.
"""
from lib import Score, p, voice, motif, augment, transpose
from lib.zones import BUFFET_THEME_A, DUMP_JIG_HEAD
from scores._fork_b import LULLABY, lullaby_bed, GAIN_THEME, held, stack


def build():
    s = Score('MUS-THRONE', bpm=76, bars=20, key='D major', seed=1690, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'fl', 'cl', 'bsn', 'hn', 'tpt', 'timp', 'choir', 'cel', 'piano', 'perc')
    for bar, nm in ((0, 'glimmer'), (2, 'the lullaby, whole'), (7, 'the lullaby, all voices'), (12, 'crossroads RESOLVED'),
                    (16, 'ring')):
        s.section(bar, nm)
    s.notes.append('First complete lullaby in the game (head + answer). Crossroads motif RESOLVED (ending cue).')

    # 0-1: starts instantly - harp + strings on D, a celesta glimmer
    for t in voice('D', 'D3', 4):
        s.note('harp', 0, 4, t, 66, human=False)
    s.note('cb', 0, 8, p('D2'), 54, human=False)
    s.pad('pad', 0, 'Dsus2', 54, beats=4)
    s.pad('pad', 1, 'A', 54, beats=4)
    s.mel('cel', 0, [('A5', 1), ('D6', 1), ('E6', 2), ('F#6', 2), ('E6', 2)], 56)

    # 2-6: the whole lullaby, flute + piano
    lullaby_bed(s, 8, 0, 50, harp=46)
    s.mel('fl', 2, LULLABY, 82, transpose=12)
    s.line('piano', 2, LULLABY, 58)
    s.line('vc', 3, [('F3', 4), ('E3', 4), ('D3', 4), ('C#3', 4)], 52)

    # 7-11: again, strings 8va + horn, the Path voices woven around it
    lullaby_bed(s, 28, 0, 58, harp=48)
    stack(s, [('vln', 12, 0), ('hn', 0, -10)], 7, LULLABY, 88)
    s.line('cl', 8, transpose(BUFFET_THEME_A[:6], -3), 58)
    s.line('bsn', 9, [('A3', 1), ('F3', 1), ('D4', 2), ('E4', 2), ('A3', 2)], 56)
    s.line('fl', 10, transpose(DUMP_JIG_HEAD[:8], -2 + 12), 52)
    s.line('tpt', 10, transpose(GAIN_THEME[:5], 4 - 12), 54, beat=2)
    s.swell('vln', 7, 5, 80, 110, 'arch')
    s.timp_roll(11 * 4, 4, 'A2', 30, 84)

    # 12-15: the Crossroads motif RESOLVED in D major, augmented, choir + timpani
    for i, sym in enumerate(['D', 'G', 'Em7 A', 'D']):
        for off, beats, c in s.parts(sym):
            s.pad('pad', 12 + i, c, 70, beats=beats, beat=off)
            s.pad('choir', 12 + i, c, 62, beats=beats, beat=off, low='D4')
            s.bass_at((12 + i) * 4 + off, beats, c, 70)
        s.harp(12 + i, sym.split()[0], 50)
    res = augment(motif('D4', 'major', resolved=True), 2)[:5] + [('D4', 4)]
    stack(s, [('hn', 0, 0), ('vln', 12, -4), ('tpt', 0, -14)], 12, res, 94, form='RESOLVED, augmented (horns + strings): the throne')
    s.note('timp', 12 * 4, 1, p('D3'), 84)
    s.hit('crash', 15 * 4, 58, dur=4)

    # 16-19: the D major chord rings out
    held(s, 15, 'D', 18, 72, ['pad'], low='D3')
    held(s, 15, 'D', 18, 62, ['choir'], low='F#4', n=3)
    s.note('cb', 60, 18, p('D2'), 60)
    s.note('vc', 60, 18, p('D3'), 54)
    s.note('timp', 60, 1, p('D3'), 74)
    s.harp(16, 'D', 50, density=16)
    s.mel('cel', 17, [('F#6', 2), ('A6', 2), ('D7', 4)], 50)
    return s
