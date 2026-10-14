# Storybook scale and the camera (Art Bible G-01, G-02)

## Scale (`world/kit/storybook_scale.gd`)

| Thing | Before | Now |
|---|---|---|
| Hero | 1.25 m | 1.70 m (`CHAR_FACTOR` 1.36; every NPC and enemy grew by the same factor, so Relative Heights are kept) |
| Door | 3.4 x 1.7 m | 1.95 x 1.25 m (hero is 87% of a door) |
| Storey | 4.0 m ground floor, 3.2-3.3 upper | 2.5 m ground, 1.9-2.1 upper (about 1.5 heroes); presets in `data/art/building_presets.json` are authored in storybook metres |
| Foundation band | 0.55 | 0.35-0.4 |
| Trees | 4.3-6.6 m tall, narrower | 4.4-6.6 m tall (2.6-3.9 heroes), 20% wider (rounder) |
| Props | barrel 1.1, crate 0.9, lamp post 4.2 | unchanged: now waist/hip height of the bigger hero |
| Walk speed | 3.4 m/s | 4.9 m/s (enemy speeds scale by the same ratio, `ZoneEnemy.SPEED_RATIO`) |
| Body radius (collision) | 0.22 | 0.30 |
| Interaction reach | spot radius | spot radius x 1.2 (`StorybookScale.INTERACT_FACTOR`), enemy touch range x 1.2 |

The zone builders that draw their own geometry (D.N.A., Gainlands, Buffet, Dump, Capital) were not rebuilt: the bigger characters make their buildings read about 26% lower relative to the hero, which is the storybook compression. Their hero landmarks get stand-ins at storybook size in the sub-area blockouts (see `docs/zone_plans/`).

## Camera (`world/look/camera_rig.gd`)

* Angle presets (Settings, key **V**): Cinematic 20 deg, Classic 30, Overview 45.
* Zoom presets (Settings, key **F**, mouse wheel fine-tunes): Close, Normal, Far.
* Swivel: hold **Z** / **X** (rebindable) or push the right stick: turns up to 18 degrees, eases back on release.
* The hero is about 11% of the screen height at Normal (`CameraRig.normal_distance`).
* Each of the 9 combinations changes FOV, tilt-shift focus, band and blur (`CameraRig.adjust`, tables at the top of the file) on top of the zone's look.
* The choice is stored in settings.cfg (`[video] camera_angle`, `zoom`), not in a save.
