# Luna Landing UI redesign plan

October 14, 2026. Draft for discussion before concept images and implementation.

The farm should stay visible while the player works. Use a few large, readable controls, recognizable item art, and one contextual action at a time. Make room by showing fewer things, never by shrinking text or icons.

**Confirmed direction**

- Minimal words: numbers, icons, and large one- or two-word labels.
- No large menus covering the play view. Small popups appear when a choice is necessary.
- Hover or target an object, then act with E or the equipped tool.
- A small visible row of tool icons.
- Warm cream, deep green, rounded shapes, and colorful 3D item icons.
- Remove unnecessary lettering from seed and produce icons.
- Finish planning before generating UI concept images.

The interaction details, dimensions, and sequence below are proposals. Existing crop rules, prices, quality names, and progression remain governed by the gameplay catalog and concept document.

**Why the current interface feels heavy**

The current farming UI uses a nearly full-height panel, capped at 500 by 700 logical pixels, for inventory, crop actions, shopping, and sales. It repeats item names, quantities, equipment instructions, and explanatory prose in rows. Labels use 16-pixel text and some compact descriptions shrink to 13 pixels. Targeting a growing crop opens this same panel even when watering is the only useful action. The live Studio view showed that panel covering roughly the right third of the scene.

The replacement separates ordinary work from choices: work happens directly on the world target; choices use a compact tray.

**The resting screen**

| Element | Appearance | Behavior |
| --- | --- | --- |
| Balance | Approved octagonal Sterne coin and one large number | Small corner capsule; no repeated currency name |
| Tool row | Four large icons: shovel, can, seeds, fertilizer | Bottom center; active icon has a clear outline and raised position; fertilizer appears when owned |
| Bag | One large bag icon beside the row | Opens the compact inventory tray; I remains a shortcut |
| Context action | Target outline, input glyph, action word | Appears only for the single nearby target the player is inspecting |
| Result | Item icon and +number | Brief feedback beside the action or tool row, then disappears |

The Seeds position displays the selected packet and its remaining count. Fertilizer shows remaining charges. Reusable tools do not need counts. Press an already-selected shovel, can, or fertilizer icon again to put it away. Press the already-selected Seeds icon to change the packet; its picker includes a hand icon for putting the packet away. Keep optional settings/help out of the main action row; an unobtrusive settings entry can expose them on demand.

No permanent crop list, instruction paragraph, task feed, or inventory summary. The central world view stays clear. Existing world signs should follow the same economy: large crop pictures, progress rings, and brief status symbols without duplicating a screen panel.

**Direct interaction rules**

Hover identifies a target; it never spends, plants, waters, or harvests by itself. E and an explicit click/tap are the action inputs. Highlight one valid nearby target, keep it stable as the cursor moves slightly, and never allow a click on UI to also activate a tool behind it.

| Target and held item | Visible prompt | Result |
| --- | --- | --- |
| Digging patch with shovel | Shovel icon, E, Dig | One digging action and compact reward feedback |
| Empty slot with a selected seed packet | Packet icon, count, E, Plant | Plant one seed directly; preserve selection for the next slot |
| Empty slot without a selected seed | Packet icon, E, Seeds | Open the seed picker |
| Growing owned crop with can, care available | Droplet icon, E, Water | Water once; brief droplet/check feedback |
| Growing neighbor crop with fertilizer, help available | Fertilizer icon, E, Help | Apply one charge; show the new count |
| Ready owned crop | Hand icon, E, Harvest | Collect directly; brief item/quality counts |
| Growing crop without an available action | Progress ring and remaining time | Inspect without opening a menu |
| Wrong tool for the target | Required tool icon, Need Can or Need Shovel | Highlight the matching tool-row slot; no large error or automatic tool swap |
| Care already applied | Droplet/check, Watered | Noninteractive state; no repeated warning |
| Another player's ready crop | Lock symbol, Not Yours | Inspection only |

Harvesting is proposed as a hand action available without adding a new harvest-tool requirement. Seed selection equips the chosen packet. Correct equipment must gate planting, digging, watering, and fertilizing consistently in both the interface and server validation. This is an explicit change to current paths that allow panel planting and prompt digging without the matching held item.

The prompt always describes the action E will perform on the highlighted target. With a popup open, E must not also act on the world. Losing range or line of sight cancels actionable targeting. Clicking empty ground must never act on a previously selected plant.

**Seed picker**

- A small cream tray titled Seeds, placed beside the target without covering it. Clamp it to the safe screen area. It opens on an explicit Seeds action, not every hover.
- Show owned crops as large packet pictures and counts. Zero-stock crops are omitted from this quick picker; an empty tray uses a packet symbol, No Seeds, and a Dig shortcut cue.
- Desktop: at most eight visible choices in a four-by-two grid. Small landscape screens: four choices per page in a two-by-two grid with large arrows.
- Selecting a packet equips and remembers it, then closes the tray. It does not also consume a seed. E or a world click plants in the highlighted slot.
- Opening the Seeds tool-row position lets the player change crops. A normal tool-row click equips the remembered packet; provide a clear second-click/change affordance when already selected.
- Packet art carries the crop identity. Only the hovered or focused choice needs a large crop name, such as Pepper. Touch selection shows that name briefly above the equipped packet.
- When the selected crop reaches zero, show its empty count briefly and return to the picker on the next planting action. Never silently plant a different crop.

**Inventory, shopping, and sales**

Inventory becomes a shallow Bag tray with Seeds and Produce tabs, a small grid, and page arrows. Tools already have their own row. Each tile is primarily item art, a count, and an optional quality badge. Selecting an item opens at most one compact detail/action area with its short name and Hold or Store. Avoid repeated sentences underneath tiles. Preserve clear access to every quality stack as stock grows.

Shopping and selling happen at the relevant world location. Until those destinations are built, the existing produce box may expose two compact choices: Buy and Sell. This UI pass does not implement the truck or grocery building.

| Choice | Minimum information |
| --- | --- |
| Seed offer | Packet picture, crop name on focus, 4 or 9 quantity, coin and price |
| Purchase review | Selected packet, quantity, total, Buy, close |
| Sale selection | Produce picture, quality symbol, selected/owned count, large minus/plus, All |
| Sale review | Selected stacks with quality and quantities, unit values, coin total, Sell |

Use pages within the small tray when more items must be reviewed. Do not hide a sale's affected items behind a single unexplained total. A sale never includes unselected goods. Retain the existing server quote/review step while removing its technical prose. If stock or price changes, show Updated, the new values, and require another deliberate confirmation. Routine planting, watering, and harvesting do not need confirmation popups.

**Icon and typography contract**

Seed art is a clean packet with one large crop pictogram; produce art is the recognizable loose crop. Remove crop names, SEEDS, planting instructions, quality lettering, and decorative microprint from the UI artwork. Keep quantity and quality as separate overlays so icons remain reusable. Existing packet models contain title/subtitle SurfaceGuis: UI renders must omit those lettering layers, not merely hide surrounding captions.

Match the approved faceted crop finish and the existing Sterne coin. Use consistent camera angle, lighting, visual scale, and padding across the eight current crops: lettuce, carrot, wheat, pepper, potato, corn, grape, pumpkin. Each silhouette must read without its name. Preserve approved crop geometry when producing UI representations.

Common produce needs no quality badge; Blue, Silver, and Gold need distinct symbols as well as color, with their short names on focus. Symbol designs still need visual review. Growing plants must not show a predetermined harvest quality.

| Element | Starting design target |
| --- | --- |
| Action and item labels | 24–28 logical pixels, medium/bold, one or two words |
| Counts and balance | 28–36 logical pixels |
| Popup title | 32–36 logical pixels |
| Tool icon buttons | 72–88 logical pixels on desktop; at least 64 on small screens |
| Item tiles | 96–120 logical pixels with art filling most of the tile |
| Small-screen text | Keep at least 22 logical pixels; reflow or paginate before reducing size |
| Normal seed popup | Approximately 480 by 300 logical pixels on desktop; fewer visible choices on small screens |

Treat these as mockup targets to verify at actual gameplay size, not approved measurements. Keep at least 90% of the desktop world view unobstructed at rest and aim for 70% with a choice tray open. On smaller landscape screens, preserve the world target and movement/jump controls while reducing visible choices. Never solve overflow with tiny text.

Use cream surfaces, deep-green text and selected outlines, generous padding, restrained shadows, and simple rounded corners. Keep crop colors as the main accents. Avoid thick wooden frames, distressed paper, ornamental borders, and broad dark backdrops. Short labels use normal readable capitalization; ALL CAPS is not required to make them large.

**Feedback and input parity**

Use a small press response, a soft hover lift, and a quick settling motion when equipping. Harvest feedback shows the crop and +quantity; mixed qualities appear as separate symbol/count groups in one short receipt. Combine rapid repeated rewards rather than stacking notifications. Animate completed rewards only after server success; use a subtle pending state and prevent duplicate actions while waiting.

Care feedback uses a droplet/check; growth uses a ring and a short time such as 1:24. Keep progress and care separate: watering improves quality, not growth speed or yield. Show details only for the target being inspected so a full garden does not become a wall of labels.

On desktop, hover previews and E/click commits. On controller, a stable nearby aim target replaces hover, X performs the context action, and focus reveals item names. On touch, tapping a world object selects it and reveals a large action button; tapping that button commits. Touch must never depend on hover. Popups close through a large close button, Escape/controller B, or tapping outside; the closing tap must not activate the world. Preserve selected tool and seed across ordinary popup closes.

Keep contrast, visible focus, large input glyphs, and non-color state cues. Reduced motion should remove lifts and travel animations while preserving immediate state feedback. Significant loading/save failures stay visible as short status plus Retry or Details; a readable explanation remains available in that optional detail view. Routine screens contain no server, revision, or persistence terminology.

**Concept image sequence after planning**

Use the actual autumn gameplay scene and existing item references. Create separate readable gameplay mockups at the same camera and scale, not a tiny collage or a new farm design.

1. Resting HUD: balance and tool row; most of the frame is the farm.
2. Watering: one outlined grape or pepper, can selected, E Water, compact care feedback.
3. Seed choice: one small Seeds tray, large text-free packets and counts, target still visible.
4. Harvest and Bag: reward feedback plus a separate inventory state showing count/quality hierarchy.
5. Sell: selected produce, quantity controls, explicit value, compact review.
6. Small-screen adaptation: landscape touch view with fewer choices, equally readable type, and clear movement controls.

Review screen coverage, icon recognition, type size, and whether the next action is obvious before approving component details. If an image needs explanatory paragraphs to make sense, revise the design.

**Implementation sequence after concept review**

1. Produce the clean packet, produce, tool, quality, and currency UI assets; establish shared sizes/colors and popup placement rules.
2. Replace the header and inventory access with the small balance capsule and tool row. Ensure Roblox's existing backpack/tool controls do not create a second competing row.
3. Replace the crop panel with stable world targeting, direct actions, correct-tool checks, seed memory, and the compact picker.
4. Add the paged Bag, compact purchase/sale flows, and brief result/error states.
5. Simplify duplicated world labels and test desktop, touch, and controller at actual gameplay sizes.

Implementation should use light UI art derived from the approved assets rather than cloning every high-detail crop into a live viewport grid. Keep gameplay validation, save behavior, quote integrity, and inventory accounting intact. No world/crop remodeling, economy changes, or new progression systems are part of this plan.

**Acceptance checks**

- An ordinary dig, plant, water, help, or harvest never opens a large panel.
- The highlighted world object always matches the action target; UI clicks cannot hit through.
- Wrong tools, empty stock, completed care, other owners, and lost range have concise, readable states.
- Seeds and produce remain identifiable without printed words on their artwork; counts never overlap the main silhouette.
- Repeated planting keeps the same selected seed until changed or exhausted.
- Quality stacks and transaction totals remain understandable without prose or color alone.
- No core control, popup close button, count, or label becomes tiny at desktop, small-window, or landscape phone sizes.
- Mobile/controller players can discover and complete every flow without hover.
- A failed or repeated action cannot consume extra items or show a false success reward.
- Compare fresh gameplay captures to the approved concepts before declaring the redesign complete.

**Project references**

- [Current farming interface](src/farming/Interface.client.luau)
- [Interaction validation](src/farming/Runtime.server.luau)
- [Current crop and item catalog](src/farming/Catalog.luau)
- [Packet and equipment art construction](src/InventoryWorkshop.luau)
- [Farming integration notes](FARMING_LOOP.md)
- [Visual style contract](../STYLE_CONTRACT.md)
- [Gameplay concept](../CONCEPT.md)

Only this planning document was added. No gameplay or asset edits are included. This workspace is not a Git repository, so local staging and commits are unavailable.
