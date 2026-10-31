"""MUS-OMAKASE-BOSS - The Itamae Supreme. 80 bars 4/4, 132 BPM, G minor. Its own boss track (no longer MUS-OMAKASE-BATTLE's file).
The Itamae's own idea is ITAMAE: a stern, exact phrase that rises a fifth, cuts down in a 16th flourish like a blade and lands on the
flat sixth - mastery without warmth. Under it the KNIFE: repeated 16th strokes on one string note. The Buffet theme returns corrupted -
in G minor on koto and shamisen a half-beat apart, never quite together - against the Crossroads motif inverted in the horns. A quiet
tea-ceremony middle (shakuhachi alone with the motif over suspended harmony) is the contrast; then the climax sets the hero's motif in
the horns against the Itamae's theme in the brass. Intro/outro: pad, taiko and knife strokes.
"""
from lib import Song, m, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, to_mode

THEME = to_mode(transpose(BUFFET_THEME, 2), {11: -1, 4: -1, 6: -1})          # the Buffet theme in G minor
ITAMAE = m('G4:1.5 D5:.5 C5:.25 Bb4:.25 A4:.25 G4:.25 F#4:1 | Eb5:3 D5:1 | C5:1.5 G5:.5 F5:.25 Eb5:.25 D5:.25 C5:.25 Bb4:1 '
           '| A4:2 F#4:1 r:1')
ITAMAE_H = ['Gm', 'Ebmaj7', 'Cm', 'D7']
SUSP = ['Gsus4', 'Gm', 'Ebmaj7', 'Dsus4', 'Cm9', 'Absus2', 'D7sus4', 'D7']
CLIMAX = ['Gm', 'Eb', 'Cm', 'D7', 'Gm', 'Ab', 'Fm', 'D7']


def build():
    s = Song('MUS-OMAKASE-BOSS', bpm=132, bars=80, key='G minor', seed=409, jitter=0.005)
    s.channel('koto', 107, 46, 85, 90)
    s.channel('sham', 106, 60, 80, 82)
    s.channel('shaku', 77, 58, 100, 98)
    s.channel('vln', 'strings', 36, 95, 96)
    s.channel('spic', 'strings', 30, 85, 80)
    s.channel('pad', 'slow_strings', 64, 100, 76)
    s.channel('brass', 'brass', 70, 90, 98)
    s.channel('hn', 'horn', 78, 95, 92)
    s.channel('tbn', 'trombone', 88, 95, 84)
    s.channel('cb', 'contrabass', 92, 90, 90)
    s.channel('taiko', 116, 64, 75, 98)
    s.channel('timp', 'timpani', 64, 80, 92)
    s.channel('kit', 'standard_kit', 64, 60, 86)
    for bar, nm in ((0, 'intro knife'), (4, 'A Itamae'), (20, 'B corrupted course'), (36, 'C tea ceremony'), (48, 'build'),
                    (52, 'D climax'), (72, 'wind-down'), (76, 'outro knife')):
        s.section(bar, nm)
    s.notes.append('Villain idea = ITAMAE (rise, blade-like 16th cut, flat sixth) + the KNIFE 16th strokes.')

    def knife(bar, sym, vel):
        r = p(s.voicing(sym)[0])
        while r < p('G3'):
            r += 12
        for k in range(16):
            s.note('spic', bar * 4 + k * .25, .18, r, vel + (10 if k % 4 == 0 else -6), human=False)

    def drums(bar, vel, full=True):
        s.note('taiko', bar * 4, .6, 'C3', vel + 6)
        s.note('taiko', bar * 4 + 2, .6, 'C3', vel)
        if full:
            s.note('taiko', bar * 4 + 1.5, .4, 'G3', vel - 10)
            s.note('taiko', bar * 4 + 3.5, .4, 'G3', vel - 8)
            s.note('kit', bar * 4 + 1, .2, 38, vel - 18, human=False)
            s.note('kit', bar * 4 + 3, .2, 38, vel - 12, human=False)
        for k in range(4):
            s.note('kit', bar * 4 + k + .5, .1, 75, vel - 30, human=False)

    def bass(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        s.note('cb', bar * 4, 1.8, b, vel)
        s.note('cb', bar * 4 + 2, 1.8, b if sym.startswith(('D7', 'Dsus')) else b + 7, vel - 6)

    def bed(bar):
        for i, sym in enumerate(['Gm', 'Gm', 'Ebmaj7', 'D7']):
            knife(bar + i, sym, 70)
            bass(bar + i, sym, 76)
            drums(bar + i, 86)
            s.pad('pad', bar + i, sym, 74, low='G3')
            s.chord('tbn', (bar + i) * 4, 3.8, s.chord_tones(sym, 'D3', 2), 62)
        s.mel('shaku', bar + 1, ITAMAE[:7] + [('r', 2)], 86)
        s.swell('pad', bar + 3, 1, 86, 104)

    bed(0)

    # A 4-19: the Itamae's theme - brass, shakuhachi doubling; knife strokes underneath
    for i in range(16):
        sym = ITAMAE_H[i % 4]
        knife(4 + i, sym, 64)
        bass(4 + i, sym, 82)
        drums(4 + i, 86)
        s.pad('pad', 4 + i, sym, 50, low='G3')
        if i % 4 == 0:
            s.timp_hit((4 + i) * 4, 'G2', 88)
    s.mel('brass', 4, ITAMAE * 2, 98)
    s.line('shaku', 4, ITAMAE * 2, 70, tr=12)
    s.mel('brass', 12, ITAMAE * 2, 100, tr=0)
    s.line('tbn', 12, ITAMAE * 2, 82, tr=-12)
    s.note('kit', 12 * 4, 2, 49, 84)
    s.timp_roll(19 * 4, 4, 'D2', 50, 100)

    # B 20-35: the corrupted course - the Buffet theme on koto, shamisen half a beat behind; motif inverted in the horns
    for i in range(16):
        bar = 20 + i
        sym = ['Gm', 'Ebmaj7', 'Cm7', 'D7', 'Gm', 'Eb', 'Cm', 'D7', 'Ebmaj7', 'Ebm6', 'Gm/D', 'A7', 'Cm7', 'D7', 'Gm', 'D7'][i]
        bass(bar, sym, 80)
        drums(bar, 84)
        s.pad('pad', bar, sym, 56, low='G3')
        if i % 2 == 0:
            knife(bar, sym, 56)
    s.mel('koto', 20, THEME, 96)
    s.line('sham', 20, THEME, 74, beat=.5)
    s.motif('hn', 24, motif('G4', 'minor', inverted=True) + [('r', 1)], 90, form='inverted (horns, against the corrupted course)', lead=False)
    s.motif('hn', 32, motif('D4', 'minor', inverted=True) + [('r', 1)], 88, form='inverted (horns)', lead=False)
    for k in range(16):
        s.note('kit', 35 * 4 + k * .25, .2, 38, 40 + k * 4, human=False)

    # C 36-47: the tea ceremony - shakuhachi alone with the motif over suspended harmony
    for i in range(12):
        bar = 36 + i
        sym = SUSP[i % 8]
        s.pad('pad', bar, sym, 58, low='G3')
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 56)
        s.note('kit', bar * 4, .1, 76, 56, human=False)
        tn = s.chord_tones(sym, 'G4', 4)
        s.note('koto', bar * 4 + 2, 1.5, tn[0], 54)
        s.note('koto', bar * 4 + 2.5, 1.5, tn[2], 50)
    s.motif('shaku', 36, augment(motif('G4', 'minor'), 1.5) + [('r', 1.5)], 92, form='stated, broadened (shakuhachi, the tea ceremony)')
    s.mel('shaku', 39, [('r', .5)] + augment(THEME[21:28], 2)[:5] + [('r', 1)], 82)
    s.motif('vln', 44, motif_head('D5', 'minor', rhythm=(2, 1, 5)), 76, form='head (violins, suspense)')
    s.swell('pad', 36, 12, 66, 100)

    # build 48-51
    for i, sym in enumerate(['Cm', 'Cm', 'D7sus4', 'D7']):
        knife(48 + i, sym, 66 + i * 6)
        bass(48 + i, sym, 80)
        s.pad('pad', 48 + i, sym, 66 + i * 6, low='G3')
        for k in range(8):
            s.note('taiko', (48 + i) * 4 + k * .5, .3, 'C3', 60 + i * 8 + k * 2)
    s.mel('brass', 48, ITAMAE[:7] + [('r', 2)] + ITAMAE[7:9], 92)
    s.timp_roll(50 * 4, 8, 'D2', 50, 112)

    # D 52-71: climax - the hero's motif in the horns against the Itamae in the brass
    for i in range(20):
        bar = 52 + i
        sym = CLIMAX[i % 8]
        knife(bar, sym, 70)
        bass(bar, sym, 88)
        drums(bar, 94)
        s.pad('pad', bar, sym, 62, low='G3')
        if i % 4 == 0:
            s.note('kit', bar * 4, 2, 49, 92)
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 94)
    s.motif('hn', 52, motif('G4', 'minor') + [('r', 1)] + motif('C5', 'minor') + [('r', 1)], 104, form='stated twice (horns: the hero fights back)')
    s.line('tbn', 52, ITAMAE * 2, 92, tr=-12)
    s.mel('brass', 60, ITAMAE * 2, 104)
    s.line('vln', 60, ITAMAE * 2, 96, tr=12)
    s.mel('vln', 68, THEME[:15], 100, tr=12)
    s.line('koto', 68, THEME[:15], 80)

    # wind-down 72-75
    for i, sym in enumerate(['Gm', 'Ebmaj7', 'Cm', 'D7']):
        knife(72 + i, sym, 70 - i * 2)
        bass(72 + i, sym, 80)
        drums(72 + i, 84, full=i < 2)
        s.pad('pad', 72 + i, sym, 70, low='G3')
    s.mel('shaku', 72, ITAMAE, 88)

    bed(76)
    s.fade_vel(78, 80, 1.15, ['spic', 'cb', 'taiko', 'kit', 'tbn'])
    return s
