#!/usr/bin/env bash
# Fable Nov 15 (Part 3): Crosspath round Pip Threadwell's shop, rendered large and cropped to the shop front. Usage: bash tools/pip_shot.sh <before|after>
cd "$(dirname "$0")/.."
tag="${1:-after}"
SHOT_RES=3200x1800 bash tools/shot.sh res://scenes/town.tscn "n15_pip_${tag}_wide" --pos=35.0,9.5 --size=3200x1800 --nohud=true --clean=true --wait=3 2>&1 | grep "saved\|SCRIPT ERROR"
python -c "
from PIL import Image
im=Image.open('_screenshots/n15_pip_${tag}_wide.png')
w,h=im.size
im.crop((int(w*0.40),int(h*0.47),int(w*0.64),int(h*0.74))).save('docs/overnight_shots/nov15/p3_pip_${tag}.png')
print(im.size)
"
