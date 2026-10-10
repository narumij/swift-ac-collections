# コードスニペット候補アンケート

## 対象task

`DOC-019` — コードスニペット候補メソッドTOP10アンケート

## 目的

BareArray、OptionalArray、Permutationの公開APIについて、利用者向けコードスニペットを追加する効果が
高いsymbolを、二つのAIの回答から選ぶ。既存コメントの正誤監査ではなく、例示による理解支援の
優先順位を決めるための調査である。

## 実施方法

CodexとClaudeが「コードスニペットがあると理解・誤用防止・採用判断に特に効くメソッド」を各10件まで
順位付けする。回答fileは同時編集の競合を避けるために分ける。

- Codexは`CODE_SNIPPET_SURVEY_CODEX.md`だけへ回答する。
- Claudeは`CODE_SNIPPET_SURVEY_CLAUDE.md`だけへ回答する。
- 共通の本書、source、testは両者ともread-onlyとし、同時作業時のwrite競合を避ける。

各回答はsymbol、順位、想定する利用者の疑問、スニペットで示すべき最小の振る舞い、既存説明だけでは
不足する理由を記載する。単に代表的なAPIであることや、全面的なtutorialが欲しいことは選定理由にしない。
initializer、subscript、operatorも候補に含めてよいが、同一パターンの次元違いを重複させる場合は理由を示す。

両回答の確定後、Codexが2回答の一致・相違を本書へ整理し、統合TOP10と圏外だが意見が割れた候補を返す。

## 回答状態

- Codex回答: 2026-10-10確定
- Claude回答: 2026-10-10確定
- 統合: 2026-10-10完了

## 統合TOP10

両回答で同じ利用場面を挙げた候補を優先し、次元違いは例の必要性が別に説明できる場合だけ残した。

1. `Collection.nextPermutations()` — 現在順以後だけを返すことと、全順列には事前sortが必要なこと。
2. `OptionalArray1D.subscript(_:)` — 初期未設定、値の設定、`nil`による未設定化。
3. `BareArray2D.subscript(_:)` — `array[y][x]`の軸順と通常の連鎖書き込み。
4. `OptionalArray2D.subscript(_:)` — View越しでもOptional slotの読み書きと解除が働くこと。
5. `BareArray.init(count:_:)` — closureによる逐次生成と0要素時の非呼出し。
6. `BareArray4D.init(repeating:size0:size1:size2:size3:)` — 数字名の軸と`array[w][z][y][x]`の対応。
7. `OptionalArray1D.removeAll()` — storageを保持したまま全slotを未設定へ戻して再利用できること。
8. `NextPermutationsSequence.Permutation.subscript(_:)` — sourceと独立した0始まりのIndex。
9. `NextPermutationsSequence.Iterator.next()` — 手動列挙、途中終了、取得済み結果の安定性。
10. `OptionalArray4D.init(size0:size1:size2:size3:)` — 4Dの軸順と全slotが未設定で始まること。

## 一致と相違

- 強い一致: `nextPermutations()`、OptionalArray1D subscript、BareArray2D連鎖subscript、
  OptionalArray2D連鎖subscript、closure initializer、BareArray4D、`removeAll()`、Permutationの0始まりIndex。
- IteratorはCodexがcopy独立性を`makeIterator()`で、Claudeが手動列挙と値安定性を`next()`で選んだ。
  スニペットの入口として直接操作する`next()`へ統合した。
- Claudeの`BareArray`型と`~Copyable`は重要だが、ユーザー指定がメソッドTOP10なので統合順位から外した。
  型ページ用スニペット候補として保持する。
- CodexだけがOptionalArray4Dを選び、4Dでは初期未設定と軸順を同時に示す価値があるため10位に残した。

本アンケートは公開宣言とコメントを中心に判断した。testは、スニペットへ書く挙動が公開契約として
確定できない場合の事実確認にだけ使うものとし、候補選定の必須入力にはしない。

## 対象外

- source、公開コメント、利用者向け文書へのスニペット追加
- 掲載場所や文面の最終決定
- RedBlackTree系、互換mode、内部API、test専用API

採用するスニペットと掲載場所は、アンケート受入後に別taskとして扱う。
