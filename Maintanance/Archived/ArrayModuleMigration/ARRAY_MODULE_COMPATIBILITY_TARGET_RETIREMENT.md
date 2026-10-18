# ElementBuffer系旧名互換targetの削除

## TL;DR（人間向け）

ElementBuffer系の旧名facade target（`BareArrayModule`・`OptionalArrayModule`）を削除し、新moduleだけをpackageと継続CIに残した実行task（ARRAY-018、DONE）の記録。ローカル検証とPR #196の全job成功を確かめ、Claudeの独立目視検査の指摘と、ユーザー指示によるmaintenance folder・監査文書名の統一も反映した。本文中の歴史上の型名・target名・当時のsource pathは変えていない。

## Task

- ID: `ARRAY-018`
- Kind: `EXECUTION`
- State: `DONE`
- Owner: Codex
- Closeness to the current intermediate goal: `DIRECT`
- Prerequisite: `ARRAY-016`

<a id="ゴール"></a>
## Goal

As the final state of the ElementBuffer-family module-name migration, delete the old-name facade targets `BareArrayModule` and `OptionalArrayModule`,
and leave only `ElementBufferModule` and `OptionalElementBufferModule` in the package and continuous CI.

<a id="確認した境界"></a>
## Confirmed boundaries

- The only library product the root package publishes is `AcCollections`; no library product directly contains the old-name facades.
- `AcCollections` re-exports the new modules directly and does not depend on the public declarations of the old-name facades.
- Production source and benchmarks import the new modules directly.
- Execution-related dependencies on the old-name facades are limited to `AcCollections` and test target dependencies in the manifest, the compatibility smoke tests, and the DocC CI entries.
- Initially the maintenance folder names were excluded from renaming as history and management coordinates, but to avoid the burden and misreading of continuing to remember their correspondence with the current module names,
  the current canonical folders are also unified to the new module names by the user's additional instruction.
- Compatibility for benchmark task-name renames is independent of deleting module targets and is not deleted.

<a id="実行範囲"></a>
## Scope of execution

1. Delete the 2 old-name targets and the internal dependencies on them from `Package.swift`.
2. Delete the facade sources and DocC of `Sources/_BareArrayModule` and `Sources/_OptionalArrayModule`.
3. Delete the compatibility smoke tests that import only the old names.
4. Delete the 2 old-name targets from the PR DocC matrix and return it to the 5-target structure including the new modules.
5. Reflect the structure after the end of the old-name facades in the current migration canonical and the CI plan.
6. Do not stop at deleting the old-name facades' DocC entries; place DocC entries with the new module names in the respective targets.
7. Move the 2 old-name maintenance folders to folders with the new module names, and unify all management path references, including current and Archived, to the new
   coordinates. Historical type names, target names and source paths in the body text are not changed.

<a id="検証"></a>
## Verification

- Manifest evaluation and the default package tests succeed.
- The target tests with `ENABLE_OPTIONAL_ELEMENT_BUFFER` enabled succeed.
- The benchmark package's release build and the CI library's task resolution succeed.
- DocC generation of `ElementBufferModule` and `OptionalElementBufferModule` succeeds.
- The generated DocC of both new modules contains module landing pages with the new module names.
- No old maintenance folders or management path references pointing to them remain.
- No dependency on or import of the old-name targets remains in execution.
- All jobs, including performance, complete in the remote PR CI.

<a id="停止条件"></a>
## Stop conditions

If a library product directly providing the old-name targets or a consumer outside the repository is confirmed and a new
product decision on when compatibility ends becomes necessary, do not proceed with the deletion; separate it into a decision task.

<a id="ローカル検証2026-10-14"></a>
## Local verification (2026-10-14)

- YAML parsing and `swift package --disable-sandbox dump-package` succeeded.
- `swift test --disable-sandbox` succeeded.
- With `ENABLE_OPTIONAL_ELEMENT_BUFFER` enabled, 35 normal Optional-family tests and 21 Death Tests succeeded.
- The benchmark package's release build succeeded.
- DocC generation of `ElementBufferModule` and `OptionalElementBufferModule` succeeded with `--warnings-as-errors`.
- A search confirmed that no old-name target definitions, dependencies, imports or DocC matrix entries remain in execution.
- Claude's independent visual inspection found old-name imports remaining in 2 compiler fixtures under `Utilities` and an outdated
  compatibility-test description in `Tests/TESTING.md`. Both were fixed, and the fixture's 1 compile-pass and the expected
  4 escape diagnostics were re-confirmed by script. Codex accepted the visual inspection.
- In PR #196 CI run `38465709778` for commit `7377b76d`, all 10 jobs including performance succeeded.
  The DocC matrix completed with 5 targets excluding the 2 old-name targets, and the remote structure after the end of the old-name facades was accepted.
- After recording completion, a gap was found: only the old-name facades' DocC landing pages had been deleted, without placing corresponding landing pages on the new module side.
  `ElementBufferModule.docc/ElementBufferModule.md` and
  `OptionalElementBufferModule.docc/OptionalElementBufferModule.md` were added, and both targets were
  generated with `--warnings-as-errors` successfully. The generated JSON also confirmed that the overviews with the new module names and the symbol links to the 4 public types
  were adopted.
- Claude's second independent visual inspection found a MUST-FIX: the Bare user-facing draft still had an import route from the deleted module.
  Fixed the module names in both drafts, the Optional trait boundary in the `AcCollections` DocC, the guidance in the ElementBuffer landing page,
  and the current and historical paths and Optional's DocC CI description in both audits. Regenerated the DocC of `AcCollections` and `ElementBufferModule`
  with `--warnings-as-errors` successfully, and the finding was accepted. Expanding public comments, the language of public media, and
  release-oriented migration explanations were separated as later documentation work.
- By the user's additional instruction, the maintenance folder names, which had been an exception kept in memory, were also moved to
  `ElementBufferModule` / `OptionalElementBufferModule`. 8 documents were moved, and 241 management paths, including current and Archived,
  were replaced with the new coordinates. Historical type names, target names and source paths of their time were kept as historical facts.
- By a following user instruction, the audit document names were also unified to `ElementBufferAudit.md` / `OptionalElementBufferAudit.md`, and all references
  were replaced with the new file names. Stable task IDs and historical names in the body text were not changed.
- Claude's independent check for missed replacements was `accept`: confirmed that the 8 new paths and 246 references exist and are consistent, that live references to the old management coordinates are 0,
  and that historical source paths and stable task IDs are kept. The current Quality Profile guidance in 2 Archived quality assessments that were pointed out
  was fixed. Management path expressions inside past Returns were also unified, following the user's purpose of not leaving old coordinates in current documents and reducing the memory burden,
  into wording that shows the judgment at the time of inspection; the original text before the change is kept in the Git history.
