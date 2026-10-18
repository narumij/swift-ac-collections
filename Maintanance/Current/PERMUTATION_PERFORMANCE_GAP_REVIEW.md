# Permutation性能の落ち穂調査案

## TL;DR（人間向け）

契約を維持したままPermutationの性能改善候補を探す、当初の提案です。ユーザーの保存差分で完了指定され、仮接続も外れています。

この完了は、調査を実施した・性能が改善したという認定ではありません。再び測るときは対象版・範囲・担当を定め直します。

<!-- OPS-133: 2026-10-19 / Astra. Reading entry; does not replace canonical decisions/status. Review when conclusions/boundaries change. -->

PERM-080 / Author: Astra / 2026-10-16. Registered CP-20261016-016 as a proposal, initially PROPOSED.

After the 0.5.4 release, fix its runtime-check version as a baseline and investigate performance opportunities while retaining contracts. Start from regular CI's two batched cases, one end-to-end case, and quality measurements; inspect costs using interleaved measurements, machine code and profiles. Compare old 0.5.3, the borrowed version and C++ only as references with contract differences explicit, not as regression standards under old contracts.

Before starting, fix the target SHA, measurement environment and ordering against PERM-064's display-name migration, and approve scope/owner. Completing 0.5.4 does not authorize automatic execution. Deliver candidates, measurement evidence and unverified items. Implementation adoption, weaker contracts, threshold changes and the 0.5.4 judgment are excluded. If contract changes are needed, stop and return them to the user.

Original proposal: CP-20261016-016 in CLAUDE_PENDING_TASKS.md. Acceptance here records the proposal, not an established performance deficiency.

<a id="2026-10-18-ユーザー状態更新"></a>
## User status update — 2026-10-18

The instruction to import Studio save `20261018T014717178322Z-c0ad4b23` changed this to DONE and removed the provisional connection to END-0.6.1. AI did not establish that investigation occurred or performance improved. Preserve the above as the initial proposal.
