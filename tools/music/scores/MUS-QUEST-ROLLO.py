"""MUS-QUEST-ROLLO - Rollo Spokes, the wheel never stops (Capital Path quest conclusion, Beefcake). One-shot, 24 bars 4/4, 88 BPM
easing to 70, Bb major, ~74 s with the ring-out.
Human cost underneath the joke. An exhausted Beefcake pulse - low pizzicato strings turning like a wheel, a soft snare - with the Gainlands
theme on a weary horn. Then the pulse lets go: the tempo eases, the snare stops, and the strings take the theme in free, broad phrasing (the
wheel finally stops). The Crossroads motif's head in the clarinet. Courage underneath the breathless jokes; it closes on a warm Bb chord.
"""
from lib import Score, p, voice, motif_head
from scores._fork_b import GAIN_THEME, GAIN_H, held


def build():
    s = Score('MUS-QUEST-ROLLO', bpm=88, bars=24, key='Bb major', seed=1822, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'pizz', 'hn', 'cl', 'harp', 'perc', 'timp')
    for bar, bpm in ((8, 84), (10, 78), (12, 74), (20, 70)):
        s.tempo(bar, bpm)
    for bar, nm in ((0, 'the wheel'), (8, 'easing'), (12, 'free phrasing'), (20, 'rest')):
        s.section(bar, nm)
    s.notes.append('Tempo eases 88 -> 70 in steps; the snare and wheel ostinato stop at bar 12.')

    def wheel(bar, sym, vel=56):
        tn = voice(sym, 'Bb2', 3)
        for k in range(8):
            s.note('pizz', bar * 4 + k * .5, .4, (tn + [tn[1]])[k % 4], vel + (8 if k % 4 == 0 else -4))

    # 0-11: the tired wheel and the weary horn
    for i in range(12):
        sym = GAIN_H[i]
        wheel(i, sym, 56 - i)
        s.pad('pad', i, sym, 46)
        s.note('cb', i * 4, 4.02, p(s.voicing(sym)[0]), 50)
        if i < 10:
            s.drum(i, [(1, 'snare', -30), (3, 'snare', -32)], 66 - i * 2)
    s.mel('hn', 0, GAIN_THEME[:16], 76)
    s.mel('hn', 4, GAIN_THEME[16:30], 72)
    s.motif('cl', 8, motif_head('Bb4', 'major', rhythm=(1.5, .5, 2)), 64, form='head (clarinet), catching breath')
    s.line('vc', 8, [('D3', 4), ('C3', 4), ('Eb3', 4), ('F3', 4)], 52)

    # 12-19: free phrasing - the strings take the theme broadly, harp instead of the wheel
    for i in range(8):
        sym = GAIN_H[8 + i]
        s.pad('pad', 12 + i, sym, 54)
        s.harp(12 + i, sym, 48)
        s.note('cb', (12 + i) * 4, 4.02, p(s.voicing(sym)[0]), 52)
    s.mel('vln', 12, GAIN_THEME[30:], 84, transpose=12)
    s.line('hn', 12, [('D4', 4), ('F4', 4), ('G4', 4), ('F4', 4), ('Eb4', 4), ('Eb4', 4), ('F4', 4), ('D4', 4)], 58)
    s.swell('vln', 12, 8, 80, 106, 'arch')
    s.timp_roll(19 * 4 + 2, 2, 'F2', 28, 60)

    # 20-23: rest on Bb
    held(s, 20, 'Bb', 14, 52, ['pad'], low='D3')
    held(s, 20, 'Bb', 14, 46, ['hn'], low='F3', n=3)
    s.harp(20, 'Bb', 46, density=16)
    s.note('cb', 80, 14, p('Bb1'), 46)
    s.mel('cl', 20, [('F5', 2), ('D5', 2), ('Bb4', 8)], 60)
    return s
