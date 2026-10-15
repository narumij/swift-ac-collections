# Codex-to-Claude Work Request

Status: Bounded assignments only. Temporary primary-user-support delegation ended 2026-10-08 by user direction.

Task selection and start authority are defined in the root `CLAUDE.md`. This document records only the current job and
bounded-task execution constraints. Codex integrates returned results, performs Registry acceptance and state updates,
and owns public-document completion. Repository evidence establishes factual correctness; product decisions remain with
the user.

## Current job status

**`PERM-067`のうち、姫による独立候補提出を依頼中。**

ユーザーがClaudeへ直接依頼した採番前の作業は、[採番待ちqueue](CLAUDE_PENDING_TASKS.md)に記録する。
この節のjob有無と、queueの未処理記録は区別する。

Completed assignments and their Return records through 2026-10-14 are preserved in
`Archived/CLAUDE_TASK_HISTORY_2026-10-14.md`. Earlier history remains in `Archived/CLAUDE_TASK_HISTORY.md`.

Use [Progress V2](ProgressV2/PROGRESS_OVERVIEW_V2.md) as the current entry point. Frozen work, remaining tasks,
assignees, dependencies, and restart conditions are recorded in [Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md).
Task rules, numbering, and document authority are defined in [Task Rules V2](ProgressV2/TASK_RULES_V2.md).
Current assignments must follow the current request and explicit delegation, not a Registry assignee name alone.

For the authority of historical records, including these Return records and the retired `PROGRESS_OVERVIEW.md`,
follow [AGENTS.md — 現在の仕事と正本](../AGENTS.md#現在の仕事と正本).

## Active assignment

### PERM-067-HIME — PermutationModule公開API名称候補の独立提出

#### Objective

PermutationModuleの現行6 surfaceについて、姫自身の名称候補を独立に提出する。現行名の維持も候補として
扱い、名前だけでは解けない契約上の問題は候補へ混ぜず分離する。候補提出は採点・採用・renameではない。

#### Inputs

- `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md`
- `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATE_FORM.md`
- `Sources/PermutationModule/NextPermutations.swift`
- `Sources/PermutationModule/BorrowedNextPermutations.swift`
- `Sources/PermutationModule/PermutationModule.docc/PermutationModule.md`
- 必要な範囲の現行testと`Maintanance/PermutationModule/UserDocumentationDraft.md`

#### Work

1. source、test、DocC、利用者向け本文から、対象surfaceと現行契約を照合する。
2. 他者の候補を読まず、module名と通常版・borrowed版のAPI familyについて候補を作る。
3. 各候補に、意図、代表call site、familyとしての予測可能性、誤読・懸念、互換コストを付ける。
4. 契約変更を伴わない名称案と、未解決事項・契約変更案を分ける。
5. 共通書式を使い、結果を
   `Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_HIME.md`へ記録する。

#### Independence boundary

- 候補提出を終えるまで、ユーザーまたはV3の候補・採点・意見を読まない。
- `Maintanance/Archived/PublicAPINaming/`は過去のPermutation候補を含むため読まない。
- 候補数や表現を他者に合わせず、現行名を採用済みとも不採用ともみなさない。
- 調査中に偶然他者候補を見た場合は、その範囲をReturnへ明記し、独立案と混ぜない。

#### Boundaries

- production、test、benchmark、fixture、DocC、利用者向け本文を変更しない。
- Registry、Task Rules、名称決定正本、共通提出表を変更しない。
- 候補を順位付け、採点、集計、採用しない。
- 列挙範囲、所有、寿命、runtime検査、`Span`契約、`Sequence`適合、toolchain提供範囲を変更しない。
- `PERM-060`その他の凍結taskを再開しない。
- commitしない。

#### Questions

- 現行6 surfaceは、利用者が実際に選ぶ経路と寿命差を名称だけでどこまで予測できるか。
- 通常版とborrowed版を一つのfamilyとして見たとき、どの対応関係が自然か。
- 現行名維持を含む各案は、どの誤読を減らし、どの誤読または互換コストを生むか。
- 名称ではなく製品判断や契約変更として分離すべき発見があるか。

#### Completion

- 対象6 surfaceすべてについて、維持案・変更案・候補なしのいずれかが記録されている。
- 各候補に比較材料があり、名前だけの案と契約変更案が分離されている。
- 独立性境界を守った範囲が記録されている。
- 指定した候補文書以外を変更していない。

#### Return

（姫が完了時に、作成ファイル、照合範囲、候補概要、未解決事項、独立性への影響、変更ファイルを記録する。）
