# itch.io upload guide - The Wayward Path (free, donations welcome)

Step by step for the owner. Everything you paste is in `docs/release/itch_page/` (`page.md`, `ai_disclosure.md`, `screenshots/`).
The zip comes from `bash tools/export_windows.sh <version>` (see `how_to_build.md`); the current one is named in **Files to upload** below.
Nothing here is public until step 9.

## 1. Create the project page

1. Log in at itch.io, open **Dashboard** (top right) and press **Create new project**.
2. **Title:** The Wayward Path. **Project URL:** `the-wayward-path` (itch fills it from the title; shorten it if it is taken).
3. **Classification:** Games. **Kind of project:** Downloadable.
4. **Release status:** Released (or "In development" while playtesters have it; you can change it at any time).

## 2. Pricing: free, with donations

In the **Pricing** block pick the option that lets people download for free and pay only if they want to. On itch.io it is labelled
**"$0 or donate"**: the download button is free, and itch shows a small "pay what you want" prompt first that the player can skip.
Put a **suggested donation** of 3-5 USD in the field (it is a suggestion, never a wall).

If you would rather have no payment prompt on the page at all, pick **"No payments"**: the download is plain and the only way to tip is the
in-game **Support the game** button (step 7). Either choice is fine; you can switch later.

## 3. Page text (from `docs/release/itch_page/page.md`)

- **Short description or tagline:** the one line under "Short description".
- **Details (the page body):** paste the "Long description", the "Features" list, the "Controls" table and the "System requirements" block.
  itch's editor takes Markdown-ish rich text: paste as plain text and re-apply bold and the headings with the toolbar.
- Below the description, paste the short AI note from `ai_disclosure.md` (the quoted paragraph). It is also in the game's Credits page.
- **Genre:** Card Game. **Tags:** the ten in `page.md` (card-game, deckbuilding, rpg, fantasy, story-rich, singleplayer, cozy, turn-based,
  adventure, funny).
- **AI disclosure field:** itch's edit form asks "Does this project contain AI-generated content?". Answer **Yes** and tick **Graphics**,
  **Sound/Music** and **Text/Dialogue** (the code and the game design are hand-made; do not tick Code). Fill the free-text box with the
  same short note.

## 4. Upload the zip

1. In **Uploads** press **Upload files** and pick the zip from `builds/` (the exact file is in **Files to upload** below; about 740 MB,
   so the browser upload takes 5-15 minutes on a home connection - leave the tab open).
2. When it has uploaded, tick **Windows** under the file and set its label to e.g. "Windows 64-bit (zip)". Leave "This file will be played
   in the browser" unticked.
3. itch allows 1 GB per file by default; the zip is under that. If a later build grows past 1 GB, ask itch support to raise the limit (they do
   it on request) or use butler (step 10), which has no such limit.

## 5. Screenshots and cover

- **Cover image** (630x500): follow the crop recipe in `page.md` ("Cover image"): the TITLE-KEYART with the wordmark over the sky.
- **Screenshots:** upload the eight in `docs/release/itch_page/screenshots/` in their numbered order (`README.md` there says what each shows).
  The first screenshot is the one players see in listings, so keep the title or a battle first.

## 6. Visibility: keep it private until the public flip

At the bottom of the edit page, **Visibility & access**: pick **Draft** (only you can see it) while you check the page, or
**Restricted** (anyone with the secret URL or a download key) while playtesters have the build. Save. Open the page as a player would
(the "View page" link), download the zip once, unzip it in a fresh folder and run `TheWaywardPath.exe` to confirm the right file is up.

## 7. The in-game Support button (optional)

`data/credits/credits.cfg`, `[support] url=""` is empty, so every "Support the game" button stays hidden. To show it, paste your page's
donation address between the quotes, e.g. `url="https://<your-itch-name>.itch.io/the-wayward-path/purchase"` (that address opens itch's
pay-what-you-want dialog for the project; a Ko-fi or PayPal link works too), then re-export and re-upload. A tip is never needed to play.

## 8. Tell the playtesters

Send the Restricted page link (or a download key from **Distribute > Download keys**) with `docs/release/rc1_notes.md`: what to look at, the
known issues, and how to report a bug (pause menu > Report a Problem, or Settings > Accessibility > **Copy log**, then paste the log in the
message).

## 9. The public flip (release day)

1. Set `config/version` in `project.godot` to `1.0.0`, export, run the release smoke, and replace the upload with the 1.0.0 zip (delete the
   RC file from Uploads or untick it, so players get one file).
2. Add a line to `CHANGELOG.md` and tag the commit (`git tag v1.0.0`, push with tags).
3. Visibility: **Public**. Save. The page is live and appears in itch's "new releases" feeds within an hour.
4. Optional: a **Devlog** post ("1.0 is out") from the project's dashboard; itch shows it to followers.

## 10. Updates later with butler (optional, faster)

butler is itch's command-line uploader: it sends only the parts of the zip that changed, so a 600 MB update is a few MB.

```
# once: download butler from https://itch.io/docs/butler/ and put butler.exe on the PATH, then
butler login
# every update (channel "windows"; the version shows on the page):
butler push builds/TheWaywardPath-v1.0.0-windows.zip <your-itch-name>/the-wayward-path:windows --userversion 1.0.0
butler status <your-itch-name>/the-wayward-path
```

butler creates the "windows" channel on the first push; tick **Windows** on it once in Uploads. Keep the web-uploaded zip or the butler
channel, not both.

## Files to upload (RC1, Nov 9)

| File | What | Where |
|---|---|---|
| `builds/TheWaywardPath-v1.0.0-rc1-windows.zip` (**736 MB**; unpacks to about 950 MB) | the Windows build: `TheWaywardPath.exe`, `TheWaywardPath.pck` (847 MB), the five `Start (...).bat` launchers, `README_PLAYTEST.txt` | made Nov 9 by `bash tools/export_windows.sh 1.0.0-rc1`; every check passed (pack MD5s, 89 baked shaders, zip CRCs); the release smoke and the exported-build checks are in `docs/overnight_report.md` |
| the cover (630x500) | from TITLE-KEYART, see `page.md` | make it in any image editor from `assets/art/keyart/TITLE-KEYART.webp` |
| 8 screenshots | `docs/release/itch_page/screenshots/0*.jpg` | re-picked in Part 3 of the Fable Nov 9 pass |
| trailer (optional) | `docs/release/itch_page/trailer/` when it exists; itch takes a YouTube or Vimeo link, not a file | see Part 3 |
