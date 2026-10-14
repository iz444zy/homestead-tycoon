# Working files — table of contents

## Start here

| File | Role |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Workspace instructions, approval rules and file discipline |
| [STYLE_CONTRACT.md](STYLE_CONTRACT.md) | Approved visual language and plant benchmark |
| [CONCEPT.md](CONCEPT.md) | Gameplay scope and unresolved decisions |

## Active Roblox experiences

| File / scene | Role |
| --- | --- |
| [MarketWorkshop-v2.rbxlx](studio/build/MarketWorkshop-v2.rbxlx) | **Sole active market workshop.** Save edits here. Stage alternatives beside existing models and wait for approval before replacement. |
| [AssetWorkshop.rbxlx](studio/build/AssetWorkshop.rbxlx) | Approved plant and inventory asset workshop; preserve original assets |
| Connected **Homestead Tycoon: Luna Landing v1** | Live gameplay scene; inspect/export current state before reconciliation. Do not replace it from an older disk file. |
| [LunaLanding-AutumnReview.rbxlx](studio/build/LunaLanding-AutumnReview.rbxlx) | Existing local gameplay build; not proof of the connected live scene's current state |

## Market working sources

| File | Role |
| --- | --- |
| [MARKET_ASSETS.md](studio/MARKET_ASSETS.md) | Asset notes and validation history; current user approval takes precedence |
| [revise_seed_truck.py](studio/revise_seed_truck.py) | Historical truck builder; automatic place-file generation is disabled |
| [build_market_assets.py](studio/build_market_assets.py) | Shared model helpers and historical initial builder; automatic place-file generation is disabled |
| [TruckRiders.server.luau](studio/src/TruckRiders.server.luau) | Standing hold validation, attachment and release |
| [TruckRiders.client.luau](studio/src/TruckRiders.client.luau) | Jump-to-release input |
| [MarketAssets.rbxmx](studio/build/MarketAssets.rbxmx) | Existing reusable export; update only after design approval, not for unapproved studies |

## Visual references

| File | Role |
| --- | --- |
| [Seed truck](concept/pngs/05-market-truck.png) | Vehicle silhouette, palette and cargo character |
| [Community market](concept/pngs/12-community-market.png) | Market hub concept |
| [Sell stall](concept/pngs/13-player-market-stand.png) | Stocked/empty stall construction |
| [Community grocery](concept/pngs/17-community-grocery-sheet.png) | Grocery architecture and selling counter |
| [Concept prompts](concept/prompts) | Text accompanying concept images |

## Gameplay and UI sources

| Location | Role |
| --- | --- |
| [studio/README.md](studio/README.md) | Existing implementation history and studio setup |
| [studio/src/farming](studio/src/farming) | Farming runtime, domain, inventory persistence, house chest and checks |
| [studio/src/ui](studio/src/ui) | UI components and interactions |
| [FARMING_LOOP.md](studio/FARMING_LOOP.md) | Farming-loop implementation notes |
| [UI_INTEGRATION.md](studio/UI_INTEGRATION.md) | UI integration notes |
| [studio/assets](studio/assets) | Existing image assets and UI atlas |

## Historical files — do not use as new working versions

- `studio/build/MarketWorkshop.rbxlx`: superseded by `MarketWorkshop-v2.rbxlx`.
- `studio/build/market-checkpoint-*`, `truck-before-*`, `truck-after-*`: historical copies, retained without deletion; do not create more place-file checkpoints.
- `studio/build/*.before-*`, `LunaLanding-FirstPlot.rbxlx`, `LunaLanding-AutumnFinal.rbxlx`, `LunaLanding-BackgroundReview.rbxlx`, and old live/UI snapshots: historical material, not automatic sources of truth.
- `studio/build/truck-v2-sync.json`, `truck-v2-report.json`, `market-assets-report.json`: earlier generated sync/validation data; may be stale after live edits.
