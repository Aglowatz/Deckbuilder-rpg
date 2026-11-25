"""MUS-SHUFFLE-EXP - Step right up (the Shuffle House's menu and the Shuffled Halls' map). Loop, 64 bars 4/4, 128 BPM, Bb major.
Techno carnival-casino: a four-on-the-floor kick with the synth bass and an organ on the off-beats (the oom-pah of a fairground
organ, played by a drum machine), the house's own hook on a calliope, bright brass stabs, and a slot machine's sparkle on the
glockenspiel and celesta. The back room's sly minor tune is the middle (organ and muted trumpet); a breakdown lets the calliope
play the hook slowly over a pad, with the Crossroads motif once on the glockenspiel; then the hook comes back with a saw lead
under it. Upbeat and playful. Quantised. Original (Fable Nov 25).
"""
from lib import Score, motif, augment, bass_note
from scores._fork_c import tr, drums, snare_build, pump, roll_bass, riser, CRASH
from scores._shuffle import HOUSE_HOOK, HOUSE_PROG, CASINO_TUNE, CASINO_PROG, offbeat, sparkle, jackpot, stabs

BREAK_PROG = ['Bb', 'Eb', 'Cm', 'F7']


def build():
    s = Score('MUS-SHUFFLE-EXP', bpm=128, bars=64, key='Bb major', seed=2510, human=(0.0, 2))
    s.channel('kit', 'electro_kit', pan=64, reverb=40, vol=96)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=20, vol=90)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=20, vol=58)
    s.channel('org', 'organ', pan=40, reverb=70, vol=66)
    s.channel('cal', 'calliope', pan=56, reverb=72, vol=84)
    s.channel('lead', 'saw_lead', pan=76, reverb=66, vol=62)
    s.channel('stab', 'brass', pan=74, reverb=85, vol=80)
    s.channel('mute', 'muted_tpt', pan=70, reverb=80, vol=78)
    s.channel('glock', 'glock', pan=44, reverb=95, vol=62)
    s.channel('cel', 'celesta', pan=84, reverb=95, vol=58)
    s.channel('pad', 'poly_pad', pan=64, reverb=95, vol=64)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=62)
    s.detune('sbass2', 8)
    for bar, name in ((0, 'bed'), (4, 'A the house hook'), (20, 'B the back room'), (36, 'breakdown'), (44, 'A again, with the saw lead'),
                      (60, 'bed')):
        s.section(bar, name)

    def bounce(bar, sym, vel, pattern='off', clap=True, ohat=True):
        """The oom-pah as techno: the kick is the oom, the bass and the organ the pah."""
        s.pad('pad', bar, sym, 56, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, vel - 10, pattern=pattern)
        offbeat(s, 'org', bar, sym, 62)
        drums(s, bar, 1, vel, clap=clap, ohat=ohat)

    def bed(bar):
        for i in range(4):
            sym = HOUSE_PROG[4 + i]
            bounce(bar + i, sym, 90, clap=i >= 2)
            sparkle(s, 'glock', bar + i, sym, 54)
        pump(s, 'pad', bar, 4)
        s.mel('cal', bar, HOUSE_HOOK[-24:], 74, legato=.8)
        stabs(s, 'stab', bar, HOUSE_PROG[4], 70, beats=(0.0,))
        jackpot(s, 'cel', bar + 3, HOUSE_PROG[7], 56)

    bed(0)

    # A 4-19: the hook twice - calliope alone, then with the brass answering and the celesta ringing the phrase ends
    for i in range(16):
        bar, sym = 4 + i, HOUSE_PROG[i % 8]
        bounce(bar, sym, 96)
        if i >= 8 and i % 2 == 0:
            stabs(s, 'stab', bar, sym, 80)
        if i % 4 == 3:
            jackpot(s, 'cel', bar, sym, 60)
        if i % 8 in (1, 5):
            sparkle(s, 'glock', bar, sym, 52, beats=2.0, start=2.0)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 96, human=False)
    pump(s, 'pad', 4, 16)
    s.mel('cal', 4, HOUSE_HOOK, 90, legato=.8)
    s.mel('cal', 12, HOUSE_HOOK, 94, legato=.8)
    s.line('lead', 12, tr(HOUSE_HOOK, -12), 60, legato=.85)

    # B 20-35: the back room - the casino tune on the organ and a muted trumpet, a rolling bass, chips of celesta
    for i in range(16):
        bar, sym = 20 + i, CASINO_PROG[i % 8]
        s.pad('pad', bar, sym, 58, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, 86, pattern='gallop')
        drums(s, bar, 1, 92, ohat=i % 2 == 0)
        if i % 2 == 1:
            stabs(s, 'stab', bar, sym, 78, beats=(2.0, 3.0))
            sparkle(s, 'cel', bar, sym, 50, low='G5', beats=1.0, start=3.0)
        if i % 8 == 7:
            jackpot(s, 'glock', bar, sym, 60, low='D5')
    pump(s, 'pad', 20, 16)
    for k in (20, 28):
        s.mel('mute', k, CASINO_TUNE, 90, legato=.85)
        s.line('org', k, tr(CASINO_TUNE, -12), 60, legato=.7)
    s.line('cal', 28, tr(CASINO_TUNE, 12), 60, legato=.7)

    # breakdown 36-43: no kick - the calliope plays the hook's first half slowly over a pad; the motif on the glockenspiel; a riser
    for i in range(8):
        bar, sym = 36 + i, BREAK_PROG[i % 4]
        s.pad('pad', bar, sym, 70, low='A3')
        s.note('sbass', bar * 4, 3.8, bass_note(sym), 74, human=False)
        sparkle(s, 'cel', bar, sym, 46, low='Bb4', beats=4.0)
        if i >= 4:
            drums(s, bar, 1, 70 + i * 3, kick=False, clap=False)
    s.mel('cal', 36, augment(HOUSE_HOOK[:22], 2), 84, legato=.95)
    s.motif('glock', 40, motif('Bb5', 'major'), 72, form='stated (glockenspiel, breakdown)', lead=False)
    riser(s, 'rise', 40, 4, 'Bb3', vel=50, step=.5)
    snare_build(s, 42, 2, 44, 100)

    # A again 44-59: the drop - the hook on calliope and saw lead, the bass rolling, brass on every other bar, chimes everywhere
    for i in range(16):
        bar, sym = 44 + i, HOUSE_PROG[i % 8]
        bounce(bar, sym, 100, pattern='roll')
        if i % 2 == 0:
            stabs(s, 'stab', bar, sym, 84)
        if i % 4 == 3:
            jackpot(s, 'cel', bar, sym, 62)
        if i % 4 == 1:
            sparkle(s, 'glock', bar, sym, 54, beats=2.0, start=2.0)
        if i % 8 == 0:
            s.note('kit', bar * 4, 2, CRASH, 100, human=False)
    pump(s, 'pad', 44, 16, lo=34, hi=112)
    for k in (44, 52):
        s.mel('cal', k, HOUSE_HOOK, 96, legato=.8)
        s.line('lead', k, HOUSE_HOOK, 70, legato=.85)
    s.line('mute', 52, tr(HOUSE_HOOK, -12), 66, legato=.8)

    bed(60)
    return s
