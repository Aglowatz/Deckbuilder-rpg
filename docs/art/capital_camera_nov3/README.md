
## Part 5 - the city camera (Standard / Raised / Low)

`Settings.city_camera` ("City camera (the Capital only)" in Settings; the Dev Menu's View page has the same picker), saved in settings.cfg,
**default Standard (unchanged until you pick)**. `world/look/city_camera.gd`; hooks: `ZoneScene._update_camera` (offset, follow rate,
pull-in), `WorldLookRig` (extra aim, FOV / tilt-shift via `CityCamera.adjust`), `CapitalScene` (`in_capital` on tree enter / exit, so a
parked scene and every other zone are Standard; `_camera_blocked` = solid / void cells).

- **Raised**: 29 degree pitch at the normal distance, aimed 9 degrees higher, a 2 degree longer lens, a wider sharp band.
- **Low** (HD-2D): 9 degree pitch, 4.8 m behind and 0.8 m to the right of the hero at about head height, aimed 13 degrees up, an 8 degree
  wider lens, a tilt-shift sharp round the hero and soft near and far, a softer follow (lag); pulled in along the line to the hero's head so
  it never stands in a building (never closer than 1.8 m; past that the occlusion fader ghosts what is in the way).
- Both keep the fixed facing (keys and stick unchanged), the swivel and the zoom, the minimap and the talk prompts (screen-space), and work at
  the gate and through the side passage (the Capital walk smoke ran in Standard; the mode does not change walkability).
- Shots: the six spots (the gate plaza, the west boulevard, the fountain plaza, the west and east side plazas, the palace approach) in all
  three: `<n>_<spot>_<Standard|Raised|Low>.jpg`, `contact_sheet.jpg` (rows = spots, columns = Standard | Raised | Low).
- Tests: tests/world/test_city_camera.gd (5).

**Fresh critic** (no context, the paint-over PAINTOVER-CAP-INNER-CITY and the shots; first round of shots):

| Camera | Paint-over match | Readability | Grand / charming |
|---|---:|---:|---:|
| Raised | 7 | 8 | 6 |
| Standard | 6 | 7 | 6 |
| Low | 4 | 4 | 8 |

Ranking: 1 Raised (closest to the paint-over's high three-quarter view, the plaza patterns and axis read, NPCs readable), 2 Standard (same
idea, flatter, more overlap), 3 Low (the only one with sky, spires and looming facades - the grandest - but the hero covers the path and
there is little ground to read). Its top Raised fixes were applied (aimed 5 -> 9 degrees higher, 10 % closer; the Raised column was
re-shot); its third (less distance haze in the Capital) is a look change left for you. Its advice: Raised as the default, Standard kept,
Low as a showcase / arrival mode rather than the walking camera.

**Recommendation**: Raised for walking the Capital. Low is worth keeping as an option (or for scripted arrivals at the gate and the palace
stair).
