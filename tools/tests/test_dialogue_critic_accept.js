// Oct 31: the critic columns of the edit CSV ("Critic suggestion", "Accept (Y)") in tools/apply_dialogue_pass.js.
//   node tools/tests/test_dialogue_critic_accept.js
// Unit checks of tools/dialogue_edit_rows.js, then a dry run (--no-fit, nothing written to the game) of a four-row temp CSV built from real
// rows of docs/dialogue/edit_oct27.csv. Exit code 1 on any failure.
const assert = require('assert');
const fs = require('fs');
const os = require('os');
const path = require('path');
const { execFileSync } = require('child_process');
const { root, parseCsv, csvq } = require('../dialogue_ids');
const { editRow, accepted } = require('../dialogue_edit_rows');

let failures = 0;
function check(name, fn) {
	try { fn(); console.log(`ok   ${name}`); } catch (e) { failures++; console.log(`FAIL ${name}: ${e.message}`); }
}

const base = { ID: 'data/story/intro_story.tres::x::0', Speaker: 'S', 'Zone/Area': 'Prologue (Opening Forest) / x', 'Current line': 'Old.' };

check('Accept Y and an empty New line take the critic suggestion', () => {
	const r = editRow({ ...base, 'New line': '', 'Critic suggestion': 'Critic.', 'Accept (Y)': 'Y' });
	assert.strictEqual(r.new_text, 'Critic.');
	assert.strictEqual(r.from_critic, true);
	assert.strictEqual(r.area, 'Prologue (Opening Forest)');
});
check('lower-case y and spaces count as accepted', () => {
	assert.ok(accepted(' y '));
	assert.ok(accepted('Y'));
	assert.ok(!accepted('yes'));
	assert.ok(!accepted('N'));
	assert.ok(!accepted(''));
	assert.ok(!accepted(undefined));
});
check('an explicit New line wins over an accepted suggestion', () => {
	const r = editRow({ ...base, 'New line': 'Mine.', 'Critic suggestion': 'Critic.', 'Accept (Y)': 'Y' });
	assert.strictEqual(r.new_text, 'Mine.');
	assert.strictEqual(r.from_critic, false);
});
check('a suggestion without Accept is ignored', () => {
	const r = editRow({ ...base, 'New line': '', 'Critic suggestion': 'Critic.', 'Accept (Y)': '' });
	assert.strictEqual(r.new_text, '');
	assert.strictEqual(r.from_critic, false);
});
check('Accept with an empty suggestion changes nothing', () => {
	const r = editRow({ ...base, 'New line': '', 'Critic suggestion': '  ', 'Accept (Y)': 'Y' });
	assert.strictEqual(r.new_text, '');
	assert.strictEqual(r.from_critic, false);
});
check('a CSV without the critic columns reads as before', () => {
	const r = editRow({ ...base, 'New line': 'Mine.' }, { [base.ID]: 'Snap.' });
	assert.strictEqual(r.new_text, 'Mine.');
	assert.strictEqual(r.snapshot, 'Snap.');
	assert.strictEqual(r.current_text, 'Snap.', 'Current line differs from the snapshot, so the snapshot is what the game says');
	assert.strictEqual(editRow({ ...base, 'New line': 'Mine.' }, { [base.ID]: 'Old.' }).current_text, 'Old.');
});

check('a rewrite typed over Current line is the new line (a suggestion without Y does not change that)', () => {
	const snap = { [base.ID]: 'Old.' };
	const r = editRow({ ...base, 'Current line': 'Designer.', 'New line': '', 'Critic suggestion': 'Critic.', 'Accept (Y)': '' }, snap);
	assert.strictEqual(r.typed_over, true);
	assert.strictEqual(r.own_line, true);
	assert.strictEqual(r.new_text, 'Designer.');
	assert.strictEqual(r.current_text, 'Old.', 'the line it replaces is the snapshot');
	assert.strictEqual(r.from_critic, false);
});
check('Y on a critic fix of a typed-over line takes the fix', () => {
	const r = editRow({ ...base, 'Current line': 'Desinger typo.', 'New line': '', 'Critic suggestion': 'Designer, fixed.', 'Accept (Y)': 'Y' }, { [base.ID]: 'Old.' });
	assert.strictEqual(r.new_text, 'Designer, fixed.');
	assert.strictEqual(r.from_critic, true);
	assert.strictEqual(r.current_text, 'Old.', 'still replaces what the game says');
});
check('an explicit New line beats a typed-over Current line', () => {
	const r = editRow({ ...base, 'Current line': 'Designer.', 'New line': 'Mine.' }, { [base.ID]: 'Old.' });
	assert.strictEqual(r.new_text, 'Mine.');
	assert.strictEqual(r.typed_over, false);
});
check('spreadsheet re-encodings are not rewrites (a swallowed leading quote, curly quotes)', () => {
	const snap = { [base.ID]: "'Lift,' it rumbles." };
	assert.strictEqual(editRow({ ...base, 'Current line': "Lift,' it rumbles." }, snap).typed_over, false);
	assert.strictEqual(editRow({ ...base, 'Current line': '‘Lift,’ it rumbles.' }, snap).typed_over, false);
	assert.strictEqual(editRow({ ...base, 'Current line': "Lift,' it rumbles." }, snap).new_text, '');
	assert.strictEqual(editRow({ ...base, 'Current line': 'Old.' }).typed_over, false, 'no snapshot, no rewrite');
});

// End to end: a dry run of the real importer on a temp CSV. Rows: A accepted suggestion (applies), B own New line beats the suggestion
// (applies the New line), C suggestion not accepted (blank), D accepted suggestion that drops a token (fails validation).
check('dry run counts accepted critic rows and never writes the game', () => {
	// The game's text of each row is the export snapshot (the sheet's Current line may hold the designer's rewrites).
	const snap = JSON.parse(fs.readFileSync(path.join(root, 'docs/dialogue/edit_oct27/export_snapshot.json'), 'utf8'));
	const rows = parseCsv(fs.readFileSync(path.join(root, 'docs/dialogue/edit_oct27.csv'), 'utf8')).map((r) => ({ ...r, 'Current line': snap[r.ID] ?? r['Current line'] }));
	const pick = (re) => rows.find((r) => re.test(r.ID) && !/\{/.test(r['Current line']) && !/^\s*-/.test(r['Current line']));
	const withToken = rows.find((r) => /intro_story\.tres::/.test(r.ID) && r['Current line'].includes('{town}'));
	const a = pick(/intro_story\.tres::awakening_lines::0$/), b = pick(/intro_story\.tres::awakening_lines::1$/), c = pick(/intro_story\.tres::awakening_lines::2$/);
	const e = pick(/intro_story\.tres::prologue\.self_talk::2$/);
	assert.ok(a && b && c && e && withToken, 'test rows found');
	const before = fs.readFileSync(path.join(root, 'data/story/intro_story.tres'), 'utf8');
	const cols = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line', 'Critic suggestion', 'Accept (Y)'];
	const line = (r, own, critic, yes) => [r.ID, r['Zone/Area'], r.Speaker, r["When it's heard"], r['Current line'], own, critic, yes].map(csvq).join(',');
	const csv = [cols.map(csvq).join(','),
		line(a, '', 'Cold. Leaves in my mouth. Off to a flying start.', 'Y'),
		line(b, 'My own rewrite of the name line.', 'The critic version.', 'y'),
		line(c, '', 'Not accepted, so never applied.', ''),
		line(withToken, '', 'This rewrite forgot the town token.', 'Y'),
		[e.ID, e['Zone/Area'], e.Speaker, e["When it's heard"], 'Typed straight over the old line.', '', 'Ignored critic line.', ''].map(csvq).join(',')].join('\n') + '\n';
	const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'critic-accept-'));
	const file = path.join(dir, 'edit_test.csv');
	fs.writeFileSync(file, csv);
	// The export snapshot (what each line said at export) is how a rewrite typed over Current line is told apart.
	fs.mkdirSync(path.join(dir, 'edit_test'), { recursive: true });
	fs.writeFileSync(path.join(dir, 'edit_test', 'export_snapshot.json'), JSON.stringify(Object.fromEntries([a, b, c, e, withToken].map((r) => [r.ID, r['Current line']]))));
	const out = execFileSync('node', [path.join(root, 'tools/apply_dialogue_pass.js'), `--csv=${file}`, '--no-fit'], { cwd: root, encoding: 'utf8' });
	assert.match(out, /\(dry run\): 3 would apply, 1 blank, 0 conflicts, 1 failed validation/);
	assert.match(out, /critic suggestions accepted: 2; 1 would apply, 1 failed, 0 held, 0 conflicts/);
	assert.match(out, /rewrites typed over Current line: 1; 1 would apply/);
	assert.match(out, /FAILED .*tokens/);
	const report = fs.readFileSync(path.join(dir, 'edit_test', 'apply_report_dry_run.md'), 'utf8');
	assert.ok(report.includes('Off to a flying start.'), 'the accepted suggestion is in the report');
	assert.ok(report.includes('My own rewrite of the name line.'), 'the own New line is in the report');
	assert.ok(!report.includes('The critic version.'), 'the overridden suggestion is not');
	assert.ok(report.includes('Typed straight over the old line.') && !report.includes('Ignored critic line.'), 'the typed-over line applies; the suggestion without Y does not');
	assert.strictEqual(fs.readFileSync(path.join(root, 'data/story/intro_story.tres'), 'utf8'), before, 'game file unchanged');
	fs.rmSync(dir, { recursive: true, force: true });
});

console.log(failures ? `${failures} failed` : 'all passed');
process.exitCode = failures ? 1 : 0;
