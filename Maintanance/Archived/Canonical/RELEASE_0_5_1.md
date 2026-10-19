# Release 0.5.1

## TL;DR（人間向け）
0.5.1の製品範囲とrelease検討、候補検証の経緯を記録します。release checklistへの進行は承認されましたが、この記録の時点ではtagやpushの許可を含みません。これは当時のrelease記録です。

最終更新: 2026-10-09 / Codex

## 状態

The product scope was established and a candidate was being prepared using the release checklist. At this point, neither a release-candidate commit nor tag position had been fixed; no tag or push had occurred.

## Release検討開始条件

The following three targets had to complete their Test as Specification work before release consideration for 0.5.1 could begin:

- Permutation: complete
- OptionalArray: complete
- BareArray: complete

This was a start condition, not a release completion condition. Once met, the user would decide in a single judgment both the product scope for 0.5.1 and whether to proceed to the release checklist.

## 条件到達後の流れ

1. Review changes since the prior version and separate those to include in 0.5.1 from those deferred to later work.
2. The user decides the product scope and whether to begin release consideration.
3. Only if adopted, design the candidate commit, required CI, documentation, performance checks, and independent review under [`RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md).
4. Obtain separate approval for each target operation: tag creation, push, release page, and integration into a later branch.

This document and task registration do not authorize a release, tag, or push.

## 2026-10-09 到達範囲の判断材料

The product-code diff from `0.5.0..HEAD` was mainly BareArray. Public names and type structure were retained, and the following work was completed:

- Added initializer preconditions requiring each dimension to be non-negative (zero permitted) and the dimension product to fit in `Int`.
- Changed chained writeback setters for owning 2D–4D types and 2D–3D Views to permit only the same pointer and shape.
- Completed numbered BareArray Test as Specification coverage for asymmetric dimensions, bounds, writeback, invalid dimensions, and reference lifetime.
- Completed Test as Specification for Permutation, OptionalArray, and BareArray.
- The initial BareArray quality assessment was input to documentation work. Full comment documentation, a first user-facing documentation draft, performance criteria, View lifetime, and strict memory safety decisions for 1.0 remained for later releases.

Codex recommended defining 0.5.1 as a maintenance release that hardens existing BareArray public contracts and provides Test as Specification evidence for all three targets. It would include no new public features, public-name changes, first user-documentation draft, or 1.0 quality decisions.

Release consideration would begin and the candidate commit and required gates would be specified under `RELEASE_CHECKLIST.md` only if the user adopted this scope.

### User decision

On 2026-10-09, the user adopted the recommended scope for 0.5.1 and decided to proceed to the release checklist.

## Release計画

- Scope: harden existing BareArray public contracts and complete Test as Specification work for Permutation, OptionalArray, and BareArray. Exclude new public features, naming changes, an initial documentation draft, and 1.0 quality decisions.
- Required local gates: ordinary Debug/Release tests, Death Tests, documentation with warnings as errors, and a diff review for unintended public API, re-export, and Package changes.
- Required remote gates: all required workflow jobs, including ordinary tests, Linux, documentation, Address Sanitizer, and performance. Performance is a release gate for the candidate commit as a whole; it does not claim a product performance change.
- Independent review: after local and remote gates pass on the same candidate commit, Claude reviews the final candidate without modifying it.
- Record boundary: include release records in the candidate commit before fixing it. Put post-tag records on a new work branch.
- Operation boundary: obtain separate user approval for tag creation, tag push, release page, and integration into a later branch.

## Checklist進捗

### 0. Release計画

- [x] The user confirmed version `0.5.1` and its product scope.
- [x] Separated changes included in the release from documentation work and 1.0 decisions deferred to later work.
- [x] Established this document as the version-specific release record.
- [x] Defined required local and remote gates and Claude's independent check.
- [x] Confirmed that tag, push, release page, and later-branch integration are separate operations.
- [x] Decided to include release records in the candidate commit and put post-tag records on a new work branch.

### 1. 候補commit固定前

- [x] Reviewed the commit list and diff from `0.5.0..HEAD`.
- [x] Confirmed that README has no version-pinned text and the Package manifest has no release-version setting.
- [x] Added 0.5.1-specific Test as Specification work and BareArray changes to the CHANGELOG `Unreleased` section.
- [x] Committed the release plan and CHANGELOG; provisionally fixed `7d1a9a79` as the candidate.
- [ ] Perform a final check for unintended merges, generated files, local-only files, or configurations outside the release scope.

### 候補固定後の再固定記録

Debug verification of `7d1a9a79` found that the OptionalArray quality-assessment document remained as an unhandled-file warning from SwiftPM. The BareArray target already excluded this kind of file, so add `Documentation` to the OptionalArray target's exclusions as well. This invalidates the provisional candidate; after committing the change, fix the candidate commit and local gates again.

### 2. Codex一次検収

Verification was performed on candidate `7884ecb4` (repository tree `227801b5699f51c6a8c5a3d3687c3240b067bdc6`).

- [x] All package Debug tests passed, including 35 ordinary BareArray tests and 42 Death Tests.
- [x] All package Release tests passed, including 28 ordinary BareArray tests and 42 Death Tests.
- [x] The CI-matching RedBlackTreeCollections documentation command succeeded with `--warnings-as-errors`.
- [x] Excluded the OptionalArray and BareArray quality-assessment documents from their targets, resolving SwiftPM unhandled-file warnings.
- [ ] Complete the final check for unintended public API, re-export, or Package changes.
- [ ] Pass all required remote CI jobs on the same candidate commit.
- [ ] Complete Claude's independent check.

Known non-blocking candidates remained: an unused-result warning in Permutation source and warnings such as `var` in existing tests. They were not introduced by the product diff, and tests passed. They do not affect the documentation warnings-as-errors gate. Classify them as release-blocking or deferred after the public-diff review and Claude's independent check.

The commit adding this section changes only release records. Use the resulting HEAD as the final candidate for remote CI and independent review, and confirm that `7884ecb4..HEAD` contains no source, test, Package, workflow, or user-facing documentation changes.

### 独立チェック1回目

Claude marked candidate `4d5ce7b8` as `BLOCK` because the CHANGELOG mixed the 0.5.0 and 0.5.1 entries under the same `Unreleased` heading, preventing version-specific identification of 0.5.1 changes. Two items were `UNVERIFIED` because the CI head SHA could not be checked directly; the others were `PASS`. Accepting the block, clear `Unreleased` and separate the three 0.5.1 items from the existing 0.5.0 items under distinct version headings. Use the corrective commit as a new candidate and rerun remote CI and independent review.
