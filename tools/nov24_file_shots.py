"""Fable Nov 24: files play-script shots into docs/overnight_shots/nov24b/ as JPEGs under a part prefix.
    python tools/nov24_file_shots.py <play folder name> <prefix> [name=newname ...]
With pairs, only those shots are filed (renamed); without, every PNG of the folder is filed as <prefix>_<its name>.jpg."""
import os
import sys

from PIL import Image

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), '..'))
OUT = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov24b')


def main():
    folder = os.path.join(ROOT, '_screenshots', 'play', sys.argv[1])
    prefix = sys.argv[2]
    pairs = [arg.split('=', 1) for arg in sys.argv[3:]]
    if not pairs:
        pairs = [[name[:-4], name[:-4]] for name in sorted(os.listdir(folder)) if name.endswith('.png')]
    os.makedirs(OUT, exist_ok=True)
    done = 0
    for source, target in pairs:
        path = os.path.join(folder, source + '.png')
        if not os.path.exists(path):
            print('missing: %s' % source)
            continue
        Image.open(path).convert('RGB').save(os.path.join(OUT, '%s_%s.jpg' % (prefix, target)), quality=88)
        done += 1
    print('%d shots filed as %s_*.jpg' % (done, prefix))


if __name__ == '__main__':
    main()
