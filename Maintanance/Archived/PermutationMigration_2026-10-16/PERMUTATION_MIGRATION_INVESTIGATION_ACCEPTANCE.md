# Permutation移行調査の受入・統合記録

## TL;DR（人間向け）

Permutation移行の静的調査3件（PERM-073〜075）を、Astraが現行ファイルと独立照合して訂正・補足つきで受け入れた記録。先行互換の適用範囲、release candidate経路の補完、方式と要求の区別などを訂正し、計画への入力をまとめた。方式・工程の決定や実装開始、build・CIの成功保証は含まない。

Written by Astra. 2026-10-15. Targets: PERM-073, PERM-074, PERM-075.
Base HEAD: `cd2dd7ad3ac594b84bccc3fe62dd45779d88fb82`.

<a id="受入結果"></a>
## Acceptance result

On receiving the user's start/finish reports and the 3 return texts, Astra independently checked them against the current files. The 3 are accepted as static investigations, including the corrections and supplements below. The investigation work is complete. On 2026-10-15 the user permitted the commit, so the Registry's DONE record is saved in the same commit as the outputs and acceptance record. Deciding the method or steps and starting implementation are not included.

The original answers are not changed. The 「未返却」 at the top of workers 1 and 2 remains as template text outside their editing permission. The receipt and acceptance state of these returns are recorded in this document and the Registry.

<a id="独立照合した主な根拠"></a>
## Main grounds checked independently

- Structure: checked `Package.swift`'s products, the dependencies and settings of AcCollections, PermutationModule and PermutationTests, `Sources/AcCollections/AcCollections.swift`, and the existing RedBlackTree compatibility shim. Accepted the organization that the new/old entries and the facade need separate checks.
- Public surface: checked the normal types and nested types, the compiler conditions of the borrowed version, the AtCoder 2025 conditions, and the public-surface tests and compiler fixture manifest. Type identity of the new/old entries and success of real builds are unverified.
- Performance CI: checked the registered titles in `PermutationBenchmarks.swift`, `CI.json` and `CI-Small.json`, the current/base separation in `ci.yml`, library forwarding, and the name conversion and result normalization of the existing 2 series. Renaming the module alone does not require changing benchmark titles.
- Documents: checked the module DocC entry and symbol links, the facade example, the DocC matrix, the existing Pages targets, and the record in `DOCUMENTATION_CI_PLAN.md` that the publication destination and URL are unconfirmed. Also confirmed that 「旧module互換未決」 remains in the quality documents. The user's policy of keeping the old name is distinguished from the undecided way of realizing it, and both are handed to the plan.
- The uncommitted changes at the time of checking were only the 3 worker return files; no source, manifest or workflow changes. No build, test or CI was run this time either, and success after the migration is not guaranteed.

<a id="統合時の訂正補足"></a>
## Corrections and supplements at merging

1. **Scope of advance compatibility**: Astra's request file's 「名前互換の先行merge後にrename」 (rename after first merging name compatibility) was too broad. What the guide requires is workflow compatibility before changing benchmark task titles. Worker 1's proposal to add a new-name shim first and later reverse the dependency is an option, not a required step of the module migration. Worker 3's DocC changes also do not always presuppose benchmark-name compatibility. The condition of keeping each stage working is kept.
2. **Release candidate route**: worker 2's main check target was `ci.yml`. Astra also checked `.github/workflows/candidate.yml` and supplemented that it has the same library forwarding and the conversion/normalization of the 2 Array-family series. A plan that changes benchmark titles includes the candidate route, not only the PR route.
3. **Distinguishing method from requirement**: the requirement is that the same types and implementation can be used; re-exporting from the old module is a strong method candidate. The concrete shim structure in the original answer's 「維持対象」 is not treated as a decided method.
4. **Checked scope**: this is not an exhaustive check of all external URLs or saved run results. Evidence obtained under the old name is kept under the old name; the new target's build, DocC and comparison with the old baseline are confirmed by execution after the plan.

<a id="計画へ渡す入力"></a>
## Inputs handed to the plan

- Make the structure concrete with one new implementation target, so that the old entry and the facade reach the same declarations. Verify the three entries (new, old, facade) and normal / 2025 compatibility mode.
- The module migration and the benchmark title tidy-up can be handled as separate changes. Only if titles are changed, set up the steps compatibility first → green → title change → comparison completes, for both PR and candidate. Do not automatically resume the frozen PERM-063 and 064.
- Align the new target, the DocC entry, continuous generation targets and the current quality explanation. Do not bulk-replace old names in history; connect the SPI URL after confirming it exists.
- Plan the concrete method and merge units in consultation with the user. Deleting the old module or CI compatibility is not a completion condition.

<a id="受領した原回答"></a>
## Original answers received

- [Worker 1 return](PERMUTATION_MIGRATION_WORKER_1_RESULT.md): SHA-256 `3b43a52dfd23b1a0ef441558c7d498c621494812777f9a4aea6bdd9fe97225cc`.
- [Worker 2 return](PERMUTATION_MIGRATION_WORKER_2_RESULT.md): SHA-256 `7e9251306b66f0b255dad57625a60e25ad1072d6cd83d8a2c1147262061c96a5`.
- [Worker 3 return](PERMUTATION_MIGRATION_WORKER_3_RESULT.md): SHA-256 `7ba266b6cc6d2991d9504dd96bed3d03e1bcd1bf0181ab1dde3441d11d1b0cce`.

<a id="後続計画"></a>
## Follow-up plan

On 2026-10-15 the user confirmed the policy of keeping the old name for compatibility and delaying the benchmark-name tidy-up to a later stage. The confirmed policy and the concrete step proposal are recorded separately in [the module migration plan](../../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md).
