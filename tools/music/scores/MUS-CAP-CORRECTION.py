"""MUS-CAP-CORRECTION - Smiled incorrectly (Correction Ward). Loop, 64 bars 4/4, 120 BPM, A minor, quantised.
A metronome that never stops (orchestra-kit click on every beat), clinical high strings held like fluorescent light, isolated piano notes.
The Capital theme comes in slowed and in minor on a celesta - the anthem as a procedure. Threat and vulnerable silence get equal room: low
tremolo swells and muted-brass statements of the theme, then nothing but the click, the high strings and an oboe trying a human phrase
(the Crossroads motif) that never finishes. No comic accents.
"""
from lib import Score, m, motif_head, augment, p
from lib.capital import QUANTISED
from scores._fork_a import cap, bed

H = ['Am', 'Am', 'Fmaj7', 'E', 'Am', 'Dm', 'Bdim', 'E']


def build():
    s = Score('MUS-CAP-CORRECTION', bpm=120, bars=64, key='A minor', seed=607, human=QUANTISED)
    s.seat('vln', 'pad', 'trem', 'vc', 'cb', 'piano', 'ob', 'cel', 'perc', 'tbn')
    s.channel('mtpt', 'muted_tpt', pan=70, reverb=95, vol=78)
    s.channel('high', 'slow_strings', pan=50, reverb=110, vol=70)
    for bar, nm in ((0, 'metronome'), (4, 'A the anthem as procedure'), (20, 'B threat'), (32, 'C the unfinished phrase'),
                    (44, 'D threat returns'), (60, 'metronome')):
        s.section(bar, nm)
    s.notes.append('Capital theme in A harmonic minor, augmented on celesta; metronome click on every beat; quantised; no comedy.')

    def click(bar, vel=52):
        for k in range(4):
            s.hit('click', bar * 4 + k, vel + (8 if k == 0 else 0), dur=.1)

    def light(bar, bars, vel, notes=('A5', 'E6')):
        for n in notes:
            s.note('high', bar * 4, bars * 4 - .02, p(n), vel)

    def intro(bar):
        for i in range(4):
            click(bar + i)
        light(bar, 4, 66)
        s.note('cb', bar * 4, 15.98, p('A1'), 50)
        for i, sym in enumerate(['Am', 'Am', 'Fmaj7', 'E']):
            bed(s, bar + i, sym, 44, ch='pad', low='A3', n=3)
        s.mel('piano', bar, m('E6:4 | r:4 | C6:4 | B5:4'), 56)

    intro(0)

    for i in range(16):
        sym = H[i % 8]
        click(4 + i)
        if i % 4 == 0:
            light(4 + i, 4, 50)
        bed(s, 4 + i, sym, 36, ch='pad', low='A3', n=3, bass=('cb', None), bvel=42)
        if i % 4 == 2:
            s.note('piano', (4 + i) * 4 + 2, 2, p(s.voicing(sym)[1][-1]) + 24, 50)
    s.mel('cel', 4, augment(cap(0, 4, -3, minor=True), 2) + augment(cap(4, 8, -3, minor=True), 2), 78)

    # B 20-31: threat - tremolo swells from the low strings, the theme head in muted trumpets and trombone
    for i in range(12):
        sym = ['Am', 'F', 'Dm', 'E'][i % 4]
        click(20 + i, 56)
        bed(s, 20 + i, sym, 62, ch='trem', low='A2', n=4, bass=('cb', 'vc'), bvel=64)
        light(20 + i, 1, 44, notes=('A5', 'Bb5') if i % 4 == 3 else ('A5', 'E6'))
    s.swell('trem', 20, 4, 50, 118, back='arch')
    s.swell('trem', 24, 4, 50, 118, back='arch')
    s.swell('trem', 28, 4, 60, 124)
    s.mel('mtpt', 20, cap(0, 4, -3, minor=True) + cap(0, 4, -3, minor=True), 92)
    s.line('tbn', 24, cap(0, 4, -15, minor=True), 76)

    # C 32-43: the vulnerable silence - click, high strings, the oboe's unfinished phrase (the Crossroads head, stopped short)
    for i in range(12):
        click(32 + i, 46)
    light(32, 12, 46)
    s.note('cb', 32 * 4, 47.98, p('A1'), 36)
    s.motif('ob', 33, motif_head('A4', 'minor', rhythm=(2, 1, 1)) + m('F5:3 r:1'), 72, form='head (oboe, a human phrase - unfinished)')
    s.mel('ob', 36, m('E5:2 D5:1 C5:1 | B4:4 | r:4'), 66)
    s.motif('ob', 39, motif_head('A4', 'minor', rhythm=(2, 1, 1)) + m('r:4'), 62, form='head again (oboe, stops)')
    s.mel('piano', 41, m('C6:4 | B5:4 | E6:4'), 52)

    # D 44-59: threat returns - the theme in minor on low brass + celesta, tremolo, then dissolving back to the click
    for i in range(16):
        sym = H[i % 8]
        click(44 + i, 54)
        if i < 11:
            bed(s, 44 + i, sym, 66, ch='trem', low='A2', n=4, bass=('cb', 'vc'), bvel=66)
        if i % 4 == 0:
            light(44 + i, 4, 48)
    s.mel('tbn', 44, cap(0, 8, -15, minor=True), 90)
    s.line('mtpt', 44, cap(0, 8, -3, minor=True), 70)
    s.mel('cel', 52, augment(cap(12, 14, -3, minor=True), 2), 72)
    s.tag_melody('high', 56, 60)
    s.swell('trem', 44, 8, 70, 120)
    s.swell('trem', 52, 3, 120, 50)

    intro(60)
    s.hit('cym_roll', 63 * 4, 30, dur=4)
    return s
