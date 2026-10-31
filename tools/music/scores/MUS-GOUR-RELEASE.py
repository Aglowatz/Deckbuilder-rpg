"""MUS-GOUR-RELEASE - The true Chef and a name freely given. One-shot story cue, 21 bars 4/4, 76 BPM, F major (~66 s + ring).
The Buffet theme slowed into a sincere character moment: its welcome phrase at half speed on a warm cello over piano and a soft string
bed, the clarinet answering playfully in the rests, the violins taking the second phrase, and then the Crossroads motif RESOLVED, slowly,
in the horn and cello - the question answered - onto a held F major chord that rings out. Low busyness: room for dialogue.
"""
from lib import Song, motif, motif_head, augment, p
from lib.zones import BUFFET_THEME_A, BUFFET_THEME_8, BUFFET_CHORDS


def build():
    s = Song('MUS-GOUR-RELEASE', bpm=76, bars=21, key='F major', seed=406, kind='oneshot', jitter=0.02)
    s.lufs = -20.0
    s.V = dict(BUFFET_CHORDS)
    s.channel('vc', 'cello', 82, 90, 100)
    s.channel('vln', 'strings', 36, 100, 92)
    s.channel('pad', 'slow_strings', 64, 100, 76)
    s.channel('piano', 'piano', 58, 85, 78)
    s.channel('cl', 'clarinet', 60, 85, 80)
    s.channel('hn', 'horn', 78, 95, 88)
    s.channel('harp', 'harp', 46, 85, 74)
    s.channel('cb', 'contrabass', 92, 90, 80)
    s.channel('glock', 'glock', 44, 100, 54)
    for bar, nm in ((0, 'opening'), (4, 'cello theme'), (12, 'violins'), (16, 'resolution'), (20, 'held chord')):
        s.section(bar, nm)

    def bed(bar, sym, vel, bars=1):
        s.pad('pad', bar, sym, vel, beats=4 * bars)
        s.note('cb', bar * 4, 4 * bars, p(s.V[sym][0]), vel - 6)
        tn = s.chord_tones(sym, 'F3', 6)
        for k in range(8 * bars):
            s.note('piano', bar * 4 + k * .5, 1.2, tn[(0, 2, 4, 2, 1, 3, 5, 3)[k % 8]], vel - 10)

    for i, sym in enumerate(['F', 'Bb', 'Dm', 'C7']):
        bed(i, sym, 52)
    s.motif('cl', 1, augment(motif_head('F4', 'major'), 2) + [('r', 2)], 68, form='head augmented (clarinet, opening)')
    s.note('glock', 0, 3, 'C6', 44)
    s.chord('piano', 0, 3, ['F2', 'C3', 'F3', 'A3'], 78, spread=0.0)     # a clear first sound: the cue starts at once
    s.chord('harp', 0, 3, ['F3', 'C4', 'A4'], 70)

    # 4-11: the welcome phrase at half speed on the cello; clarinet answers in the rests
    for k, sym in enumerate(['F', 'Dm', 'Gm7', 'C7']):
        bed(4 + 2 * k, sym, 50, bars=2)
    s.mel('vc', 4, augment(BUFFET_THEME_A, 2), 86, tr=-12)
    s.line('cl', 7, [('r', 2), ('A5', .5), ('Bb5', .5), ('C6', 1)], 62)
    s.line('cl', 11, [('r', 2), ('G5', .5), ('A5', .5), ('Bb5', 1)], 62)
    s.harp(11, 'C7', 44)

    # 12-15: the violins take the second phrase, gently
    for k, sym in enumerate(['F', 'D7', 'Gm', 'C7']):
        bed(12 + k, sym, 54)
    s.mel('vln', 12, BUFFET_THEME_8[21:40] + [('r', 1)], 82)
    s.swell('vln', 12, 4, 80, 100, 'arch')

    # 16-19: the motif RESOLVED, slowly, horn then cello
    for k, sym in enumerate(['Bb', 'F/A', 'Gm7', 'C7']):
        bed(16 + k, sym, 50)
    s.motif('hn', 16, motif('F3', 'major', resolved=True), 80, form='RESOLVED (horn, slowly)')
    s.motif('vc', 18, [('Bb3', 2), ('A3', 2), ('G3', 2), ('F3', 2)], 76, form='resolved tail (cello, falling home)')

    # 20: the held F major chord, ringing out
    s.pad('pad', 20, 'F', 60, beats=4)
    s.chord('vln', 80, 4, ['F4', 'A4', 'C5', 'F5'], 64)
    s.note('vc', 80, 4, 'F3', 66)
    s.note('cb', 80, 4, 'F2', 58)
    s.harp(20, 'F', 50, density=8)
    s.note('glock', 80, 3, 'F6', 40)
    return s
