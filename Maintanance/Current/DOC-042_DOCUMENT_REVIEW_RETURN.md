# DOC-042 — RedBlackTreeMultiSet 文書レビュー返却

担当：Claude（姫）。依頼：[正式依頼](RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md)。返却済み。ここから下がClaudeの編集範囲。

## 入力確認・実施範囲

固定入力20件のSHA-256を`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`と照合し、すべて一致（2026-10-16 20時台、HEAD `3780fb90`）。outline・日英本文・公開型コメント（`RedBlackTree<型>.swift`の型宣言前）を読み、必要な実装と既存のTest as Specへ当てた。例の実行結果は既存証拠`existing-examples-output.log`を参照し、新たなテスト・ビルドは実行していない。

範囲：`RedBlackTreeMultiSet.outline.md`全項目、日英本文（各12フェンス）、型コメント（7フェンス）。照合した実装：`RedBlackTreeMultiSet.swift` 291〜317行（`update(_:at:)`）・515・530行（`eraseUnique`・`eraseMulti`）、`+Combining.swift`（`insert(contentsOf:)`はSet・MultiSet・Sequenceの3形、`meld`/`melding`）。

## 指摘・修正案

1. **技術訂正（小）** `update(_:at:)`のメソッドコメント（`RedBlackTreeMultiSet.swift` 291〜298行）は「equivalent」と書くが、実装は`oldMember == newMember`（311行）で判定する。本文（日英）は「`==` の場合だけ」と正しい。Comparableで`==`と同値（`!(a<b) && !(b<a)`）が食い違う型では、メソッドコメントだけ読んだ利用者が誤る。最小修正案：メソッドコメントを「when `newMember == ` the current element」に揃える。
2. **文章（小）** 日本語本文に、訳されていない文の継ぎ足しが残っている。42行「 array literal、sequence、collection、rangeから初期化できます。」、89行「 insert系はSet、MultiSet、任意のsequenceを入力にできます。」（どちらも先頭に空白があり、前の文とつながっていない）。最小修正案：「配列リテラル、Sequence、Collection、Rangeから初期化できます。」「insert系はSet・MultiSet・任意のSequenceを受け取れます。」と整える。
3. **任意改善** 50行「hintは有効な位置を渡し…」は、どのAPIのhintかを名前で示していない（MultiMapは`insert(_:hint:)`と明記）。最小修正案：API名を添える。
4. **技術訂正（小・共通）** 型コメント29行の「Any declaration below…」が宙に浮いている（DOC-040の2と同じ）。

確認して問題がなかった点：多重度の演算（union a+b、intersection min、difference max(a−b,0)、symmetricDifference |a−b|）と`SetAlgebra`非適合の明記、`eraseUnique`/`eraseMulti`、`popFirst`等の空の扱い、`insert(contentsOf:)`のO(n log(m+n))と`meld`のO(n+m)・新しいstorage、K件一致のO(log n + K)。

製品の観察（範囲外、文書の誤りではない）：`update(_:at:)`は失敗する場合でも先に`ensureUnique()`を呼ぶので、共有中ならnilを返すときもCoW複製が起きる。過去のCoW-on-emptyと同じ形。必要なら別taskで。

## 検証と未確認

- 文書照合：本文・outline・型コメントの読み合わせ。
- 実装照合：該当APIの宣言・実装を`git grep`と読解で確認。
- 実行確認：新規実行なし。例の出力は既存証拠のログで確認。
- 推測：本文の意図（例の並び順など）に関する指摘は推測を含む旨を明記した。

## 返却

型別レビュー完了。指摘は技術訂正2件、文章1件、任意改善1件、範囲外の製品観察1件。公開を阻むものはない。Registryの状態は変更していない。


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 本レビューの入力はHEAD`3780fb907c1c1107582eec233b22439faa9cb872`の固定入力20件（7行目） | `Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`は版にある。`git diff --numstat 3780fb90… <版> -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources`で14ファイルに差分。差分を含むcommitは`f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8`（「resolve red-black tree review findings」）と`8a0c8769e4b1b2092a225fba3126ed2fb30d16c5`。分かるのは差分の所在まで。指摘ごとの対応・未対応は確かめておらず、レビューの有効・無効も判定しない | 対象の本文・英訳・型コメントの変更 |

指摘の再レビューはしていない（第4区切りの範囲外）。
