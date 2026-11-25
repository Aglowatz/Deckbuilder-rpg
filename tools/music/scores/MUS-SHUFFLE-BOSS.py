"""MUS-SHUFFLE-BOSS - The house always deals (Octavia Eightfold at the Big Wheel). Loop, 96 bars 4/4, 184 BPM, E minor. Quantised.
The fight track at its most intense: lower (E minor), faster, with straight 16th hats on top of the kit, timpani and orchestra
hits on every section's downbeat, a choir under the long phrases, an organ doubling the DEAL riff an octave down, and the
house's own hook as a loud calliope over the drop - the showwoman's tune turned against the player. Original (Fable Nov 25).
"""
from lib import Score
from scores._shuffle import fight


def build():
    s = Score('MUS-SHUFFLE-BOSS', bpm=184, bars=96, key='E minor', seed=2512, human=(0.0, 2))
    s.channel('kit', 'electro_kit', pan=64, reverb=36, vol=102)
    s.channel('sbass', 'synth_bass2', pan=64, reverb=18, vol=98)
    s.channel('sbass2', 'bass_lead', pan=64, reverb=18, vol=70)
    s.channel('pad', 'poly_pad', pan=64, reverb=90, vol=72)
    s.channel('lead', 'saw_lead', pan=50, reverb=66, vol=88)
    s.channel('lead2', 'saw_lead', pan=80, reverb=66, vol=66)
    s.channel('sq', 'square_lead', pan=34, reverb=60, vol=54)
    s.channel('stab', 'synth_brass', pan=72, reverb=80, vol=84)
    s.channel('hit', 'orch_hit', pan=64, reverb=90, vol=72)
    s.channel('cal', 'calliope', pan=42, reverb=70, vol=78)
    s.channel('rise', 'sweep_pad', pan=64, reverb=100, vol=68)
    s.channel('timp', 'timpani', pan=64, reverb=75, vol=94)
    s.channel('choir', 'choir', pan=64, reverb=110, vol=62)
    s.channel('org', 'organ', pan=58, reverb=80, vol=60)
    s.detune('sbass2', 11)
    s.detune('lead2', -12)
    fight(s, shift=-3, hot=True)
    s.notes.append('The boss version of MUS-SHUFFLE-BATTLE: E minor, 184 BPM, timpani, choir, organ, 16th hats, the hook loud on the calliope.')
    return s
