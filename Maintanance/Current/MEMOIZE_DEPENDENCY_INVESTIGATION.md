# Memoize関連リポジトリの依存状況調査

## TL;DR（人間向け）

指定されたMemoize系2リポジトリのローカル依存を調べ、LRU wrapperの限定型チェックまで受入・完了した記録。非公開化・削除検討はユーザー整理で除外した。外部package全体・macro・実行安全性・性能を検証済みとはせず、APIも変更していない。

2026-10-16, recorded by Astra. RBT-005.

<a id="目的と現在の扱い"></a>
## Purpose and current treatment

DISCOVERY on dependencies of user-designated local checkouts `swift-ac-memoize` and `Memoization` on this repository. User instruction changed it to ACTIVE, owner Codex. [Task Registry](../ProgressV2/TASK_REGISTRY_V2.md) is canonical for state. Astra performed/accepted the investigation below on 2026-10-16; user commit instruction that day makes it DONE.

The user explained dependency investigation was the original need. It had been frozen because getting AI to take the investigation seemed unlikely and progress became burdensome. Treating it as waiting for user policy was mistaken.

<a id="調査後のユーザー判断2026-10-16"></a>
## Post-investigation user decision (2026-10-16)

User decided 「非公開化や削除検討というタスク自体を整理でいい」. Remove Memoize privatization/deletion consideration from remaining work as `EXCLUDED` by organization, not successful execution/API deletion. Current API unchanged; do not retain consumer migration/public-surface reduction as mandatory follow-up/gates.

Registry RBT-005 already describes dependency investigation: retain accepted findings/evidence as completed investigation (same-day commit instruction, DONE). No new ID solely for privatization/deletion consideration. Impact discussion below is knowledge, not an execution plan.

<a id="調べる範囲と返すもの"></a>
## Investigation scope and outputs

- Inspect `/Users/narumij/Documents/GitHub/swift-ac-memoize/` and `/Users/narumij/Documents/GitHub/Memoization/`. Record remote/branch/commit/uncommitted diff; distinguish local/public. Correct earlier `Memoize` target-name mistake.
- From declarations/actual code, identify dependent products/modules/APIs.
- Explain affected usage/migration needs if Memoize-related portions change/disappear, with evidence. Run narrowly scoped compilation if needed; separate checked/unchecked.
- Return dependencies, usage, impacts and unknowns for both repos; then concrete decisions/work can follow.

<a id="境界"></a>
## Boundaries

Do not make old 「外部consumer 2件の移行」 a prerequisite to investigation: migration need is itself being investigated. Do not presume migrated or necessarily needing migration.

Do not force a 「公開終了／正式API化」 binary conclusion. No external-repository edits, product-policy decisions, API removal/publication changes.

<a id="資料"></a>
## Materials

- [Existing audit](EXTERNAL_TYPE_EXTENSION_AUDIT.md)
- [Record before treatment as user decision](../Archived/RBT-005_BEFORE_USER_DECISION_2026-10-16.md)
- [Record before this correction](../Archived/RBT-005_BEFORE_DEPENDENCY_DISCOVERY_2026-10-16.md)

<a id="調査結果2026-10-16--astra"></a>
## Investigation results (2026-10-16 / Astra)

Basis: swift-ac-collections `ff209700` (develop/misc/68). Noticed unrelated changes in CLAUDE_PENDING_TASKS.md and Testing/JudgmentCoordinates/README.md during investigation; did not edit them. External repos read-only: no resolve/fetch/build/edit. Findings concern specified local checkouts, not latest public state.

<a id="結論"></a>
### Conclusions

- Both declare AcCollections and import RedBlackTreeModule. Lack of internal use alone does not justify privatizing/deleting current public LRU API.
- Blanket 「外部consumer 2件の移行完了」 wait is inaccurate: separate current-LRU paths from experimental/macro paths referencing already-removed APIs.
- Retaining current `___LRUMemoizeStorage` requires no type replacement for inspected wrappers. Limited type-checks pass with new/old module names; not whole-package operation assurance.
- Removing/privatizing LRU requires at least wrapper migration below. Sources/Tests searches in these two consumers found no direct _LinkingPair usage, but public typealias/protocol/@inlinable chains require separate compilation to assess internal surface reduction.

<a id="対象版と未commit差分"></a>
### Target revisions and pending changes

| Target | Local HEAD | Declaration / Package.resolved | Working tree |
| --- | --- | --- | --- |
| swift-ac-memoize | main / e671245070bd962490bcd33a6f78621ce1331807 | compatible/AtCoder/2025 / 0fb609e336a2ed2218294490e37f5141f4b57af2 | 9 changed files, including Cache V2/Array/macro/tests |
| Memoization | main / 48dcd32d55565ac0a52f107e2dfe10a541048d05 | from 0.1.30 / 0.4.1（174e304acbdd6848604a62e70169b26ac982d775） | 8 changed files including MemoizeCache/Pack additions and macros |

Remotes: https://github.com/narumij/swift-ac-memoize.git and https://github.com/narumij/Memoization.git . Match to published HEAD unverified.

swift-ac-memoize `.build/checkouts/swift-ac-collections` is `730d3433b47219244ef69e130970cb80f68a94a2`, unlike Package.resolved. Its internal LRU with old _KeyCustomProtocol constraints differs from current/pinned public Comparable version. Existing build output is not current resolution evidence. Memoization has no corresponding checkout; Package.swift local-path declaration is commented out, not active.

<a id="実利用と変更影響"></a>
### Actual usage and impact

| Path | Evidence relative to consumer root | Dependency/treatment |
| --- | --- | --- |
| swift-ac-memoize public LRU | Sources/swift-ac-memoize/MemoizeCache.swift:121, swift_ac_memoize.swift:1 | Exists in HEAD. MemoizeCache.LRU holds ___LRUMemoizeStorage and uses init(maxCount:), subscript get/set, removeAll(keepingCapacity:), maxCount, count; reexports module |
| Pending V2 | Same MemoizeCache.swift:250 | Uncommitted ~Copyable wrapper uses same LRU; Standard uses Swift Dictionary. InlineMemoizeMacro.swift emits LRU/Standard wrappers |
| Memoization new LRU/Actor | Sources/Memoize/MemoizeCache.swift:75/188, Memoize.swift:4 | New file absent from HEAD, staged+unstaged. ___MemoizeCache.LRU/LRUActor use same current LRU API; Standard/StandardActor use Dictionary |
| Memoization old experimental target | Sources/MemoizeCache/MemoizeCache.swift, tarai/V1〜V6.swift, Tests/MemoizeCacheTests/MemoizeCacheTests.swift | _MemoizeCacheBase/_MemoizeCacheLRU/_KeyCustomProtocol/_ComparableMemoizationCacheProtocol/_HashableMemoizationCacheProtocol remain in active declarations/#if true paths, not only comments |
| Memoization macro generation | Sources/MemoizeMacros/Common.swift:81〜157/367, StoredMemoizeMacro.swift, MemoizeMacro.swift | storedCache still emits old protocols; adding new wrappers does not complete old-macro migration |

Pack.swift old Base/LRU/CoW aliases active in HEAD but commented in working tree; V7 is #if false in working tree. Did not uniformly count these as current active use. Package.swift retains Memoization's MemoizeCache target/tests.

Git search of current Sources and pinned 0.4.1 found no old _MemoizeCacheBase etc definitions; ___LRUMemoizeStorage is public in both pinned dependencies/current. Do not attribute old experimental inconsistencies to a newly introduced current-version breaking change.

<a id="コンパイラによる限定確認"></a>
### Limited compiler check

Saved inputs/diagnostics in [evidence and rerun guide](Evidence/MemoizeDependency20261016/README.md). Extracted pending Pack+Cache implementations from both consumers and type-checked against current module: four new/old-name combinations passed. Old _MemoizeCacheBase probe failed with missing type (「型が見つからない」).

Checks cover wrapper type/call surface only. No whole-consumer resolution, macro expansion, Swift 6.2 behavior, LRU clear/capacity/copy/actor runtime safety or performance validation. Close investigation here without independently repairing external working trees.

<a id="後続へ渡すもの"></a>
### Handoff

1. If current LRU API unchanged, this investigation alone does not require external migration.
2. Before public-LRU API changes, decide wrapper migration/compatibility. Separate compile checks of public aliases/inlinable for internal-only reduction.
3. Restoring Memoization operation requires user decision on keeping old experimental target/macro paths, as separate external-repo work; no organization/deletion here.
4. Sources/RedBlackTreeCollections/Documentation/MEMO.md statement 「swift-ac-memoizeはdrop」 is positioning, not proof source dependencies vanished. Do not infer revival/service policy.

Acceptance criteria for dependencies/usage/impact/unknowns met; RBT-005 accepted and DONE by same-day user commit instruction. Not completed migration/public-contract change.
