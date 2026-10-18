# ElementBuffer系target・module名移行の調査

## TL;DR（人間向け）

公開型を`ElementBuffer`・`OptionalElementBuffer`へ改名した後も残っていた旧target・module名について、新moduleへ移して旧名を薄い互換targetとして残す方式を調査した記録（ARRAY-015、DONE）。ユーザーの指定した方向と新module名に沿って、変更対象と影響範囲、benchmark・CIへの影響を確かめ、実際の移行は後続のARRAY-016へ渡した。

## Task

- ID: `ARRAY-015`
- Kind: `DISCOVERY`
- State: `DONE`
- Owner: Codex
- Closeness to the current intermediate goal: `NEAR`

<a id="背景"></a>
## Background

The public owned types have been renamed to `ElementBuffer` and `OptionalElementBuffer`, but `BareArrayModule` and `OptionalArrayModule` remain in SwiftPM targets, modules, source
directories, test targets and maintenance materials.
The old names are valid as coordinates pointing to the current modules, but the cognitive load of translating between the old product image and the current public types and provision categories
was observed in an actual task review.

Registering with the Swift Package Index externalizes per-module DocC pages and public routes. To avoid renaming modules after registration,
settle, before the 0.9.x registration, the execution boundary for migrating to new modules matching the public types and keeping the old module names as thin compatibility targets.

<a id="採用済み方向"></a>
## Adopted direction

On 2026-10-14 the user specified, like RedBlackTree's existing method, the direction of migrating to new modules while using the old module names to keep
compatibility. `Sources/_RedBlackTreeModule/RedBlackTreeModule.swift` has only
`@_exported import RedBlackTreeCollections`, and the old target in the manifest depends on the new target.
This thin compatibility-facade method is adopted as the direction for the ElementBuffer family too; keeping the current names permanently, or an incompatible rename that does not keep the old module names,
are removed from the comparison candidates.

In a following confirmation, the user also specified that the new implementation target and module names be `ElementBufferModule` and
`OptionalElementBufferModule`. The old names `BareArrayModule` and
`OptionalArrayModule` are kept, as with RedBlackTree, as thin compatibility targets that `@_exported import` the new modules. No time for deleting the compatibility targets
is set, and they are not deleted in this migration.

<a id="現在確認できる事実"></a>
## Facts confirmed now

- `Package.swift` uses `OptionalArrayModule`, `OptionalArrayModuleTests`, `BareArrayModule` and
  `BareArrayModuleTests` as target names.
- `AcCollections` depends on and re-exports `OptionalArrayModule` only with the `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait, and
  `BareArrayModule` in the normal configuration.
- Public type names, target names, module names and directory names do not currently match.
- RedBlackTree has a past record of migrating directories, target and test imports and an old-name re-export target in stages.
  That record is evidence of an option, not a ground for adopting the same method automatically.
- In the public type rename of 2026-10-13, HEAD's performance CI library was passed as is to the pre-rename baseline,
  which requested new task names not present in the baseline and gave `unknown tasks`. There is now compatibility processing that maps the old and new names of the library input
  and the result names.
- The past Prime Codex has no experience of executing an ElementBuffer-family target/module rename. The recovery procedure of the public type rename
  and RedBlackTree's migration history can be referred to, but they are not evidence demonstrating a working procedure for this time.
- A full search of old module-name references in execution found that the change targets are limited to the targets and dependencies in `Package.swift`,
  the re-export import in `Sources/AcCollections/AcCollections.swift`, the imports of both test groups, the imports of 2 benchmark sources,
  and the DocC target matrix in `.github/workflows/ci.yml`. The performance CI and the candidate
  workflow check that benchmark source files exist, but do not use module names as comparison contracts or task titles.
- The benchmark package depends only on the product `AcCollections`, and benchmark task titles keep the current names based on the public type names.
  Therefore this module rename does not change the library definitions for the pre-rename baseline or the result-name normalization.
- The only product the root package publishes is `AcCollections`. The old modules' compatibility targets keep direct imports within the repository and
  existing source compatibility, but a decision to create an independent library product is not included in this migration.

<a id="調査範囲"></a>
## Scope of investigation

1. Enumerate the targets, dependencies, trait conditions and test targets in `Package.swift`.
2. Check `import`s and module-name dependencies, with their configuration conditions, in production, tests, benchmarks, compiler fixtures, CI, DocC, maintenance documents and single-file outputs.
   For the performance CI, take `Current/PERFORMANCE_CI_CHANGE_GUIDE.md` as canonical, and separate the effects of a target/module rename on
   the full task titles in the benchmark source, the library definitions passed from HEAD to the baseline, the normalization of result names, and the harness builds of
   base and current respectively.
3. Separate the effects on direct imports that currently work in consumers outside the repository and on the `AcCollections` re-export route.
4. For the structure that migrates to the new names and keeps the old module names as thin compatibility targets, check source compatibility, SPI/DocC display,
   the amount of migration and the maintenance burden. Take RedBlackTree's current manifest, its one-line re-export source and its compatibility-module DocC as
   the minimal baseline, and extract the places where the ElementBuffer family needs additional conditions.
5. Check whether the `ElementBuffer` family and the `OptionalElementBuffer` family must be handled together, or should be separated because of their different provision categories.
6. If a judgment is needed, separate it into one `DECISION` candidate per judgment, and do not include migration implementation in this task.
7. When creating a rename execution candidate, check whether the performance CI's compatibility processing must be established before the rename.
   If the meaning of task titles or the measurement boundary changes, do not treat it as rename compatibility; separate it as a different workload or a baseline switch.

<a id="調査結論"></a>
## Conclusion of the investigation

- Move the implementation bodies to `Sources/ElementBufferModule` and `Sources/OptionalElementBufferModule`, and create
  targets and modules of the same names.
- The old-name targets are thin facades in `Sources/_BareArrayModule` and `Sources/_OptionalArrayModule` that depend on the new modules and
  `@_exported import` them. The old-name targets are not deleted without a separate explicit decision.
- The test target names and directory names are also moved, to match the public type system, to `ElementBufferModuleTests` and
  `OptionalElementBufferModuleTests`.
- `AcCollections` depends on and re-exports the new modules directly. The Optional side's trait condition and the
  name `ENABLE_OPTIONAL_ELEMENT_BUFFER` are kept.
- Only benchmark imports are changed to the new module names; existing task titles, workloads, baseline comparison and result normalization are not changed.
- The DocC target matrix is replaced with the new module names. The old compatibility modules' DocC is a minimal structure that only explains compatibility.
- The actual changes and verification of source, tests, manifest, CI and public documents are done in the following execution task.

<a id="このtaskで変更しないこと"></a>
## Not changed in this task

- Changing the trait name `ENABLE_OPTIONAL_ELEMENT_BUFFER`
- Returning ElementBuffer to the 1.0 provision targets
- Benchmark workload names, task titles, performance judgments, baselines
- The root package's library product structure

<a id="完了条件"></a>
## Completion conditions

- The surfaces and configuration conditions that depend on the current names are listed with reproducible grounds.
- For the performance CI, the current full task names, the full task names resolved in the pre-rename baseline, the full task names after result normalization,
  and the harness build boundaries of both generations have been checked.
- The effects of a rename with thin compatibility targets on the manifest, source, DocC, consumers and CI have been checked.
- Grounds for judging both modules together or separately are shown.
- The needed product decisions and the execution units after the decisions are separated without mixing.
- The scope that must be closed before Swift Package Index registration is stated explicitly.

<a id="後続"></a>
## Follow-up

In `ARRAY-016`, the rename above, the old-name compatibility facades, import updates, DocC target updates, and build/test/benchmark
verification are carried out as one mechanical migration. If compiler diagnostics find an unconfirmed module dependency, follow the diagnostics
within the same task, but if a change to public products, traits, workloads or the end condition of compatibility becomes necessary, stop and
separate it into a different decision.
