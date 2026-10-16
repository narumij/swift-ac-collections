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

### `CP-20261017-001` — 文書マイルストーンを版フォルダ`Milestones/`へ正本として分割

- queue状態: `RECONCILED`（2026-10-17 Astra、文書分割・配置移行をOPS-047へ受入・統合。以下の本文は返却時のまま。処理結果は末尾「Astra受入・統合（2026-10-17、マイルストーン移行）」）
- 発見元・ユーザー指示: 2026-10-17未明。ユーザーが`Maintanance/Milestones/`（`HEAD.md`、版フォルダ、`MS_*.md`）を作成し、「これをさっきのフォルダに分割して正本形式で配置してほしい」（`Current/DOCUMENTATION_MILESTONES.md`）。
- 種別候補: `EXECUTION`
- 実施:
  - `Milestones/0.5.4/MS_RBT_DOCUMENTS.md`：旧RBT-014の節、ゲート作業、受入証拠、履歴。ユーザーの「到達済み」を保持。
  - `Milestones/0.7.0/MS_VALIDATION_REVIEW.md`：旧DOC-032の節とDOC-036のゲート作業。
  - `Milestones/0.8.0/MS_DOCUMENT_EXPANSION.md`：新規。0.8.0への拡充移管と固定範囲の決定。
  - `Current/DOCUMENTATION_MILESTONES.md`：索引に変えた。見出しは残したので、`MILESTONES.md`などからのアンカー付きリンクは切れない。
  - 移し先の決まらなかった1行（DOC-035 → 0.6.0の文書初版条件、DOC-035は完了済み）は、ユーザーの指定で`Milestones/Archived/DOCUMENTATION_MILESTONES_LEFTOVER_2026-10-16.md`へ移した。
  - `registry.json`の到達点の出典（MS-DOC、MS-VALIDATION、DOC-036→MS-VALIDATIONの関係）を新しいファイルへ向け直し、`sync.py`で再生成した。
- 検証:
  - 元の段落と箇条（13件）は、リンク先の相対パス以外すべて逐語で新しいファイルにある（`4532e9df`の版と機械照合）。
  - 新しいファイルと索引の相対リンクは、すべて実在する。
  - `sync.py`の書き込みは成功（verify.cjsもpass）。`--check`でずれなし。
- 対象外: `MS_CANDIDATE.md`各ファイル（Xcodeのテンプレート見出しが入ったまま。触っていない）、`MS_LEFT.md`、`HEAD.md`、`MILESTONES.md`本文、Registry。
- 判断が要ること: 旧ID（`MS-DOC`・`MS-VALIDATION`・`MS-080`）と新しいファイル名のどちらを正式なIDにするか。今はファイルに両方を書いた。
- 追記（同夜）: ユーザーがリリース文書8件を`Current/`から版フォルダへ移した（`RELEASE_0_5_4`・`RELEASE_0_6_0`系5件→`0.5.4/`、`RELEASE_0_7_0`→`0.6.0/`、`RELEASE_0_8_0`→`0.7.0/`）。ユーザー依頼「リンクなおしてくれない？」により、姫がリンクを直した。
  - 移動先を指すMarkdownリンクを15ファイルで書き換え。移動したファイル自身の相対リンクも、新しい場所から辿れるように直した。書き換えた範囲で、リンク切れは0件。
  - `registry.json`の到達点の出典13件を新しい場所へ向け直した。リンクを直したファイルのhashも更新し、`sync.py`で再生成した（verify pass、`--check`でずれなし）。試作`GateDecisionDigestPrototype/marks.json`のパス2件も直した。
  - 直していないもの（持ち主の判断か、過去の記録のため）: `TASK_REGISTRY_V2.md`の詳細正本列のパス6件（39・40・47・48・49・78行）、`Archived/`の2ファイル（`CLAUDE_TASK_HISTORY_2026-10-16_3.md`・`MILESTONE_REORGANIZATION_2026-10-16.md`）のリンク、`COORDINATION_KNOW_HOW.md`の本文中のパス表記1件、試作の出力スナップショット`out-*.md`、`completed-document-layout-fixture.json`。
- 配置の決まり（2026-10-17ユーザー判断、会話）: リリース文書（`RELEASE_*.md`）は「その文書を扱っている現在地」の版フォルダに置く（例：0.7.0の計画は`0.6.0/`）。到達点（`MS_*.md`）はゲートなので「目標の版」のフォルダに置いたまま（例：`MS_VALIDATION_REVIEW`は`0.7.0/`）。
- 追記（同夜、2回目）: ユーザーがリリース文書8件をすべて`Milestones/Archived/`へ移し、各版に`GATE_<次の版>.md`を置いた（理想形を先に作り、のちにサルベージする方針）。`MS_CANDIDATE.md`は「候補が本当に確定したら記入するだけ」のファイルにする予定（ユーザー）。ユーザー依頼によりリンクを再度直した：11ファイル18か所、`registry.json`の出典を`Archived/`へ向け直してhash更新、`marks.json`も同様。`sync.py`再生成。`Archived/`（ルート）の2ファイルは過去の記録なので直していない。
- commit: していない。
- Codex reconciliation: 2026-10-17 Astra。文書分割・配置移行をOPS-047へ受入・統合。

### `CP-20261017-002` — MILESTONES.mdのゲート要素を版ごとのゲートへ移す

- queue状態: `RECONCILED`（2026-10-17 Astra、追記16までをOPS-047 / OPS-048へ受入・統合。以下の本文は返却時のまま。処理結果は末尾「Astra受入・統合（2026-10-17、マイルストーン移行）」）
- 発見元・ユーザー指示: 2026-10-17未明。ユーザー「これ（MILESTONES.md）のうち、報告要素とゲート要素があって、ゲート要素をさっきみたいに抜き出して、配置して欲しい」。
- 種別候補: `EXECUTION`
- 実施:
  - `Milestones/Archived/GATE_0_5_4.md`：旧「0.6.0」として準備したゲート（今回の0.5.4、merge済みなので過去の記録）。版ごとの重点の0.6.0行と「文書ゲートの作業接続」の節。
  - `Milestones/0.6.0/GATE_0_7_0.md`：版ごとの重点の0.7.0行、その下の注記、見取り図の下の0.7.0の条件の注記。
  - `Milestones/0.7.0/GATE_0_8_0.md`：版ごとの重点の0.8.0行と「0.8.0の追加」の2段落。
  - 3ファイルとも`GATE_TEMPLATE.md`の形にし、原文は「原文（MILESTONES.mdから移した）」に逐語で置いた（リンクの相対パスだけ直した）。
  - `MILESTONES.md`には報告要素（現在位置、タスク数、全体の図、SPI・1.0の流れ、未接続の到達点、維持方法、CI立て直し）を残した。移した箇所には移動先へのリンクを置き、到達点の一覧表のリンクを新しいゲートと`MS_*.md`へ向け直した。
- 検証: 元の行・段落はすべて、`MILESTONES.md`か3つのゲートに逐語である（機械照合）。リンク切れ0件。`registry.json`の出典を向け直して`sync.py`で再生成（verify pass、`--check`ずれなし）。
- 判断が要ること: 移した原文の「0.6.0」は、振り替え前の名前（今回の0.5.4）を指す場合と、これからの0.6.0を指す場合が混ざっている。特に0.7.0の条件「0.6.0完了と後続差分を材料にする」がどちらを指すかは決めていない。`0.5.5/GATE_TEMPLATE.md`（空）と`0.5.5/GATE_0_6_0.md`（未作成）には触っていない。
- commit: していない。
- Codex reconciliation: 2026-10-17 Astra。追記16までをOPS-047 / OPS-048へ受入・統合。
- 追記（2026-10-17）：ユーザー「README配置して、今は切り替え中で方針は項ですってかきますか。で、各フォルダには次の目標をいれる」。`Milestones/README.md`を作った（切り替え中であること、方針：`<版>/`には次の目標`GATE_<次の版>.md`を入れる）。`MS_*.md`の置き場所（いまは到達先の版のフォルダ）とこの方針が食い違う点は、ユーザーに確認中。続けてユーザー「バージョンゲートは、そのフォルダの最終ゲートですってしよう」。READMEに追記（フォルダ内の`MS_*.md`は途中の到達点）。ユーザーが`MS_VALIDATION_REVIEW`を`0.6.0/`へ、`MS_DOCUMENT_EXPANSION`を`0.7.0/`へ、`SPI_PUBLICATION_MILESTONE`と`DOCUMENTATION_MILESTONES`を`Milestones/Archived/`へ移動。ユーザー「そもそもどのバージョンで実施するって記述を消そう」により、`MS_VALIDATION_REVIEW`から版の記述（「版:」行、「0.7.0のリリース前ゲートへ配置する。0.6.0の前提にはしない。」、「→ 0.7.0」）を消し、由来欄に削除を明記。移動で切れたリンクを直し、`registry.json`の出典を向け直して再同期（verify pass、ずれなし、リンク切れ0）。`MS_DOCUMENT_EXPANSION`・`MS_RBT_DOCUMENTS`の版の記述はまだ残す。続けてユーザーが方針を決定（フォルダ＝版、ファイル＝ゲート、フォルダ作成とゲートの新規作成・移動で版の遷移、ゲートは常にシーケンス・最終がバージョンゲート・他はナンバリングのソート順）。READMEの方針節へそのまま記載。既存`MS_*.md`への番号付けは未実施。ユーザー「逆でさ。いったん、スタジオとおなじにしたいの」により、番号付けではなくStudioのIDへ改名：`MS_RBT_DOCUMENTS`→`0.5.4/MS-DOC.md`、`MS_VALIDATION_REVIEW`→`0.6.0/MS-VALIDATION.md`、`MS_DOCUMENT_EXPANSION`→`0.7.0/MS-080.md`。ID欄・リンク・`GATE_TEMPLATE`・`registry.json`を追随、再同期（verify pass、ずれなし、リンク切れ0）。上の記録中の旧ファイル名は当時の名前。
- 追記2（2026-10-17）：Studioの到達点を調べると、`4532e9df`（10-16 23:48）でMS-060の見出しが「0.6.0 リリース」から「0.5.4 リリース」へ書き換えられ、0.6.0がStudioから消えていた（0.5.4の挿入ではなく改名）。到達点データは`8a0c8769`〜`a5669c53`で不変、変わったのは`4532e9df`だけ。ユーザー「まずリリースしくじる前のスタジオにもどそう」により、`registry.json`の`milestones`・`milestoneRelations`（とbaseline）を`a5669c53`の内容へ戻した。調整は3点：(1) 出典pathを移動後のファイルへ向け直しsha・行を更新、(2) Task Registryにもう無いtaskへの関係3本（RELEASE-078→MS-060、DOC-034→MS-DOC、DOC-035→MS-060）は戻さない、(3) DOC-036→MS-VALIDATIONの引用は今日削った「→ 0.7.0」なしの現行文へ。`4532e9df`で足されたMS-RECOVERY（RELEASE-087→）は戻した結果なくなった（HEADの`registry.json`に残る）。`verify.cjs`の件数固定を8・17→7・16へ。sync完了・verify pass・ずれなし。Studioの到達点データの変更なので、Astraの受入が要る。
- 追記3（2026-10-17）：ユーザー「マイルストーンで並列扱うと難しいから、シーケンシャル制限にしたい」、列の案に「1よい、2-bがいいな」。到達点を一本の列にした：MS-DOC→MS-060→MS-VALIDATION→MS-070→MS-SPI→MS-080→MS-HUMAN（→QUALITY-001）。Studioの関係は3本外し（MS-060→MS-070、MS-070→MS-080、MS-SPI→MS-HUMAN）、3本足した（MS-060→MS-VALIDATION、MS-SPI→MS-080、MS-080→MS-HUMAN、出典は`Milestones/README.md`の「いまの列」）。外したMS-060→MS-070の制約文（0.6.0完了証拠を0.7.0検討の前提とする）は`Archived/RELEASE_0_7_0.md`に残るがStudioの線からは消えた。各到達点のdetailをゲートのファイルへ。フォルダ：`0.5.4/10_RBT_DOCUMENTS.md`＋`GATE_0_6_0.md`（新）、`0.6.0/10_VALIDATION_REVIEW.md`＋`GATE_0_7_0.md`、`0.7.0/10_SPI.md`（新）＋`GATE_0_8_0.md`（旧`MS-080.md`の本文を統合して削除）、`0.8.0/10_HUMAN_REVIEW.md`（新）＋`GATE_1_0_0.md`（新、QUALITY-001）。READMEに制限と列、`GATE_TEMPLATE`を番号形式へ。`verify.cjs`に一本の列の検査を追加（分岐・合流・循環・離れ島で失敗。分岐を入れたデータで失敗することを確認）。sync完了・verify pass・ずれなし・リンク切れ0。
- 追記4（2026-10-17）：ユーザー「0.9と1.0もゲート足して欲しい」「1.0はいらないか」。`0.8.0/GATE_1_0_0.md`を`0.9.0/`へ移し、`0.8.0/GATE_0_9_0.md`（中身は未定、Studioの到達点なし）を作った。`1.0.0/`は到着点でゲートなし。READMEの列と、それを引用するMS-080→MS-HUMANの出典を更新。sync完了・verify pass・ずれなし・リンク切れ0。
- 追記5（2026-10-17）：ユーザー提案「先頭にUUID」、「ある程度準備ができてからアストラに受け入れてもらうから、なっとくいくまでおれとやろう」。ユーザーと設計中（Astraへはまだ出さない）。第1歩として版フォルダの9ゲートの1行目に`<!-- gate: <UUID> -->`を付け、`GATE_TEMPLATE`にも欄を置いた。`sync.py`はまだ変えていない（UUIDは未使用）。sha更新・sync済み。続けてユーザー「カードと同じ情報が入ってて欲しい」「1，いいよ」「ステートとして、ACTIVEかDONEでいいような」「というか、DONEチェックか」「選択肢を狭めよう」。9ゲートの見出しをカードの名前にし、直後に`- ID:`・`- [ ] DONE`（済みは`[x]`）・`- 担当:`・`- 条件:`を置いた（値はStudioのカード、QUALITY-001はRegistry）。旧の状態見出し（「# 到達済み」「# 未通過」）と旧ID行は外した（MS-DOCはユーザー記載の到達済み→`[x] DONE`）。`GATE_TEMPLATE`も同じ並び。Studio側の状態はまだ「到達未確認」のまま（読取りは`sync.py`変更時）。続けてユーザーが形を指定（「# 一意識別子 / # カード情報（## ID・## 名前・## 正本・## 状態 `- [ ] DONE`）/ # 記録」）。9ゲートと`GATE_TEMPLATE`をこの三部構成に組み替えた。正本はStudioの引用元ファイル（MS-DOC・MS-VALIDATIONは「このファイル」、QUALITY-001は品質Profile、0.9.0は「なし」）。担当・条件はカード情報の指定に無いので記録の先頭へ移した。記録内の見出しは1段下げた。sha更新・sync済み・リンク切れ0。続けてユーザー「担当はなしかな。必ず俺が同席するし。一人ではやらせないって書いておいて欲しい、もう」。9ゲートから担当行を消し、READMEに「マイルストーンとゲートの作業は、必ずユーザーが同席する。AIに一人ではやらせない」を記載（`GATE_TEMPLATE`の記録欄にも注記）。Astra受入時にAGENTS等へ載せるかはAstra・ユーザー判断。
- 追記6（2026-10-17）：ユーザー「A-2はうまいことやって」。`sync.py`を変更：(1) 到達点のカードを`Milestones/<版>/*.md`の一意識別子とカード情報から作る（ID・名前・状態DONE/ACTIVE・正本→detail、条件欄は「ゲート：…／正本：…」、担当は「ユーザー同席（AI単独では扱わない）」、UUIDとゲートpathも保持。ID「なし」とRegistryのtaskは到達点にしない。`END.md`は読まない）。UUID重複・カード欠け・正本リンク切れで停止。(2) 関係の引用元ファイルが動いた/引用が無いときは`Milestones/`と`MILESTONES.md`から引用を探し、1ファイルだけなら付け替え。(3) 引用が残っていてファイルだけ変わった場合はsha・行を自動更新して続行（引用が消えたときだけ停止）。試験：ゲートの記録に追記＋ファイル名変更→sync 1回でカード・関係とも追随、verify pass、元に戻して再sync。MS-DOCがStudioでDONE表示に。Astraの道具の変更なので受入が要る（ユーザーと詰めてから出す）。
- 追記7（2026-10-17）：ユーザー「ちょっと1回全部こみっとして」→`e2dd63d6`（push無し）。想定演習「0.5.4中止・0.5.5追加」をユーザーが自分で実施（`0.5.4/GATE_0_6_0`を`GATE_0_5_5`へ改名し名前を書換、写しを`0.5.5/GATE_0_6_0`にID`MS-060-2`で作成）→`sync.py`がUUID重複で停止。既存到達点の名前を書き換えて意味を入れ替える形（10-16の`4532e9df`と同型）だった。ユーザー「UUIDあきらめるかｗ」「うん。UUID廃止」。(1) 全ゲートと`GATE_TEMPLATE`から「# 一意識別子」を削除、`sync.py`のUUID処理を削除（IDが身元。重複IDは停止）。(2) 演習の正しい形に直した：`0.5.5/GATE_0_6_0.md`は元のMS-060を中身そのままで移動、`0.5.4/GATE_0_5_5.md`は新規MS-055。(3) `sync.py`が到達点どうしのつながりをゲートの並び（版フォルダの数値順、フォルダ内はファイル名順）から作るようにした。既にある組は関係の種類と根拠を保持、消えたゲートに触れる持ち越しは捨てる、自動のつながりは古さの検査から外す。(4) `verify.cjs`の到達点・関係の件数固定を外した（ゲートで増減するため。一本の列の検査は維持）。(5) READMEに「既存ゲートのIDと名前は変えない／新しいゲートには新しいID」と、Studioとの関係を記載。試験：演習の状態→ファイル移動だけで戻す→ファイル移動だけでやり直す、の3状態ともsync 1回でverify pass、列はMS-DOC→MS-055→MS-060…と…MS-DOC→MS-060…を往復、ファイルは開始時と一致。動かしたゲートの通る条件にある同じフォルダへの相対リンクが1件切れたので`../0.5.4/`へ直した。sync時の注記：Registryの詳細正本列が`Current/`の移動済みファイル5件を指したまま（Registryは触らない）。
- 追記8（2026-10-17）：ユーザーが現状に合わせて`0.5.3/`（10_RBT_DOCUMENTS・GATE_0_5_4）と`0.5.4/GATE_0_6_0`へ配置。GATE_0_5_4のカードがMS-055／0.5.5リリースのまま残っていた。ユーザー「GATE-000で、そのままバージョンと同じになるナンバリングにするべき」。版ゲートのIDを`GATE-xyz`（ファイル名と同じ番号）、名前を「x.y.z リリース」に統一：MS-055→GATE-054、MS-060→GATE-060、MS-070→GATE-070、MS-080→GATE-080（名前「0.8.0 文書拡充・再検討」→「0.8.0 リリース」）、なし→GATE-090、QUALITY-001→GATE-100（1.0品質判断のtaskは別に残る）。各ゲートの記録に変更を一行。`sync.py`に版ゲートのID・名前とファイル名の照合を追加（食い違いで停止）。`registry.json`の持ち越し関係の端点26か所をGATE-*へ、`verify.cjs`の現行データに対する固定ID（rewire先1、存在確認リスト1、関係確認2）をGATE-*へ（過去fixtureに対する検査は不変）。sync完了・verify pass。列：MS-DOC→GATE-054→GATE-060→MS-VALIDATION→GATE-070→MS-SPI→GATE-080→MS-HUMAN→GATE-090→GATE-100。MILESTONES.md・Registry等の旧MS-060/070/080の記述は未変更。
- 追記9（2026-10-17）：ユーザー「END-053は、0.5.3フォルダで、それはリリースゲートに自動接続」「そう、実ファイルいらないんだよね」「END-053とかの、識別子だけにしよう」。`sync.py`が各版フォルダにEND-xyz（実ファイルなし、識別子だけ：名前＝ID、条件なし）を作り、途中のゲートの後・リリースゲートの前に置く。END-xyzの状態はそのフォルダのリリースゲートと同じ。旧来の(途中ゲート→リリースゲート)の関係は(途中ゲート→END)へ種類ごと引き継ぐ（MS-VALIDATION→END-060 required）。`verify.cjs`の該当1か所をEND-060へ。READMEに記載。列：MS-DOC→END-053→GATE-054→END-054→GATE-060→MS-VALIDATION→END-060→GATE-070→MS-SPI→END-070→GATE-080→MS-HUMAN→END-080→GATE-090→END-090→GATE-100→END-100。sync完了・verify pass。未決だった3点：(1)「版のない作業」をENDへつなぐ件はユーザー「よくわからない」で保留（何もつながない）。(2) ユーザーが`0.5.3/GATE_0_5_4`を`[x] DONE`に（HEAD.md 0.5.4と一致）。(3) ユーザーが`1.0.0/END.md`を削除、READMEから記述を外した。注意：`1.0.0/`は空フォルダになり、gitは空フォルダを保存しないので、clone先ではEND-100が出ない。
- 追記10（2026-10-17）：ユーザー「HEADが動くとDONEもいらなくて自明なんだよね、ゲートは」「中間マイルストーンにだけDONEがひつよう」。版ゲート6件と`GATE_TEMPLATE`から「## 状態」を削除。`sync.py`が状態を導く：版ゲートは版≦HEADで済み、ENDはフォルダ＜HEADで済み、途中のゲートはチェックか、フォルダ＜HEADで済み。試験：HEAD.mdを0.6.0にするだけでGATE-060・END-054まで済みに変わることを確認、戻して再sync。READMEに記載。
- 追記11（2026-10-17）：ユーザー「先頭にアンスコつけたら除外にしよう。それ以外のフォルダはドットを除去した文字列の識別子を自動付与というルールに」。ユーザーが`Milestones/Archived`→`_Archived`、`1.0.0/GOAL.md`（空）を置いた。`sync.py`：`_`始まりのフォルダを除外、それ以外は全部版フォルダ（数字は数値順、他は文字順）、END-<ドット除去名>を自動付与。ゲートとして読むのは`NN_*.md`と`GATE_x_y_z.md`だけ（GOAL.md等は無視）。引用の付け替えで同名ファイルを優先（引用が複数ファイルにあっても、元と同じ名前のファイルが1つなら付け替え）。`_Archived`への改名で切れたMarkdownリンク25件（12ファイル、うちProgressV2/COORDINATION_KNOW_HOW.md 1件はリンク先パスだけ）と、ユーザーが`0.5.3/`へ移した`10_RBT_DOCUMENTS`への4件を直した。Studioの関係の出典は`sync.py`が自動で`_Archived`へ付け替えた。sync完了・verify pass・Milestones内リンク切れ0。
- 追記12（2026-10-17）：ユーザー「END>GATEいがいの接続を許さないようにしたいのと、タスクはENDにつながってる方がいい」。`sync.py`：タスク→GATEはそのGATEのフォルダのENDへ（RELEASE-072/075/076→END-060、DOC-038/039→END-070）、GATE→タスクは「その版でやる作業」としてタスク→その版のENDへ向きを変えて付け替え（PERM-079→END-060 resume、QUALITY-005→END-070 after）。`verify.cjs`に「GATEへ入るのはENDだけ、GATEから出るのは到達点だけ」を追加、PERM-079の確認を新しい向きへ。ユーザーが置いた空の`0.9.0/10_QUALITY-0001.md`を、ユーザー「なんかうめて」で途中のゲート`MS-QUALITY`「1.0 品質判断」として記入（Registryの`QUALITY-001`とIDが重ならないように）。sync完了・verify pass。列：…GATE-090→MS-QUALITY→END-090→GATE-100→END-100。途中のゲートへのタスクの直接接続（DOC-027→MS-SPI、DOC-036→MS-VALIDATION、MS-HUMAN→QUALITY-001）はユーザー「それはかまわないかな」で許容。READMEに記載。
- 追記13（2026-10-17）：Studio表示。ユーザー「全部グラフにするんじゃなくて、各バージョン毎のグラフに」「そのバージョンがどこのバージョンに行きたいかはマイルストーンしかしらなくていい」「HTMLとしてはENDはかくしてゲートに置き換える」。`index.html`：`graphData()`でENDを描かず、ENDへの線をそのENDの先の版ゲートへ描く（データはENDを保持）。見取り図の上に版の選択欄を追加、`versionView()`でそのフォルダのゲートと上流のタスクだけを表示（前の版は描かない）。線のない版はカードを横に並べる。`sync.py`が`milestoneHead`（HEAD.mdの版）をregistry.jsonへ出す。ユーザー「ENDを根としたDAGか」→`verify.cjs`に「各版フォルダのゲートと上流タスクはすべてそのENDに着く」を追加（15ノード）。最後にユーザー「班ごとじゃなくて全体で見たい」→初期表示を「全体」に（版の選択欄は残す）。sync完了・verify pass。画面の実表示は未確認（ユーザーのブラウザで確認待ち）。ユーザーの画面で「1.0 品質判断」が2枚（MS-QUALITYと、`graphData()`の旧特別扱いでQUALITY-001を到達点として描いたもの）。MS-QUALITYがあるときは旧特別扱いをしないよう修正（過去fixtureの検査は不変）。
- 追記14（2026-10-17）：ユーザー「タスクレジストリから削除しよう」（ユーザー同席の直接指示。Registry更新は本来Astraの担当なので受入で確認を）。`TASK_REGISTRY_V2.md`から`QUALITY-001`の行と、QUALITY-001を後続とするTask precedence 5行（RBT-001・RBT-009・RBT-034・QUALITY-002・QUALITY-003）を削除。6行は`Milestones/0.9.0/10_QUALITY-0001.md`の記録へ逐語で移した。Studioでは5本をMS-QUALITYへmaterialでつなぎ直し（出典は移した行）、MS-HUMAN→QUALITY-001は削除（列でMS-HUMAN→…→MS-QUALITYとつながる）。`verify.cjs`の描画確認リストをMS-QUALITYへ。Registry本文207行の過去判断の記録「1.0ゲート（QUALITY-001）との境界」は記録なので未変更。sync完了・verify pass（タスク43、依存7）。
- 追記15（2026-10-17）：仕様レビュー（姫）で版ゲートIDの衝突（0.1.10と0.11.0がともにGATE-0110）を指摘。ユーザー「GATE-0.5.4とかそのまましよう。ENDも同様でEND-0.5.4」。版ゲートIDを`GATE-x.y.z`、ENDを`END-x.y.z`（フォルダ名そのまま）に変更。6ゲートのIDと記録、`registry.json`の関係の端点、`verify.cjs`の固定ID5か所、`sync.py`の照合、READMEを追随。sync完了・verify pass。列：MS-DOC→END-0.5.3→GATE-0.5.4→…→GATE-1.0.0→END-1.0.0。レビューの残り（タスク→ゲートの線をカード情報へ、GATE→タスク付け替えの意味確認、verify固定IDの削減、旧ID記述の移行）は未着手。
- 追記16（2026-10-17）：ユーザー「正本とカードをわけよう」。11ゲートと`GATE_TEMPLATE`で`## 正本`をカード情報から出し、`# 正本`として独立させた（カード情報：ID・名前・状態、正本、記録の三部）。`sync.py`の読み取りとエラー文を追随、READMEに記載。sync完了・verify pass。

### `CP-20261017-003` — Registry Studio：registry.jsonを空から生成する

- queue状態: `AWAITING_CODEX`（実施済み・commit済み`5f090e1a`。受入はAstra。CP-20261017-002のRECONCILED（追記16まで）には含まれない）
- 発見元・ユーザー指示: ユーザー「JSON生成を姫がつくれないかな」
- 実施・検証: Astraの手順（1.関心度と古いスナップショットを外し表示順への影響だけ確認、2.空から組み立てる、3.既存JSONは差分確認用だけ・無くても生成、最後に既存JSONなしで再生成して一致を検証）に沿って実施。`sync.py`：`build()`を空から組み立てる形に（schemaVersion・source・tasks・edges・baseline・milestones・milestoneRelations・milestoneHeadのみ）、`displayInterest`と`milestoneSnapshot`を廃止、使われていなかった`milestone_sources`・`relocate_sources`と旧引用照合の分岐を削除、既存JSONが無いときも生成・失敗時の復元を両対応、差分報告にゲートと線を追加。`index.html`：関心度による並べ替えと吹き出しの関心度表示を削除（並びはDONEを後ろ・Registry順）。`verify.cjs`：恒久図の順の確認を関心度なしに。表示順への影響：独立タスク12件と恒久図10件の並びがRegistry順に変わる（見取り図本体は不変）。検証：registry.jsonを削除して生成→コミット済みのものとtasks43・edges7・milestones18・relations31がすべて一致、違いは`milestoneSnapshot`が無いことだけ。2回目は`--check`でずれなし。Studio README更新。
- Codex reconciliation: 未処理

### `CP-20261017-004` — マイルストーン移行の健全性回復（Astra調査A・B・Cの修正）

- queue状態: `AWAITING_CODEX`（実施済み・未commit。受入はAstra。OPS-047 / OPS-048）
- 発見元・ユーザー指示: Astra「マイルストーン移行後の健全性調査・姫への引継ぎ」（`Current/MILESTONE_HEALTH_AUDIT_2026-10-17.md`）。ユーザー「先にコミットしてから、タスクやって」（先にAstraの文書を`dacd456f`でcommit）。
- A（`index.html`）：ENDの代わりにGATEへ描く線は元のEND側の端点（`shownFor`）を保持。除去・つなぎ替えは元データの関係で行い、選んだ版ゲートはデータ上その手前のENDへ結ぶ（版ゲートへ入るのはENDだけ）。ゲートどうしの列は配置から作るので編集を断り案内を出す。除去で何も変わらなければ変更ありにしない。表示用の情報は保存JSONへ入らない。`verify.cjs`に、描画用に変換された線を入力して、取消・変更なし・列の拒否・除去・つなぎ替え・保存に表示用情報が無いことの検査を追加。
- B（`CLAUDE_PENDING_TASKS.md`）：CP-20261017-001・002の元entryのqueue状態とreconciliation行を、末尾のAstra照合結果（RECONCILED）へ合わせた。本文は返却時のまま。採番待ち表示はCP-20261016-013（凍結）とCP-20261017-003だけになった。
- C（`sync.py`）：HEAD.mdの欠落・不正、HEADの版フォルダ不在、ゲートIDが「なし」、ゲートIDとtask IDの衝突、恒久タスクの親子関係の崩れた行・存在しない親を、書き込み前に説明付きで止める（`build()`がerrorsを返し`main`は何も書かずに終了）。壊れた旧`registry.json`は読めない旨を出して正本から作り直す。JSONが無い場合も生成。
- Registry：Astraの`dacd456f`で恒久タスクの親子関係の行に詳細正本のパスが混入し（`` `OPS-059`  / `Maintanance/Current/MILESTONE_HEALTH_AUDIT_2026-10-17.md` ``）、OPS-059の親が読めずverifyが失敗していた。パスはOPS-047/048の詳細正本列に既にあるため、行を`2cfcd945`の形`` | `OPS-048` | `OPS-059` | ``へ戻した（上のCで今後は停止する）。
- 検証：不正入力4種（HEAD不正・HEADの版フォルダ不在・ID「なし」・task ID衝突）と親子行の崩れは一時コピーで停止・生成物不変を確認。実リポジトリで壊れた旧JSON→作り直し（内容一致）、JSON不在→生成、2回目`--check`ずれなし。sync完了・verify pass。
- 未実施：Safariでの実操作（Astraの受入確認項目）。理由：画面操作の手段がない。代わりにverifyで描画用の線を直接入力して確認。残存リスク：クリック経路（ダイアログ）の見た目と文言は未確認。解消：ユーザーかAstraがSafariで線をクリックし、除去・つなぎ替え・キャンセルを一度ずつ試す。
- commit: `39f81e5b`（A・B・C）。
- 追記（2026-10-17）：ユーザー「独立タスクの並びが違うんだ」「単に色なんだよね」。関心度を外した後、独立タスクの帯をStudioの状態の順（STATES：ACTIVE→WAITING_USER→WAITING_EXTERNAL→FROZEN→USER_ONLY→PROPOSED→DONE…）でまとめ、同じ状態の中はRegistry順にした（`index.html`の`stateRank`）。sync完了・verify pass。未commit。
- Codex reconciliation: 未処理

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

## Astra受入・統合（2026-10-17、マイルストーン移行）

原返却は保持し、CP-20261017-001・002のqueue状態と処理結果は本節を最新とする。

- CP-20261017-001：RECONCILED。文書分割・配置移行をOPS-047へ受入・統合。
- CP-20261017-002：RECONCILED。追記16までのゲート移行・Studio対応をOPS-047 / OPS-048へ受入・統合。恒久タスクはACTIVEのまま。
- 検証、Astraによる後続変更との区別、残る意味確認・古い説明の補正は[受入正本](Current/MILESTONE_MIGRATION_ACCEPTANCE_2026-10-17.md)を参照。リリース通過やUSER_ONLYの判断は代行しない。
- CP-20261016-013 / OPS-059は今回対象外、凍結維持。2026-10-17ユーザーが受入記録のコミットを承認。
