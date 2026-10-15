# Permutation公開API名称 — Astra最終提案・三者合意確認

作成者：Astra。作成日：2026-10-15。確認task：`PERM-072`。

## 位置づけ

本書は、ユーザーから依頼された最終提案と、ユーザー・Claude姫・V3の三者による合意確認の正本である。
Astraは提案作成者であり、三者の回答者には含めない。現在は提案・三者未回答。
本書の作成を依頼したこと、過去の点数、AI同士の一致を、提案への同意として記録しない。
公開名の最終決定は既存の`PERM-070`と`PUBLIC_API_NAMING_DECISIONS.md`で扱う。

## 最終提案

| 判断対象 | Astraの提案 | 変更 |
| --- | --- | --- |
| Module名 | `NextPermutationModule` | 現行`PermutationModule`から変更を提案 |
| 通常版一時view | `NextPermutations.Permutation` | leaf名`Permutation`を維持 |

通常入口`nextPermutations()`、通常owner`NextPermutations`、borrowed入口`borrowedNextPermutations()`、
borrowed owner`BorrowedNextPermutations`、generic parameter`Element`は、既存の暫定確定を前提とし再採点しない。
`Element`の実sourceでのcompile・DocC確認という条件は維持する。

### Module名の理由

現在の中心入口とownerが`nextPermutations()`／`NextPermutations`にまとまっているため、moduleも同じ機能の語幹に揃える。
具体化していない将来のPermutation APIを収容する広さより、現在の機能との対応を優先する。
互換modeに全順列APIがあることは留意するが、中心機能を表す名称を妨げる決定的な理由とはしない。

`Next`だけで「初回に現在の並びを含み、その後は辞書順後続だけ」という契約が伝わるとは主張しない。
この契約は文書と使用例で説明する。module改名の移行費用は存在し、無料の変更とは扱わない。

### 一時view名の理由

`NextPermutations.Permutation`で、列挙するものと一件の結果という関係が読める。
`CurrentPermutation`の`Current`は「常に現在の状態を映すもの」とも読める。一方、現行viewは次の状態へ追従せず、
次の`next()`で失効する。その違いを`Current`の追加だけで明確にできるとは考えない。
これはAstraの意味上の評価であり、利用者実験で誤読率を測定した結果ではない。

一時viewであること、次の`next()`で失効すること、保存には`Array`等へのcopyが必要なことは、
型の冒頭説明・使用例・診断で伝える。名前に寿命契約を詰め込みすぎず、`Permutation`を維持する。

## 固定する契約と対象外

- 初回は入力の現在の並び、その後は辞書順後続だけを返す。
- 通常版は所有bufferの一時viewを返し、失効をruntimeで検査する。
- borrowed版は所有bufferからSpanを貸し、compilerで寿命を検査する。
- ownerは非コピー型、非Sequenceである。
- 今回は二つの名称への合意確認。rename実行、公開契約変更、既定経路変更、凍結taskの再開は行わない。
- module改名時に旧名の互換targetを残すかは本提案では決めない。名称に同意しても移行方式への同意とはしない。既存の最終決定taskでユーザーが明示し、実装前に確定する。

## 三者への確認方法

再採点ではなく、上記提案を採用することに同意できるかを、対象ごとに回答する。
回答は「同意」「条件付き同意」「不同意」「判断保留」のいずれかと、必要な理由・条件を記入する。
同意を求めるために既存の反対意見を削らない。異論が残った場合は何が未解決かを明記し、
多数決や追加ラウンドの自動開催で解消したことにしない。

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
| `NextPermutationModule` | 未回答 | |
| `Permutation`維持 | 未回答 | |

## 受渡しと完了条件

三者へ渡す際は本書の提案本文を固定し、各回答者の変更範囲を本人の回答欄に限定する。
ユーザー回答は明示された発言を担当Codexが転記してよい。他者の回答・提案本文は書き換えない。
現時点では正本とtaskを用意したのみで、他の会話への送信・実行依頼はしていない。

1. 三者の各対象への回答と条件が揃う。未回答や条件付き回答を合意済みと数えない。
2. 対象ごとに合意の成立・不成立、未解決条件を記録し、既存の最終決定taskへ渡す。全員一致は回答収集taskの完了条件ではなく、結果として区別する。
3. 記録確認後は`WAITING_USER`でコミット許可を尋ねる。コミットを確認するか、ユーザーがコミット不要と判断したら`DONE`にする。
4. 本taskの完了は名称の正式決定やrename完了を意味しない。

## 集約欄（担当Codex）

未集約。三者未回答。

## 参照資料

- [Round 1 ballot](PERMUTATION_PUBLIC_API_NAMING_BALLOT.md)
- [Round 2統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND2_REPORT.md)
- [Round 3統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND3_REPORT.md)
- [Round 4統合](PERMUTATION_PUBLIC_API_NAMING_SCORE_ROUND4_REPORT.md)
- [名称決定正本](PUBLIC_API_NAMING_DECISIONS.md)
