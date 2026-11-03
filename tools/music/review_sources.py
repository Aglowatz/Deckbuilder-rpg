"""Copy the sources of reviewed tracks next to their MP3 previews (Gainlands rock Nov 3).

    python tools/music/review_sources.py "Gainlands rock" MUS-BEEF-BATTLE MUS-BEEF-EXP ...
Writes <Drive>/Music Review/<folder>/sources/: <ID>.mid (the full score), <ID>_score.py, and for rock-profile scores the two stems the
renderer synthesises separately, <ID>_guitars.mid (the amp-sim stem) and <ID>_band.mid (everything else). Run build.py first.
"""
import os
import shutil
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from build import load  # noqa: E402
from deliver import DRIVE  # noqa: E402


def main():
    folder, ids = sys.argv[1], sys.argv[2:]
    out = os.path.join(DRIVE, 'Music Review', folder, 'sources')
    os.makedirs(out, exist_ok=True)
    for id in ids:
        s = load(id)
        s.to_midi(os.path.join(out, f'{id}.mid'))
        src = os.path.join(HERE, 'scores', f'{id}.py')
        shutil.copy2(src, os.path.join(out, f'{id}_score.py'))
        extra = ''
        if s.profile == 'rock' and s.stem:
            s.to_midi(os.path.join(out, f'{id}_guitars.mid'), only=s.stem)
            s.to_midi(os.path.join(out, f'{id}_band.mid'), skip=s.stem)
            extra = ' + guitar/band stems'
        print(f'{id}: midi + score{extra}')
    for helper in ('_stingers.py', '_rock_a.py', '_rock_b.py', '_rock_c.py'):
        path = os.path.join(HERE, 'scores', helper)
        if os.path.exists(path):
            shutil.copy2(path, os.path.join(out, helper))
    for lib in ('rock.py',):
        shutil.copy2(os.path.join(HERE, 'lib', lib), os.path.join(out, f'lib_{lib}'))
    print('->', out)


if __name__ == '__main__':
    main()
