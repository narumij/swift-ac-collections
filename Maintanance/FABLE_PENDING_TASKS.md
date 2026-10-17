# Fable採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとFableが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Fableが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。CodexからFableへの個別依頼と返却は
[FABLE_TASK.md](FABLE_TASK.md)で扱う。

## 規則

- 仮IDは`FP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。Claudeのqueue（`CP-`）とは別系列。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがFableへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- FableはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codexは照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- Codexによる照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてFableが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。

## entry template

### `FP-YYYYMMDD-NNN` — <短い名称>

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

### `FP-20261017-001` — Registry Studio：Fableの採番待ちqueueも表示する

- queue状態: `AWAITING_CODEX`（実施済み・未commit。Studio（OPS-048）はAstraの道具なので受入が要る）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「これ（RegistryApp）に、姫の採番まちはあるけど、ふぁぶるさんの採番まちがまだみれないから、みれるようにしてくれる？それ自体を採番待ちに記載して、動作みてほしい」。
- 種別候補: `EXECUTION`
- 実施:
  - `build-pending.py`：読むqueueを先頭の`queues`一覧（path・持ち主・仮ID接頭辞）にし、`CLAUDE_PENDING_TASKS.md`（CP-）と`FABLE_PENDING_TASKS.md`（FP-）の両方から未処理entryを集める。存在しないfileは飛ばす。seedに`sources`（file毎のpathとsha256）と各entryの`source`・`owner`を足した。従来の`source`文字列は両pathの連結で残した。
  - `index.html`の`renderPending`：カードの小文字にqueue状態に続けて持ち主を表示。原文を開くときのstampはそのentryのfileを出す。下部のstampは全queueを並べる。
  - `README.md`「採番待ちの表示」を両queue対応に更新。
- 対象外: `sync.py`・`verify.cjs`・`registry.json`の構造、queue本文の整形規則。
- 検証: `sync.py`完了・verify.cjs pass（`PATH`にnodeが無いため、`--node`・`--marked`にCodex実行環境`~/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/`配下のnode v24.19.0とmarkedを指定）。生成seedは姫5件（CP-013・005〜008）＋Fable 1件（FP-001）、全entryに整形済みHTMLあり。`renderPending`をstub DOMで実行し、6枚のカード・持ち主表示・FP-001クリックで`FABLE_PENDING_TASKS.md`を出典に原文が開くことを確認。`registry.json`の差分は`source.head`（HEAD 93fd0204への追随）と生成時刻だけ。画面の実表示はユーザーのSafariで確認待ち。
- commit: していない。
- Codex reconciliation: 未処理

過去のreconciliation済みentryはまだない。圧縮時は`Archived/FABLE_PENDING_TASKS_RECONCILED_<日付>.md`へ移し、ここにリンクを残す。
