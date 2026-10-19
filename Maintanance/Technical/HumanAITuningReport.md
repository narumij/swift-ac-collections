# 人間とAIによる実提出チューニング報告

## TL;DR（人間向け）

Swift 6.2向け`NextPermutations`の実験実装を実際の組合せ列挙問題に組み込み、人間とAIが機械語・Time Profiler・ローカル測定・AtCoder実提出を往復して、実提出を203ms（調査基準150ms）から最速80msまで縮めた探索報告。主な差は順列更新ではなく、C++版との移植条件（DSUの確保の繰り返し、重複した探索、再帰のleader探索）だった。正式な性能評価や製品版の採用判断ではなく、80msの枝は安全性を外した上限値として保存しているだけで、製品版Permutationは変えていない。

<a id="目的"></a>
## Purpose

This document records the process in which the Swift 6.2 experimental implementation of `NextPermutations` was built into an actual combination-enumeration problem, and a human and an AI went back and forth between
hypotheses, machine code, Time Profiler, local repeated measurement and real AtCoder submissions to break down the performance gap.

It is not a formal external performance assessment, a decision to adopt it in the product, a proposal of a public DSU API, or a safety evaluation. It is an exploration report
so that the findings obtained in conversation are not lost, and so that results are not later attributed to the wrong cause by looking only at the results.

<a id="結論"></a>
## Conclusion

Real submissions were shortened from Swift 203ms before the investigation and about 150ms for the experimental version under investigation, to a fastest 80ms.
The C++ real submissions reported for the same problem were Clang 67ms and GCC 83ms; the fastest Swift experimental version was about the same as GCC.

The main gap was not in `NextPermutations`'s permutation update itself. The following asymmetries remained in the porting conditions from the C++ version.

- The Swift version allocated and freed the DSU storage for each candidate, while the C++ version allocated once and only reset the contents.
- The Swift version called `merge` after `same`, duplicating the leader search for the same edge, while the C++ version did the cycle check and the union
  in one `unite`.
- The Swift version's leader search was recursive, but for this workload an iterative implementation was faster.
- The checking cost of the safe `Permutation` subscript showed up more strongly on AtCoder's Linux x86_64 than on macOS ARM64.

This result does not show that the DSU's pointer storage or `NextPermutations`'s algorithm is inherently slow.
The first big mistake was attributing the end-to-end value alone to the permutation API without aligning the structures being compared.

<a id="比較条件"></a>
## Comparison conditions

<a id="実提出"></a>
### Real submissions

The target problem enumerates 1,184,040 candidates choosing 7 elements from binary selection states of up to 28 elements, and judges each candidate with a DSU.
Submission values are single judge observations and include runner fluctuation.

<a id="ローカル測定"></a>
### Local measurement

Used Swift 6.2 Release builds on macOS 27.0.1, Apple Silicon. To make differences easier to see, profiling and
repeated measurement used a fixed input of 36 edges. This is not AtCoder's constrained input but a load for observing the processing structure.

Therefore the ranking on local ARM64 was used to generate hypotheses, and adoption for Linux x86_64 was confirmed by real submissions.

<a id="性能の推移"></a>
## Performance history

<a id="atcoder実提出"></a>
### Real AtCoder submissions

| Configuration | Run time | Handling |
| --- | ---: | --- |
| Old Swift-compatible version | 203ms | past baseline |
| Initial version pasting the new source | 162ms | past observation |
| Early runtime-check View experiment | 158ms | reference |
| Adjusting inline attributes | 153ms | small improvement |
| `@inlinable`-centred version | 150ms | investigation baseline |
| Removing GateKeeper ownership from the View | 150ms | no effect; not a product candidate because it loses safety |
| DSU reuse + single `unite` | 101ms | fixed the porting conditions relative to C++ |
| Iterative leader | 88ms | the adopted experimental branch |
| Edge scan turned into `while` | 93ms | improvement not reproduced; rejected |
| Getting the selection state directly from a pointer | 80ms | fastest; isolating the cause by lowering safety |
| Edge array also turned into an unsafe buffer | 81ms | improvement not reproduced; rejected |

The C++ real submissions were Clang 67ms and GCC 83ms. The difference between 80ms and 83ms may be smaller than the fluctuation of single measurements,
and is not used for a claim that Swift is generally faster than GCC. On the other hand, it was confirmed that the Swift experimental version can reach about the same as GCC
for this workload.

<a id="macos-arm64反復測定"></a>
### macOS ARM64 repeated measurement

The medians of 7 runs each with the same 36-edge input were as follows.

| Configuration | Median |
| --- | ---: |
| Initial baseline | 0.82s |
| DSU storage reuse | 0.64s |
| Up to single `unite` | 0.54s |
| Iterative leader | 0.48s |
| `for` changed to `while` | 0.46s |
| Getting the selection state directly from a pointer | 0.46s |
| Edge array also turned into an unsafe buffer | 0.45s |

`while` and the unsafe edge buffer, which improved slightly locally, did not reproduce the improvement in real submissions. This became the reason not to adopt branches for x86_64
on ARM64 results alone.

<a id="time-profilerによる分解"></a>
## Breakdown with Time Profiler

Time Profiler was captured with 1ms sampling. The numbers are sample totals of self time, not an exact wall-clock breakdown.

| Generation | CPU sample total |
| --- | ---: |
| Initial baseline | 814ms |
| DSU reuse + single `unite` | 556ms |
| Iterative leader | 494ms |
| Getting the selection state directly from a pointer | 488ms |

In the initial baseline, DSU search and union took about 284ms, and region management such as malloc/free about 141ms. After DSU reuse and
single `unite`, per-candidate allocation almost disappeared, and DSU processing also fell to about 174ms. With the iterative leader,
`DSU._leader` fell from 112ms to 78ms.

Getting the selection state directly from a pointer removed the 72ms observed as `Permutation.subscript`.
However, the ARM64 sample total only changed from 494ms to 488ms, while on AtCoder x86_64 it shortened from 88ms to 80ms.
This was a real example of the same source-level boundary showing different costs depending on architecture and optimizer.

<a id="探索した枝"></a>
## Branches explored

<a id="inline指定"></a>
### Inline attributes

When moving into a single file for submission, the inline information present in the library version had been dropped. In the machine code, the hot loop called
`NextPermutations.next()`, and retain/release accompanying the View return also remained. Adding `@inlinable` and
`@inline(__always)` together to `next()` removed the function call, but the difference in real submissions stayed at a few ms.

The lack of inlining was real, but was not the main cause of the 150ms level.

<a id="gatekeeper所有"></a>
### GateKeeper ownership

An experiment completely removed the GateKeeper and generation from the View and returned only a pointer and count. The real submission stayed at 150ms,
so the View's ownership ARC was not the dominant term. This version cannot detect using a View after the owner is destroyed or after the next `next()`, and
cannot be adopted for the formal implementation.

### `element(at:)`

Instead of the safe subscript, added `element(at:)` with the same bounds precondition. The ARM64 median stayed
0.82s, and the compiler merged it into effectively the same implementation. Changing only the API name or the method boundary did not remove the checking cost.

<a id="dsu-storage再利用"></a>
### DSU storage reuse

As in the C++ version, the DSU was created only once outside the candidate enumeration, and for each candidate all elements were updated to `-1`. The ARM64 median
shortened from 0.82s to 0.64s. Time Profiler also confirmed that the malloc/free group disappeared.

<a id="単一unite"></a>
### Single `unite`

Instead of calling `same` and `merge` separately, they were merged into a `unite` that finds each leader once and does the cycle check and union.
The ARM64 median shortened from 0.64s to 0.54s, and the real submission from 150ms to 101ms. Before suspecting the permutation implementation, the processing structure
needed to be aligned with C++.

<a id="反復leader"></a>
### Iterative leader

Changed the recursive path compression into an iterative implementation. The version that compresses the parent to the grandparent while advancing the scan position to the parent was fastest at 0.48s.
A version closer to the C++ expression, also jumping the scan position to the grandparent, was 0.51s and was rejected. The real submission shortened from 101ms to 88ms.

<a id="range-iterator除去"></a>
### Removing the Range iterator

In Time Profiler there were 48ms of samples from `for i in 0..<M` to `Range.formIndex(after:)`, `IndexingIterator.next()` and
`Collection._failEarlyRangeCheck`. A manual `while` shortened ARM64 from 0.48s to 0.46s, but
the real submission went from 88ms to 93ms. It was rejected because it does not support an improvement on x86_64.

<a id="選択状態のpointer直接取得"></a>
### Getting the selection state directly from a pointer

Changed `selected[i]` to `selected.elements[i]` as an experiment within the same file. On ARM64 it was a small difference from 0.48s to 0.46s, but
in real submissions it shortened from 88ms to 80ms. It is the result of bypassing the safe Collection contract and is not a proposal to adopt as is
in the public API. It is treated as a counterexample and upper bound confirming that the safety check has a performance difference.

<a id="辺配列のunsafe-buffer化"></a>
### Edge array as an unsafe buffer

Placed `edges` in a `withUnsafeBufferPointer` scope and obtained elements from `baseAddress[i]`. On ARM64 it shortened from 0.46s to 0.45s,
but the real submission went from 80ms to 81ms. Because the improvement did not reproduce, it was returned to the ordinary `edges[i]`.

<a id="協業の進め方"></a>
## How the collaboration proceeded

What worked this time was not agreeing on the right answer from the start, but bringing different observation abilities together and updating the exploration graph.

<a id="人間が担ったこと"></a>
### What the human did

- Brought in actual C++ submissions, Swift submissions and judge values as external answers.
- Presented new branches, such as 「IntとInt32の差」, 「Viewの所有」, 「subscript」 and 「DSUの使い方」, at the points where anchoring came off.
- Judged, even for branches with small improvements, whether they were worth a real submission and the operational cost.
- Pointed out that the local machine was ARM64 and the judge x86_64, stopping over-generalization of local results.

<a id="aiが担ったこと"></a>
### What the AI did

- Built a reproduction environment for Swift 6.2 and checked Release builds and machine code.
- Changed only one condition at a time and pre-evaluated branches with local repeated measurement.
- Aggregated Time Profiler XML in the same way and chose the next candidate from self time.
- Reverted branches whose improvement did not reproduce and kept the best point.
- Corrected the initial overly strong estimate that "DSU allocation is the main cause" according to the profile results.

<a id="答えを持つものへ聞いた順序"></a>
### The order of asking those that have the answers

In this exploration, agreement in conversation was not taken as evidence.

1. Asked the compiler which declarations work in Swift 6.2 and the optimization results.
2. Asked the assembly where inline, ARC, witness dispatch and allocation remain.
3. Asked Time Profiler where real time concentrates.
4. Asked repeated measurement under identical conditions about the direction of local changes.
5. Asked real submissions on AtCoder's Linux x86_64 whether the improvement holds in the target environment.

When answers disagreed, evidence closer to the target environment took priority. macOS ARM64 results were useful for finding branches, but
were not grounds for adopting branches that did not improve on Linux x86_64.

<a id="今回の失敗と訂正"></a>
## Failures and corrections this time

- At first, the end-to-end gap was strongly attributed to the permutation implementation. The DSU usage structures of C++ and Swift should have been checked first.
- When per-candidate allocation was found in the assembly, it was described as the main cause. After profiling, it was corrected: DSU search, checks
  and permutation updates were also large, and allocation alone could not explain it.
- Seeing samples of `Permutation.subscript`, `element(at:)` was proposed, but renaming to a method with the same precondition
  did not change the machine code.
- `while` and the unsafe edge buffer, which improved on ARM64, were expected to help, but did not reproduce in x86_64 real submissions.

These are not failures to hide but evidence that narrowed the next branches.

<a id="再利用できる知見"></a>
## Reusable findings

1. In performance comparisons with external implementations, first make the allocation, initialization, duplicated searches and early termination of the surrounding algorithms symmetric,
   not only the target API.
2. Do not confuse end-to-end values with component benchmarks. Even if the permutation alone is fast, the user code's DSU or accessors may
   dominate.
3. Assembly answers "what remained", the profiler "what dominated", and real submissions "whether it holds in the target environment".
   Do not decide all three with one piece of evidence.
4. Change one branch at a time and revert branches that do not improve. Mixing several changes loses the boundaries for adoption and recovery.
5. For optimizations across architectures, use local measurement for candidate exploration and the target environment as acceptance evidence.
6. Keep upper-bound experiments with safety removed not as formal proposals but as comparison points showing "where the cost of safety lies".

<a id="現在の実験sourceの扱い"></a>
## Handling of the current experiment source

`Maintanance/User/PermutationBorrowedSpanExperiment.swift` does not make the unsafe upper-bound experiment that reached 80ms a product candidate as is,
and keeps the converged state returned to runtime-checked temporary Views. DSU reuse, single `unite` and the
iterative leader remain as optimizations on the submission side, while the View keeps the GateKeeper and generation, and element access also goes through the public subscript.
The content and results of the 80ms branch are saved in this document and the commit history.

Running the fixed 36-edge input 7 times on Swift 6.4 Release, the equivalent of the unsafe 80ms branch, the version returned to safe Views,
the version with `@inline(__always)` removed from `next()`, and the version with the GateKeeper's `closeCurrentView()` returned to the same
`@inline(never)` as the product all had a median of 0.46 seconds. All outputs also matched. At the resolution of ARM64 local measurement,
no differences could be confirmed for additional inline attributes, removing safety checks, or the DSU declaration order.

Therefore no change attributed to this exploration is added to the product Permutation. The large shortening is separated as the result of aligning the surrounding processing structure with the C++ version
through DSU reuse, single `unite` and the iterative leader. The fact that getting the selection state directly from a pointer shortened the
AtCoder real submission from 88ms to 80ms is an upper bound bypassing the safe public contract, and is not grounds for adopting it in the product implementation.
