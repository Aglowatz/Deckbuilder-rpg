"""MUS-ARENA-BATTLE - The Grand Clashatorium. Loop, 64 bars 4/4, 140 BPM, Eb major.
Showbiz spectacle for Grand Bellows' arena: brass fanfares over rolling snare and timpani, assertive string 8ths, and a broad adventurous
tune (_fork_c.ARENA_THEME) in trumpets and horns. A quieter strategic B section (pizzicato, clarinet, a light snare, the Crossroads
motif in the horn) keeps a long duel comfortable; the tune returns in the violins an octave up with the motif as a brass countermelody
and cymbals; a "ladies and gentlemen" build of rising brass chords over a drumroll leads back to the fanfare bed at the loop point.
"""
from lib import Score, motif, motif_head, augment, m, p, transpose, voice
from scores._fork_c import ARENA_THEME, ARENA_PROG


def chords_of(prog):
    out = []
    for bar, spec in enumerate(prog):
        syms = spec.split()
        for k, sym in enumerate(syms):
            out.append((bar, k * 4 / len(syms), 4 / len(syms), sym))
    return out


def build():
    s = Score('MUS-ARENA-BATTLE', bpm=140, bars=64, key='Eb major', seed=966)
    s.seat('vln', 'spic', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'cl', 'fl', 'glock', 'pizz', 'timp', 'perc')
    for bar, nm in ((0, 'fanfare'), (4, 'A the tune'), (20, 'B strategy'), (36, 'C the tune, strings'), (52, 'D presenting'),
                    (60, 'fanfare')):
        s.section(bar, nm)

    def harmony(bar0, vel, pattern='march', strings=True, chs=('cb', 'vc')):
        for bar, beat, dur, sym in chords_of(ARENA_PROG):
            b = bar0 + bar
            s.bass_at(b * 4 + beat, dur, sym, vel, chs=chs)
            if strings:
                tn = voice(sym, 'Bb3', 3)
                for k in range(int(dur * 2)):
                    s.note('spic', b * 4 + beat + k * .5, .4, tn[k % 3], vel - 6 + (8 if k % 4 == 0 else 0))

    def kit(bar, vel, light=False):
        if light:
            s.drum(bar, [(0, 'bd', 0), (1.5, 'snare2', -14), (3, 'snare2', -10)], vel)
            return
        s.drum(bar, [(0, 'bd', 8), (1, 'snare', -4), (2, 'bd', 2), (3, 'snare', 0), (3.5, 'snare2', -12), (3.75, 'snare2', -10)], vel)

    def fanfare(bar):
        for i, sym in enumerate(['Eb', 'Ab', 'Bb', 'Bb7']):
            s.brass('tbn', bar + i, sym, 76, beats=1.5, low='Eb3')
            s.brass('tbn', bar + i, sym, 70, beats=2, low='Eb3', beat=2)
            s.pad('pad', bar + i, sym, 60, low='G3')
            s.bass(bar + i, sym, 70, 'half')
            kit(bar + i, 70)
        s.mel('tpt', bar, m('Bb4:.5 Bb4:.25 Bb4:.25 Eb5:1 G5:1 Bb5:1 | Ab5:2 C6:2 | Bb5:1 F5:1 D5:1 F5:1 | Bb5:4'), 92)
        s.line('hn', bar, m('G4:.5 G4:.25 G4:.25 Bb4:1 Eb5:1 G5:1 | F5:2 Ab5:2 | F5:1 D5:1 Bb4:1 D5:1 | F5:4'), 76)
        s.motif('glock', bar + 2, motif_head('Eb6', 'major', rhythm=(1, .5, .5)), 50, form='head (glockenspiel sparkle)', lead=False)
        s.timp_hit(bar * 4, 'Eb3', 86)
        s.snare_roll((bar + 3) * 4, 4, 40, 84)

    fanfare(0)

    # A 4-19: the tune in trumpet + horns, strings driving, snare march
    for rep in range(2):
        harmony(4 + rep * 8, 72)
        for i in range(8):
            kit(4 + rep * 8 + i, 72)
    s.mel('tpt', 4, ARENA_THEME, 94)
    s.line('hn', 4, ARENA_THEME, 78, transpose=-12)
    s.mel('hn', 12, ARENA_THEME, 96)
    s.line('tbn', 12, ARENA_THEME, 70, transpose=-12)
    s.motif('fl', 8, motif('Eb5', 'major') + [('r', 1)], 70, form='stated (flute, over the trumpets)', lead=False)
    for b in (4, 12):
        s.timp_hit(b * 4, 'Eb3', 88)
        s.hit('crash', b * 4, 80)

    # B 20-35: strategy - quieter, pizzicato, clarinet, the hero's motif in the horn, a light kit
    bprog = ['Cm', 'Ab', 'Eb/G', 'Bb', 'Cm', 'Fm7', 'Bb7sus4', 'Bb7'] * 2
    for i, sym in enumerate(bprog):
        bar = 20 + i
        s.pizz(bar, sym, 62)
        s.pad('pad', bar, sym, 44, low='G3')
        s.bass(bar, sym, 56, 'whole', chs=('cb', None))
        kit(bar, 58, light=True)
    s.motif('hn', 20, motif('C4', 'minor') + [('r', 1)], 84, form='stated (horn, strategy)')
    s.mel('cl', 22, m('Eb5:1 D5:1 C5:1 Bb4:1 | Ab4:2 G4:2 | F4:1 G4:1 Ab4:1 C5:1 | Bb4:4'), 80)
    s.motif('cl', 28, motif('C5', 'minor') + [('r', 1)], 80, form='stated (clarinet)')
    s.mel('fl', 30, m('F5:1 Eb5:1 D5:1 F5:1 | Bb5:2 Ab5:2 | G5:1 F5:1 Eb5:1 D5:1 | F5:4'), 74)
    s.snare_roll(35 * 4, 4, 36, 80)

    # C 36-51: the tune in the violins 8va, the motif as a brass countermelody, cymbals
    for rep in range(2):
        harmony(36 + rep * 8, 78)
        for i in range(8):
            kit(36 + rep * 8 + i, 78)
    s.mel('vln', 36, transpose(ARENA_THEME, 12), 100)
    s.mel('vln', 44, transpose(ARENA_THEME, 12), 102)
    s.motif('hn', 38, augment(motif('Eb4', 'major'), 1) + [('r', 1)], 88, form='countermelody (horns, under the violins)', lead=False)
    s.motif('tbn', 46, augment(motif_head('Eb3', 'major'), 2) + [('r', 4)], 84, form='head augmented (trombones)', lead=False)
    for b in (36, 40, 44, 48):
        s.hit('crash', b * 4, 84)
        s.timp_hit(b * 4, 'Eb3', 90)

    # D 52-59: presenting... - rising brass chords over a drumroll, the timpani pounding
    ladder = ['Cm', 'Db', 'Eb', 'F', 'Gb', 'Ab', 'Bbsus4', 'Bb7']
    for i, sym in enumerate(ladder):
        bar = 52 + i
        s.brass('tbn', bar, sym, 66 + i * 3, low='Eb3')
        s.brass('tpt', bar, sym, 62 + i * 3, beats=2, low='Bb4', beat=2)
        s.pad('pad', bar, sym, 54 + i * 2, low='G3')
        s.bass(bar, sym, 64 + i * 2, 'pulse', chs=('cb', None))
        s.snare_roll(bar * 4, 4, 40 + i * 5, 50 + i * 5)
        s.timp_hit(bar * 4, s.voicing(sym)[0] + 24, 70 + i * 3)
    s.mel('vln', 52, m('C5:4 | Db5:4 | Eb5:4 | F5:4 | Gb5:4 | Ab5:4 | Bb5:4 | D6:4'), 80)
    s.tag_melody('vln', 52, 60)

    fanfare(60)
    return s
