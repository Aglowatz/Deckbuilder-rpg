"""MUS-TUT-BOSS - Hollow Warden, familiar scent. 72 bars 4/4, 136 BPM, B minor (Phrygian colour: C natural).
Its own idea: the Warden's stone theme, heavy steps in the trombones and horns (B A F# | G F# | B C A | F#) over stone drums (concert
bass drum and taiko) and a low pedal. Dignified strings answer a small royal motif (the Crossroads head in the celesta). In the quiet
middle the celesta lets slip the lullaby's first notes - the Warden catches the familiar scent - and the strings answer with the motif
augmented. A build where the motif in the trumpets fights the stone theme, a tutti climax, then the stone theme turns to D major and
approves, before the challenge resumes. Challenge and recognition, not a villain.
"""
from lib import Score, m, motif, motif_head, augment, p

W = m('B3:2 A3:1 F#3:1 | G3:3 F#3:1 | B3:2 C4:1 A3:1 | F#3:4')
W2 = m('B3:2 A3:1 F#3:1 | G3:3 A3:1 | B3:2 D4:1 C#4:1 | B3:4')
W_H = ['Bm', 'G', 'Bm C', 'F#m', 'Bm', 'G', 'Bm A', 'Bm']
WD = m('D4:2 C#4:1 A3:1 | B3:3 A3:1 | D4:2 E4:1 C#4:1 | A3:4 | D4:2 C#4:1 A3:1 | B3:3 A3:1 | G3:2 A3:1 B3:1 | A#3:4')
WD_H = ['D', 'G', 'D A', 'A', 'D', 'Bm', 'G A', 'F#']
ANSWER_H = ['Bm', 'G', 'D', 'A', 'Bm', 'G', 'Em', 'F#']
ROYAL_H = ['Bm', 'Gmaj7', 'D', 'A', 'Bm', 'Gmaj7', 'Em', 'F#sus4 F#']
CL = m('B4:1 F#5:.5 E5:.5 D5:1.5 C#5:.5 | F#5:3 r:.5 F#5:.5 | G5:1.5 F#5:.5 E5:1 D5:1 | C#5:2 A#4:2 '
       '| B4:1 F#5:.5 E5:.5 D5:1.5 E5:.5 | F#5:2 A5:2 | G5:1 F#5:1 E5:1 C#5:1 | F#5:4')
CL_H = ['Bm', 'Gmaj7', 'Em', 'F#', 'Bm', 'D', 'Em A', 'F#']
OST = [(0, 0, .45, 10), (.5, 0, .45, -6), (1, 1, .45, 0), (1.5, 0, .45, 6), (2, 2, .45, -4), (2.5, 0, .45, -6), (3, 1, .45, 8), (3.5, 3, .45, -2)]
STONE = [(0, 'bd', 12), (1.5, 'bd', -16), (2.5, 'bd', -8), (3, 'bd', 0)]


def build():
    s = Score('MUS-TUT-BOSS', bpm=136, bars=72, key='B minor', seed=505)
    s.seat('spic', 'vln', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'timp', 'harp', 'cel', 'choir', 'perc')
    s.channel('taiko', 'taiko', pan=58, reverb=90, vol=96)
    for bar, nm in ((0, 'stone drums'), (4, 'A stone theme'), (12, 'B royal answer'), (20, "A' stone theme"), (28, 'C familiar scent'),
                    (36, 'D challenge'), (44, 'climax'), (52, 'E approval'), (60, "A'' stone theme"), (68, 'stone drums')):
        s.section(bar, nm)

    def stone(bar, vel, full=True):
        s.drum(bar, STONE if full else STONE[:1], vel)
        for beat, acc in ((0, 8), (2.5, -6), (3, 0), (3.5, -12)) if full else ((0, 0),):
            s.note('taiko', bar * 4 + beat, .5, p('D3'), vel + acc)

    def pedal(bar, spec, vel, stabs=True):
        b = p(s.voicing(spec.split()[0])[0])
        if b > p('D2'):
            b -= 12
        if stabs:
            for beat in (0, 1.5, 3):
                s.note('cb', bar * 4 + beat, .6, b, vel + (8 if beat == 0 else 0))
                s.note('tuba', bar * 4 + beat, .6, b, vel - 10)
            s.note('vc', bar * 4, 3.9, b + 12, vel - 6)
        else:
            s.bass_at(bar * 4, 4, spec.split()[0], vel)

    def ost(bar, spec, vel):
        for off, beats, sym in s.parts(spec):
            s.figure('spic', bar, sym, [x for x in OST if off <= x[0] < off + beats], vel, low='B3')

    def timp(bar, spec, vel):
        r = p(s.voicing(spec.split()[0])[0])
        tp = r + 12 if r + 12 <= p('A2') else r
        s.timp_hit(bar * 4, tp, vel)

    def stone_section(bar, vel, mel=W, mel2=W2):
        for i, spec in enumerate(W_H):
            stone(bar + i, vel - 6)
            pedal(bar + i, spec, vel - 4)
            ost(bar + i, spec, vel - 2)
            timp(bar + i, spec, vel)
            s.pad('pad', bar + i, spec.split()[0], vel - 18)
        s.mel('tbn', bar, mel + mel2, vel + 14)
        s.line('hn', bar, mel + mel2, vel + 4, transpose=12)

    def drums_only(bar):
        for i, spec in enumerate(['Bm', 'Bm', 'G', 'F#m']):
            stone(bar + i, 78)
            pedal(bar + i, spec, 70)
            s.pad('pad', bar + i, spec, 50)
        s.line('hn', bar, m('B3:8 | B3:4 A#3:4'), 66, legato=1.0, shape=False)

    # STONE DRUMS 0-3
    drums_only(0)
    s.timp_roll(3 * 4 + 2, 2, 'F#2', 40, 90)

    # A 4-11: the Warden's stone theme
    stone_section(4, 72)
    s.hit('crash', 4 * 4, 70, dur=3)
    s.notes.append('Villain idea: the stone theme W (trombones + horns), Phrygian C natural; never the Crossroads shape.')

    # B 12-19: a small royal motif in the celesta/harp, dignified strings answer
    for i, spec in enumerate(ANSWER_H):
        bar = 12 + i
        stone(bar, 60, full=False)
        pedal(bar, spec, 62, stabs=False)
        ost(bar, spec, 60)
        s.brass('hn', bar, spec, 54, low='D4')
    for k, bar in enumerate((12, 14, 16)):
        head = motif_head('B5' if k != 1 else 'A5', 'minor' if k != 1 else 'major', rhythm=(1, .5, 2.5))
        s.motif('cel', bar, head, 74, form='head, small (celesta + harp)')
        s.line('harp', bar, head, 64, transpose=-12)
    s.mel('vln', 13, m('D5:1.5 C#5:.5 B4:1 D5:1'), 88)
    s.mel('vln', 15, m('C#5:1.5 B4:.5 A4:1 C#5:1'), 88)
    s.mel('vln', 17, m('D5:1 E5:.5 F#5:.5 G5:2 | G5:1 F#5:.5 E5:.5 B4:2 | C#5:2 A#4:2'), 92)
    s.line('vln', 13, m('D4:4'), 66)
    s.swell('vln', 12, 8, 84, 112)
    s.timp_roll(19 * 4, 4, 'F#2', 40, 96)

    # A' 20-27: the stone theme again, heavier
    stone_section(20, 80)
    s.hit('crash', 20 * 4, 80, dur=3)

    # C 28-35: familiar scent - quiet; the celesta lets slip the lullaby's first notes, the strings answer with the motif augmented
    for i, spec in enumerate(ROYAL_H):
        bar = 28 + i
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, 60, beats=beats, beat=off)
            s.bass_at(bar * 4 + off, beats, sym, 62)
            s.harp(bar, sym, 60, beats=beats, beat=off)
        s.note('taiko', bar * 4, .5, p('D3'), 60 if i % 2 == 0 else 48)
    s.line('cel', 29, m('B5:1 F#6:1 D6:2'), 62)
    s.motifs.append((29, 'lullaby head (B F# D) - recognition, story theme', 'cel'))
    s.motif('vln', 31, augment(motif('B4'), 2)[:5] + m('r:1'), 84, form='augmented (strings), dignified answer')
    s.line('vln', 31, augment(motif('B4'), 2)[:5] + m('r:1'), 66, transpose=-12)
    s.line('hn', 32, m('D4:4 | F#4:4 | G4:4 | F#4:2 A#3:2'), 60, legato=1.0)
    s.swell('vln', 31, 5, 76, 106, 'arch')
    s.timp_roll(35 * 4, 4, 'F#2', 30, 100)
    s.snare_roll(35 * 4 + 2, 2, 30, 80)

    # D 36-43: challenge - the motif in the trumpets fights the stone theme in the trombones
    for i, spec in enumerate(W_H):
        bar = 36 + i
        stone(bar, 76)
        pedal(bar, spec, 72)
        ost(bar, spec, 74)
        timp(bar, spec, 82)
    s.line('tbn', 36, W + W2, 84)
    s.motif('tpt', 36, motif('B4'), 92, form='stated (trumpets) against the stone theme')
    s.mel('tpt', 37, m('r:3 B4:1 | B4:1 F#5:.5 E5:.5 E5:1 D5:1 | C#5:4'), 92)
    s.motif('tpt', 40, motif('B4'), 96, form='stated (trumpets), again')
    s.mel('tpt', 41, m('r:3 B4:1 | D5:1 E5:.5 F#5:.5 G5:1 A5:1 | B5:4'), 96)
    s.line('hn', 36, motif('B4') + m('r:1 | B4:1 F#5:.5 E5:.5 E5:1 D5:1 | C#5:4') + motif('B4') + m('r:1 | D5:1 E5:.5 F#5:.5 G5:1 A5:1 | B5:4'), 78, transpose=-12)
    s.swell('pad', 36, 8, 80, 112)
    s.timp_roll(43 * 4, 4, 'B1', 50, 110)
    s.snare_roll(43 * 4, 4, 40, 96)

    # CLIMAX 44-51: tutti - the motif tune on top, the stone theme augmented beneath, choir, cymbals
    for i, spec in enumerate(CL_H):
        bar = 44 + i
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, 76, beats=beats, beat=off)
            s.pad('choir', bar, sym, 64, beats=beats, beat=off, octave=1)
            s.figure('spic', bar, sym, [x for x in OST if off <= x[0] < off + beats], 82, low='B3')
        pedal(bar, spec, 82)
        stone(bar, 84)
        timp(bar, spec, 100 if i % 4 == 0 else 84)
    s.motif('tpt', 44, CL, 98, form='stated (climax tune: trumpets, horns, violins 8va)')
    s.line('hn', 44, CL, 94, transpose=-12)
    s.line('vln', 44, CL, 104, transpose=12)
    s.line('vln', 44, CL, 92)
    s.line('tbn', 44, augment(W, 2), 86)
    s.swell('vln', 44, 8, 112, 126, 'arch')
    s.swell('choir', 44, 8, 70, 116, 'arch')
    s.hit('crash', 44 * 4, 100, dur=4)
    s.hit('crash2', 48 * 4, 90, dur=4)
    s.timp_roll(51 * 4 + 2, 2, 'F#2', 80, 60)

    # E 52-59: approval - the stone theme in D major, a chorale; the strings hold the motif's last notes above
    for i, spec in enumerate(WD_H):
        bar = 52 + i
        for off, beats, sym in s.parts(spec):
            s.pad('pad', bar, sym, 64, beats=beats, beat=off)
            s.bass_at(bar * 4 + off, beats, sym, 70)
            s.brass('hn', bar, sym, 62, beats=beats, beat=off, low='F#3')
            s.harp(bar, sym, 52, beats=beats, beat=off)
        s.note('taiko', bar * 4, .5, p('D3'), 56)
    s.mel('tbn', 52, WD, 92)
    s.line('vln', 52, m('F#5:8 | F#5:4 E5:4 | F#5:8 | D5:4 C#5:4'), 80, legato=1.0)
    s.motif('vln', 52, m('r:8 | r:8 | A5:4 G5:4 | E5:4 A#5:4'), 80, form='tail held above (strings)', lead=False)
    s.swell('vln', 52, 8, 86, 110, 'arch')
    s.timp_roll(59 * 4, 4, 'F#2', 40, 96)

    # A'' 60-67: the challenge resumes
    stone_section(60, 76)
    s.hit('crash', 60 * 4, 74, dur=3)

    # STONE DRUMS 68-71: as bar 0, so the loop lands
    drums_only(68)
    s.timp_roll(71 * 4 + 2, 2, 'F#2', 40, 90)
    return s
