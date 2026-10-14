# First homestead prototype

## Native UI and chest � October 14, 2026

See [UI_INTEGRATION.md](UI_INTEGRATION.md) for the current native HUD, object-following action cue, Bag, Seeds, house chest, controls, migration and fresh Studio evidence. This supersedes the older UI/control descriptions below. The current canonical file was exported from the reconciled live place, not rebuilt over newer Studio work.


## Farming integration — October 14, 2026

The canonical `build/LunaLanding-AutumnReview.rbxlx` now includes all eight crop
families, the physical inventory assets, planting, timed stages, care, individual
produce quality, weighted harvests, regrowth, a temporary seed shop, reviewed sales,
and a persistent server-authoritative profile system. The four-slot starter area
and world layout remain unchanged.

See [FARMING_LOOP.md](FARMING_LOOP.md) for configuration, controls, persistence,
local Studio setup, verification evidence, and measured asset costs. The source
catalog is `src/farming/Catalog.luau`; server settings are in
`src/farming/Settings.luau`. Use `build_farming.py` to patch this game in place.

**Local testing:** the saved game defaults to real persistence. An unpublished
place cannot access DataStore; enable the explicit `StudioTest.Enabled` and
`UseMemoryStore` settings for an unsaved local test, with `TimeScale=1` to retain
normal growth times. The UI labels memory mode. No test funds, accelerated
settings, or fixture crops were saved in the canonical game.

The sections below document earlier prototype and workshop work. Their old
pepper-only economy and session-reset behavior are superseded by this integration.

## Pepper AssetWorkshop rebuild — October 13

`build/AssetWorkshop.rbxlx` now contains a fresh compact pepper study. The earlier
workshop experiments were replaced; `build/AssetWorkshop.before-pepper-rebuild.rbxlx`
preserves the previous saved file. The gameplay places are separate from this study.

- Four displayed stages: paired seed leaves, branching young plant, mature green
  fruit, and harvest-ready red/golden bell peppers. A separate fruit study uses the
  same geometry at actual asset scale.
- `ReplicatedStorage.AssetLibrary.PepperGrowthStages` holds Planted, Developing,
  Mature, Ready, and Regrowing templates. Mature/Ready/Regrowing share foliage;
  Regrowing has no fruit. The ready plant is about 2.62 × 2.83 × 2.30 studs.
- Broad folded leaves and four-lobed fruit are baked native UnionOperations with
  local geometry, flat normals, matte colors, and no external asset dependency.
  The ready template has five fruit (two smaller ones at the top), a 2.92-stud
  timber support stake with two ties, and 55 parts; all crop parts are anchored, noncolliding,
  nontouching, and nonqueryable. This is a workshop asset, not yet integrated into
  the gameplay crop builder.
- `src/PepperWorkshop.luau` rebuilds this workshop in Studio Edit mode. It is also
  stored as the inert `ServerStorage.PepperWorkshopBuilder` ModuleScript. Running
  it intentionally replaces the workshop scene; do not run it in a gameplay place.
- Front/back Studio renders and stage/size/physics checks completed. Preview:
  `build/pepper-workshop-rebuilt.png`. The folder has no Git repository, so no local
  commit was possible.

`save_pepper_snapshot.py` persists the exported Edit-mode snapshot while reusing
the place's embedded geometry. It preserves the current arrangement of studies.
The native CSG assets have a low-poly appearance but contain extra internal
triangles; mesh simplification remains a production optimization.

## Autumn world visual pass — October 13

The rebuilt `build/LunaLanding-FirstPlot.rbxlx` adds deeper built-in Grass material, sparse dimensional grass tufts at the margins, warm plaster walls, wood-grain construction, sage shutters, window boxes, lanterns, and a textured terracotta-colored slate roof. `autumn_world.py` owns the deterministic visual additions. No new asset uploads are required.

Loose russet/gold/evergreen groves frame the property. Lower, distant mountain silhouettes sit behind them. The surrounding ground is now continuous at property level across 2,048 studs; the front gate joins a broad village lane, and three additional open fence passages support future routes. Trees, mountains and decorative details do not collide or intercept queries. The large customization lawn remains clear. These are expansion connections, not implemented town destinations or new loading transitions.

Verification: all four fence openings passed an eight-stud-wide clearance check at body height. All 1,675 new decorative parts are nonblocking and nonqueryable, and eight growing areas remain. The final lower mountain skyline and autumn canopy pass were inspected in Studio overview and Play mode. The player walked from the spawn through the gate to Z=78.4, then back outside to Z=144.4 using ordinary Humanoid movement; no teleport or load was involved. Runtime confirmed StreamingEnabled=false and all 50 mountain model/part descendants present. Evidence: `build/autumn-gate-play.png`.

The existing `LunaLanding-AutumnReview.rbxlx` is the canonical working place and contains the expanded open world. This pass updates that file in place, preserving its AutumnDetails content. The status produce image is generated from the crop model in a ViewportFrame, so it does not depend on uploaded image access; the earlier seed-packet asset returned Roblox asset-access 403 errors in this local session.

This pass updates `build/LunaLanding-AutumnReview.rbxlx` directly. Continue from that exact file. Do not edit or rebuild `LunaLanding-AutumnFinal.rbxlx`. `build_plot.py` writes the smaller standalone `LunaLanding-FirstPlot.rbxlx`; do not use it for the canonical Autumn Review place.

`build/LunaLanding-BeforeAutumn.rbxlx` and `build/build_plot.before-autumn.py` preserve the previous build. `build/LunaLanding-AutumnFinal.rbxlx` is outside the current work scope. This workspace is not a Git repository, so no local commits could be staged. Do not rebuild the smaller standalone prototype when continuing work in Autumn Review.

Open `build/LunaLanding-AutumnReview.rbxlx` in Roblox Studio and press Play.

1. Approach the gate sign and hold **E** to claim the free homestead.
2. Follow **DIG HERE** and the large shovel to the dirt patch. Stand on the pit and hold **E**, or equip the shovel and click in the game view. Each completed hit earns **1 Sterne** and may find a pepper seed. A successful dig plays a short shovel stroke and soil response. Before claiming, the pit explains where to claim instead of hiding its prompt.
3. Approach an empty slot in the raised bed and hold **E** when its prompt says **Plant**. The current prototype seed supply is pepper seeds.
4. Return when its prompt says **Harvest**. The crop in that slot stays and regrows; crop type is stored per slot so different resources can occupy different slots.
5. Take harvested produce to the one shared box just outside the farm gate and hold **E**. It sells all harvested crops together; peppers currently sell for **1 Sterne each**, a provisional prototype value.

The dark-gray floating planter display sits above the active bed in a near-square 2×2 layout. Its four circles are 15% larger than the previous layout, with closer horizontal spacing and more vertical separation. Empty circles stay blank; planted circles show the icon mapped to that slot's crop type, with a growth ring that fills as the crop grows and turns green when ready. The display contains only the `PLANTER` heading and circles; the one shared physical produce box remains outside the entry fence, opposite the gate sign across the doorway.

Pepper visuals use distinct seedlings, branching young plants, mature foliage with small green fruit, and red/amber harvest-ready bell peppers. Broad pointed leaves have folded faces, and fruit has three blunt lobes with simple stems. The foliage stays after harvest while fruit regrows. Decorative crop parts are anchored and do not collide, touch-trigger, or intercept queries. These primitive assemblies are prototype models; mesh consolidation is still appropriate before populating a full village.

Roblox's standard proximity prompts also provide touch and controller controls; those devices have not yet been tested. This is a session-only prototype: progress resets when Play stops. One shared produce box just outside the gate sells all harvested crop types for Sterne; pepper currently pays the provisional 1 Sterne. Sales are not saved. There is no grocery, care, quality, processing, persistence, or village system yet.

The compact top bar shows Sterne with the approved octagonal C coin. **Inventory** holds seed and harvested-pepper counts; **Diary** shows the most recent 40 actual session events and basic controls. Both panels open and close. Notices fade after seven seconds. The diary and inventory reset with the session.

## Layout

- Flat 220 × 196 stud property, enlarged from 160 × 144: 87% more total land. The northwest cottage retains its open doorway, porch and steps.
- Eight fixed growing-area footprints in asymmetrical clusters; only Area01 is unlocked, with four slots.
- Greenhouse footprint is separate and unbuilt.
- An uninterrupted 108 × 116 stud lawn remains clear of paths: 12,528 square studs, about 31% of usable land and more than twice the previous lawn. Broad grass margins around loose garden clusters are additional space.
- Seven future areas are marked by low stakes and quiet grass patches, without purchase prompts or invented unlock prices.
- Curving cream paths with broad rounded joins and slight edge variation connect the gate, cottage, digging patch and gardens. The meadow remains open.
- Layered roof fascia, gable timbers, porch brackets, framed windows, two porch planters and sparse faceted shrubs refine the cottage silhouette.
- The welcome sign displays the exact approved `03-cottage-sign-logo-v3.png` as `rbxassetid://76464012414224`. A separate claim instruction stays readable below it.
- The digging pit has a rounded earth footprint, darker center, low irregular earth shoulders, a few clods, and the shovel cue.
- Plain matte earthy parts. This is a primitive-based prototype; production foliage/path meshes can reduce the part count.

## Prototype tuning

`src/Prototype.server.luau` contains temporary tuning: 0.7-second dig cooldown, 40% pepper-seed chance per hit, 25-second initial growth, 20-second regrowth, one pepper per harvest, and 1 Sterne per pepper sold. These are test values, not approved final balance. The 1 Sterne base dig reward and repeat-harvest peppers follow CONCEPT.md. No first-seed guarantee is implemented.

Ownership, distance and cooldown checks run on the server. Other players cannot use the owner's dig or planting actions. The one-plot prototype releases its claim when the owner leaves; inventory is deliberately not saved.

## Rebuild

For the current in-place work, use `build/LunaLanding-AutumnReview.rbxlx`; do not run the standalone builder, which writes the smaller `LunaLanding-FirstPlot.rbxlx` prototype.

## Checked in Studio

- File loaded as its own unpublished place; the separate blank Place1 was left intact.
- The one shared box sits outside the entry fence by the gate, opposite the sign across the doorway; the raised display is separate and above the active bed. The four-circle UI and corrected SurfaceGui faces have not been rendered in Roblox Studio.
- Eight area models, four planting prompts and the flat ground dimensions verified.
- Play mode: claim → shovel receipt → dig rewards/random seed discovery → plant → ready → harvest. The harvested pepper remains as a regrowing plant.
- Sign orientation, enlarged text, posts behind lettering, and shovel/soil cues visually checked from the approach and in Play mode.
- Revised paths and cottage checked from an elevated overview and approach camera; claim/dig/plant checked again after the visual pass.
- A collision ray through the cottage doorway confirmed a clear entry.
- All eight growing-area reservations passed conservative path-bounds checks using expanded, rotated 28 × 26 stud boxes (larger than the 21 × 19 stud outer bed borders, allowing at least 3.5 studs outside future borders). The contiguous customization lawn also returned zero path overlaps. Garden centers are staggered, future footprints have slight orientation differences, and the enlarged property gives them broad grass margins. Paths serve groups rather than wrapping every bed.
- AutumnReview carries the approved logo asset ID. The claim sign and raised status display SurfaceGuis are assigned to their Front faces toward the approach and bed; this pass has not been visually checked in Studio.
- After enlargement, the relocated sign successfully claimed the property, six test digs awarded six Sterne and random pepper seeds, and planting succeeded in the relocated four-slot bed. The cottage doorway remained clear.
- Output log was empty after testing.
- Refined pepper stages were checked in Play mode. Harvest removes the fruit while keeping mature foliage, and regrowth restores harvest-ready fruit. All crop parts remained nonblocking.
- Per-slot indicators were checked empty, staggered growing/ready, post-harvest regrowing, and fully occupied at 4/4. Each slot kept its own timer; harvesting kept the occupied count. Restarting Play reset the sign and plants to 0/4. The 4/6/9 indicator layouts were checked for clipping without granting upgrades.
- Saved previews: `build/pepper-refined-close.png`, `build/pepper-status-live.png` (actual Play mode), and `build/pepper-status-mixed-preview.png` (staged mixed-state UI preview).

Touch/controller behavior, multiplayer sessions, and prolonged play have not yet been tested. Geometry and art are a first construction pass, not final assets.

## Digging/UI repair checks

The reported session was unclaimed: the old script disabled the dig prompt and had granted no shovel. After claiming, real E input and equipped mouse clicks both awarded rewards; no broken reward callback or raycast dependency was found. The fix leaves a prerequisite prompt visible, explains rejected out-of-range tool use, adds explicit controls to both faces of the pit sign, and adds successful-action motion. Decorative crop CanQuery flags do not affect digging: the server checks ownership, living character, distance and cooldown, not mouse-hit identity.

Live input checks: eight held E actions gave eight Sterne and a random seed. In the compact UI pass, five successful digs gave five Sterne and three seeds; planting reduced seeds to two and set the bed to 1/4; harvest gave one pepper, removed fruit and started regrowth without changing occupancy. Diary entries matched those actions. Client-observed shovel grip moved during mouse input and returned to its resting transform. Inventory/Diary buttons and close buttons worked. A 360×640 layout harness checked narrow-screen bounds; actual touch/controller input is still untested.

The approved C coin PNG (`studio/assets/sterne-c-icon-v2.png`) is uploaded as `rbxassetid://79465188173312` and used on the dig sign. The balance display uses the same coin asset. The bell-pepper seed packet without a quantity badge is a reversible art preview (`rbxassetid://70460576376188`) shown in inventory only. The planter circles use the transparent low-poly bell-pepper icon (`rbxassetid://94516029859579`) with their growth rings.

The dig sign is a compact 9 × 7.5 stud panel with `DIG HERE` above large Sterne and pepper icons, each followed by `+1`. Matching faces are shown from both approaches. `studio/build/SyncDigSign.luau` applies the layout in Studio; `studio/build/patch_dig_sign_xml.py` applies it to the canonical Autumn Review place file.

The earlier Play pass used six real E digs (six Sterne, two seeds), planted one seed, and harvested the same persistent plant twice after regrowth. Counts and diary matched. An observed SurfaceGui text cache issue was corrected with a client refresh on replicated text changes. The new elevated display and shared box still need a Studio render and Play-mode sale check.

## Approved crop workshop — October 13, 2026

`build/AssetWorkshop.rbxlx` now preserves the approved pepper composition and adds a pumpkin study row at Z = -11, 11 studs behind the pepper growth row. Pumpkins have four purpose-built stages, two harvest-ready fruit, low vines, lobed folded leaves, and a separate fruit study. The reusable Ready template is approximately 3.76 × 1.42 × 3.47 studs.

All ten workshop captions are under `Workspace.WorkshopLabels.Pepper` / `.Pumpkin`, outside the plant studies and reusable assets. Crop templates remain in `ReplicatedStorage.AssetLibrary`. The pumpkin builder is `src/PumpkinWorkshop.luau`; run it only in AssetWorkshop after peppers and separate captions exist. It replaces only pumpkin containers. The pepper builder remains a full destructive workshop reset and should not be rerun to adjust pumpkins.

The approved visual direction and lessons are recorded in `../STYLE_CONTRACT.md`. Studio overview and close-up renders checked the first pumpkin pass. Saved XML checks confirmed separate captions, four pumpkin stages, matching builder sources, embedded native geometry, and preserved pepper part transforms/sizes/colors (serialization differences below 0.00000001). Crop physics flags were checked live.

These are visual studies, not production-optimized meshes: Studio CSG inflated the pumpkin body to 11,596 triangles despite 448 designed faces. The stalk, vine segment and leaf also have CSG overhead. Optimize/export clean meshes before bulk gameplay integration. No gameplay assets were replaced. Backup: `build/AssetWorkshop.before-pumpkin-pass.rbxlx`.

The older `save_pepper_snapshot.py` and pepper snapshot predate the separated caption hierarchy; use Studio Save for the current multi-crop workshop rather than restoring that old snapshot.

## Six-crop workshop extension

`src/CropWorkshop.luau` adds Grapes, Corn, Wheat, Lettuce, Potatoes and Carrots as six independent rows behind the pumpkin row, spaced nine studs apart (Z = -20 through -65). Each crop has four growth stages under `ReplicatedStorage.AssetLibrary.<Crop>GrowthStages`, a separate `<Crop>Harvest` model, and display-only captions under `Workspace.WorkshopLabels.<Crop>`.

Grapes use low timber trellises and three hanging clusters; corn has folded blades, husks, faceted kernels and tassels; wheat develops from green shoots into golden grain heads; lettuce builds a cupped rosette; potatoes have compound foliage, pale flowers at maturity and buried tubers; carrots have divided foliage with orange shoulders and buried tapered roots. Harvest studies expose the whole produce. These are art studies, not new gameplay or crop-system commitments.

The builder replaces only its own six crop rows and templates. Pepper and pumpkin studies remain unchanged. Preserve these existing rows when refining one crop. The same native CSG triangle overhead noted above applies: production mesh optimization remains separate from this visual pass. Backup: `build/AssetWorkshop.before-six-crops.rbxlx`.

Corn was revised after the initial review: shorter stalk, custom arching folded blades, staggered foliage, slimmer cobs with smaller kernels, and a lighter tassel. Studio close-ups checked this revision as well as the other five crop families. All stages are art previews pending user approval.

Corn husk pass: the mature and ready plants now have three cobs, with the upper cob slightly smaller. Five curved green husk panels wrap each ear; ripe ears expose yellow kernels through a shorter front opening. The separate corn harvest study uses the same husks. Backup: `build/AssetWorkshop.before-corn-husks.rbxlx`.

Grape/wheat shape and foliage pass: grape berries are rounder with tapered bunches; broader lobed leaves increase the mature/ready canopy to 12/14 leaves. Wheat has slimmer tapering grain heads, varied stalk heights, ten/eleven mature/ready stalks and three arching blades per mature stalk. Labels remain separate. Studio close-ups verified corn, grapes and wheat.

Corn silhouette revision: uneven leaf nodes, varied lengths/widths, yaw into depth, drooping lower blades and a narrower upright crown replace the regular horizontal ladder. All three wrapped cobs remain. Front and oblique Studio views checked. Backup: `build/AssetWorkshop.before-corn-silhouette.rbxlx`.

Ready potato tubers raised by 0.22 studs in both the display and reusable Ready template so their tops peek above the soil. Other growth stages, foliage, and harvest study remain unchanged. Studio close-up verified the visible potato tops. Backup: `build/AssetWorkshop.before-potato-peek.rbxlx`.

## Inventory asset workshop

`src/InventoryWorkshop.luau` adds 18 reusable Tools under `ReplicatedStorage.AssetLibrary.InventoryItems`: seed packets and harvest items for Pepper, Pumpkin, Grape, Corn, Wheat, Lettuce, Potato and Carrot, plus Watering Can and Fertilizer Bag. Seed packets have crop-colored seams, readable packaging and miniature produce emblems. Harvests reuse the existing crop geometry; the potato item is one tuber. Original crop assets and rows remain intact.

The item display is at X=23/27, Z=5 through -30. In Play, approach a plinth and use its prompt to add that item to the standard Roblox Backpack, then equip or unequip it. `InventoryWorkshopDemo.server.luau` handles workshop pickup with distance and duplicate checks. All 18 Tools passed live equip/unequip and noncolliding, massless, unanchored-part checks. The watering can grip and packaging were visually checked. Stable `ItemId`, `ItemKind` and `CropType` attributes support later inventory integration. These assets do not implement planting, watering, fertilizer consumption, stacking, or persistent inventory saves.

`build/InventoryItems.rbxmx` is the standalone reusable item pack. `save_inventory_snapshot.py` preserves embedded native CSG and writes the pack plus workshop file from `build/inventory-workshop-snapshot.json`. The rebuild source is also stored as `ServerStorage.InventoryWorkshopBuilder`. SurfaceGui MaxDistance is explicitly 150 so packaging is visible. Backup: `build/AssetWorkshop.before-inventory-items.rbxlx`. The directory has no Git repository, so no local commit was possible.

Persistence check: reopened the saved scene in a separate Studio instance; all 18 Tools equipped and returned to Backpack, with all 592 weld references resolved. `verify_inventory_snapshot.py` confirmed the entire original scene was preserved and the standalone pack's references and embedded meshes resolve. These inherit the crop workshop's CSG complexity and still need mesh optimization before bulk gameplay use.

## Background scenery variety — October 14, 2026

`background_scenery.py` updates only `Workspace.LunaLandingFirstPlot.AutumnDetails.AutumnForest` and `DistantMountains` in the current saved `build/LunaLanding-AutumnReview.rbxlx`. It must not be replaced by rerunning the older standalone world builder. Each run backs up its input and asserts that every other saved scene element is unchanged.

The background now contains 57 trees across six silhouettes: spreading oak, copper maple, golden birch, light-green aspen, tall fir and broad pine. Irregular groves, varied yaw/scale, overlapping faceted crowns and pale trunks break up repetition. Nine blue-gray ridge and sage foothill groups use offset peaks, twin summits, broad shoulders and descending crests. Routes and the property remain open.

`build/BackgroundScenery.rbxmx` is a standalone pack of the placed scenery. `build/LunaLanding-BackgroundReview.rbxlx` is a review copy of the saved gameplay scene, opened in Studio for this pass. The canonical gameplay file remains AutumnReview. Both include the farming integration; the old open Edit copy encountered during the pass did not.

Verification: full saved-scene comparison excluding the two replaced folders; reloaded Studio overview and grove close-up; 57 trees and nine ridge groups; all 8,319 scenery parts anchored, noncolliding, nontouching and nonqueryable. These are portable native wedge assemblies with no external mesh dependencies or runtime builder. The part count is higher than the old simple background; mesh consolidation and device performance profiling remain appropriate before expanding the world. No gameplay code or workshop assets were changed. No Git repository exists in this folder, so no local commit could be created.
