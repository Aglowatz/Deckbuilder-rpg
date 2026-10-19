// Daytime Oct 19, Part 6: adds a pre-filled row to docs/playtest/feedback_log.md from one F8 report folder (report.json written by
// app/feedback_report.gd). Fills date, version, area / quest step and the notes; guesses category and severity from the notes (correct
// them in the log). Skips a folder that is already logged. Usage:
//   node tools/feedback_row.js <report folder> [--reporter=Name] [--category=bug|confusion|balance|praise] [--severity=blocker|high|medium|low] [--log=<md>] [--dry]
// Loop cycle 4: a folder of report folders (an unzipped batch, or the game's feedback folder) logs every report not logged yet, oldest
// first; with no folder at all the game's own feedback folder (%APPDATA%/Deckbuilder-RPG/feedback) is used.
const fs = require('fs');
const path = require('path');

const CATEGORIES = ['bug', 'confusion', 'balance', 'praise'];
const SEVERITIES = ['blocker', 'high', 'medium', 'low'];
// First match wins; the order matters (a crash report that also says "love it" is a bug).
const GUESSES = [
	['bug', /\b(crash|crashed|froze|freez|stuck|soft.?lock|bug|broke|broken|glitch|error|can'?t (move|continue|leave)|lost (my )?(save|progress)|missing|wrong)/i],
	['confusion', /\b(confus|unclear|didn'?t know|don'?t know|where (do|am|is)|how (do|to)|what (do|does|is)|lost\b|no idea|not sure|explain)/i],
	['balance', /\b(too (hard|easy|slow|fast|strong|weak|long)|hard|easy|unfair|overpowered|op\b|grind|impossible|cheap|balance)/i],
	['praise', /\b(love|loved|fun|great|awesome|nice|cool|beautiful|charming|funny|enjoy)/i],
];
const BLOCKER = /\b(crash|crashed|froze|freez|soft.?lock|stuck|can'?t (move|continue|leave)|lost (my )?(save|progress))/i;

function parseArgs(argv) {
	const options = { folder: '', reporter: '', category: '', severity: '', log: '', dry: false };
	for (const arg of argv) {
		const m = arg.match(/^--([a-z]+)(?:=(.*))?$/);
		if (!m) options.folder = arg;
		else if (m[1] === 'dry') options.dry = true;
		else options[m[1]] = m[2] || '';
	}
	return options;
}

function guessCategory(notes, rating) {
	for (const [category, re] of GUESSES) if (re.test(notes)) return category;
	if (rating >= 4) return 'praise';
	return 'confusion';
}

function guessSeverity(category, notes) {
	if (category === 'praise') return '-';
	if (category === 'bug') return BLOCKER.test(notes) ? 'blocker' : 'high';
	return 'medium';
}

function cell(text) {
	return String(text || '').replace(/\r?\n+/g, ' ').replace(/\|/g, '/').trim();
}

function areaQuest(state) {
	const parts = [];
	parts.push(state.location_name || state.area || '?');
	if (state.quest && state.quest.title) parts.push(`${state.quest.title}${state.quest.step ? ': ' + state.quest.step : ''}`);
	return parts.join(' / ');
}

function nextId(log) {
	let highest = 0;
	for (const m of log.matchAll(/^\| F-(\d+) \|/gm)) highest = Math.max(highest, Number(m[1]));
	return `F-${String(highest + 1).padStart(3, '0')}`;
}

function main() {
	const options = parseArgs(process.argv.slice(2));
	if (!options.folder) {
		options.folder = path.join(process.env.APPDATA || '', 'Deckbuilder-RPG', 'feedback');
		console.log(`no folder given: reading ${options.folder}`);
	}
	if (!fs.existsSync(options.folder)) {
		console.error(`no such folder: ${options.folder}`);
		process.exit(1);
	}
	if (fs.existsSync(path.join(options.folder, 'report.json'))) {
		addRow(options, options.folder);
		return;
	}
	const batch = fs.readdirSync(options.folder).map((name) => path.join(options.folder, name))
		.filter((dir) => fs.existsSync(path.join(dir, 'report.json'))).sort();
	if (batch.length === 0) {
		console.error(`no report.json in ${options.folder} or its subfolders`);
		process.exit(1);
	}
	for (const dir of batch) addRow(options, dir);
}

function addRow(options, folder) {
	const reportPath = path.join(folder, 'report.json');
	const report = JSON.parse(fs.readFileSync(reportPath, 'utf8'));
	const state = report.state || {};
	const notes = cell(report.notes);
	const rating = Number(report.rating || 0);
	if (options.category && !CATEGORIES.includes(options.category)) throw new Error(`category must be one of ${CATEGORIES.join(', ')}`);
	if (options.severity && !SEVERITIES.includes(options.severity)) throw new Error(`severity must be one of ${SEVERITIES.join(', ')}`);
	const category = options.category || guessCategory(notes, rating);
	const severity = options.severity || guessSeverity(category, notes);
	const logPath = options.log || path.join(__dirname, '..', 'docs', 'playtest', 'feedback_log.md');
	const log = fs.readFileSync(logPath, 'utf8');
	const folderName = path.basename(path.resolve(folder));
	if (log.includes(`\`${folderName}\``)) {
		console.log(`already logged: ${folderName}`);
		return;
	}
	const date = String(report.created || '').slice(0, 10);
	const summary = (notes || '(no notes)') + (rating > 0 ? ` (rated ${rating}/5)` : '');
	const shot = report.has_screenshot ? ', screenshot' : '';
	const row = `| ${nextId(log)} | ${date} | ${cell(options.reporter) || '?'} | ${cell(state.version) || '?'} | ${cell(areaQuest(state))} | ${category} | ${severity} | new | ${summary} | \`${folderName}\`${shot} |`;
	if (options.dry) {
		console.log(row);
		return;
	}
	fs.writeFileSync(logPath, log.replace(/\s*$/, '\n') + row + '\n');
	console.log(row);
}

main();
