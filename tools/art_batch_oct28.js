// Overnight Oct 27-28, Part 2: writes the master missing-art catalogue docs/art/art_batch_oct28.csv from the row table in
// tools/art_batch_oct28_rows.js, plus the counts section of docs/art/art_batch_oct28.md (between the <!-- counts --> markers).
//   node tools/art_batch_oct28.js
// Columns: Art ID, Category, Zone, Name/What, Story/theme purpose, Where used, Stand-in today, Size/aspect + transparency,
// Destination Approved_* folder, File name to save as, Priority, Image description, Notes.
const fs = require('fs');
const path = require('path');
const repo = path.resolve(__dirname, '..');
const { LOCKS, ROWS } = require('./art_batch_oct28_rows.js');

const HEADER = ['Art ID', 'Category', 'Zone', 'Name/What', 'Story/theme purpose', 'Where used', 'Stand-in today',
  'Size/aspect + transparency', 'Destination Approved_* folder', 'File name to save as', 'Priority', 'Image description', 'Notes'];

function cell(v) { v = String(v == null ? '' : v); return /[",\n\r]/.test(v) ? '"' + v.replace(/"/g, '""') + '"' : v; }

const ids = new Set();
const out = [HEADER];
for (const r of ROWS) {
  if (ids.has(r.id)) throw new Error('duplicate Art ID ' + r.id);
  ids.add(r.id);
  const lock = LOCKS[r.lock];
  if (!lock) throw new Error(r.id + ': unknown lock ' + r.lock);
  const desc = (r.lockInline === false ? '' : '[' + r.lock + ' lock] ') + r.desc;
  out.push([r.id, r.cat, r.zone, r.name, r.purpose, r.where, r.standin, r.size, r.dest, r.file, r.prio, desc, r.notes || '']);
}
fs.writeFileSync(path.join(repo, 'docs/art/art_batch_oct28.csv'), out.map(r => r.map(cell).join(',')).join('\n') + '\n');

// Counts
function count(key) { const m = {}; for (const r of ROWS) { const k = r[key]; m[k] = (m[k] || 0) + 1; } return m; }
function table(title, m, order) {
  const keys = order ? order.filter(k => m[k]).concat(Object.keys(m).filter(k => !order.includes(k)).sort()) : Object.keys(m).sort();
  return `| ${title} | Rows |\n|---|---:|\n` + keys.map(k => `| ${k} | ${m[k]} |`).join('\n') + `\n| **Total** | **${ROWS.length}** |\n`;
}
const byCat = count('cat'), byZone = count('zone'), byPrio = count('prio');
const cross = {};
for (const r of ROWS) { cross[r.cat] = cross[r.cat] || { High: 0, Medium: 0, Low: 0 }; cross[r.cat][r.prio]++; }
let crossTable = '| Category | High | Medium | Low | Total |\n|---|---:|---:|---:|---:|\n';
for (const c of Object.keys(cross).sort()) { const x = cross[c]; crossTable += `| ${c} | ${x.High} | ${x.Medium} | ${x.Low} | ${x.High + x.Medium + x.Low} |\n`; }
const high = ROWS.filter(r => r.prio === 'High').map(r => `- \`${r.id}\` ${r.name} (${r.cat}, ${r.zone})`).join('\n');
const counts = `\n${table('Category', byCat)}\n${table('Zone', byZone, ['Global', 'Opening Forest', 'Crosspath', 'Gainlands', 'D.N.A.', 'Endless Buffet', 'Verdant Dump', 'Capital', 'Castle', 'Lab', 'Dungeons'])}\n${table('Priority', byPrio, ['High', 'Medium', 'Low'])}\n${crossTable}\n### The High list (${byPrio.High || 0})\n\n${high}\n`;

const mdPath = path.join(repo, 'docs/art/art_batch_oct28.md');
let md = fs.existsSync(mdPath) ? fs.readFileSync(mdPath, 'utf8') : '# Art batch Oct 28\n\n<!-- counts -->\n<!-- /counts -->\n';
md = md.replace(/<!-- counts -->[\s\S]*?<!-- \/counts -->/, '<!-- counts -->' + counts + '<!-- /counts -->');
fs.writeFileSync(mdPath, md);
console.log(`${ROWS.length} rows -> docs/art/art_batch_oct28.csv; counts: ` + JSON.stringify(byPrio));
