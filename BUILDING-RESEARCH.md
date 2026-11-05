# Research cost repair

`research.json` lists all 21 active unlocks: 1 point for each individual device,
3 for the universal transmitter. The retired universal receiver remains hidden
and loadable for existing saves.

Use `tools/build_research.py` with `--retoc`, `--baseline` (the public 1.0.0
CaretakerWirelessFix_P.utoc), `--base` (the matching original game containers),
`--mapping` (Voyage 0.10.0.653173) and a new `--output` directory. See `--help`.
The baseline UCAS hash is pinned. The builder extracts skills with full import
context, updates Cost and localized descriptions using UAssetAPI, and replaces
only their 21 raw Zen chunks in the original container. All other 75 chunks,
including the container dependency header, must remain identical. A final
complete-context extraction verifies semantic exports and imports.

Copy the three verified container files from `output/package` into the runtime
folder. Generate translations with `generate_runtime` in
`tools/build_localization.py`. Update `Dateien.json` deliberately, then run
`tools/package_release.py`. The ZIP must contain only its 22 runtime files.

`py -m unittest discover -s tools -p 'test_*.py'` runs the Lua regressions
with Python/lupa. Recipe recovery must never grant skills or infer ownership
of a receiver from a transmitter.

Native regression uses `tools/research_probe.lua` in an isolated copied profile
whose path contains `/research-1.0.1/profile/`. The private harness supplies
`WIRELESS_RESEARCH_TEST.output` and `.slot`; it is not packaged. Once ready,
run `tools/research_checks.lua` with the Controls Scripts directory on Lua's
package.path. Research validation uses `ValidatePlayerSkill`, the same eligibility
API as normal research, before the engine's unconditional `UnlockPlayerSkill`
grant operation. Tests cover point deductions, both level gates, zero points,
two versus three points for the universal transmitter, duplicate purchases and
the recipe-recovery bypass. Restore `T.pc.PlayerState=T.originalState` afterwards.

The native test uses a temporary player state in the copied world and does not
edit the original saves. Do not install changes over a running game; preserve
the user's configuration. Remove the development probe's enabled.txt after
testing. See `verification/research-1.0.1.json` for the recorded scope and limits.
