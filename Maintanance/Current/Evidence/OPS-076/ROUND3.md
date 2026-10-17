# OPS-076 第3区切り：保留42件の浅い仕分け（入力版 `1175e583b1857819e9e0b07b83a1cb5fc8be657a`）

2026-10-17 / 姫（Opus 5.5）。第1区切り`CANDIDATES.md`（入力版`876d405b`）で保留にした42件だけが対象。すべて`git show <版>:…`で読んだ。

読んだ範囲：各文書の冒頭8行、候補にした文書は関係する節、現行Registryの行。分類は案で、Registryの状態・編集権限は変えていない。対象文書は編集していない。

## 元一覧との差

- 42件とも入力版に実在する（移動・消失なし）。
- 第1区切りで状態付きだった4件は、状態も担当も同じ：HIST-003 ACTIVE、OPS-068 PROPOSED、RBT-026 ACTIVE、PERM-080 PROPOSED。
- 「Registry行から参照なし」だった38件は、冒頭に関連task IDを書いたものが多い。
  - 現行Registryにある関連IDはHIST-001（ACTIVE）、OPS-048（ACTIVE）、PERM-064（ACTIVE）だけ。他は圧縮済み。
  - 圧縮済みtaskの最終状態は、文書本文の記述に頼った。Archived側の版ごとの状態は照合していない（最初に一致した行は古い版のこともあり、信用しなかった）。

## 分類の凡例

- (1) 浅い根拠追記の候補
- (2) 運用・提案・意図・履歴など、機械照合に向かない
- (3) 占有中・ユーザー判断待ち・ユーザー確定
- (4) 低コストでは確かめられない

## 一覧

| # | 文書 | 分類 | 理由 | 候補の主張・確認方法・結果（入力版） | 更新条件の案 |
| --- | --- | --- | --- | --- | --- |
| 1 | `AI_TECHNICAL_ORIENTATION.md` | (2) | 396行のオリエンテーション。判断の理由を説く長命な知識が中心 | — | — |
| 2 | `ASAN_DEATH_TEST_INVESTIGATION.md` | (1) | RBT-033の調査。11行目に短命な情報と長命な知識が混ざる（OPS-073の失敗例1） | 主張「現在のASan CIはLinuxでENABLE_DEATH_TESTSを指定していない」。`ci.yml`の384行には`--traits`なし、`candidate.yml`の152行付近のjobにはある（RBT-049の候補CI）。前半は一部古く、後半の知識は有効 | `.github/workflows/ci.yml`・`candidate.yml`のASan jobの変更 |
| 3 | `ASTRA_DECISION_TRACE_SUPPORT.md` | (2) | OPS-056の運用試作 | — | — |
| 4 | `BENCHMARK_TASK_NAME_MIGRATION.md` | (3) | 冒頭で現行正本`PERMUTATION_BENCHMARK_TITLE_MIGRATION.md`（PERM-064 ACTIVE・Codex）を指す履歴 | — | — |
| 5 | `BENCHMARK_USAGE_GUIDE.md` | (2) | 測定手順のガイド。正本はコードと明記 | — | — |
| 6 | `CLAUDE_QUEUE_RECONCILIATION_2026-10-16.md` | (3) | HIST-003 ACTIVE（Claude作成） | — | — |
| 7 | `CLAUDE_STARTUP_DOCUMENT_REVIEW.md` | (2) | OPS-054の運用見直し | — | — |
| 8 | `DECISION_ARCHIVE_PILOT.md` | (3) | OPS-068 PROPOSED。OPS-058のユーザー承認待ち | — | — |
| 9〜13 | `DOC-040`〜`DOC-044_DOCUMENT_REVIEW_RETURN.md` | (1) | 姫のレビュー返却5件。入力の版で効力が決まる | 主張「固定入力20件をHEAD `3780fb90`で照合」。`Evidence/DOC-033-2026-10-16/review-inputs.sha256.json`は版にある。`3780fb90`→版で`UserDocuments/.../Head`と`Sources`の14ファイルに差分あり（+32/−26）。レビュー後の修正かどうかは未確認 | レビュー対象（4型の本文・英訳・型コメント）の変更。差分が出たら、その指摘がまだ当てはまるか見る |
| 14 | `EXTERNAL_TYPE_EXTENSION_AUDIT.md` | (1)済 | OPS-074で追記・追記2・追記3があり、根拠と更新条件がそろっている | 追加は不要 | — |
| 15 | `GATE_DECISION_DIGEST_PROPOSAL.md` | (2) | 姫の提案（CP-20261016-006） | — | — |
| 16 | `HIST_002_EXPLORATION.md` | (3) | 親HIST-001はACTIVE・V3オーサーの範囲 | — | — |
| 17 | `INDEX_UPDATE_FAILURE_COW_INVESTIGATION.md` | (1) | RBT-047の調査。RBT-048（USER_ONLY、0.7.0で判断）の材料 | 主張「対象3実装のSHA-256は調査時と同じ」。版で計算すると`RedBlackTreeMultiSet.swift` `465e345f`・`RedBlackTreeMultiMap.swift` `10edbcd3`・`+Deprecated.swift` `531a69f6`で、本文35行目の先頭と一致。調査用testは版にあり、`RBT047_EXPECT_NO_COPY_ON_FAILURE`は4か所。再現結果は今も有効 | 3ファイルのどれかの変更。0.7.0の判断前にこの3つのhashだけ見ればよい |
| 18 | `JUDGMENT_COORDINATES_REVISION_RECEIPT.md` | (2) | TEST-008の受渡し確認の履歴。これに依存する判断なし | — | — |
| 19 | `MAINTENANCE_HEALTH_CHECK_2026-10-16.md` | (4) | 196行の点検記録で事実が多い。主張を1つに絞るには全体を読む必要があり、見込みを超える | 未確認 | — |
| 20 | `MAPPED_VALUES_VIEW_CONTRACT_DECISION.md` | (3) | RBT-026 ACTIVE、ユーザー判断 | — | — |
| 21 | `MEMOIZE_DEPENDENCY_INVESTIGATION.md` | (4) | 調べた対象がrepository外のローカルcheckoutで、commitでは固定できない | 未確認 | — |
| 22 | `PERFORMANCE_CI_CHANGE_GUIDE.md` | (2) | Codex側の手順・事例の正本 | — | — |
| 23 | `PERMUTATION_MODULE_MIGRATION_PLAN.md` | (1) | 「段階：計画」と書いてあるが、計画した構成はもう実現している | `Package.swift` 335行目に`NextPermutationModule`、346〜348行目に`PermutationModule`（`path: "Sources/_PermutationModule"`、依存は`NextPermutationModule`）。本文11・21〜22行目の構成と一致 | Permutation系targetの変更 |
| 24 | `PERMUTATION_PERFORMANCE_GAP_REVIEW.md` | (3) | PERM-080 PROPOSED、範囲の承認待ち | — | — |
| 25 | `PLACEMENT_EXCEPTION_SIMPLIFICATION_REVIEW.md` | (2) | OPS-053の運用検討 | — | — |
| 26 | `PUBLIC_API_NAMING_DECISIONS.md` | (3) | 採用済みの公開名の決定。ユーザー確定として扱い、編集しない | — | — |
| 27 | `PUBLIC_DOCUMENTATION_INITIAL_EDITION_CHECK.md` | (4) | 「基点`e76964c2`＋作業ツリー」が入力で、commitだけでは入力を固定できない | 未確認 | — |
| 28 | `RED_BLACK_TREE_BALANCED_DESIGN_INTENT.md` | (2) | ユーザーの設計意図 | — | — |
| 29 | `RED_BLACK_TREE_COMPARISON_DECLARATIONS_CONTEXT.md` | (2) | ユーザーの記憶による経緯。本文も「確定ではない」と書いている | — | — |
| 30 | `RED_BLACK_TREE_DOCUMENT_COMPLETION.md` | (4) | DOC-034の本文完成記録。9〜13と同じ対象だが、完成時点の版を冒頭から特定できない | 未確認（完成のcommitを特定すれば(1)にできる） | — |
| 31 | `RED_BLACK_TREE_DOCUMENT_REVIEW_ACCEPTANCE.md` | (2) | 9〜13の受入記録。根拠は返却側に置けば足りる | — | — |
| 32 | `RED_BLACK_TREE_DOCUMENT_REVIEW_REQUEST.md` | (2) | 依頼票の履歴（入力は作業ツリーで固定と明記） | — | — |
| 33 | `RED_BLACK_TREE_OUTLINE_AUDIT.md` | (1) | DOC-033。基準HEAD `1dc613ff`が冒頭にある | `1dc613ff`→版で、Outlinesと4型本文を含む20ファイルに差分あり（+816/−1820）。照合結果はかなり古い版に対するもの | Head/Outlinesか4型本文の変更。差分が大きいので「本文へ渡す結論」だけを見直す範囲にする |
| 34 | `RED_BLACK_TREE_TUNING_RESEARCH_DECISION.md` | (2) | マイルストーンへ移した決定の記録 | — | — |
| 35 | `REGISTRY_STUDIO_SYNC.md` | (1) | OPS-057。仕組みが今もあるかを安く確かめられる | `sync.py` 492行目に`--check`がある | `sync.py`の変更 |
| 36 | `RELEASE_CANDIDATE_BASELINE_INVESTIGATION.md` | (1) | RELEASE-083。後続のRELEASE-084正本には第1区切りで追記済み | 固定入力の候補`a5a39d12…`・比較元`139ffef8…`はどちらも解決できる。`139ffef8`はtag `0.5.3`と一致 | なし（固定入力の事実）。現行の判断は`RELEASE_CANDIDATE_BASELINE_FIX.md`の追記を見る |
| 37 | `RELEASE_CANDIDATE_COMMENT_CI.md` | (2) | RELEASE-080の履歴。冒頭で現行の残作業ではないと明記 | — | — |
| 38 | `RELEASE_SHAPING_WORKER_REQUEST_DRAFT.md` | (2) | 0.7.0向けの未発注の手順書ドラフト | — | — |
| 39 | `TASK_REGISTRY_APP_CLAUDE_ADVICE.md` | (2) | 姫の設計助言（OPS-050） | — | — |
| 40 | `TASK_REGISTRY_APP_DISCOVERY.md` | (4) | OPS-049。既存graph試験の知見で、照合先がrepository外の共有資料を含む | 未確認 | — |
| 41 | `TASK_REGISTRY_APP_PROTOTYPE.md` | (1) | OPS-051。「単一HTML＋JSON、`Maintanance/RegistryApp/`に置く」は今は事実が違う | 版の`RegistryApp/`にあるのは`index.template.html`・`serve.py`・`sync.py`など。生成物の`Maintanance/Cache/RegistryStudio/index.html`は`.gitignore`の21行目で管理外 | Studioの構成の変更 |
| 42 | `TASK_REGISTRY_LAYOUT_ADVICE.md` | (2) | 姫の設計助言（OPS-052） | — | — |

## 集計（42件と照合済み）

| 分類 | 件数 |
| --- | --- |
| (1) 候補 | 12件（2、9〜13の5件、17、23、33、35、36、41） |
| (1)済 | 1件（14） |
| (2) 不向き | 17件 |
| (3) 占有・判断待ち | 7件（4、6、8、16、20、24、26） |
| (4) 低コストでは未確認 | 5件（19、21、27、30、40） |

(2)の17件：1、3、5、7、15、18、22、25、28、29、31、32、34、37、38、39、42。

## 再実行

```sh
S=1175e583b1857819e9e0b07b83a1cb5fc8be657a; C=Maintanance/Current
git show $S:.github/workflows/ci.yml | grep -n 'sanitize address'; git show $S:.github/workflows/candidate.yml | grep -n 'sanitize address\|traits'
for n in RedBlackTreeMultiSet/RedBlackTreeMultiSet.swift RedBlackTreeMultiMap/RedBlackTreeMultiMap.swift 'RedBlackTreeMultiMap/RedBlackTreeMultiMap+Deprecated.swift'; do git show "$S:Sources/RedBlackTreeCollections/$n" | shasum -a 256; done
git diff --stat 3780fb90 $S -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources
git diff --stat 1dc613ff $S -- Maintanance/UserDocuments/RedBlackTreeCollections/Head Sources
git show $S:Package.swift | grep -n 'PermutationModule"'
git show $S:Maintanance/RegistryApp/sync.py | grep -n "'--check'"
git rev-parse a5a39d124eb4c63fa3fe3539f2024bedc367d1e9^{commit} 139ffef8db3eb75d118dbaecc8a1ec05d2e9894f^{commit} 0.5.3^{commit}
git ls-tree --name-only $S Maintanance/RegistryApp/; git check-ignore -v Maintanance/Cache/RegistryStudio/index.html
```
