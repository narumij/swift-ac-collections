# OPS-074 差し戻し対応（補足記録）

2026-10-17 / 姫（Opus 5.5）。依頼：`CANONICAL_INVENTORY_APPEND.md`「第2区切り受領・追加対応依頼」。旧結果（`shallow_check.py`・`shallow_check_result.json`・`README.md`）は残し、新しい結果として追加した。

## 1. 入力版の区別

- 新スクリプト `shallow_check_v2.py`（SHA-256 `1479888d882d48e265e8d8b513b4c3d38763ad20571e8609a07a4b25b841f68e`）は作業ツリーを読まない。文書・参照先の存在・履歴をすべて指定commitのgit treeから取る（`git show <commit>:path`、`git cat-file -e <commit>:path`、`git log <commit> -- path`）。
- 履歴探索の範囲：指定commitから到達できるcommitのみ（`--all`は使わない）。
- 結果には完全SHA・スクリプトのSHA-256・対象文書一覧を記録する。
- 旧版の問題（Astra指摘）：旧`shallow_check.py`は作業ツリーを読み、`input_commit`にHEADを書いていた。旧結果は「入力版`1bdbbd4f`＋当時の未コミット変更」の作業ツリーの値で、HEADの事実ではなかった。

## 2. 新しい結果（固定版）

| 結果ファイル | 入力commit（完全SHA） | 文書 | 参照（出現ごと） | 参照（文書×参照で重複除き） | hash（出現ごと／重複除き） |
| --- | --- | --- | --- | --- | --- |
| `result_v2_d6e6fab6.json` | `d6e6fab66fa3a4fda020080c8d401d3ec1cb9de4` | 72 | 272（存在246・`:行`付き存在2・不在で履歴あり16・履歴なし8） | 258（存在235・`:行`付き2・履歴あり15・履歴なし6） | 124／97（commit 80・blob 3・objectでない14） |
| `result_v2_10d4951f.json` | `10d4951fc88d34f55d1b99f0712504c0e8468354` | 76 | 291（存在264・`:行`付き2・履歴あり17・履歴なし8） | 273（存在250・`:行`付き2・履歴あり15・履歴なし6） | 131／103（commit 86・blob 3・objectでない14） |

- 各参照は出現行（`line`）・確認した主張（`claim`：参照先がそのcommitに存在する）・確認方法（`method`）を持つ。重複参照も出現ごとに残す。
- 追加4文書（d6e6fab6→10d4951f）：`CANONICAL_INVENTORY_APPEND.md`、`HIME_TRADE_NAME_DECISION.md`、`OPS_072_ACCEPTANCE.md`、`RECORD_LIFETIME_STUDY.md`。削除0。

## 3. 集計訂正の境界

- 第1区切りの報告値（72文書、不在23件、hash 97件中commit 80）は、固定版`d6e6fab6`を新スクリプトで読むと「重複除き：不在21＋`:行`付き2＝23」「hash重複除き97・commit 80」と一致した。旧集計の数は、この固定版の再実行で再現できた（根拠：`result_v2_d6e6fab6.json`）。
- 第2区切りの旧結果（76文書・272・100）は作業ツリー基準で、固定版`10d4951f`（273・103）とは一致しない。差は旧結果の後にcommitされた内容（第2区切りReturn・新規文書など）による。旧結果の数は「作業ツリー時点の値」として扱い、固定版の値は上表を使う。

## 4. 根拠の書き方の例（少数）

`EXTERNAL_TYPE_EXTENSION_AUDIT.md`の「棚卸し追記3」に、次の3例を、根拠（完全SHA・パス・行範囲・主張・確認方法）と更新条件の組で書いた。

1. 行を持たない事実（ファイルの存在）：本文64行のパス → パスと確認方法だけ。
2. 不在の主張：本文14行「`Result: @retroactive Comparable`は削除済み」→ `git grep -c "@retroactive Comparable" <SHA> -- Sources`が0件（不在の証明ではなく、そのcommitの`Sources`内で未発見）。
3. 行に依存する事実：本文23行「`Result._NodePtr`を`@usableFromInline package`へ縮小」→ `Sources/RedBlackTreeCollections/Implements/__tree/unsafe_node/unsafe_node+pointer+safe.swift`の322〜325行（そのcommitの行番号）。

## 5. 限界・未確認

- 存在の判定だけ。参照の意味上の正しさ、深い挙動は見ていない。
- 「履歴なし」は主候補パスでの結果（別の基準で書かれた参照は誤判定しうる）。
- hashの「objectでない14件」の正体（SHA-256先頭・外部repoの版）は本文の文脈による解釈。
- 作業ツリーに残る他者の未コミット変更（`CLAUDE_TASK.md`・Registry）は対象外（Current配下ではない）。
