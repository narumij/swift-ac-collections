# Public API naming decisions

Status: decisions in progress. Copied value access vocabulary was adopted on 2026-10-13; all other
scopes remain undecided.

## Purpose

This is the authoritative record of public API naming decisions produced after scoring and
discussion. The score report, ChatGPT discussion, and reviewer agreement are inputs; none of them
adopts an API by itself. The user makes the final public decision.

Record conclusions rather than conversation transcripts. Preserve material rejected alternatives,
accepted review observations, user priorities, reservations, and implementation consequences so
the decision can be understood and applied later.

## Decisions

| Scope | Status | Adopted public name or family | Principal alternatives | Material discussion result | User priority or reservation | Implementation and specification consequence | Date |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Always-initialized owner base | Not decided |  |  |  |  |  |  |
| Presence-tracked owner base | Not decided |  |  |  |  |  |  |
| One-dimensional suffix | Adopted | Unsuffixed 1D for both owner families; append `2D`, `3D`, and `4D` for higher ranks | Explicit `1D` for both; preserve the current asymmetry | Codex and Claude independently preferred one predictable base-case rule. After the concrete meaning was clarified, the user accepted the aligned AI recommendation | The selected base name itself denotes the 1D owner; do not preserve family asymmetry merely to avoid migration | Rename the current `OptionalArray1D` lineage to the selected unsuffixed presence-tracked base. Keep higher-rank suffixes explicit and apply the same rule to both families | 2026-10-13 |
| Copied value access | Adopted | `element(at:)` / `setElement(_:at:)` | `value(at:)` / `setValue(_:at:)` | Codex and Claude independently preferred the current `element` vocabulary because it names stored elements and does not blur reference-element identity with copied-value access. The user accepted the aligned AI recommendation | Preserve element identity and use the existing tested vocabulary | No production rename. Keep both Array families, tests, benchmarks, and documentation on `element` / `setElement` | 2026-10-13 |
| Borrowed-reference method | Not decided |  |  |  |  |  |  |
| Borrowed-reference result type | Adopted | `MutableRef` directly | Contextual `Reference` alias; `MutableElementReference` | The current Prime Codex and Claude independently ranked direct `MutableRef` in their top group. The user clarified that they also considered direct `MutableRef` sufficient. Historical Codex material preserved `Reference` for compatibility or proposed a longer explicit name, but recorded no technical requirement for the alias | Keep one public canonical name and retain visible mutability; do not treat historical AI preference as product authority | Public declarations and documentation use `MutableRef`. `Reference` is not the canonical result name; immediate removal versus a compatibility transition remains an implementation/release decision | 2026-10-13 |
| Borrowed-reference property | Not decided |  |  |  |  |  |  |
| Permutation normal API family | Not decided |  |  |  |  |  |  |
| Permutation borrowed API family | Not decided |  |  |  |  |  |  |
