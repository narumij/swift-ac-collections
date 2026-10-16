# 照合済みqueue原文：CP-014〜016

2026-10-16 / Astra。元：CLAUDE_PENDING_TASKS.md。履歴であり現行指示ではない。状態と成果は正式taskへ統合済み。

### `CP-20261016-014` — ASan＋Death Testの子プロセスSIGABRT：原因はASanの`strip_env`

- queue状態: `RECONCILED`（調査済み。RBT-033の続きとしての接続・採否はAstra）
- 発見元・ユーザー指示: 2026-10-16夜。ユーザー「こっそりASanの調査してて」「リリースおわったらあすとらに報告できるようドキュメント準備してて」。その後「リリース候補確定でキャンセルになったから、未採番にして」。
- 種別候補: `DISCOVERY`
- 成果: [`Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md`](../Current/Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md)（Probe・ログ4本つき）。
  - macOSのASan runtimeは`strip_env`（既定で有効）で、自分のdylibを`DYLD_INSERT_LIBRARIES`から外す。そのため、Swift Testingのexit test子プロセスがASan未挿入で起動し、SIGABRTになる。
  - `ASAN_OPTIONS=strip_env=0`を付けると、最小package 3件（heap-buffer-overflowの検出を含む）と、写しのdeath test 213件がすべて成功した。既定のままでは213件中issue 360件。
- 対象外: 製品・Tests・CI・Package.swiftの変更。Linuxでの確認。全体suiteのASan実行。
- 未確認: Linux、全体suite、`RedBlackTreeInternalCoverageTests`、写しのcommit（22:20頃の作業ツリー）。報告時に対象commitで再実行するのがよい。
- 担当候補・受入担当: 調査は姫 / RBT-033への接続、CI反映の採否、受入はAstra。
- commit: していない。
- Codex reconciliation: 2026-10-16 Astra。末尾の照合・統合節を参照。

### `CP-20261016-015` — 候補CIの比較元が前回release tagだったことによる移行の穴

- queue状態: `RECONCILED`（読み取り調査済み。RELEASE-083・084への接続はAstra）
- 発見元・ユーザー指示: 2026-10-16夜。ユーザー「CIの移行ミスってる線でも調査ひつようかもな」「その線でまだ調べる余地あるなら、しらべてもらって、タスクに載せにくいなら未採番でも」。
- 種別候補: `DISCOVERY`
- 成果: [`Evidence/CANDIDATE-CI-BASELINE-GAP-2026-10-16/README.md`](../Current/Evidence/CANDIDATE-CI-BASELINE-GAP-2026-10-16/README.md)。
  - 性能CI変更ガイドの段階手順は、比較元が`main`の通常CIを前提にしていた。候補CIの比較元は最新release tagなので、0.5.3以後の切替（10-12のworkload追加、10-12のPermutation契約の変更）が候補CIには届いていなかった。
  - RELEASE-083の8件欠落と、RELEASE-084のPermutation契約差は、同じ根から出ている。
  - 候補CIの性能比較は、新設（`67cbc78e`、10-10）から一度も成功した記録がない。RELEASE-080の初回失敗も、同じ原因の可能性が高い（推定、ログは未確認）。
  - 赤黒木の18件は、比較の契約が同じと考えてよい（製品差は`31aa2f07`だけで、測定経路の外）。
- 対象外: workflow・Benchmarks・ガイドの変更。比較元の規則の決定。
- ユーザーの方針（2026-10-16夜、会話）: 0.5.3のPermutationは世代の確認がない旧実装で、方式差は「仕方ない」。ユーザーが赤のままmergeし、その後チューニングの余地を探し直す。（ユーザー特権の判断。記録の正本化はAstraへ）
- 担当候補・受入担当: 調査は姫 / 接続・方針の整理はAstra / 比較元の規則と0.6.0の扱いはユーザー。
- commit: していない。
- Codex reconciliation: 2026-10-16 Astra。末尾の照合・統合節を参照。

### `CP-20261016-016` — Permutation性能の落ち穂ひろい（提案）

- queue状態: `RECONCILED`（提案の記録のみ。着手しない）
- 発見元・ユーザー指示: 2026-10-16夜。CP-015のあと、ユーザー「俺が赤でマージして、再度チューニング余地を探す道のりだな」「ある種りせっとだし」「できれば、パーミュテーションのパフォーマンス落ち穂ひろいタスク提案もついかしてほしいわ」。
- 種別候補: `DISCOVERY`（取りこぼし探し。採否と実装は別）
- 背景:
  - 0.5.3は世代の確認がない旧実装、候補はruntime-check版（`9ff515c9`）で、性能の比較はここで一度リセットされる。
  - 0.6.0のreleaseが、runtime-check版の新しい比較元になる。
- 対象範囲（案）:
  1. 0.6.0（runtime-check版）を基準に、通常CIの3件（batched 2件、end-to-end 1件）と品質評価用の測定を測り直す。
  2. 0.5.3（旧実装）・borrowed版（Swift 6.4）・C++との差を、契約の違いを分けたまま並べる。旧比較を回帰の基準にはしない（性能CI変更ガイドの「Permutation実装方式の切替」）。
  3. runtime-checkの費用がどこにかかっているかを、機械語とプロファイルで見る。世代確認の位置、inline化、ループ内の冗長な確認、境界検査との重なりなど。
  4. 契約を変えずに取り戻せる候補を一覧にする。契約を変える案（確認を弱めるなど）は、別にユーザー判断へ回す。
- 進め方の下敷き: [[project_rbt_tuning_gap_hunt]]（赤黒木の取りこぼし探し）と同じ手法。測定は交互計測と機械語比較で判断する（コード配置だけで±20%動くため）。
- 既存の材料: `Benchmarks/QualityAssessment/macOS/Permutations/`（旧比較、runtime View版対C++、borrowed版対C++の生JSONとPNG）。`Quality/0.6.0-1/PermutationModule/CurrentQualityAssessment.md`の「次回品質評価への性能引継ぎ」（旧PERM-043・044は除外済み。比率候補は採用済みとして扱わない）。
- 対象外: 公開契約の変更、閾値の変更、0.6.0の判定。
- 前提・既存task候補: 0.6.0 release（新しい比較元）。PERM-064（benchmark表示名の移行）とは測定名が重なるので、順番を確認する。
- 担当候補・受入担当: 調査は姫かCodex / 受入はAstra / 採否はユーザー。
- 停止条件: 契約を変えないと取り戻せない差だけが残ったら、理由を記録して止める。
- 成果・検証: 未着手
- Codex reconciliation: 2026-10-16 Astra。末尾の照合・統合節を参照。


## Astra照合・統合（2026-10-16、811b7a7aの返却を確認）

原entry本文は保持する。処理結果は本節を最新とする。

- CP-013：追加報告受領。OPS-059のSafari解決情報を訂正。凍結維持、修正の完了受入は保留。
- CP-014：RECONCILED。RBT-033正本へmacOS保存実験の証拠を受入・統合。固定版・適用範囲検証はRBT-049 PROPOSED。Linux CIへ適用しない。
- CP-015：RECONCILED。RELEASE-083/084へ統合。workflowとガイドを照合。契約差による停止は適切。未取得runの成功不在は断定しない。ユーザーの赤merge方針は伝達記録として保持。
- CP-016：RECONCILED。PERM-080 PROPOSEDとして正式登録、未着手。0.6.0後の範囲確定待ち。
