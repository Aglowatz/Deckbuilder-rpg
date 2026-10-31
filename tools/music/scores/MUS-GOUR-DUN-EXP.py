"""MUS-GOUR-DUN-EXP - Test Kitchen, exploration. 64 bars 4/4, 112 BPM, D minor.
Hidden machinery: a clockwork ostinato (celesta 16ths, woodblock ticks, a pizzicato/contrabass pulse, no humanising - every note on the
grid) under the Buffet theme turned cold: down to D minor, played staccato and evenly by a clarinet with no phrase arc, so the melody
looks perfect while its phrasing is impersonal. A colder B section passes the theme's welcome head from desk to desk (glock, muted
trumpet, celesta - an assembly line) while the muted trumpet asks the Crossroads motif; the strings then take the theme in unison over
the full machine before it winds back down to the ticking intro.
"""
from lib import Song, motif, motif_head, augment, transpose, p
from lib.zones import BUFFET_THEME, BUFFET_THEME_A, to_mode

THEME = to_mode(transpose(BUFFET_THEME, -3), {6: -1, 11: -1, 1: -1})       # the Buffet theme in D minor
HEAD = to_mode(transpose(BUFFET_THEME_A[:6], -3), {6: -1, 11: -1, 1: -1})  # D Bb D... the welcome head, cold
PROG = ['Dm', 'Bbmaj7', 'Gm7', 'A7', 'Dm', 'Bb', 'Gm', 'A7', 'Bbmaj7', 'Bbm6', 'Dm/A', 'E7', 'Gm7', 'A7sus4', 'Dm', 'A7']
COLD = ['Dm', 'Bbmaj7', 'Gm', 'Asus4']


def build():
    s = Song('MUS-GOUR-DUN-EXP', bpm=112, bars=64, key='D minor', seed=402, jitter=0.0)
    s.vel_spread = 2
    s.channel('cel', 'celesta', 44, 90, 74)
    s.channel('xylo', 'xylophone', 52, 80, 64)
    s.channel('glock', 'glock', 40, 95, 62)
    s.channel('cl', 'clarinet', 60, 80, 100)
    s.channel('mtpt', 'muted_tpt', 56, 85, 92)
    s.channel('vln', 'strings', 36, 95, 98)
    s.channel('pad', 'slow_strings', 64, 100, 72)
    s.channel('pizz', 'pizz', 74, 70, 82)
    s.channel('cb', 'contrabass', 92, 90, 86)
    s.channel('bsn', 'bassoon', 76, 85, 74)
    s.channel('hn', 'horn', 78, 95, 84)
    s.channel('harp', 'harp', 46, 80, 74)
    s.channel('timp', 'timpani', 64, 80, 86)
    s.channel('kit', 'standard_kit', 64, 70, 84)
    for bar, nm in ((0, 'machinery'), (8, 'A cold theme'), (24, 'B assembly line'), (36, "A' strings"), (56, 'machinery again')):
        s.section(bar, nm)

    def clock(bar, vel, dense=False):
        for k in range(8):
            s.note('kit', bar * 4 + k * .5, .1, 76 if k % 2 == 0 else 77, vel + (8 if k == 0 else 0), human=False)
        if dense:
            for k in range(16):
                s.note('kit', bar * 4 + k * .25, .1, 70, vel - 22 + (6 if k % 4 == 0 else 0), human=False)

    def gears(bar, sym, vel, ch='cel', low='D5'):
        tn = s.chord_tones(sym, low, 4)
        cell = [tn[0], tn[2], tn[1], tn[3], tn[2], tn[1], tn[0], tn[2]]
        for k in range(16):
            s.note(ch, bar * 4 + k * .25, .2, cell[k % 8], vel + (6 if k % 4 == 0 else -4), human=False)

    def pulse(bar, sym, vel):
        b = p(s.voicing(sym)[0])
        for k in range(8):
            s.note('cb', bar * 4 + k * .5, .3, b, vel + (8 if k % 4 == 0 else 0), human=False)
        s.note('pizz', bar * 4 + 1, .3, b + 12, vel - 6)
        s.note('pizz', bar * 4 + 3, .3, b + 19, vel - 8)

    def machine(bar, bars, vel):
        for i in range(bars):
            sym = COLD[i % 4]
            gears(bar + i, sym, vel - 6)
            pulse(bar + i, sym, vel - 4)
            clock(bar + i, vel - 18)
            s.pad('pad', bar + i, sym, vel - 18, low='A3')
        s.motif('bsn', bar + 4, augment(motif_head('D3', 'minor'), 2) + [('r', 4)], vel + 6, form='head augmented (bassoon, in the machine)')
        s.swell('pad', bar, bars, 70, 90)

    machine(0, 8, 64)

    # A 8-23: the theme cold - clarinet staccato, even, no arc; the muted trumpet doubles the second half
    for i in range(16):
        bar = 8 + i
        sym = PROG[i]
        gears(bar, sym, 54)
        pulse(bar, sym, 60)
        clock(bar, 44)
        s.pad('pad', bar, sym, 44, low='A3')
    s.mel('cl', 8, THEME, 90, legato=.55, arc=False)
    s.line('mtpt', 16, THEME[21:40], 66, legato=.5, arc=False)
    s.timp_hit(8 * 4, 'D2', 70)
    s.timp_hit(16 * 4, 'D2', 64)

    # B 24-35: the assembly line - the welcome head passed from station to station; the motif asked on muted trumpet
    for i in range(12):
        bar = 24 + i
        sym = COLD[i % 4]
        s.pad('pad', bar, sym, 52, low='A3')
        s.harp(bar, sym, 46)
        s.note('cb', bar * 4, 4, p(s.voicing(sym)[0]), 52)
        clock(bar, 36)
    for k, (ch, tr) in enumerate([('glock', 12), ('cel', 0), ('xylo', 12), ('glock', 0)]):
        s.line(ch, 26 + k * 2, HEAD, 64, tr=tr, legato=.5, arc=False)
    s.motif('mtpt', 24, motif('D4', 'minor') + [('r', 1)], 84, form='stated (muted trumpet, a question at the station)')
    s.motif('mtpt', 30, motif('A4', 'minor') + [('r', 1)], 80, form='stated, a fifth up (muted trumpet)')
    s.mel('cl', 26, [('r', 4)] + augment(HEAD, 2)[:4] + [('r', 2)], 70, legato=.6)
    s.mel('cl', 32, augment(HEAD, 2)[:4] + [('A4', 4)], 74, legato=.6)
    s.swell('pad', 24, 12, 60, 96, 'arch')
    s.timp_roll(35 * 4, 4, 'A1', 34, 76)

    # A' 36-55: the strings take the theme in unison over the whole machine; horns in cold stabs
    for i in range(20):
        bar = 36 + i
        sym = PROG[i % 16]
        gears(bar, sym, 58)
        gears(bar, sym, 50, ch='xylo', low='A5') if i % 2 == 0 else None
        pulse(bar, sym, 66)
        clock(bar, 48, dense=True)
        s.pad('pad', bar, sym, 50, low='A3')
        s.chord('hn', bar * 4 + 1, .4, s.chord_tones(sym, 'F3', 3), 50)
        if i % 4 == 0:
            s.timp_hit(bar * 4, p(s.voicing(sym)[0]) + 12, 76)
    s.mel('vln', 36, THEME, 96, legato=.7, arc=False)
    s.line('cl', 36, THEME, 62, legato=.5, arc=False, tr=-12)
    s.mel('vln', 52, THEME[:15], 92, legato=.7, arc=False)
    s.motif('hn', 44, motif('D3', 'minor') + [('r', 1)], 72, form='stated low (horns, under the strings)', lead=False)

    machine(56, 8, 64)
    return s
