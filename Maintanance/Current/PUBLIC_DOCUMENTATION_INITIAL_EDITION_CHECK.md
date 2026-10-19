# 0.6.0公開ドキュメント初版確認

## TL;DR（人間向け）

0.6.0の公開ドキュメント初版（赤黒木・NextPermutation・OptionalElementBuffer・ElementBufferの4モジュールとREADME）を、意味・制約の照合とRelease DocC生成・既存例の実行で確認した記録。見つけた文書上の不整合は訂正し、ユーザーのcommit承認で完了した。リリース開始や1.0品質合格ではなく、ブラウザ目視・Linux・全製品テストは未実施。

2026-10-16, Astra. Task DOC-035. The initial-edition check was done and completed by the user's commit approval on 2026-10-16. The working tree is base e76964c2 plus this document correction.

<a id="入力"></a>
## Input

RELEASE-078's organization of provision categories, targets and needed document inputs, and DOC-034's completed red-black tree body. The draft acceptance of the existing 3 modules is reused, but is not treated as the current public initial edition having been checked.

<a id="実施と完了条件"></a>
## Execution and completion condition

Fix the target version, and check the public documents of RedBlackTreeCollections, NextPermutationModule, OptionalElementBufferModule and ElementBufferModule, the routes from the README, the public API comments, the published examples and the DocC build diagnostics. Verify a successful build and semantic consistency separately. Check provision categories, language version / platform / trait conditions, important usage constraints and unverified claims, and make the missing document fixes and re-check their impact.

List each target's outputs, verification evidence and unresolved items, and return with grounds whether the public initial-edition conditions are met. Do not complete while there are unresolved items blocking publication. Public contract changes, product implementation fixes and starting a release are not in this task; the needed decisions are separated.

The outputs connect to the documentation initial-edition condition in RELEASE_0_6_0.md. Do not bring forward the 1.0 quality assessment or the human review after SPI. The quality checks needed for each 0.x.0 and the user's release decision are kept.

Additional user instruction on 2026-10-16: DOC-034 → DOC-037 (the user's acceptance decision on the red-black tree body) → DOC-035. Proceed to DOC-035 only after DOC-037 explicitly states acceptance. Do not proceed on a send-back or hold, and do not treat merely completing the decision task as permission. DOC-035's RELEASE-078 prerequisite is also kept.

<a id="080への拡充移管と今回の固定範囲2026-10-16ユーザー決定"></a>
## Moving the expansion to 0.8.0 and this fixed scope (user decision, 2026-10-16)

In this 0.6.0 documentation work, the composition and number of existing snippets are fixed: none are added or removed. Checking and verifying existing examples and correcting errors are handled, but if an increase or decrease is needed, record it rather than changing it without permission. Adding code snippets and reviewing the documents as a whole were placed in 0.8.0. The existing 「必須コード例」 and 「不足補完」 are handled within this fixed scope and are not requirements to create new examples.

<a id="実施入力2026-10-16"></a>
## Execution input (2026-10-16)

Started on receiving [the RELEASE-078 reconciliation result](../Milestones/_Archived/RELEASE_0_5_4_HISTORY.md#release-0-6-0-scope-reconciliation). Evidence is saved in Evidence/DOC-035-2026-10-16/.

<a id="確認結果2026-10-16--astra"></a>
## Check result (2026-10-16 / Astra)

Within the scope checked this time, the documentation inconsistencies blocking the initial edition have been corrected. The main uses, basic operations and important constraints of the 4 targets were checked against the current contracts, and the Release DocC builds and existing examples were checked. A successful build alone was not the ground. Completed by the user's commit approval on 2026-10-16; this is neither the start of a release nor passing 1.0 quality.

| Target | Meaning and constraint check | Verification |
| --- | --- | --- |
| RedBlackTreeCollections | Reused DOC-034's 4-type body, the public comments and DOC-037's acceptance. Confirmed the input is unchanged since f6e181b2 | Release DocC succeeded this time. Reused the compile/run evidence for the 78 existing examples |
| NextPermutationModule | Initial order and lexicographic successor, invalidation of temporary Views, borrowing, non-Sequence, owned buffer | Release DocC succeeded. The 4 outputs of the published examples match |
| OptionalElementBufferModule | Trait condition, experimental offering, unset and disposal, axis order, range conditions, non-mutating updates | Release DocC succeeded. AcCollections build with the trait enabled and the published example run; value 42 confirmed |
| ElementBufferModule | Swift 6.2 provision category versus the current package 6.4, MutableRef on Apple OS 27, borrowing and non-mutating access constraints | Release DocC succeeded. Value access 42 and borrowed update 3 confirmed by running. Type comment example also checked |
| Common entry and README (ja/en) | Routes to the source-version guides of the 4 modules, the Swift 6.4 condition, Optional's experimental category | AcCollections DocC succeeded. The added local links in the README exist |

<a id="訂正"></a>
### Corrections

- Corrected "permutation sequence" in the AcCollections overview to iterators.
- Stated the experimental offering and the constraint on simultaneous access in the OptionalElementBuffer overview. Also supplemented the Sendable explanations of the 4 types: they do not provide synchronization. Implementation and conformances are unchanged.
- The README (ja/en) now guides to the required Swift version and the source-version guides of the 4 modules. Current Pages cover only the red-black tree, so the other 3 targets are not pointed at published URLs.
- The composition and number of code examples are unchanged.

<a id="証拠と限界"></a>
### Evidence and limits

See verify.py, verification.json, input-sha256.json and each DocC log in [the evidence set](Evidence/DOC-035-2026-10-16/). Done on macOS 27.0.1 / arm64 / Apple Swift 6.4. Compiled and ran the 6 existing code blocks of the 3 targets and the common entry (including 1 import-only block) and checked values and outputs. The 78 red-black tree examples reuse accepted evidence and were not re-run.

To avoid an environment problem of the default Xcode build route, the SwiftPM native build route was used (with deprecation warnings). DocC succeeded with warnings-as-errors. The first example verification failed to link because the verification script specified a nonexistent per-module object; it was fixed to per-source objects and succeeded. This is not a product bug.

Browser viewing, reachability of external links, Linux runs, all product tests and performance re-measurement were not done this time. The Pages delivery method for the 3 unpublished targets stays in the already-decided 0.7.0 steps. Do not read these as checked this time. No public contract changes or new snippets beyond this document correction were made.

This result connects to [the 0.6.0 gate](../Milestones/_Archived/RELEASE_0_5_4_HISTORY.md#release-0-6-0). After the result report, the user explicitly said 「コミットして」 and this document check was completed. The quality checks needed for the target version and the user's decisions on product scope and release start are kept separately.
