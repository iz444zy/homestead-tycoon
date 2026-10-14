# Market asset studies — October 14, 2026

## Pending mound study

`Workspace.SeedTruck_MoundStudy` is staged 40 studs beside the current truck in
the connected V2 workshop. It preserves `Workspace.SeedTruck`, removes cargo
crates, uses a compact 25-produce/12-envelope mound, and anchors closed grab
loops to the side rails. Its scripts and prompts are disabled for visual review.
It is not approved for replacement or export. Native save was not confirmed
because Studio UI automation detected active user input.

## Current truck revision: eight riders

`build/MarketWorkshop-v2.rbxlx` is the sole active market experience.
`build/MarketWorkshop.rbxlx` is historical. The reusable pack is an export, not
another working experience. See ../AGENTS.md and ../WORKING_FILES.md.

The user rejected the cluttered cargo/rail treatment below. Preserve the existing
truck while staging a cleaner mound study beside it; wait for approval before
replacement. New experience files always require explicit permission.
The truck is approximately 11.5 × 12.58 × 23.57 studs, versus the first pass's
8.73 × 10.47 × 14.28 studs. Only the truck changed; other saved workspace objects
were compared against the preceding checkpoint and are unchanged.

The elongated cargo bed has five uneven crate stacks, 38 loosely heaped produce
models and 30 tilted seed envelopes, reusing existing asset geometry. Packed
crate interiors support the piles. Four cushioned seats face backward: two on an
upper rear platform and two on the tailgate. There are no side or cab-roof Seats.
Two standing footboards per side have paired vertical handgrips, for eight total
riding positions. The upper platform has a rear ladder and side rails.

`TruckRiders.server.luau` provides distance-checked, exclusive standing holds.
R15 hands use IK targets on the grab handles, while the torso stays upright and
Humanoid.Sit remains false. `TruckRiders.client.luau` releases on JumpRequest,
including the mobile jump button. Both are embedded in the truck as Scripts with
explicit server/client RunContext. The server also releases on death or departure.
Passenger Seats still do not grant vehicle controls.

Play checks: all four hold prompts successfully mounted the real player upright;
Space released the hold, removed its hand IK and restored normal movement. A real
standing rider stayed attached through a 45-degree arc with under 0.000001 studs
of local drift. Eight simultaneous avatar rigs (four native seated occupants,
four standing holds) passed visual clearance and the same arc test with under
0.000002 studs of maximum drift. These are Studio assembly and layout checks,
not an eight-client multiplayer/network test. Full-road motion and seed-release
gameplay remain separate. No runtime script errors were present in the checked log.

The historical `revise_seed_truck.py` entry point is disabled to prevent automatic
file proliferation and replacement of unapproved models.
The original `build_market_assets.py` executable entry point is also disabled;
its geometry helpers remain available. The expanded produce pile inherits the crop
CSG overhead and needs optimization before large-scale production use.

## Original first pass (superseded truck layout)

Open `build/MarketWorkshop.rbxlx` in Roblox Studio. The four new models are staged
at Z ≈ 40, alongside a preserved copy of the existing crop studies. The original
`build/AssetWorkshop.rbxlx` and gameplay place were not modified.

`build/MarketAssets.rbxmx` contains origin-centered reusable models:

- CommunityMarket: timber/plaster grocery with porch, open doorway, selling
  counter, framed windows, closed gables, broad roof, crates and display board.
- SeedTruck: sage/cream cab, timber cargo, striped canopy, existing seed envelopes,
  rear drop shelf, ladder, running boards, grab rails, two roof passenger Seats
  and two outward-facing side passenger Seats. No VehicleSeat.
- SellStallStocked and SellStallEmpty: matching striped stalls, four sloped trays,
  offer-card holders, owner-sign panel, open rear and lower shelf.

References: STYLE_CONTRACT.md and concept images 05, 13 and 17. Produce geometry
is cloned from the approved workshop libraries. Lettuce fills the fourth display
bin because an approved apple asset is not present in that library. Sign emblems
and blank offer panels are provisional; no prices or ownership UI is implemented.

## Truck integration contract

Front is local -Z. Chassis is PrimaryPart and the only anchored part. All other
parts, including Seats, are massless and welded to Chassis. Move Chassis from a
server-owned route controller; players have no steering input. SeedDropOrigin
is an Attachment on Chassis, located above the rear shelf. The route controller,
seed-release schedule, purchase interactions and cleanup are not implemented.
CONCEPT.md currently describes purchasable packets, not free inventory pickups.

The roof perches occupy the solid cab roof; the canvas cargo canopy is not a
designated seat. Side riding currently uses ordinary seats, not a hanging pose.
An animation and mounting-interaction pass remains for that treatment.

## Verification

Inspected truck, both stalls and grocery in native Studio. Corrected inverted
canopy slopes and closed the grocery gables after visual inspection.

In Play mode, all four Seats retained the real player character during a scripted
3-stud translation. A fresh roof-seat test retained the player through a scripted
90-degree arc, with approximately 0.00000012 studs of local-position drift.
The initial arc attempt began during a remount cooldown and was discarded because
the seat was not occupied; the repeat asserted occupancy before starting motion.
This is an assembly check, not multiplayer or full-road integration validation.

Geometry uses native parts and the existing embedded crop CSG. The inherited crop
meshes retain their known CSG triangle overhead; these are review assets, not a
claim of production optimization. Eight-stall layout placement remains separate.

Rebuild with `python studio/build_market_assets.py`. The generator writes the
workshop, reusable pack, report and a dated checkpoint. This directory is not a
Git repository, so dated local checkpoints substitute for unavailable commits.
