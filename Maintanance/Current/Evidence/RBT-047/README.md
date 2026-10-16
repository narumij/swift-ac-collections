# RBT-047 証拠

2026-10-16 / Claude（姫）。[正本](../../INDEX_UPDATE_FAILURE_COW_INVESTIGATION.md)のReturnから参照する。入力版はHEAD `f6e181b2`。

| ファイル | 内容 | 終了 |
| --- | --- | --- |
| `normal.log` | 通常構成。`swift test --filter IndexUpdateFailureCoWInvestigationTests` | 0（4件pass） |
| `reproduce-normal.log` | 通常構成で失敗時の期待を有効化。`-Xswiftc -DRBT047_EXPECT_NO_COPY_ON_FAILURE`を追加 | 1（5件fail、4件pass） |
| `compat.log` | 互換構成。`--scratch-path .build/rbt047-compat -Xswiftc -DCOMPATIBLE_ATCODER_2025` | 0（2件pass） |
| `reproduce-compat.log` | 互換構成で期待を有効化 | 1（1件fail、2件pass） |
| `fix-draft.diff` | 修正案。製品ソースには適用していない | — |
| `fix-draft-normal.log` | 一時コピーに修正案を当て、期待を有効化して通常構成で実行。filter `IndexUpdateFailureCoWInvestigationTests\|RedBlackTreeMultiSet\|RedBlackTreeMultiMap\|Multiset\|Multimap` | 0（373件pass） |
| `fix-draft-compat.log` | 同じく互換構成。filter `IndexUpdateFailureCoWInvestigationTests\|RedBlackTreeMultiMap\|Multimap` | 0（97件pass） |

一時コピー（`mktemp -d -t rbt047-fix-check`）と`.build/rbt047-compat`は実行後に削除した。ログ中の`/var/folders/...`はその一時コピーのパスである。
