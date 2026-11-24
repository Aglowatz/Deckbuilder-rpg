"""Fable big pass Nov 23 (Part 7): the lines between dungeon map rooms follow the painted walkways.

For every dungeon with a painted map (data/dungeons/dungeons.json, postgame_dungeons.json; spots in map_layout.json):
  1. the walkway colours are learned from the picture itself: the colours on the room spots (the landings) and along the middle
     of every link (in these paintings a walkway runs more or less straight from landing to landing). Stone paving, a dirt path,
     a red carpet or a boardwalk: whatever is commonest there is 'paving' for that map;
  2. with --fit the room spots are fitted to the painted landings: a spot moves to the centre of the landing-coloured blob it
     stands on or beside (never further than SNAP of the picture's width);
  3. every link is traced: the cheapest route between its two spots over a cost map in which paving is cheap and everything
     else is dear; the route is thinned to a few points and smoothed;
  4. a link whose route leaves the paving for more than OFF_LIMIT of its length has NO painted walkway: it gets a tidy shallow
     arc instead and is listed (docs/art/map_walkways_missing.csv -> the Batch 21 redo rows).
Writes map_layout.json "curves": {dungeon: {"from>to" (room numbers): [[x, y], ...], "_missing": [...]}} and a check picture
per map in docs/overnight_shots/nov23b/maps/ (the picture, the spots, the curves; missing walkways in red).

    python tools/map_curves.py            trace, write the curves, draw the check pictures
    python tools/map_curves.py --fit      also move the spots onto the painted landings
    python tools/map_curves.py --check    only draw the check pictures from the data as it is
    python tools/map_curves.py --only=D-HOG,S-BEEF
"""
import csv
import heapq
import io
import json
import math
import os
import re
import sys

from PIL import Image, ImageDraw

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..')
LAYOUT = os.path.join(ROOT, 'data', 'dungeons', 'map_layout.json')
MAPS = os.path.join(ROOT, 'assets', 'art', 'maps')
OUT = os.path.join(ROOT, 'docs', 'overnight_shots', 'nov23b', 'maps')
MISSING = os.path.join(ROOT, 'docs', 'art', 'map_walkways_missing.csv')
MAP_IDS = {'D-SHUFFLE': 'MAP-DRAFT'}
GRID_W = 384
SNAP = 0.045
OFF_LIMIT = 0.40
OFF_COST = 14.0
SIMPLIFY = 0.007
WAY_SHARE = 0.5
WAY_BINS = 6
NUMBER = '-?[0-9.]+'
# A map whose walkways cannot be learned from the middle of its links (the Shuffled Halls: the red carpets cross under arches and
# the pavilions are every colour): the walkway colours given by hand (r, g, b).
WAY_COLOURS = {
    'D-SHUFFLE': [(176, 44, 62), (150, 34, 54), (198, 62, 76), (122, 26, 44), (212, 84, 92)],
}
DETOUR_LIMIT = 1.7
# A room that is never shown (the Halls' stage door, the run's hidden first step): its links get no line and no redo row.
HIDDEN_ROOMS = {'D-SHUFFLE': [1]}


def load_dungeons():
    result = {}
    for name in ('dungeons.json', 'postgame_dungeons.json'):
        rows = json.load(io.open(os.path.join(ROOT, 'data', 'dungeons', name), encoding='utf-8'))
        for row in rows:
            links = []
            hidden = set()
            for node in row.get('nodes', []):
                if node.get('hidden'):
                    hidden.add(int(node['n']))
                for nxt in node.get('next', []):
                    links.append((int(node['n']), int(nxt)))
            links = [(a, b) for a, b in links if a not in hidden and b not in hidden]
            result[row['id']] = {'links': links, 'map_id': row.get('map_id', ''), 'name': row.get('name', row['id'])}
    return result


def map_file(dungeon_id, info):
    for candidate in (MAP_IDS.get(dungeon_id, ''), info.get('map_id', ''), 'MAP-' + dungeon_id.replace('D-', ''), 'MAP-' + dungeon_id):
        if candidate and os.path.exists(os.path.join(MAPS, candidate + '.webp')):
            return candidate
    return ''


def colour_bin(r, g, b):
    """A coarse colour class: hue (24 steps), saturation (5), value (6)."""
    mx, mn = max(r, g, b), min(r, g, b)
    value = mx / 255.0
    sat = 0.0 if mx == 0 else (mx - mn) / float(mx)
    if mx == mn:
        hue = 0.0
    elif mx == r:
        hue = ((g - b) / float(mx - mn)) % 6.0
    elif mx == g:
        hue = (b - r) / float(mx - mn) + 2.0
    else:
        hue = (r - g) / float(mx - mn) + 4.0
    return (int(hue * 4.0) % 24, min(4, int(sat * 5.0)), min(5, int(value * 6.0)))


def near_bins(key):
    h, s, v = key
    for dh in (-1, 0, 1):
        for ds in (-1, 0, 1):
            for dv in (-1, 0, 1):
                yield ((h + dh) % 24, s + ds, v + dv)


def top_bins(counts, share, most):
    total = float(sum(counts.values())) or 1.0
    picked, covered = [], 0.0
    for key, count in sorted(counts.items(), key=lambda item: -item[1]):
        if covered >= share or len(picked) >= most:
            break
        picked.append(key)
        covered += count / total
    return picked


class Grid:
    def __init__(self, image, spots, links, way_colours=None):
        self.w = GRID_W
        self.h = int(round(GRID_W * image.size[1] / float(image.size[0])))
        small = image.convert('RGB').resize((self.w, self.h), Image.BILINEAR)
        px = small.load()
        bins = [[colour_bin(*px[x, y]) for x in range(self.w)] for y in range(self.h)]
        land_count, way_count = {}, {}
        for spot in spots.values():
            cx, cy = self.cell(spot)
            for dy in range(-3, 4):
                for dx in range(-4, 5):
                    x, y = cx + dx, cy + dy
                    if 0 <= x < self.w and 0 <= y < self.h:
                        land_count[bins[y][x]] = land_count.get(bins[y][x], 0) + 1
        for a, b in links:
            if str(a) not in spots or str(b) not in spots:
                continue
            ax, ay = self.cell(spots[str(a)])
            bx, by = self.cell(spots[str(b)])
            steps = max(abs(bx - ax), abs(by - ay), 1)
            for i in range(steps + 1):
                t = i / float(steps)
                if t < 0.3 or t > 0.7:
                    continue
                x, y = int(round(ax + (bx - ax) * t)), int(round(ay + (by - ay) * t))
                for dx, dy in ((0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)):
                    if 0 <= x + dx < self.w and 0 <= y + dy < self.h:
                        key = bins[y + dy][x + dx]
                        way_count[key] = way_count.get(key, 0) + 1
        land_bins = top_bins(land_count, 0.6, 5)
        if way_colours:
            strong = set(land_bins) | set(colour_bin(*colour) for colour in way_colours)
        else:
            strong = set(land_bins) | set(top_bins(way_count, WAY_SHARE, WAY_BINS))
        weak = set()
        for key in strong:
            weak.update(near_bins(key))
        land_near = set()
        for key in land_bins:
            land_near.update(near_bins(key))
        raw = [[1.0 if bins[y][x] in strong else (0.55 if bins[y][x] in weak else 0.0) for x in range(self.w)] for y in range(self.h)]
        self.land = [[bins[y][x] in land_near for x in range(self.w)] for y in range(self.h)]
        # the middle of a walkway is cheaper than its edge (a route should not hug the kerb): a cell is no more paving than the
        # mean of its neighbourhood
        self.pave = [[0.0] * self.w for _ in range(self.h)]
        for y in range(self.h):
            for x in range(self.w):
                if raw[y][x] <= 0.0:
                    continue
                total, count = 0.0, 0
                for dy in (-2, -1, 0, 1, 2):
                    yy = y + dy
                    if yy < 0 or yy >= self.h:
                        continue
                    row = raw[yy]
                    for dx in (-2, -1, 0, 1, 2):
                        xx = x + dx
                        if 0 <= xx < self.w:
                            total += row[xx]
                            count += 1
                self.pave[y][x] = min(raw[y][x], total / count)

    def cell(self, spot):
        return (min(self.w - 1, max(0, int(round(spot[0] * (self.w - 1))))), min(self.h - 1, max(0, int(round(spot[1] * (self.h - 1))))))

    def spot(self, cell):
        return [cell[0] / float(self.w - 1), cell[1] / float(self.h - 1)]

    def fit(self, spot):
        """The centre of the landing blob at or beside `spot`, or the spot itself."""
        start = self.cell(spot)
        reach = int(SNAP * self.w)
        best = None
        for radius in range(0, reach + 1):
            for dy in range(-radius, radius + 1):
                for dx in range(-radius, radius + 1):
                    if max(abs(dx), abs(dy)) != radius:
                        continue
                    x, y = start[0] + dx, start[1] + dy
                    if 0 <= x < self.w and 0 <= y < self.h and self.land[y][x]:
                        best = (x, y)
                        break
                if best:
                    break
            if best:
                break
        if not best:
            return spot, False
        seen = {best}
        stack = [best]
        limit = int(0.05 * self.w)
        while stack:
            x, y = stack.pop()
            for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                nx, ny = x + dx, y + dy
                if (nx, ny) in seen or not (0 <= nx < self.w and 0 <= ny < self.h):
                    continue
                if abs(nx - start[0]) > limit or abs(ny - start[1]) > limit or not self.land[ny][nx]:
                    continue
                seen.add((nx, ny))
                stack.append((nx, ny))
        if len(seen) < 40:
            return spot, False
        cx = sum(p[0] for p in seen) / float(len(seen))
        cy = sum(p[1] for p in seen) / float(len(seen))
        fitted = self.spot((cx, cy))
        if math.hypot(fitted[0] - spot[0], (fitted[1] - spot[1]) * self.h / self.w) > SNAP:
            return spot, False
        return [round(fitted[0], 3), round(fitted[1], 3)], True

    def route(self, a, b):
        start, goal = self.cell(a), self.cell(b)
        best = {start: 0.0}
        back = {}
        heap = [(0.0, start)]
        while heap:
            cost, at = heapq.heappop(heap)
            if at == goal:
                break
            if cost > best.get(at, 1e18):
                continue
            for dx in (-1, 0, 1):
                for dy in (-1, 0, 1):
                    if dx == 0 and dy == 0:
                        continue
                    nx, ny = at[0] + dx, at[1] + dy
                    if not (0 <= nx < self.w and 0 <= ny < self.h):
                        continue
                    total = cost + math.hypot(dx, dy) * (1.0 + OFF_COST * (1.0 - self.pave[ny][nx]))
                    if total < best.get((nx, ny), 1e18):
                        best[(nx, ny)] = total
                        back[(nx, ny)] = at
                        heapq.heappush(heap, (total, (nx, ny)))
        path = [goal]
        while path[-1] != start and path[-1] in back:
            path.append(back[path[-1]])
        path.reverse()
        off = sum(1 for (x, y) in path if self.pave[y][x] < 0.3) / float(max(1, len(path)))
        straight = math.hypot(goal[0] - start[0], goal[1] - start[1]) or 1.0
        detour = sum(math.hypot(path[i + 1][0] - path[i][0], path[i + 1][1] - path[i][1]) for i in range(len(path) - 1)) / straight
        return path, off, detour


def simplify(points, eps):
    if len(points) < 3:
        return points
    a, b = points[0], points[-1]
    far, index = 0.0, 0
    length = math.hypot(b[0] - a[0], b[1] - a[1]) or 1e-9
    for i in range(1, len(points) - 1):
        p = points[i]
        d = abs((b[0] - a[0]) * (a[1] - p[1]) - (a[0] - p[0]) * (b[1] - a[1])) / length
        if d > far:
            far, index = d, i
    if far <= eps:
        return [a, b]
    return simplify(points[:index + 1], eps)[:-1] + simplify(points[index:], eps)


def smooth(points, passes=1):
    for _ in range(passes):
        if len(points) < 3:
            return points
        out = [points[0]]
        for i in range(1, len(points) - 1):
            out.append([(points[i - 1][0] + 2 * points[i][0] + points[i + 1][0]) / 4.0, (points[i - 1][1] + 2 * points[i][1] + points[i + 1][1]) / 4.0])
        out.append(points[-1])
        points = out
    return points


def arc(a, b, bow=0.07):
    """A tidy shallow arc for a link the painting has no walkway for."""
    mx, my = (a[0] + b[0]) / 2.0, (a[1] + b[1]) / 2.0
    nx, ny = -(b[1] - a[1]), b[0] - a[0]
    side = -1.0 if ny > 0 else 1.0  # bow upward on the screen
    cx, cy = mx + nx * bow * side, my + ny * bow * side
    out = []
    for i in range(9):
        t = i / 8.0
        out.append([round((1 - t) ** 2 * a[0] + 2 * (1 - t) * t * cx + t * t * b[0], 4), round((1 - t) ** 2 * a[1] + 2 * (1 - t) * t * cy + t * t * b[1], 4)])
    return out


def draw_check(dungeon_id, name, image, spots, curves, missing):
    picture = image.convert('RGB').copy()
    w, h = picture.size
    draw = ImageDraw.Draw(picture, 'RGBA')
    for key, points in curves.items():
        xy = [(p[0] * w, p[1] * h) for p in points]
        red = key in missing
        draw.line(xy, fill=(20, 10, 30, 200), width=9, joint='curve')
        draw.line(xy, fill=(255, 70, 60, 255) if red else (120, 255, 255, 255), width=4, joint='curve')
    for number, spot in spots.items():
        x, y = spot[0] * w, spot[1] * h
        draw.ellipse([x - 13, y - 13, x + 13, y + 13], fill=(30, 20, 50, 230), outline=(255, 255, 255, 255), width=2)
        draw.text((x - 3 if len(str(number)) < 2 else x - 6, y - 6), str(number), fill=(255, 255, 255, 255))
    draw.rectangle([0, 0, 640, 26], fill=(0, 0, 0, 170))
    draw.text((8, 7), '%s  %s   cyan: follows the painting   red: no painted walkway (%d)' % (dungeon_id, name, len(missing)), fill=(255, 255, 255, 255))
    os.makedirs(OUT, exist_ok=True)
    picture.save(os.path.join(OUT, 'map_%s.jpg' % dungeon_id), quality=86)


def compact(text):
    """A point, a line of points and a list of link names each on one line (as the file was written by hand)."""
    text = re.sub(r'\[\s*(' + NUMBER + r'),\s*(' + NUMBER + r')\s*\]', r'[\1, \2]', text)
    text = re.sub(r'\[\s*((?:\[' + NUMBER + ', ' + NUMBER + r'\],?\s*)+)\]', lambda m: '[' + ' '.join(m.group(1).split()) + ']', text)
    text = re.sub(r'\[\s*((?:"[0-9]+>[0-9]+",?\s*)+)\]', lambda m: '[' + ' '.join(m.group(1).split()) + ']', text)
    return text


def main():
    args = {a.lstrip('-').split('=')[0]: (a.split('=', 1)[1] if '=' in a else 'true') for a in sys.argv[1:]}
    text = io.open(LAYOUT, encoding='utf-8', newline='').read()
    newline = '\r\n' if '\r\n' in text else '\n'
    layout = json.loads(text)
    dungeons = load_dungeons()
    curves_all = layout.get('curves', {}) if isinstance(layout.get('curves'), dict) else {}
    only = set(args['only'].split(',')) if 'only' in args else None
    report = []
    for dungeon_id, info in dungeons.items():
        if only and dungeon_id not in only:
            continue
        spots = layout.get(dungeon_id)
        map_id = map_file(dungeon_id, info)
        if not isinstance(spots, dict) or not map_id:
            continue
        image = Image.open(os.path.join(MAPS, map_id + '.webp'))
        if 'check' not in args:
            grid = Grid(image, spots, info['links'], WAY_COLOURS.get(dungeon_id))
            unpainted = set('%d>%d' % (int(pair[0]), int(pair[1])) for pair in layout.get('drawn_links', {}).get(dungeon_id, []))
            moved = 0
            if 'fit' in args:
                for number in list(spots.keys()):
                    fitted, ok = grid.fit(spots[number])
                    if ok and fitted != spots[number]:
                        spots[number] = fitted
                        moved += 1
            curves = {}
            missing = []
            for a, b in info['links']:
                if str(a) not in spots or str(b) not in spots or a in HIDDEN_ROOMS.get(dungeon_id, []) or b in HIDDEN_ROOMS.get(dungeon_id, []):
                    continue
                path, off, detour = grid.route(spots[str(a)], spots[str(b)])
                key = '%d>%d' % (a, b)
                if off > OFF_LIMIT or detour > DETOUR_LIMIT or key in unpainted:
                    curves[key] = arc(spots[str(a)], spots[str(b)])
                    missing.append(key)
                else:
                    points = smooth(simplify([grid.spot(c) for c in path], SIMPLIFY))
                    points[0], points[-1] = list(spots[str(a)]), list(spots[str(b)])
                    curves[key] = [[round(p[0], 4), round(p[1], 4)] for p in points]
            curves['_missing'] = missing
            curves_all[dungeon_id] = curves
            report.append('%-10s %-13s links %2d  painted %2d  missing %2d  spots moved %d' % (dungeon_id, map_id, len(info['links']), len(info['links']) - len(missing), len(missing), moved))
        entry = curves_all.get(dungeon_id, {})
        shown = {k: v for k, v in entry.items() if not k.startswith('_')}
        draw_check(dungeon_id, info['name'], image, spots, shown, set(entry.get('_missing', [])))
    if 'check' not in args:
        layout['curves'] = curves_all
        layout['_curves'] = "Fable big pass Nov 23 (tools/map_curves.py): per dungeon, the line of each link ('from>to' in room numbers) as points on the picture (0..1), traced along the painted walkway; '_missing' lists the links the painting has no walkway for (a tidy arc, and a Batch 21 redo row)."
        out = compact(json.dumps(layout, indent='\t', ensure_ascii=False))
        io.open(LAYOUT, 'w', encoding='utf-8', newline='').write(out.replace('\n', newline) + (newline if text.endswith('\n') else ''))
        with io.open(MISSING, 'w', encoding='utf-8', newline='') as handle:
            writer = csv.writer(handle)
            writer.writerow(['dungeon', 'name', 'map', 'from room', 'to room'])
            for dungeon_id, entry in curves_all.items():
                for key in entry.get('_missing', []):
                    info = dungeons.get(dungeon_id, {})
                    writer.writerow([dungeon_id, info.get('name', ''), map_file(dungeon_id, info), key.split('>')[0], key.split('>')[1]])
    print('\n'.join(report))
    print('check pictures: docs/overnight_shots/nov23b/maps/')


if __name__ == '__main__':
    main()
