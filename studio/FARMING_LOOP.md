# Farming loop integration — October 14, 2026

The saved game is `build/LunaLanding-AutumnReview.rbxlx`. The world, eight growing-area reservations, and first area's four slots are preserved. Apples, additional area unlocks, a moving truck, player trading, and processing were not added.

## Configuration and local play

`src/farming/Catalog.luau` is the shared crop/item/economy catalog. In Studio it is `ReplicatedStorage.Farming.Catalog`. It contains all eight stable crop IDs, their existing `CropType` and item IDs, explicit packet/produce Tool references, stage paths, first-growth/regrowth/care durations, weighted yields, pack prices, sale prices, equipment, quality multipliers, and the NPC market multiplier. All requested prices and normal timings remain intact as configurable first-playtest defaults. Area-tier bonuses are reserved at zero.

`src/farming/Settings.luau` is server-only (`ServerStorage.Farming.Settings`). It controls persistence, request cooldowns, distance, storage limits, the existing four unlocked slot IDs, and explicit Studio test settings.

**The canonical saved file uses real persistence and has StudioTest disabled.** This is still an unpublished local place, so Roblox cannot provide its DataStore. The game displays an explanation and blocks progress rather than silently substituting new data.

For a local, unsaved playtest, edit `ServerStorage.Farming.Settings` before Play:

```lua
StudioTest={Enabled=true, UseMemoryStore=true, TimeScale=1, StartingSterne=0}
```

That retains normal economy and growth defaults, with a visible **STUDIO MEMORY — NOT SAVED** notice. Tests used explicit time scales and fixture funds only in live test sessions. None of those overrides or test crops are in the saved gameplay file. For persistent testing, publish a private test place, enable its Studio API access, and leave StudioTest disabled. Production ignores StudioTest entirely. Do not use the production store for destructive test fixtures.

## Controls and loop

Current UI/control documentation and verification: [UI_INTEGRATION.md](UI_INTEGRATION.md).

Aim at a nearby object, then press E/controller X or click/tap explicitly. The cue follows the target. Shovel digs; selected seeds plant directly; empty slots without a selected seed open the compact picker; can waters; fertilizer helps a neighbor; Ready crops harvest with the hand action. The server checks the same target/tool rules. Hover never performs work.

Bag (button or I/D-pad Up) contains paged Seeds, Produce and Tools. The house chest stores whole stacks by default and offers Amount for partial transfers; stored tools remain owned but unavailable until retrieved. Quality stacks remain separate. The toolbar remains usable during chest interaction. Escape/controller B/close dismiss panels. The existing market offers purchases and deliberate quote-based sales.

The custom native toolbar replaces the default backpack UI. All item grids use the uploaded raster atlas, with separate counts and quality symbols. Landscape layouts show fewer choices rather than smaller controls.

## Authority and persistence

- `Domain.luau` contains crop transitions, interval coverage, weighted yield, per-unit quality, purchases, and sales. Only server callers can award items.
- `Runtime.server.luau` validates a living character, distance, ownership, unlocked slot, balance, seed/produce stock, readiness, cycle identity, revision, held care equipment, and cooldowns. Actor/recipient locks serialize neighbor actions; a separate claim lock prevents simultaneous owners.
- `ProfileStore.luau` uses a versioned player profile with UpdateAsync, session leases, optimistic revisions, operation identities, and retries for ambiguous writes. Mutations become visible only after the complete profile commits. Failed loads never write defaults. Failed writes pause further mutations until recovery.
- Profiles save Sterne, seeds, quality stacks, can ownership, fertilizer charges, crop/slot assignments, timestamps, care records, cycle identity and random seed, last resolved harvest, helper sequence/intent, and care receipts. Instances are reconstructed, never saved.
- A saved cycle seed fixes harvest randomness. Capacity failures, save retries, and reconnects cannot reroll a frozen crop. Awards and the next plant state are one profile commit.
- Fertilization records a durable helper intent, commits the owner's care receipt, and then consumes one helper charge. Recovery resolves success or writes a terminal cancellation that fences late owner writes. A pending intent blocks additional actions until settled. Receipts retain the latest sequence per helper.
- Growth uses server Unix timestamps. Offline time can finish the current cycle; it cannot harvest, start another cycle, spoil crops, or generate payouts.
- Version 1 farming profiles migrate in place to version 2 with empty Chest storage and transfer receipts. Existing progress stays intact in the same DataStore namespace. Invalid profiles fail closed without writing defaults.

## Assets and build

`build_farming.py` patches the canonical place without running either world or workshop builders. It imports 34 reusable growth models and the 18 Tools with embedded CSG. Workshop labels, plinths, demo scripts, pickup interactions, and construction templates are excluded. Source asset files remain byte-identical.

Crop templates live in `ServerStorage.FarmingCropAssets`. Only the current model for each planted slot enters Workspace; decorative parts are anchored, noncolliding, nontouching, and nonqueryable. Tools live in `ReplicatedStorage.FarmingAssets.InventoryItems`; equipped parts are welded, unanchored, massless, noncolliding, and cannot be dropped. The UI uses atlas ImageLabels for icons, not cloned models in inventory ViewportFrames.

The older workshop XML omitted stable model pivots. `World.luau` explicitly sets each clone's pivot to the authored soil origin before applying the slot CFrame. This preserves the approved geometry, orientation, and native scale across stages instead of using Roblox's inferred rotated bounding-box pivot.

Run `python studio/build_farming.py` from the repository root after editing source. The builder creates a dated gameplay checkpoint before each write and verifies references, embedded mesh blobs, world equality, and asset-source hashes. Backups include `build/LunaLanding-AutumnReview.before-farming-*.rbxlx` and `build/LunaLanding-AutumnReview.checkpoint-*.rbxlx`. This directory is not a Git repository; commits are unavailable.

## Verification

Machine-readable evidence: `build/farming-verification.json`. Build evidence: `build/farming-build-report.json`.

- **80,546 domain/store assertions passed.** Both pack sizes and exact settings for every crop; invalid/occupied/locked planting; stage boundaries; first, subsequent and partial care intervals; Ready freeze; zero, partial, full, and fertilizer-only quality distributions; regrowth/reset; slot clearing; capacity rejection; deterministic retries; duplicate sales; final-only rounding; malformed quantities; load failure, corrupt schema, competing leases, lost acknowledgements, stale revisions, and helper cancellation races.
- **80,000 sampled harvests:** 10,000 per crop. Observed yield frequencies stayed within two percentage points of configured weights, and every family produced mixed-quality harvests.
- **2,477 live runtime assertions passed** in the final full-loop regression. All crops purchased, planted, rendered at every stage, watered, harvested, equipped/stored, and sold through the actual runtime. Model soil alignment, upright stakes/trellises, physics, welds, failed/repeated actions, pepper/grape second harvests, sale-stack cleanup, and death/respawn inventory preservation were checked.
- **34 checks passed in a real three-client Studio session.** Simultaneous claims, two neighbors racing to fertilize, ownership rejections, independent watering, charge accounting, repeated concurrent harvesting, saved-profile reload, pending-help recovery, and offline completion. Store writes deliberately yielded to expose interleaving. Reload tests used the injected memory backend, not Roblox's production DataStore.
- Real keyboard input claimed via E, opened the shop via R and inventory via I. Actual button clicks bought a four-seed pack, planted, and harvested. At explicit 6× speed a lettuce transitioned through Planted, Developing, Mature, and Ready in about ten seconds; it awarded mixed-quality produce and cleared its slot. Mouse activation of the held watering can applied care to the targeted plant.
- iPhone 17 Pro landscape emulation verified touch-enabled inventory, equip interactions, scrolling, feedback placement, and the actual can preview. Xbox emulation verified layout and selection focus. Studio's virtual-input tool rejected gamepad button injection as a CoreGui-bound action, so physical controller activation remains unverified. This game is landscape-only. Studio was reset to its default viewport afterward.
- The unpublished-place save failure was exercised: inventory stayed unloaded and defaults were not written. A published-place DataStore/rejoin test remains necessary before release.

## Measured performance and remaining limits

At the tested 789×870 desktop viewport, the same bed-facing camera measured **26,386 non-shadow triangles / 33 draws** without crops/previews, versus **903,048 / 44 draws** with four Ready crops (pepper, grape, corn, wheat) and planter previews. A 120-frame desktop sample measured **16.56 ms median / 18.29 ms p95**. These are one machine and viewpoint, not mobile or full-capacity guarantees.

Ready-template CSG triangles (excluding primitive parts): Pepper 60,272; Pumpkin 42,752; Grape 103,838; Corn 485,538; Wheat 226,930; Lettuce 15,000; Potato 32,426; Carrot 20,502. The four-crop fixture alone contains 678 BaseParts. Appearance is preserved; mesh simplification remains necessary before considering 72 plants per property or 576 across a village. No maximum-capacity performance claim is made.

The current world still has one claimable property. Multiple clients can visit and help, but this pass does not create additional properties or invent unlock prices. Production persistence, hardware touch/controller behavior, mobile GPU performance, and long-duration multiplayer soak testing remain release checks. The full truck, NPC grocery building, market fluctuations, and player trading systems remain outside this integration.
