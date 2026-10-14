# Homestead Tycoon: Luna Landing

> **Working tagline:** Start with dirt. Grow a home.

| Project | Definition |
| --- | --- |
| Platform | Roblox |
| Genre | Homestead tycoon with farming, processing, and player commerce |
| Lobby | 8 players; one homestead per player |
| Setting | Luna Landing: a nonmagical community focused on natural living |
| Initial season | Fall |
| Player goal | Turn an empty property into a thriving farm and home |
| Currency | **Sterne**, represented by a star coin |
| Document status | Refined concept baseline · October 12, 2026 |

**How to read this document**

- **Confirmed:** Approved by Izzy; the default status of rules unless marked otherwise.
- **Proposed:** A recommendation still awaiting approval.
- **Open:** A design choice or balance value not yet settled.
- **Later:** Approved direction outside the initial base-game scope; not a delivery commitment.
- This is a concept reference, not a final economy specification or implementation plan.

## Table of contents

1. [Vision and design principles](#1-vision-and-design-principles)
2. [Core loop and first session](#2-core-loop-and-first-session)
3. [Homestead layout and growing areas](#3-homestead-layout-and-growing-areas)
4. [Beginner crops](#4-beginner-crops)
5. [Quality and plant care](#5-quality-and-plant-care)
6. [Processing and preserves](#6-processing-and-preserves)
7. [Sterne and digging upgrades](#7-sterne-and-digging-upgrades)
8. [Central market and direct trading](#8-central-market-and-direct-trading)
9. [Home upgrades and progression](#9-home-upgrades-and-progression)
10. [World and art direction](#10-world-and-art-direction)
11. [Persistence and implementation guardrails](#11-persistence-and-implementation-guardrails)
12. [Base scope and approved deferrals](#12-base-scope-and-approved-deferrals)
13. [Playtest goals](#13-playtest-goals)
14. [Remaining decisions](#14-remaining-decisions)
15. [Visual development brief](#15-visual-development-brief)

## 1. Vision and design principles

- Eight players settle in Luna Landing with empty properties and a shovel.
- Digging earns currency and uncovers planting materials.
- Players grow produce, sell it fresh, process it into goods, and reinvest in their homesteads.
- A shared market supports direct commerce; neighbors provide optional care and processing bonuses.
- Solo progression remains possible, but trading and cooperation make it faster.
- The fantasy combines a productive farm with a home that visibly improves over time.

| Principle | Design consequence |
| --- | --- |
| Tycoon progression | Repetitive digging is intentional early gameplay; wealth opens more productive activities |
| Useful upgrades | Digging upgrades remain beneficial after farming becomes established |
| Meaningful harvest choices | Fresh sales are quicker; processing takes time and can improve quality |
| Independent ownership | Each player owns their property, inventory, and progress |
| Optional cooperation | Help improves efficiency without requiring coordinated play sessions |
| Natural living | Farming and community provide the identity; moon motifs do not imply magic |
| Room to grow | Reserve the full property footprint before designing later unlocks |

**Proposed comfort rules:** No crop death, theft, spoilage, or loss of progress for taking a break. These remain recommendations rather than approved failure-state rules.

## 2. Core loop and first session

**Claim → dig → plant → care → harvest → sell, trade, or process → upgrade → repeat.**

| Stage | Player action | Result |
| --- | --- | --- |
| Establish | Claim a homestead and unlock the dirt patch for free | A place to begin |
| Earn | Click to shovel; receive Sterne and random planting materials | Starter income and crops |
| Grow | Plant in the free first growing area | First harvest underway |
| Care | Water on plant-specific cycles; receive optional neighbor fertilization | Better growing outcomes |
| Harvest | Collect produce with a quality result | Inventory to use or sell |
| Choose | Sell to the grocery, list at a stand, trade, or process | Immediate income or a higher-value opportunity |
| Expand | Spend Sterne and materials on upgrades | Greater capacity and a more developed home |

### Proposed tutorial sequence

1. Claim a property; receive a starter shovel and the free tier-1 growing area.
2. First dig awards the base currency reward and a guaranteed starter seed.
3. Plant peppers as a suggested fast starter crop; show growth and care prompts.
4. Dig or explore while the plant grows; optionally shorten this first growth cycle.
5. Harvest and sell at the community grocery to demonstrate dependable income.
6. Introduce an upgrade, then the preserving station and player market.
7. End the guided sequence with a visible property improvement.

- Only the first growing area begins unlocked; its four slots are available under the approved tier model.
- Exact tutorial timing, first-seed guarantee, starter equipment delivery, and sequencing remain proposed.
- The market and trading do not need to be mandatory tutorial steps.

## 3. Homestead layout and growing areas

### Reserved footprint

| Feature | Property allocation |
| --- | --- |
| Growing areas | **8 areas per homestead** |
| Cottage | Space for a small cottage |
| Greenhouse | Separate space for a tree greenhouse |
| Greenhouse expansion | A second-floor upgrade |
| Initial placement | Fixed unlock locations |
| Later placement | Free placement becomes unlockable |

- Eight areas are reserved capacity, not eight areas granted at spawn.
- Cottage and greenhouse space is additional to the eight growing areas.
- Unlock order beyond the free first area remains open.
- Greenhouse capacity and release timing remain open; reserve its space now.
- Property layouts must leave meaningful contiguous space for eventual free placement and customization after all eight growing areas, the cottage, and greenhouse are present. The earlier two-column garden images are layout studies, not a locked plan.
- **Proposed spatial direction:** A broader property with an offset cottage, small clusters of growing areas, branching paths, and a substantial open lawn for future player arrangements. Aim for roughly one-third of usable land to remain an uninterrupted customization area in the next visual study; this is a study target, not a final dimension or budget.
- Keep property boundaries and future expansion space consistent between starter and developed states. Initial fixed placements should be a useful starting arrangement for later customization.
- **Open:** Final property dimensions, movable object categories (including buildings and beds), placement grid/rotation, path editing, and the free-placement unlock condition. Village spacing must be revisited when property dimensions are settled.

### Terms and area tiers

| Term | Meaning |
| --- | --- |
| Homestead | The player's entire property |
| Growing area / plot | One of eight upgradeable outdoor growing areas |
| Planting slot | A location for one standard crop inside a growing area |
| Standard crop | Pepper plant, pumpkin plant, or grape bush |

| Area tier | Standard crop capacity | Apple-tree alternative |
| --- | --- | --- |
| 1 | 4 slots | One tree; base tree harvest |
| 2 | 6 slots | One tree; larger harvest |
| 3 | 9 slots | One tree; further increased harvest |

- Standard crops occupy one slot each and may be mixed within an area.
- **One apple tree occupies the entire area**, replacing all standard slots there.
- Area upgrades increase an apple tree's yield, not the number of trees in that area.
- Area upgrades also improve crop-quality odds; exact effects remain open.
- All eight areas at tier 3 can hold **72 standard plants** if none contain trees. This excludes the greenhouse.
- Confirm spacing and performance before treating maximum capacity as a finished layout.

**Proposed safeguards:** Confirm removal of established plants; prevent upgrades or decorations from erasing occupied crops.

## 4. Beginner crops

**Confirmed:** Crop selection, permanence, space use, and outdoor apple access. Relative growth speeds and detailed silhouettes below remain proposed.

| Crop | Space | Harvest behavior | Proposed role and appearance |
| --- | --- | --- | --- |
| Peppers | 1 slot | Repeat harvests | Quick starter; compact foliage with prominent colored peppers |
| Pumpkins | 1 slot | Replant after harvest | Larger occasional payout; ground vine and orange pumpkins |
| Grapes | 1 slot | Repeat harvests | Processing supply; bush-like vine on a low wooden support with purple clusters |
| Apples | Entire growing area | Repeat harvests; yield increases with area tier | Longer establishment; rounded tree canopy and readable red fruit |

- Apple trees grow outdoors from the beginning; the greenhouse is not required for a beginner crop.
- A tree produces more fruit than one standard crop. Exact yield relative to a fully planted area is a balance decision.
- Growth durations, regrowth times, fruit counts, and seed discovery odds remain open.
- **Proposed growth display:** Planted → developing → mature → harvest-ready.
- **Proposed inventory naming:** Pepper seeds, pumpkin seeds, grape cuttings, apple saplings, grouped under a simple planting-material category.

## 5. Quality and plant care

### Crop quality

| Quality tier | Badge treatment |
| --- | --- |
| Common | No color |
| Blue | Blue |
| Silver | Silver |
| Gold | Gold |

- Determine crop quality at harvest.
- Area upgrades and owner watering improve quality odds; some randomness remains.
- Blue, Silver, and Gold are the approved identifiers; no additional rarity names are needed.
- Exact probabilities and the badge design remain open.
- **Proposed UI detail:** Pair color with a text label or symbol so quality is understandable without color alone.

### Care and neighbor help

| Action | Actor | Frequency | Effect |
| --- | --- | --- | --- |
| Water | Owner | Once per plant-specific time cycle | Improves crop-quality odds |
| Fertilize | Neighbor | **+1 per cycle** | Additional bonus; exact effect open |
| Speed processing | Neighbor | Once per batch | Reduces processing time; amount open |

- Watering intervals differ by plant; care cycles need not equal harvest cycles.
- Plants grow without watering or fertilization; care provides bonuses.
- Processing help does not require repeated clicking or remaining at the station.
- **Working interpretation:** One neighbor fertilization allowance per plant care cycle in total, not one per visitor. Target granularity and the meaning of the +1 bonus still need specification.
- Helping does not grant harvesting, building, or spending rights.

## 6. Processing and preserves

### Confirmed behavior

| Input / choice | Intended outcome |
| --- | --- |
| Fresh sale | Quicker income; high-quality produce can be more worthwhile to sell directly |
| Low-quality produce | Processing can turn it into higher-quality preserves |
| High-quality produce | Best opportunity for very high-quality preserves |
| Processing equipment | Equipment tier and input quality influence output quality |
| Processing time | Waiting is part of the tradeoff; processing is not always the best use of a harvest |

- Quality formulas, durations, batch sizes, and output values remain open.
- Preserve quality exists; whether it uses the same badge treatment as crops is not yet approved.
- Player-set selling prices remain independent of NPC valuation.

### Proposed initial recipes

| Input | Product | Process | Visual |
| --- | --- | --- | --- |
| Grapes | Grape jelly | Cook | Purple jar |
| Peppers | Pepper jelly | Cook | Amber-red jar |
| Apples | Nonalcoholic apple cider | Press / bottle | Amber bottle with apple label |
| Pumpkins | Pumpkin puree | Cook | Orange jar |
| Pumpkins | Pumpkin soup | Cook | Creamy orange jar with a distinct soup label |

### Proposed station rules

- Start with one preserving station supporting cooking and pressing/bottling.
- Select recipe → preview ingredients/output → start → wait → collect.
- One active batch per station; consume ingredients once at batch start.
- Completed products wait for collection.
- Initial recipes use the named crop only; containers are included.
- Distinguish puree and soup through batch size, duration, or value.
- Separate glass, sugar, and packaging supply chains are deferred.

### Additional product directions

| Product | Status |
| --- | --- |
| Wine | Original user idea; final inclusion remains open |
| Grape juice / sparkling grape juice | Proposed bottled alternative |
| Apple puree | Proposed additional recipe |
| Pumpkin + pepper harvest soup | Proposed later mixed recipe |

### Later: stockpiled preserve income

- An upgrade allows stored preserves to generate **passive Sterne income per second**.
- Rates, quality effects, eligible storage, consumption, and offline accrual remain open.
- This is a separate system from market sales; it does not imply offline player-stand sales.
- Decide whether listed goods can qualify before implementing either income calculation.

## 7. Sterne and digging upgrades

### Currency identity

- **Confirmed name:** Sterne.
- **Confirmed appearance:** Star coin.
- Fits the natural setting as ordinary currency rather than magical energy.
- **Approved visual design:** Option C in [Sterne concept sheet](concept/pngs/15-sterne-star-coin.png): thick octagonal coin with inset five-point star, shallow rim, and muted matte brass/ochre finish. Final mesh dimensions and interface treatment remain open.
- **Proposed:** One earned currency throughout the initial economy.

### Digging

| Rule | Direction |
| --- | --- |
| Starter action | Repetitive shovel clicking |
| Base reward | 1 unit of Sterne per completed hit |
| Discovery | Random planting materials alongside currency |
| Upgrade reward | More Sterne per hit |
| Broader upgrade benefit | **+0.1% overall profit multiplier** |
| Long-term role | Players move beyond relying on digging, while upgrades keep it useful |

- A single 0.1% increase corresponds to **1.001×**; cumulative stacking is undecided.
- Sterne-per-hit increases, costs, profit sources affected, and rounding remain open.
- Seed-find improvements are not a confirmed digging-upgrade benefit; the approved amendment prioritizes currency and profit upgrades.
- **Proposed:** Reusable digging patch; protection against long runs without seed finds. Seed purchases use the circulating market truck described below.

### Income and spending

| Income route | Purpose |
| --- | --- |
| Digging | Always-understandable starter activity |
| Community grocery | NPC sales at the current displayed market price |
| Player stand | Seller-priced stocked goods; requires player demand |
| Direct trade | Exchange goods and/or Sterne with another player |
| Preserve stockpile | Later passive income upgrade |

- Spend on growing areas, equipment, home/garden upgrades, required materials, and player goods.
- Material types and how players acquire them remain open.
- Define how the profit bonus interacts with player payments so transfers and generated rewards are accounted for separately.

## 8. Central market and direct trading

### Central market

| Feature | Confirmed behavior |
| --- | --- |
| Player stands | Eight stands; one per player |
| Stock | Sellers place produce or made goods into stand inventory |
| Prices | Seller sets a unit price per item/quality combination |
| Purchase | Buyer purchases directly; seller may be elsewhere in the lobby |
| Seller disconnects | Listings close; unsold stock remains saved for relisting next session |
| Community grocery | NPC buys fresh and processed goods at the current market price; price fluctuations are intended, with rules still open |
| Market hub | Check current prices, game information board, leaderboard, and upgrades |
| Solo route | Grocery sales do not require another player's demand |
| Offline player sales | Deferred |

- NPC base prices do not control player-set prices.
- Listing limits, fees if any, and exact stand assignment remain open.

### Circulating market truck

- A produce/market truck continuously circles the village loop road, releasing a fixed number of purchasable seed packets over each lap: a moving carousel of randomized offers.
- Unpurchased packets disappear when the truck returns around to their location. Exact drop spacing, lap duration, and refresh timing remain open.
- Standard packs contain **4 seeds**. Less-common large packs contain **9 seeds**. Large-pack rarity is separate from any seed-type rarity.
- Players must buy dropped packs; they are not free pickups. Pack prices, random selection weights, and whether contents are fully disclosed before purchase remain open.
- **Later possibility:** A functional minimap shows icons for the seed types currently available along the route, so players can watch for a desired seed and travel to buy it.
- The truck is a recurring item source and an event-decoration focal point. Build a recognizable everyday vehicle whose decorations and item displays can change for events. Event inventories and their rules remain open.
- The stationary market remains the destination for selling goods at market prices and accessing its boards and services.
- **Open:** Shared first-buyer stock versus per-player availability; purchase interaction and expiry handling; whether the fixed per-lap amount counts packets or seeds; treatment of apple saplings and grape cuttings in packs; initial release scope.
- **Visual proposal:** A compact chunky produce truck with a timber cargo display, broad plain canopy, simple seed pictograms, and reusable areas for event signs and decorations. Decorations should preserve its silhouette and route visibility.

### Direct requests and offers

| Trade rule | Confirmed direction |
| --- | --- |
| Eligible | Seeds, produce, preserves, materials, Sterne |
| Ineligible | Buildings, planted crops, unlocked areas |
| Agreement | Both players confirm the complete offer |
| Offer changes | Clear prior confirmations; both confirm again |

**Proposed transaction safeguards**

- Show item, quality, quantity, unit price, and total before purchase.
- Reserve listed stock against simultaneous use in trading or processing.
- Recheck balances, price, and stock at purchase time.
- Transfer payment and goods together; prevent partial transfers and duplicated items.

## 9. Home upgrades and progression

| Layer | Approved direction |
| --- | --- |
| Base property | Small cottage; eight reserved growing areas; greenhouse footprint |
| Growing-area upgrades | Three tiers; 4/6/9 standard slots or increasing apple yield |
| Greenhouse | Tree growing space; second-floor upgrade |
| Prototype requirements | **Sterne + materials** for early upgrades |
| Later progression | Crop-based milestones linked to a community center |
| Home/garden improvements | Eventually require milestone access plus materials and currency |
| Later placement | Free placement unlocked after fixed-layout progression |

- Community center inspiration: crop contributions and milestones in the spirit of Stardew Valley.
- Develop detailed progression after implementing the four-beginner-crop base loop.
- Later milestones support new plots, greenhouse access, and additional crops.
- Personal versus shared community center progress remains open.
- No final bundles, material recipes, milestone thresholds, or unlock order are set.
- The **community grocery** is the base-game NPC shop; the **community center** is the later progression system.

## 10. World and art direction

### Approved visual foundation

| Element | Direction |
| --- | --- |
| Style | Cozy stylized 3D; simple forms and clear silhouettes |
| Palette | Warm wood, dark soil, cream gravel, leafy green, pumpkin orange, apple red, grape purple |
| Garden structure | Raised wooden beds, trellises, flower borders |
| Paths | Generous movement space and clear interaction areas |
| Crops and products | Recognizable produce; labeled jars and bottles |
| Home | Approved cottage exterior in `concept/pngs/16-cottage-housing-sheet.png`; porch and pantry display support the homestead identity |
| Initial atmosphere | Fall; nonmagical natural living |
| Growth | Empty starting property visibly fills out through investment |

- Reviewed reference: `image(2).png`, showing raised beds, pale gravel paths, arched trellises, flowers, and timber fencing.
- **Approved building reference:** `concept/pngs/17-community-grocery-sheet.png` establishes grocery architecture and selling-counter visual direction. Exact market interfaces, price rules and construction dimensions remain open.
- Other reference images have not been reviewed for this document.
- **Proposed decorative details:** Crescent signs and moonlit garden scenes; these are not magical mechanics.
- Seasons, moon phases, and richer weather are intended later.

### Proposed neighborhood principles

- **Approved visual direction:** Use `concept/pngs/09-spacious-property-layout.png` for roomy homesteads with clustered growing areas and open customization land. The village footprint may grow to fit eight equal properties and the truck route.
- **Approved village-map feature:** A parkour area in the eastern central green, with access clear of the circulating truck route. Obstacle design, rewards (if any), and implementation timing remain open.

- Equal usable property footprints and convenient access to the central market.
- Include all eight stands and the community grocery in layout proposals.
- Clear entrances and ownership boundaries; avoid routing traffic through work areas.
- Compare a village green, two-row lane, and courtyard arrangement.
- Preserve space for future growth without defining the deferred community center layout yet.
- Final geometry, dimensions, and architectural detail remain open.

## 11. Persistence and implementation guardrails

**Proposed engineering requirements unless they restate a confirmed gameplay rule.**

| Area | Requirement |
| --- | --- |
| Ownership | Save the homestead to the account; load into an available lobby slot |
| Economy | Save Sterne, inventory, item quality, upgrade levels, materials, stand stock |
| Farming | Save crops, area tiers, growth state, care timers, fertilization state |
| Processing | Save batches and help state; collect outputs once |
| Property | Save cottage/greenhouse upgrades and decorations; extend for later progression |
| Server authority | Validate rewards, trades, purchases, harvesting, processing, and bonuses |
| Transactions | No duplicated goods, partial exchanges, or double spending |
| Stand disconnect rule | Close listings and retain unsold stock, as approved |
| Permissions | Assistance does not grant general property access |
| Controls | Support understandable touch, keyboard, and controller interactions |

### Proposed absence behavior

- Existing crops and batches may finish while the player is away.
- No automatic harvesting, batch restarting, or repeated base-game payouts.
- No crop spoilage or progress loss for absence.
- Later preserve passive income needs its own offline rule; none is assumed here.

## 12. Base scope and approved deferrals

### Confirmed base-game systems

| System | Scope |
| --- | --- |
| Lobby | Eight homesteads, central market, community grocery |
| Starter economy | Free claim/digging area/first growing area; shovel clicks, Sterne, random seeds |
| Upgrades | Higher Sterne per hit; 0.1% profit bonus direction; early Sterne + material costs |
| Farming | Four crops, mixed standard planting, whole-area apple trees, three area tiers |
| Quality | Four crop badges; harvest quality influenced by care and upgrades |
| Care | Owner watering, neighbor fertilization, one processing boost per batch |
| Processing | Timed production; quality influenced by inputs and equipment |
| Commerce | Direct trades, stocked player-priced stands, NPC sales at current market prices |

### Property target versus initial access

- Reserve eight growing areas, cottage, and greenhouse from the start.
- Only the first growing area begins unlocked.
- Tree greenhouse, second floor, and later areas are approved property features; their playable release/unlock sequence is still open.
- Reserve their footprint without treating their complete progression as a base-loop prerequisite.

### Proposed supporting details

- Tutorial sequence, first-seed guarantee, and unlucky-drop protection.
- Circulating seed-market truck is an approved direction; its release timing remains open. Seed-type minimap icons are a later possibility.
- One processing station and the five initial recipes in Section 6.
- Comfort rules and persistence behavior described above.

### Approved later directions and deferrals

| Category | Deferred work |
| --- | --- |
| Progression | Detailed community center system, crop milestones, additional crops/plots |
| Nature | Seasons, moon phases, more involved weather |
| Building | Free-placement unlock and detailed interiors |
| Passive income | Stockpiled-preserve income-per-second upgrade |
| Farming additions | Animals, breeding, crop mutations |
| Production complexity | Separate supply chains, large automation systems |
| Social | Guilds and offline player-stand sales |
| Monetization | Model undecided; no paid random seeds or paid progression requirements assumed |

- Deferral directions are approved; exact mechanics and schedules are not.
- Direct trading, player stands, and crop/preserve quality are **not deferred**.

## 13. Playtest goals

| Area | What to establish |
| --- | --- |
| First session | Players understand digging, planting, harvesting, and a reliable sale route |
| Digging | Clicking works as an opening tycoon activity; upgrades stay useful later |
| Area balance | 4/6/9 slots feel worthwhile; whole-area apple yields justify their space |
| Quality | Players can identify quality and understand how their actions influence it |
| Processing | Fresh selling and processing each have useful situations |
| Cooperation | Trading and passive help accelerate progress without becoming mandatory |
| Solo play | All core goals remain achievable without another player's participation |
| Market | Sellers understand pricing; buyers understand stock, quality, and total cost |
| Upgrades | Material and currency costs support visible, satisfying improvements |
| Visual clarity | Crops, harvest readiness, paths, stands, and prompts are clear in a developed lobby |
| Performance | Up to 576 outdoor standard plants across eight full homesteads remains practical; trees and greenhouse content require separate budgeting |

- Capacity figures are arithmetic bounds, not measured performance claims.
- Balance rates and costs through playtesting; avoid inventing final numbers in the concept.

## 14. Remaining decisions

### Before layouts and detailed visuals

| Decision | What remains |
| --- | --- |
| Scale | Growing-area dimensions, crop spacing, full-area apple silhouette |
| Greenhouse | Tree capacity, second-floor layout, functional benefits |
| Art finish | Geometry, textures, architecture, lighting, badge/coin designs |
| Processing space | Station size and location on the property |

### Before implementing the relevant system

| Decision | What remains |
| --- | --- |
| Materials | Types, sources, and basic upgrade recipes |
| Processing | Confirm station/recipes; resolve grape products including wine; batch and cancellation rules |
| Quality | Crop odds, processing formula, mixed-quality ingredients, preserve badges |
| Care | Plant-specific timers, fertilization target, exact +1 effect, permissions |
| Help | Processing speed reduction amount |
| Digging | Per-tier reward/cost, profit-bonus stacking, income coverage, fractional rounding |
| Market | Listing limits, any fees, UI, exact stand assignment; NPC price-fluctuation rules and update timing |
| Market truck | Lap duration, fixed drop amount and units, pack prices and odds, stock sharing, purchase/expiry rules, event inventory, and release timing |
| Crop lifecycle | Clearing/transplanting rules and upgrade behavior while planted |
| Persistence | Approve absence behavior and comfort rules |

### During later progression design

- Unlock timing for later areas and greenhouse upgrades.
- Community center ownership, milestones, and bundles.
- Preserve passive-income rates, stock consumption, eligibility, and offline accrual.
- Free placement, seasons, moon phases, and weather behavior.

**Balance parameters still open:** Crop growth/regrowth times, harvest counts, apple yields by tier, sale prices, seed odds, quality probabilities, care intervals, processing times, help boosts, and upgrade costs.

## 15. Visual development brief

**Next step:** Refine the approved art direction in chat before generating imagery.

| Topic | Choice to resolve |
| --- | --- |
| Geometry | Rounded, low-poly, or a combination |
| Surface finish | Simple colors versus soft texture |
| Architecture | Cottage, greenhouse, grocery, and stand styling |
| Growing areas | Tier changes; standard crop layout versus whole-area apple tree |
| Product display | Jar/bottle shapes, labels, quality badges, stock displays |
| Atmosphere | Natural daylight and warm evenings; restrained moon references |

### Planned deliverables

| Order | Visual output | Must show |
| --- | --- | --- |
| 1 | Mood concepts | Approved natural, cozy fall identity |
| 2 | Neighborhood alternatives | Eight homesteads, eight stands, community grocery |
| 3 | Property layouts | Eight reserved areas plus cottage/greenhouse; starter and developed states |
| 4 | Growing-area and crop sheets | Three tiers, 4/6/9 slots, whole-area apple, four crop growth stages |
| 5 | Building and production sheets | Cottage, greenhouse second floor, station, jars/bottles |
| 6 | UI and currency direction | Sterne star coin, four crop-quality treatments, care and market displays |

- Work from confirmed rules; label unresolved choices in visual proposals.
- New mechanics suggested by an image remain proposals until approved.
