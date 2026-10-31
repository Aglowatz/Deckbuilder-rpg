"""MUS-NECRO-RELEASE - Agnes: help people. One-shot story cue, 28 bars 3/4, 72 BPM, Eb major (~70 s + ring-out).
The D.N.A. theme in Eb major, slow and sincere: the clarinet asks its first half over organ and harp, the strings answer with the second
half (it arrives on time now), then the horn and organ sing the Crossroads motif RESOLVED, augmented, and the music settles on a long-held
Eb chord that leaves room for the last line of dialogue. No clock: nobody is counting any more.
"""
from lib import Score, m, motif, motif_tail, augment, p
from lib.zones import DNA_THEME, to_mode, theme_in

THEME = theme_in(to_mode(DNA_THEME, {3: 1, 8: 1, 10: 1, 1: 1}), 3 - 12)       # C minor -> Eb major, down an octave
PROG = ['Eb', 'Eb', 'Ab', 'Ab', 'Bb7', 'Bb7', 'Eb', 'Cm', 'Ab', 'Fm', 'Eb/Bb', 'Bb7', 'Eb', 'Cm', 'Bb7', 'Eb']


def build():
    s = Score('MUS-NECRO-RELEASE', bpm=72, bars=28, meter=(3, 4), key='Eb major', seed=311, kind='oneshot')
    s.lufs = -20.0
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'cl', 'cel', 'timp')
    s.channel('organ', 'organ', pan=64, reverb=105, vol=74)
    for bar, nm in ((0, 'organ and harp'), (4, 'clarinet asks'), (12, 'strings answer'), (20, 'resolved motif'), (24, 'held ending')):
        s.section(bar, nm)
    s.notes.append('Release cue: the D.N.A. theme in Eb major and the Crossroads motif resolved (Eb Bb Ab G F -> Eb).')

    def bed(bar, sym, vel, harp=True):
        s.pad('organ', bar, sym, vel, beats=3, low='Eb3')
        s.note('cb', bar * 3, 2.9, p(s.voicing(sym)[0]), vel)
        if harp:
            s.harp(bar, sym, vel - 2, beats=3)

    for i, sym in enumerate(['Eb', 'Ab', 'Eb/Bb', 'Bb7']):
        bed(i, sym, 56)
    s.note('harp', 0, 2, p('Eb5'), 64, human=False)       # sound at once
    s.motif('cel', 1, motif_tail('Eb5', 'major', rhythm=(1, .5, 1.5), resolved=True), 48, form='tail resolved (celesta)', lead=False)

    for i in range(8):
        bed(4 + i, PROG[i], 48)
    s.mel('cl', 4, THEME[:20], 80, transpose=12)
    s.line('vc', 8, THEME[10:20], 58)

    for i in range(8):
        bar, sym = 12 + i, PROG[8 + i]
        bed(bar, sym, 52, harp=(i % 2 == 0))
        s.pad('pad', bar, sym, 48, low='G3')
    s.mel('vln', 12, THEME[20:], 88, transpose=12)
    s.swell('vln', 12, 8, 88, 104, 'arch')

    for i, sym in enumerate(['Eb', 'Ab', 'Eb/Bb', 'Bb7']):
        bed(20 + i, sym, 54)
        s.pad('pad', 20 + i, sym, 50, low='G3')
    s.motif('hn', 20, augment(motif('Eb4', 'major', resolved=True), 4 / 3.5), 84, form='RESOLVED, augmented (horn + organ)')
    s.line('organ', 20, augment(motif('Eb4', 'major', resolved=True), 4 / 3.5), 60)
    s.timp_roll(23 * 3 + 1, 2, 'Bb1', 30, 60)

    # the held ending: Eb for four bars, harp spread once, strings and organ fading
    for k, n in enumerate(['Eb2', 'Bb2', 'G3', 'Eb4', 'Bb4', 'G5']):
        s.note('harp', 24 * 3 + k * .25, 6, p(n), 60)
    s.note('cb', 24 * 3, 11.5, p('Eb2'), 56)
    s.pad('organ', 24, 'Eb', 54, beats=11.5, low='Eb3')
    s.pad('pad', 24, 'Eb', 52, beats=11.5, low='G3')
    s.note('vln', 24 * 3, 11.5, p('G5'), 70)
    s.timp_hit(24 * 3, 'Eb2', 54)
    s.swell('pad', 24, 4, 100, 50)
    s.swell('organ', 24, 4, 100, 56)
    s.swell('vln', 24, 4, 100, 50)
    return s
