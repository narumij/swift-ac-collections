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

### `CP-20261016-004` — 判断座標の草案の改訂（`TEST-007`の本文修正）

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-16 13時頃の会話。ユーザーが「ひめ、採番すんだから、判断座標の更新したがってたやつ未採番でやっちゃって」と指示し、
  中断後に「つづけて」と再開した。`TEST-007`の照合記録が「本文修正は配置と分け、ユーザー判断へ返す」としていた部分への、ユーザーの判断である。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/Testing/JudgmentCoordinates/`を新設し、原本の写し`JUDGMENT_COORDINATES.md`に`CP-20261016-003`の所見7点を反映。
  由来・預かり・共有の扱いを書いた`README.md`を置く。
- 対象外: Archivedの原本（改変しない）。統合元・補足の5文書の写し。`TASK_RULES_V2.md`・Registry・`DOCUMENT.md`・`TESTING.md`からのリンク（Astra）。規則への昇格。
- 前提・既存task候補: `TEST-007`（配置・紐付け、Astra）。`TEST-005`。
- 担当候補・受入担当: 姫（改訂）/ Astra（`TEST-007`への統合・入口接続・受入）。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。
  - 7点を反映した。原本のパス`User/CONCEPT_DEFINITION.md`は現行の`Maintanance/Quality/CONCEPT_DEFINITION.md`に直した。
  - 所見6のcommit件数は再集計した（10-15 00:00以降、`ff209700`まで155件中、件名にtask番号の形があるもの5件）。所見作成時の「149件中2件」から更新。
  - 所見4の`RBT-042`の記述は、当時の作業記録との照合をしていない（姫の記憶と会話の要約による）。
  - 訂正（同日）: 作業中にAstraが`ff209700`で6文書の写しと`README.md`を回収・commitしていた。姫はそれを確かめずに`README.md`を
    上書きし、`c3b0259a`でcommitした。誤りなので、Astraの`README.md`を`ff209700`の内容へ戻した。改訂版`JUDGMENT_COORDINATES.md`への
    案内をREADMEへ足すかはAstraに任せる。
- Codex reconciliation: 2026-10-16 Astra。TEST-008へ登録。7点の改訂差分を確認しREADMEから接続。草案として受渡し完了。史実の全面検証・規則への昇格は含まない。留保はCurrent/JUDGMENT_COORDINATES_REVISION_RECEIPT.md。

### `CP-20261016-005` — Registry Studioの依存見取り図が全体fallbackで崩れる件（先頭の到達点へ入る枝）

- queue状態: `RECONCILED`（原返却は調査・試作のみ。下記にAstraの反映結果を追記）
- 発見元・ユーザー指示: 2026-10-16 夕方の会話。ユーザー「HTMLの配置がえらい崩れたんだけど、ルールだけで前っぽく戻せないかな？」「未採番タスクにしといて」。
- 種別候補: `EXECUTION`
- 原因（調査済み）: 配置コードは`HEAD`から変わっておらず、データが増えたのが引き金。新しい`DOC-034 → MS-DOC`は、骨格の**先頭**（列0）へ入る供給の枝である。
  列は`Math.max(0, target.index - distance)`で決まるので、先頭より左の列がなく、DOC-034が列0に置かれる。供給の枝は骨格nodeの右下（`x + golden`）に置く作りのため、
  DOC-034 → MS-DOCの辺が右から左へ向き、`valid()`が不成立になる。その結果、全体が依存深さ順の配置（fallback）へ落ちた。
  検査は、作業ツリーの`index.html`と`registry.json`の関数をJavaScriptCoreで実行して確かめた（`fallback=true`、逆向きの辺はDOC-034→MS-DOCの1本だけ）。
- 提案するルール（1つ）: 「供給の枝は、合流先の列より左に置く。先頭より左が要るなら、骨格の前に列を1つ足す」。
  実装は4か所の小さな変更：`Math.max(0, …)`の切り捨てをやめ、負の列になる枝を先頭の補助列（`leadGroup`）に集め、骨格の前に1列ぶん置いてから`x`を進める。
- 試作の結果: 一時ディレクトリの写しで上の変更を入れ、同じデータで`fallback=false`になった。WebKitで描いた図では、MS-DOC → MS-060 → MS-070 → MS-SPI → MS-HUMAN → QUALITY-001の骨格が横に通り、
  DOC-033 → DOC-034が骨格の前の列、DOC-035・DOC-036・RELEASE-078がMS-DOCの下に並ぶ。崩れる前の形に戻った。
- 対象外: `index.html`・`verify.cjs`の変更（Astraの未commit作業中のため触らない）。交差数の最適化、線の接続点の散らし。
- 前提・既存task候補: 恒久`OPS-048`（Registry Studio）、`OPS-052`（配置の助言、DONE）の続き。
- 担当候補・受入担当: 実装はAstraか、委任があれば姫 / 受入はAstra。
- 停止条件: 先頭の補助列を入れても`valid()`が不成立になるデータが出たら、全体fallbackではなく枝単位のfallback（OPS-052の提案3）を検討する。
- 成果・検証: 未着手（調査と試作のみ。試作に使った一時ディレクトリ`registry-layout-check.*`は削除済み）。
- Codex reconciliation: 2026-10-16、Astra。既存の恒久OPS-048へ統合。ユーザーの「修正お願いします」に基づき、先頭へ入る枝の補助列ルールを実装。原回答は保持。Nodeで現行40taskのfallback=false、重なり・辺方向・収容、ID置換不変性と従来fixtureの座標維持を検証。実画面はユーザー確認待ち。新規採番なし。

### `CP-20261016-006` — リリースゲート手前の判断を一度に出す（Astraへの提案）

- queue状態: `RECONCILED`（OPS-056へ正式化。原提案の方式採用・完了認定ではない）
- 発見元・ユーザー指示: 2026-10-16 夕方の会話。ユーザー「判断を正本に記載するようになってて散らばってるため、追跡が難しい」「リリースゲートの手前の判断を一気にだせるぐらいがいいのかなぁ？」
  「未採番で、あすとらさんに提案タスクとして、なんかやってみて」。
- 種別候補: `DISCOVERY`
- 対象範囲: 提案文書[`Current/GATE_DECISION_DIGEST_PROPOSAL.md`](Current/GATE_DECISION_DIGEST_PROPOSAL.md)の新規作成。`registry.json`からゲートの上流をさかのぼり、未決のユーザー判断・判断の言及・ゲートの直接条件を出す試作（MS-060で実行、結果を文書に転記）。
- 対象外: `index.html`・`registry.json`・Registry・Rulesの変更。判断の印の書式の採用。試作スクリプトのrepository追加（文書に本文だけ載せた）。
- 前提・既存task候補: 恒久`OPS-048`（Registry Studio）。`OPS-036`（Task履歴索引）は将来の拡張先。
- 担当候補・受入担当: 試作・提案は姫 / 採否・実装・受入はAstra。
- 成果・検証: 2026-10-16 / Claude Opus 5.5。MS-060の上流6件のうち、未決のユーザー判断1件（DOC-037）、判断の言及4件を出した。MS-070は12件中5件、QUALITY-001は24件中11件が未決。
  限界は3つ（語の照合は「ユーザー指示」などの経緯と判断を分けられない／詳細正本の本文は見ていない／置き換え関係が分からない）で、文書に記した。
  一時ディレクトリ`gate-decision-digest.*`は削除済み。commitしていない。
- Codex reconciliation: 2026-10-16 Astra。ユーザーの採番・依頼指示によりOPS-056へ統合。原提案は保存し、Astraの要望を別正本へ記載。限定試作をCLAUDE_TASK.mdで正式依頼。

### `CP-20261016-007` — Registry Studioの同期を1コマンドにする（`sync.py`）

- queue状態: `RECONCILED`（OPS-057へ正式化。2026-10-16受入・commit済み）
- 発見元・ユーザー指示: 2026-10-16夕方。Astraの悩み「正本から画面への更新がまだ手作業寄り。同じ事実を複数箇所へ手で反映して、最後に整合を確かめる仕事を一番減らしたい」を受けた姫の提案A-1に、ユーザーが「A-1は未採番でやって」。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/RegistryApp/sync.py`の新規作成。Task Registryからtask・依存辺・親子関係・常設区分を読み、`registry.json`とHTMLのseedを作り直す。`--check`は書き込まずに差分だけを出す。
  書き込みモードでは、続けて既存の`build-pending.py`を実行する。Nodeがあれば`build-documents.mjs`と`verify.cjs`も実行する。
- 引き継ぐもの（Registryから導けないので、現行の`registry.json`から持ち越す）: マイルストーンとその関係、`milestoneSnapshot`、taskごとの`displayInterest`。マイルストーンの引用が原文にまだあるかは検査して報告する。
- 対象外: `index.html`・`registry.json`・`verify.cjs`・`README.md`の変更（Astraの未commit作業中のため）。書き込みモードの実行。マイルストーン関係の自動導出。
- 検証: 2026-10-16 / Claude Opus 5.5。
  - 現行の`registry.json`に対し、生成したtask 44件はすべての欄が一致した（`sourceLine`・親子・常設・`displayInterest`を含む）。依存辺14本は、行番号以外のすべての欄が一致した。マイルストーン7件は持ち越しで一致した。
  - `--check`の結果は「sourceLine moved for 14 rows」だった。現行`registry.json`の依存辺の行番号が、Registryの今の位置から4行ずれている。手作業の同期で起きる漏れの実例で、これを検知できた。
  - 一時コピーのRegistryでDOC-034の状態とDOC-035←DOC-037のFlowを書き換えたところ、`~ task DOC-034: state, raw`、`~ edge DOC-035 <- DOC-037`、hashの変化が出た（一時ディレクトリ`sync-drift-test.*`、削除済み）。
  - Nodeがこの環境にないため、書き込みモードの後段（`build-documents.mjs`・`verify.cjs`）は試していない。
- 使い方の提案（採否はAstra）: 正本を直したら`sync.py`を1回実行し、`registry.json`とHTML内のデータは手で直さない。コミット前に`--check`が差分なしを返すことを確かめる。README（利用手順の正本）の手順2・3をこれに置き換えるかはAstraが判断する。
- 担当候補・受入担当: 作成は姫 / 採否・READMEへの接続・受入はAstra。
- Codex reconciliation: 2026-10-16 Astra。ユーザー指示によりOPS-057へ正式登録。既存試作を入力にCLAUDE_TASK.mdで仕上げ・通常更新の検証を依頼。

### `CP-20261016-008` — 判断アーカイブ（Astraへの提案）

- queue状態: `RECONCILED`（提案の記録のみ。実施しない）
- 発見元・ユーザー指示: 2026-10-16夕方。Astraの悩み「判断を追記で残すと、古い本文との優先関係が残る。『後ろに訂正を書いたから読めるはず』に頼っている」に対する姫の提案A-3を、ユーザーが「いいね。判断アーカイブだ。それは提案として追加の未採番にして」。
- 種別候補: `DECISION`（運用の方針。採否はユーザーとAstra）
- 提案:
  1. 本文はいつも「今効いている判断」に書き換える。古い文は、同じ文書の履歴の節か`Archived/`へ移す（CLAUDE_TASK.mdの圧縮と同じ考え方）。追記で訂正を重ねない。
  2. 同じ判断は一か所に書き、ほかの場所からはリンクする。OPS-056の試作では、「0.6.0では既存スニペットを固定」が同じ文で3か所（RELEASE_0_8_0.md、RELEASE_0_6_0.md、Registry DOC-034行）にあった。
  3. 書き換えるときは、移した先へのリンクを本文に一行残し、由来をたどれるようにする。
- 前提・既存task候補: `OPS-056`（判断追跡の試作）、`OPS-044`（Registry運用）、`DOC-030`（文書整備）。
- 担当候補・受入担当: 採否はユーザー / 運用はAstra。
- 停止条件: ユーザーが確定した文書（書き換えない約束のもの）には適用しない。その場合は別文書に訂正を置き、持ち主へ渡す。
- 成果・検証: 未着手（提案の記録のみ）
- Codex reconciliation: 2026-10-16 Astra。OPS-058へPROPOSEDで正式登録。Current/DECISION_ARCHIVE_PROPOSAL.mdへ接続。提案の登録のみで、方式は未承認。

### `CP-20261016-009` — 姫のAI用キャッシュ領域`Maintanance/Cache/Hime/`の申請

- queue状態: `RECONCILED`（担当名の割当てを承認）
- 発見元・ユーザー指示: 2026-10-16夕方。Rulesの「ゲートの人間用資料とAI用キャッシュ」（`Cache/<担当名>/`）について、ユーザー「`Maintanance/Cache/Hime/`じゃなくていいの？ネームドClaudeだから、未採番で申請すれば通るよ」。
- 種別候補: `DECISION`（担当名の割当て）
- 申請内容: Claude（姫）のAI用キャッシュの保存先を`Maintanance/Cache/Hime/`とする。一時用途は`Cache/Hime/Temporary/<task IDまたは固有名>/`。担当名は「Claude」ではなく呼び名の「Hime」にする（Astraが`Cache/Astra/`であるのと同じ考え方。将来ほかのClaudeが加わっても区別できる）。
- 使い方: TEST-005・HIST-003などの常設taskや、RBT-026のような長い議論を引き継ぐとき、AI用ゲートとして使う。正本の代わりにせず、操作直前のRegistry確認は維持する。
- 対象外: Rules・COMMONS.mdの本文変更。ほかの担当のキャッシュ。
- 担当候補・受入担当: 申請は姫 / 承認・Rulesへの担当名の記載はAstra。
- 成果・検証: 未着手
- Codex reconciliation: 2026-10-16 Astra。既存OPS-044へ統合し担当名Himeを承認。Rulesに保存先を明記しCache/Hime/README.mdを作成。既存キャッシュ規則の範囲内で使用可能。原申請本文は保持し、新たな作業権限は追加しない。

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
