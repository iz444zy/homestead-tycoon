# Native UI and house chest integration — 2026-10-14

Implemented in the real Luna Landing place (113237857204007), using native Roblox controls and the uploaded atlas. The approved farm/crop assets were retained.

## Current controls

- Aim at a nearby object. Its cream action cue follows the object. E, controller X, or an explicit world/cue click performs the current action. Hover never works or spends an item.
- The five-button toolbar holds shovel, can, selected seed/produce, fertilizer and Bag. Roblox's default backpack is hidden. Bag remains available when stacks empty.
- Empty slots open Seeds if no seed is equipped. Selecting a packet equips and closes; planting needs another explicit action. The remembered planting seed is separate from temporary produce.
- Ready crops use the hand action regardless of equipped tool. Care/stock/wrong-tool states are short cues. UI focus blocks world actions.
- Bag has Seeds/Produce/Tools and paging; the landscape version shows two large items beside category buttons. Other small-screen grids show three.
- The house chest is inside the existing cottage, near its front/right corner. Its lid opens without changing the camera. Select a carried item, Store its whole stack, or select stored stock and Take. Amount changes quantity only; transfer remains deliberate. The toolbar works while Chest is open.
- Market at the existing produce box offers Buy and Sell. A sale requires a server quote and final confirmation showing quality, quantity, unit value and total.

## Persistence and safeguards

Profiles migrate from version 1 to version 2 in the same `LunaLandingFarming_v1` namespace. All old balances, counts, ownership, plants, care and timestamps remain carried/current; Chest starts empty. Equipment ownership is retained while carried availability subtracts stored equipment. Hotbar entries reference inventory.

Deposit/Withdraw validate actual chest, owner, range, line of sight, focus, item/quality, integer quantity, stock, revision and safe numeric limits. Each transfer commits one complete candidate profile through the existing lease/revision/ambiguous-save system. Bounded request receipts make exact retries idempotent; stale revisions fence older requests after receipt pruning. Failed/pending saves do not render candidate quantities.

The former representation-only Store is now PutAway internally. It does not deposit stock.

## E/click fixes verified during integration

1. Digging decorations no longer block their own patch's line of sight; unrelated world blockers still do.
2. Current ray hit/nearby aim is resolved for the explicit action; there is no Tool.Activated callback to a remembered planting target.
3. Panel Close/Focus are separated from gameplay cooldown. Selecting a seed can no longer leave invisible server focus blocking Plant.
4. Pointer/world projection uses viewport coordinates; UI hit testing converts to the Core UI inset coordinate system, including device safe areas. A toolbar hit cannot be inferred from the wrong vertical inset.
5. The action cue follows the current object, as requested. Panel dismissal is suppressed from world activation.

## Verification performed

- Existing domain/store regression: **80,546 assertions passed**, preserving crop prices, yields, intervals and quote rules.
- New storage contracts: **455 assertions passed**. Full/partial conservation for seeds, all four produce qualities, fertilizer and equipment; invalid/excess quantities, empty/capacity failures, migration, failed/ambiguous writes, duplicate/stale revisions, lease contention and reconnect through injected stores.
- New live server integration: **25 assertions passed**. Actual chest reference, full/partial transfers, quality isolation, stored tool availability, immediate close after Equip, picker-to-Plant, range rejection and decorative/real LOS blockers.
- Actual desktop input: claim; equip; Dig with E and with click; picker selection without planting; repeated planting on two different slots; water only the aimed slot; harvest while holding the can; equip Gold produce; Store whole stack; Amount without mutation; partial Take; store/retrieve can; quote and sell; deliberate purchase.
- Real player character respawn: carried/stored Blue, Silver and Gold stacks and stored watering-can ownership were conserved (4 assertions).
- Exact manual receipts: 5 Gold lettuce stored, 3 taken, 2 left stored; other qualities unchanged. Sale: 5 Gold lettuce × 28 = 140 Sterne. Purchase: 4 lettuce seeds for 16 Sterne.
- All **24** uploaded sprites loaded and were visually inspected in a temporary native gallery at 88-pixel icon size, on light and green backgrounds. Complete can spout, proportions, alpha edges and no adjacent sprite bleed were checked. Gallery was removed by stopping Play.
- Roblox serves this atlas as **682×1023**, despite the source being 1024×1536. UIAssets scales each individual manifest rectangle to served dimensions. This fixed the blank lower rows; the source artwork pixels remain unchanged.
- Fresh desktop and landscape iPhone 13 simulator captures are in `build/ui-evidence-20261014/`: resting, world cue, Seeds, Bag, Chest, sale review and the 24-sprite check. Large tool targets, text, safe-area spacing, paging and absence of broad modal backdrops were inspected.
- Final gameplay session had no game-script errors. Console diagnostics include expected injected store failures and Studio automation warnings for CoreGUI interception; earlier implementation/test-fixture errors were corrected.

## Verification limits

Production DataStore writes/reconnect, physical phone/controller input and a second real player were not exercised. Studio's virtual input rejects controller B/X as protected CoreGUI keys. Controller bindings/focus are implemented but not certified on hardware. Reconnect and ambiguous save coverage used injected adapters; do not interpret that as production-service certification. The neighbor-help persistence regression passed in the existing domain suite, but a two-human-client help loop was not exercised in this UI pass.

## Safe reconciliation and saved files

Initial live scripts matched local source, while several scripts in the old canonical XML were older. The live place was preserved before editing as `build/LunaLanding-live-before-ui-20261014.rbxlx.rbxl`, alongside `ui-live-before-20261014.json` and a full source/file checkpoint. No old local place was loaded over cloud work.

The final cloud place was saved with StudioTest disabled and no active fixtures. A fresh Download a Copy was opened separately and saved as XML. All 21 source mappings matched the exported XML before it replaced `build/LunaLanding-AutumnReview.rbxlx`; `build/ui-build-report.json` records checksum and backup. Thus the canonical local file comes from the current Studio world, including the chest.

`build_farming.py` still patches source/assets in place and creates a checkpoint; it never runs the world builders. Before future edits, compare live Studio work again. The uploaded atlas and UI helpers live under `src/ui`; farming, chest and transaction code under `src/farming`.

Git is unavailable: `git rev-parse --show-toplevel` reports no repository. No repository was initialized. Meaningful checkpoints: `ui-checkpoint-20261014-013250`, `ui-checkpoint-20261014-020724`, `ui-checkpoint-20261014-022257`, plus the pre-export canonical backup.

Final clean source/place checkpoint: `build/ui-checkpoint-20261014-022957`. The selected tool lifts four logical pixels (verified in Play), with reduced-motion handling. Cloud save was confirmed at 02:28:36; Save to Roblox was used, not Publish. The final canonical XML is a clean Studio export and all 21 script mappings match local source.
