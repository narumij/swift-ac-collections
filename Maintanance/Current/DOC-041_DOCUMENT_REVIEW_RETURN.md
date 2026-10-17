# DOC-041 — RedBlackTreeDictionary 文書レビュー返却

担当：Claude（姫）。依頼：[正式依頼](RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md)。返却済み。ここから下がClaudeの編集範囲。

## 入力確認・実施範囲

固定入力20件のSHA-256を`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`と照合し、すべて一致（2026-10-16 20時台、HEAD `3780fb90`）。outline・日英本文・公開型コメント（`RedBlackTree<型>.swift`の型宣言前）を読み、必要な実装と既存のTest as Specへ当てた。例の実行結果は既存証拠`existing-examples-output.log`を参照し、新たなテスト・ビルドは実行していない。

範囲：`RedBlackTreeDictionary.outline.md`全項目、日英本文（各6フェンス）、型コメント（6フェンス）。照合した実装：`+Sequence.swift`（`keys`は遅延の`Keys`、`values`は`_modify`付きの`RedBlackTreeMappedValuesView`、`sorted()`/`reversed()`は配列）、`+Index.swift`（`firstIndex(of: Key)`・`index(forKey:)`）、`+Initialize.swift`・`+Combining.swift`と`UnsafeTreeV2+InsertRange.swift` 114・283行（重複時の`combine(既存値, 入力値)`の引数順）。

## 指摘・修正案

1. **構成（中）** 日英とも「Declaration」節にコードブロックがない（`RedBlackTreeDictionary.ja.md` 5行、`.md` 5行）。outlineは「コードブロック必須」で、Set・MultiSet・MultiMapにはある。最小修正案：他3型と同じ宣言断片（`import AcCollections` と `struct RedBlackTreeDictionary<Key: Comparable, Value>`）を置く。ただしフェンスが1つ増えるので、0.6.0の掲載数固定に当たるかはAstra・ユーザーの判断。
2. **技術訂正（中）** 「Performance」節に、outlineの「Viewの作成は要素配列をコピーしないが、独立したViewの変更でCoWが発生する場合がある」がない（日英とも。英語本文125〜128行付近は空行だけが残る）。Set・MultiSet・MultiMapにはある。最小修正案：他3型と同じ一文を足す（文の追加で、例の追加ではない）。
3. **判断事項（0.8.0候補）** outlineで「コード例必須」の「Creating a Dictionary」「Searching and Accessing Elements」「Transforming and Combining Dictionaries」「Iterating over Keys and Values」に例がない。掲載数固定のため、0.8.0候補として記録する。

確認して問題がなかった点：default付きsubscriptの読み取りは挿入せず、変更時は既定値を挿入してから変更すること。`init(_:uniquingKeysWith:)`・`merge`の結合クロージャが既存値・入力値の順（実装で確認）。`count(forKey:)`が0か1。`updateValue`の戻り値。`filter`/`mapValues`/`compactMapValues`のO(n)とクロージャ費用の別記。`merge`のO(n log(m+n))。Index・View・Boundの記述は他型と一致。

## 検証と未確認

- 文書照合：本文・outline・型コメントの読み合わせ。
- 実装照合：該当APIの宣言・実装を`git grep`と読解で確認。
- 実行確認：新規実行なし。例の出力は既存証拠のログで確認。
- 推測：本文の意図（例の並び順など）に関する指摘は推測を含む旨を明記した。
- 未確認：`init(grouping:by:)`の配列が入力順であることは、実装の読解だけで、実行では確かめていない。

## 返却

型別レビュー完了。指摘は構成1件（判断要）、技術訂正1件、0.8.0候補1件。公開を阻むものはない。Registryの状態は変更していない。


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 本レビューの入力はHEAD`3780fb907c1c1107582eec233b22439faa9cb872`の固定入力20件（7行目） | `Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`は版にある。`git diff --numstat 3780fb90… <版> -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources`で14ファイルに差分。差分を含むcommitは`f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8`（「resolve red-black tree review findings」）と`8a0c8769e4b1b2092a225fba3126ed2fb30d16c5`。分かるのは差分の所在まで。指摘ごとの対応・未対応は確かめておらず、レビューの有効・無効も判定しない | 対象の本文・英訳・型コメントの変更 |

指摘の再レビューはしていない（第4区切りの範囲外）。
