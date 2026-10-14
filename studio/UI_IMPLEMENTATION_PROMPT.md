# Implement the Luna Landing UI and house chest in Roblox

Implement the approved UI redesign directly in the actual Roblox game, using native Roblox UI and the prepared image assets. Complete the functional gameplay integration, persistence, and in-Studio visual verification. Do not create another HTML, browser, website, or detached mockup implementation.

Work in `C:\Users\isalu\OneDrive\homestead-tycoon`. Read the project instructions and inspect the current source and connected Studio place before editing. The last observed Studio place was **Homestead Tycoon: Luna Landing v1**, place ID **113237857204007**; verify this rather than assuming the connection is unchanged. The existing local gameplay file is `studio/build/LunaLanding-AutumnReview.rbxlx`. Determine whether live scripts or the local file have newer work and reconcile safely before applying changes. Do not overwrite newer Studio work with an older local build.

Stage and create local commits after meaningful changes when a Git repository is available. This folder was previously verified not to contain a Git repository; verify again, and if that remains true, use dated checkpoints and report that commits are unavailable. Do not initialize Git solely to satisfy the commit instruction.

**Visual references and ready assets**

Open and inspect these actual files before implementation:

- `concept/ui/seed-selection-approved-direction.png` — primary approved UI appearance: warm cream, deep green, big icons, clear numbers, rounded surfaces, compact toolbar and seed picker.
- `concept/ui/house-chest-concept.png` — matching chest layout study. Its Store/Amount flow is requested; exact layout must remain compact at real gameplay sizes.
- `studio/UI_REDESIGN_PLAN.md` — interaction and visual plan. The chest requirements in this prompt extend that plan and supersede its earlier inventory-only scope.
- `studio/assets/ui-v1/items-atlas.png` — 1024×1536 transparent PNG containing 24 reusable item images.
- `studio/assets/ui-v1/manifest.json` — exact sprite rectangles, item keys, colors, dimensions, and texture checksum.
- `studio/src/ui/UIAssets.luau` — prepared atlas lookup and ImageLabel helper.
- `studio/src/ui/UIPrimitives.luau` — prepared code-drawn control/status symbols; review and refine as needed.
- `studio/build_ui_assets.py` and `studio/assets/ui-v1/asset-verification.json` — atlas indexing and alpha/region checks. The script reads artwork without modifying its pixels.

The atlas is already uploaded as **`rbxassetid://98237999999525`**. It contains eight seed packets, eight produce icons, shovel, watering can, fertilizer sack, bag, Sterne coin, closed chest, open chest, and hand. Use the manifest's individual source rectangles, not a naive equal-cell crop: the watering-can spout crosses its nominal cell. Preserve proportions. Verify image loading, transparency, dimensions, moderation/permissions, and every sprite in Studio; an upload result is not a completed runtime visual check. Use ImageRectOffset/ImageRectSize correctly and prevent adjacent-sprite bleed.

The generated concepts are appearance references, not screenshots of implemented behavior. Their farm scenery and avatar are illustrative; do not rebuild the world or replace approved crop assets to match that scenery. `preview.html`, `preview-data.js`, and `preview-background.png` are a superseded browser experiment. Do not extend them or treat their interactions as finished Roblox code.

**Required screen design**

Keep the farm visible. No full-height inventory sidebar, screen-filling modal, persistent instructions, or broad dark backdrop. Show fewer choices per page rather than shrinking controls.

Use warm cream panels, deep-green bold text, rounded corners, light shadows, and the colorful item artwork. Match the reference's balance, spacing, icon prominence, and selected outline as closely as native Roblox UI allows. Avoid default gray menus, ornamental wood frames, placeholder emoji, or a generic dashboard appearance.

Use numbers and icons wherever they communicate clearly. Normal labels are one or two words: Seeds, Bag, Chest, Plant, Water, Harvest, Store, Take, Amount. Keep them large. Start with 24–28 logical-pixel labels, larger numbers, 72–88-pixel desktop tool buttons, and at least 64-pixel small-screen tool targets. Verify actual readability rather than relying solely on those values.

The resting HUD contains the star coin plus balance in one corner and a short bottom row for shovel, can, selected seed/item, fertilizer, and bag. Show a strong active-tool outline. Show remaining counts on consumables; omit meaningless counts on reusable tools. Replace or coordinate Roblox's default backpack so there are not two competing toolbars. The bag must remain accessible even when a carried stack becomes empty.

Use text-free packets and produce artwork. Counts, selection marks, and quality badges are separate UI layers. Show the short crop name on hover/focus/selection rather than under every item. Distinguish seed packets from harvested produce and all eight crop types. Common has no quality badge; Blue, Silver, and Gold each use a distinguishable symbol as well as color. Do not put harvest quality on growing plants.

**World interactions**

Hover or aim selects one nearby valid world object and reveals its short action. E, controller X, or an explicit click/tap performs that action. Hover alone never consumes an item or performs work.

- Shovel + digging patch: Dig directly.
- Selected seed + empty owned slot: Plant one directly and keep that seed selected.
- Empty slot with no seed selected: open the compact Seeds picker.
- Can + owned growing crop with care available: Water directly.
- Fertilizer + eligible neighbor crop: Help directly, spending one charge.
- Ready owned crop: Harvest directly as a hand action, without inventing a new harvest-tool requirement.
- Wrong tool: show the required tool icon and short cue, and highlight the relevant toolbar control.
- Growing, already-watered, empty-stock, out-of-range, and other-owner states: concise icons/numbers/labels without opening a panel.

Use the same target and tool rules on the server. Remove the current stale-target behavior where a held item may operate on the previously prompted slot. Do not allow UI clicks to activate world tools behind the UI. Disable world-action input while a picker or transfer panel owns focus. Respect range, line of sight, ownership, readiness, care interval, stock, and server cooldowns.

The Seeds picker is small, shows large packet images and owned counts, and remembers the last choice. Selecting a packet equips it and closes the picker; the next explicit world action plants. Do not silently substitute a different seed when a stack reaches zero.

**Bag, hotbar, and house chest**

Implement an actual interactable house chest and a matching compact inventory view. The user explicitly chose **whole-stack storage by default, with an optional quantity picker**.

Place a modest reusable timber chest with simple dark metal bands at a reachable location inside or beside the existing cottage, preserving approved architecture and paths. No reusable world chest model was created during asset preparation: inspect for an existing suitable model, otherwise build one. Keep body, lid, interaction anchor, and any UI separate. Make the lid open/close neatly; avoid oversized treasure-chest ornament or intrusive camera changes.

Hover/approach the chest and press E/controller X/tap Chest to open its inventory. The hotbar stays visible and usable while this compact panel is open.

- Select a carried hotbar item and choose **Store** to move the entire selected stack into the house chest.
- Select a chest stack and choose **Take** to move it back into carried inventory.
- **Amount** opens a small minus/plus/All quantity choice. Whole stack remains the default; choosing a quantity does not itself transfer items.
- Support seeds, produce quality stacks, fertilizer charges, and reusable equipment without duplicating ownership or quantities. A stored reusable tool remains owned but is unavailable for use until retrieved.
- The bag provides access to carried Seeds, Produce, and Tools through a compact paged grid. Selecting a bag item can equip it into the selected-item hotbar position so produce can also be stored from the hotbar. Preserve the remembered planting seed separately from a temporarily held produce stack.
- Treat hotbar positions as references to carried inventory, not a second copy of item counts. Taking a stack merges only with the same item and quality. Storing the selected stack clears or disables its equipped representation appropriately.
- Preserve Blue/Silver/Gold stacks individually through store/take, equipment changes, respawn, and reconnect.
- Six visible chest slots in the concept are a page layout, not a newly invented six-stack storage limit. Use paging and existing safe numeric limits; do not add a paid capacity upgrade or arbitrary economy restriction.
- Escape, controller B, or the close button closes the panel. Walking out of range or losing valid ownership cancels interaction. A dismissal tap must not also perform a world action.

The current runtime's `Store` action only puts away a held representation. Replace ambiguous UI wording with Put Away for that behavior or another clear separation. Actual chest deposit/withdrawal must have distinct, server-validated operations.

**Persistence and existing game behavior**

Inspect `studio/src/farming/Domain.luau`, `Runtime.server.luau`, `ProfileStore.luau`, `Representations.luau`, `Catalog.luau`, `Settings.luau`, and `Interface.client.luau`, plus `studio/FARMING_LOOP.md` and the build workflow.

Add the chest to the player's real saved profile, keeping carried and stored inventory separate. Safely migrate existing profiles without resetting balances, seeds, quality stacks, tool ownership, care history, planted crops, or timestamps. Existing items remain carried; new chest storage starts empty. Do not change the DataStore namespace to sidestep migration. Invalid profiles must still fail safely without writing defaults.

Server-side transfer operations must validate the actual chest, distance, ownership, item/quality, integer quantity, available carried/stored stock, revision, and limits. Subtract and add as one committed transaction. Handle duplicate requests, concurrent requests, retries after an ambiguous save, and disconnect/rejoin without item loss or duplication. Render successful transfers only after authoritative success; show a short pending state while processing. Failed transfers leave both inventories unchanged.

Keep current prices, yields, growth/regrowth, watering effects, neighbor-help rules, persistence guarantees, and quote-based sales intact. Shorten the shopping and sale UI to fit the same design, preserving quantities, affected quality stacks, unit values, totals, and deliberate purchase/sale confirmation. No new truck, processing, trading, housing progression, or crop redesign belongs in this implementation.

**Inputs, feedback, and performance**

Support desktop, landscape touch, and controller. Touch and controller cannot depend on hover. Preserve movement/jump controls and device safe areas. On smaller screens, show fewer choices and reflow; do not shrink text into tiny labels. Use obvious focus, non-color cues, and sufficiently large close/page/quantity controls.

Use short, satisfying motion: small press response, selected-tool lift, compact item +count harvest receipt, and droplet/check care feedback. Preserve reduced-motion behavior. Avoid stacked notification spam. Keep actionable save/connection failures visible with short labels and a readable Details path when necessary.

Use the raster atlas for grids rather than cloning many high-detail models into ViewportFrames. Keep approved plant geometry unchanged. Centralize tokens, component styles, item mappings, and input handling so the seed, bag, chest, shop, and sale views remain consistent.

**Verification and delivery**

Test the real Studio implementation, not the browser experiment. Allow at least ten minutes for long-running test processes. Add focused tests for the new storage and interaction risks rather than snapshot tests that merely mirror layout code.

Verify full-stack and partial store/take, empty stacks, invalid/excess quantities, quality separation, stored equipment, capacity rejection, duplicate/racing requests, failed/ambiguous saves, existing-profile migration, respawn, and reconnect. Total quantity across carried inventory and chest must be conserved. Check that other players cannot access the owner's chest and that out-of-range requests are rejected.

Exercise the full farming loop through actual input: equip, dig, pick seed, repeated planting, water/help, harvest, equip produce, store, take, sell. Check stale target prevention and UI click-through. Validate all 24 uploaded sprites against the concept at actual use size, including alpha edges and the complete watering-can spout.

Capture fresh gameplay screenshots of the resting HUD, world action, Seeds, Bag, and Chest at desktop and landscape phone sizes. Inspect overlap, clipping, text size, controller focus, image loading, and console errors. Keep test fixtures out of the saved gameplay file. Report any checks that genuinely could not be performed, especially production persistence or physical-device checks.

Update local source, the correct gameplay place through the established safe build/save workflow, and concise integration notes. Preserve unrelated work. Finish with the implemented behavior, actual verification results, screenshots, changed paths, and commit/checkpoint information. Do not stop at another plan, concept image, asset list, or standalone preview.
