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
| Always-initialized owner base | Adopted | `ElementBuffer` | `BareElements`, `FixedShapeElements`, `BareArray`, `FixedArray`, `HeapArray` | Round 2 converged on `ElementBuffer`: the user scored it neutral 5 and both AIs scored it 7 after reviewing all first-round reasons. It describes owned low-level element storage without promising ordinary Array value semantics | Prefer role accuracy and coherence with the adopted `element(at:)` vocabulary over preserving “Bare” or `Array` | Rename the 1D owner to `ElementBuffer`; with the adopted suffix rule, use `ElementBuffer2D`, `ElementBuffer3D`, and `ElementBuffer4D` for higher ranks. Update production, tests, benchmarks, and documentation together | 2026-10-13 |
| Presence-tracked owner base | Not decided |  |  |  |  |  |  |
| One-dimensional suffix | Adopted | Unsuffixed 1D for both owner families; append `2D`, `3D`, and `4D` for higher ranks | Explicit `1D` for both; preserve the current asymmetry | Codex and Claude independently preferred one predictable base-case rule. After the concrete meaning was clarified, the user accepted the aligned AI recommendation | The selected base name itself denotes the 1D owner; do not preserve family asymmetry merely to avoid migration | Rename the current `OptionalArray1D` lineage to the selected unsuffixed presence-tracked base. Keep higher-rank suffixes explicit and apply the same rule to both families | 2026-10-13 |
| Copied value access | Adopted | `element(at:)` / `setElement(_:at:)` | `value(at:)` / `setValue(_:at:)` | Codex and Claude independently preferred the current `element` vocabulary because it names stored elements and does not blur reference-element identity with copied-value access. The user accepted the aligned AI recommendation | Preserve element identity and use the existing tested vocabulary | No production rename. Keep both Array families, tests, benchmarks, and documentation on `element` / `setElement` | 2026-10-13 |
| Borrowed-reference method | Adopted | `reference(at: ...)` | `mutableElement(at: ...)`, `elementReference(at: ...)` | After `MutableRef` was adopted as the result type, round 2 converged on the current short method. The result type already communicates mutability, so repeating it in the method adds less value | Preserve the compact existing call site and let `MutableRef` carry the result semantics | Keep `reference(at:)` for every ElementBuffer rank and update its declared return type and documentation to the canonical `MutableRef` name | 2026-10-13 |
| Borrowed-reference result type | Adopted | `MutableRef` directly | Contextual `Reference` alias; `MutableElementReference` | The current Prime Codex and Claude independently ranked direct `MutableRef` in their top group. The user clarified that they also considered direct `MutableRef` sufficient. Historical Codex material preserved `Reference` for compatibility or proposed a longer explicit name, but recorded no technical requirement for the alias | Keep one public canonical name and retain visible mutability; do not treat historical AI preference as product authority | Public declarations and documentation use `MutableRef`. `Reference` is not the canonical result name; immediate removal versus a compatibility transition remains an implementation/release decision | 2026-10-13 |
| Borrowed-reference property | Not decided |  |  |  |  |  |  |
| Permutation normal API family | Not decided |  |  |  |  |  |  |
| Permutation borrowed API family | Not decided |  |  |  |  |  |  |
