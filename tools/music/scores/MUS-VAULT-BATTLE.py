"""MUS-VAULT-BATTLE - Forgotten Vault combat. Loop, 72 bars 4/4, 140 BPM, B minor.
The vault's royal phrase (_fork_c.VAULT_ROYAL, in B minor) driven: a measured 8th string ostinato and moving bass under it, crisp snare
and timpani, the clockwork ticking in 8ths on woodblock. Phrase one: the royal phrase in the horns. Phrase two (contrast): the
Crossroads motif in the brass, answered by quick calls from the four Path colours (flute, celesta, clarinet, trumpet). A driving
string statement of the phrase an octave up with brass stabs, a darker tension passage (the motif augmented in the low brass), and an
intro/outro bed of brass and strings so the loop never thins out.
"""
from lib import Score, motif, motif_head, augment, m, p, transpose, voice
from scores._fork_c import VAULT_ROYAL, VAULT_PROG

T = 5                                    # F# minor -> B minor
PROG = ['Bm', 'A', 'Bm', 'G', 'Em', 'F#7', 'G', 'Bm']


def build():
    s = Score('MUS-VAULT-BATTLE', bpm=140, bars=72, key='B minor', seed=962)
    s.seat('vln', 'spic', 'pad', 'vc', 'cb', 'hn', 'tpt', 'tbn', 'fl', 'cl', 'cel', 'timp', 'perc')
    s.channel('wb', 'woodblock', pan=30, reverb=70, vol=58)
    for bar, nm in ((0, 'bed'), (4, 'A royal phrase (horns)'), (20, 'B four colours answer'), (36, 'C strings drive'),
                    (52, 'D tension'), (68, 'bed')):
        s.section(bar, nm)

    def drive(bar, sym, vel):
        tn = voice(sym, 'F#3', 3)
        cell = [tn[0], tn[1], tn[0], tn[2], tn[0], tn[1], tn[2], tn[1]]
        for k in range(8):
            s.note('spic', bar * 4 + k * .5, .4, cell[k], vel + (10 if k % 4 == 0 else 0))

    def kit(bar, vel, full=True):
        s.drum(bar, [(0, 'bd', 6), (1, 'snare', -6), (2, 'bd', 0), (3, 'snare', -2)] + ([(3.5, 'snare2', -14)] if full else []), vel)
        for k in range(8):
            s.note('wb', bar * 4 + k * .5, .1, p('E5') if k % 2 else p('B5'), 44 + (6 if k == 0 else 0), human=False)

    def bed(bar):
        for i, sym in enumerate(['Bm', 'G', 'Em', 'F#7']):
            s.brass('tbn', bar + i, sym, 62, low='D3')
            s.pad('pad', bar + i, sym, 64, low='F#3')
            s.bass(bar + i, sym, 70, 'half')
            drive(bar + i, sym, 66)
            kit(bar + i, 66, full=False)
        s.timp_hit(bar * 4, 'B2', 82)
        s.motif('hn', bar + 1, motif_head('B3', 'minor', rhythm=(1, .5, 2.5)), 84, form='head (horns, over the bed)')
        s.mel('vln', bar + 2, m('D5:1 C#5:1 B4:1 A4:1 | A#4:4'), 76)
        s.timp_roll((bar + 3) * 4 + 2, 2, 'F#2', 50, 86)

    bed(0)

    # A 4-19: the royal phrase in the horns over the drive
    for i in range(16):
        bar, sym = 4 + i, PROG[i % 8]
        drive(bar, sym, 70)
        s.bass(bar, sym, 72, 'march')
        kit(bar, 70)
        s.pad('pad', bar, sym, 48, low='F#3')
        if i % 4 == 0:
            s.timp_hit(bar * 4, s.voicing(sym)[0] + 12, 84)
    s.mel('hn', 4, transpose(VAULT_ROYAL, T - 12), 94)
    s.mel('hn', 12, transpose(VAULT_ROYAL, T - 12), 96)
    s.line('tpt', 12, transpose(VAULT_ROYAL[:11], T), 70)
    s.motif('fl', 8, motif('B4', 'minor') + [('r', 1)], 66, form='stated (flute, over the horns)', lead=False)

    # B 20-35: the hero's motif in the brass, the four colours answer
    bprog = ['G', 'D', 'Em', 'F#'] * 4
    calls = [('fl', 'D6:.5 C#6:.5 B5:1'), ('cel', 'F#5:.5 G5:.5 A5:1'), ('cl', 'B4:.5 D5:.5 F#5:1'), ('tpt', 'F#5:.5 E5:.5 D5:1')]
    for i, sym in enumerate(bprog):
        bar = 20 + i
        drive(bar, sym, 66)
        s.bass(bar, sym, 70, 'half')
        kit(bar, 66, full=i % 2 == 1)
        s.pad('pad', bar, sym, 54, low='F#3')
    for k in (20, 28):
        s.motif('tpt', k, motif('B4', 'minor') + [('r', 1)], 90, form='stated (trumpets)')
        s.line('hn', k, motif('B3', 'minor'), 74)
        for j, (ch, mm) in enumerate(calls):
            s.mel(ch, k + 2 + (j // 2) * 2, m(mm), 82, beat=(j % 2) * 2 + 0)
        s.mel('vln', k + 6, m('G5:1 F#5:1 E5:1 D5:1 | C#5:4'), 84)
    s.timp_roll(35 * 4, 4, 'F#2', 50, 90)

    # C 36-51: the phrase in the violins an octave up, brass stabs, full kit
    for i in range(16):
        bar, sym = 36 + i, PROG[i % 8]
        drive(bar, sym, 74)
        s.bass(bar, sym, 76, 'march')
        kit(bar, 76)
        s.brass('tbn', bar, sym, 76, beats=.5, low='D3')
        s.brass('tbn', bar, sym, 70, beats=.5, low='D3', beat=2.5)
        if i % 4 == 0:
            s.timp_hit(bar * 4, s.voicing(sym)[0] + 12, 88)
            s.hit('crash', bar * 4, 76)
    s.mel('vln', 36, transpose(VAULT_ROYAL, T), 98)
    s.line('cl', 36, transpose(VAULT_ROYAL, T - 12), 66)
    s.mel('vln', 44, transpose(VAULT_ROYAL, T + 12)[:11] + transpose(VAULT_ROYAL, T)[11:], 100)
    s.motif('hn', 44, augment(motif_head('B3', 'minor'), 2) + [('r', 4)], 86, form='head augmented (horns)', lead=False)

    # D 52-67: tension - lower, the motif augmented in trombones, snare roll build, the clock louder
    dprog = ['Em', 'Em', 'C', 'C', 'Am', 'Am', 'F#', 'F#'] * 2
    for i, sym in enumerate(dprog):
        bar = 52 + i
        drive(bar, sym, 70)
        s.bass(bar, sym, 72, 'whole')
        kit(bar, 64, full=False)
        s.pad('pad', bar, sym, 60, low='E3')
    s.motif('tbn', 52, augment(motif('E3', 'minor'), 2) + [('r', 2)], 90, form='augmented (trombones, tension)')
    s.mel('vln', 54, m('G5:4 | F#5:4 | E5:2 G5:2 | B5:4 | A5:4 | C6:4 | B5:2 A#5:2 | F#5:4'), 86)
    s.mel('hn', 60, transpose(VAULT_ROYAL[:6], T - 12 + 0), 90)
    s.line('cel', 62, m('B5:.5 C#6:.5 D6:.5 E6:.5 F#6:2'), 60)
    s.snare_roll(66 * 4, 8, 40, 96)
    s.timp_roll(67 * 4, 4, 'F#2', 50, 92)

    bed(68)
    return s
