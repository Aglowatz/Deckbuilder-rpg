"""MUS-GRAVE-EXP - Old Hob's evening hum (Crosspath graveyard). Loop, 64 bars 3/4, 96 BPM, G minor.
Creepy-cheerful: a slow, crooked funeral phrase (_fork_c.GRAVE_HUM) that Old Hob hums - first the bassoon, then the oohs choir as his
voice, with the bassoon grumbling a counter-line. Pizzicato on the downbeat, soft cello, a celesta and glockenspiel twinkling like
lantern light, a xylophone rattling like friendly bones. A faintly amusing B section in Bb major (clarinet, the Crossroads motif) and a
misty C section with real unease underneath (tremolo strings, the motif inverted in the cello, the hum broken into pieces). No organ:
the graveyard is kept apart from the D.N.A.'s administrative sound.
"""
from lib import Score, motif, motif_head, augment, m, p, transpose
from scores._fork_c import GRAVE_HUM, GRAVE_PROG


def build():
    s = Score('MUS-GRAVE-EXP', bpm=96, bars=64, meter=(3, 4), key='G minor', seed=964)
    s.seat('pad', 'trem', 'vc', 'cb', 'pizz', 'bsn', 'cl', 'cel', 'glock', 'xylo', 'harp', 'fl')
    s.channel('hob', 'oohs', pan=60, reverb=105, vol=82)
    for bar, nm in ((0, 'lanterns'), (4, 'A the hum (bassoon, then Hob)'), (20, 'B amusing'), (36, 'C mist'), (52, 'D all hum'),
                    (60, 'lanterns')):
        s.section(bar, nm)

    def oom(bar, sym, vel, crooked=False):
        b = s.voicing(sym)[0]
        s.note('cb', bar * 3, 1.2, b, vel + 4)
        v = s.voicing(sym, 'D4', 3)[1]
        beats = (1.5, 2.5) if crooked else (1, 2)       # the crooked bar: the chords arrive late
        for bt in beats:
            for t in v:
                s.note('pizz', bar * 3 + bt, .4, t, vel - 8)

    def twinkle(bar, sym, vel):
        v = s.voicing(sym, 'G5', 3)[1]
        s.note('cel', bar * 3 + 1, .5, v[2], vel)
        s.note('cel', bar * 3 + 1.5, .5, v[1], vel - 6)
        s.note('glock', bar * 3 + 2.5, .4, v[0] + 12, vel - 16)

    def intro(bar):
        for i, sym in enumerate(['Gm', 'Eb', 'Cm', 'D7']):
            oom(bar + i, sym, 54, crooked=i == 2)
            twinkle(bar + i, sym, 50)
            s.pad('pad', bar + i, sym, 40, low='G3')
        s.motif('cl', bar, motif_head('G4', 'minor', rhythm=(1.5, .75, .75)) + [('r', 3)], 64, form='head (clarinet, a lantern peeking)')
        s.mel('bsn', bar + 2, m('C3:1 Eb3:1 D3:1 | D3:3'), 66)

    intro(0)

    # A 4-19: the hum - bassoon (4-11), then Old Hob humming on oohs (12-19) with the bassoon below
    for i in range(16):
        bar, sym = 4 + i, GRAVE_PROG[i % 8]
        oom(bar, sym, 56, crooked=i % 8 == 5)
        if i % 2 == 1:
            twinkle(bar, sym, 46)
        s.pad('pad', bar, sym, 36, low='G3')
    s.mel('bsn', 4, GRAVE_HUM, 84)
    s.mel('hob', 12, GRAVE_HUM, 84, transpose=12)
    s.line('bsn', 12, m('G3:3 | F#3:3 | G3:3 | A3:3 | Bb3:3 | Eb3:3 | D3:3 | G3:3'), 58)
    s.line('vc', 8, m('D4:3 | C4:3 | Bb3:3 | A3:3'), 54)
    s.mel('xylo', 11, m('D5:.5 D5:.5 r:2'), 60)
    s.mel('xylo', 19, m('G5:.5 F#5:.5 G5:.5 r:1.5'), 60)

    # B 20-35: faintly amusing - Bb major, clarinet tune and the motif, xylophone bones, pizz walking
    bprog = ['Bb', 'F/A', 'Gm', 'Eb', 'Bb', 'Cm', 'F7', 'Bb', 'Eb', 'Bb/D', 'Cm', 'F', 'Gm', 'Eb', 'D', 'D7']
    for i, sym in enumerate(bprog):
        bar = 20 + i
        oom(bar, sym, 56, crooked=i in (6, 13))
        s.pad('pad', bar, sym, 40, low='F3')
        if i % 4 == 2:
            s.mel('xylo', bar, m('F5:.5 Bb5:.5 F5:.5 D5:.5 r:1'), 58)
    s.motif('cl', 20, augment(motif('Bb4', 'major'), 1.5)[:5] + [('F5', 3), ('r', 1.5)], 80, form='stated (clarinet, Bb major, amused)')
    s.mel('cl', 26, m('D5:1 C5:1 Bb4:1 | C5:2 A4:1 | Bb4:3 | r:3'), 78)
    s.mel('fl', 28, m('G5:1.5 F5:.5 Eb5:1 | D5:3 | Eb5:1 D5:1 C5:1 | D5:3 | Bb5:1 A5:1 G5:1 | Eb5:3 | F#5:3 | A5:3'), 72)
    s.line('bsn', 28, m('Eb3:3 | D3:3 | C3:3 | F3:3 | G3:3 | Eb3:3 | D3:3 | D3:3'), 60)

    # C 36-51: mist with unease - tremolo, the motif inverted in the cello, the hum in pieces
    cprog = ['Gm', 'Gm', 'Ab', 'Ab', 'Cm', 'Cm', 'D', 'D'] * 2
    for i, sym in enumerate(cprog):
        bar = 36 + i
        s.pad('trem', bar, sym, 44 + (i % 8) * 2, low='G3')
        s.note('cb', bar * 3, 2.9, s.voicing(sym)[0], 50)
        if i % 4 == 0:
            twinkle(bar, sym, 40)
    s.swell('trem', 36, 8, 50, 90, back='arch')
    s.swell('trem', 44, 8, 50, 90, back='arch')
    s.motif('vc', 36, augment(motif('G3', 'minor', inverted=True), 1.5) + [('r', 1.5)], 76, form='inverted (cello, unease)')
    s.mel('hob', 42, transpose(GRAVE_HUM[:4], 12) + [('r', 3)], 70)
    s.mel('bsn', 44, GRAVE_HUM[4:8] + [('r', 3)], 70)
    s.mel('cl', 46, m('Ab4:3 | G4:2 F#4:1 | G4:3 | r:3'), 66)
    s.mel('hob', 50, m('D4:3 | F#4:3'), 64)

    # D 52-59: everyone hums - oohs, bassoon and cello in octaves, harp
    for i in range(8):
        bar, sym = 52 + i, GRAVE_PROG[i]
        oom(bar, sym, 58, crooked=i == 5)
        s.harp(bar, sym, 44)
        s.pad('pad', bar, sym, 44, low='G3')
    s.mel('hob', 52, GRAVE_HUM, 86, transpose=12)
    s.line('bsn', 52, GRAVE_HUM, 70)
    s.line('vc', 52, GRAVE_HUM, 62, transpose=12)

    intro(60)
    return s
