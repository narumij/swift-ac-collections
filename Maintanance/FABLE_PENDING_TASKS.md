# Fable採番待ちqueue

正式なRegistry IDへの照合・登録前に、ユーザーとFableが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Fableが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。調整担当からFableへの個別依頼と返却は
[FABLE_TASK.md](FABLE_TASK.md)で扱う。

## 規則

2026-10-17：代理期間中は[ユーザーの明示委任](Current/FABLE_COORDINATOR_DEPUTY.md)により、Fable自身が正式採番・照合・Registry更新を行える。調整担当としての現在の割当。原返却と自身の成果の独立受入は区別する。

- 仮IDは`FP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。Claudeのqueue（`CP-`）とは別系列。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがFableへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- FableはRegistryの状態、最終受入、公開方針、他担当の完成判定を、明示的な委任なしに代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- ユーザーから委任された調整担当は照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- 委任された調整担当による照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてFableが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。


旧フィールド名`Codex reconciliation`と状態名`AWAITING_CODEX`は互換のため保持する。処理担当をCodexに限定する意味ではなく、委任された調整担当が実際の担当名を添えて照合結果を記録する。

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

- queue状態: `RECONCILED`（2026-10-17 Astra。以下の括弧は返却当時の状態）（実施済み・未commit。Studio（OPS-048）はAstraの道具なので受入が要る）
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
- Astra reconciliation（2026-10-17、最新）: OPS-048へ統合。5ea16511の差分・seed照合とverify成功。Safari実操作は未確認。 原返却のcommit記述は当時の記録として保持。

### `FP-20261017-002` — 残りの採番待ち（CP-005・CP-006）の照合案

- queue状態: `RECONCILED`（2026-10-17 Astra。以下は返却時の注記）（照合案のみ。Registry・両queue・正本は未編集）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「のこりの採番待ちもしょりして」。OPS-044管理試験（`Current/FABLE_MANAGEMENT_TRIAL.md`、Astra受入`318d78f4`）と同じ形式で、Fableが案を作りAstraが受入・反映する。試験の受入は「Registry直接編集まで認定しない」なので、Fableは案にとどめる。
- 種別候補: `EXECUTION`（管理補助）
- 対象: `CLAUDE_PENDING_TASKS.md`の`CP-20261017-005`・`CP-20261017-006`。対象外: `CP-20261016-013`（OPS-059としてFROZEN登録済み。再開・受入はユーザー指示が要るため触れない）。
- 照合時点: HEAD `318d78f4`。作業ツリーに`RegistryApp/index.html`・`registry.json`の未commit再生成（seed head 318d78f4、13:45生成、Fable以外の実行）と`User/MEMO.md`あり。Fableは触っていない。

#### CP-20261017-005 — Studio：DONEのtaskがあると作り直しが止まる不具合

- 事実: 作成者は姫。commit `4163ff4e`（10-17 04:37「docs: sort Studio regular list by state and allow DONE tasks before compression」、`index.html`・`verify.cjs`・`registry.json`・queue）。本文の「未commit」は当時の記録で、現在は古い。`verify.cjs`144行目にユーザー判断「DONE tasks may stay in the Registry until compression; compression is not immediate (2026-10-17 user)」がコメントとして残る。
- 重複・衝突: Rules43行目のDONE定義・`TASK_REGISTRY_ARCHIVE.md`と矛盾しない（即時圧縮を求める規則はない）。`FP-20261017-001`（`5ea16511`）とは変更箇所が別で、`5ea16511`は`4163ff4e`を含むHEADでverify pass。`TASK_REGISTRY_APP.md`・`RegistryApp/README.md`にこの修正の記録はない。
- 統合先: 既存`OPS-048`。新規採番不要。
- 提案編集:
  1. `Current/TASK_REGISTRY_APP.md`末尾に節追加: `## DONE混在時の再生成修正（2026-10-17）` 本文「CP-20261017-005（姫）をOPS-048へ統合。独立タスクの状態順の並べ替えを`independentGroups`内へ移し、`verify.cjs`の「RegistryにDONEを残さない」検査を外した（ユーザー「タスク圧縮はすぐはしないから」）。commit `4163ff4e`。」
  2. `CLAUDE_PENDING_TASKS.md`の同entry: `queue状態: `AWAITING_CODEX`（実施済み・未commit。OPS-048）` → `queue状態: `RECONCILED`（2026-10-17 Astra、OPS-048へ統合。括弧内は返却当時）（実施済み・未commit。OPS-048）`、`Codex reconciliation: 未処理` の下に `- Astra reconciliation（2026-10-17）: OPS-048へ統合。commit `4532e9df`の検査撤回を含む。実装commitは`4163ff4e`。` を追加（原文は保持）。
- ユーザー判断待ち: なし。任意: 「DONEはしばらく残す」の判断をRulesか`TASK_REGISTRY_ARCHIVE.md`に一文置くか（今はqueueとコードのコメントだけ）。

#### CP-20261017-006 — 候補CIにLinuxのASan＋death test jobを追加

- 事実: 作成者は姫。実装commit `8631a031`（10-17 04:37、`.github/workflows/candidate.yml` +43/−2）、CI通過の記録commit `eb52378c`（04:44）。HEADの`candidate.yml`に`address-sanitizer-death-tests` job（126行目〜、`--sanitize address`、`report`のneedsと一覧に登録）が残っている。CI成功はユーザー報告のみで、run URL・対象commitは未記録。本文の「commit: `8631a031`」は正しいが状態欄の「未commit」は古い。
- Registry: 直接の受け皿はない。`RBT-049`（DONE、「Linux・CI・リリース可否は未検証」）、`QUALITY-002`（ACTIVE、Codex、1.0品質保証CIの構成・証拠化、「今回CI変更・起動は行わず」）、`RELEASE-085`（PROPOSED、候補CI立て直し範囲のユーザー判断）。`Current/RELEASE_CI_RECOVERY.md`13行目「ASanのRBT-049も自動的に混ぜない」。
- 重複・衝突: 本jobはユーザーの明示依頼で入ったので規則違反ではないが、立て直し（RELEASE-085）が未決のまま候補CIの構成が1 job増えた点は、RELEASE-085の範囲決定時に扱う必要がある。`RBT-049`の「Linux未検証」は、本jobの成功で「Linuxでは`strip_env`相当の対処なしで成立」という新事実が出た（ただしrun URL未保存、Astra未確認）。重複する既存entryやtaskはない。
- 統合先（案）: 既存`QUALITY-002`へ「Linux代表環境でのASan＋death test証拠」として統合。`RBT-049`正本へは相互参照だけ。新規採番は不要（受入時にAstraが`RELEASE-085`側で扱うと判断するなら、そちらでも可）。
- 提案編集:
  1. `TASK_REGISTRY_V2.md`の`QUALITY-002`行、説明末尾に追記: 「2026-10-17、ユーザー依頼で候補workflowにLinux ASan＋death test jobを追加（`8631a031`、CP-20261017-006）。成功はユーザー報告、run URL未保存。恒久採用は未決。」
  2. `Current/ASAN_STRIP_ENV_FIXED_REVISION_VALIDATION.md`末尾に節追加: `## Linux候補CIでの後続（2026-10-17 / Astra）` 本文「CP-20261017-006により`candidate.yml`へASan death test jobを追加し、ubuntu-24.04で成功（ユーザー報告、`8631a031`・`eb52378c`）。本taskの結論（macOS DYLD経路のstrip_env）とは独立で、Linuxでは対処不要と整合。本taskのDONE範囲は変更しない。」
  3. `Current/RELEASE_CI_RECOVERY.md`の13行目の段落末尾に一文: 「2026-10-17時点で候補workflowには`address-sanitizer-death-tests` jobが入っている（CP-20261017-006）。立て直し範囲の決定時に残す・外すを明示する。」
  4. `CLAUDE_PENDING_TASKS.md`の同entry: `queue状態: `AWAITING_CODEX`（実施済み・未commit。…）` → `queue状態: `RECONCILED`（2026-10-17 Astra、QUALITY-002へ証拠として統合。括弧内は返却当時）（…）`、`Codex reconciliation: 未処理` の下に `- Astra reconciliation（2026-10-17）: QUALITY-002へ統合、RBT-049正本・RELEASE_CI_RECOVERYへ参照追記。CI成功のrun URLは未保存。` を追加。
- ユーザー判断待ち: (a) 候補CIにこのjobを恒久的に残すか（RELEASE-085の範囲）。(b) 成功runのURLか対象commitを記録するか（GitHub側はユーザーの領分。残すなら本entryへ一行）。
- 範囲外所見: なし。

- 成果・検証: 本entryのみ。commit hash・行番号は`git show --stat`・`grep -n`で確認した。Studio再生成・commitはしていない。
- commit: していない。
- Codex reconciliation: 未処理
- Astra reconciliation（2026-10-17、最新）: OPS-044の管理補助として受入、CP-005/006を既存OPS-048/QUALITY-002へ統合。ASan恒久採用の再判断とrun保存をユーザー専任とする提案は不採用。既存の明示依頼を維持し、run証拠の照合はQUALITY-002へ残す。

過去のreconciliation済みentryはまだない。圧縮時は`Archived/FABLE_PENDING_TASKS_RECONCILED_<日付>.md`へ移し、ここにリンクを残す。
