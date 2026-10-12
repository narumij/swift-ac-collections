# Borrowed Permutation Test as Specification Plan

## Task

- ID: `PERM-047`
- Type: `DISCOVERY`
- Owner: Claude
- Proximity to current intermediate goal: `DIRECT`

Current state, ownership, and restart conditions are controlled by the Task Registry.

## Objective

Inspect the seven disabled legacy test files under
`Tests/PermutationTests/NextPermutationsSequence/` and the compiler-backed experiments in
`Tests/PermutationTests/EtcTests.swift`, then produce a function-level ledger that can be used to
reconstruct Test as Specification for the Swift 6.4 borrowed `NextPermutations` contract.

The ledger must distinguish behavior that remains required from behavior that belonged only to the
retired `NextPermutationsSequence` value-semantic and Copy on Write contract.

## Authoritative inputs

- `Sources/PermutationModule/Documentation/Quality-Profile.md`
- The active runtime-checked implementation in `Sources/PermutationModule/NextPermutations.swift`
- The seven disabled files in `Tests/PermutationTests/NextPermutationsSequence/`
- Git history for the removed Swift 6.2 COW implementation, when implementation details are needed
- `Tests/PermutationTests/EtcTests.swift`, which is a persistent scratchpad whose individual checks
  must be inventoried rather than silently treated as finished specification tests
- The test-specific instructions in `Tests/CLAUDE.md`

Do not treat the disabled implementation or disabled tests as the current contract.

## Classification

Record every legacy test function exactly once using one of these outcomes:

- `KEEP_RUNTIME`: observable behavior remains valid and can be tested while the borrowed `Span` is live.
- `REPLACE_RUNTIME`: the underlying requirement remains, but the setup or assertion must change for the borrowed API.
- `REPLACE_COMPILE_PASS`: the property is best demonstrated by code that must compile.
- `REPLACE_COMPILE_FAIL`: the property is a forbidden ownership or lifetime use that must be rejected by the compiler.
- `REPLACE_LIFETIME`: the property concerns initialization, ownership, destruction, or deallocation.
- `RETIRED`: the property belongs only to the removed Sequence, persistent result, iterator-copy, COW, or result-Collection contract.

For each function, record the source file and function name, classification, reason, corresponding
new-contract requirement, and proposed destination test group. Do not write replacement test code in
this task.

Record every function in `EtcTests.swift` separately as an experimental check. For each one, state
what compiler or runtime fact it established, whether that fact belongs in a successor runtime,
compile-pass, compile-fail, or availability test, and whether the scratch check should remain after
that successor exists. Do not force these experiments into the legacy-test classifications above.

## Boundaries

- Do not modify production source, tests, package manifests, CI, or public documentation.
- Do not choose new public API, naming, compatibility policy, or guarantees absent from the Quality Profile.
- Do not remove the `#if false` blocks.
- If a legacy assertion exposes an ambiguity in the new public contract, record it under
  `Unresolved questions` and stop classification of only that assertion; do not resolve it.
- Do not infer runtime safety from compiler acceptance or compiler rejection from runtime behavior.

## Deliverable

Append these sections to this file:

1. `Function ledger`
2. `Proposed successor test groups`
3. `Unresolved questions`
4. `Validation performed`
5. `Handoff to Codex`

## Completion conditions

- Every legacy test function in all seven files appears exactly once in the ledger.
- Every test function in `EtcTests.swift` appears exactly once in the experimental-check ledger.
- Each proposed successor test group is bounded to runtime behavior, compile-pass, compile-fail, or ownership/destruction.
- Retired COW and persistent-value requirements are not silently carried into the borrowed contract.
- No product or test implementation file is changed.

## PERM-051 返却記録（2026-10-12 Claude）

`PERM-047`の棚卸しはEXCLUDEDのため、このtaskでは旧testの台帳を作らず、現行の
`Sources/PermutationModule/BorrowedNextPermutations.swift`の公開コメントを契約として直接testを書いた。
2026-10-12、ユーザーから「Test as Specをやったことは構わない、受け入れできるよう整えて」との指示を受け、
凍結中の残作業（compiler診断の証拠、互換modeの確認）だけを埋めた。

### 追加したruntime test（`Tests/PermutationTests/BorrowedNextPermutations/`、全25件）

| file | 件数 | 内容 |
|---|---|---|
| `_0_PublicSurfaceTests` | 2 | 入口と返り値の型（Array、Range、Slice、String）、`next()`が`Span<Element>?` |
| `_1_EnumerationTests` | 12 | 列挙順、開始位置、空・単一・全等値・降順、重複なし、終了後の`nil`継続、非Array入力、元を変更しない |
| `_2_SpanAccessTests` | 5 | 0始まりの添字（Slice、非Int Index）、`count`、空`Span`、次の`next()`前に読めること |
| `_4_CoexistenceTests` | 2 | runtime-check版と同じ並びを返す（通常版だけ）、swift-algorithmsと共存 |
| `_98_InternalTests` | 4 | 要素のコピー保持、途中破棄・完走後破棄で各要素を1回だけ解放、空iteratorの破棄 |

### 検証

- `swift test -c debug --filter PermutationTests.BorrowedNextPermutations`: 25件、0 failures。
- `swift test -c release --filter PermutationTests.BorrowedNextPermutations`: 25件、0 failures。
- 互換mode（一時copyで`COMPATIBLE_ATCODER_2025`を有効化して`swift build --build-tests`）: 当初は
  `_4`のruntime-check版比較testが、互換版の`nextPermutations()`を指してcompile errorになった。そのtestだけを
  `#if !COMPATIBLE_ATCODER_2025`で囲み、借用版の5 fileは互換modeでもcompileできることを確認した。
  互換modeには、このtaskと無関係な既存のcompile error 3件が`Tests/PermutationTests/EtcTests.swift`（29行、48行、58行。
  実験用で保全対象）に残っている。

### 借用寿命のcompiler診断（一時client、Swift 6.4、`swift build`）

| 種別 | コード | 結果 |
|---|---|---|
| PASS | `while let s = it.next() { n += s[0] }` | build成功 |
| FAIL | `let a = it.next()!; _ = it.next(); a[0]`（次の`next()`後に使う） | `lifetime-dependent value escapes its scope` |
| FAIL | 関数から`Span<Int>`を返す（iteratorの寿命を越える） | `a function cannot return a ~Escapable result` |
| FAIL | `Span`が生きている間に`consume it` | `missing reinitialization ... after consume while accessing memory`ほか |
| FAIL | `var b = it`の後に`it`を使う（copy） | `'it' is borrowed and cannot be consumed` |
| FAIL | `for p in [1,2].borrowedNextPermutations()` | `for-in loop requires ... to conform to 'Sequence'` |
| FAIL | `[Span<Int>]`へ保存 | `type 'Span<Int>' does not conform to protocol 'Escapable'` |

test内でも、`_98`で`Span`が生きている間の`consume iterator`が`overlapping accesses`として拒否されたため、
`Span`のscopeを閉じてから破棄する形にしている。compile-failはXCTestで表せないため、repositoryには
test化していない（compile-fail testの仕組みはない）。この表が証拠であり、再現は上のコードを一時packageで
buildすれば足りる。

### 未確認・範囲外

- Swift 6.4未満で公開面が存在しないことは確認していない（test自身も`#if compiler(>=6.4)`の中にある）。
- `Sources/PermutationModule/Documentation/Quality-Profile.md`への反映は行っていない（Codex担当）。
