# ElementBuffer系target・module名移行の実行

## TL;DR（人間向け）

ElementBuffer系の実装moduleを`ElementBufferModule`・`OptionalElementBufferModule`へ移し、旧名を再公開の互換targetとして残した実行task（ARRAY-016、DONE）の記録。build・test・trait有効時のtest・互換smoke・benchmarkのtitle維持・DocC生成の成功を確かめ、PR #195でmainへ固定した。旧名targetの削除は後続のARRAY-018で行った。

## Task

- ID: `ARRAY-016`
- Kind: `EXECUTION`
- State: `DONE`
- Owner: Codex
- Closeness to the current intermediate goal: `DIRECT`
- Prerequisite: `ARRAY-015`

<a id="確定済み方針"></a>
## Settled policy

- Move the implementation modules to `ElementBufferModule` and `OptionalElementBufferModule`.
- Keep `BareArrayModule` and `OptionalArrayModule` as thin compatibility targets that `@_exported import` the new modules.
- Rename the test targets and directories to match the public type system as well.
- `AcCollections` depends directly on the new modules and re-exports them directly.
- Keep the `ENABLE_OPTIONAL_ELEMENT_BUFFER` trait condition on the Optional side.
- Benchmarks change only imports; do not change task titles, workloads, baseline comparison or result normalization.
- Do not change the root package's library product structure or the end condition of the old compatibility targets.

<a id="実行範囲"></a>
## Scope of execution

1. Move the current implementation directories to `Sources/ElementBufferModule` and `Sources/OptionalElementBufferModule`.
2. Create old-name compatibility facades and DocC explaining compatibility in `Sources/_BareArrayModule` and `Sources/_OptionalArrayModule`.
3. Reflect the new and old targets, dependencies, paths, test targets and the trait condition in `Package.swift`.
4. Change the imports of `AcCollections`, tests and benchmarks to the new modules.
5. Move the test target directories to `Tests/ElementBufferModuleTests` and `Tests/OptionalElementBufferModuleTests`.
6. Update the DocC target matrix of the normal CI to the new module names.
7. Update module names and current source paths in the current user-facing canonical documents. Archived records are not renamed, as history.
8. Search again for remaining old-name references, and confirm there are no execution-related references other than the compatibility targets, history or intended explanations.

<a id="検証"></a>
## Verification

- Package build and tests with the trait disabled succeed.
- Package build and the target tests with `ENABLE_OPTIONAL_ELEMENT_BUFFER` enabled succeed.
- Both test targets that import the new modules directly succeed.
- A minimal compatibility test that imports only the old module name can use the new modules' public types.
- The benchmark package's release build succeeds, and the existing ElementBuffer-family task titles are unchanged.
- DocC generation of both new modules succeeds with warnings-as-errors.
- The search results and compiler diagnostics after the change show no unintended dependency on old modules.

<a id="停止条件"></a>
## Stop conditions

If it becomes necessary to change the public library products, the trait name or provision conditions, benchmark workloads or task titles, the performance baseline, or the end condition of the old compatibility targets,
do not decide it in this task; stop and separate it into another task.

<a id="実施結果2026-10-14"></a>
## Results (2026-10-14)

- Moved the implementation and test targets and directories to the settled new names, and added the 2 old-name targets as one-line re-export facades.
- Updated the imports of `AcCollections`, tests and benchmarks, the manifest dependencies, the DocC CI target matrix, and the source paths in current canonicals.
  At this stage the Archived records and the maintenance directory names were kept as history and management coordinates.
- Xcode Build for Testing and `swift test --disable-sandbox` succeeded.
- With the trait enabled, 36 normal Optional-family tests, 1 AcCollections re-export test and 21 Death Tests succeeded.
- Added a compatibility smoke test using the new modules' public types through the old-name facades to both test targets; it succeeded.
- The benchmark package's release build succeeded, and a dry run confirmed that the 22 existing ElementBuffer-family task titles are kept.
- DocC generation of the 4 new and old modules succeeded with `--warnings-as-errors`.

The old-name facades were fixed into main by PR #195 as an intermediate migration state. The final goal of the migration is, in `ARRAY-018`, to delete the 2 old-name targets
and leave only the new modules in the package and continuous CI.

In the later `ARRAY-018`, by the user's additional instruction, the maintenance directory was also unified to the new module names, and the management path references in current and Archived
documents were updated. Historical names and source paths of their time in the body text were not included in the replacement.
