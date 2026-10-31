"""MUS-LAB-RESCUE - The hand that helped (postgame: rescuing the defected Path-ologist). One-shot, 24 bars 4/4, 80 BPM, A minor -> A major.
Orchestral, not techno. Urgency first: tremolo strings and a pulsing low string ostinato in A minor, the Crossroads head asked again and
again in the horn, unfinished (the prologue's rescue phrase). Then the turn to A major: clarinet and oboe carry a warm tune over harp and
strings, guilt and courage held together in a minor-chord shadow, and at last the motif answered - resolved - in the violins (a release
cue, like the zone *-RELEASE cues). The ending breathes on a long A major chord.
"""
from lib import Score, motif, motif_head, augment, m, p


def build():
    s = Score('MUS-LAB-RESCUE', bpm=80, bars=24, key='A major', seed=905, kind='oneshot')
    s.lufs = -20
    s.seat('trem', 'spic', 'vc', 'cb', 'pad', 'vln', 'harp', 'hn', 'cl', 'ob', 'fl', 'timp')
    for bar, nm in ((0, 'urgency'), (6, 'turn'), (8, 'relief'), (16, 'answered'), (20, 'breath')):
        s.section(bar, nm)

    # 0-5 urgency in A minor
    for i, sym in enumerate(['Am', 'Am', 'F', 'E', 'Dm', 'E']):
        bar = i
        s.pad('trem', bar, sym, 60 + i * 3, low='A3')
        b = s.voicing(sym)[0]
        for k in range(8):
            s.note('spic', bar * 4 + k * .5, .4, p(b) + 12 if k % 2 == 0 else p(b) + 19, 66 + (8 if k % 4 == 0 else 0), human=k > 0)
        s.note('cb', bar * 4, 3.9, b, 60)
    s.note('trem', 0, 3.9, p('A3'), 70, human=False)
    s.timp_hit(0, 'A2', 76)
    s.swell('trem', 0, 6, 70, 105)
    s.motif('hn', 1, motif_head('A3', 'minor', rhythm=(1, .5, 2.5)), 82, form='head (horn, the unfinished rescue phrase)')
    s.motif('hn', 3, motif_head('A3', 'minor', rhythm=(1, .5, 2.5)), 86, form='head (horn, again)')
    s.mel('vln', 4, m('F5:2 E5:2 | D5:1 E5:1 G#5:2'), 84)
    s.timp_roll(5 * 4, 4, 'E2', 50, 86)

    # 6-7 the turn: E7sus -> A major, the tremolo stops
    s.pad('pad', 6, 'E7sus4', 60, beats=4, low='A3')
    s.pad('pad', 7, 'E7', 62, beats=4, low='G#3')
    s.note('cb', 24, 7.9, p('E2'), 56)
    s.mel('fl', 6, m('B5:2 A5:1 G#5:1 | E5:4'), 70)
    s.harp(7, 'E7', 50)

    # 8-15 relief: clarinet then oboe sing over harp + strings; a minor-chord shadow at 12-13 (guilt beside the relief)
    prog = ['A', 'C#m', 'D', 'A/C#', 'Bm7', 'F#m', 'D', 'E']
    for i, sym in enumerate(prog):
        bar = 8 + i
        s.pad('pad', bar, sym, 52, low='A3')
        s.harp(bar, sym, 48)
        s.bass(bar, sym, 52, 'whole')
    s.swell('pad', 8, 8, 70, 96)
    s.mel('cl', 8, m('E4:1 A4:1 C#5:1.5 B4:.5 | A4:2 G#4:1 E4:1 | F#4:1.5 A4:.5 D5:2 | C#5:4'), 80)
    s.mel('ob', 12, m('D5:1.5 C#5:.5 B4:2 | A4:1 C#5:1 F#5:2 | F#5:1.5 E5:.5 D5:1 F#5:1 | E5:4'), 80)
    s.motif('vc', 12, motif('B3', 'minor') + [('r', 1)], 62, form='stated (cello, guilt beneath the oboe)', lead=False)

    # 16-19 answered: the motif resolved in the violins, horns underneath
    for i, sym in enumerate(['A', 'E/G#', 'F#m', 'D', ]):
        bar = 16 + i
        s.pad('pad', bar, sym, 62, low='A3')
        s.harp(bar, sym, 52, density=16)
        s.bass(bar, sym, 58, 'whole')
    s.motif('vln', 16, augment(motif('A4', 'major', resolved=True), 1.0) + [('r', 1)], 92, form='RESOLVED (violins: the rescue lands)')
    s.line('hn', 16, augment(motif('A3', 'major', resolved=True), 1.0), 70)
    s.mel('vln', 18, m('F#5:1 E5:1 D5:1 C#5:1 | B4:2 E5:2'), 88)
    s.timp_roll(19 * 4 + 2, 2, 'E2', 46, 78)

    # 20-23 breath: the long A major chord
    s.pad('pad', 20, 'Aadd9', 60, beats=16, low='A3')
    s.pad('vln', 20, 'A', 58, beats=12, low='C#5', n=3)
    s.note('cb', 80, 15.9, p('A1'), 56)
    s.note('vc', 80, 15.9, p('A2'), 54)
    s.timp_hit(80, 'A2', 64)
    s.mel('fl', 20, m('E5:2 C#5:2 | A4:8'), 62)
    s.note('harp', 80, 6, p('A4'), 56)
    s.note('harp', 81, 6, p('C#5'), 52)
    s.note('harp', 82, 6, p('E5'), 50)
    return s
