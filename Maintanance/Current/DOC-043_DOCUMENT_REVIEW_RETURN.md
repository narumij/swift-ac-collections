# DOC-043 — RedBlackTreeMultiMap 文書レビュー返却

担当：Claude（姫）。依頼：[正式依頼](RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md)。返却済み。ここから下がClaudeの編集範囲。

## 入力確認・実施範囲

固定入力20件のSHA-256を`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`と照合し、すべて一致（2026-10-16 20時台、HEAD `3780fb90`）。outline・日英本文・公開型コメント（`RedBlackTree<型>.swift`の型宣言前）を読み、必要な実装と既存のTest as Specへ当てた。例の実行結果は既存証拠`existing-examples-output.log`を参照し、新たなテスト・ビルドは実行していない。

範囲：`RedBlackTreeMultiMap.outline.md`全項目、日英本文（各13フェンス）、型コメント（7フェンス）。照合した実装：`RedBlackTreeMultiMap.swift` 362〜384行（`insert(_:hint:)`）・`updateValue(_:at:)`、`+Subscript.swift`（key subscriptは`RedBlackTreeMappedValuesView`、pair範囲はindex range subscript）。

## 指摘・修正案

1. **技術（小）** `insert(_:hint:)`の説明（日本語111行、英語111行）は「有効かつ順序条件に合うhintの直前へ挿入できる」までで、順序条件に合わないhintでどうなるかがない。実装コメントは「Otherwise, the hint affects only performance」で、通常の位置に挿入される。また無効なhintは`fatalError(.invalidIndex)`（事前条件違反）。最小修正案：「順序条件に合わないhintでも通常の位置へ挿入し、hintは性能にだけ効く。無効なhintは事前条件違反」と一文足す。
2. **文章（小）** 日本語47行に、訳されていない継ぎ足し「 array literal、dictionary literal、`init(keysWithValues:)` は重複キーを保持し…」が残る（MultiSetと同じ形）。最小修正案：日本語に整える。
3. **技術訂正（小・共通）** 型コメント29行の「Any declaration below…」が宙に浮いている（DOC-040の2と同じ）。

確認して問題がなかった点：key subscriptが単一値ではなく`RedBlackTreeMappedValuesView`を返すこと、pair走査は`map[map.equalRange(key)]`であること、mapped Viewでの値更新・`swapAt`・削除（削除はpairも取り除く）、キーは変更しないこと、`erase(exactly:)`への言及、同一キー内が挿入順であること、Viewを別変数へ取り出す場合と直接subscript変更の区別。

## 検証と未確認

- 文書照合：本文・outline・型コメントの読み合わせ。
- 実装照合：該当APIの宣言・実装を`git grep`と読解で確認。
- 実行確認：新規実行なし。例の出力は既存証拠のログで確認。
- 推測：本文の意図（例の並び順など）に関する指摘は推測を含む旨を明記した。

## 返却

型別レビュー完了。指摘は技術1件、文章1件、共通の技術訂正1件。公開を阻むものはない。Registryの状態は変更していない。
