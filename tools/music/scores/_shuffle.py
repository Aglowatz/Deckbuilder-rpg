"""Shared material of the Shuffle House's music (Fable Nov 25, the owner's decision 6). All of it is original.

The owner's direction:
  - exploring and menus (the Shuffle House, the Shuffled Halls): TECHNO CARNIVAL-CASINO - a driving electronic beat under carnival
    and casino colour (calliope or organ hooks, bright brass stabs, a chiming slot-machine sparkle), upbeat, playful, family friendly;
  - battles there: fast, intense electronic combat music in the spirit of modern cyberpunk action games - a pounding beat, heavy
    synth bass, rising tension, a quick punchy start; Octavia's boss fight the most intense version.

Three ideas carry the three tracks:
  HOUSE_HOOK   the house's own tune, a bouncing calliope hook in a major key (eight bars);
  CASINO_TUNE  the back-room tune, a sly minor line with a chromatic neighbour (eight bars);
  DEAL_RIFF    the battle riff, a syncopated two-bar figure with a tritone bite, and its two-bar answer.
The battle and the boss track are written once, in G minor, and moved to their own key (`shift`); `hot` adds the boss's extra
layers (timpani, choir, orchestra hits, the house hook as an "evil calliope", doubled leads).
"""
from lib import m, p, voice, bass_note, tones, motif, REST
from scores._fork_c import tr, chord, drums, snare_build, pump, roll_bass, arp, stutter, glitch, riser, KICK, CLAP, CRASH, HAT

ROOTS = {'C': 0, 'D': 2, 'E': 4, 'F': 5, 'G': 7, 'A': 9, 'B': 11}
NAMES = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']

# The house hook, Bb major, eight bars: Bb | Bb | F7 | F7 | Bb | Eb | Cm | Bb
HOUSE_HOOK = m('F5:.5 D5:.5 Bb4:.5 D5:.5 F5:1 G5:1 | F5:.5 Eb5:.5 D5:.5 C5:.5 D5:2 | '
               'Eb5:.5 C5:.5 A4:.5 C5:.5 Eb5:1 F5:1 | Eb5:.5 D5:.5 C5:.5 Bb4:.5 C5:2 | '
               'F5:.5 D5:.5 Bb4:.5 D5:.5 F5:1 Bb5:1 | A5:.5 G5:.5 F5:.5 Eb5:.5 G5:1.5 F5:.5 | '
               'Eb5:.5 G5:.5 F5:.5 Eb5:.5 D5:.5 F5:.5 Eb5:.5 C5:.5 | Bb4:1 D5:.5 F5:.5 Bb5:2')
HOUSE_PROG = ['Bb', 'Bb', 'F7', 'F7', 'Bb', 'Eb', 'Cm', 'Bb']

# The casino tune, G minor, eight bars: Gm | D7 | F | Bb | Cm | Gm | A7 | D7
CASINO_TUNE = m('G4:1 Bb4:.5 D5:.5 C#5:1 D5:1 | Eb5:.5 D5:.5 C5:.5 A4:.5 F#4:1.5 r:.5 | '
                'F4:1 A4:.5 C5:.5 B4:1 C5:1 | D5:.5 C5:.5 Bb4:.5 F4:.5 D5:1.5 r:.5 | '
                'Eb5:1 G5:.5 Eb5:.5 D5:1 C5:1 | D5:.5 Bb4:.5 G4:.5 Bb4:.5 D5:1.5 r:.5 | '
                'C#5:1 E5:.5 G5:.5 F5:1 E5:1 | D5:.5 F#5:.5 A5:.5 C6:.5 D6:1.5 r:.5')
CASINO_PROG = ['Gm', 'D7', 'F', 'Bb', 'Cm', 'Gm', 'A7', 'D7']

# The battle riff, G minor: two bars and a two-bar answer, over Gm | Gm | Eb | D
DEAL_RIFF = m('G4:.75 G4:.25 Bb4:.5 C5:.5 C#5:.25 D5:.75 F5:.5 D5:.5 | Bb4:.75 A4:.25 G4:.5 F4:.5 G4:1 r:.5 D5:.5')
DEAL_ANSWER = m('Eb5:.75 D5:.25 C5:.5 Bb4:.5 A4:.25 Bb4:.75 C5:.5 A4:.5 | G4:.75 F#4:.25 G4:.5 Bb4:.5 D5:1.5 r:.5')
RIFF_PROG = ['Gm', 'Gm', 'Eb', 'D']
# The house hook turned minor (G minor) for the fights: the same shape, the third and sixth lowered.
HOOK_MINOR = m('D5:.5 Bb4:.5 G4:.5 Bb4:.5 D5:1 Eb5:1 | D5:.5 C5:.5 Bb4:.5 A4:.5 Bb4:2 | '
               'C5:.5 A4:.5 F#4:.5 A4:.5 C5:1 D5:1 | C5:.5 Bb4:.5 A4:.5 G4:.5 A4:2 | '
               'D5:.5 Bb4:.5 G4:.5 Bb4:.5 D5:1 G5:1 | F5:.5 Eb5:.5 D5:.5 C5:.5 Eb5:1.5 D5:.5 | '
               'C5:.5 Eb5:.5 D5:.5 C5:.5 Bb4:.5 D5:.5 C5:.5 A4:.5 | G4:1 Bb4:.5 D5:.5 G5:2')
HOOK_MINOR_PROG = ['Gm', 'Gm', 'D7', 'D7', 'Gm', 'Cm', 'D7', 'Gm']


def tsym(sym, semis):
    """A chord symbol moved by `semis` semitones ('Cm/Eb', 3 -> 'Ebm/F#')."""
    def move(part):
        i = 1
        root = ROOTS[part[0]]
        while i < len(part) and part[i] in '#b':
            root += 1 if part[i] == '#' else -1
            i += 1
        return NAMES[(root + semis) % 12] + part[i:]
    return '/'.join(move(part) for part in sym.split('/'))


def prog(symbols, semis):
    return [tsym(sym, semis) for sym in symbols]


def offbeat(s, ch, bar, sym, vel, low='D4', n=3):
    """The "pah" of the oom-pah: a short chord on every off-beat 8th."""
    notes = voice(sym, low, n)
    for beat in range(int(s.bar_q)):
        chord(s, ch, bar * s.bar_q + beat + .5, .22, notes, vel)


def sparkle(s, ch, bar, sym, vel, low='Bb5', beats=4.0, start=0.0):
    """The slot machine: a chime of 16ths running up the chord and back."""
    tn = tones(sym, low, 6)
    order = [0, 1, 2, 3, 4, 5, 4, 3, 2, 3, 4, 5, 4, 3, 2, 1]
    for k in range(int(beats * 4)):
        s.note(ch, bar * s.bar_q + start + k * .25, .2, tn[order[k % 16]], vel + (8 if k % 4 == 0 else -4), human=False)


def jackpot(s, ch, bar, sym, vel, low='F5'):
    """Three rising chimes and a ring on the last beat of a phrase (the reels stop)."""
    tn = tones(sym, low, 8)
    t = bar * s.bar_q + 2.0
    for k, i in enumerate((0, 2, 4, 5, 7)):
        s.note(ch, t + k * .25, .22, tn[i], vel + k * 4, human=False)
    s.note(ch, t + 1.5, .5, tn[7], vel + 18, human=False)


def stabs(s, ch, bar, sym, vel, low='D4', n=3, beats=(0.0, 2.5)):
    for beat in beats:
        chord(s, ch, bar * s.bar_q + beat, .3, voice(sym, low, n), vel)


def full_hats(s, bar, vel, ch='kit'):
    """Straight 16th hats (the boss's extra drive), on top of the kit's pattern."""
    for k in range(16):
        s.note(ch, bar * s.bar_q + k * .25, .08, HAT, vel - (0 if k % 4 == 0 else 14), human=False)


def punch(s, bar, sym, vel, hot=False):
    """The downbeat of a section: a crash, an orchestra hit on the root, the timpani in the boss track."""
    s.note('kit', bar * s.bar_q, 2, CRASH, vel, human=False)
    s.note('hit', bar * s.bar_q, 1, voice(sym, 'G3', 1)[0], vel - 14, human=False)
    if hot:
        s.timp_hit(bar * s.bar_q, bass_note(sym) + 12, vel - 6)


def fight(s, shift=0, hot=False):
    """The fight track on Score `s` (96 bars of 4/4), written in G minor and moved by `shift` semitones.
    Channels wanted: kit, sbass, sbass2, pad, lead, lead2, sq, stab, hit, cal, rise (and timp, choir, org for `hot`)."""
    riff = tr(DEAL_RIFF, shift)
    answer = tr(DEAL_ANSWER, shift)
    casino = tr(CASINO_TUNE, shift)
    hook = tr(HOOK_MINOR, shift)
    a_prog = prog(RIFF_PROG, shift)
    c_prog = prog(CASINO_PROG, shift)
    h_prog = prog(HOOK_MINOR_PROG, shift)
    tonic = NAMES[(7 + shift) % 12]
    lead_vel = 96 if hot else 92
    for bar, name in ((0, 'A the deal (riff)'), (16, 'B the back room (casino tune)'), (32, 'C half-time'), (40, 'build'),
                      (48, 'drop'), (72, 'D glitch'), (88, 'A the deal again')):
        s.section(bar, name)

    def groove(bar, sym, vel, pattern='roll', half=False, ohat=True, clap=True):
        s.pad('pad', bar, sym, 64 if not hot else 70, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, sym, vel - 8, pattern=pattern)
        drums(s, bar, 1, vel, half=half, ohat=ohat, clap=clap)
        if hot and not half:
            full_hats(s, bar, vel - 30)

    def riff_block(bar, bars, vel, high=False):
        """The riff and its answer, four bars at a time, on the two detuned leads (an octave up when `high`)."""
        up = 12 if high else 0
        for k in range(bars // 4):
            at = bar + k * 4
            s.mel('lead', at, tr(riff, up), vel, legato=.82)
            s.mel('lead', at + 2, tr(answer, up), vel, legato=.82)
            s.line('lead2', at, riff, vel - 20, legato=.82)
            s.line('lead2', at + 2, answer, vel - 20, legato=.82)
            if hot:
                s.line('org', at, tr(riff, -12), vel - 26, legato=.7)
                s.line('org', at + 2, tr(answer, -12), vel - 26, legato=.7)

    # A 0-15: no warm-up - the hit, the kick and the riff land together on the first beat
    for i in range(16):
        bar, sym = i, a_prog[i % 4]
        groove(bar, sym, 104 if hot else 100)
        arp(s, 'sq', bar, 1, sym, 58, low=tonic + '4')
        if i % 2 == 0:
            stabs(s, 'stab', bar, sym, 82, low='D4')
        if i % 4 == 0:
            punch(s, bar, sym, 108 if i == 0 else 98, hot)
    pump(s, 'pad', 0, 16)
    riff_block(0, 16, lead_vel)

    # B 16-31: the casino tune over a galloping bass, brass stabs answering each phrase
    for i in range(16):
        bar, sym = 16 + i, c_prog[i % 8]
        groove(bar, sym, 100 if hot else 96, pattern='gallop', ohat=i % 4 != 3)
        if i % 2 == 1:
            stabs(s, 'stab', bar, sym, 86, low='D4', beats=(2.0, 2.5, 3.0))
        if i % 8 == 0:
            punch(s, bar, sym, 100, hot)
        if hot and i % 4 == 0:
            s.pad('choir', bar, sym, 62, beats=8, low='D4', n=3)
    pump(s, 'pad', 16, 16)
    for k in (16, 24):
        s.mel('lead', k, casino, lead_vel - 2, legato=.9)
        s.line('cal', k, tr(casino, 12), 58 if not hot else 64, legato=.7)
        s.line('lead2', k, casino, lead_vel - 24, legato=.9)
    snare_build(s, 30, 2, 54, 106)

    # C 32-39: half-time - the kick on one and three, a square arpeggio, the riff's first bar broken up; the Crossroads motif once
    for i in range(8):
        bar, sym = 32 + i, a_prog[i % 4]
        s.pad('pad', bar, sym, 68, low='A3')
        s.note('sbass', bar * 4, 3.8, bass_note(sym), 84, human=False)
        drums(s, bar, 1, 88, half=True, clap=False, ohat=False, snare=True)
        arp(s, 'sq', bar, 1, sym, 66, low=tonic + '4', order=(0, 2, 1, 3, 2, 4, 3, 1))
    pump(s, 'pad', 32, 8, lo=50, hi=110)
    s.motif('lead', 32, glitch(motif(tonic + '4', 'minor')) + [(REST, 1)], 86, form='glitched (saw lead, half-time)')
    s.mel('lead', 34, glitch(riff, cuts=(0, 5)), 84, legato=.8)
    s.mel('lead', 36, tr(answer, 0), 84, legato=.85)
    s.mel('lead', 38, glitch(tr(riff, 12), cuts=(0, 2, 5)), 86, legato=.8)

    # build 40-47: the bass holds the fifth, the hats double, a riser and a snare run into the drop
    fifth = tsym('D', shift)
    for i in range(8):
        bar = 40 + i
        s.pad('pad', bar, fifth, 60 + i * 3, low='A3')
        roll_bass(s, ('sbass', 'sbass2'), bar, fifth, 80 + i * 2, pattern='off' if i < 4 else 'roll')
        drums(s, bar, 1, 84 + i * 2, kick=i >= 4, clap=False, ohat=False)
        arp(s, 'sq', bar, 1, fifth, 60 + i * 2, low=tonic + '4', step=.25 if i < 6 else .125)
        s.mel('lead', bar, tr(riff[:8], 0 if i < 4 else 12), 78 + i * 2, legato=.8)
    riser(s, 'rise', 40, 8, tonic + '3', vel=48, step=1.0)
    snare_build(s, 44, 4, 44, 110)
    if hot:
        s.timp_roll(44 * 4, 16, bass_note(fifth) + 12, 40, 100)

    # drop 48-71: everything - the riff an octave up, stabs every bar, the house hook rides over it from bar 64
    for i in range(24):
        bar, sym = 48 + i, a_prog[i % 4]
        groove(bar, sym, 108 if hot else 104)
        stabs(s, 'stab', bar, sym, 84 + (4 if hot else 0), low='D4', beats=(0.0, 1.5, 2.5) if i % 2 else (0.0, 2.5))
        arp(s, 'sq', bar, 1, sym, 60, low=tonic + '5')
        if i % 4 == 0:
            punch(s, bar, sym, 108 if i == 0 else 100, hot)
        if hot and i % 8 == 0:
            s.pad('choir', bar, sym, 70, beats=8, low='D4', n=3)
    pump(s, 'pad', 48, 24, lo=30, hi=114)
    riff_block(48, 16, lead_vel + 2, high=True)
    for i in range(8):
        bar, sym = 64 + i, h_prog[i]
        # the hook's own harmony for eight bars, in the stabs; the bass stays on the groove
        stabs(s, 'hit' if hot else 'stab', bar, sym, 74, low='G3', beats=(0.0,))
    s.mel('cal', 64, tr(hook, 12), 92 if hot else 86, legato=.75)
    s.line('lead', 64, hook, lead_vel - 10, legato=.85)
    s.line('lead2', 64, riff * 4, lead_vel - 26, legato=.8)

    # D 72-87: glitch - half-time bars against full ones, stutters, the casino tune cut short
    for i in range(16):
        bar, sym = 72 + i, c_prog[i % 8]
        groove(bar, sym, 98 if hot else 94, pattern='gallop', half=i % 4 == 2, ohat=False)
        if i % 4 == 3:
            for k in range(4):
                stutter(s, 'sq', bar * 4 + k, voice(sym, tonic + '4', 3)[k % 3], 74, beats=.5)
        if i % 8 == 0:
            punch(s, bar, sym, 100, hot)
    pump(s, 'pad', 72, 16)
    for k in (72, 80):
        s.mel('lead', k, glitch(casino[:22], cuts=(0, 4, 9, 13)), lead_vel - 2, legato=.85)
        s.mel('lead', k + 4, casino[22:], lead_vel - 2, legato=.9)
        s.line('lead2', k, casino, lead_vel - 24, legato=.9)
    snare_build(s, 86, 2, 54, 104)

    # A 88-95: the riff again, as the track began (the loop's seam)
    for i in range(8):
        bar, sym = 88 + i, a_prog[i % 4]
        groove(bar, sym, 104 if hot else 100)
        arp(s, 'sq', bar, 1, sym, 58, low=tonic + '4')
        if i % 2 == 0:
            stabs(s, 'stab', bar, sym, 82, low='D4')
        if i % 4 == 0:
            punch(s, bar, sym, 98, hot)
    pump(s, 'pad', 88, 8)
    riff_block(88, 8, lead_vel)
    if hot:
        # the seam: the boss track opens on timpani, choir and a hit, so its last bars carry them too
        s.pad('choir', 92, a_prog[0], 70, beats=16, low='D4', n=3)
        s.timp_roll(94 * 4, 8, bass_note(a_prog[3]) + 12, 56, 104)
        stabs(s, 'stab', 95, a_prog[3], 90, low='D4', beats=(0.0, 1.0, 2.0, 2.5, 3.0, 3.5))
