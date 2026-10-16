# DOC-040 — RedBlackTreeSet 文書レビュー返却

担当：Claude（姫）。依頼：[正式依頼](RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md)。返却済み。ここから下がClaudeの編集範囲。

## 入力確認・実施範囲

固定入力20件のSHA-256を`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`と照合し、すべて一致（2026-10-16 20時台、HEAD `3780fb90`）。outline・日英本文・公開型コメント（`RedBlackTree<型>.swift`の型宣言前）を読み、必要な実装と既存のTest as Specへ当てた。例の実行結果は既存証拠`existing-examples-output.log`を参照し、新たなテスト・ビルドは実行していない。

範囲：`RedBlackTreeSet.outline.md`全項目、`RedBlackTreeSet.ja.md`・`RedBlackTreeSet.md`（各12フェンス）、型コメント（7フェンス）。照合した実装：`RedBlackTreeSet+SetAlgebra.swift`（計算量O(n+m)の宣言）、`+Sequence.swift`（`sorted()`/`reversed()`は配列）、`+Index.swift`（`find`・`distance`）、`+BoundsExpression.swift`、`+RangeExpression.swift`（`containsSubrange`）、`RedBlackTreeSet.swift`（`count(of:)`・`erase(_:) -> Index`）。

## 指摘・修正案

1. **技術訂正（中）** `RedBlackTreeSet.ja.md` 122〜130行：`print(set[.start.advanced(by: 1)])` のコメントが `// 3`、`print(set[.lowerBound(5)])` が `// 5` になっている。実際の出力は `Optional(3)`・`Optional(5)`（`existing-examples-output.log`）。英語本文と型コメントは「Optional containing 3/5」に直っており、日本語だけ未同期。利用者は非Optionalが返ると誤読する。
   最小修正案：`// Optional(3)`・`// Optional(5)`（または英語と同じく「Optional containing 3」）。
2. **技術訂正（小）** 型コメント29行：「Any declaration below illustrates the type signature…」とあるが、型コメントには宣言のコードブロックがない（本文にはある）。DocCでは宣言はページ上部に出るので、宙に浮いた参照になる。最小修正案：型コメントからこの一文を削る。（MultiSet・MultiMapも同じ。DOC-044で共通化）
3. **任意改善** 日英で例の並びが違う：日本語は `set.insert(…)` の連続例が2番目、英語は4番目。内容・数は同じ。訳の見比べがしにくい。最小修正案：どちらかに揃える。
4. **判断事項（0.8.0候補）** outlineの「Searching and Accessing Elements」「Set Algebra」は「コード例必須」だが、両節とも例がない。0.6.0では掲載数固定の決定があるため、追加はせず0.8.0（DOC-038）の候補として記録する。outlineの「必須」と固定決定のどちらを優先するかの明記がDOC-034側にあるとよい。

確認して問題がなかった点：Index（他要素の挿入・削除で有効、削除で無効、slot再利用で復活しない、CoW後の世代、無関係indexは事前条件違反で検出保証なし）、Viewの直接変更と独立変数の区別、Bound一覧と`nil`・空View、計算量の前提（比較定数・CoW複製別）、集合演算4組の非破壊／`form`の区別、`erase(_:) -> Index`による逐次削除。

## 検証と未確認

- 文書照合：本文・outline・型コメントの読み合わせ。
- 実装照合：該当APIの宣言・実装を`git grep`と読解で確認。
- 実行確認：新規実行なし。例の出力は既存証拠のログで確認。
- 推測：本文の意図（例の並び順など）に関する指摘は推測を含む旨を明記した。

## 返却

型別レビュー完了。指摘は技術訂正2件、任意改善1件、0.8.0候補1件。公開を阻むものはない。Registryの状態は変更していない。
