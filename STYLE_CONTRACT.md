# Homestead Tycoon: Luna Landing — Style Contract

> A welcoming autumn garden village. Start with dirt. Grow a home.

**Purpose:** Shared visual direction and reusable image-generation prompts for environments, maps, buildings, crops, products, and branding.

**Date:** October 12, 2026

**October 13 visual direction update:** The playable world now favors deeper green grass with restrained material texture, warmer plaster-and-timber cottages, and layered autumn woods backed by distant mountains. This supersedes the older no-grain / almost-no-texture guidance below for world surfaces; archived concept prompts retain their original wording. Use built-in matte grass, timber, plaster and stone textures sparingly, with broad low-poly silhouettes doing most of the work. Carry ochre, russet, muted gold and evergreen accents into future town decorations. Keep the lobby continuous and walkable: open lot entrances and road connections, no loading-screen transitions between locations, and scenery around the routes rather than a mountain or forest enclosure. Future destinations are not implemented by this art pass.

**Companion:** [CONCEPT.md](CONCEPT.md) remains the source of truth for gameplay, counts, progression, and scope. This document establishes the working visual direction from the concept discussion. Layouts, care treatments, recipe packaging, and interface behaviors described as proposals are visual studies, not new gameplay commitments. Generated imagery does not approve new mechanics.

## 1. Visual identity

### Approved asset benchmark — October 13, 2026

The rebuilt pepper in `studio/build/AssetWorkshop.rbxlx`, from the chat **Rebuild pepper plant asset**, is the approved crop benchmark: **charming, intentionally high-definition low-poly**. High definition means a carefully resolved silhouette and clean, readable construction: broad deliberate facets, folded leaves with real thickness, connected branching stems, and recognizable sculpted fruit. Keep matte surfaces and economical geometry; do not substitute smooth inflated primitives, thin triangular blades, or dense surface detail.

Use compact, believable scale, healthy earthy greens, brighter produce, slight asymmetry, and open gaps that let the fruit read. Growth stages change structure rather than merely scaling one model. The approved ripe pepper has five balanced fruit, including two smaller upper peppers, and a slim timber stake extended above the crown with subtle ties. Preserve this composition when exploring other crops.

Workshop captions, stage labels, and status UI belong in separate display/UI containers, never inside reusable plant or fruit assets. Soil display mounds are staging, separate from plant templates. Pumpkins should share the same finish while retaining their own low spreading vines, broad lobed leaves, squat broadly ribbed fruit, and bent woody stems.

Implementation lessons: use closed geometry, keep mesh axes canonical before nonuniform scaling, check connected stems and foliage from several angles, and verify saved geometry in the place file. Intentional visible facets do not guarantee a low underlying triangle count; inspect actual mesh complexity separately. The gameplay place remains separate from asset studies.

**Layered low-poly 3D: simple chunky shapes assembled into charming, recognizable homes and gardens.**

The world should feel welcoming, a little scruffy, and achievable as an actual Roblox game. Its emotional promise is: “I want to build a home here.” Productive gardens, humble cottages, and visible improvements carry the identity.

The user's reference is the simple, slightly dingy charm of old Sega Sonic Chao gardens. Use that as a cue for restrained geometry, faded earthy colors, approachable proportions, and readable game spaces; keep Luna Landing's own buildings, crops, and identity.

**Detail comes from construction and layering.** A cottage has a foundation, roof thickness, eaves, window frames, recessed door, porch posts, and steps. A tree has a branching trunk and overlapping canopy clusters. Each component stays simple. Preserve structural depth while keeping individual meshes economical.

This direction supersedes the earlier premium miniature-village finish. The first generated validation images were too detailed and are not approved style references. Do not reduce every object to a single primitive either: use enough overlapping parts to explain its structure and give it personality.

Luna Landing is a nonmagical community. Restrained crescents can appear as simple town emblems or sign details. Natural blue-hour skies and warm windows support the name. Moon motifs do not imply magical farming.

## 2. Geometry, materials, color, and light

| Element | Contract |
| --- | --- |
| Overall forms | Chunky, friendly, slightly squat forms built from a modest number of distinct overlapping parts |
| Geometry | Clearly low-poly meshes, broad flat-shaded faces, visible but deliberate facets; restrained bevels only where they improve the silhouette |
| Structural layering | Roof overhangs, inset windows, raised borders, branching trunks, clustered foliage, and overlapping crop leaves supply depth |
| Proportions | Substantial porch posts, thick bed borders, broad steps, thick roof edges, slightly oversized recognizable fruit |
| Detail hierarchy | Silhouette first, functional construction second, sparse identifying accents last; omit details that disappear at gameplay distance |
| Materials | Solid matte colors; identify wood, soil, metal, and glass primarily through shape and color. Glass uses simple transparency or a restrained tint |
| Textures | Almost none. Allow simple labels, broad color patches, and care-state markings; no wood grain, weathering maps, or dense surface noise |
| Lighting | Simple daylight and modest shadows that reveal the forms; use the finish of a lightweight playable game scene |
| Handmade character | Slight asymmetry and imperfect proportions; a little scruffy without damage, neglect, or decay |
| Density | Layer the focal objects, leave breathing room between them, and use decoration sparingly |
| Camera | Readable gameplay-like three-quarter views for environments and models; strict overhead orthographic views for planning maps |

### Palette

- **Foundation:** Faded warm timber, dull warm cream paths, muddy brown and dark fertile soil.
- **Landscape:** Dusty leafy greens and muted sage; retain healthy green foliage in the fall setting.
- **Produce accents:** Pumpkin orange, apple red, grape purple, pepper red and amber. These are brighter than their surroundings.
- **Secondary accents:** Muted terracotta, faded midnight blue, restrained dull metal tones.
- **Evening:** Muted blue surroundings with warm amber windows and lanterns; plants and paths remain visible.

“Slightly dingy” means faded, earthy, humble, and lived-in through color and proportion. Keep the garden welcoming and healthy. No exact color values are locked yet; maintain clear separation between soil, foliage, paths, buildings, and produce.

### Finish boundaries

| Favor | Avoid |
| --- | --- |
| Plain matte timber with separate structural pieces | Wood grain, carved surface detail, weathering, tiny fasteners |
| Broad polygonal faces and economical edge treatment | Bevel-heavy construction, inflated smooth shapes, needless triangulated surface noise |
| Layered readable models | Featureless single-block objects or elaborate miniature architecture |
| Several overlapping tree canopy clumps | Hundreds of individual canopy leaves |
| Simple transparent or tinted greenhouse panes | Glass refraction, mirror reflections, jewel-like jars |
| Simple daylight and modest shadows | Cinematic lighting, heavy ambient occlusion, bloom, dramatic haze, studio product-render polish |
| Faded earthy surroundings and brighter crops | Uniformly saturated toy colors or uniformly brown lifeless gardens |
| Clear focus across the playable scene | Depth-of-field and tilt-shift blur |
| Small crescent emblems and natural gardens | Celestial architecture, glowing plants, magical particles, Halloween styling |

## 3. Model language

These are construction examples, not fixed mesh counts or performance budgets. Use a modest number of parts with visible purpose. An added shape should strengthen the silhouette, explain structure, or clarify function.

| Model family | Required character |
| --- | --- |
| Cottages | Separate foundation, broad wall body, pitched roof with thickness and overhanging eaves, recessed door, simple window frames, porch platform, posts, and steps. Large plain roof sections; no individual shingles, masonry blocks, furniture clutter, or intricate trim. |
| Greenhouses | Timber base, chunky posts and roof beams, a few large panes, and an obvious entrance. Trees remain readable through simple glass. A second-floor study repeats this construction language without adding dense framework. |
| Raised beds and fences | Plain thick boards, simple corner posts, and soil visibly recessed below the rim. A few broad color differences may separate pieces. No grain or hardware. |
| Trees | Angular tapered trunk splitting into a few branches, several overlapping broad faceted canopy clusters, chunky visible fruit at the outer and lower edges. No individually modeled canopy leaves or bark texture. |
| Crops | A few broad overlapping leaves, simple stems, and prominent low-poly produce. Layered enough to distinguish species; foliage must not become a dense mass of small parts. |
| Jars and bottles | Low-sided body, shoulder, neck or thick rim, oversized simple lid, and one flat produce-symbol label. Opaque colored contents or restrained tinted glass. No intricate cloth folds, rope, refraction, or glossy highlights. |
| Tools and stations | Thick handles and recognizable working parts assembled from simple shapes. Practical workbench with clear cooking or pressing equipment; omit bolts and tiny mechanisms. |
| Paths | Broad flat cream surfaces with simple irregular boundaries and clear junctions. Gravel is suggested by color, not individual pebble geometry. |
| Market stalls | Chunky posts, counter, a simple awning with one or two broad folds, and grouped low-poly produce. Leave openings clear and omit trim clutter. |
| Garden accents | Low-sided terracotta pots, simple fence sections, and sparse flower clumps made from broad shapes. Use accents to frame entrances without filling every gap. |

### Layering test

At gameplay distance, a cottage should still show its porch, roof overhang, windows, and steps; a tree should show separate canopy clusters and fruit. At close range, surfaces should remain plain. If a model only feels interesting because of texture, tiny parts, or elaborate lighting, revise its proportions and structural layers.

## 4. Plants: growth, care, and harvest

**Growth changes the plant’s shape; care changes its immediate surroundings; harvest readiness emphasizes the produce.**

Plants should be among the most enticing objects in the world. Use recognizable growth silhouettes, satisfying fruit, and distinct care signals that can coexist in a developed garden.

### Proposed four-stage growth language

| Stage | Visual treatment |
| --- | --- |
| Planted | Small tidy mound and crop-specific planting marker; grape cuttings and apple saplings can visibly emerge immediately |
| Developing | Crop-specific young silhouette: compact pepper stem, spreading pumpkin leaves, grape cutting beginning to fill its support, slender apple sapling |
| Mature | Fuller foliage and recognizable adult structure with smaller developing fruit |
| Harvest-ready | Full-size richly colored produce positioned visibly outside or beneath foliage; fruit supplies the payoff |

Use purpose-built model changes, not uniformly scaled copies. Pumpkin vines spread; grape foliage fills its support; apple trees develop branching and canopy structure.

### Crop personalities

| Crop | Shape and development | Harvest payoff |
| --- | --- | --- |
| Peppers | Upright compact foliage, broad pointed leaves, peppers hanging clear of the leaf mass | Chunky low-poly peppers with broad shoulders and solid color |
| Pumpkins | Low spreading vines, large lobed leaves, fruit near the outside of foliage | Squat faceted orange pumpkins with a few broad lobes, thick stems, and slight asymmetry; no fine ribbing |
| Grapes | Bush-like vines progressively filling a low wooden support; separated leaf groups | Generous purple clusters hanging beneath leaves, made from a small group of low-sided grape shapes |
| Apples | Slender sapling develops a sturdy visible trunk and clustered faceted canopy | Readable red apples around outer and lower canopy edges, with space between fruit |

Peppers, grapes, and apples retain their established plant after harvest; produce disappears and later develops again. Harvested pumpkins leave a cleared planting space that requires replanting. One apple tree occupies an entire growing area, replacing its standard planting slots.

### Proposed care and readiness treatments

“Dry” means ready for watering. The plant stays healthy: care improves outcomes, and plants grow without watering or fertilization.

| Status | World indication | Supporting feedback |
| --- | --- | --- |
| Ready for watering | Lighter matte brown soil; healthy upright plant | Outlined droplet on targeting or in a proposed care view |
| Watered | Locally darkened, softly edged soil patch around the plant base | Brief watering droplets; filled droplet with check indicator |
| Fertilized this cycle | Sparse flat matte ochre-gold nutrient flecks in soil near the base, visible on wet or dry soil; revised visual proposal | Sprout-plus badge and brief application animation |
| Harvest-ready | Full-size produce, richer natural color, clear separation from leaves | Brief gentle settling or bounce on becoming ready; basket badge on approach or targeting |

- Care signals must combine: watered plus fertilized; harvest-ready plus dry; harvest-ready plus watered and fertilized.
- Do not use a single whole-plant tint to encode all states.
- For mixed beds, wet soil must belong to the watered plant rather than falsely indicating that the entire bed was watered.
- Neighbor fertilization target granularity remains unresolved in CONCEPT.md. Per-plant nutrient flecks are a visual proposal to revisit when that rule is specified.
- Models communicate growth and harvest at a glance. Detailed badges appear near or on selected plants; a proposed care view can reveal compact symbols across the garden.
- Pair colors with distinct symbols. Do not require color alone to distinguish states.
- Crop quality is determined at harvest. Reserve Common, Blue, Silver, and Gold indicators for the resulting crop; growing plants must not imply an already-determined quality.
- No wilting, cracked desert soil, or threatening decay imagery is needed for the dry treatment.

### Motion direction

Use brief leaf responses to watering, a small branch response when picking, grape clusters detaching as a coherent bunch, and gentle pepper-branch lift after harvest. Ambient motion stays subtle and offset between plants. Avoid constant synchronized bouncing or persistent particle effects.

## 5. Spatial and map studies

Maps use the same 3D model and material language as the environment. Render them directly overhead with uniform scale, restrained shadows, clear boundaries, and visible roads. Earlier storybook-paper treatments are superseded by this 3D contract.

### Proposed village starting layout

- Eight equal rectangular homesteads: four north and four south.
- Northern entrances face south; southern entrances face north.
- A rounded rectangular loop road surrounds an elongated central market green.
- Eight player stalls form two rows of four with a pedestrian aisle.
- A separate community grocery anchors the west end; open gathering space occupies the east end.
- Short matching connections join all property gates to the loop.
- Perimeter trees soften the boundary without hiding the plan.

This is a layout to evaluate, not final geometry. Verify usable property equality, access, counts, and movement space before approving it.

### Proposed sample property

- Supersedes the earlier tight two-column arrangement: use a broader property with an offset cottage, clustered productive gardens, and substantial open space for eventual free placement and decoration.
- A southern gate leads to a branching cream path with generous movement space; avoid making the whole property a narrow central aisle.
- Exactly eight growing areas arranged in a few readable clusters. Keep beds reachable and leave building footprints separate.
- Cottage and tree greenhouse occupy distinct zones with practical entrances; preserve greenhouse second-floor clearance.
- Reserve a contiguous customization lawn, not just thin leftover strips. For the next study, aim for roughly one-third of usable land open after all eight areas and both buildings are present; final dimensions remain open.
- Digging patch near the gate, outside the beds; proposed preserving station beside the cottage.
- Cottage and greenhouse footprints are additional to all eight growing areas.

Starter and developed images must preserve identical boundaries and reserved footprints. Only the first four-slot growing area begins unlocked. An illustration of a developed greenhouse does not establish its release timing.

The property-map, starter-to-thriving, and cottage-arrival prompts below use the approved spacious direction. The saved starter-to-thriving v2 prompt already follows that direction and is preserved as generation history. Superseded unapproved images and their saved prompts have been removed from `concept/`.

## 6. Branding, currency, and interface identity

The logo borrows chunky silhouettes and the faded earthy world palette, with cream lettering kept clear. Use flat graphic layers and shallow depth for small-size readability; lettering can be softer than the world geometry. Avoid textured wood, carved ornament, and elaborate bevels.

- Main title: **Homestead Tycoon**.
- Clear secondary line: **Luna Landing**.
- Preferred first exploration: a welcoming cottage sign with cream lettering, forest-green outline, warm timber, and a small crescent emblem.
- Alternatives: a harvest badge or a simpler village wordmark.
- Working tagline: **Start with dirt. Grow a home.** Omit from initial logos to preserve readability.
- Sterne is an ordinary star coin. **Approved design: option C** in `concept/pngs/15-sterne-star-coin.png`: thick octagonal silhouette, inset five-point star, shallow rim, and muted matte brass/ochre finish. Use only C as the currency reference; A and B are unselected explorations. Final mesh dimensions and interface treatment remain open; moon and star branding must not imply magical currency.
- Crop-quality identifiers remain Common, Blue, Silver, and Gold. Pair color with a label or symbol. Preserve-quality badge treatment remains unapproved.

## 7. Reusable generation contract

Append this shared block to environment and asset prompts below. Each prompt describes its own subject and composition; the shared block maintains the finish. Rebuild prompts from this revision before generating; saved `.prompt.txt` files beside earlier renders document previous attempts and do not override this contract.

> Layered low-poly 3D for a cozy Roblox homesteading game, achievable in Roblox Studio. Early-console garden charm: slightly scruffy, friendly, recognizable forms built from a modest number of chunky overlapping geometric parts. Broad flat-shaded faces, restrained bevels, solid matte colors, almost no surface texture. Structural depth from roof thickness and overhangs, inset windows, porch posts and steps, recessed soil, branching trunks, several faceted canopy clusters, and a few overlapping crop leaves. Faded warm timber, dull cream paths, muddy brown soil, healthy dusty greens, muted terracotta, and brighter recognizable produce. Slight asymmetry and humble proportions. Simple daylight, modest shadows, clear gameplay-like framing, generous paths, and practical entrances. Nonmagical natural living. Preserve structural layering; avoid featureless single-primitive objects. No individual shingles, wood grain, bark texture, individual tree leaves, dense tiny flowers, fasteners, pebble geometry, elaborate cloth folds, glass refraction, glossy plastic, cinematic lighting, bloom, or depth-of-field blur. The result should resemble a lightweight playable game scene, not a detailed miniature render.

**Map addition:**

> Strict overhead orthographic view of a layered low-poly game environment. Uniform scale, clear property boundaries, readable road geometry, and restrained shadows. Preserve the specified layout and counts. No perspective convergence, tilt-shift blur, or paper texture.

**Logo exception:** Use the branding prompts directly. Do not append environment lighting, garden-layout instructions, or full 3D scene styling to a logo prompt. Request a transparent background when generating logos.

## 8. Concept prompt library

### 1. Main atmosphere — the emotional target

> Wide concept image for “Homestead Tycoon: Luna Landing,” a cozy Roblox homesteading game set in a nonmagical autumn village. View from a cream gravel garden path toward a small timber cottage with a welcoming porch. Raised wooden beds contain recognizable peppers, pumpkins, and purple grapes on low supports; a tree with clustered faceted foliage grows in its own dedicated bed. Sparse simple flower clumps, plain timber fencing, a simple produce basket, and a timber-framed greenhouse with large plain panes create a productive, cared-for home. Simple warm afternoon daylight, spacious paths, inviting human scale, attainable low-poly Roblox environment. The garden feels cultivated and rewarding. No text or UI. Landscape 16:9.

### 2. Art-style comparison — controlled finish calibration

This exploratory sheet varies structural layering while keeping geometry and surfaces simple. Use it to calibrate the number of parts, not to introduce richer textures or cinematic rendering.

> Three-panel visual development sheet showing the exact same small cottage, raised pumpkin bed, apple tree, and gravel path from the same three-quarter camera angle. Panel one: sparse structural layers. Panel two: moderate structural layers with foundation, roof thickness, window frames, porch posts and steps, and overlapping canopy clumps. Panel three: slightly more structural layering through a few extra broad trim pieces and branches, still plain and economical. All panels use clearly low-poly flat-shaded geometry, solid matte colors, and almost no texture. Keep silhouettes, object positions, scale, warm autumn palette, and natural afternoon lighting consistent. Equal panel sizes, neutral cream background, no text or decorative borders. Simple playable-game rendering in every panel; no photorealism, glossy plastic, individual leaves, shingles, or wood grain.

Preferred baseline: panel two, with moderate structural layering, plain surfaces, and readable crops.

### 3. Color, materials, and garden details

> Curated 3D art-direction board for a cozy autumn homesteading game. Large color swatches accompanied by stylized material samples: faded warm timber, dark fertile soil, dull cream path surface, muted sage foliage, dusty leafy green, pumpkin orange, apple red, grape purple, and a small midnight-blue accent. Include short wooden fence sections, raised-bed corners, simple arched trellises, porch posts, terracotta pots, and understated flower borders. Broad faceted shapes, restrained bevels, plain matte colors, no grain, consistent scale, and simple daylight. Spacious arrangement on warm ivory, no text or photographic elements.

### 4. Starter-to-thriving property

> Two-panel concept illustration of the same homestead from an identical elevated three-quarter camera. Use the approved spacious property layout as the reference: broad boundaries, northwest cottage, northeast greenhouse footprint, branching paths, clustered western/northern gardens, and a large uninterrupted southeastern customization lawn of roughly one-third of usable land. Preserve identical property boundaries, reserved positions, and open lawn in both panels. Left: a modest cottage, reusable digging patch, one unlocked wooden growing bed with four planting slots, and open land. Right: a thriving version with precisely eight distinct growing areas, an improved cottage porch, produce displays, sparse simple flower clumps, and a tree greenhouse. Reserve all eight growing-area footprints plus separate cottage and greenhouse space in both views; show unused reserved ground naturally in the starter view. One apple tree occupies an entire growing area in the developed view. Generous cream gravel paths, warm fall daylight, achievable handmade upgrades. No UI, text, or prices.

### 5. Community market

> Elevated wide concept view of a friendly autumn village market. Exactly eight distinct wooden player stalls arranged around an accessible village green, with a separate community grocery as the architectural anchor. Stalls display peppers, pumpkins, apples, grapes, preserve jars, and cider bottles. Plain cream awnings with minimal folds, faded warm timber, simple produce symbols, chunky benches, sparse low-poly planters, broad flat cream walkways. A few blocky game characters browse and carry baskets. Clear navigation, restrained decoration. No readable text, oversized fantasy buildings, or festival crowds.

### 6. Harvest and pantry still life

Recipe products and packaging are proposals from CONCEPT.md.

> Stylized 3D product concept board: a red pepper, orange pumpkin, purple grape cluster, red apple, purple grape-jelly jar, amber-red pepper-jelly jar, amber apple-cider bottle, and two orange jars distinguished by pumpkin-puree and soup pictograms. Layered low-sided bodies, shoulders, rims, plain oversized lids, and flat pictogram labels, readable at small game scale. Use solid colored contents and minimal highlights. Arrange on a cottage pantry shelf with a simple low-poly produce basket and plain cream cloth with one broad fold. Warm timber and soft daylight. No brands, readable lettering, quality effects, or magical glow.

### 7. Logo explorations

Generate the three directions separately.

**A. Cottage sign — preferred starting point**

> Logo concept for a cozy farming game. Exact title “HOMESTEAD TYCOON” in large friendly rounded lettering, with “LUNA LANDING” clearly readable beneath. Compact timber-sign silhouette, cream lettering, deep forest-green outline, small cottage roof and sprouting leaf integrated into the composition. A restrained crescent appears as a carved town emblem. Warm, welcoming, and simple enough to read at thumbnail size. Plain faded timber color, no grain. Clean flat graphic layers with shallow depth and minimal edge treatment. Transparent background, no mockup, no extra words or tagline.

**B. Harvest badge**

> Compact illustrated badge logo reading exactly “HOMESTEAD TYCOON” with “LUNA LANDING” beneath. Bold rounded cream lettering, dark green outline, pumpkin and apple accents at the base, a simple roofline above, and a tiny crescent detail. Pumpkin orange, leafy green, honey gold, and cream. Balanced silhouette, minimal ornament, softly rounded shapes, crisp edges, shallow dimensional depth, strong readability at small sizes. Transparent background, no scenery, no additional text.

**C. Village wordmark**

> Clean playful wordmark logo reading exactly “HOMESTEAD TYCOON” and secondary text “LUNA LANDING.” Soft substantial lettering with gently irregular handmade character, deep evergreen and warm cream, small terracotta accent. Integrate one simple cottage-roof shape and a subtle crescent into a compact emblem beside the lettering. Flat colors, minimal detail, legible at small sizes. Transparent background, no scenery, no extra wording.

### 8. Evening atmosphere

> Cozy autumn homestead at blue hour, viewed from the garden gate toward a timber cottage with warmly lit windows and porch lanterns. Raised beds and recognizable crops remain clearly visible, with cream gravel paths catching the last daylight. A small natural crescent moon above the roofline, muted blue sky, warm amber windows, deep green foliage, restrained orange pumpkins. Gentle contrast, peaceful inhabited atmosphere. Moonlight behaves naturally. No magical particles, glowing plants, spooky Halloween decorations, text, or UI. Landscape 16:9.

### 9. Village map — roads, properties, and market

Append both the shared contract and map addition.

> Readable layered low-poly 3D overhead planning map for “Homestead Tycoon: Luna Landing.” North at the top. Exactly eight equally sized rectangular homestead properties: four across the north side and four across the south side. Each property has a visible boundary and one inward-facing entrance. Northern properties face south; southern properties face north. A continuous rounded rectangular cream-gravel loop road sits between the property rows and surrounds an elongated central village green. Exactly eight small timber market stalls occupy the green in two rows of four, separated by a broad pedestrian aisle. A separate community grocery anchors the west end; the east end has the approved parkour area with open gathering space and pedestrian access clear of the truck road. Short paths connect all eight property gates to the loop. Each equal homestead follows the approved spacious direction: offset cottage, separate greenhouse footprint, eight clustered growing areas and substantial uninterrupted customization lawn. Enlarge the village footprint to fit these properties rather than squeezing the lawns. Show the circulating market truck and a sparse visible purchasable-seed trail on the loop without prescribing packet counts or prices. Dusty sage grass, muted terracotta rooftops, faded timber and pumpkin accents, autumn trees around the perimeter. Roads and boundaries remain fully visible. No extra homesteads, extra stalls, decorative road branches, fantasy landmarks, or text. Landscape 3:2.

### 10. Sample property map — spacious approved direction

Append the shared contract and map addition.

> Use the approved spacious property image as the spatial reference. Strict overhead orthographic view, north at top, broad nearly square timber-fenced property. Southern gate slightly left of center, branching cream paths, cottage northwest with porch facing south and greenhouse northeast with west-facing entrance. Exactly eight countable raised growing areas clustered in western and northern-middle pockets, with clear access around each; one whole-area apple tree and peppers, pumpkins and grapes elsewhere. Separate cottage and greenhouse footprints, unframed digging patch southwest near gate, proposed compact preserving workbench beside cottage. Leave roughly the southeastern third as uninterrupted open customization lawn inside the fence; no beds or decor there. Do not revert to a narrow central aisle or four matching rows. Final dimensions and greenhouse capacity remain open. No text, measurements or UI. Landscape 4:3.

### 11. Cottage arrival view — spacious approved direction

Append the shared contract.

> Use concept/pngs/09-spacious-property-layout.png as the approved spatial reference. Eye-level game view from the southern gate slightly left of center, looking along a broad branching cream path toward the northwest cottage porch. Productive raised beds cluster to the west and northern middle rather than forming a narrow symmetrical aisle; preserve all eight growing-area positions even if some are obscured by this camera. Northeast timber-framed greenhouse entrance faces west toward the garden paths. Southwest digging patch near the gate, proposed preserving workbench beside cottage, and large open southeastern customization lawn visible to the right. Separate building footprints and unobstructed practical entrances. Warm natural fall afternoon; cottage is the main visual anchor. Preserve spacious boundaries and open lawn. No extra buildings, lawn-filling decor, text or UI. Landscape 16:9.

### 12. Crop growth model sheet

> Layered low-poly 3D crop model development sheet for Roblox. Four rows showing peppers, pumpkins, low-supported bush-like grapes, and apple trees. Each row contains four clearly separated stages from left to right: planted, developing, mature with small developing fruit, and harvest-ready with full-sized produce. Purpose-built silhouettes for every stage, not uniformly scaled copies. Maintain consistent scale within each crop row; apple trees use their own clearly separated scale. A few broad overlapping polygonal leaves, plain matte foliage, and low-sided fruit with minimal highlights. Trees use overlapping canopy clumps without individual leaves. Harvest-ready produce is prominent and visible outside the foliage. Pumpkin vines spread low, peppers grow upright, grapes fill a low timber support, apples develop a clustered faceted canopy. Neutral warm-cream background, consistent three-quarter orthographic camera and simple even daylight. Clean spacing, no decorative scenery, UI, or text.

### 13. Plant care and readiness comparison

The original compost-ring prompt below is superseded by `concept/prompts/10-plant-care-states-v2.prompt.txt`: short blue droplet feedback and persistent matte gold soil flecks. Use the revised prompt for future studies.

> Layered low-poly 3D visual development sheet showing the same mature pepper plant in six separate small soil samples, with identical camera, scale, lighting, and foliage geometry. Sample one: lighter matte soil, healthy plant ready for watering. Sample two: locally darkened watered soil around the base. Sample three: lighter soil with a simple compost ring of a few broad marks. Sample four: darkened watered soil plus compost ring. Sample five: harvest-ready plant with prominent full-size ripe peppers above lighter soil. Sample six: harvest-ready plant with full-size peppers, dark watered soil, and compost ring together. First four samples have smaller developing fruit. Care states coexist visibly without changing overall plant color. A few broad overlapping leaves, chunky faceted peppers, warm neutral background, simple consistent daylight. No wilting, cracked desert soil, magical particles, status text, or floating icons.

### 14. Style validation scene

Recommended first generation to test whether buildings, foliage, crops, and small props belong together.

> A compact layered low-poly 3D visual development scene achievable in Roblox Studio containing one small timber cottage, one apple tree in its own raised growing area, one separate raised bed planted with peppers and pumpkins, and one oversized preserve jar displayed separately as a material study. Consistent design language across architecture, foliage, fruit, soil, and glass. Cottage has a separate foundation, plain wall body, broad thick pitched roof with eaves, inset door, window frames, porch platform, chunky posts, and steps. No shingles or wood grain. Tree has an angular branching trunk and several overlapping broad faceted canopy clumps with readable red apples; no individual canopy leaves. Crops use a few overlapping polygonal leaves and chunky produce. Jar has a low-sided body, shoulder, thick rim, plain lid, solid colored contents, and a flat fruit-symbol label. All surfaces remain plain and matte; interest comes from layered construction. Warm neutral background, three-quarter orthographic view, clear spacing, simple daylight and modest shadows. Show the complete silhouette of every study object. No text or UI.

### 15. Sterne ordinary star coin — design exploration

**Status:** Approved: option C only — thick octagonal star coin. A and B are unselected explorations.

The prompt below records the original exploration; the approval above governs future use.

Saved prompt: [concept/prompts/15-sterne-star-coin.prompt.txt](concept/prompts/15-sterne-star-coin.prompt.txt). Append the shared generation contract.

> Asset type: currency concept sheet, proposed designs for Homestead Tycoon: Luna Landing.
> Primary request: Explore three ordinary physical star-coin silhouettes for the single currency Sterne. Equal columns: A, a thick low-sided round coin with a large shallow five-point star stamp; B, a chunky five-point star-shaped coin with blunt tips; C, a thick octagonal coin with a large inset five-point star. Each column shows the same option in a large front view, a three-quarter view exposing thickness, and a small flat inventory-icon preview. Keep one muted brass/ochre matte color family across all three options so silhouette is the comparison. Shallow rim, broad plain faces and no fine engraving. Plain warm-cream background, generous spacing, simple even lighting and modest shadows. Exact small column labels: "A", "B", "C"; title "Sterne". Landscape 3:2.
> Constraints: All options represent the same ordinary earned currency, not denominations, rarities or upgrade levels. Shape and material remain open. No numbers, balances, prices, gems, moons, magical energy, particles, sparkle, mirror metal, ornate engraving or invented gameplay. Star remains legible at icon size. References supply palette and economical construction, not a currency design to copy.

### 16. Cottage housing — exterior construction sheet

**Status:** Approved exterior concept; use as a cottage architecture reference.

The prompt below records the original exploration; the approval above governs future use.

Saved prompt: [concept/prompts/16-cottage-housing-sheet.prompt.txt](concept/prompts/16-cottage-housing-sheet.prompt.txt). Append the shared generation contract.

> Asset type: dedicated cottage exterior concept sheet for Homestead Tycoon: Luna Landing.
> Primary request: Isolate the humble timber-and-cream cottage from the approved spacious-property reference. One consistent proposed building shown in a large front three-quarter view, smaller rear three-quarter view and straight front elevation, all on a plain warm-cream background. Maintain the same roof, doors, windows and porch across views. Separate foundation, cream wall body, terracotta pitched roof with thickness and broad eaves, timber structural trim, recessed front door, simple inset framed windows, porch platform, substantial posts, low rail and broad steps. Use large plain roof planes, sparse low-poly foundation pieces and a modest chimney. The main view reveals the side wall and all steps. Keep the silhouette approachable and achievable in Roblox Studio, with generous entrance access and only sparse shrubs near foundation edges. Landscape 3:2; no text.
> Constraints: This is one house studied from several angles, not house tiers or an upgrade sequence. Cottage is additional to eight growing areas. Do not design a full property or interior, add mandatory room functions, imply a final footprint or price, or consume the reserved customization lawn. Keep pantry/interior detail deferred. No luxury manor, shingles, tiny masonry, fine porch ornament, wood grain or clutter.

### 17. Community grocery — architecture and NPC selling access

**Status:** Approved grocery architecture/service concept; use as a visual reference. Market rules and final interface behavior remain open.

The prompt below records the original exploration; the approval above governs future use.

Saved prompt: [concept/prompts/17-community-grocery-sheet.prompt.txt](concept/prompts/17-community-grocery-sheet.prompt.txt). Append the shared generation contract.

> Asset type: standalone community grocery architecture and service concept sheet for Homestead Tycoon: Luna Landing, complementing the existing community-market and player-stand studies.
> Primary request: A modest timber-and-cream community grocery with a broad terracotta pitched roof and welcoming covered porch, structurally related to the approved cottage but wider for clear public access. Large three-quarter exterior view on the left; smaller straight front elevation at upper right and a close architectural view of the NPC selling counter at lower right. All views show the SAME building with the same entrance and counter locations. Plain warm-cream background and a small cream forecourt patch, without a village layout. Separate a broad open doorway from an obvious low selling counter under the porch. Show one simple counter tray for goods, grouped crates of the four beginner crops and a few low-sided jars and cider bottles; these explain selling access without prescribing inventory limits. A compact board beside the counter uses only four recognizable crop pictograms and broad up/down arrows to suggest current market-price checking, no numeric values. A small restrained crescent town emblem above the doorway. Spacious clear approach and room to stand at counter; chunky posts do not block access. Landscape 3:2. No readable text, UI or characters.
> Constraints: Grocery is the NPC buyer of fresh and processed goods at current market prices and supports solo sales. Counter and board arrangement is a visual proposal; price fluctuation rules, purchase interface, and exact service placement remain open. Grocery is distinct from the later community center, eight player-owned stands, and moving seed-market truck. Do not add seed sales, player-set NPC prices, donation bundles, milestone unlocks, final prices, extra stalls or upgrade requirements. Game information, leaderboard and upgrade access remain hub services; this sheet does not relocate or finalize them.

### 18. Tree greenhouse — ground floor and second-floor study

**Status:** Proposed visual study; awaiting review.

Saved prompt: [concept/prompts/18-tree-greenhouse-floors.prompt.txt](concept/prompts/18-tree-greenhouse-floors.prompt.txt). Append the shared generation contract.

> Asset type: proposed greenhouse architectural study for Homestead Tycoon: Luna Landing.
> Primary request: Three clearly separated views on a warm-cream background: a one-floor timber-framed tree greenhouse exterior; a second-floor architectural alternative on the SAME ground footprint; and a simplified cutaway of that two-floor alternative revealing floor separation, practical circulation and headroom for clustered tree canopies. Plain timber base, chunky posts and roof beams, a few large simply tinted transparent panes, broad obvious entrance. Sparse representative low-poly trees with angular branching trunks and clustered canopy, without planting-slot grids or capacity labels. Use a simple visible staircase as one proposed access solution, not an approved requirement. Landscape 3:2, no text, dimensions or arrows.
> Constraints: Tree greenhouse and second-floor upgrade are approved directions; capacity, functional benefit, access design, release timing, dimensions and unlock order remain open. Do not imply a fixed tree count, area tiers, extra outdoor growing areas, magical glass or a production-ready structural plan. Separate greenhouse footprint from the eight outdoor areas. Keep tree clearance honest rather than squeezing foliage through ceilings.

### 19. Preserving station and proposed product family

**Status:** Proposed visual study; awaiting review.

Saved prompt: [concept/prompts/19-preserving-station-products.prompt.txt](concept/prompts/19-preserving-station-products.prompt.txt). Append the shared generation contract.

> Asset type: proposed processing station and product concept sheet for Homestead Tycoon: Luna Landing.
> Primary request: On a warm-cream background show a compact practical preserving workbench in a large three-quarter view, with chunky cooking vessel and a simple hand press/bottling arrangement. Clearly separated collection shelf and broad working surface, minimal tools. Below it show five isolated readable products at consistent scale: purple grape-jelly jar, amber-red pepper-jelly jar, amber nonalcoholic apple-cider bottle with apple pictogram, orange pumpkin-puree jar with pumpkin pictogram, and creamy-orange pumpkin-soup jar with distinct bowl-and-spoon pictogram. Low-sided bodies, shoulders, thick rims, plain oversized lids, one flat pictogram label each, solid contents or restrained tinted glass. Keep the station modest enough to sit beside the cottage without blocking the porch or path. Landscape 3:2, no text.
> Constraints: One station supporting cooking and pressing/bottling and these five recipes are proposals. Equipment affects output quality, but final tiers, size, recipe confirmation, batch quantities, duration, costs and quality formulas remain open. No conveyor, repeated-help clicking, ingredient supply chain, wine, passive-income mechanisms, invented tiers, rarity glow or final preserve-quality badge. This is construction/packaging exploration, not interface approval.

### 20. Crop quality badges — accessible harvested-goods treatment

**Status:** Proposed visual study; awaiting review.

Saved prompt: [concept/prompts/20-crop-quality-badges.prompt.txt](concept/prompts/20-crop-quality-badges.prompt.txt). Append the shared generation contract.

> Asset type: proposed inventory badge visual study for Homestead Tycoon: Luna Landing.
> Primary request: Four equal columns with exact labels "Common", "Blue", "Silver", "Gold". Each contains a large simple matte badge and a small inventory-tile preview using the same harvested red apple. Pair warm neutral Common, muted blue Blue, dull silver Silver and muted ochre-gold Gold with clearly different broad outline/symbol treatments so color alone is never required: plain rounded square, simple triangle mark, simple diamond mark, and simple broad rosette mark respectively. These symbol choices are proposals, not locked rank iconography. Clear dark outlines, flat colors, minimal shallow depth, plain warm-cream background, generous spacing and easy small-size readability. Landscape 3:2.
> Constraints: These are the four confirmed crop quality names, applied to harvested goods only. Do not show quality on growing plants, odds, values, star ratings, additional ranks or magical effects. Preserve quality exists but whether it uses this badge system remains unapproved; do not attach badges to jars or bottles. Badge shapes and interface arrangement remain for user review.

## 9. Generation sequence and review

### Approved references — October 12, 2026

- [Style validation v2](concept/pngs/01-style-validation-v2.png): approved asset construction and finish.
- [Main atmosphere v2](concept/pngs/02-main-atmosphere-v2.png): approved environmental mood.
- [Market truck](concept/pngs/05-market-truck.png): approved everyday truck design.
- [Spacious property layout](concept/pngs/09-spacious-property-layout.png): approved spatial direction with clustered gardens and substantial customization space; exact dimensions remain open.

Village-map revision must accommodate eight equally spacious properties based on the approved layout, the circulating truck and visible seed packets, and a parkour area at the east end of the central green. Enlarge the village footprint as needed instead of squeezing out property customization space. Keep all eight market stalls and the separate grocery.

Logo revision should give Luna Landing a more distinctive moon-and-stars identity while preserving clear title hierarchy and small-size legibility. Stronger celestial branding is approved for the logo; it does not introduce magical farming. The superseded earlier logo and village-map renders do not override the approved v3 logo and v2 village-map references listed below.

1. Regenerate the style validation scene using the layered low-poly direction. Review it before extending the set; use the comparison sheet if structural layering needs calibration.
2. Establish the main atmosphere and preferred logo direction.
3. Approve overhead village and property arrangements before deriving perspective images.
4. Refine crop growth and combined care states before illustrating a densely planted garden.
5. Extend the chosen direction to market, pantry, materials, evening, and progression images.

Reuse only images accepted under this revised contract as references for subsequent generations. Preserve camera and composition when comparing style, growth, or state variants.

### Additional approved references — October 12, 2026

- [Luna Landing logo v3](concept/pngs/03-cottage-sign-logo-v3.png).
- [Village map v2](concept/pngs/04-village-map-v2.png): parkour, truck, seed trail, and roomy properties; individual bed counts still need refinement.
- [Starter-to-thriving v2](concept/pngs/07-starter-to-thriving-v2.png): regenerated from the approved spacious property, with one four-slot starter bed and eight developed beds while retaining the customization lawn.

The seven references listed above are approved. Images live in `concept/pngs/` and their matching generation prompts live in `concept/prompts/`, using the same filename stem. Approval establishes visual direction rather than measured construction geometry.

### New studies awaiting approval

- [Crop growth sheet v2](concept/pngs/08-crop-growth-sheet-v2.png): four stages for each of the four beginner crops.
- [Plant care states v2](concept/pngs/10-plant-care-states-v2.png): top row dry / watering / fertilized; bottom row watering + fertilized / ripe + dry / ripe + watering + fertilized. Brief blue falling droplets and splash shapes depict watering feedback; flat matte ochre-gold soil flecks propose a persistent fertilized marker. Dark soil remains after the watering animation ends. This PNG is an animation concept, not an animated asset. The rejected compost-ring sheet has been removed.
- [Seed pack designs](concept/pngs/11-seed-pack-designs.png): standard four-seed packs and larger nine-seed packs, differentiated by size, band, quantity numeral, and seal shape. Packaging and crop pictograms are proposals, not final minimap icons or planting-material naming.

### Additional generated studies awaiting approval

- [Community market](concept/pngs/12-community-market.png): grocery, eight player stalls, price and information boards, leaderboard, and upgrade access.
- [Player market stand](concept/pngs/13-player-market-stand.png): matching stocked, rear-access, and empty views.
- [Parkour garden](concept/pngs/14-parkour-garden.png): low timber and rock obstacle route, gathering space, and separation from the truck road.

Before accepting an image, check:

- Clearly low-poly geometry with moderate structural layering, plain matte surfaces, faded earthy surroundings, and simple game-like lighting.
- A cottage retains porch, eaves, inset openings, and steps; trees retain branches and canopy clusters. Avoid both featureless primitives and excessive small parts.
- No wood grain, individual shingles, dense canopy leaves, intricate prop detail, or cinematic miniature finish.
- Legibility at gameplay or thumbnail scale, as appropriate.
- Exact counts and intended orientation in maps; image generation may drift from specifications.
- Eight reserved growing areas plus separate building footprints in property studies.
- One apple tree per occupied area; correct crop silhouettes and repeat-harvest behavior.
- Care states that combine and remain distinguishable without color alone.
- Exact logo wording, hierarchy, and small-size readability.
- No invented mechanics treated as approved features.

These images establish art direction. They are not measured construction plans, production-ready meshes, final UI specifications, or evidence that maximum planting density performs well in-game.

### Prompt coverage audit — October 12, 2026

- Existing market hub (12) and player stand (13) already have saved prompts and PNGs awaiting approval; no duplicate market scenes needed.
- Added reusable prompts for Sterne (15), one cottage exterior (16), standalone grocery (17), greenhouse floors (18), preserving station/products (19), and harvested-crop quality badges (20). Sterne option C, the cottage and the grocery are now approved visual references. Greenhouse, processing and quality-badge sheets remain proposals; no tiers, prices or progression are approved by these prompts.
- Replaced stale narrow property-map and arrival directions with the approved spacious layout; saved forward-use prompts as 21 and 22. Kept all existing renders and historical matching prompts intact, including approved starter-to-thriving v2.
- Greenhouse capacity/access, material identities, equipment tiers, preserve badges, market interfaces and later community-center content still need decisions in CONCEPT.md. Do not fill those gaps with invented mechanics. Evening and pantry directions exist in this document but have no dedicated PNGs; they are later visual opportunities rather than missing gameplay rules.
- Next focused sheet opportunities: growing-area 4/6/9-slot tier comparison and whole-area apple yield silhouette. Their gameplay direction exists, but final dimensions and yields remain open. No dedicated sheet generated in this pass.

### Approved priority concepts — October 12, 2026

Generated using the built-in imagegen tool with inspected approved style-validation v2 and spacious-property images as references. User approved Sterne option C and the cottage and grocery concepts on October 12, 2026.

- [Sterne star-coin exploration](concept/pngs/15-sterne-star-coin.png): **Option C approved:** thick octagonal coin with inset five-point star, shallow rim and muted matte brass/ochre finish. A and B remain unselected; use C for subsequent currency work.
- [Cottage housing exterior sheet](concept/pngs/16-cottage-housing-sheet.png): **Approved cottage exterior:** one cottage shown in exterior views; no upgrade tiers or interior commitments.
- [Community grocery architecture/service sheet](concept/pngs/17-community-grocery-sheet.png): **Approved grocery concept:** exterior, front elevation and selling counter, using the four beginner crops and broad plain roof planes. Price-board arrows and counter arrangement are accepted visual direction; exact interfaces and market rules remain open.

Matching complete prompts are saved under `concept/prompts/` with identical stems. Prompts 18–22 are saved for reuse; no images were generated for them in this pass. The sheets are art references rather than measured plans; view-to-view details still need reconciliation when modeling in Studio. CONCEPT.md gameplay rules and all previously approved reference statuses remain unchanged.
