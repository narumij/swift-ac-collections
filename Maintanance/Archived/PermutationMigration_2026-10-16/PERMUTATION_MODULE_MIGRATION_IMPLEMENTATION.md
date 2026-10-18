# ワーカー依頼：Permutation module移行の実装・ローカル検証

## TL;DR（人間向け）

Permutation module移行の実装とローカル検証を、Worker Codex 1体へ渡した依頼書（PERM-076）。新名`NextPermutationModule`を実装と主入口に、旧名`PermutationModule`を再公開の互換入口にする実施内容・編集範囲・検証・停止条件を定めている。benchmark名の変更やremote CI・commitは含まない。受入とmain到達は別の記録にある。

Fixed ID: `PERM-076`. Kind: EXECUTION. Owner: Worker Codex (1 implementer). Author and acceptance: Astra.
Base: `17c7ea72`. Based on the user's go-ahead instruction on 2026-10-15. A request file handed over after Registry registration.

<a id="目的と入力"></a>
## Purpose and input

Return the module migration of [the migration plan](../../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md) as one diff verifiable locally.
Read the corrections and supplements in [the investigation acceptance](PERMUTATION_MIGRATION_INVESTIGATION_ACCEPTANCE.md) first.
The new name `NextPermutationModule` is the implementation and main entry; the old name `PermutationModule` stays in main as a compatibility entry re-exporting the same declarations. The benchmark-name tidy-up is delayed to a later stage.

<a id="確定した実施内容"></a>
## Settled work

1. Move the implementation, DocC and design materials in `Sources/PermutationModule/` to `Sources/NextPermutationModule/`, and make the old-name target a thin re-export entry in `Sources/_PermutationModule/`. Use `@_exported import NextPermutationModule`; do not duplicate the implementation.
2. Keep the `AcCollections` product. The facade target depends on the new and old targets, and its source re-exports the new name. Keep existing settings, compiler conditions and the exclusivity of normal / 2025 compatibility mode.
3. Align the normal owner's generic parameter with the decided `Element`. Keep public type names, method names, the nested `Permutation`, contracts and algorithms.
4. Align normal tests and compiler fixtures with the new main entry, and also keep checks of old direct imports and the facade. Confirm type identity of the new and old entries and use of extensions in an external client.
5. Align the new DocC catalog and headings, the old shim's compatibility guidance, and the DocC matrix of both targets. Keep the README's normal import of AcCollections and state the roles of new and old. Do not add a deprecated attribute or a removal deadline.
6. Align only benchmark imports with the new name. Do not change registered titles, libraries, measurement, or input/result normalization.
7. Align names, paths and the compatibility policy in the current documents below. Past execution evidence keeps the names of its time.

<a id="編集できる範囲"></a>
## Editable scope

- `Package.swift`, `Sources/AcCollections/AcCollections.swift`.
- The old and new Permutation source directories and the compatibility shim directory, including DocC, design and quality materials within the moved targets.
- Permutation-related checks in `Tests/PermutationTests/` and `Tests/AcCollectionsTests/`.
- `Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/` and `Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`. Checks of the new, old and facade entries may be added within this fixture.
- Only the imports of `Benchmarks/Sources/Benchmarks/PermutationBenchmarks.swift`.
- Only the DocC matrix of `.github/workflows/ci.yml`.
- The Permutation introduction in `README.md` and `README.ja.md`.
- The current Permutation names, paths and compatibility explanation in `Maintanance/Current/QUALITY_REQUIREMENTS.md`, `QUALITY_ASSESSMENT_INVENTORY.md` and `DOCUMENTATION_CI_PLAN.md`.
- The same scope in `Maintanance/PermutationModule/CurrentQualityAssessment.md` and `UserDocumentationDraft.md`. This management directory is not renamed.
- From 「返却」 onward in the dedicated return destination.

If current references outside the scope break because of the migration, return the path and the needed fix. Do not edit outside the scope on your own, and do not report overall completion.

<a id="実行と検証"></a>
## Execution and verification

At the start, check HEAD, the branch, uncommitted diffs, the Registry's current state and the relevant local procedures. If there are changes after the base, check their impact. Do not overwrite existing diffs.

- Run the target Debug / Release tests and the compiler success / expected-rejection checks. Also run the related Death Tests and record their counts.
- In an external client depending only on the product AcCollections, check the three entries (new name, old name, facade) and passing types when importing new and old together. Separate normal mode and 2025 compatibility mode. State the range of usable toolchains.
- Check the benchmark release build and the list of registered tasks, and confirm the old full titles are kept. Performance measurement itself is not needed this time.
- Generate DocC for the new and old targets and check the module entries, symbol links, compatibility guidance and diagnostics. Do not treat failures or non-runs as success.
- Keep the commands, toolchain, target version, counts, exit results and the scope not run. Do not substitute existing success records for this verification.

<a id="停止条件と対象外"></a>
## Stop conditions and out of scope

If a new specification decision, a failure of type identity, a need to change the public contract, or a required change outside the scope becomes clear, return with the partial output and grounds. Do not weaken checks to make them pass.
Do not edit the Registry, numbering, request files, the naming decision, AGENTS, Claude's area, or others' returns. Do not resume frozen tasks. No benchmark-name changes, performance tuning, SPI registration, remote CI runs, branch creation, commit, push or merge.

<a id="返却と受入"></a>
## Return and acceptance

Return destination: [implementation result](PERMUTATION_MODULE_MIGRATION_IMPLEMENTATION_RESULT.md). Fill in the list of changes, verification evidence, unconfirmed items and stop points, and remaining work, and state that the work has ended and the assigned scope is returned. Do not edit the management fields at the top.
Astra keeps the original answer and checks it independently. After accepting the local diff it waits for commit permission, and after user permission and confirming the save, this implementation task becomes DONE. Remote CI and reaching main are a separate later stage, and this task's DONE does not treat the whole migration as complete.
