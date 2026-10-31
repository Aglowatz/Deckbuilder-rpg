"""MUS-MEM-03 - The coup (third freed-zone memory). One-shot, 28 bars 4/4, 92 BPM, C minor -> Eb major, ~78 s with the ring-out.
Royal safety violently interrupted. It begins with a royal phrase in Eb - horns and strings, a dignified processional built on the
Crossroads motif's head, a harp and soft timpani. At bar 8 Primm's rigid pulse cuts in: quantised snare rudiments, a low string tremolo,
the Primm motif in even notes in the low brass, C minor, the royal phrase trying twice to return and being cut off. Then everything thins
out for Maren's admission - a solo clarinet over a held cello. Serious and restrained; the last bars warm into Eb major (the motif's head
in the flute over a soft horn chord): hope remains.
"""
from lib import Score, p, voice, motif, motif_head, PRIMM_HEAD, PRIMM_ANSWER
from lib.capital import rudiment
from scores._fork_b import held

ROYAL = [('Eb4', 1), ('Bb4', .5), ('Ab4', .5), ('G4', 1.5), ('F4', .5), ('G4', 2), ('Ab4', 1), ('Bb4', 1),
         ('C5', 1.5), ('Bb4', .5), ('Ab4', 1), ('G4', 1), ('F4', 3), ('r', 1)]           # 4 bars
PRIMM_C = [(p(n) - 12, d) for n, d in PRIMM_HEAD + PRIMM_ANSWER]


def build():
    s = Score('MUS-MEM-03', bpm=92, bars=28, key='C minor -> Eb major', seed=1813, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'tbn', 'cl', 'fl', 'timp', 'trem', 'perc')
    for bar, nm in ((0, 'royal phrase'), (8, 'the pulse cuts in'), (18, "Maren's admission"), (24, 'hope')):
        s.section(bar, nm)
    s.notes.append('Primm motif even, quantised hits for the coup; the royal phrase is the Crossroads head (Eb major).')

    # 0-7: royal phrase - starts instantly on a horn + string chord and a timpani stroke
    s.note('timp', 0, 1, p('Eb3'), 70, human=False)
    for i, sym in enumerate(['Eb', 'Ab', 'Cm', 'Bb', 'Eb', 'Abmaj7', 'Fm7', 'Bb7sus4']):
        s.pad('pad', i, sym, 56)
        s.brass('hn', i, sym, 50, low='Eb3')
        s.harp(i, sym, 46)
        s.note('cb', i * 4, 4.02, p(s.voicing(sym)[0]), 50)
    s.motif('vln', 0, ROYAL[:6], 84, form='head as a royal processional (strings)', transpose=12)
    s.mel('vln', 0, ROYAL[6:], 84, transpose=12, beat=7)
    s.mel('hn', 4, ROYAL, 82)

    # 8-17: the rigid pulse - quantised rudiments, low tremolo, Primm's motif in the low brass; the royal phrase cut off twice
    save = (s.jitter, s.vel_spread)
    for i in range(10):
        bar = 8 + i
        sym = ['Cm', 'Cm', 'Ab', 'G', 'Cm', 'Fm', 'Ab', 'G', 'Cm', 'G'][i]
        s.pad('trem', bar, sym, 60, low='C3')
        s.note('cb', bar * 4, 4.02, p(s.voicing(sym)[0]), 60)
        s.jitter, s.vel_spread = 0, 0
        rudiment(s, 'perc', bar, 'march' if i % 2 == 0 else 'paradiddle', 60)
        s.jitter, s.vel_spread = save
        if i % 2 == 0:
            s.note('timp', bar * 4, .9, p(s.voicing(sym)[0]) + 12, 76)
    s.jitter, s.vel_spread = 0, 0
    s.mel('tbn', 8, PRIMM_C, 82)
    s.line('vc', 8, PRIMM_C, 64)
    s.mel('tbn', 14, PRIMM_C[:8], 84)
    s.jitter, s.vel_spread = save
    s.line('hn', 12, ROYAL[:3], 78)                 # the royal phrase tries to return - cut off
    s.line('vln', 16, ROYAL[:4], 70, transpose=12)

    # 18-23: thin out - a solo clarinet over a held cello, Maren's admission
    for i, sym in enumerate(['Ab', 'Fm', 'Cm', 'G7sus4', 'Ab', 'Bb7sus4']):
        s.pad('pad', 18 + i, sym, 34)
        s.note('cb', (18 + i) * 4, 4.02, p(s.voicing(sym)[0]), 36)
    s.line('vc', 18, [('C3', 8), ('Bb2', 8), ('Ab2', 8)], 50, shape=False)
    s.mel('cl', 18, [('Eb5', 2), ('D5', 1), ('C5', 1), ('Bb4', 4), ('C5', 2), ('Ab4', 2), ('G4', 4), ('Ab4', 1), ('Bb4', 1),
                     ('C5', 2), ('D5', 4), ('Eb5', 6), ('r', 2)], 70)

    # 24-27: warmth - Eb major, the motif's head in the flute, a soft horn chord
    held(s, 24, 'Eb', 16, 48, ['pad'], low='Eb3')
    held(s, 24, 'Eb', 16, 44, ['hn'], low='Eb3', n=3)
    s.harp(24, 'Eb', 44, density=16)
    s.note('cb', 96, 16, p('Eb2'), 42)
    s.motif('fl', 24, motif_head('Eb5', 'major', rhythm=(2, 1, 1)) + [('G5', 8)], 64, form='head (flute), hope')
    return s
