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

照合済みCP-014〜016は[原文と統合結果](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_4.md)へ保存。CP-014→RBT-033追加証拠・RBT-049候補、CP-015→RELEASE-083/084、CP-016→PERM-080。未着手の候補はRegistryで扱う。

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
