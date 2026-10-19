# Sequenceによる失効View収集のバグ課題

## TL;DR（人間向け）

テスト専用SequenceからViewを配列へ集めると、後で読めなくなることを固定版で再現しました。調査は受入済みです。

通常公開型はSequence非準拠なので、製品全体のバグ確定や修正完了にはしません。実験アダプターの扱いはPERM-081へ引き継いでいます。

<!-- OPS-133: 2026-10-19 / Astra. Reading entry; does not replace canonical decisions/status. Review with conclusion/boundary changes. -->

Recorded 2026-10-16 by Astra. Task PERM-060.

<a id="ユーザー判断と現在の範囲"></a>
## User decision and current scope

The user directed 「これはバグなので、課題に復活」 and delegated reactivation method. Changed the frozen adoption question 「Sequence表面を製品候補として検討するか」 to ACTIVE DISCOVERY on reproduction, impact and repair requirements. [Task Registry](../ProgressV2/TASK_REGISTRY_V2.md) is canonical for status.

<a id="問題"></a>
## Problem

The [experiment](../Technical/NextPermutationsSequenceExperiment.md) passes tests-only RuntimeCheckedPermutationSequence to `Array(sequence)`; later next() and terminal nil invalidate Views, leaving collected elements unreadable. Producing unusable results with ordinary Sequence operations is the issue.

Adapter is in [tests](../../Tests/PermutationTests/NextPermutationsSequenceExperimentTests.swift). Current [normal public type](../../Sources/NextPermutationModule/NextPermutations.swift) and [borrowed public type](../../Sources/NextPermutationModule/BorrowedNextPermutations.swift) explicitly do not conform to Sequence. Do not claim the same operation is possible in the public product.

<a id="調査の到達点"></a>
## Investigation goals

- Reproduce valid sequential use versus collection invalidation with current toolchain/experimental code.
- Identify public API, adapter and example impact, including shared advancement/invalidation through iterator copies.
- Return required user behavior and repair scope with evidence.

Past successes are evidence, not this task's reruns. At this stage only reactivation/material/public-declaration checks occurred; no reproduction/fix yet.

<a id="判断と修正の境界"></a>
## Decision and repair boundaries

Do not decide product Sequence adoption, returned-value ownership or acceptable copy/performance cost here, or designate the entire temporary-View contract a bug. Separate new contract/product decisions from findings and return them to the user. Define approved repairs separately.

Accepted investigation is not a fixed bug. Record handoff of unresolved repair/decisions before closure.

<a id="経緯"></a>
## History

Preserved [frozen original](../Archived/PERM-060_BEFORE_REACTIVATION_2026-10-16.md). This explicit direction replaces old adoption/freeze conditions. Keep fixed ID, no renumbering.

<a id="現行再現受入2026-10-18--astra"></a>
## Current reproduction and acceptance (2026-10-18 / Astra)

Evidence revision `76a96cf7123d9dfbd63a1a652160802b27843dff`. Apple Swift 6.4 (swiftlang-6.4.0.34.1), arm64 macOS. `swift test -c debug --filter NextPermutationsSequenceExperiment` succeeded: 6 XCTest + 2 Swift Testing death tests, 8 total/0 failures. [Full log](../Evidence/PERM-060/2026-10-18-debug.log). Release/ASan/compatibility traits excluded; do not use existing timing-test numbers for performance judgment.

- Sequential consumption by `map(Array.init)` and in-loop copying passes. New iterators are independent; copied iterators advance shared state.
- Reading old View startIndex after `Array(sequence)` and reading an old View after next on an iterator copy both produced expected traps.
- `NextPermutations.next()` closes the generation before branching, including terminal nil. Adapter returns that View directly as Element; retained Views are invalid when collection finishes.
- Public NextPermutations/BorrowedNextPermutations explicitly do not conform to Sequence; adapter is private in tests. This reproduction alone does not establish needed normal-public-API repairs.
- `Compatibility/AtCoder2025/PermutationsAtCoder2025.swift` has another Sequence implementation. Tests are under `!COMPATIBLE_ATCODER_2025`; no compatibility safety/defect conclusions included.

Accepted investigation. Product/test code unchanged. Not fixed; hand adapter policy to [PERM-081](PERMUTATION_SEQUENCE_ADAPTER_DECISION.md). Later implementation scope follows that decision.

<a id="一時作業物"></a>
## Temporary artifacts:

`/tmp/astra-perm060-test.log` (realpath `/private/tmp/astra-perm060-test.log`), Astra, 2026-10-18, limited-test log. Saved to Evidence above; deletable. Retain ordinary .build as shared build cache.
