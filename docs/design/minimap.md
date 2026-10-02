# Minimap and fog of war (brief 6, Part C)

Code: `core/zone/fog_of_war.gd`, `map_poi.gd`, `map_view.gd`; `ui/minimap/` (`MinimapHud`, `FullMapScreen`, `MapRaster`, `MapDraw`); `WalkableArea.is_floor_at()/map_bounds()`.

- **Where**: the HUD of the starting area, the town, every placeholder zone and every framework zone (D.N.A., Gainlands, future zones). Top-right under the buttons; click it or press **M** for the full-screen map with a legend.
- **Orientation**: **north-up** (decision F5). The game camera never rotates, so up on the map is up on screen. The arrow shows which way the hero faces.
- **Fog of war**: 1 m cells; a disc of `FogOfWar.REVEAL_RADIUS` (9 m) is revealed around the player every 0.12 s. Revealed ground draws light with a darker rim, revealed non-ground draws dim, everything else is transparent fog.
- **Persistence**: `Session.map_fog[area_id]` (zone ids plus `town`, `start`, `zone_<id>` for placeholders), saved with the campaign (deflate + base64 per area). If a map's size changes between versions, saved cells are copied by world position.
- **Points of interest** (drawn only once the cell under them is revealed): vendors, healing spots, quest givers (a gold "!" badge while they have a quest to offer or hand in), dungeon and mini-dungeon entrances, puzzle, quiz master, minigame NPC, exits/portals, throwers and portal rippers (dimmed while locked), interactables, challengers (corrupted guardians).
- **Secrets are never shown**: `MapPoi.Kind` has no kind for chests/secrets; each scene builds its POIs from an explicit whitelist (`ZoneDef.poi_kinds`, `TownScene.POI_KINDS`) - hidden chests, the lever/vault/secret dealer in town and the starting area's tunnel are not in any list. Tests: `tests/core/zone/test_fog_and_map.gd`.
- **Settings**: Settings -> "Show minimap" (the M map still works when it is off).
