"""MUS-BEEF-RELEASE - Flex's rescue and true strength (story one-shot). 24 bars 4/4, 80 BPM, Bb major, ~74 s with the ring-out.
The Gainlands march slowed into a sincere character moment: the heavy rhythm loosens into a light swung pizzicato and tuba, breathing room
between phrases for dialogue. A warm horn sings the Gainlands theme (MUS-BEEF-EXP), the strings take its second half, and the Crossroads
motif - augmented, then RESOLVED to Bb (a release cue) - closes on a long held Bb major chord that rings out.
"""
from lib import Score, m, motif, augment, voice, p, split_beats

THEME = m('Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 D5:1 Bb4:1 | C5:1 D5:.5 Eb5:.5 F5:1 G5:1 | F5:3 r:1 '
          '| G5:1.5 F5:.5 Eb5:1 C5:1 | D5:1.5 C5:.5 Bb4:1 G4:1 | A4:1 C5:1 F5:1 A4:1 | Bb4:2 F4:1 r:1 '
          '| Bb4:1 F5:.5 Eb5:.5 D5:1.5 C5:.5 | F5:2 G5:1 A5:1 | Bb5:2 G5:1 Eb5:1 | F5:3 r:1 '
          '| Ab5:1.5 G5:.5 F5:1 Eb5:1 | G5:1.5 F5:.5 Eb5:1 D5:1 | C5:1 Eb5:1 D5:1 C5:1 | Bb4:3 r:1')
H1 = ['Bbmaj7', 'Gm7', 'Cm7', 'F7sus4', 'Ebmaj7', 'Gm7', 'F7', 'Bb6']
H2 = ['Bbmaj7', 'F/A', 'Ebmaj7', 'F7sus4', 'Abmaj7', 'Ebmaj7', 'Cm7 F7', 'Bb6']


def build():
    s = Score('MUS-BEEF-RELEASE', bpm=80, bars=24, key='Bb major', seed=818, kind='oneshot')
    s.lufs = -20.0                                 # story cue: sits with the loops
    s.swing = 0.14
    s.seat('hn', 'tpt', 'tbn', 'tuba', 'vln', 'pad', 'vc', 'cb', 'harp', 'cl', 'pizz', 'timp', 'perc')
    for bar, nm in ((0, 'opening'), (4, 'A horn theme'), (12, 'B strings, swing'), (20, 'resolution + held chord')):
        s.section(bar, nm)
    s.notes.append('Release cue: resolved motif allowed; starts instantly on a timpani + harp + string chord; held ending.')

    # opening 0-3: a soft timpani stroke and a held Bb chord start at once; the horn breathes the theme's head
    s.note('timp', 0, 2.0, p('Bb2'), 74, human=False)
    for n in voice('Bbmaj7', 'D3', 4):
        s.note('harp', 0, 3.0, n, 70, human=False)
    for i, sym in enumerate(['Bbmaj7', 'Ebmaj7', 'Bbmaj7', 'F7sus4']):
        s.pad('pad', i, sym, 56)
        s.note('cb', i * 4, 4.02, p(s.voicing(sym)[0]), 54)
    s.mel('hn', 1, m('Bb3:2 F4:1 Eb4:1 | D4:6 r:2'), 76)
    s.mel('cl', 3, m('r:2 C5:1 D5:1'), 58)

    # A 4-11: the warm horn on the first half of the theme; harp and soft tuba, plenty of room
    for i, sym in enumerate(H1):
        bar = 4 + i
        s.pad('pad', bar, sym, 52)
        s.harp(bar, sym, 46)
        s.note('tuba', bar * 4, 1.6, p(s.voicing(sym)[0]), 54)
    s.motif('hn', 4, THEME[:6], 84, form='stated (horn: the Gainlands fanfare, slowed)')
    s.mel('hn', 4, split_beats(THEME, 0, 32)[6:], 84, beat=7)
    s.line('vc', 8, m('Bb3:4 | Bb3:2 A3:2 | F3:4 | F3:4'), 52)

    # B 12-19: the strings take the second half; the rhythm gains a light swing (pizzicato + tuba), horns hum
    for i, sym in enumerate(H2):
        bar = 12 + i
        for off, beats, ch in s.parts(sym):
            b = p(s.voicing(ch)[0])
            s.note('tuba', bar * 4 + off, .9, b, 58)
            if beats >= 2:
                s.note('tuba', bar * 4 + off + 2, .9, b + 7 if b + 7 < p('C3') else b - 5, 50)
        s.pizz(bar, sym.split()[0], 46, pattern=[(1, 2), (1.5, 1), (3, 2), (3.5, 3)])
        s.pad('pad', bar, sym.split()[0], 50)
        s.drum(bar, [(1, 'snare', -30), (3, 'snare', -26)], 70)
    s.mel('vln', 12, split_beats(THEME, 32, 64), 86, transpose=12)
    s.line('hn', 12, m('D4:4 | C4:4 | Bb3:4 | A3:4 | C4:4 | Bb3:4 | Bb3:2 A3:2 | D4:4'), 56)
    s.swell('vln', 12, 8, 80, 104, 'arch')
    s.timp_roll(19 * 4 + 2, 2, 'F2', 30, 70)

    # 20-23: the Crossroads motif augmented and RESOLVED (horns + strings 8va), then the held Bb major chord
    for i, sym in enumerate(['Ebmaj7', 'F7sus4', 'Bb', 'Bb']):
        s.pad('pad', 20 + i, sym, 58)
        if i < 3:
            s.harp(20 + i, sym, 50)
        s.note('cb', (20 + i) * 4, 4.02, p(s.voicing(sym)[0]), 60)
    res = motif('Bb3', 'major', resolved=True, rhythm=[2, 1, 1, 3, 1, 8])
    s.motif('hn', 20, res, 92, form='RESOLVED, augmented (horns, strings 8va): strength shared willingly')
    s.line('vln', 20, res, 80, transpose=12)
    # the motif lands on Bb at bar 22: the held Bb major chord (trombones, tuba, a soft timpani and cymbal) rings out from there
    for n in voice('Bb', 'F3', 4):
        s.note('tbn', 22 * 4, 8.0, n, 66)
    s.note('tuba', 22 * 4, 8.0, p('Bb1'), 66)
    s.note('timp', 22 * 4, 1.0, p('Bb2'), 70)
    s.hit('crash', 22 * 4, 54, dur=4)
    s.swell('pad', 22, 2, 90, 110)
    return s
