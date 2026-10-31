"""MUS-VAULT-EXP - Forgotten Vault exploration. Loop, 44 bars 4/4, 80 BPM, F# minor.
A mossy chamber mystery: a soft string pad, low harp, and a ticking clockwork of woodblock and glockenspiel. The vault's quiet royal
phrase (_fork_c.VAULT_ROYAL) is handed between four distinct colours, one per Path - horn (Beefcake), celesta (Necrocrat), clarinet
(Gourmand), flute (Refusemancer) - as if four old keys fit one lock. Discovery brightens the middle (A and D major, warm strings, the
Crossroads motif stated, the lullaby's first four notes once on the celesta - a royal clue). The phrase returns softly in octaves and
the clockwork carries back into the loop.
"""
from lib import Score, motif, motif_head, m, p, transpose, LULLABY_HEAD
from scores._fork_c import VAULT_ROYAL, VAULT_PROG


def build():
    s = Score('MUS-VAULT-EXP', bpm=80, bars=44, key='F# minor', seed=961)
    s.seat('pad', 'vln', 'vc', 'cb', 'harp', 'hn', 'cel', 'cl', 'fl', 'glock', 'timp', 'pizz')
    s.channel('wb', 'woodblock', pan=30, reverb=80, vol=60)
    for bar, nm in ((0, 'clockwork'), (4, 'A royal phrase, four colours'), (20, 'B discovery'), (32, 'C the phrase together'),
                    (40, 'clockwork')):
        s.section(bar, nm)

    def clock(bar, vel=46, glock=True):
        for k in range(8):
            s.note('wb', bar * 4 + k * .5, .1, p('G5') if k % 2 == 0 else p('D5'), vel + (8 if k == 0 else 0), human=False)
        if glock:
            s.note('glock', bar * 4 + 3.5, .3, p('C#6'), vel - 4)

    def ground(bar, sym, vel=44):
        s.pad('pad', bar, sym, vel, low='A3')
        s.bass(bar, sym, vel + 4, 'whole')
        s.harp(bar, sym, vel - 4)

    def intro(bar):
        for i, sym in enumerate(['F#m', 'D', 'Bm', 'C#7']):
            ground(bar + i, sym)
            clock(bar + i)
        s.motif('cel', bar + 1, motif_head('F#5', 'minor', rhythm=(1, .5, 2.5)), 62, form='head (celesta, a clue)')
        s.mel('pizz', bar + 2, m('F#4:1 r:1 C#4:1 r:1 | D4:1 r:1 E#4:2'), 58)

    intro(0)

    # A 4-19: the royal phrase passed between four colours (2 bars each, twice through)
    colours = ['hn', 'cel', 'cl', 'fl']
    for rep in range(2):
        for i in range(8):
            bar = 4 + rep * 8 + i
            ground(bar, VAULT_PROG[i], 46)
            clock(bar, 40, glock=i % 2 == 1)
    order = [('hn', -12), ('cel', 12), ('cl', 0), ('fl', 12)]
    pos = 0.0
    phrase = VAULT_ROYAL
    for rep in range(2):
        for k, (ch, o) in enumerate(order):
            seg = phrase[{0: 0, 1: 6, 2: 11, 3: 17}[k]: {0: 6, 1: 11, 2: 17, 3: 22}[k]]
            bar = 4 + rep * 8 + k * 2
            s.mel(ch, bar, seg, 78 if ch != 'cel' else 74, transpose=o)
    s.motif('vc', 12, motif('F#3', 'minor') + [('r', 1)], 58, form='stated (cello, under the clarinet)', lead=False)

    # B 20-31: discovery brightens - A major, D major, warm strings, the motif stated; the lullaby's first four notes once
    bprog = ['A', 'E/G#', 'F#m', 'D', 'A', 'C#m', 'D', 'E', 'D', 'A/C#', 'Bm7', 'C#7']
    for i, sym in enumerate(bprog):
        bar = 20 + i
        s.pad('pad', bar, sym, 54, low='A3')
        s.bass(bar, sym, 54, 'half')
        s.harp(bar, sym, 50, density=16)
        if i % 2 == 0:
            clock(bar, 34, glock=True)
    s.swell('pad', 20, 4, 70, 96)
    s.motif('vln', 20, motif('A4', 'major') + [('r', 1)], 84, form='stated (violins, A major - discovery)')
    s.mel('vln', 22, m('C#5:1 E5:1 A5:2 | G#5:1 F#5:1 E5:2'), 82)
    s.mel('hn', 24, m('E4:2 A4:2 | C#5:3 B4:1 | A4:2 F#4:2 | E4:4'), 76)
    s.mel('cel', 28, [(p(n) + 4 + 12, 1) for n, d in LULLABY_HEAD[:4]], 70)     # F# C# A G#: first four notes, once
    s.notes.append('Lullaby: first four notes once (celesta, bar 28, F# C# A G#) - a royal clue.')
    s.mel('fl', 29, m('B5:2 A5:2 | G#5:2 E#5:2 | F#5:4'), 66)
    s.timp_roll(31 * 4, 4, 'C#3', 40, 70)

    # C 32-39: the phrase together - strings in octaves, the four colours as a chord underneath
    for i in range(8):
        bar = 32 + i
        sym = VAULT_PROG[i]
        s.pad('pad', bar, sym, 50, low='A3')
        s.bass(bar, sym, 52, 'whole')
        s.harp(bar, sym, 46)
        clock(bar, 38, glock=i % 2 == 0)
    s.mel('vln', 32, VAULT_ROYAL, 84)
    s.line('vc', 32, VAULT_ROYAL, 62, transpose=-12)
    s.line('cl', 36, transpose(VAULT_ROYAL[11:], -12), 56)
    s.motif('hn', 34, motif_head('C#4', 'minor', rhythm=(2, 1, 5)), 58, form='head (horn, under the phrase)', lead=False)
    s.timp_hit(32 * 4, 'F#2', 60)

    intro(40)
    s.fade_vel(42, 44, 1.2, ['pad', 'cb', 'vc', 'harp', 'wb'])     # seam: lift into the loop point
    return s
