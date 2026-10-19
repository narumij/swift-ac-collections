# Permutation Test as Spec 仕様レビュー

## TL;DR（人間向け）

NextPermutationModuleの通常版と借用版について、公開コメントと現行のTest as Specを静的に照合したAstraのレビュー（PERM-077）。全面的な書き直しは不要とし、検証の不足B〜Dを依頼（PERM-078）にして、Claudeの反映をAstraが独立実行で受け入れた。Aの借用寿命のcompiler検査はPERM-051の範囲で、後に品質側へ移ったため独立taskとしては除外された。製品の不具合を確認した報告ではない。

Written by Astra. 2026-10-15. Base: `4f8c9aef`. Review and request preparation: `PERM-077`.

<a id="結論と範囲"></a>
## Conclusion and scope

For the new main entry NextPermutationModule's normal runtime-check version and the Swift 6.4 borrowed version, the public comments and the current Test as Spec were checked statically. Existing checks cover enumeration order, initial order, duplicates, empty / single element / descending, non-Int Index, invalidation of normal Views, and destruction of normal owners. A full rewrite is not needed. The following are gaps in verification, not a report confirming defects in the product implementation.

No tests or compiler fixtures were added or run this time. The success records at migration are not reused as re-run results. The 5 existing specifications of AtCoder 2025 compatibility mode were read, but an exhaustive review of the whole old API is not part of this conclusion. Disabled old COW tests are not counted as current specifications.

<a id="a借用寿命の再実行可能なcompiler検査既知の残件"></a>
## A: re-runnable compiler checks of borrowed lifetimes (a known remaining item)

**Update 2026-10-16 (Astra)**: the user judged 「品質側に移行してるからいらない」 (not needed because it has moved to the quality side) and excluded PERM-051 as an independent task. The resumption requests and out-of-scope statements below are the boundaries of their time, and do not require resuming the old task in future quality-side handling. The quality point of this item is kept, but it is not treated as having fixtures implemented. [Exclusion record](../../Archived/PERM-051_EXCLUDED_2026-10-16.md).

Grounds: next() in `Sources/NextPermutationModule/BorrowedNextPermutations.swift` promises that the Span does not outlive the owner and does not overlap with the next mutating access. `Tests/PermutationTests/BorrowedNextPermutations/` has runtime checks of legal use, but the negative checks in `Utilities/Maintenance/CompilerDiagnostics/PermutationPublicSurface/` and `VerifyPermutationCompilerDiagnostics.sh` cover only direct initialization, copy and Sequence of normal owners.

The PERM-051 return in `Maintanance/Quality/0.6.0-1/PermutationModule/BorrowedPermutationTestPlan.md` already has rejection results from a temporary client. So the gap is not "unverified so far" but "no fixture that can be re-run with the current names and the current toolchain". PERM-051 in the Registry is FROZEN and this review does not lift it. Do not bypass the freeze by moving the same work into a new application task.

Check proposal at resumption: take legal sequential use as the positive control, and make independent fixtures for using an old Span after next, carrying it outside the owner's lifetime, consuming the owner while the Span is used later, owner copy, and non-Sequence. Merely failing with a syntax error or a general Span constraint is not evidence of a lifetime dependence on the owner. Confirm the diagnostic of the expected cause. This proposal is not ordered.

<a id="b終端失効death-testの偽陽性を防ぐ反映対象"></a>
## B: preventing false positives in the terminal invalidation Death Tests (to apply)

Grounds: `subscriptTrapsAfterTerminalNextReturnsNil` and `startIndexTrapsAfterTerminalNextReturnsNil` in `Tests/PermutationTests/NextPermutations/NextPermutations_99_ViewInvalidationDeathTests.swift` check, with a precondition inside the child process that checks the expected signal, that the terminal result is nil. Even if terminal handling breaks and it is not nil, that precondition stops with the same signal, and the invalidation check looks successful.

Needed change: distinguish setup failure as an exit other than the expected trap. Also check that nil holds with an ordinary assertion, and structure it so that only access to the invalidated View can cause the expected signal. Not adding Death Tests for every combination, but fixing the verification power of the existing 2. If possible, also confirm with a temporary test-side condition replacement that a setup failure is not treated as success, and revert the replacement.

<a id="c借用版の未開始ownerの非空要素解放反映対象"></a>
## C: releasing nonempty elements of a never-started borrowed owner (to apply)

Grounds: `BorrowedNextPermutations_98_InternalTests.swift` verifies destruction midway, after completion and of an empty owner, but does not directly verify releasing a nonempty owner on which next() was never called. The normal version has `testNeverStartedOwnerReleasesEachElementOnce`. The owned buffer holds elements from creation, so they must be released whether or not enumeration started.

Addition: using reference-type elements and a local counter, destroy a nonempty owner without starting it and confirm all elements are released. Use a scope in which references from the source array do not remain and prevent release. Do not duplicate the same check of the normal version.

<a id="d借用版の生成時copyと元collectionの独立反映対象"></a>
## D: copy at creation and independence from the source Collection in the borrowed version (to apply)

Grounds: `BorrowedNextPermutations_1_EnumerationTests.testSourceIsNotModified` confirms that enumeration does not change the source. On the other hand, the reverse direction — keeping the order at creation even if the source array is changed after creating the owner — is not asserted directly. The public comment explains that it copies into an owned buffer once at creation. The normal version has `NextPermutations_98_OwnershipTests.testLaterSourceChangesDoNotAlterTheCurrentPermutation`.

Addition: after creating a borrowed owner, replace an element of the source Int array and append an element, and confirm that the first and next Spans follow the successor order of the input at creation. This is independence of array storage / order, and does not demand a deep copy of reference-type elements.

<a id="今回追加を求めないもの"></a>
## Not required to add this time

- The normal and borrowed versions have checks of expected values for short enumerations, duplicate elements, nil after the end, and input kinds. Full expansion of combinations or random testing is not a completion condition this time.
- For saving the normal version into an Array, the enumeration helper copies each View during its validity and compares all results afterwards. It is not treated as having no checks of saving.
- Existing tests cover the normal version's independence from the source, release when never started / midway / after completion, and that invalidated Views do not keep the storage.
- Performance re-measurement, adopting Sequence, the benchmark-name tidy-up, reviving the old COW contract and deleting the compatibility entry are not included.

<a id="引渡し"></a>
## Handover

B–D were organized into [the request draft](PERMUTATION_TEST_AS_SPEC_CLAUDE_DRAFT.md) as unordered candidates for `PERM-078`. After confirming Claude's end of OPT-074, the return of occupancy and Astra's acceptance, re-check the current state, and prepare and hand over the request in CLAUDE_TASK with a fixed ID. The current Claude request is not changed. A needs a separate decision to resume PERM-051.

<a id="検証と状態"></a>
## Verification and state

The static review and request preparation are complete. No code changes, no test runs. On 2026-10-15 the user permitted the commit. The review and request preparation are saved as DONE in the same commit as the response record. Creating follow-up candidates is not delegating execution to Claude.

<a id="発注記録2026-10-15astra"></a>
## Order record (2026-10-15, Astra)

Instructed by the user with 「先に渡して、次に閉じる」 (hand it over first, then close), confirmed OPT-074's formal return, no remaining work and the return of occupancy, activated PERM-078, and posted the request in CLAUDE_TASK.md with a fixed ID. The "not ordered" record above is the history at preparation time; it is now ordered (start report not yet confirmed). The scope of B–D is unchanged. A / PERM-051 remains out of scope.

<a id="perm-078返却のastra受入2026-10-15"></a>
## Astra acceptance of the PERM-078 return (2026-10-15)

Independently checked Claude's returned uncommitted diff against base HEAD `904baa02`. The changes are limited to the 3 specified test files, the Tests/TESTING.md handoff and the return field itself; no changes to production, the manifest or the frozen PERM-051. The formal return has no remaining items and a return of occupancy.

B: a failed terminal setup branches to exitCode 86, which does not match the expected Swift trap signal. An ordinary terminal-nil check was also added. C: checks holding a never-started owner made only from a temporary source, and the release count after consume. D: confirms with Int the independence of source changes after creation from the initial order and the successor enumeration. Accepted as within the existing contract.

Astra's independent runs (macOS arm64 / Apple Swift 6.4):
- `swift test --filter PermutationTests`: build failure from the environment's sandbox permission restriction. Not included as evidence of success.
- `swift test --disable-sandbox --filter PermutationTests`: exit 0. XCTest 63 + 7, Swift Testing 18 in 3 suites succeeded. Confirmed that the 2 new borrowed cases and the terminal invalidation cases actually ran.
- `swift test --disable-sandbox -c release --filter PermutationTests`: build failure with Operation not permitted in dSYM generation of the unrelated RedBlackTreeTreeTests.
- `swift test --disable-sandbox -c release -debug-info-format none --filter PermutationTests`: exit 0. Succeeded with the same counts. Release optimization is kept; only debug information generation is omitted.
- `git diff --check`: no problems.

The compatibility configuration and B's old/new negative controls were checked by comparing Claude's returned evidence with the diff. Astra did not re-run them. Not extended to guarantees for Linux, Swift 6.2, ASan, compatibility Release, or running all targets.
Acceptance complete. This commit permission had already been applied to the preceding red-black tree review record, so the Permutation application and acceptance record are WAITING_USER (waiting for commit permission).

On 2026-10-15 the user permitted committing the Permutation application and acceptance record. PERM-078 is DONE, and the changes and this record are saved in the same commit.
