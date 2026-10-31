"""MUS-TITLE - The Wayward Path. 48 bars 4/4, 76 BPM, D minor (B section in F major colours).
The grand statement of the Crossroads motif: an RPG overture, not a town tune. A lone horn begins the royal phrase and stops (incomplete),
the orchestra opens into the full theme, an adventurous B section with a string ostinato and horn calls, a gentle oboe middle where the
celesta remembers the lullaby's first notes and is interrupted, a tutti climax with the motif augmented in the trombones, and the lone horn again.
"""
from lib import Score, m, motif, motif_head, augment, Scale, p

TUNE = m('D4:1 A4:.5 G4:.5 F4:1.5 E4:.5 | A4:3 C5:.5 D5:.5 | E5:1.5 D5:.5 C5:1 A4:1 | Bb4:1 A4:.5 G4:.5 A4:2 '
         '| F4:1 C5:.5 Bb4:.5 A4:1.5 G4:.5 | C5:3 r:.5 C5:.5 | D5:1 E5:.5 F5:.5 G5:1.5 F5:.5 | E5:2 C#5:1 A4:1')
TUNE_H = ['Dm', 'Bbmaj7', 'C', 'Gm A', 'F', 'Am7', 'Gm7', 'A']
CALLS = m('F4:1 C5:.5 Bb4:.5 C5:2 | G4:1 D5:.5 C5:.5 E5:2 | A4:1 E5:.5 D5:.5 F5:1.5 E5:.5 | D5:3 r:1 '
          '| Eb5:1 Bb4:.5 C5:.5 G5:2 | F5:1 D5:.5 Bb4:.5 D5:2 | Bb4:1 D5:1 G5:1 F5:1 | E5:2 C#5:1 A4:1')
CALLS_H = ['F', 'C', 'Dm', 'Bb', 'Eb', 'Bb', 'Gm', 'A']
OBOE = m('D5:1.5 C5:.5 Bb4:1 A4:1 | C5:3 F4:1 | Bb4:1.5 A4:.5 G4:1 F4:1 | E4:2 G4:1 C5:1 '
         '| D5:1.5 Eb5:.5 D5:1 Bb4:1 | C5:2 A4:2 | Bb4:1 G4:1 F4:1 D4:1 | E4:1 r:3')
OBOE_H = ['Bbmaj7', 'F/A', 'Gm7', 'C', 'Bbmaj7', 'F/A', 'Gm7', 'A7sus4']
INTRO_H = ['Dm', 'Bbmaj7', 'Gm', 'A7sus4 A']
HORN_COUNTER = m('A3:4 | F3:2 G3:2 | G3:4 | E3:2 C#4:2 | C4:4 | E4:4 | D4:2 Bb3:2 | A3:2 C#4:2')


def build():
    s = Score('MUS-TITLE', bpm=76, bars=48, key='D minor', seed=101)
    s.seat('vln', 'pad', 'vc', 'cb', 'harp', 'hn', 'tbn', 'tpt', 'fl', 'ob', 'cl', 'timp', 'choir', 'cel', 'perc')
    for bar, nm in ((0, 'intro'), (4, 'A'), (12, "A' tutti"), (20, 'B adventure'), (28, 'C oboe'), (36, 'climax'), (44, 'outro')):
        s.section(bar, nm)
    dm = Scale('D3', 'minor')

    def bed(bar, spec, pad_v, harp_v=None, bass_v=None, dens=8, pad_ch='pad', bass_pat='whole'):
        for off, beats, sym in s.parts(spec):
            s.pad(pad_ch, bar, sym, pad_v, beats=beats, beat=off)
            if harp_v:
                s.harp(bar, sym, harp_v, density=dens, beats=beats, beat=off)
            if bass_v:
                if bass_pat == 'whole' or beats < s.bar_q:
                    s.bass_at(bar * 4 + off, beats, sym, bass_v)
                else:
                    s.bass(bar, sym, bass_v, bass_pat)

    def lone_horn(bar, outro=False):
        # the royal phrase, begun and left hanging (motif head only), over the intro bed. In the outro the flute echo comes first and
        # the horn last, so the horn sounds on both sides of the loop point.
        for i, spec in enumerate(INTRO_H):
            bed(bar + i, spec, 54, harp_v=50, bass_v=52)
        s.swell('pad', bar, 4, 84, 84)
        h, e = (bar + 2, bar) if outro else (bar, bar + 2)
        s.motif('hn', h, motif_head('D4', rhythm=(2, 1, 5)), 70, form='head, incomplete (lone horn)')
        s.line('fl', e, m('D5:1 A5:2 G5:1'), 46)
        s.line('cl', e, m('F3:2 A3:2 | F3:4') if outro else m('Bb3:2 A3:2 | E4:4'), 50)

    # INTRO 0-3: the lone horn
    lone_horn(0)
    s.timp_roll(3 * 4 + 3, 1, 'A1', 40, 78)
    s.hit('crash2', 3 * 4 + 3, 30, dur=1)

    # A 4-11: the theme, horns and violas-strings in unison, harp moving
    for i, spec in enumerate(TUNE_H):
        bed(4 + i, spec, 58, harp_v=54, bass_v=68)
    s.swell('pad', 4, 4, 76, 98, 'arch')
    s.swell('pad', 8, 4, 76, 104, 'arch')
    s.motif('hn', 4, TUNE[:6], 88, form='stated (horns)')
    s.mel('hn', 4, TUNE[6:], 88, beat=7)
    s.line('vln', 4, TUNE, 66, transpose=0)
    s.timp_hit(4 * 4, 'D2', 72)
    s.timp_hit(8 * 4, 'F2', 64)
    s.timp_roll(11 * 4 + 2, 2, 'A1', 40, 90)

    # A' 12-19: tutti - strings in octaves and trumpet on the tune, horns counter, choir, timpani
    for i, spec in enumerate(TUNE_H):
        bar = 12 + i
        bed(bar, spec, 66, harp_v=50, bass_v=82, dens=16, bass_pat='half')
        s.pad('choir', bar, spec.split()[0], 54, octave=1)
    s.motif('vln', 12, TUNE, 94, form='stated (tutti strings 8va + trumpet)', transpose=12)
    s.line('vln', 12, TUNE, 78)
    s.line('tpt', 12, TUNE, 72)
    s.line('hn', 12, HORN_COUNTER, 74, legato=1.0, shape=False)
    s.swell('vln', 12, 4, 86, 116, 'arch')
    s.swell('vln', 16, 4, 90, 122, 'arch')
    s.swell('choir', 12, 8, 60, 96, 'arch')
    for bar, pitch, v in ((12, 'D2', 96), (14, 'C2', 70), (16, 'F2', 84), (18, 'G2', 76)):
        s.timp_hit(bar * 4, pitch, v)
    s.hit('crash', 12 * 4, 80, dur=4)
    s.line('tbn', 18, m('G3:2 A3:2 | A3:4'), 66)
    s.timp_roll(19 * 4 + 2, 2, 'A1', 50, 96)

    # B 20-27: adventure - string ostinato, horn calls on the motif head in sequence, snare, flute runs
    for i, spec in enumerate(CALLS_H):
        bar = 20 + i
        s.pad('pad', bar, spec, 52)
        s.bass(bar, spec, 74, 'march')
        tn = s.voicing(spec)[1]
        cell = [(tn[1] + 12, .5, 8), (tn[2] + 12, .5, -6), (tn[3] + 12, .5, 0), (tn[2] + 12, .5, -6)]
        s.ostinato('vln', bar, 1, cell, 66)
        s.drum(bar, [(0, 'snare', 8), (1.5, 'snare', -10), (2, 'snare', 0), (3, 'snare', -6), (3.5, 'snare', -12)], 48)
        s.timp_hit(bar * 4, p(s.voicing(spec)[0]) + (12 if p(s.voicing(spec)[0]) < p('F2') else 0), 70 if i % 2 == 0 else 56)
    s.expr('vln', 20, 96)
    s.motif('hn', 20, CALLS[:4], 92, form='head in sequence (horn calls)')
    s.mel('hn', 20, CALLS[4:], 92, beat=4)
    s.line('tpt', 24, CALLS[16:], 70, transpose=0)
    s.run('fl', 23, 'D5', 'D6', Scale('D4', 'minor'), 60, step=0.25, beat=2, crescendo=16)
    s.run('fl', 27, 'A4', 'E6', Scale('A4', 'harmonic'), 58, step=1 / 6, beat=2, crescendo=18)
    s.swell('pad', 20, 8, 70, 100)
    s.timp_roll(27 * 4 + 2, 2, 'A1', 50, 100)

    # C 28-35: the gentle middle - oboe over harp; the celesta remembers the lullaby's first notes, and is interrupted
    for i, spec in enumerate(OBOE_H):
        bed(28 + i, spec, 46, harp_v=50, bass_v=50)
    s.expr('pad', 28, 80)
    s.mel('ob', 28, OBOE, 84)
    s.line('cl', 28, m('F4:4 | F4:2 E4:2 | D4:4 | C4:2 E4:2 | F4:4 | F4:4 | D4:4 | C#4:4'), 50)
    s.line('fl', 31, m('r:2 G5:1 C6:1'), 40)
    s.line('cel', 35, m('D5:1 A5:1 F5:1'), 50)
    s.motifs.append((35, 'lullaby head (D A F, cut off) - story theme, not the motif', 'cel'))
    s.timp_roll(35 * 4 + 2, 2, 'A1', 46, 108)
    s.run('vln', 35, 'A4', 'D6', Scale('D4', 'harmonic'), 70, step=1 / 6, beat=3, crescendo=30)

    # CLIMAX 36-43: tutti - tune in strings/trumpets/horns, the motif augmented in the trombones underneath
    for i, spec in enumerate(TUNE_H):
        bar = 36 + i
        bed(bar, spec, 78, harp_v=48, bass_v=94, dens=16, bass_pat='half')
        s.pad('choir', bar, spec.split()[0], 66, octave=1)
        root = p(s.voicing(spec.split()[0])[0])
        tp = root + 12 if root + 12 <= p('A2') else root
        s.timp_hit(bar * 4, tp, 100 if i % 4 == 0 else 80)
        s.timp_hit(bar * 4 + 2.5, tp, 60)
    s.motif('tpt', 36, TUNE, 94, form='stated (climax, trumpets + strings 15ma)')
    s.line('hn', 36, TUNE, 96)
    s.line('vln', 36, TUNE, 108, transpose=24)
    s.line('vln', 36, TUNE, 96, transpose=12)
    s.motif('tbn', 36, augment(motif('D3'), 2), 84, form='augmented (trombones, under the tune)', lead=False)
    s.line('tbn', 39, m('r:2 C#3:2 | C3:4 | C3:4 | D3:4 | C#3:4'), 76)
    s.line('fl', 40, TUNE[12:], 80, transpose=12)
    s.swell('vln', 36, 8, 114, 126, 'arch')
    s.swell('choir', 36, 8, 76, 114, 'arch')
    s.hit('crash', 36 * 4, 96, dur=4)
    s.hit('bd', 36 * 4, 84)
    s.hit('crash2', 40 * 4, 78, dur=4)
    s.swell('pad', 42, 2, 110, 84)
    s.swell('vln', 42, 2, 120, 90)

    # OUTRO 44-47: the lone horn again, the same bed and level as bar 0 so the loop lands
    lone_horn(44, outro=True)
    s.expr('vln', 44, 90)
    s.swell('pad', 47, 1, 84, 104)
    s.swell('hn', 47, 1, 100, 118)
    s.timp_roll(47 * 4 + 2, 2, 'A1', 34, 66)
    s.expr('hn', 0, 100)
    return s
