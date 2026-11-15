// Fable Nov 14: prints Maren's post-Path conversations before and after (from the dialogue pass's ledger and the game's text) as Markdown,
// for the report. node tools/nov14_maren_table.js > _logs/nov14/maren_before_after.md
const fs = require('fs');
const path = require('path');
const root = path.resolve(__dirname, '..');
const ledger = JSON.parse(fs.readFileSync(path.join(root, 'docs/dialogue/fable_nov14/applied_ledger.json'), 'utf8'));
const before = {};
for (const entry of Object.values(ledger)) before[entry.id] = entry.before;
const story = fs.readFileSync(path.join(root, 'data/story/intro_story.tres'), 'utf8');

function lines(key) {
	const at = story.indexOf('"' + key + '": [');
	if (at < 0) return [];
	const end = story.indexOf(']', at);
	return JSON.parse(story.slice(story.indexOf('[', at), end + 1));
}

const GROUPS = [
	['After the first Path (Fragment 1)', ['memory.1.intro', 'memory.1.after']],
	['After the second Path (Fragment 2)', ['memory.2.fragment', 'memory.2.after']],
	['After the third Path (Fragment 3)', ['memory.3.after']],
	['After the fourth Path (Fragment 4)', ['memory.4.fragment', 'memory.4.after', 'memory.4.reply', 'memory.4.after2']],
	['After the fourth Path, when Primm already told him (the rushed castle)', ['memory.4.after_known']],
];
const out = [];
for (const [title, keys] of GROUPS) {
	out.push('**' + title + '**', '', '| | Before | After |', '|---|---|---|');
	for (const key of keys) {
		const now = lines(key);
		now.forEach((text, index) => {
			const id = 'data/story/intro_story.tres::' + key + '::' + index;
			const was = before[id];
			const who = key.includes('fragment') ? 'memory' : key.includes('reply') ? 'Wanderer' : 'Maren';
			out.push('| ' + who + ' | ' + (was === undefined ? '(unchanged)' : was) + ' | ' + (was === undefined ? text : '**' + text + '**') + ' |');
		});
	}
	out.push('');
}
console.log(out.join('\n'));
