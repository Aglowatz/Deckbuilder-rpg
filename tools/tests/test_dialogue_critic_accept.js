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
	assert.strictEqual(r.current_text, 'Old.');
});

// End to end: a dry run of the real importer on a temp CSV. Rows: A accepted suggestion (applies), B own New line beats the suggestion
// (applies the New line), C suggestion not accepted (blank), D accepted suggestion that drops a token (fails validation).
check('dry run counts accepted critic rows and never writes the game', () => {
	const rows = parseCsv(fs.readFileSync(path.join(root, 'docs/dialogue/edit_oct27.csv'), 'utf8'));
	const pick = (re) => rows.find((r) => re.test(r.ID) && !/\{/.test(r['Current line']) && !/^\s*-/.test(r['Current line']));
	const withToken = rows.find((r) => /intro_story\.tres::/.test(r.ID) && r['Current line'].includes('{town}'));
	const a = pick(/intro_story\.tres::awakening_lines::0$/), b = pick(/intro_story\.tres::awakening_lines::1$/), c = pick(/intro_story\.tres::awakening_lines::2$/);
	assert.ok(a && b && c && withToken, 'test rows found');
	const before = fs.readFileSync(path.join(root, 'data/story/intro_story.tres'), 'utf8');
	const cols = ['ID', 'Zone/Area', 'Speaker', "When it's heard", 'Current line', 'New line', 'Critic suggestion', 'Accept (Y)'];
	const line = (r, own, critic, yes) => [r.ID, r['Zone/Area'], r.Speaker, r["When it's heard"], r['Current line'], own, critic, yes].map(csvq).join(',');
	const csv = [cols.map(csvq).join(','),
		line(a, '', 'Cold. Leaves in my mouth. Off to a flying start.', 'Y'),
		line(b, 'My own rewrite of the name line.', 'The critic version.', 'y'),
		line(c, '', 'Not accepted, so never applied.', ''),
		line(withToken, '', 'This rewrite forgot the town token.', 'Y')].join('\n') + '\n';
	const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'critic-accept-'));
	const file = path.join(dir, 'edit_test.csv');
	fs.writeFileSync(file, csv);
	const out = execFileSync('node', [path.join(root, 'tools/apply_dialogue_pass.js'), `--csv=${file}`, '--no-fit'], { cwd: root, encoding: 'utf8' });
	assert.match(out, /\(dry run\): 2 would apply, 1 blank, 0 conflicts, 1 failed validation/);
	assert.match(out, /critic suggestions accepted: 2; 1 would apply, 1 failed, 0 held, 0 conflicts/);
	assert.match(out, /FAILED .*tokens/);
	const report = fs.readFileSync(path.join(dir, 'edit_test', 'apply_report_dry_run.md'), 'utf8');
	assert.ok(report.includes('Off to a flying start.'), 'the accepted suggestion is in the report');
	assert.ok(report.includes('My own rewrite of the name line.'), 'the own New line is in the report');
	assert.ok(!report.includes('The critic version.'), 'the overridden suggestion is not');
	assert.strictEqual(fs.readFileSync(path.join(root, 'data/story/intro_story.tres'), 'utf8'), before, 'game file unchanged');
	fs.rmSync(dir, { recursive: true, force: true });
});

console.log(failures ? `${failures} failed` : 'all passed');
process.exitCode = failures ? 1 : 0;
