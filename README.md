# Homestead Tycoon: Luna Landing

<p align="center">
  <img src="concept/pngs/03-cottage-sign-logo-v3.png" alt="Homestead Tycoon: Luna Landing logo" width="720">
</p>

> Start with dirt. Grow a home.

Homestead Tycoon is a Roblox farming and community game set in Luna Landing. Players turn an empty property into a thriving homestead by digging, planting, caring for crops, harvesting, selling or processing produce, and improving their home.

## Project at a glance

- **Platform:** Roblox
- **Genre:** Homestead tycoon with farming, processing, and player commerce
- **Setting:** A welcoming autumn village focused on natural living
- **Currency:** Sterne, represented by a star coin
- **Core loop:** Claim → dig → plant → care → harvest → sell, trade, or process → upgrade

## Project files

- [`CONCEPT.md`](CONCEPT.md) — gameplay vision, core loop, world and scope
- [`STYLE_CONTRACT.md`](STYLE_CONTRACT.md) — visual direction for the world, crops, buildings, and assets
- [`WORKING_FILES.md`](WORKING_FILES.md) — active places and source-of-truth guide
- [`studio/README.md`](studio/README.md) — implementation history, setup notes, and validation records
- [`studio/src/`](studio/src/) — Luau gameplay, UI, crop, and workshop sources
- [`studio/build/MarketWorkshop-v2.rbxlx`](studio/build/MarketWorkshop-v2.rbxlx) — active market workshop experience
- [`studio/build/LunaLanding-AutumnReview.rbxlx`](studio/build/LunaLanding-AutumnReview.rbxlx) — local gameplay place
- [`concept/`](concept/) — concept art and visual references

Open `.rbxlx` experiences in Roblox Studio. Read [`WORKING_FILES.md`](WORKING_FILES.md) before choosing a place to edit; the connected live gameplay scene may be newer than a local file.

## Development notes

This project is developed in native Roblox Studio and Luau. The concept and style documents describe approved direction and identify proposals or open decisions; concept art and workshop studies do not automatically establish gameplay commitments.

For current gameplay setup, persistence settings, controls, and verification notes, see [`studio/FARMING_LOOP.md`](studio/FARMING_LOOP.md) and [`studio/UI_INTEGRATION.md`](studio/UI_INTEGRATION.md).

## Status

An active prototype with farming, inventory, persistence, and native UI work underway. Studio validation notes describe what has been checked and what remains unverified; they are not a claim of a production release.
