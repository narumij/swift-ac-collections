# Claude採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。CodexからClaudeへの個別依頼と返却は
[CLAUDE_TASK.md](CLAUDE_TASK.md)で扱う。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codexは照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- Codexによる照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてClaudeが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。

## entry template

### `CP-YYYYMMDD-NNN` — <短い名称>

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_CODEX` / `RECONCILED`
- 発見元・ユーザー指示:
- 種別候補: `DISCOVERY` / `DECISION` / `EXECUTION`
- 対象範囲:
- 対象外:
- 完了条件:
- 前提・既存task候補:
- 担当候補・受入担当:
- 停止条件:
- 成果・検証: 未着手
- Codex reconciliation: 未処理

## 採番待ち

CP-004〜012は[照合済み履歴](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_3.md)へ保存。CP-013はOPS-059へ登録済み。以下の追加返却は受入待ちであり、新規採番不要。

### `CP-20261016-013` — Registry Studio：行き止まりの到達点の枝（MS-080）を近くに置く

- queue状態: `AWAITING_CODEX`（実施済み。一度凍結したが、同夜ユーザーのSafariで反映を確認「お、うごいた」。OPS-048への接続はAstra）
- 発見元・ユーザー指示: 2026-10-16夜。ユーザー「MS-080がすんごいとおいんで、これもう少し近くによせるルール修正ないかな？」「こっそりなおして」。
- 実施: `index.html`のレイアウト1か所（2行）。行き止まりの到達点の枝を「地図全体のいちばん下」ではなく「その枝が使う列のカードの下」に置く。MS-080はy=1153→457。差分は`Cache/Hime/ms080-layout.diff`と同じ。
- 検証: `verify.cjs`全項目PASS（exit 0）、fallbackなし、`sync.py --check`はHEADの差だけ。WebKitで描いて確認した。MS-070→MS-080の線がQUALITY-005のカードを斜めに横切る点は残る。
- 未解決: ユーザーのSafariでは位置が変わっていない。2026-10-16夜に調べた範囲: 作業ツリーの`index.html`に修正は入ったまま（Astraの`6cb0c88d`の後で上書きされていない）。描画経路は`graphLayout`1つだけで、localStorage等の保存状態や`layout-reference.json`（verify専用）は描画に使われていない。SafariのエンジンであるWebKitで同じファイルを描くと動いている。残る候補は、Safari側の古い表示か、開いているファイルの取り違え。ユーザーの画面は未確認。`index.html`の2行は未commitのまま残してある。戻すかどうかは再開時に決める。
- 解決: 21:58台に`index.html`が再書き込みされた（更新時刻21:58:44、修正は残存）後、ユーザーのSafariで動いた。Safariが再読み込みでも古い内容を出し続けた理由は特定していない。
- commit: していない。
- Codex reconciliation: 2026-10-16 Astra。OPS-059へFROZENで正式登録。Safariでの未解決と未commit差分を保持。受入・修正・再開は行わない。

### `CP-20261016-014` — ASan＋Death Testの子プロセスSIGABRT：原因はASanの`strip_env`

- queue状態: `RECONCILED`（調査済み。RBT-033の続きとしての接続・採否はAstra）
- 発見元・ユーザー指示: 2026-10-16夜。ユーザー「こっそりASanの調査してて」「リリースおわったらあすとらに報告できるようドキュメント準備してて」。その後「リリース候補確定でキャンセルになったから、未採番にして」。
- 種別候補: `DISCOVERY`
- 成果: [`Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md`](Current/Evidence/ASAN-strip-env-2026-10-16/ASAN_DEATH_TEST_STRIP_ENV_REPORT.md)（Probe・ログ4本つき）。
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
- 成果: [`Evidence/CANDIDATE-CI-BASELINE-GAP-2026-10-16/README.md`](Current/Evidence/CANDIDATE-CI-BASELINE-GAP-2026-10-16/README.md)。
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

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）

- [2026-10-16の照合記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16.md)（CP-20261015-007 → PERM-072）
- [2026-10-16の照合記録（2）](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_2.md)（CP-20261016-001〜003 → HIST-003・TEST-006・TEST-007）


## 同時変更の照合（2026-10-16 / Astra / OPS-044）

ユーザーの依頼により、`c1f2c7f9` → `203f3be0` → `e42d9630` の変更を照合した。

- `203f3be0`は姫の感想・評価と申請のcommitだが、Astraが編集中だったCP-004・008・009の照合結果も同じqueueファイル内で取り込まれている。commit範囲の重なりがあった。内容の作成担当は本文記録どおりで、commitの著者から判断担当を推定しない。
- `e42d9630`でRegistry・Rules・詳細正本・入口・Hime領域を接続した。最終状態では004→TEST-008 DONE、008→OPS-058 PROPOSED、009→OPS-044へ統合が一致する。重複採番、処理結果の消失、提案の無断実施は確認されなかった。
- OPS-057はRegistryでは受入済みDONEだったため、queueの旧「受入は未実施」表示を訂正した。元の依頼・返却本文は保持する。
- Studioの同期確認で内容の差はなく、生成時のHEAD・dirty表示のみ変化していた。今回再同期する。画面の実操作検証は今回含まない。

同じ共有ファイルを含めてcommitするときは、stage直前の差分に他担当の編集中の行が混ざっていないかを確認する。今回は最終内容が整合しているため、既存commitの書き換えは行わない。

## Astra照合・統合（2026-10-16、811b7a7aの返却を確認）

原entry本文は保持する。処理結果は本節を最新とする。

- CP-013：追加報告受領。OPS-059のSafari解決情報を訂正。凍結維持、修正の完了受入は保留。
- CP-014：RECONCILED。RBT-033正本へmacOS保存実験の証拠を受入・統合。固定版・適用範囲検証はRBT-049 PROPOSED。Linux CIへ適用しない。
- CP-015：RECONCILED。RELEASE-083/084へ統合。workflowとガイドを照合。契約差による停止は適切。未取得runの成功不在は断定しない。ユーザーの赤merge方針は伝達記録として保持。
- CP-016：RECONCILED。PERM-080 PROPOSEDとして正式登録、未着手。0.6.0後の範囲確定待ち。
