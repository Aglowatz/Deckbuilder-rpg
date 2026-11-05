# Dialogue rewrite, Nov 5

Part 4 of `docs/prompts/overnight_nov4.md`. Style authority: `docs/dialogue/story_voice_nov5.md` (story spine, voice cards, banned patterns).
Review sheet for the owner: **`docs/dialogue/edit_nov5.csv`** (4,316 rows in story order; type over "New line" to change a line).

## What was done

- **Fresh export** before the pass: `docs/dialogue/edit_nov5_before/before_nov5.csv` (4,266 lines).
- **15 chunks in story order** (`docs/dialogue/rewrite_nov5/chunks/`, built by `tools/dialogue_rewrite_chunks.js`), each rewritten by a
  writing agent from the brief `docs/dialogue/rewrite_nov5/AGENT_BRIEF.md`: main-quest lines first, then the primary characters, side quests,
  barks. Every line kept its ID, `{tokens}`, `[tags]` and the phrases tests assert; all passed `tools/dialogue_critic_check.js`.
- **Applied as a revertible pass:** `node tools/apply_dialogue_pass.js --csv=docs/dialogue/rewrite_nov5/edit_rewrite.csv --apply` -
  **1,178 lines changed**, 0 conflicts, 0 failed validation (tokens, length, box fit measured in Godot). The ledger keeps every original:
  `--csv=docs/dialogue/rewrite_nov5/edit_rewrite.csv --revert` puts the whole pass back, `--revert=<ids.txt>` any part of it.
- Lines kept on purpose (about 3,100): UI and rule text, quest steps and hints that were already exact, titles and buttons, Fig Sly and the
  Secret Dealer (locked), and lines that already read well.
- Two tests asserted words the rewrite had moved ("escape", "regime"); the Rescuer's send-off and Brick Bronson's intro were adjusted.
- PathDirection's tokens (`{zone}`, `{path}`, `{vendor}`, `{buff}` ...) and `{rescuer_full}` are now known to both dialogue tools.
- `tools/export_dialogue.js`: the armory equip lines export as Bertram's (he says them). The three labels the brief listed were already
  right (inbox 7).

## The blind critic

A writing editor with no context scored 100 random changed lines (60 main story, 40 side content), each as two unlabelled versions
(`docs/dialogue/rewrite_nov5/critic_sample.md`, review `critic_review.md`). Decoded:

| | Version | Voice | Clarity | Emotion | Humour | Preferred |
|---|---|---:|---:|---:|---:|---:|
| Main story | old | 6.32 | 7.30 | 6.00 | 6.29 | 5 |
| Main story | **new** | **7.53** | **8.03** | **7.02** | **7.23** | **49** (6 ties) |
| Side content | old | 6.63 | 7.33 | - | 6.72 | 10 |
| Side content | **new** | **7.42** | **8.10** | - | **7.18** | **29** (1 tie) |

Fixes from the review: the 15 lines where the old version won were put back (`rewrite_nov5/reverted_by_critic.txt`); four lines it still
found weak were rewritten (`rewrite_nov5/merges_critic.csv`: Maren's regret about Elowen's father, the Wanderer's phase-2 answer without the
slogan, Rollo's line about lateness, Agnes's "1987" made "forty years ago").

## Ten of the best before / after

| Speaker | Before | After |
|---|---|---|
| The Wanderer, waking | I search for my name. For how I got here. But I find nothing. | I keep reaching for my name, or for how I got here, and there's nothing there at all. |
| Elder Maren, memory 1 | I sense something within you that wasn't there before. I trust the Paths to guide you. | That tune's stayed with you, hasn't it? I can see it on your face. Good. Keep it somewhere safe, dearie, even when it hurts. |
| Agnes Overdue, the vacancy | Even the dead deserve humanity. Our job is to help the lost souls. Following orders be damned: we treat everyone with respect. | Everyone in that queue was somebody, dear, and the dead deserve to be treated as people. No order outranks that, not his and not anyone's. |
| Grandmaster Flex, the reveal | True strength is not the ability to lift heavy things. It comes from the heart, and from the mind. | Strength was never about how heavy a thing is, Clench. It lives in the heart and the mind, and nobody can lock those in a cell. |
| Flex, in his cell | So I had everything. My breath. My body. My mind. | And nothing, it turns out, is a fine place to start. I still had my breath, my body and my mind, so I trained them every day. |
| Primm, at the model table | Of comfort? Of being safe? I have given them roofs, and hats, and rules. | I have given them roofs, and hats, and rules, and I have given each of them exactly the same amount of each, which is more than anyone before me ever managed. |
| Elowen, Cell 4 | They put me in your cell. My father thinks that's educational. With him it is hard to tell. | They put me in your cell. My father calls it educational, and the worst of it is that he means it. |
| Widow Pell | I cannot bury him. Form 27-B needs Form 27-C, and 27-C needs 27-B. He has waited in his chair for three years. | And I can't bury him. Form 27-B needs a 27-C, and the 27-C needs a 27-B, so he's still in his chair, waiting, the way he always used to wait for me. |
| Chef Gravois, freed | The simmer let go. The sauce let go. Plain bread. No sauce. I could weep. I am weeping. | The sauce has let go of me. Is that plain bread, with no sauce on it at all? I could weep. In fact, I am weeping. |
| A freed citizen | He was not kind. He was afraid. I think both can be true. | He wasn't kind, he was afraid, and for ten years none of us could tell the difference. |
