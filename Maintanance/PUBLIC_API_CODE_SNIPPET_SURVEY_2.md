# リポジトリ公開APIコードスニペット候補アンケート第2弾

## 対象task

`DOC-020` — リポジトリ公開APIコードスニペット候補メソッドTOP10アンケート第2弾

## 目的と対象

このリポジトリの公開API全体から、各公開APIのコメントドックへ短い利用コードを載せる効果が高い箇所を
選ぶ。特定moduleを除外しない。内部APIとtest専用APIは公開APIではないため対象外とする。

## 実施方法

- Codexは`PUBLIC_API_CODE_SNIPPET_SURVEY_2_CODEX.md`へ回答する。
- Claudeは`PUBLIC_API_CODE_SNIPPET_SURVEY_2_CLAUDE.md`へ回答する。
- 回答fileを分ける目的は同時編集の競合回避である。
- 公開宣言と現在のコメントドックを中心に判断し、不明な挙動だけtestで確認する。
- 各候補にsymbol、順位、利用者の疑問、示すべき最小の振る舞い、既存説明だけでは不足する理由を書く。

両回答の確定後、Codexが一致・相違を整理して本書へ記録する。

## 回答状態

- Codex回答: 完了
- Claude回答: 完了、Codex受入済み
- まとめ: 完了

## 両回答のまとめ

両者とも、公開APIの説明文を増やすより、呼び出し方と結果を短く並べることで独自契約が早く伝わる
箇所を優先した。特に次の5観点は共通して上位となった。

1. RedBlackTreeの境界式による単一点・範囲アクセス
2. `RedBlackTreeMultiMap.subscript(key:)`が返す可変Values View
3. `Collection.nextPermutations()`の開始位置と列挙範囲
4. `OptionalArray1D.subscript(_:)`の未設定・設定・`nil`解除
5. BareArrayの非対称shapeを使った軸順と連鎖subscript

RedBlackTreeでは、CodexはDictionaryのdefault subscript、insert-only契約、MultiSetの値View、meldingを
挙げた。Claudeは近傍探索、`eraseUnique`／`eraseMulti`、境界式の相対移動、保持Indexによる削除を
挙げた。いずれも候補として保持し、実際の掲載順位やスニペット作成は後続taskで決める。

Claudeの確認では、RedBlackTree各型の既存スニペットに現在の公開名と一致しない
`.advance(by:)`／`.endIndex`が残っており、現在の`.advanced(by:)`／`.end`へ直す必要がある。また、
`RedBlackTreeSet.upperBound(_:)`の例がSetに重複値を含めている。これらは新規スニペット候補とは別の
既存コメント修正候補として記録する。

## 受入

2026-10-10、両回答がリポジトリ全体の公開APIを対象とし、各候補にsymbol、利用者の疑問、最小の
振る舞い、既存説明との差が記載されていることを確認した。回答fileの分離は同時編集の衝突回避として
扱い、相互未読や独立性を受入条件にはしていない。アンケート第2弾を完了とする。

## 対象外

スニペットの実装、掲載場所の決定、公開コメントや利用者向け文書の変更は別taskとする。
