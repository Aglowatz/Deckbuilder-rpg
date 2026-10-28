// Oct 27: exports every player-facing dialogue line to one CSV for editing, in story order.
//   node tools/export_dialogue.js [--out=docs/dialogue/edit_oct27.csv]
// Columns: ID (tools/dialogue_ids.js; the key tools/apply_dialogue_pass.js --csv understands), Zone/Area, Speaker, When it's heard,
// Current line, New line (empty: fill it to change the line). Also writes <out folder>/export_snapshot.json (id -> line at export), which
// the importer uses when a spreadsheet program has re-encoded the Current line column.
// Sources: data/story/*.tres (zone + intro story text; quiz questions and .speaker labels are data, not lines), data/story/story_scenes.json,
// data/story/old_well_story.json, data/npcs/npcs.json barks, data/encounters/boss_intros.json (title, line), data/encounters/
// encounter_scripts.json (text, line, banner, warn, name), data/dungeons/dungeon_content.json (text, event titles/bodies/choices, challenge
// titles/texts, blurbs) and the quest text in core/quests/quest_definitions.gd and zone_quest_definitions.gd (titles, summaries, objectives,
// where-to-go hints). core/data/story_beats.gd holds only scene ids and flags, so it adds no rows.
// Story order: Prologue, Crosspath (first visit), the four zones (gatekeeper, hub, side dungeon, main dungeon by node, after freeing),
// Crosspath between zones (memories, Cave Mouth, Old Well, secrets), the Capital, the Ending, the Postgame. Within a place, file order.
const fs = require('fs');
const path = require('path');
const { root, csvq, parseCsv, fileText, spansOf, gdLiterals, gdProse, locate, namedSlot } = require('./dialogue_ids');

const args = Object.fromEntries(process.argv.slice(2).map((a) => { const m = a.match(/^--([a-z-]+)(?:=(.*))?$/); return m ? [m[1], m[2] ?? true] : [a, true]; }));
const OUT = path.resolve(root, args.out || 'docs/dialogue/edit_oct27.csv');
const SNAPSHOT_DIR = OUT.replace(/\.csv$/, '');
const readJson = (f) => JSON.parse(fileText(f));

const CHAPTERS = ['Prologue (Opening Forest)', 'Crosspath (first visit)', 'Gainlands', 'Endless Buffet', 'D.N.A.', 'Verdant Dump',
	'Crosspath (between zones)', 'The Capital', 'Ending', 'Postgame'];
const PATH_CH = { beefcake: 2, gourmand: 3, necrocrat: 4, refusemancer: 5, final: 7 };
const ZONE_FILE_CH = { 'gainlands_story.tres': 2, 'gourmand_story.tres': 3, 'dna_story.tres': 4, 'refusemancer_story.tres': 5, 'capital_story.tres': 7 };
// Where each dungeon of dungeon_content.json sits: [chapter, phase] (phase 2 = side dungeon, 3 = main dungeon); Crosspath's secrets use node 6.
const DUNGEON_AT = { 'D-HOG': [2, 3], 'D-TTK': [3, 3], 'D-HFA': [4, 3], 'D-ROT': [5, 3], 'D-PC': [7, 3], 'D-LAB': [9, 3], 'S-IRON': [2, 2],
	'S-BEEF': [9, 2], 'S-GOUR': [3, 2], 'S-NECRO': [4, 2], 'S-REF': [5, 2], 'S-CAP': [7, 2], 'S-PASTE': [7, 2], 'S-TOWN': [6, 1] };
const MAIN_DUNGEON = { 2: 'D-HOG', 3: 'D-TTK', 4: 'D-HFA', 5: 'D-ROT', 7: 'D-PC' };
const SIDE_DUNGEON = { iron: 'S-IRON', beef: 'S-BEEF', gour: 'S-GOUR', necro: 'S-NECRO', ref: 'S-REF', cap: 'S-CAP', town: 'S-TOWN' };
const GATEKEEPER = { 'Brick Bronson': 'beefcake', 'Chef Fennel Gravois': 'gourmand', 'Prudence Pallor': 'necrocrat', 'Moss Mulligan': 'refusemancer' };
const PATH_ZONE = { beefcake: 'Gainlands', gourmand: 'Endless Buffet', necrocrat: 'D.N.A.', refusemancer: 'Verdant Dump' };

const dungeons = Object.fromEntries(readJson('data/dungeons/dungeons.json').map((d) => [d.id, d]));
const content = readJson('data/dungeons/dungeon_content.json');
const npcs = readJson('data/npcs/npcs.json');
const npcName = Object.fromEntries(npcs.map((n) => [n.id, n.name]));
const nodeName = (d, n) => ((dungeons[d] && dungeons[d].nodes.find((x) => x.n === Number(n))) || {}).name || `node ${n}`;
const dungeonName = (d) => (dungeons[d] || {}).name || d;
const h = (s) => s.replace(/[._]/g, ' ').trim();

// ---------- rows ----------
// Sort tuple: chapter, phase (0 gatekeeper, 1 hub/arrival, 2 side dungeon, 3 main dungeon, 4 after freeing), node, sub, then source order.
const rows = [];
let seq = 0;
function add(r) { rows.push({ phase: 1, node: 0, sub: 5, ...r, seq: seq++ }); }

// Speakers from the Oct 21 export (same keys), then .speaker labels in the story files, then key rules.
const priorSpeaker = new Map();
const priorDir = path.join(root, 'docs/dialogue/chatgpt_pass_oct21');
for (const f of fs.readdirSync(priorDir).filter((x) => /^batch_.*_done\.csv$/.test(x))) {
	for (const r of parseCsv(fs.readFileSync(path.join(priorDir, f), 'utf8'))) {
		if (r.speaker && !/^\(check key\)$/.test(r.speaker)) priorSpeaker.set(r.id.replace(/::\d+$/, ''), r.speaker);
	}
}
function npcFor(word) {
	const w = word.toLowerCase();
	const n = npcs.find((x) => x.id.toLowerCase().endsWith('-' + w)) || npcs.find((x) => x.name.toLowerCase().split(/[ ,]+/).includes(w));
	return n ? n.name : null;
}
const SPEAKER_RULES = [
	[/^town\.elder\./, 'Elder Maren'], [/^storeroom\.wanderer/, 'The Wanderer'], [/^storeroom\.(before|challenge|after_win|after_loss)/, 'The Store Room Ghosts'],
	[/^storeroom\./, '(narration)'], [/^(town\.hidden_vendor|pack\.black_market)/, 'Fig Sly'], [/^npc\.minigame\./, '(minigame host)'],
	[/^ambient\.gym_attendant/, 'Gym attendant'], [/^npc\.gate\./, '(gate golem)'], [/^boss\.phase\./, '(battle UI)'],
	[/^(town\.name|memory\.(title_format|hint)|zone\.complete|travel\.\w+\.ask|wheel\.|growth\.|grow\.|ruler\.statue|capital\.castle)/, '(narration/UI)'],
];
const UI_KEYS =/^(hud|ui|fx|sign|prop|poster|memo|effect|debuff|travel\.(title|subtitle|here|locked|warning|button|close|prompt|sign)|arena\.screen|pack\.hint|shrine|gate\.(ingredient|quest|battle)|end\.marker|boon|still)\b/;

// ---------- quest titles (for "When it's heard") ----------
const questTitle = {};
for (const file of ['core/quests/quest_definitions.gd', 'core/quests/zone_quest_definitions.gd']) {
	const text = fileText(file);
	for (const m of text.matchAll(/static func (_\w+)\(\)[^\n]*\n(?:[^\n]*\n){0,6}?\s*quest\.title = "([^"]*)"/g)) questTitle[gdQuestId(m[1])] = m[2];
	for (const m of text.matchAll(/_side\(SIDE_(\w+), "[^"]*", \d+, "([^"]*)"/g)) questTitle[`side_s_${m[1].toLowerCase()}`] = m[2];
	for (const m of text.matchAll(/\n\t"(\w+)": \{\n\t\t"title": "([^"]*)"/g)) questTitle[`main_${m[1]}`] = m[2];
}
function gdQuestId(fn) {
	const special = { _armory: 'some_assembly_required', _backlog: 'dna_backlog', _onboarding: 'dna_onboarding', _audit: 'dna_audit', _oldest_trick: 'oldest_trick',
		_four_seals: 'four_seals', _fragments: 'fragments' };
	return special[fn] || fn.replace(/^_/, '');
}
const qt = (id) => (questTitle[id] ? `"${questTitle[id]}"` : `"${h(id)}"`);
const QUEST_STAGE = { offer: 'when offered', active: 'while it is active', ready: 'handing it in', done: 'after it is done', offer_pack: 'when offered (pack step)',
	active_pack: 'while active (pack step)' };
const QUEST_GIVER = {};
{
	const zq = fileText('core/quests/zone_quest_definitions.gd');
	const givers = zq.match(/const GIVERS: Dictionary = \{([\s\S]*?)\n\}/)[1];
	for (const m of givers.matchAll(/"(\w+)": \["(\w+)", "(\w+)"\]/g)) QUEST_GIVER[m[1]] = [m[2], m[3]];
}
function questChapter(id) {
	if (/^main_(\w+)$/.test(id)) return [PATH_CH[id.slice(5)], 0];
	if (id === 'side_s_beef') return [9, 2];
	if (id === 'side_s_town' || ['oldest_trick', 'four_seals', 'fragments'].includes(id)) return [6, 1];
	const g = QUEST_GIVER[id];
	if (g) return [g[0] === 'town' ? 1 : PATH_CH[g[0]], /^side_/.test(id) ? 2 : 1];
	return [1, 1];
}

// ---------- describing a story key ----------
function when(key, speaker = '') {
	let m;
	const named = speaker && !speaker.startsWith('(') ? speaker.split(/, | \(/)[0] : null;
	const freed = /\.freed\b/.test(key) ? ' (after the zone is freed)' : '';
	const k = key.replace(/\.freed\b/, '');
	if (k === 'awakening_lines') return 'Prologue: waking up in the forest';
	if ((m = k.match(/^town\.(\w+)\.?(.*)$/)) && named) return `Talking to ${named} in Crosspath${m[2] ? ` (${h(m[2])})` : ''}`;
	if ((m = k.match(/^(\w+?)_npc_(intro|victory|defeat)_lines$/))) return `Gatekeeper of the ${PATH_ZONE[m[1]]}: ${{ intro: 'before the battle', victory: 'after you win', defeat: 'after you lose' }[m[2]]}`;
	if ((m = k.match(/^(\w+?)_(intro|return|victory|defeat)_lines$/))) return `${h(m[1])}: ${{ intro: 'first meeting / before the battle', return: 'later visits', victory: 'after you win', defeat: 'after you lose' }[m[2]]}`;
	if ((m = k.match(/^quest\.(\w+)\.(\w+)$/)) && QUEST_STAGE[m[2]]) return `Quest ${qt(m[1])}: ${QUEST_STAGE[m[2]]}${freed}`;
	if ((m = k.match(/^quest\.(\w+)$/))) return `Quest ${qt(m[1])}`;
	if ((m = k.match(/^sign\.(.+)$/))) return `Reading a sign: ${h(m[1])}${freed}`;
	if ((m = k.match(/^fx\.(.+)$/))) return `Pop-up message: ${h(m[1])}${freed}`;
	if ((m = k.match(/^prop\.(.+)$/))) return `Examining: ${h(m[1])}${freed}`;
	if ((m = k.match(/^(hud|ui)\.(.+)$/))) return `${m[1] === 'hud' ? 'HUD objective' : 'Screen text'}: ${h(m[2])}${freed}`;
	if ((m = k.match(/^npc\.([a-z0-9]+)_?(\w*)\.?(.*)$/))) { const who = named || npcFor(m[1]) || h(m[1] + (m[2] ? '_' + m[2] : '')); return `Talking to ${who}${m[3] ? ` (${h(m[3])})` : ''}${freed}`; }
	if ((m = k.match(/^freed_npc\.(.+)$/))) return `After freeing: ${npcFor(m[1]) || h(m[1])} talks`;
	if ((m = k.match(/^dungeon\.(\w+)\.(before|after|title|blurb)$/))) return `Dungeon node "${h(m[1])}": ${{ before: 'entering the node', after: 'after the node', title: 'map title', blurb: 'map description' }[m[2]]}`;
	if ((m = k.match(/^event\.(\w+)\.(.+)$/))) return `Dungeon event "${h(m[1])}": ${h(m[2])}`;
	if ((m = k.match(/^challenge\.(\w+)\.(.+)$/))) return `Deck challenge "${h(m[1])}": ${h(m[2])}`;
	if ((m = k.match(/^cutscene\.(\w+)\.(\d+)$/))) return `Cutscene "${h(m[1])}", beat ${m[2]}`;
	if ((m = k.match(/^memory\.(\d)\.(.+)$/))) return `Memory ${m[1]} (after ${m[1]} zone${m[1] === '1' ? '' : 's'} freed): ${h(m[2])}`;
	if ((m = k.match(/^still\.(.+)$/))) return `Story still caption: ${h(m[1])}`;
	if ((m = k.match(/^gate\.(beefcake|necrocrat|gourmand|refusemancer)\.?(.*)$/))) return `Gatekeeper of the ${PATH_ZONE[m[1]]}: ${m[2] ? h(m[2]) : 'talking at the gate'}`;
	if ((m = k.match(/^ending\.(.+)$/))) return `Ending: ${h(m[1])}`;
	if ((m = k.match(/^(\w+)\.(.+)$/))) return `${h(m[1])[0].toUpperCase() + h(m[1]).slice(1)}: ${h(m[2])}${freed}`;
	return h(k);
}

function speakerFor(file, key, speakerLabels) {
	const prior = priorSpeaker.get(`${file}::${key}`);
	if (prior) return prior;
	// A variant key (cutscene.primm_p2.2.gourmand) speaks with its parent's label.
	const label = speakerLabels.get(key) ?? speakerLabels.get(key.replace(/\.[a-z_]+$/, ''));
	if (label) return label === 'You' ? 'The Wanderer' : label;
	let m;
	for (const [re, who] of SPEAKER_RULES) if (re.test(key)) return who;
	if (UI_KEYS.test(key)) return '(narration/UI)';
	if ((m = key.match(/^(?:npc|freed_npc)\.([a-z0-9]+)/)) && npcFor(m[1])) return npcFor(m[1]);
	if ((m = key.match(/^quest\.(\w+)\./)) && QUEST_GIVER[m[1]]) return npcFor(QUEST_GIVER[m[1]][1]) || '(quest giver)';
	if (/^quest\./.test(key)) return 'Elder Maren';
	if (/^(dungeon|event|challenge|enemy)\./.test(key)) return '(narration)';
	return '(check key)';
}

// ---------- 1. story .tres files ----------
// Inverse dungeon maps: story key -> [dungeon, node], cutscene name -> [dungeon, node, before|after].
const storyKeyNode = {}, sceneNode = {}, talkNode = {};
for (const [d, x] of Object.entries(content.dungeons)) {
	for (const [n, k] of Object.entries(x.story_keys || {})) storyKeyNode[k] = [d, Number(n)];
	for (const [n, s] of Object.entries(x.scenes || {})) for (const [when_, name] of Object.entries(s)) sceneNode[name] = [d, Number(n), when_];
	for (const [n, s] of Object.entries(x.talks || {})) for (const [when_, name] of Object.entries(s)) talkNode[name] = [d, Number(n), when_];
}
const STILL_CH = { wake: [0, 1, 0], flex: [2, 3, 13], doppel: [3, 3, 13], approval: [4, 3, 14], rotheart: [5, 3, 13], primm: [7, 3, 10], reunion: [8, 1, 0] };

function introPlace(key) {
	let m;
	if (/^(awakening_lines|prologue\.|start\.|tutorial\.|cave_mouth\.)/.test(key)) return { ch: 0 };
	if ((m = key.match(/^(beefcake|gourmand|refusemancer|necrocrat)_npc_(intro|victory|defeat)/))) return { ch: PATH_CH[m[1]], phase: 0, sub: { intro: 1, victory: 4, defeat: 5 }[m[2]] };
	if ((m = key.match(/^gate\.(beefcake|gourmand|refusemancer|necrocrat)/))) return { ch: PATH_CH[m[1]], phase: 0, sub: 0 };
	if ((m = key.match(/^still\.(\w+)/)) && STILL_CH[m[1]]) { const [ch, phase, node] = STILL_CH[m[1]]; return { ch, phase, node, sub: 8 }; }
	if ((m = key.match(/^memory\.(\d)\./))) return { ch: 6, node: Number(m[1]), sub: 1 };
	if (/^(memory\.|zone\.complete)/.test(key)) return { ch: 6, node: 0 };
	if (/^graveyard_/.test(key)) return { ch: 6, node: 6 };
	if (/^capital\./.test(key)) return { ch: 7 };
	if (/postgame/.test(key)) return { ch: 9 };
	if ((m = key.match(/^town\.elder\.(?:idle|progress)\.(\d)/))) return { ch: 6, node: Number(m[1]) };
	return { ch: 1 };
}
function zonePlace(file, key) {
	const ch = ZONE_FILE_CH[file];
	if (ch === 7 && /^(ending\.postgame|postgame)/.test(key)) return { ch: 9 };
	if (ch === 7 && /^(ending\.|freed_npc\.|fx\.ending|end\.marker|cutscene\.primm_reveal)/.test(key)) return { ch: 8 };
	if (/^(dungeon|challenge|event|cutscene|boss|boon)\./.test(key)) return { ch, phase: 3 };
	if (/\.freed\b|^freed_npc\.|^ruler\.statue/.test(key)) return { ch, phase: 4 };
	if (/^quest\.side_/.test(key)) return { ch, phase: 2 };
	return { ch };
}
function storyFiles() {
	for (const f of fs.readdirSync(path.join(root, 'data/story')).filter((x) => x.endsWith('.tres')).sort()) {
		const file = `data/story/${f}`;
		const text = fileText(file);
		const keys = [];
		const labels = new Map();
		let inDict = false;
		for (const line of text.split('\n')) {
			if (/^(lines|texts|quest_dialogue) = \{/.test(line)) { inDict = !line.trim().endsWith('{}'); continue; }
			if (/^[a-z_]+ = /.test(line)) inDict = false;
			let m = line.match(/^([a-z_]+_lines) = Array\[String\]\(\[/);
			if (m) { keys.push(m[1]); continue; }
			if (!inDict || !(m = line.match(/^"([A-Za-z0-9_.]+)": (\S)/))) continue;
			if (m[1].endsWith('.speaker')) { const loc = locate(`${file}::${m[1]}::0`); if (loc) labels.set(m[1].replace(/\.speaker$/, ''), loc.slots.map((s) => s.value).join(' / ')); continue; }
			if (m[2] === '"' || m[2] === '[') keys.push(m[1]);
		}
		if (!keys.length) continue;
		let lastNode = 0;
		for (const key of keys) {
			const loc = locate(`${file}::${key}::0`);
			if (!loc) throw new Error(`cannot locate ${file}::${key}`);
			const place = ZONE_FILE_CH[f] ? zonePlace(f, key) : introPlace(key);
			if (place.phase === 3) {
				// Main dungeon: the node of the story key or cutscene, else the node of the key above it.
				const dk = (key.match(/^(?:dungeon|event|challenge)\.(\w+)/) || [])[1];
				const cs = (key.match(/^cutscene\.(\w+)\./) || [])[1];
				if (dk && storyKeyNode[dk]) lastNode = storyKeyNode[dk][1];
				if (cs && sceneNode[cs]) lastNode = sceneNode[cs][1];
				if (place.node === undefined) place.node = lastNode;
				if (place.sub === undefined) place.sub = /\.after$/.test(key) || (cs && sceneNode[cs] && sceneNode[cs][2] === 'after') ? 7 : /\.before$/.test(key) ? 1 : 4;
			}
			if (place.phase === 3 && !place.area) place.area = MAIN_DUNGEON[place.ch];
			const speaker = speakerFor(file, key, labels);
			loc.slots.forEach((s, i) => add({ id: `${file}::${key}::${i}`, key, text: s.value, speaker, when: when(key, speaker), ...place }));
		}
	}
}

// ---------- 2. dungeon_content.json ----------
function dungeonContent() {
	const file = 'data/dungeons/dungeon_content.json';
	const text = content.text;
	for (const key of Object.keys(text)) {
		let place = { ch: 1 }, m, area = null;
		if ((m = key.match(/^quest\.side_s_(\w+)\./))) { const d = SIDE_DUNGEON[m[1]]; place = { ch: DUNGEON_AT[d][0], phase: DUNGEON_AT[d][1], node: d === 'S-TOWN' ? 6 : 0 }; }
		else if (/^(quest\.cap_|npc\.kestrel|fx\.old_tunnels)/.test(key)) place = { ch: 7, phase: /kestrel|old_tunnels/.test(key) ? 2 : 1 };
		else if ((m = key.match(/^dungeon\.dg_s_(\w+)_boss\.(before|after)$/))) { const d = SIDE_DUNGEON[m[1]]; place = { ch: DUNGEON_AT[d][0], phase: DUNGEON_AT[d][1], node: d === 'S-TOWN' ? 6 : 3, sub: m[2] === 'before' ? 1 : 7 }; area = d; }
		else if (/lab_/.test(key)) { place = { ch: 9, phase: 3, node: 11, sub: 4 }; area = 'D-LAB'; }
		const loc = locate(`${file}::${key}::0`);
		const speaker = /^quest\.side_s_(\w+)\./.test(key) ? (npcFor(QUEST_GIVER[key.split('.')[1]] ? QUEST_GIVER[key.split('.')[1]][1] : '') || '(quest giver)')
			: priorSpeaker.get(`${file}::${key}`) || (/^(event|dungeon|fx)\./.test(key) ? '(narration)' : 'Elder Maren');
		loc.slots.forEach((s, i) => add({ id: `${file}::${key}::${i}`, key, text: s.value, speaker: priorSpeaker.get(`${file}::${key}`) || speaker, when: when(key), area, ...place }));
	}
	for (const [d, x] of Object.entries(content.dungeons)) {
		const [ch, phase] = DUNGEON_AT[d] || [9, 2];
		const base = (n) => ({ ch, phase, node: d === 'S-TOWN' ? 6 : Number(n), area: d });
		const one = (key, sub, speaker, w, n) => {
			const loc = locate(`${file}::${key}::0`);
			if (!loc) return;
			loc.slots.forEach((s, i) => add({ id: `${file}::${key}::${i}`, key, text: s.value, speaker, when: w, ...base(n), sub }));
		};
		for (const [n, b] of Object.entries(x.blurbs || {})) if (typeof b === 'string') one(`dungeons/${d}/blurbs/${n}`, 0, '(narration/UI)', `${dungeonName(d)}, "${nodeName(d, n)}": map description`, n);
		for (const [n, ev] of Object.entries(x.events || {})) {
			if (ev.ref) continue;
			const at = `${dungeonName(d)}, "${nodeName(d, n)}"`;
			one(`dungeons/${d}/events/${n}/title`, 4, '(narration/UI)', `${at}: event title`, n);
			one(`dungeons/${d}/events/${n}/body`, 4, '(narration)', `${at}: event text`, n);
			(ev.choices || []).forEach((c, ci) => {
				for (const idx of [0, 1]) {
					add({ id: `${file}::dungeons/${d}/events/${n}/choices/${ci}::${idx}`, key: `dungeons/${d}/events/${n}/choices/${ci}`, text: c[idx], speaker: idx ? '(narration)' : '(choice button)',
						when: `${at}: choice ${ci + 1} ${idx ? 'outcome' : 'button'}`, ...base(n), sub: 4 });
				}
			});
		}
		for (const [n, c] of Object.entries(x.challenges || {})) {
			if (c.ref) continue;
			const at = `${dungeonName(d)}, "${nodeName(d, n)}"`;
			one(`dungeons/${d}/challenges/${n}/title`, 4, '(narration/UI)', `${at}: deck challenge title`, n);
			one(`dungeons/${d}/challenges/${n}/text`, 4, '(narration)', `${at}: deck challenge text`, n);
		}
	}
}

// ---------- 3. story_scenes.json ----------
const SCENE_PLACE = [
	[/^quota_fled/, { ch: 2, phase: 4 }], [/^crumb_fled/, { ch: 3, phase: 4 }], [/^clipwell_fled/, { ch: 5, phase: 4 }],
	[/^(quota_yards|clipwell_lawn|plume_ribbon|hob_final)/, { ch: 7 }], [/^(maren|wren)_after_capture/, { ch: 7, phase: 4 }],
	[/^cave_mouth_(\d)/, (m) => ({ ch: 6, node: Number(m[1]), sub: 6 })], [/^hob_town_(funeral|after_funeral)/, { ch: 8 }], [/^hob_town_freed/, { ch: 6 }],
	[/^hob_(town|wake)/, { ch: 1 }], [/^hob_(beefcake|necrocrat|gourmand|refusemancer)(_freed)?/, (m) => ({ ch: PATH_CH[m[1]], phase: m[2] ? 4 : 1 })],
	[/^(isla_|royal_funeral|brannoch_isla)/, { ch: 8 }], [/^lab_/, { ch: 9, phase: 3 }],
];
function storyScenes() {
	const file = 'data/story/story_scenes.json';
	const scenes = readJson(file).scenes;
	for (const [name, scene] of Object.entries(scenes)) {
		let place = { ch: 7 };
		const talk = talkNode[name] || talkNode[name.replace(/_alone$/, '')]; // the "alone" variant plays at the same node
		if (talk) { const [ch, phase] = DUNGEON_AT[talk[0]]; place = { ch, phase, node: Number(talk[1]), sub: talk[2] === 'before' ? 2 : 6, area: talk[0] }; }
		else for (const [re, p] of SCENE_PLACE) { const m = name.match(re); if (m) { place = typeof p === 'function' ? p(m) : { ...p }; break; } }
		const at = talk ? `${dungeonName(talk[0])}, "${nodeName(talk[0], talk[1])}": ${talk[2]} the node` : h(name);
		scene.steps.forEach((step, n) => {
			if (step[0] === '@set') return;
			const speaker = step[0] === '' ? '(narration)' : step[0] === 'NPC-PLAYER' ? 'The Wanderer' : step[0] === 'NPC-ELOWEN' ? 'The Rescuer (Elowen)' : npcName[step[0]] || step[0];
			for (let i = 1; i < step.length; i++) add({ id: `${file}::scenes/${name}/steps/${n}::${i}`, key: `scenes/${name}/steps/${n}`, text: step[i], speaker, when: `Scene "${h(name)}" (${at}), step ${n + 1}`, ...place });
		});
	}
}

// ---------- 4. battles: boss_intros.json, encounter_scripts.json ----------
const foeAt = {};
for (const [d, x] of Object.entries(content.dungeons)) for (const [n, f] of Object.entries(x.foes || {})) foeAt[typeof f === 'string' ? f : f.name] = [d, Number(n)];
const BATTLE_PLACE = {
	'Hollow Warden': { ch: 0, node: 9 }, 'The Restless Dead': { ch: 6, node: 6 }, 'Shiro Swindle': { ch: 6, node: 6 }, 'The Warden of the Four Seals': { ch: 6, node: 6 },
	"The Wellspring's Echo": { ch: 6, node: 5 }, 'Captain Spotless': { ch: 7 }, Primm: { ch: 7, phase: 3, node: 10, area: 'D-PC' }, 'Announcer Grand Bellows': { ch: 1 },
	'Colonel Casserole': { ch: 3 }, 'town:graveyard': { ch: 6, node: 6 }, 'town:ninja': { ch: 6, node: 6 }, 'town:vault': { ch: 6, node: 6 }, 'town:old_well': { ch: 6, node: 5 },
	'zone:gourmand:casserole': { ch: 3 }, 'zone:final:spotless': { ch: 7 }, 'capital:quota': { ch: 7 },
};
function battlePlace(name) {
	const base = name.replace(/ \((\w+)\)$/, '');
	let m;
	if (GATEKEEPER[base]) return { ch: PATH_CH[GATEKEEPER[base]], phase: 0 };
	if ((m = base.match(/^town:npc:(\w+)$/))) return { ch: PATH_CH[m[1]], phase: 0 };
	if (/^arena:/.test(base)) return { ch: 1 };
	if (BATTLE_PLACE[base]) return { ...BATTLE_PLACE[base] };
	const hit = foeAt[base] || Object.entries(foeAt).find(([k]) => k.split(/, | - /)[0] === base.split(/, | - /)[0])?.[1];
	if (hit) { const [ch, phase] = DUNGEON_AT[hit[0]]; return { ch, phase, node: hit[0] === 'S-TOWN' ? 6 : hit[1], area: hit[0] }; }
	return { ch: 1 };
}
function battles() {
	const intros = 'data/encounters/boss_intros.json';
	for (const [name, b] of Object.entries(readJson(intros))) {
		if (name === '_about') continue;
		for (const field of ['title', 'line']) {
			if (typeof b[field] !== 'string') continue;
			add({ id: `${intros}::${name}/${field}::0`, key: `${name}/${field}`, text: b[field], speaker: field === 'line' ? name : '(name card)',
				when: `Boss intro before the battle with ${name}: ${field === 'line' ? 'opening line' : 'title under the name card'}`, ...battleRow(name, 2) });
		}
	}
	const scripts = 'data/encounters/encounter_scripts.json';
	const FIELD = { name: 'event name', text: 'what can happen (rule text)', warn: 'warning the turn before', line: 'the foe says it when the event fires', banner: 'banner: what just happened' };
	for (const [foe, list] of Object.entries(readJson(scripts))) {
		if (foe === '_about') continue;
		const who = foe.includes(':') ? battleSpeaker(foe) : foe;
		list.forEach((t, i) => {
			for (const field of ['name', 'text', 'warn', 'line', 'banner']) {
				if (typeof t[field] !== 'string') continue;
				add({ id: `${scripts}::${foe}/${i}/${field}::0`, key: `${foe}/${i}/${field}`, text: t[field], speaker: field === 'line' ? who : '(battle UI)',
					when: `Mid-fight event "${t.name}" vs ${who}: ${FIELD[field]}`, ...battleRow(foe, 3) });
			}
		});
	}
}
// Dungeon and gatekeeper battles sort by sub (intro 2, mid-fight 3); the others follow the talk that starts them.
const BATTLE_AFTER = { 'Hollow Warden': 'tutorial.warden.before', 'Announcer Grand Bellows': 'town.arena.intro', 'The Restless Dead': 'graveyard_intro_lines',
	'town:graveyard': 'graveyard_intro_lines' };
function battleRow(name, sub) {
	const place = battlePlace(name);
	const m = name.match(/^arena:(\w+)$/);
	const after = BATTLE_AFTER[name] || (m && `arena.${m[1]}`);
	return { ...place, sub: place.phase === 0 || place.phase >= 2 ? sub : 8 + sub / 10, anchor: after ? { key: after, after: true } : null };
}
function battleSpeaker(key) {
	const fixed = { 'town:graveyard': 'The Restless Dead', 'town:ninja': 'Shiro Swindle', 'town:vault': 'The Warden of the Four Seals', 'town:old_well': "The Wellspring's Echo",
		'zone:gourmand:casserole': 'Colonel Casserole', 'zone:final:spotless': 'Captain Spotless', 'capital:quota': 'Vivienne Quota' };
	let m;
	if (fixed[key]) return fixed[key];
	if ((m = key.match(/^town:npc:(\w+)$/))) return Object.keys(GATEKEEPER).find((n) => GATEKEEPER[n] === m[1]);
	if ((m = key.match(/^arena:(\w+)$/))) return `Arena challenger (${h(m[1].replace(/^arena_/, ''))})`;
	return key;
}

// ---------- 5. Old Well, NPC barks ----------
function oldWell() {
	const file = 'data/story/old_well_story.json';
	const data = readJson(file);
	for (const [key, beats] of Object.entries(data.beats)) {
		beats.forEach((b, n) => b.lines.forEach((text, i) => add({ id: `${file}::beats.${key}.${n}::${i}`, key: `beats.${key}.${n}`, text,
			speaker: b.speaker === '' ? '(narration)' : b.speaker === 'You' ? 'The Wanderer' : b.speaker, when: `Old Well secret quest: ${h(key)}`, ch: 6, node: 5 })));
	}
	for (const [key, text] of Object.entries(data.text || {})) add({ id: `${file}::text.${key}::0`, key: `text.${key}`, text, speaker: '(narration/UI)', when: `Old Well secret quest: ${h(key)}`, ch: 6, node: 5 });
}
function barkChapter(loc) {
	if (/Lab/.test(loc)) return 9;
	if (/Swolympus/.test(loc)) return 9;
	if (/Forest|Forgotten Cave/.test(loc)) return 0;
	if (/^Gainlands|House of Gains/.test(loc)) return 2;
	if (/^Endless Buffet|Test Kitchen|Omakase/.test(loc)) return 3;
	if (/^D\.N\.A\.|Hall of Final|Waiting Room/.test(loc)) return 4;
	if (/^Verdant Dump|Rotheart|Trash Panda/.test(loc)) return 5;
	if (/^Capital|Primm|Memories/.test(loc)) return 7;
	if (/Vault|Graveyard/.test(loc)) return 6;
	return 1;
}
function barks() {
	const file = 'data/npcs/npcs.json';
	for (const n of npcs) {
		(n.barks || []).forEach((text, i) => add({ id: `${file}::${n.id}.barks::${i}`, key: `${n.id}.barks`, text, speaker: n.name,
			when: `Bark (speech bubble when you walk past ${n.name}; ${n.location})`, ch: barkChapter(n.location || ''), sub: 9 }));
	}
}

// ---------- 6. quest text in core/quests ----------
function quests() {
	for (const file of ['core/quests/quest_definitions.gd', 'core/quests/zone_quest_definitions.gd']) {
		const text = fileText(file);
		const counts = {};
		for (const lit of spansOf(file)) {
			if (!gdProse(lit)) continue;
			const i = counts[lit.scope] = (counts[lit.scope] ?? -1) + 1;
			const upto = text.slice(0, lit.start);
			const lineHead = lit.before;
			let qid = null, m;
			if (lit.scope === 'TARGETS' && (m = lineHead.match(/^\s*"(\w+)":/))) qid = m[1];
			else if (lit.scope === 'ZONE_MAIN_TEXT') qid = `main_${[...upto.matchAll(/\n\t"(\w+)": \{/g)].pop()[1]}`;
			else if (lit.scope === 'side_quests') qid = `side_s_${[...upto.matchAll(/_side\(SIDE_(\w+)/g)].pop()[1].toLowerCase()}`;
			else if (/^_/.test(lit.scope)) qid = gdQuestId(lit.scope);
			let field = 'objective';
			const fm = lineHead.match(/"(\w+)":\s*$/);
			if (/\.title\s*=\s*$/.test(lineHead) || (fm && fm[1] === 'title')) field = 'quest title';
			else if (/\.summary\s*=\s*$/.test(lineHead) || (fm && fm[1] === 'summary')) field = 'quest summary';
			else if (lit.scope === 'side_quests' && /_side\(/.test(lineHead)) field = (lineHead.match(/"[^"]*"/g) || []).filter((s) => / /.test(s)).length ? 'quest summary' : 'quest title';
			else if (lit.scope === 'TARGETS' || /\.at\(/.test(lineHead) || (fm && /_hint$/.test(fm[1]))) field = 'where to go (objective hint)';
			const [ch, phase] = qid ? questChapter(qid) : [1, 1];
			add({ id: `${file}::${lit.scope}::${i}`, key: lit.scope, text: lit.value, speaker: '(Quest Log)', when: `Quest Log, ${qt(qid || lit.scope)}: ${field}`,
				ch, phase, node: qid === 'side_s_town' || ['oldest_trick', 'four_seals'].includes(qid) ? 6 : 0, sub: 5, anchor: qid ? { key: `quest.${qid}.offer` } : null });
		}
	}
}

storyFiles();
dungeonContent();
storyScenes();
battles();
oldWell();
barks();
quests();

// Quest Log rows sit just before their quest's offer dialogue when there is one.
// Battle rows anchored "after" follow the last line of their key (or of the first key under that prefix).
const first = new Map(), last = new Map();
for (const r of rows) {
	if (r.anchor) continue;
	for (const k of [r.key, r.key.replace(/\.[^.]+$/, '')]) { if (!first.has(k)) first.set(k, r); last.set(k, r); }
}
for (const r of rows) {
	if (!r.anchor) continue;
	const a = (r.anchor.after ? last : first).get(r.anchor.key);
	if (a) Object.assign(r, { ch: a.ch, phase: a.phase, node: a.node, sub: a.sub, area: r.area || a.area, seq: a.seq + (r.anchor.after ? 0.5 : -0.5) + r.seq / 1e6 });
}
rows.sort((a, b) => a.ch - b.ch || a.phase - b.phase || a.node - b.node || a.sub - b.sub || a.seq - b.seq);

// Every id must lead back to its line (the importer depends on it).
const bad = [];
for (const r of rows) {
	const slot = namedSlot(locate(r.id));
	if (!slot || slot.value !== r.text) bad.push(r.id);
}
const ids = new Set();
for (const r of rows) { if (ids.has(r.id)) bad.push(`duplicate ${r.id}`); ids.add(r.id); }
if (bad.length) { console.error(`ids that do not round-trip:\n${bad.slice(0, 40).join('\n')}`); process.exit(1); }

const LOCKED = [/::npc\.fig\./, /::pack\.black_market/, /::pack\.hint\.gilded/, /::town\.hidden_vendor/, /V-FIGSLY\./];
const area = (r) => {
	const d = r.area && dungeonName(r.area);
	const phase = r.phase === 0 ? 'gatekeeper' : r.phase === 4 ? 'after freeing' : null;
	return [CHAPTERS[r.ch], d, !d && phase].filter(Boolean).join(' / ');
};
const header = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line'];
const lines = rows.map((r) => [r.id, area(r), r.speaker, LOCKED.some((re) => re.test(r.id)) ? `${r.when} [LOCKED: black market, never changed]` : r.when, r.text, ''].map(csvq).join(','));
fs.mkdirSync(path.dirname(OUT), { recursive: true });
fs.writeFileSync(OUT, '﻿' + header.map(csvq).join(',') + '\r\n' + lines.join('\r\n') + '\r\n');
fs.mkdirSync(SNAPSHOT_DIR, { recursive: true });
fs.writeFileSync(path.join(SNAPSHOT_DIR, 'export_snapshot.json'), JSON.stringify(Object.fromEntries(rows.map((r) => [r.id, r.text])), null, '\t') + '\n');

const per = {};
for (const r of rows) per[CHAPTERS[r.ch]] = (per[CHAPTERS[r.ch]] || 0) + 1;
const bySource = {};
for (const r of rows) { const f = r.id.split('::')[0]; bySource[f] = (bySource[f] || 0) + 1; }
console.log(`export_dialogue: ${rows.length} rows -> ${path.relative(root, OUT)}`);
console.log(Object.entries(per).map(([k, v]) => `  ${k}: ${v}`).join('\n'));
console.log(Object.entries(bySource).map(([k, v]) => `  ${k}: ${v}`).join('\n'));
const unknown = rows.filter((r) => r.speaker === '(check key)');
if (unknown.length) console.log(`  speaker unknown (check key): ${unknown.length}`);
const formula = rows.filter((r) => /^[=+\-@]/.test(r.text));
if (formula.length) console.log(`  lines starting with = + - @ (spreadsheets may read them as formulas): ${formula.length}`);
