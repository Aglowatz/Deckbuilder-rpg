"""MUS-TOWN-FREED - Crosspath, returning citizens. 48 bars 4/4, 92 BPM, D major (the v04 town theme out of Dorian into the light).
The town tune reharmonised warmer, its Crossroads head now RESOLVED (D A G F# E D: the question answered). Each Path adds its voice in
turn as interlocking countermelodies: Refusemancer fiddle and tin-whistle (recorder) in A, Gourmand accordion and mandolin in A',
Necrocrat celesta and harpsichord in the B tune, Beefcake warm horns/trombone chorale and a soft snare in B', then all four together
under the tune. Warm, with space and a little mystery (the intro's G major 7), not a fanfare.
"""
from lib import Score, m, motif, augment, p

MEL_A = m('D4:1 A4:.5 G4:.5 F#4:1.5 E4:.5 | D4:3 r:1 | F#4:1 G4:.5 A4:.5 C#5:1 B4:.5 A4:.5 | G4:2 E4:1 A4:1 '
          '| D5:1 C#5:.5 B4:.5 A4:1.5 G4:.5 | A4:2 C#5:1 F#5:1 | E5:1 D5:.5 C#5:.5 B4:1 D5:1 | E5:1 C#5:1 A4:2')
MEL_A_END = m('D4:1 A4:.5 G4:.5 F#4:1.5 E4:.5 | D4:3 r:1 | F#4:1 G4:.5 A4:.5 C#5:1 B4:.5 A4:.5 | G4:2 E4:1 A4:1 '
              '| D5:1 C#5:.5 B4:.5 A4:1.5 G4:.5 | A4:2 C#5:1 F#5:1 | E5:1 D5:.5 C#5:.5 B4:1 G4:1 | A4:1 E4:1 D4:2')
MEL_B = m('F#4:1 B4:1 D5:2 | C#5:1 A4:1 F#4:2 | G4:1 B4:1 D5:1 C#5:1 | C#5:1.5 D5:.5 E5:2 '
          '| D5:1 F#5:1 E5:1 D5:1 | C#5:1 A4:.5 C#5:.5 F#5:2 | D5:1 C#5:1 B4:1 G4:1 | A4:2 C#5:1 E5:1')
PROG_A = ['D', 'G', 'D/F#', 'A7sus4', 'G', 'D/F#', 'Em7', 'A']
PROG_A_END = ['D', 'G', 'D/F#', 'A7sus4', 'G', 'D/F#', 'Em7', 'A D']
PROG_B = ['Bm', 'F#m', 'G', 'A', 'Bm', 'F#m', 'G', 'A']
INTRO = ['D', 'Bm7', 'Gmaj7', 'A7sus4']


def build():
    s = Score('MUS-TOWN-FREED', bpm=92, bars=48, key='D major', seed=909)
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'tbn', 'cl', 'timp', 'cel', 'perc')
    s.channel('fiddle', 'fiddle', pan=30, reverb=80, vol=80)
    s.channel('whistle', 'recorder', pan=96, reverb=85, vol=78)
    s.channel('acc', 'accordion_it', pan=84, reverb=75, vol=70)
    s.channel('mand', 'mandolin', pan=40, reverb=80, vol=74)
    s.channel('hpsi', 'harpsichord', pan=88, reverb=85, vol=64)
    for bar, nm in ((0, 'intro'), (4, 'A + Refusemancer'), (12, "A' + Gourmand"), (20, 'B + Necrocrat'), (28, "B' + Beefcake"),
                    (36, 'all four'), (44, 'outro')):
        s.section(bar, nm)

    def bed(bar, spec, pad_v, harp_v=None, bass_v=60, pat='whole', dens=8):
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, pad_v, beats=beats, beat=off)
            if harp_v:
                s.harp(bar, sym, harp_v, density=dens, beats=beats, beat=off)
            if pat == 'whole' or beats < 4:
                s.bass_at(bar * 4 + off, beats, sym, bass_v)
            else:
                s.bass(bar, sym, bass_v, pat)

    def intro(bar, outro=False):
        for i, spec in enumerate(INTRO):
            bed(bar + i, spec, 54, harp_v=54, bass_v=52)
        s.expr('pad', bar, 84)
        if outro:
            s.motif('hn', bar, augment(motif('D4', 'major', resolved=True), 1.0)[:5] + m('D4:4 | r:4'), 66,
                    form='RESOLVED (horn), farewell')
        else:
            s.motif('hn', bar + 1, m('D4:2 A4:1 G4:1 | F#4:4 | E4:4'), 64, form='head, slow (horn)')
        s.line('cl', bar + 2, m('B4:2 A4:2 | G4:2 E4:2'), 46)

    # INTRO 0-3
    intro(0)
    s.timp_roll(3 * 4 + 2, 2, 'A1', 34, 70)

    # A 4-11: horn on the tune (resolved head); Refusemancer fiddle fills the gaps, the tin whistle answers
    for i, spec in enumerate(PROG_A):
        bed(4 + i, spec, 56, harp_v=50, bass_v=64)
    s.motif('hn', 4, MEL_A[:6], 86, form='RESOLVED (horn; tune head)')
    s.mel('hn', 4, MEL_A[7:], 86, beat=8)
    s.line('fiddle', 5, m('r:1 A5:.5 B5:.5 A5:1 F#5:1'), 70)
    s.line('fiddle', 7, m('r:2 C#6:.5 B5:.5 A5:1'), 70)
    s.line('whistle', 8, m('r:2.5 F#5:.25 G5:.25 A5:1'), 64)
    s.line('fiddle', 9, m('r:2 E6:.5 D6:.5 C#6:1'), 72)
    s.line('whistle', 10, m('r:3 B5:.5 C#6:.5'), 62)
    s.line('fiddle', 11, m('r:2 A5:.5 B5:.5 C#6:1'), 70)
    s.timp_hit(4 * 4, 'D2', 60)
    s.swell('pad', 4, 8, 76, 100, 'arch')

    # A' 12-19: strings on the tune; Gourmand accordion on the off-beats, mandolin tremolo counter, clarinet
    for i, spec in enumerate(PROG_A):
        bar = 12 + i
        bed(bar, spec, 58, bass_v=70, pat='half')
        for beat in (1, 3):
            s.brass('acc', bar, spec, 50, beats=.5, low='F#3', beat=beat)
    s.motif('vln', 12, MEL_A, 90, form='RESOLVED (violins 8va)', transpose=12)
    s.line('vln', 12, MEL_A, 72)
    mand = [('F#5', 4), ('D5', 4), ('D5', 4), ('C#5', 4), ('B4', 4), ('A4', 4), ('B4', 2), ('G4', 2), ('C#5', 4)]
    t = 12 * 4
    for n, d in mand:
        for k in range(int(d * 4)):
            s.note('mand', t + k * .25, .2, p(n), 50 + (8 if k % 4 == 0 else 0))
        t += d
    s.line('cl', 15, m('r:2 E5:.5 D5:.5 C#5:1'), 58)
    s.line('cl', 19, m('r:2 A4:.5 B4:.5 C#5:1'), 58)
    s.swell('vln', 12, 8, 86, 112, 'arch')
    s.timp_hit(12 * 4, 'D2', 66)

    # B 20-27: the B tune in the clarinet; Necrocrat celesta waltzes above it, harpsichord arpeggios, cellos underneath
    for i, spec in enumerate(PROG_B):
        bar = 20 + i
        bed(bar, spec, 48, bass_v=56)
        s.figure('hpsi', bar, spec, [(k * .5, (0, 1, 2, 1, 3, 1, 2, 1)[k], .45, -4 if k % 2 else 4) for k in range(8)], 54, low='F#3')
        up = s.chord_tones(spec, p('B5'), 3)
        for k, tn in enumerate(up):
            s.note('cel', bar * 4 + 2 + k * (2 / 3), .6, tn, 52 - 4 * k)
    s.mel('cl', 20, MEL_B, 84)
    s.line('vc', 20, m('D4:4 | C#4:4 | B3:4 | C#4:4 | D4:4 | C#4:4 | B3:4 | A3:2 C#4:2'), 56, legato=1.0, shape=False)
    s.motif('cel', 27, m('A5:.5 E6:.5 D6:1 C#6:.5 B5:.5 A5:1'), 56, form='head + tail glint (celesta)', lead=False)
    s.swell('pad', 20, 8, 70, 92, 'arch')

    # B' 28-35: strings on the B tune; Beefcake warm horns and trombone chorale, a soft snare march
    for i, spec in enumerate(PROG_B):
        bar = 28 + i
        bed(bar, spec, 56, harp_v=46, bass_v=68, pat='half')
        s.brass('hn', bar, spec, 60, low='D4')
        s.brass('tbn', bar, spec, 54, low='F#3', n=2)
        s.drum(bar, [(0, 'snare', 0), (1, 'snare', -12), (1.5, 'snare', -18), (2, 'snare', -4), (3, 'snare', -12), (3.5, 'snare', -16)], 44)
    s.mel('vln', 28, MEL_B, 92, transpose=12)
    s.line('vln', 28, MEL_B, 74)
    s.swell('hn', 28, 8, 70, 112)
    s.swell('vln', 28, 8, 84, 118)
    s.timp_roll(35 * 4, 4, 'A1', 40, 92)

    # ALL FOUR 36-43: the tune in strings and horns; fiddle descant, accordion, celesta, mandolin, snare - the voices in harmony
    for i, spec in enumerate(PROG_A_END):
        bar = 36 + i
        bed(bar, spec, 70, harp_v=50, bass_v=80, pat='half', dens=16)
        for beat in (1, 3):
            s.brass('acc', bar, spec.split()[0], 48, beats=.5, low='F#3', beat=beat)
        s.drum(bar, [(0, 'bd', 0), (2, 'snare', -10), (3.5, 'snare', -18)], 50)
        s.note('cel', bar * 4 + 3, .5, s.chord_tones(spec.split()[0], p('D6'), 2)[i % 2], 46)
        r = p(s.voicing(spec.split()[0])[0])
        s.timp_hit(bar * 4, r + 12 if r + 12 <= p('A2') else r, 80 if i % 4 == 0 else 64)
    s.motif('vln', 36, MEL_A_END, 98, form='RESOLVED (tutti; the tune ends on D)', transpose=12)
    s.line('hn', 36, MEL_A_END, 90)
    s.line('vln', 36, MEL_A_END, 82)
    s.line('fiddle', 36, m('F#5:4 | B5:4 | A5:4 | G5:2 E5:2 | B5:4 | A5:4 | G5:4 | E5:2 F#5:2'), 66, legato=1.0)
    s.line('whistle', 40, m('r:2 A5:.5 B5:.5 C#6:1 | D6:4 | r:2 G5:.5 A5:.5 B5:1 | A5:4'), 62)
    t = 36 * 4
    for n, d in [('A4', 4), ('B4', 4), ('A4', 4), ('A4', 4)]:
        for k in range(int(d * 4)):
            s.note('mand', t + k * .25, .2, p(n), 46 + (8 if k % 4 == 0 else 0))
        t += d
    s.swell('vln', 36, 8, 104, 122, 'arch')
    s.hit('crash', 36 * 4, 70, dur=4)
    s.swell('pad', 42, 2, 104, 84)

    # OUTRO 44-47: the horn says the motif resolved, over the intro bed, so bar 0 follows
    intro(44, outro=True)
    s.swell('pad', 47, 1, 84, 100)
    s.expr('pad', 0, 84)
    return s
