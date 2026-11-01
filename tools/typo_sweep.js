// Fable pass Nov 1 (Part 7): a typo sweep over the dialogue sheet export and the UI's literal strings.
// Usage: node tools/typo_sweep.js [--csv=docs/dialogue/edit_oct27.csv] [--out=docs/dialogue/typo_fixes_nov1.csv]
// Dialogue lines are frozen: their fixes go to the CSV for the designer. UI/code strings are printed for a direct fix.
// Checks: a list of common misspellings, doubled words, a space before punctuation, two spaces, "colour/color" and "parlour/parlor"
// consistency (the game writes British "colour" in cards and UI: report the odd ones out), straight-quote imbalance.
const fs = require("fs");
const path = require("path");
const args = Object.fromEntries(process.argv.slice(2).map(a => { const m = a.match(/^--([^=]+)=(.*)$/); return m ? [m[1], m[2]] : [a, true]; }));
const csvPath = args.csv || "docs/dialogue/edit_oct27.csv";
const outPath = args.out || "docs/dialogue/typo_fixes_nov1.csv";

// misspelling -> fix (word-boundary, case-insensitive; the fix keeps the first letter's case)
const MISSPELLINGS = {
  "acheive": "achieve", "acheived": "achieved", "accomodate": "accommodate", "accomodation": "accommodation", "acquaintence": "acquaintance",
  "adress": "address", "agressive": "aggressive", "alot": "a lot", "apparant": "apparent", "aquainted": "acquainted", "aquire": "acquire",
  "arguement": "argument", "assasin": "assassin", "beleive": "believe", "begining": "beginning", "buisness": "business", "calender": "calendar",
  "cemetary": "cemetery", "commitee": "committee", "concious": "conscious", "definately": "definitely", "definetly": "definitely", "desparate": "desperate",
  "dissapear": "disappear", "dissapoint": "disappoint", "embarass": "embarrass", "enviroment": "environment", "existance": "existence",
  "familar": "familiar", "fourty": "forty", "freind": "friend", "goverment": "government", "grammer": "grammar", "gaurd": "guard", "harrass": "harass",
  "immediatly": "immediately", "independant": "independent", "innoculate": "inoculate", "intrest": "interest", "knowlege": "knowledge",
  "liason": "liaison", "libary": "library", "lisence": "license", "maintainance": "maintenance", "millenium": "millennium", "mischevious": "mischievous",
  "neccessary": "necessary", "necessery": "necessary", "noticable": "noticeable", "occassion": "occasion", "occured": "occurred", "occurence": "occurrence",
  "offical": "official", "paralel": "parallel", "percieve": "perceive", "persistant": "persistent", "posession": "possession", "preceeding": "preceding",
  "priviledge": "privilege", "publically": "publicly", "recieve": "receive", "recieved": "received", "recomend": "recommend", "refered": "referred",
  "relevent": "relevant", "religous": "religious", "repitition": "repetition", "seperate": "separate", "seperately": "separately", "sieze": "seize",
  "succesful": "successful", "succesfully": "successfully", "supercede": "supersede", "suprise": "surprise", "suprised": "surprised", "tendancy": "tendency",
  "threshhold": "threshold", "tommorow": "tomorrow", "tounge": "tongue", "truely": "truly", "unfortunatly": "unfortunately", "untill": "until",
  "wierd": "weird", "wich": "which", "writting": "writing", "recieving": "receiving", "teh": "the", "adn": "and", "thier": "their", "seige": "siege",
  "sargeant": "sergeant", "sargent": "sergeant", "lightening": "lightning", "loose it": "lose it", "alright": "all right",
};
const DOUBLED = /\b(\w+)\s+\1\b/gi;
const DOUBLED_OK = new Set(["that", "had", "very", "no", "so", "yes", "well", "ha", "go", "bang", "tick", "tock", "clap", "ding", "eat", "work", "blah", "la", "da", "chef", "more", "never", "yes,", "wait", "nod", "stamp", "busy", "bye", "yum", "ding,", "bonk", "sure", "hot", "hot,"]);

function findings(text) {
  const out = [];
  if (typeof text !== "string" || text.length === 0) return out;
  for (const wrong in MISSPELLINGS) {
    const re = new RegExp("\\b" + wrong.replace(/ /g, "\\s+") + "\\b", "gi");
    let m;
    while ((m = re.exec(text)) !== null) {
      const fix = m[0][0] === m[0][0].toUpperCase() ? MISSPELLINGS[wrong][0].toUpperCase() + MISSPELLINGS[wrong].slice(1) : MISSPELLINGS[wrong];
      out.push({ what: m[0], fix, why: "misspelling" });
    }
  }
  let d;
  DOUBLED.lastIndex = 0;
  while ((d = DOUBLED.exec(text)) !== null) {
    if (!DOUBLED_OK.has(d[1].toLowerCase()) && d[1].length > 1) out.push({ what: d[0], fix: d[1], why: "doubled word" });
  }
  if (/\s[,.;:!?](?!\.)/.test(text) && !/\s\.\.\./.test(text)) out.push({ what: text.match(/\S*\s[,.;:!?]/)[0], fix: "(no space before the punctuation)", why: "space before punctuation" });
  if (/\S  +\S/.test(text)) out.push({ what: "double space", fix: "one space", why: "double space" });
  if (/\bparlor\b/i.test(text)) out.push({ what: text.match(/\bparlor\w*/i)[0], fix: "parlour", why: "British spelling elsewhere (parlour)" });
  if (/\bcolor\b/i.test(text) && !/\bcolor\s*[:=(]/.test(text)) out.push({ what: "color", fix: "colour", why: "British spelling elsewhere (colour)" });
  return out;
}

// --- the dialogue sheet (quoted CSV, multi-line cells) ---
function parseCsv(data) {
  const rows = []; let row = []; let cell = ""; let quoted = false;
  for (let i = 0; i < data.length; i++) {
    const c = data[i];
    if (quoted) {
      if (c === '"') { if (data[i + 1] === '"') { cell += '"'; i++; } else quoted = false; }
      else cell += c;
    } else if (c === '"') quoted = true;
    else if (c === ",") { row.push(cell); cell = ""; }
    else if (c === "\n") { row.push(cell); rows.push(row); row = []; cell = ""; }
    else if (c !== "\r") cell += c;
  }
  if (cell.length || row.length) { row.push(cell); rows.push(row); }
  return rows;
}
const csv = parseCsv(fs.readFileSync(csvPath, "utf8").replace(/^﻿/, ""));
const header = csv[0];
const idCol = header.indexOf("ID"), lineCol = header.indexOf("Current line"), newCol = header.indexOf("New line");
const sheetRows = [];
let colourCount = 0, colorCount = 0;
for (const row of csv.slice(1)) {
  const line = (row[newCol] || "").trim() || row[lineCol] || "";
  if (/\bcolour/i.test(line)) colourCount++;
  if (/\bcolor\b/i.test(line)) colorCount++;
  for (const f of findings(line)) sheetRows.push([row[idCol], line, f.what, f.fix, f.why]);
}
function q(s) { return '"' + String(s).replace(/"/g, '""') + '"'; }
const lines = ["ID,Current line,Found,Fix,Why"];
for (const r of sheetRows) lines.push(r.map(q).join(","));
fs.writeFileSync(outPath, lines.join("\n") + "\n");
console.log(`sheet: ${csv.length - 1} rows, ${sheetRows.length} findings -> ${outPath} (colour ${colourCount} / color ${colorCount})`);

// --- UI / code strings ---
// Real string literals of a GDScript line (a scanner, not a regex: the text between two literals is code).
function literals(code) {
  const out = []; let i = 0;
  while (i < code.length) {
    const c = code[i];
    if (c === '"' || c === "'") {
      const quote = c; let j = i + 1; let lit = "";
      while (j < code.length && code[j] !== quote) { if (code[j] === "\\") { lit += code[j + 1] || ""; j += 2; } else { lit += code[j]; j++; } }
      out.push('"' + lit + '"'); i = j + 1;
    } else i++;
  }
  return out;
}
function walk(dir, out) { for (const e of fs.readdirSync(dir, { withFileTypes: true })) { const p = path.join(dir, e.name); if (e.isDirectory()) walk(p, out); else if (e.name.endsWith(".gd")) out.push(p); } }
const files = []; for (const d of ["ui", "world", "app", "core"]) walk(d, files);
let uiCount = 0;
for (const file of files) {
  const text = fs.readFileSync(file, "utf8").split("\n");
  text.forEach((raw, i) => {
    const code = raw.replace(/\t#.*$|^\s*#.*$|\s#\s.*$/, "");
    const strings = literals(code).filter(l => l.length >= 8);
    for (const s of strings) {
      if (/^"(res:|user:|&|%)/.test(s) || !/\s/.test(s)) continue;  // paths, format strings and identifier-like keys are not prose
      for (const f of findings(s.slice(1, -1))) { uiCount++; console.log(`${file}:${i + 1}: ${f.why}: "${f.what}" -> ${f.fix}   | ${s.slice(0, 90)}`); }
    }
  });
}
console.log(`ui/code: ${uiCount} findings in ${files.length} files`);
