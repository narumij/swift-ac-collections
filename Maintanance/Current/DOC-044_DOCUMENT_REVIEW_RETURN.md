# DOC-044 — 4型横断 文書レビュー返却

担当：Claude（姫）。依頼：[正式依頼](RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md)。返却済み。ここから下がClaudeの編集範囲。

## 入力確認・実施範囲

固定入力20件のSHA-256を`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`と照合し、すべて一致（2026-10-16 20時台、HEAD `3780fb90`）。outline・日英本文・公開型コメント（`RedBlackTree<型>.swift`の型宣言前）を読み、必要な実装と既存のTest as Specへ当てた。例の実行結果は既存証拠`existing-examples-output.log`を参照し、新たなテスト・ビルドは実行していない。

範囲：DOC-040〜043の4件を横断し、同じ契約の表現差と意図した型差を分けた。4型の見出し・フェンス数（日英一致：Set 12、Dictionary 6、MultiSet 12、MultiMap 13）を機械的に比べた。

## 指摘・修正案

**公開阻害：なし。**

**技術訂正（共通修正候補としてまとめる）**

1. **型コメントの宙に浮いた一文**（Set・MultiSet・MultiMapの型コメント29行）：「Any declaration below illustrates…」と書くが、型コメントに宣言ブロックはない。3型同時に削る。本文側（日英）は宣言ブロックがあるので残してよい。
2. **Optionalを返すBoundのコメント**：日本語のSet本文だけが `// 3` `// 5`。ほかの3型の日本語本文と全型の英語・型コメントは「Optional containing …」。Setの日本語を同じ書き方に揃える（DOC-040の1）。
3. **Performanceの「Viewの作成とCoW」の一文**：Dictionaryだけ欠けている（DOC-041の2）。ほかの3型と同じ文を入れる。
4. **`update(_:at:)`のメソッドコメントの「equivalent」**（MultiSet）：実装は`==`。MultiMapの`updateValue(_:at:)`は値だけを変えるので該当しない（DOC-042の1）。

**文章（共通の形）**

5. MultiSet 42・89行、MultiMap 47行の日本語に、訳されていない継ぎ足しの一文が残る。同じ作業で一度に整える。

**意図した型差（指摘ではない）**

- 一意型（Set・Dictionary）と重複型（MultiSet・MultiMap）で、`count(of:)`/`count(forKey:)`が0か1か、K件のO(log n + K)行の有無、`eraseUnique`/`eraseMulti`の有無が違う。
- Dictionaryの`merge`はO(n log(m+n))、MultiSet・MultiMapは`insert(contentsOf:)`のO(n log(m+n))と`meld`のO(n+m)の2系統。Setは集合演算をO(n+m)としている（実装の計算量コメントと一致）。
- Dictionaryの`values`は可変のMappedValuesView、MultiMapのkey subscriptもMappedValuesView。名前が同じで用途が違うのは意図どおりと読める。

**判断事項（ユーザー・Astra）**

6. **outlineの「コード例必須」と0.6.0の掲載数固定の衝突**：Setの2節、Dictionaryの4節で、outlineが必須とする例がない。0.6.0では足さず、0.8.0（DOC-038）の候補とする扱いでよいか、DOC-034か本文の注記に一行あるとよい。
7. **Dictionaryの宣言ブロック**：構成上は必須だが、フェンスが1つ増える。掲載数固定の対象に宣言断片を含めるかの判断が要る（DOC-041の1）。

**任意改善**

8. Setの日英で例の並び順が違う（DOC-040の3）。
9. MultiSetのhint説明にAPI名を添える（DOC-042の3）。

## 検証と未確認

- 文書照合：本文・outline・型コメントの読み合わせ。
- 実装照合：該当APIの宣言・実装を`git grep`と読解で確認。
- 実行確認：新規実行なし。例の出力は既存証拠のログで確認。
- 推測：本文の意図（例の並び順など）に関する指摘は推測を含む旨を明記した。
- 横断の比較は見出しとフェンス数までを機械的に、文意は読み比べで行った。

## 返却

5件の返却を揃えた。公開阻害0件、共通の技術訂正4件、文章1件、判断事項2件、任意改善2件。範囲外の製品観察1件（MultiSet `update(_:at:)`の失敗時のCoW）。本文・outline・ソース・Registryは変更していない。commitしていない。作業はここで終了する。


## 根拠と更新条件の追記（2026-10-17 / 姫・Opus 5.5 / OPS-076第4区切り）

入力版`1175e583b1857819e9e0b07b83a1cb5fc8be657a`。本文・原返却は変えていない。確認は`git show <版>:…`等の固定treeの読み取りだけで、実行・再レビューはしていない。

| 主張 | 確認方法と結果（成立範囲） | 更新のきっかけ |
| --- | --- | --- |
| 本レビューの入力はHEAD`3780fb907c1c1107582eec233b22439faa9cb872`の固定入力20件（7行目） | `Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`は版にある。`git diff --numstat 3780fb90… <版> -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources`で14ファイルに差分。差分を含むcommitは`f6e181b2ab31dcd17c51c11236a6b5dd4b1024b8`（「resolve red-black tree review findings」）と`8a0c8769e4b1b2092a225fba3126ed2fb30d16c5`。分かるのは差分の所在まで。指摘ごとの対応・未対応は確かめておらず、レビューの有効・無効も判定しない | 対象の本文・英訳・型コメントの変更 |

指摘の再レビューはしていない（第4区切りの範囲外）。
