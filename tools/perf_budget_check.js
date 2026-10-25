// Performance pass Oct 25, Part 5: compares tools/perf_probe.gd lines (docs/perf/runs/<tag>.txt) with the "frame" budgets of docs/perf/budgets.json.
// node tools/perf_budget_check.js <raw.txt> <budgets.json> [scale]   -> prints a table, exit 1 when any area is over.
// Budget keys per area and quality ("crosspath": {"Low": {...}, "Medium": {...}}): avg_ms, p99_ms (the 1% low as a frame time), draw_calls,
// vram_mb, ram_mb. `scale` multiplies the time budgets (another PC).
const fs = require('fs');
const [rawPath, budgetPath, scaleArg] = process.argv.slice(2);
const scale = parseFloat(scaleArg || '1');
const budgets = JSON.parse(fs.readFileSync(budgetPath, 'utf8')).frame || {};
const names = ['Low', 'Medium', 'High'];
let over = 0;
const rows = ['| Area | Q | avg ms | 1% low ms | draw calls | VRAM MB | RAM MB | result |', '|---|---|---|---|---|---|---|---|'];
for (const line of fs.readFileSync(rawPath, 'utf8').split('\n')) {
  if (!line.startsWith('perf_probe:')) continue;
  const v = {};
  for (const m of line.matchAll(/(\w+)=([^ ]+)/g)) v[m[1]] = m[2];
  const q = names[parseInt(v.quality, 10)] || v.quality;
  const got = { avg_ms: +v.avg_ms, p99_ms: 1000 / +v.low1_fps, draw_calls: +v.draw_calls, vram_mb: +v.vram_mb, ram_mb: +v.ram_mb };
  const b = (budgets[v.area] || {})[q] || {};
  const fails = [];
  for (const key of Object.keys(b)) {
    const limit = key.endsWith('_ms') ? b[key] * scale : b[key];
    if (got[key] > limit) fails.push(`${key} ${got[key].toFixed(1)} > ${limit.toFixed(1)}`);
  }
  if (Object.keys(b).length === 0) fails.push('no budget');
  if (fails.length && !(fails.length === 1 && fails[0] === 'no budget')) over++;
  rows.push(`| ${v.area} | ${q} | ${got.avg_ms.toFixed(2)} | ${got.p99_ms.toFixed(1)} | ${got.draw_calls} | ${got.vram_mb} | ${got.ram_mb} | ${fails.length ? fails.join(', ') : 'ok'} |`);
}
console.log(rows.join('\n'));
if (over) { console.log(`perf_budget: ${over} area(s) over their frame budget`); process.exit(1); }
console.log('perf_budget: frame budgets met');
