# NextPermutations実装探索レポート

## TL;DR（人間向け）

`NextPermutations`の通常実装を選ぶまでに調べた候補・反証・暫定性能値の記録。`~Copyable struct`とiteratorごとの共有門番（世代番号でViewを失効させる）を通常経路に選び、Swift 6.4の借用`Span`版は特殊経路として分けた。性能値は探索用の暫定値で、正式な性能評価や品質の受入判定ではない。末尾の残作業は探索時点の記録で、現在の状態はRegistryと現行品質評価で確かめる。

<a id="目的"></a>
## Purpose

This document records the candidates, counterexamples and provisional performance values examined before choosing the normal implementation of `NextPermutations`.
It does not replace a formal quality conformance judgment or Test as Specification. The search results are saved so that the same candidates are not re-proposed without grounds and the reasons for adoption
do not have to be reconstructed from conversations.

<a id="結論"></a>
## Conclusion

Among the candidates explored so far, the following structure is the normal path.

- `NextPermutations` is a `~Copyable struct` that owns the element buffer.
- `next()` returns a `Permutation` View that reads the current buffer.
- Each iterator has one `GateKeeper`, shared by all Views.
- `next()` and destruction of the iterator advance the gatekeeper's generation, and old Views are invalidated by precondition.
- No conformance to Swift 6.2's `IteratorProtocol`; the outside iterates with `while let`.

The implementation using Swift 6.4's Lifetimes and `Span`, a special path that examined whether the View can be omitted and what performance is reachable,
is provided as `borrowedNextPermutations()` in `Sources/PermutationModule/BorrowedNextPermutations.swift`,
separated from the normal path with runtime checks.

This is not a proof of absolute optimality. It is the conclusion that, among the candidates below, this best balanced ownership, Swift 6.2 compatibility, invalidation checks and
performance.

<a id="探索した候補"></a>
## Candidates explored

<a id="借用span"></a>
### Borrowed `Span`

In Swift 6.4, an implementation returning a borrowed `Span` from `next()` works and was the fastest among this time's candidates. `Span` itself is
`Iterable`, so `for-in` can be used to traverse the elements after it is returned.

On the other hand, in Swift 6.2, declaring a `~Escapable` result returned from a `mutating` method needs the experimental Lifetimes
feature. The purpose of examining `Span` was to omit a custom View; after it turned out that the normal path needs a View, the benefit of adding
Span alongside is small. So it is kept as a special path, not the normal path.

<a id="viewごとに門番を生成"></a>
### Creating a gatekeeper per View

An implementation that returns a Swift 6.2-compatible `Permutation` View and closes the previous gatekeeper at the next `next()` succeeded in type checking, enumeration and
invalidation checks. However, it creates a `ManagedBuffer`-made gatekeeper for every permutation returned, so in the condition of choosing 7 out of 28 elements
about 1.18 million allocations occurred.

The provisional averages over 3 cycles were 49.26ms for 28 elements and 144.80ms for 32 elements. C++ in the same measurement was 19.22ms and
61.33ms, so it is slow as a normal path.

<a id="共有門番と世代番号"></a>
### Shared gatekeeper and generation number

Changed to a structure that creates only one gatekeeper per iterator, with each View holding the generation number at issue. `next()` or
iterator destruction advances the gatekeeper's generation, and if it does not match the View's generation, it stops by precondition before touching the buffer.

This removed the per-permutation allocation while keeping the following two.

- An old View stops after advancing to the next `next()`.
- A View remaining after the iterator is destroyed also stops.

Initially, making the generation-update method `@inlinable` crashed Swift 6.4 Release compiler's `CopyPropagation` with an ownership
error. Separating the generation update into `@usableFromInline @inline(never)` and updating the header pointer directly
built in both Debug and Release. This workaround is due to a compiler optimization constraint, not product behaviour.

<a id="クラスによるiteratorprotocolsequence適合"></a>
### `IteratorProtocol` / `Sequence` conformance with a class

Swift 6.2's `IteratorProtocol` inherits `Copyable`, so a `~Copyable NextPermutations` cannot conform as is.
The actual Swift 6.2 compiler rejected it with the following diagnostic.

```text
type 'NextPermutations<Value>' does not conform to protocol 'Copyable'
```

Making `NextPermutations` a `final class` let the same type conform to `IteratorProtocol` and `Sequence` and be used with `for-in`.
Swift 6.2 typecheck, Release build, enumeration and the View invalidation test also held.

However, the provisional averages over 5 cycles were 30.50ms for 28 elements and 90.56ms for 32 elements, about 1.41× and about 1.36× slower
than the `~Copyable struct` version. Also, it becomes a contract in which assigned references share the same iteration state. The benefit of changing
the ownership contract and performance just for `for-in` is small, so it was not adopted.

<a id="暫定性能比較"></a>
## Provisional performance comparison

Environment: macOS, Swift 6.4, Release. The input is an ascending binary sequence of `size - 7` `0`s followed by 7 `1`s; enumerate the non-duplicate
lexicographic successors to the end and compute a position-weighted checksum. Input preparation is outside the measurement; the input copy, enumeration and
checksum are inside.

| Implementation | 28 elements | 32 elements | Note |
| --- | ---: | ---: | --- |
| Borrowed Span special path | 16.01ms | 51.37ms | 5 cycles |
| `std::next_permutation` | 19.24ms | 61.24ms | 5 cycles |
| `~Copyable struct` + shared gatekeeper | 21.61ms | 66.39ms | 5 cycles |
| `final class` + shared gatekeeper | 30.50ms | 90.56ms | 5 cycles, separate run |
| `~Copyable struct` + gatekeeper per View | 49.26ms | 144.80ms | 3 cycles, separate run |

The normal `~Copyable struct` version was about 1.12× for 28 elements and about 1.08× for 32 elements relative to C++ in the same 5-cycle run.
The measured values are for implementation exploration, not a formal external performance assessment or a quality acceptance judgment.

Measurement example:

```console
cd Benchmarks
swift run --disable-sandbox -c release benchmark run \
  --filter '^(Permutations binary selection checksum|Borrowed Span iterator binary selection checksum|std::next_permutation binary selection checksum)$' \
  --sizes 8 12 16 20 24 28 32 \
  --cycles 5 \
  --mode replace-all \
  /tmp/permutation-runtime-view-5cycles.json
```

<a id="成立確認"></a>
## Confirmations

- Typechecked the normal source with the Swift 6.2 toolchain, Swift 6 language mode and strict memory safety.
- Confirmed by a Swift 6.2 run that `[0, 0, 1]`, which contains duplicate elements, returns 3 permutations.
- Built `PermutationModule` in Swift 6.4 Debug / Release.
- Confirmed that an old View after the next `next()` and a View after the owner is destroyed stop by precondition.
- Placed provisional tests of normal enumeration and the invalidation conditions above in `PermutationTests/EtcTests.swift`.

<a id="探索時点で残っていた作業"></a>
## Work remaining at the time of the exploration

The following is the record at the time of the exploration and is not used as a current list of unfinished items or unfreezing conditions. For the current state see the [Task Registry](../ProgressV2/TASK_REGISTRY_V2.md), and for verification results the [current quality assessment](../Quality/0.6.0-1/PermutationModule/CurrentQualityAssessment.md). The technical candidates and search results are kept in this document.

- Take inventory of the old Test as Specification against the new temporary-View contract.
- Classify the provisional tests into normal tests, Death Tests and ownership/destruction tests.
- Review public type names, doc comments and the usage contract of temporary Views.
- Re-evaluate, from the package's overall conditions, whether a version-specific manifest for Swift 6.2 is needed.
- A formal external performance assessment and acceptance judgment are done separately if the frozen performance task is resumed.
