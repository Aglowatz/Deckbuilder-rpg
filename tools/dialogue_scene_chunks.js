// Nov 13: splits the base export into scene-file skeletons, one per writing chunk (tier and group), for tools/dialogue_scene_build.js.
//   node tools/dialogue_scene_chunks.js --base=docs/dialogue/rewrite_nov13_base.csv --skip=docs/dialogue/rewrite_nov13_t1_ids.txt --out=docs/dialogue/rewrite_nov13/chunks
// Each skeleton lists every line of the chunk with its current text ("idx| text" under "@alias::key" headers, with the speaker and when it
// is heard as a comment). A writer edits the lines in place; lines left as they are count as kept. Rows in --skip (ids already rewritten)
// are shown as comments so the writer sees the scene whole. Locked rows (Fig Sly) and pure UI rows are left out.
const fs = require('fs');
const path = require('path');
const { root, parseCsv } = require('./dialogue_ids');
const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const rows = parseCsv(fs.readFileSync(path.resolve(root, args.base), 'utf8'));
const skip = new Set(args.skip ? args.skip.split(',').flatMap((f) => fs.readFileSync(path.resolve(root, f), 'utf8').split(/\r?\n/)).filter(Boolean) : []);
const ALIAS = [['data/story/intro_story.tres', 'intro'], ['data/story/capital_story.tres', 'capital'], ['data/story/gainlands_story.tres', 'gainlands'],
	['data/story/gourmand_story.tres', 'gourmand'], ['data/story/dna_story.tres', 'dna'], ['data/story/refusemancer_story.tres', 'refusemancer'],
	['data/story/story_scenes.json::', ''], ['data/encounters/boss_intros.json', 'boss'], ['data/encounters/encounter_scripts.json', 'enc'],
	['data/dungeons/dungeon_content.json', 'dc'], ['core/quests/quest_definitions.gd', 'qd'], ['core/quests/zone_quest_definitions.gd', 'zq'],
	['data/npcs/npcs.json', 'npc'], ['data/story/old_well_story.json', 'well']];
const shortKey = (id) => { const k = id.replace(/::\d+$/, ''); for (const [f, a] of ALIAS) if (k.startsWith(f)) return a + k.slice(f.length); return k; };
const LOCKED = [/::npc\.fig\./, /::pack\.black_market/, /::pack\.hint\.gilded/, /::town\.hidden_vendor/, /V-FIGSLY\./];
// Pure UI: rule text, buttons, titles, labels, names of things, quest log steps and targets (wayfinding), battle banners.
const UI = /\/(name|text|banner|warn|title)::\d+$|\.(title|button|name)::\d+$|::(ui|hud|effect|debuff|boss\.phase|pack\.hint|pack\.reward|arena\.screen|arena\.tier\.\d$|travel\.(title|here|button|close|prompt|operator|station\.[a-z]+\.name|locked\.name|unlock\.title)|memory\.(title_format|hint)|zone\.complete\.count|town\.(name|objective)|end\.marker|ending\.credits\.(3|4|5|6|7))|zone_quest_definitions\.gd::TARGETS|quest_definitions\.gd::|::(order|sort|recipe|match|puzzle|wheel|growth)\.(stations|dishes|bins|items|ingredients|pairs|souls|machines|wheel_names|intro|hint|clue)|::(quiz\.|reps\.intro|.*\.rules::)/;
const zoneOf = (z) => (z.startsWith('Gainlands') ? 'gainlands' : z.startsWith('Endless Buffet') ? 'buffet' : z.startsWith('D.N.A.') ? 'dna' : z.startsWith('Verdant Dump') ? 'dump'
	: z.startsWith('The Capital') || z === 'Ending' ? 'capital' : z.startsWith('Postgame') ? 'postgame' : 'town');
// Tier 4: the world (barks, signs, posters, memos, pop-ups, crowds). Tier 3: side content. Tier 2: everything else in a zone (the core cast).
const T4 = /npcs\.json::|::(sign|poster|memo|prop|fx|bark|enemy|ambient|shrine|facade|fortune|ruler\.statue)\.|::npc\.(guard_|exit_clerk|gate\.hint)|::travel\.(arrive|unlock|sign|dest|warning|subtitle|locked|station)|::(pack\.vendor\.(bought|poor|locked)|tailor\.)|\/blurbs\/|\.blurb::/;
const T3 = /::(npc\.(quiz|minigame|matching)|quiz|reps|order|sort|recipe|match|puzzle|wheel|growth|travel|arena|storeroom|town\.(vendor|item_vendor|equipment_vendor|pack_vendor|tailor|alchemist|arena)|equipment_vendor|quest\.armory|pack\.|graveyard|cardsharp|gate\.(ingredient|battle|quest)|grow\.)|old_well_story|side_s_|dg_s_|\/S-|S-GALLERY|D-LAB|lab_|postgame|gallery|town:(ninja|vault|old_well|graveyard)|arena:|Baron Quadzilla|Itamae|Betty Bones|Raccoon|Ancient Spotter|Automaton|Four Seals|Shiro|Restless|Wellspring|Announcer|Siphon|Failed Experiment|Drain Warden|cracks_in_the_glass|dungeons\/D-[A-Z]+\/events|\.choice\.|\.result\.|challenge\./;
const chunks = new Map();
let left = 0;
for (const r of rows) {
	if (LOCKED.some((re) => re.test(r.ID))) continue;
	if (UI.test(r.ID)) { left++; continue; }
	const zone = zoneOf(r['Zone/Area']);
	const tier = T4.test(r.ID) ? 4 : T3.test(r.ID) || zone === 'postgame' ? 3 : 2;
	const name = `t${tier}_${zone}`;
	if (!chunks.has(name)) chunks.set(name, []);
	chunks.get(name).push(r);
}
const out = path.resolve(root, args.out);
fs.mkdirSync(out, { recursive: true });
const summary = [];
for (const [name, list] of [...chunks].sort()) {
	const lines = [`# ${name}: ${list.length} lines. Edit the text after "idx| " in place; leave a line as it is to keep it.`,
		'# Lines starting "#= " were already rewritten in Tier 1 by the lead writer: read them for continuity, do not change them.', ''];
	let key = '';
	let todo = 0;
	for (const r of list) {
		const k = shortKey(r.ID);
		if (k !== key) { key = k; lines.push('', `@${k}`, `#   [${r.Speaker}] ${r["When it's heard"]}`); }
		const idx = r.ID.match(/::(\d+)$/)[1];
		if (skip.has(r.ID)) lines.push(`#= ${idx}| ${r['Current line']}`);
		else { lines.push(`${idx}| ${r['Current line']}`); todo++; }
	}
	fs.writeFileSync(path.join(out, name + '.txt'), lines.join('\n') + '\n');
	summary.push(`${name}: ${todo} to write (${list.length - todo} done in Tier 1)`);
}
console.log(summary.join('\n'));
console.log(`${left} pure UI rows left out`);
