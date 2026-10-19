# Permutation公開API名称 — Astra最終提案・三者合意確認

## TL;DR（人間向け）
Module名`NextPermutationModule`と通常版一時View名`NextPermutations.Permutation`について、三者の同意確認をまとめた当時の提案記録です。正式名称の採用とrename実行は別の判断として残しています。

作成者：Astra。作成日：2026-10-15。確認task：`PERM-072`。

## 位置づけ

This is the canonical record of the final proposal requested by the user and the agreement check among the user, Claude (Hime), and V3. Astra authored the proposal and is not one of the three respondents. All three agreed on both the module name and the regular-mode temporary View name; responses have been consolidated. On 2026-10-15, the user instructed that the completion record be saved. The request to prepare this document, earlier scores, and agreement between AIs are not recorded as agreement with the proposal. The final public-name decision remains under existing task `PERM-070` and `PUBLIC_API_NAMING_DECISIONS.md`.

## 最終提案

| Decision | Astra proposal | Change |
| --- | --- | --- |
| Module name | `NextPermutationModule` | Proposed change from current `PermutationModule` |
| Regular-mode temporary View | `NextPermutations.Permutation` | Keep leaf name `Permutation` |

The regular entry point `nextPermutations()`, regular owner `NextPermutations`, borrowed entry point `borrowedNextPermutations()`, borrowed owner `BorrowedNextPermutations`, and generic parameter `Element` rely on existing provisional confirmations and are not rescored. Retain the condition that `Element` be checked by compiling the actual source and building DocC.

### Module名の理由

The current central entry point and owner are `nextPermutations()` and `NextPermutations`, so align the module with the same functional stem. Prioritize correspondence with the existing feature over breadth for unspecified future Permutation APIs. Note that compatibility mode has an all-permutations API, but this is not a decisive reason against a name for the central feature.

The name `Next` alone does not communicate the contract that the first result is the current ordering and subsequent results are only its lexicographic successors. Explain this in documentation and examples. Renaming the module has migration cost and is not a free change.

### 一時view名の理由

`NextPermutations.Permutation` communicates the relationship between the sequence being enumerated and one result. `Current` in `CurrentPermutation` could imply a value that continuously reflects the current state. The actual View does not follow the next state; it becomes invalid at the next `next()`. Astra does not consider adding `Current` alone sufficient to clarify that difference. This is a semantic assessment, not a user study measuring misunderstanding.

Explain in the type overview, examples, and diagnostics that this is a temporary View, that it becomes invalid at the next `next()`, and that preserving it requires a copy into an `Array` or similar value. Keep `Permutation` rather than overloading the name with lifetime details.

## 固定する契約と対象外

- The first result is the input’s current ordering; subsequent results are only its lexicographic successors.
- Regular mode returns a temporary View of an owned buffer and checks invalidation at runtime.
- Borrowed mode lends a `Span` from an owned buffer and relies on the compiler to check lifetime.
- The owner is noncopyable and does not conform to `Sequence`.
- This task checks agreement on two names only. It does not implement renames, change public contracts or default paths, or reopen frozen tasks.
- This proposal does not decide whether to retain a compatibility target under the old module name. Agreement on a name is not agreement on a migration method. The user must explicitly decide this in the existing final-decision task before implementation.

## 三者への確認方法

Respond separately for each subject on whether you agree to adopt the proposal; this is not a rescoring round. Choose “agree,” “agree with conditions,” “disagree,” or “hold,” and state any reasons or conditions. Do not remove prior objections to solicit agreement. If disagreement remains, state what is unresolved; do not treat majority voting or an automatically scheduled additional round as resolution.

### ユーザー回答欄

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| `NextPermutationModule` | 同意 | そもそもこれにしたいことが一連のタスクの動機だったから。反対2だったら諦めたけど |
| `Permutation`維持 | 不同意 | 誰も確認してくれてないけど、これはかぶりがありそう |

### Claude姫回答欄

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| `NextPermutationModule` | 同意 | Round 3・4での選好（`MN-03`）と同じ。中心の入口・ownerと語幹が一致する。互換modeの全順列APIとの不一致と、旧名を残すかの移行判断は、提案どおり名称への同意に含めない |
| `Permutation`維持 | 判断保留 | 型名の衝突は確認した範囲では無い：package内のSourcesとtests、依存package（`.build/checkouts`の10件）で`Permutation`型の宣言はこのnested typeだけで、常に`NextPermutations<…>.Permutation`と修飾して使うため、利用者のtop-level型とも衝突しない（extension内では利用者側の同名型を覆い隠す）。一方、名前の重なりは別の問題として残る：数学の「置換」（全単射）や、所有された値を想像させる一般名詞で、次の`next()`で失効する一時viewの名前としては広すぎる。AtCoder利用者が自前の`Permutation`型を持つことも多いと見込まれる（未確認）。swift-ac-library等の姉妹packageは調べていない（repository外）。Round 4までの7点は型の衝突がない前提での評価だったが、ユーザーの懸念のうち「意味の重なり」は否定できないため、同意から保留へ下げる |

### V3回答欄

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| `NextPermutationModule` | 同意 | 現在の中心入口`nextPermutations()`とowner `NextPermutations`に語幹が揃い、今後の利用者がmoduleと中心機能を対応づけやすい。未具体化の将来APIより現行機能を優先する。旧module名の互換措置は名称判断に含めない |
| `Permutation`維持 | 判断保留 | repositoryと依存package内に具体的な型宣言の衝突がないことは姫の調査で確認できるが、数学上の広い「置換」、所有された値、自前の同名型との意味上の重なりというユーザーの懸念は解消していない。nested名による限定で十分か、失効する一時viewをより正確に表す候補があるかを判断できる根拠が不足している |

## 一時View名の訂正・追加回答

On 2026-10-15, Astra found that the response columns only said “keep `Permutation`,” making it unclear what they referred to. Keep the existing responses as history and collect corrections or additional responses in the following section, which states the subject explicitly. The proposal itself does not change.

**対象：通常版が返す一時Viewの型名 `NextPermutations.Permutation` を維持する提案。**

This asks about the name of the temporary View type nested under `NextPermutations`, not the module or owner name. Respond “agree,” “agree with conditions,” “disagree,” or “hold,” with reasons or conditions as needed. Once additional responses are entered, use them when consolidating the temporary View name. Do not treat a missing response as agreement or withdrawal of an earlier response. Existing three-party agreement on module name `NextPermutationModule` is outside this additional response.

### ユーザー：一時View名の訂正・追加回答

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| 通常版一時Viewの型名 `NextPermutations.Permutation` を維持 | 同意 | 2026-10-15、ユーザーが上下の候補から選ぶ表と読み違えていたと説明し、対象確認後に「じゃ、同意で。俺の同意をとりつけたということで」と明示。Astraが転記。 |

### Claude姫：一時View名の訂正・追加回答

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| 通常版一時Viewの型名 `NextPermutations.Permutation` を維持 | 同意 | 2026-10-15 18:45 JST。型宣言の衝突はない（既存回答の調査どおり）。意味の重なりについては、名前より文書と診断で補う方が確実と判断した：現行sourceの型説明はすでに冒頭で「A temporary random-access view of one permutation」とし、次の`next()`での失効と`Array`へのcopyを明記している。失効時のprecondition messageも「Permutation view is no longer valid」でviewであることを示す。`CurrentPermutation`等へ変えても失効の契約が名前から伝わるわけではない点はAstraの理由に同意する。既存回答の「判断保留」は、ユーザーの懸念を未解消と扱ったためで、ユーザーが対象を確認して同意した後の回答としてこの欄を優先する。独立性：回答前にユーザーとV3の既存回答、ユーザーの追加回答を読んでいる |

### V3：一時View名の訂正・追加回答

| 対象 | 回答 | 理由・条件 |
| --- | --- | --- |
| 通常版一時Viewの型名 `NextPermutations.Permutation` を維持 | 同意 | 対象がtop-levelの一般名ではなく、`NextPermutations`に属する通常版一時Viewのnested型名だと明示されたことで、具体的な型名衝突と意味上の広さを区別できた。`NextPermutations.Permutation`は列挙主体と一件の結果の関係を表し、失効・copyの契約は型名の変更だけでは十分に伝わらないため、既存の型説明・使用例・診断で示す方が確実である。回答前にユーザーとClaude姫の追加回答を読んでいる |

## 受渡しと完了条件

When sending this to the three respondents, keep the proposal text fixed and limit each respondent’s edits to their own response section. The responsible Codex may transcribe explicit user statements. Do not rewrite another person’s response or the proposal. On 2026-10-15, all existing responses and the additional responses about the temporary View name were reviewed. All three additional responses agreed and are consolidated below.

1. Collect the three responses and conditions for each subject. Do not count missing or conditional responses as agreement.
2. Record for each subject whether agreement was reached and any unresolved conditions, then hand it to the existing final-decision task. Unanimity is not a completion condition for response collection; record it as an outcome.
3. After reviewing the record, ask for commit approval in `WAITING_USER`. Mark `DONE` once the commit is confirmed or the user decides a commit is unnecessary.
4. Completing this task does not mean that the names have been formally decided or renamed.

## 集約欄（担当Codex）

- Module name `NextPermutationModule`: all three agreed in their existing responses. This is separate from deciding a migration method or implementing the rename.
- Regular-mode temporary View name `NextPermutations.Permutation`: all three agreed in the additional responses. Prioritize each person’s additional response, which names the subject explicitly, and retain earlier disagreement or hold responses as history.
- Consolidator: Astra. On 2026-10-15, confirmed three-party agreement on both subjects. No unresolved conditions remain for these name proposals. Compatibility under the old name after a module rename was outside this agreement and remains with `PERM-070`.
- The three responses and consolidated result were prepared as input to `PERM-070`. The confirmation task is `DONE`. On 2026-10-15, the user authorized a commit to save the responses, consolidation, and completion record together. This remains separate from the formal naming decision and implementation of the rename.

## 参照資料

- [Round 1 ballot](PERMUTATION_PUBLIC_API_NAMING_BALLOT.md)
- [Round 2統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND2_REPORT.md)
- [Round 3統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md)
- [Round 4統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md)
- [名称決定正本](../../../Current/PUBLIC_API_NAMING_DECISIONS.md)
