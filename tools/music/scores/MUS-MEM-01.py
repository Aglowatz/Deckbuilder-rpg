"""MUS-MEM-01 - Warmth (first freed-zone memory). One-shot, 22 bars 4/4, 72 BPM, F major, ~78 s with the ring-out.
A woman humming, four-coloured light. Soft piano arpeggios and a protective cello line; a hummed voice (oohs) sings the lullaby's first four
notes ONLY (F C A G - the lullaby rule) and trails off before the answer. Four glints of coloured light - celesta, harp, glockenspiel,
flute - each a small Path colour. The Crossroads motif in the flute, the cello holding it from below. Tender recognition; it ends quietly
on an unresolved Gm7/C - the memory slips away before it finishes.
"""
from lib import Score, p, voice, motif, motif_head
from scores._fork_b import first_four_lullaby

H = ['F', 'Am7', 'Bbmaj7', 'C7sus4', 'Dm7', 'Bbmaj7', 'Gm7', 'Csus4']


def build():
    s = Score('MUS-MEM-01', bpm=72, bars=22, key='F major', seed=1811, kind='oneshot')
    s.lufs = -20.0
    s.seat('piano', 'vc', 'cb', 'pad', 'fl', 'harp', 'cel', 'glock', piano={'vol': 84}, pad={'vol': 64})
    s.channel('hum', 'oohs', pan=52, reverb=110, vol=80)
    for bar, nm in ((0, 'piano'), (4, 'humming'), (10, 'four colours'), (14, 'crossroads'), (20, 'slipping away')):
        s.section(bar, nm)
    s.notes.append('Lullaby: first four notes only (hummed, oohs), bar 4. Ends unresolved (Gm7/C) per the row.')

    def arp(bar, sym, vel=46):
        tn = voice(sym, 'F3', 4)
        s.note('piano', bar * 4, 4, p(s.voicing(sym)[0]) + 12, vel)
        for k in range(8):
            s.note('piano', bar * 4 + k * .5, .9, (tn + [t + 12 for t in tn])[(0, 1, 2, 3, 4, 3, 2, 1)[k]], vel - 8)

    for i in range(4):
        arp(i, ['F', 'Bbmaj7', 'F', 'C7sus4'][i])
    s.mel('piano', 0, [('A5', 2), ('C6', 2), ('Bb5', 2), ('A5', 2), ('G5', 4), ('F5', 2), ('G5', 2), ('C5', 8)], 58)
    s.line('vc', 2, [('A3', 4), ('G3', 4)], 54)

    # 4-9: the humming - the lullaby's first four notes, then it drifts off
    for i, sym in enumerate(['F', 'F', 'Bbmaj7', 'Gm7', 'Dm7', 'C7sus4']):
        arp(4 + i, sym, 44)
        s.pad('pad', 4 + i, sym, 38)
    s.mel('hum', 4, first_four_lullaby(3, durs=(2, 2, 2, 4)) + [('r', 2)], 70)
    s.mel('hum', 7, [('D5', 2), ('C5', 2), ('A4', 4), ('r', 4), ('G4', 4), ('F4', 4)], 58)
    s.line('vc', 4, [('F3', 8), ('D3', 4), ('G3', 4), ('A3', 4), ('C3', 4)], 56)

    # 10-13: four coloured glints over the warm bed
    for i, sym in enumerate(['Bbmaj7', 'F/A', 'Gm7', 'C7sus4']):
        arp(10 + i, sym, 42)
        s.pad('pad', 10 + i, sym, 40)
        s.note('cb', (10 + i) * 4, 4.02, p(s.voicing(sym)[0]), 40)
    s.mel('cel', 10, [('D6', 1), ('F6', 1), ('A6', 2)], 52)
    s.harp(11, 'F/A', 52, density=16)
    s.mel('glock', 12, [('G6', 1), ('Bb6', 1), ('D7', 2)], 44)
    s.mel('fl', 13, [('C6', 1), ('E6', 1), ('G6', 2)], 56)

    # 14-19: the Crossroads motif in the flute, the cello beneath
    for i, sym in enumerate(H[:6]):
        arp(14 + i, sym, 44)
        s.pad('pad', 14 + i, sym, 42)
        s.note('cb', (14 + i) * 4, 4.02, p(s.voicing(sym)[0]), 42)
    s.motif('fl', 14, motif('F5', 'major', rhythm=[1.5, .75, .75, 2.5, .5, 6]), 72, form='stated (flute), tender')
    s.line('vc', 14, [('F3', 4), ('E3', 4), ('D3', 4), ('C3', 4), ('Bb2', 4), ('D3', 4)], 58)
    s.motif('cel', 18, motif_head('F5', 'major', rhythm=(1, 1, 2)), 46, form='head (celesta), an echo', lead=False)

    # 20-21: slipping away on Gm7/C
    s.V['Gm7/C'] = ('C2', ['Bb3', 'D4', 'F4', 'G4'])
    for t in voice('Gm7', 'Bb3', 4):
        s.note('pad', 80, 8, t, 40)
    s.note('piano', 80, 8, p('C3'), 40)
    for k, t in enumerate([p('G4'), p('Bb4'), p('D5'), p('F5')]):
        s.note('piano', 80 + k * .5, 7, t, 38)
    s.note('cb', 80, 8, p('C2'), 38)
    s.mel('hum', 20, [('G4', 4), ('F4', 4)], 46)
    return s
