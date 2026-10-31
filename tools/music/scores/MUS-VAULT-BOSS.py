"""MUS-VAULT-BOSS - The Vault Guardian (also the Warden of the Four Seals duel). Loop, 68 bars 4/4, 128 BPM, F# minor. Its own track.
The Guardian's own idea, SEALS (_fork_c): four heavy strokes - one per sealed Path - and a grinding half-step answer, in trombones and
tuba over stone drums (concert bass drum + timpani). The vault's royal phrase returns mirrored (inverted) in the horns: the old kingdom's
tune turned to a warning. The four-seals section gives each Path colour (horn, celesta, clarinet, flute) four bars to state a Crossroads
fragment over the grind; a hushed contrasting section (harp, celesta, the royal phrase as it was); then the climax: SEALS in the full
brass, the royal phrase in the strings in octaves, the motif augmented in the horns, cymbals. Intro/outro on the seal strokes + a bed.
"""
from lib import Score, motif, motif_head, motif_tail, augment, m, p, transpose, voice
from scores._fork_c import VAULT_ROYAL, VAULT_PROG, SEALS

PROG = ['F#m', 'G', 'F#m', 'C#7', 'Bm', 'G', 'C#7', 'F#m']


def mirror(mel, axis='F#4'):
    a = p(axis)
    return [(n if n == 'r' else 2 * a - p(n), d) for n, d in mel]


def build():
    s = Score('MUS-VAULT-BOSS', bpm=128, bars=68, key='F# minor', seed=963)
    s.seat('vln', 'trem', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'tuba', 'fl', 'cl', 'cel', 'harp', 'timp', 'perc', 'choir')
    for bar, nm in ((0, 'seal strokes'), (4, 'A the Guardian'), (20, 'B four seals'), (36, 'C hush'), (48, 'climax'), (64, 'seal strokes')):
        s.section(bar, nm)
    s.notes.append('Own villain idea SEALS (four strokes + a grinding answer); the vault\'s royal phrase inverted as the corrupted theme.')

    def strokes(bar, vel):
        for k in range(4):
            s.hit('bd', bar * 4 + k, vel + (8 if k == 0 else 0))
        s.timp_hit(bar * 4, 'F#3', vel)
        s.timp_hit(bar * 4 + 2, 'C#3', vel - 8)

    def seals(bar, vel, chs=('tbn', 'tuba')):
        s.line(chs[0], bar, SEALS, vel)
        s.line(chs[1], bar, SEALS, vel - 6, transpose=-12)

    def bed(bar):
        for i, sym in enumerate(['F#m', 'G', 'Bm', 'C#7']):
            s.pad('trem', bar + i, sym, 62, low='F#3')
            s.pad('choir', bar + i, sym, 54, low='A3', n=3)
            s.bass(bar + i, sym, 72, 'whole', chs=('cb', None))
            strokes(bar + i, 78)
        seals(bar, 86)
        seals(bar + 2, 88)
        s.motif('hn', bar + 1, motif_head('F#4', 'minor', rhythm=(1, .5, 2.5)), 84, form='head (horns, over the seals)')
        s.mel('vln', bar + 2, m('A5:2 G#5:2 | G5:2 F#5:2'), 80)
        s.timp_roll((bar + 3) * 4 + 2, 2, 'C#3', 50, 90)

    bed(0)

    # A 4-19: the Guardian - SEALS grinding, the royal phrase mirrored in the horns, string 8ths
    for i in range(16):
        bar, sym = 4 + i, PROG[i % 8]
        s.pad('trem', bar, sym, 56, low='F#3')
        s.bass(bar, sym, 74, 'pulse', chs=('cb', None))
        s.drum(bar, [(0, 'bd', 8), (1, 'snare', -6), (2.5, 'bd', 0), (3, 'snare', 0)], 74)
        if i % 2 == 0:
            seals(bar, 82)
    s.mel('hn', 4, transpose(mirror(VAULT_ROYAL), 0)[:11] + [('r', 4)], 94)
    s.mel('hn', 8, transpose(mirror(VAULT_ROYAL), 0)[11:], 94)
    s.motif('tpt', 12, motif('F#4', 'minor') + [('r', 1)], 88, form='stated (trumpet, defying)')
    s.mel('vln', 14, transpose(mirror(VAULT_ROYAL[:11]), 12), 90)
    s.hit('crash', 12 * 4, 80)

    # B 20-35: the four seals - one Path colour per seal, each with a Crossroads fragment over the grind
    colours = [('hn', 'F#3', 'horn (Beefcake seal)'), ('cel', 'F#5', 'celesta (Necrocrat seal)'),
               ('cl', 'F#4', 'clarinet (Gourmand seal)'), ('fl', 'F#5', 'flute (Refusemancer seal)')]
    for i in range(16):
        bar, sym = 20 + i, ['F#m', 'D', 'Bm', 'C#'][i % 4]
        s.pad('pad', bar, sym, 58, low='F#3')
        s.bass(bar, sym, 72, 'half', chs=('cb', None))
        strokes(bar, 66 if i % 4 else 84)
    for k, (ch, tonic, nm) in enumerate(colours):
        bar = 20 + k * 4
        s.motif(ch, bar, motif(tonic, 'minor') + [('r', 1)], 88, form=f'stated - {nm}')
        s.mel(ch, bar + 2, motif_tail(tonic, 'minor', rhythm=(1, 1, 2)) + [('r', 4)], 84)
        seals(bar + 2, 84)
        s.hit('crash', bar * 4, 72)

    # C 36-47: hush - harp, celesta, the royal phrase as it was (a memory of the vault before it was sealed)
    for i in range(12):
        bar, sym = 36 + i, VAULT_PROG[i % 8]
        s.pad('pad', bar, sym, 50, low='A3')
        s.harp(bar, sym, 52, density=16)
        s.bass(bar, sym, 52, 'whole', chs=('cb', None))
        if i % 4 == 0:
            s.hit('bd', bar * 4, 56)
    s.mel('cel', 36, transpose(VAULT_ROYAL[:11], 12), 74)
    s.mel('fl', 40, transpose(VAULT_ROYAL[11:], 12), 76)
    s.motif('vc', 44, augment(motif_head('F#3', 'minor'), 2) + [('r', 4)], 72, form='head augmented (cello, hush)')
    s.swell('pad', 44, 4, 70, 110)
    s.timp_roll(46 * 4, 8, 'C#3', 40, 96)

    # CLIMAX 48-63: SEALS in the full brass, the royal phrase in strings in octaves, the motif augmented in the horns
    for i in range(16):
        bar, sym = 48 + i, PROG[i % 8]
        s.pad('choir', bar, sym, 66, low='A3', n=3)
        s.pad('trem', bar, sym, 62, low='F#3')
        s.bass(bar, sym, 80, 'pulse', chs=('cb', None))
        s.drum(bar, [(0, 'bd', 10), (1, 'snare', -4), (2, 'bd', 2), (2.5, 'bd', -6), (3, 'snare', 2)], 80)
        if i % 4 == 0:
            s.hit('crash', bar * 4, 86)
            s.timp_hit(bar * 4, s.voicing(sym)[0] + 24, 94)
    for k in (48, 52, 56, 60):
        seals(k, 92)
        s.line('tpt', k, SEALS, 76, transpose=12)
    s.mel('vln', 48, transpose(VAULT_ROYAL, 12), 102)
    s.line('vc', 48, VAULT_ROYAL, 80, transpose=-12)
    s.motif('hn', 50, augment(motif('F#3', 'minor'), 2) + [('r', 2)], 98, form='augmented (horns, climax)', lead=False)
    s.motif('vln', 56, motif('F#5', 'minor') + [('r', 1)], 102, form='stated (violins high, climax)')
    s.mel('vln', 58, transpose(mirror(VAULT_ROYAL[11:]), 12), 100)
    s.timp_roll(63 * 4, 4, 'C#3', 50, 96)

    bed(64)
    s.fade_vel(66, 68, 0.85)     # seam: ease into the loop point
    return s
