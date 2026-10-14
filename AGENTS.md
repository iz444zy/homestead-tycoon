# Workspace instructions

## Active files and approval

- Read `WORKING_FILES.md` before selecting a place or running a builder.
- `studio/build/MarketWorkshop-v2.rbxlx` is the sole active market asset experience. Edit and save that same file.
- Always ask the user for explicit permission before creating any new experience/place file (`.rbxl`, `.rbxlx`), including renamed versions, review copies and checkpoint copies. Do not create them automatically.
- Do not multiply working files, exports, scripts or reports for each iteration. Reuse the established files. New documents explicitly requested by the user are authorized.
- Preserve alternate designs as separate models in an empty area beside the existing model, inside the same active experience. Keep the current model intact. Show the alternative and wait for explicit user approval before replacing the current model or promoting an alternative into the reusable asset pack.
- Never delete old files or versions merely to tidy the directory without user authorization. Mark them historical in the index.
- Inspect the connected live Studio scene before editing. Preserve live user changes; never overwrite it from an older disk build.

## Visual and gameplay direction

- Work in native Roblox Studio/Luau. Follow `STYLE_CONTRACT.md`, concept images and the existing approved plant assets.
- Preserve approved crops and unrelated structures. Keep workshop labels separate from reusable models.
- Seed truck: large, long, charming low-poly vehicle; eight passenger positions; no player driving. Two upper-rear seats, two tailgate seats, and two standing hold-on positions per side. Side riders must look like they are holding on, not sitting.
- Cargo must read as one coherent mound of seeds and produce. Avoid floating props, obvious interpenetration, repeated rows, exposed box scaffolding and disconnected grab rails. Build handholds into visibly supported structural rails/posts.
- Validate silhouette, support, overlaps, rider clearance and relevant interactions in native Studio. Clearly distinguish a visual study from approved assets or finished gameplay integration.

## Changes and checkpoints

- Stage local commits after each meaningful change when a Git repository exists.
- This workspace currently has no Git repository. Do not initialize one solely to satisfy the commit instruction, and do not substitute new experience files for commits.
- Use Studio undo/history and same-experience alternate models to preserve iterations. Save the active experience in place. New experience files still require explicit permission.
