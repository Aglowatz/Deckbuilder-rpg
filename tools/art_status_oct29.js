// Art import Oct 29, Part 5: docs/art/art_status_oct29.csv - Art ID, Status (In Game / Needs redo / Skipped), Where / reason - for the rows of
// docs/art/art_batch_oct28.csv delivered in batches 5-9 (CSV rows 75-164; the brief numbers them #87-164). Run: node tools/art_status_oct29.js
const fs = require('fs');
const path = require('path');
const ROOT = path.join(__dirname, '..');
const text = fs.readFileSync(path.join(ROOT, 'docs', 'art', 'art_batch_oct28.csv'), 'utf8');
const rows = [];
let row = [], field = '', quoted = false;
for (let i = 0; i < text.length; i++) {
	const c = text[i];
	if (quoted) {
		if (c === '"') { if (text[i + 1] === '"') { field += '"'; i++; } else quoted = false; } else field += c;
	} else if (c === '"') quoted = true;
	else if (c === ',') { row.push(field); field = ''; }
	else if (c === '\n') { row.push(field.replace(/\r$/, '')); rows.push(row); row = []; field = ''; }
	else field += c;
}
if (field || row.length) { row.push(field); rows.push(row); }
rows.shift();
// Where each delivered ID shows (or why not). Keys are catalogue Art IDs.
const WHERE = {
	'SPR-PRIMM': 'Primm in the Crease after his fall (freed-NPC entry, SPR-PRIMM set)',
	'SPR-DUMPWORKER': 'the three Dump farmhands, a slight tint each (HeapScene.WORKER_SET)',
	'DUMP-PROP-PRIMM-STATUE': 'delivered as CAPI-PROP-PRIMM-STATUE: the gold Primm on the plaza fountain',
	'STORY-CAPTURE': 'behind the pc_capture scene (castle gate)',
	'STORY-THRONE': 'behind ending beat "throne"',
	'STORY-WONDER': 'behind the "wonder" cutscene',
	'STORY-VACANCY': 'behind the "vacancy" cutscene',
	'STORY-SEVER': 'behind the "sever" cutscene',
	'STORY-MODEL-ROOM': 'behind the "primm_intro" cutscene',
	'STORY-KEPT-FACE': 'behind the "primm_reveal" cutscene',
	'STORY-FACADE-FALLS': 'behind ending beat "facade"',
	'STORY-CELL-4': 'behind the lab_cell4 scene',
	'STORY-FUNERAL': 'behind the royal_funeral scene',
	'STORY-HOME': 'behind the isla_homecoming scene',
	'STORY-MEMORY-1': 'behind memory fragment 1',
	'STORY-MEMORY-2': 'behind memory fragment 2',
	'STORY-MEMORY-3': 'behind memory fragment 3',
	'STORY-MEMORY-4': 'behind memory fragment 4',
	'N-10-REDO': 'delivered as N-10.png: replaced the Push Broom of Undeath',
	'COS-HAT-LEAFCROWN-SHEET': 'the Leaf Crown, re-split, hand fit (fit.json) in all five directions',
	'OF-HERO-CAVE-MOUTH': 'the Forgotten Cave mouth (lifted out of the dusk tint)',
	'OF-BD-TORCHLINE': 'kit card north of the clearing; the canopy hides it from the play camera',
	'OF-TREE-GIANT-SET': 'delivered as OF-TREE-GIANT-01/02/03: three giant trees beyond the treeline',
	'OF-PROP-LAB-HATCH': 'the postgame Lab hatch (ground picture)',
	'TOWN-BD-HORIZON': 'Crosspath skyline north',
	'TOWN-HERO-FOUNTAIN': 'the square\'s fountain (replaces the stone model)',
	'TOWN-SHEET-FREED-BANNERS': 'one banner per freed zone on the square\'s lamp posts (-01..-04; -05/-06 crest banners unused)',
	'GAIN-BD-HOUSE-OF-GAINS': 'Gainlands skyline north',
	'GAIN-HERO-HAMSTER-WHEEL': 'Mill Fields, replaces the 3D wheel',
	'GAIN-SHEET-FLOATING-ISLANDS': 'a painted islet beside each walkable island (-01..-03; rope pieces unused)',
	'GAIN-DEC-REGIME-POSTERS': 'four posters on the gym hall front',
	'DNA-BD-HALL-FACADE': 'D.N.A. skyline north',
	'DNA-SHEET-FILING-TOWERS': 'five towers in the farms and records (-01..-03); the queue post (-04)',
	'DNA-SHEET-GHOST-QUEUE': 'six ghosts queuing against a wall',
	'DNA-SHEET-PROPS': 'ghost lamps and dead topiary in the lobby, bank, mail room, breakroom',
	'DNA-DEC-FORMS': 'six floor decals in the hub',
	'BUFF-BD-CAKE-CATHEDRAL': 'Buffet skyline (replaces BUFF-BD-CAKE)',
	'BUFF-BD-TEST-KITCHEN': 'Buffet skyline north',
	'BUFF-SHEET-TASTING-STANDS': 'three stands with golem guards on the Pantry approach',
	'BUFF-DEC-ROSETTES': 'two rosettes on each kit building front',
	'DUMP-BD-ROTHEART-SKY': 'Dump skyline north (the baked-sky DUMP-BD-ROTHEART stays unused)',
	'DUMP-HERO-JUNK-MOUNTAIN': 'replaces the moss-lump model',
	'DUMP-HERO-THRONE-DUMPSTER': 'on the throne\'s top tier; from the approach mostly behind the raccoon king (top of the screen)',
	'DUMP-SHEET-ENTRANCE-FLAGS': 'pennants on the far landing posts (replace the blue triangles)',
	'DUMP-DEC-CORRUPTION': 'six ground decals at the throne and the root gate',
	'CAPI-BD-GREAT-WALL': 'Capital outskirts skyline either side of the wall',
	'CAPI-BD-CASTLE': 'Capital inside skyline north',
	'CAPI-DEC-LOST-PROPERTY': 'the painted notice on every lost-property board (-01)',
	'CAPI-SHEET-RIFTS': 'painted rifts in open tears (-01..-03), sealed stones (-04..-06)',
	'CAPI-PROP-STATUE-FALLEN': 'in the dry fountain after the ending',
	'CAP-PATH-WHITE': 'the Capital\'s white roads (same id)',
};
const out = ['Row,Art ID,Category,Status,Where / reason'];
const quote = (s) => /[",]/.test(s) ? `"${s.replace(/"/g, '""')}"` : s;
rows.forEach((r, index) => {
	const n = index + 1;
	if (n < 75 || n > 164 || !r[0]) return;
	const id = r[0], category = r[1];
	let status = 'In Game', where = WHERE[id] || '';
	if (category === 'Portrait expression') { status = 'Skipped'; where = 'not made (skipped by design, brief Oct 29)'; }
	else if (!where) {
		if (category === 'Card') where = 'card art: hand, zoom, Deck Station, packs (CardArt by ID)';
		else if (id.startsWith('ICON-GEAR-')) where = 'the relic\'s own icon: character screen, armory lists, reward box';
		else if (id.startsWith('ICON-FEAT-')) where = 'Menu > Feats group headings and rows, the unlock toast';
	}
	out.push([n, id, category, status, quote(where)].join(','));
});
fs.writeFileSync(path.join(ROOT, 'docs', 'art', 'art_status_oct29.csv'), out.join('\n') + '\n');
console.log(`${out.length - 1} rows; ${out.filter((l) => l.includes(',In Game,')).length} In Game, ${out.filter((l) => l.includes(',Skipped,')).length} Skipped`);
