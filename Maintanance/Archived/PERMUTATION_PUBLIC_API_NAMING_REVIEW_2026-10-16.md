> 2026-10-16、役目を終えた記録としてアーカイブ。元文書：`Maintanance/Current/PERMUTATION_PUBLIC_API_NAMING_REVIEW.md`。本文は履歴として保持し、現行の指示・権限にしない。相対リンクのみ補正。

# PermutationModule公開API名称レビュー

## TL;DR（人間向け）

Permutationの公開名が実際の列挙・一時View・借用の役割を伝えるか、候補・採点・理由を整理してユーザー判断へ渡した経緯です。名称は別の決定正本へ確定され、新名を主入口・旧名を互換入口とする移行も受入済みと記録されています。

本文の暫定名・未決欄・工程は当時の記録です。点数や三者の一致は採用そのものではなく、旧工程を現在のrename依頼や契約変更の許可にしません。

## 状態

名称調査・審議の経緯を残す文書。名称は2026-10-15に[名称決定正本](../Current/PUBLIC_API_NAMING_DECISIONS.md)へ確定記録され、新名を主入口・旧名を互換入口とする[移行](../Current/PERMUTATION_MODULE_MIGRATION_PLAN.md)も受け入れ済み。以下の工程記述を未実施の指示として使わない。2026-10-16の棚卸しで、重複するPERM-071を移行受入へ吸収して除外した。

## 目的

PermutationModuleの現行公開surfaceが、現在の並びを含む辞書順の後続順列、一時View、runtime失効検査、
`Span`による借用検査という実際の役割を適切に伝えるかを確認し、ユーザーが公開名を維持または変更できる
判断材料を揃える。

## 調査対象

- module名 `PermutationModule`
- 通常版入口 `nextPermutations()`
- 通常版owner `NextPermutations`
- 通常版の一時View `NextPermutations.Permutation`
- borrowed版入口 `borrowedNextPermutations()`
- borrowed版owner `BorrowedNextPermutations`
- 通常版とborrowed版の名称上の対応関係

## 役割

- ユーザー、姫、V3は候補を提出する。他者案を見てもよいが、候補の出典と閲覧後の反応を残す。
- Codexは現行surfaceとの照合、候補の集計、固定ballotと採点表、Registryの最終更新を担当する。
- ユーザー、姫、V3は固定後の同じ採点表へ独立に採点する。後から理由を読み再評価する場合は、初回採点を
  上書きせずroundを分ける。
- 公開名を最終決定できるのはユーザーだけである。候補の一致、点数、Codexの集計、ゲート確認は決定ではない。

## 工程

1. 現行source、Test as Specification、DocC、利用者向け本文から、各公開名が指す役割と契約を固定する。
2. ユーザー、姫、V3が、現行名の維持を含む候補を提出する。意味、call site、familyの予測可能性、
   誤読、互換コストを添え、他者案を見て加えた案や反応は出典を残す。
3. Codexが候補を出典つきで集計する。名前だけの変更と、列挙範囲・所有・寿命・`Sequence`適合などの
   契約変更を分離し、必要な判断単位だけを固定ballotと採点表へまとめる。
4. ユーザーが採点表の候補範囲と分離を確認した後、ユーザー、姫、V3が独立採点を開始する。
5. Codexが尺度の違い、理由、反証、対立点を統合する。点数の合計・平均・AIの一致を採用判断にしない。
6. ユーザーが各判断を最終決定し、採用名、退けた主要候補、理由、互換上の扱いを
   `PUBLIC_API_NAMING_DECISIONS.md`へ記録する。
7. Codexが決定正本、対象scope、未決事項、依存関係を照合してゲートを閉じる。rename実装は別taskとする。

## 完了条件

### 候補提出

- 現行6 surfaceの意味と相互関係が、現行実装・test・公開文書に照合されている。
- ユーザー、姫、V3の候補がそろい、候補と反応の出典が追跡できる。

### 候補集計・採点表

- 候補の出典、意味、利点、誤読、互換コストが保存されている。
- 名前だけの変更と契約変更が分離され、ユーザーが一つずつ判断できる固定ballotになっている。
- ユーザーが採点対象の完全性と判断単位を確認している。

### 採点

- ユーザー、姫、V3が同じ固定採点表へ独立に採点している。
- 尺度の違い、理由、反証、対立点が保たれ、合計や平均を自動決定に使っていない。

### 最終決定

- ユーザーが対象ごとに現行名の維持または変更を明示している。
- 決定理由、主要な不採用候補、互換方針、実装への影響が名称決定正本へ記録されている。

### 名称決定ゲート

- 決定正本と対象scope、未決事項、依存関係が一致している。
- 未決のscopeは未決として残り、調査完了だけで採用またはrenameへ進んでいない。

## ユーザーの暫定判断

2026-10-15、Round 1統合報告のうち三者の理由が同方向だった次の三項目を、ユーザーが暫定確定した。
正式な採用正本への記録とrename判断は、残るsurfaceの決定後に行う。

| 対象 | 暫定名 | Candidate ID | 状態 |
| --- | --- | --- | --- |
| 通常版入口 | `nextPermutations()` | `NE-01` | 暫定確定 |
| borrowed版入口 | `borrowedNextPermutations()` | `BE-01` | 暫定確定 |
| borrowed版owner | `BorrowedNextPermutations` | `BO-01` | 暫定確定 |
| 通常版owner | `NextPermutations` | `NO-01` | 暫定確定 |
| 通常版ownerのgeneric parameter | `Element` | `GP-02` | 暫定確定。実sourceのcompile・DocC確認はrename実装時の受入条件 |

未決: module名、通常版一時view。

## 対象外

- production、test、benchmark、fixture、文書のrename実施
- `NextPermutations`の列挙範囲、所有buffer、一時View寿命、runtime検査方式の変更
- borrowed版の`Span`契約やtoolchain境界の変更
- `Sequence` API案の再開または採否
- performance task名やbaseline互換の変更

## 根拠

- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_CANDIDATE_FORM.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_USER.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_HIME.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_CANDIDATES_V3.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_BALLOT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND1.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND1.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND1.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND1_REPORT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_ROUND2_INPUT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND2.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND2.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND2.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND2_REPORT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_ROUND3_INPUT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND3.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND3.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND3.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_ROUND4_INPUT.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_USER_ROUND4.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_HIME_ROUND4.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_V3_ROUND4.md`
- `Maintanance/Archived/PublicAPINaming/Permutation/PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md`
- `Sources/PermutationModule/NextPermutations.swift`
- `Sources/PermutationModule/BorrowedNextPermutations.swift`
- `Sources/PermutationModule/PermutationModule.docc/PermutationModule.md`
- `Maintanance/PermutationModule/UserDocumentationDraft.md`
- `Sources/PermutationModule/Documentation/Quality-Profile.md`
- `Tests/PermutationTests/NextPermutations/`
- `Tests/PermutationTests/BorrowedNextPermutations/`
- `Maintanance/Current/PUBLIC_API_NAMING_DECISIONS.md`
- `Maintanance/Archived/PublicAPINaming/`
