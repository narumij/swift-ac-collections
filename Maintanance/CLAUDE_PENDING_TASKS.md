# Claude採番待ちqueue

正式なRegistry IDへの照合・登録前に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。調整担当からClaudeへの個別依頼と返却は
[CLAUDE_TASK.md](CLAUDE_TASK.md)で扱う。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、他担当の完成判定を、明示的な委任なしに代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- ユーザーから委任された調整担当は照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- 委任された調整担当による照合・統合済みのentryの圧縮は、上記手順の範囲で、ユーザーの常設の委任としてClaudeが都度の確認なしで行ってよい。未処理のentryは動かさない。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。


状態名は`AWAITING_COORDINATOR`（調整担当待ち）とする。旧フィールド名`Codex reconciliation`は互換のため保持するが、処理担当をCodexに限定しない。委任された調整担当が実際の担当名を添えて照合結果を記録する。

## entry template

### `CP-YYYYMMDD-NNN` — <短い名称>

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_COORDINATOR` / `RECONCILED`
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

### `CP-20261020-005` — 連絡DB以後に姫が書いた内容の書き直し

- queue状態: `USER_AUTHORIZED`
- 発見元・ユーザー指示: 2026-10-20「ちょっと未採番タスクだな。連絡DBが出来て以後に姫が書いた内容、どこかmdファイルつくって、一個ずつ書き直して。」
- 対象範囲: 連絡DB（`approvals.sqlite3`）に姫が書いた返答89件（`letter_texts`のpart=reply、recorded_by=姫、27task、計310,159字）。原文は変えず（追記だけの表で変えられない）、新しいmd `Maintanance/Current/HIME_LETTER_REWRITES.md` に1件ずつ書き直す。DBは読み取り専用で開く。
- 訂正: 姫は最初「連絡DB以後に文書へ書いた節」と取り違えて別のmdを作った。ユーザー「いや、連絡DBの内容だよ？」で止め、そのmdは削除した。
- 対象外: 連絡DBへの書込み、受入・Registry更新、commit。
- 一時作業物: `Maintanance/Cache/Hime/Temporary/CP-20261020-005/`（実体同じ）・姫・2026-10-20 06:24・返答89件と依頼の冒頭の読み取り専用の書き出し（`dump.txt`）・状態「保持（書き直しと原文の照合用。受入のあと削除）」
- 成果・検証: 2026-10-20、89件すべてを`HIME_LETTER_REWRITES.md`に1件ずつ書き直した（依頼・書き直し・気づき）。冒頭に、通して見えたことを置いた（3,000字超52件、受入で戻された補正18件、戻された推奨の繰り返し、287件はV3の試験の数）。字数はdumpのヘッダから数えた。書き直しは姫の読みで、内容の照合は受入側に任せる。
- Codex reconciliation: 未処理

### `CP-20261020-004` — 未採番をDBの表にする（試作）


#### 取消済み依頼：ユーザーによる再依頼（2026-10-20、Astra中継）

ユーザー原文：「未採番DBのタスク依頼して。仕事が改善してるかどうか試したい」。今回の限定依頼を姫へ中継する。以下を現行範囲とし、下の取り下げ済みの範囲・旧試作を自動で復活させない。

- 現行queue状態: `RECONCILED`。ユーザー指示でこの未採番依頼を取消。正式タスク`OPS-185`へ仕切り直し。以下は履歴で着手指示ではない。担当：姫。返却先：ユーザーとAstra、この節のReturn。
- 目的：未採番1件を受け取る側が、長いMarkdownを読み直さず少ない手間で内容と処理状況を把握できること。成果を救済する追加調査をAstraへ押し戻さない。
- 最初の返答：現行CLAUDE.mdのCommunicationに従い、目的・最小の動く形・確認した事実を約10行でユーザーへ示す。単独動作という前提は確定済み。設計の承認を取り直すための往復は不要。
- 実施：専用SQLiteと小さなCLIで、自由テキストの登録・未処理一覧・1件の詳細・close・close後の履歴閲覧が一巡する、単独の試作を作り、自分で使う。Studio、既存サーバー、連絡DBを起動しなくても動くこと。日時はツールが自動記録する。
- 範囲：姫が所有する一時ディレクトリ内の試作と試験データ、このReturnのみ。過去試作は材料として使ってよいが、旧仕様を今回の要求に混ぜない。既存の採番待ち移行、本番接続、正式ID発行、commitは含めない。
- 返却：起動・使用コマンド、実物の場所、実際に試した結果、未達だけを短く示す。架空の利用者の感想や成功した体裁を成果にしない。
- 受入は3点：①既存サーバーなしで動く ②1件の登録→一覧→詳細→closeを受け手が再現できる ③close後も本文・処理結果を読める。確認のため追加調査や補修が必要なら、Astraが救済せず不足箇所を返す。
- 停止点：最小の一巡を返したところで止める。移行・UI・二周目の拡張は別依頼。

##### Return（姫）
未返却。

#### 以下は取り下げ時点の履歴

- queue状態: 取り下げ（2026-10-20 ユーザー「未採番タスクの、未採番DBの件、一旦取り下げて」）。以下は取り下げ時点の記録で、再開の指示ではない。試作の1周目以外（2周目の登録3件）は頼まれていない作業で、成果に数えない。
- 旧状態: `CANDIDATE`（2026-10-20訂正：姫が「さっきおれなんていったっけ」を着手の指示と取り違えて試作を始めた。着手の指示ではない）
- 目的（ユーザー判断、2026-10-20）: 「1番はあすとらさんの負担を減らすことだよ」。受入条件の中心は、調整担当が未採番の1件を受け取ってから照合・受入（または昇格・却下）するまでを、長いMarkdownを読まずに少ない手間と使用量で終えられること。他の条件（Studioで見える・時刻がある等）はこれを崩さない範囲。寿命：このtask（未採番のDB化）の判断。
- 2番目の目的（ユーザー、2026-10-20、これまで記録になかったもの）: DB化してスタジオサーバーに載せたのは「そもそも作業ページに多大な更新作業負荷がかかってたのをやめさせたかった」。今の採番待ちは`build-pending.py`がMarkdownを読みsyncでHTMLへ埋め込むため、1件の変更ごとに作業ページの作り直しが要る。サーバーがDBから直接返せばこの更新作業が要らなくなる。
- 受入条件: 未確定（姫の下書きは書く側に寄っていたとユーザー指摘。目的から作り直す）
- 最小案（2026-10-20、ユーザー「単独で動いて欲しい」・Astra同意で訂正）: 未採番の仕組みを単独で動かす。専用のSQLiteと小さなCLIで`add`・`inbox`・`show`・`close`が完結する。本文は自由テキスト。`close`は削除ではなく、通常一覧から外れ履歴として読める。Studio・連絡DBとの接続は後から（姫の前案は`approvals.sqlite3`と既存サーバーへの組み込みが前提で、ずれていた）。一括移行は試作を見てから。着手は未指示。
- 発見元・ユーザー指示: 2026-10-20、ユーザー（中継を含む）「未採番はDB化が合いそう」「まずは既存DBに未採番の表を足して、本文は自由なテキストのままでいい」「登録者・状態・関連タスクと、自動記録する日時」「正式タスクへの昇格は別操作」「B-1-1（Markdownからの移行）はあとできめられる」。手順は「隔離環境を確認しながら、一番簡単に実現できる方法を様々やってスタート地点をあわせる」の段階。
- 種別候補: `DISCOVERY`（使い捨ての試作）
- 対象範囲: RegistryAppのコードを一時ディレクトリへ複製し、その複製だけで`approvals.sqlite3`相当（一時DB）に未採番の表・追加/追記/状態変更のAPIとCLI・Studioの採番待ち表示を試作し、試験専用サーバーで見せる。
- 対象外: リポジトリ内のコード変更、本番DB・8088、Markdownの採番待ちの移行、昇格の操作、commit。
- 一時作業物: `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/CP-pending-spike.uvmmHTXhlb`（実体 `/private/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/CP-pending-spike.uvmmHTXhlb`）・姫・2026-10-20 02:21・RegistryAppの複製と一時DB・試験サーバー・状態「不使用（取り下げ）」。試験サーバーは10-20取り下げ時点で停止済み（プロセスなし）
  - `/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/CP-pending-standalone.kcpGq53o3O`（実体 `/private/var/folders/x9/2p70phpx3_xdvwx9s6gp35rm0000gn/T/CP-pending-standalone.kcpGq53o3O`）・姫・2026-10-20 04:22・単独の未採番DB試作（専用SQLiteと小さなCLI）とロールプレイ・状態「不使用（取り下げ）」。ユーザー「未採番DBを試作してみなよ。自分で使ってみなよ」
- 成果・検証: 作業中。10-20 04:23、単独試作`pending.py`（約80行・SQLite1ファイル）で登録側（姫）と受入側（Astra）を演じた。4動詞だけでは、(1)受入側が何をすればよいか本文から推測する、(2)「受領」でcloseすると残り条件（ユーザー確認後に本番反映）が隠れる、(3)後から来た情報を足せず重複登録になる、が出た。`add --ask`（してほしいことを1行、一覧に出す）と`note`（追記）を足すと、一覧だけで仕分けできた。closeを誰ができるかは制限していない。
- Codex reconciliation: 未処理

### `CP-20261020-003` — 担当から連絡を始める経路がない（姫が成果を連絡DBで渡せない）

- queue状態: `CANDIDATE`
- 発見元・ユーザー指示: 2026-10-20、CP-20261020-002のパッチを渡すとき、姫が連絡の送り手一覧（`Astra`・`ユーザー`）に入っておらず送れなかった。受入担当「連絡経路の別の不具合候補だね。今回の時刻修正とは分けて扱うのがよさそう」。
- 種別候補: `DECISION`
- 姫の確認（読み取り）: 送れる人の制限は設計どおり。連絡DB正本の調整判断3（546行）「初回の作業依頼発行は委任された調整担当とユーザー、受領/着手/返答は宛先担当」、588行「送れる人：委任された調整担当とユーザー」。壊れているのではなく、宛先担当が自分から成果・相談・発見を渡す種類の連絡がない（返答は届いた連絡の上でだけできる）。
- 対象範囲: 担当発の連絡（成果の受渡し・相談・報告）を設けるか、設けるならkindと権限（依頼の発行とは分ける）を決める。
- 対象外: 実装、送り手一覧の変更（判断の前に姫を足さない）。
- 担当候補・受入担当: 未定（判断はユーザー／調整担当）
- 成果・検証: 未着手
- Codex reconciliation: 未処理

### `CP-20261020-002` — 連絡の送信日時・受領日時を揃えて画面に出す

- queue状態: `RECONCILED`（ユーザー「パッチにしてあすとらさんに渡してもらおうかな」、2026-10-20）
- 発見元・ユーザー指示: 2026-10-20、`sentAt`が実はサーバー受領時刻で送信・受領の時刻が名前どおりに分かれていない件（姫が作ったもの：5360265bb・72ca7731f）。ユーザーの中継した仕様「サーバーが操作を成立させるときにイベントと時刻を一緒に保存」「画面には送信日時・受領日時」「本人による時刻入力は不要」。指示「1〜3をやって。隔離環境でまず見せて。欄の削除や過去データの書き換えは含めない」。
- 種別候補: `EXECUTION`
- 対象範囲: 1 送信の時刻を`sent`の出来事1つに揃え`sentAt`もそこから取る／2 軽量一覧と本文に`receivedAt`（最初の本人の受領）を足す／3 画面に「送信日時」「受領日時」、他の出来事は「記録日時」。
- 対象外: 欄の削除（`claimed_at`含む）、過去データの書き換え、本番8088・本番出力・本番DB、commit。
- 停止条件: 隔離環境でユーザーに見せた時点で止める。本番反映はユーザーの確認後。
- 一時作業物: 見せ用サーバーは既存の`OPS-183-184-demo`一時ディレクトリ（OPS-183正本に記録済み）を再利用、http://127.0.0.1:54051/ 。
- 成果・検証: 実施（未commit・本番未反映）。`studio_store.py`：送信は時計を1回だけ読み`letters`と`sent`の出来事に同じ時刻／一覧と本文の`sentAt`は`sent`の出来事から、`receivedAt`は本人の最初の`received`から（代理は数えない、未受領はnull）。`index.template.html`：一覧の行に「送信日時 … · 受領日時 …|未受領」、本文の出来事は送信日時・受領日時・記録日時、本文の版は記録日時。先に失敗を確認した試験：`test-studio-letters.py`の新1件（時計2回で失敗）・`test-view-model-letters.cjs`の追加分（「サーバー受領」で失敗）→実装後に通過。`test-*.cjs`全部・`test-*.py`は`test-letters-lanes-browser.py`以外通過。同試験は本番サーバーのログ`Cache/RegistryStudio/production-server.log`が試験中に書き換わり、`v3/hermetic`のlive指紋が一致しないため失敗（試験自体の判定は通過。本番の8088が動いているためで、この変更とは無関係。直していない）。過去データは書き換えていない（古い連絡は表示だけが`sent`の出来事の時刻に変わる、差は最大約1ミリ秒）。
- 受渡し: パッチ`Current/Evidence/CP-20261020-002/letter-times.patch`（153行、sha256 `90206ee7d224bbc43272438bcc226c8a294e453d6ce08157432a7f84ef0d4955`、基準`126f189a7`、対象4ファイル。`git apply --check --cached`で基準に当たることを確認）。作業ツリーの変更も同じ内容のまま残してある（姫はcommitしない）。姫は連絡の送り手一覧に入っていないため、連絡DBでは送れない。本番反映前にユーザーが隔離環境 http://127.0.0.1:54051/ で確認する。
- 受入向けの照合（2026-10-20、受入担当の指摘「stashの適用は途中で失敗しても一部の変更が入る場合がある」を受けて）: 実差分（対象4ファイルの`git diff --binary`）とパッチを`cmp`でバイト一致を確認。`git diff --name-only HEAD`は対象4ファイルと本queueだけ。誤って当てかけたstash（`rights-notice-before-history-rewrite-20261016`）の追跡ファイル4つ（LICENSE・Maintanance/DOCUMENT.md・README.ja.md・README.md）はHEADと差なし、未追跡扱いの2つ（Maintanance/LICENSE.md・Maintanance/User/AI_MEMORY_SUPPORT_RIGHTS_INTENT.md）は追跡済みでHEADと差なし・更新時刻10-17 00:02:53のまま。stashは`stash@{0}`に残っている。
- Codex reconciliation: 2026-10-20 Astra受入。ユーザー「検収して、よければ取り込んでください」に基づく。基準126f189a7からの対象4ファイルのdiffと提出patchがバイト一致、sha256一致。送信時刻一本化、本人の最初の受領のみ、閲覧非記録、再送時刻保持を確認。連絡25試験、letters VM/DOM、既存member連携検査が成功。パッチは作業ツリーへ適用済みのため再適用しない。既存DBの書換え・claimed_at削除なし。本番再起動後、配信HTMLの日時表示と一覧APIのreceivedAtを確認済み（画面目視は未実施）。commitは未実施。

### `CP-20261020-001` — 出どころをまたいだ時間順のログ（試作）

- queue状態: `USER_AUTHORIZED`
- 発見元・ユーザー指示: 2026-10-20、ユーザー「欲しいのはタイムラインなんだよね」「ログでもいいんだけど、多少整形したものがみたかったんだよね。整理したいかって、まず時間軸なんだ」。
- 種別候補: `DISCOVERY`（一番簡単な形での試作。画面・コードは変えない）
- 対象範囲: 旧活動・連絡の出来事・commit・承認・判断DBを読み取り専用で集め、日本時間の時刻順に1本のMarkdownへ並べる。
- 対象外: Studioの変更、DBへの書込み、本番サーバー。
- 一時作業物: `Maintanance/Cache/Hime/Temporary/timeline/`（姫・2026-10-20・試作のスクリプトと出力・状態「使用中」。ユーザーの確認まで残す）
- 成果・検証: 試作1。`timeline.py`（読み取り専用）で10-19 21:00以降の170件を`timeline-20261019-2100.md`へ。限界：Registry DBの操作は時刻を持たず入らない／本番出力はファイルの最終更新時刻1点だけ（00:24の作り直しは01:20で上書きされ見えない）／活動の文は140字で切る。
- Codex reconciliation: 未処理

### `CP-20261019-006` — Studioの表示・経路の接続もれ全点検（報告）

- queue状態: `AWAITING_COORDINATOR`
- 発見元・ユーザー指示: 2026-10-19、ユーザー「他に接続もれがないか、全点検してリストアップして、報告の未採番追加しといて」。
- 種別候補: `DISCOVERY`（報告のみ。修正なし）
- 方法: serve.pyの固定route全部と、画面テンプレートがそれぞれを呼ぶ回数、埋め込みseedを機械で数え、各routeの読む先をコードで確かめた。DBは読み取り専用。スクリプトと出力は`Current/Evidence/CP-20261019-006/`（`audit_sources.py`・`audit_sources.out.txt`）。他の利用者は`comm.py`・試験・正本のgrepで当てた。
- 結果A（つながっている）: 構造のseedと`/registry.json`（V3 DB、read-only）、`/workspace`（V3保存）、連絡の一覧・本文（`/letters?`・`/letters/<id>`→approvals.sqlite3のletters）、`/commit-approvals`（approvals.sqlite3）、`/sync`・`/save`・`/server-status`。文書の束（`documents`）はファイルが正本で設計どおり。
- 結果B（既に記録済み）: 依頼中（001、削除済み）、採番待ち（002）、メンバー状態（003）、最近の作業の活動と待機完了（004）、承認レーンと実commit（005）。
- 結果C（今回の新規。旧経路が残る）:
  - C1 「作業イベントの履歴」帯：`/activity-events`→`Activity/events.jsonl`。003・004と同じ出どころの別の欄。連絡DBの事象は出ない。004へ統合候補。
  - C2 継続確認：`/continuity`（`serve.py:149`）→`Activity/continuity.json`（`continuity.py:15`、OPS-139）。ファイルで、連絡DBと別。003へ統合候補。
  - C3 「疎通確認（動作確認専用）」欄：`/approval-probe`→`Approvals/probe.sqlite3`（承認の形での疎通、7件）。実運用の疎通は連絡DBで確認済み（H-20261019-36受入）。残すか外すかの判断が必要。
  - C4 PING送信の宛先一覧：`serve.py:439`が`events.jsonl`の`owner`から作る。連絡DBの宛先（`/letters-senders`等）と別。PINGの旧経路切替はOPS-156で保留中、同所へ統合候補。
- 結果D（画面が読まないroute。意図は未確認）:
  - D1 `/activity-commits`（`serve.py:103`、git logの直近30件）：画面は`kind`を`['events']`だけ回す（`index.template.html:1301`）。当初設計（`REGISTRY_STUDIO_ACTIVITY_TIMELINE.md`）は下段にcommitを出す。外した経緯は未確認。005の材料（直接許可のcommitを出す出どころ）になりうる。
  - D2 `/work-progress`（`serve.py:76`）：画面からの参照0、出力に`work-progress.json`なし。試験と正本の記述だけ残る。廃止か未接続かは未確認。
  - D3 `/comm-messages`・`/studio-operations`・`/approvals-cli`・`/comm-ping`・`/comm-ack`・`/comm-cutover`・`/letters-send`等：画面からは0、`comm.py`と試験が使う。CLI用で設計どおりと見られる（未確認）。
  - D4 判断DB（`RegistryApp/decisions`、Data/decision-assist.sqlite3）：Studioに表示なし。OPS-158ではCLIでの日常利用として配備。設計どおりと見られる。
- 対象外: 修正、DB・schema変更、本番8088・本番出力・ユーザー画面の操作。CLI・AI側の手順文書の経路は点検範囲外（画面とserverのrouteに限った）。
- 担当候補・受入担当: 姫（点検）／調整担当（受入・C1〜C4とD1・D2の採否、既存003〜005への統合）
- 停止条件: 点検の返却で止まる。
- 成果・検証: 実施済み（上記）。数え方の限界：文字列での照合なので、動的に組むroute名は`/activity-`の1件だけ手で足した。literalでないfetch呼び出し4か所（`fetchJson(letterListQuery)`・`fetch(path)`・`fetchRecord(endpoint)`・`fetchRecord()`）は手で読み、既出の`/letters?`・承認・`/continuity`に当たることを確かめた。
- Codex reconciliation: 未処理

共通の発見元（003〜005）: 2026-10-19、CP-20261019-001の後にユーザーがStudio作業側を順に点検。「作業のメンバー状態もDBとつながってなさそうだね」「最近の作業もつながってないね」「コミット事前承認もつながってないね」「作業内訳を添えて、接続依頼をそれぞれについて未採番に追加しといて」。002と同じく、V3・連絡DBへの切替で表示の出どころが旧経路に残った群。内訳は姫の見立てで、担当・採否は調整担当が決める。

### `CP-20261019-005` — 「最近の作業」とコミット事前承認レーンを実際のcommit運用へ接続

- queue状態: `CANDIDATE`
- 発見元・ユーザー指示: 上記共通。姫の確認（読み取り専用）：画面は`/commit-approvals`→`Approvals/approvals.sqlite3`を読み、配線は有効（`serve.py:283`）。ただし最後の承認記録は10-19 06:03 JSTのfinishで、47件ほぼ使用済み。同日21:57〜22:59の12 commitは承認レーンを通らず、ユーザーの直接許可（AGENTS.md:78の外）で行われ、画面に出ない。承認とV3 task・実commitの照合有無は未確認。
- 種別候補: `DECISION`→`EXECUTION`（直接許可のcommitを画面に出すかはユーザー判断）
- 作業内訳（案）:
  1. 現状の固定：承認の各状態と`commitSha`の記録経路、レーンの表示条件を読む。照合の有無を確かめる。
  2. 判断材料：直接許可のcommitを表示に含めるか（含めるなら出どころはgit logか、記録用の新しい事象か）、承認レーンを今後も使うかをユーザーへ返す。
  3. 決定後の実装：表示の出どころを追加／整理し、承認DBの意味（承認≠実行）を保つ。
  4. 試験：一時DB・試験サーバーで、承認経由・直接許可・混在の3通りを確認。8088・本番DBに触れない。
- 対象外: AGENTS.md:78の変更、承認DBのschema変更（判断前）、commit・push。
- 完了条件: 判断が記録され、決定どおりの表示が試験で確認される。
- 前提・既存task候補: OPS-114／OPS-119（承認・作業レーン）系、OPS-156（approvals.sqlite3に連絡の表も同居）。
- 担当候補・受入担当: 未定（ユーザー判断が先）
- 停止条件: 判断前に実装しない。
- 成果・検証: 未着手
- Codex reconciliation: 未処理

### `CP-20261019-004` — 「最近の作業」の活動と「待機完了」を連絡DBへ接続

- queue状態: `RECONCILED`（OPS-184へ正式登録）
- 発見元・ユーザー指示: 上記共通。姫の確認：欄は「直近200件の活動＋未完の承認」から作られ、活動は旧経路`Activity/events.jsonl`（`/activity-events`）。連絡DBの受領・担当中・返答済みは入らない。「待機完了」ボタンは`/activity-wake`へ送る（中身は未確認）。
- 種別候補: `EXECUTION`（接続方法の小判断を含む）
- 作業内訳（案）:
  1. 現状の固定：`workLaneItems`の入力と、`/activity-wake`が書く先・誰が読むかを確かめ、既存試験（`test-work-lane.cjs`等）を控える。
  2. 対応表：連絡DBの状態（sent/received/started/returned/declined/withdrawn/stopped/closed）を作業カードの段階へ写す案を作る。旧活動を残すか（併記・置換）を調整担当へ返す。
  3. 実装：レーンが`/letters?brief=1`も読む。待機完了は連絡DBの連絡（停止要請や専用kind）へ寄せるかを2の判断に従う。
  4. 試験：一時DBで状態ごとのカードを確認し、既存試験の差分を説明する。
- 対象外: 連絡DBの状態遷移の変更、メンバー状態（003）、承認（005）。
- 完了条件: 連絡DBでの受領・着手・返答がレーンに出る。待機完了の経路が決定どおり。
- 前提・既存task候補: OPS-156（PINGの旧経路切替・画面は保留中）、OPS-119。003と同時に行うと重複が減る。
- 担当候補・受入担当: 未定
- 停止条件: 2の判断がない間は3へ進まない。
- 成果・検証: 未着手
- Codex reconciliation: 2026-10-19 Astra：OPS-184へ登録。[詳細正本](Current/STUDIO_WORK_LANE_LETTERS_CONNECTION.md)に既存内訳を引継ぎ。第1区切りは現状確認・対応表。依頼未送信、実装未承認。

### `CP-20261019-003` — 「メンバー状態」を連絡DBへ接続

- queue状態: `RECONCILED`（OPS-183へ正式登録）
- 発見元・ユーザー指示: 上記共通。姫の確認：ランプは`/activity-events`→`Activity/events.jsonl`（`activity.py:12`）から作られ、連絡DBの状態を読まない。姫の最後の記録は22:26のACK WAKE…OPS158-CLOSEで、以後の作業はランプに出ない。
- 種別候補: `EXECUTION`（出どころの小判断を含む）
- 作業内訳（案）:
  1. 現状の固定：`createMemberLampView`の入力・「新着」「継続確認」の条件と既存試験（`test-view-model-members.cjs`）を控える。
  2. 出どころの案：本人申告（旧活動）と連絡DBの宛先ごとの開いた連絡（`/letters-inbox?owner=`）をどう合わせるか。本人申告を連絡DBへ移すかは調整担当へ返す。
  3. 実装：ランプが連絡DBも読む。読めないときの表示を決める。
  4. 試験：一時DBで、担当中・返答済み・連絡なしのランプを確認。
- 対象外: 連絡DBの仕様変更、最近の作業（004）。
- 完了条件: 連絡DBで受領・着手した担当がランプに反映される。
- 前提・既存task候補: OPS-156、OPS-151（開始待ち）。004と共通の読取部品にできる。
- 担当候補・受入担当: 未定
- 停止条件: 2の判断がない間は3へ進まない。
- 成果・検証: 未着手
- Codex reconciliation: 2026-10-19 Astra：OPS-183へ登録。[詳細正本](Current/STUDIO_MEMBER_LETTERS_CONNECTION.md)に既存内訳を引継ぎ。第1区切りは現状確認・対応表。依頼未送信、実装未承認。

### `CP-20261019-002` — 採番待ちqueueをV3 DBへ移す機能の検討

- queue状態: `CANDIDATE`
- 発見元・ユーザー指示: 2026-10-19、CP-20261019-001の作業中に、V3 DBに採番待ちの表がないと判明（表は`proposal_map`〈Studioの追加案と正式IDの対応、0件〉と`id_allocations`等のみ）。画面の「採番待ち」は今も`build-pending.py`がMarkdownの`CLAUDE_PENDING_TASKS.md`・`FABLE_PENDING_TASKS.md`から作る。ユーザー「もしかして、DBに採番待ち機能ないの？ｗ」「今の採番まちに、採番待ち機能をDBに追加する検討を依頼って追加しておいてｗ」。
- 種別候補: `DECISION`（検討。実装は別判断）
- 対象範囲: 採番待ちをDBで持つか、持つならどのDB（registry／連絡／別）・書込み経路（CLI）・既存Markdown queueの扱い・Studio表示の出どころを検討し、案を返す。
- 作業内訳（案、10-19追記）:
  1. 現状の固定：queueの項目・状態（CANDIDATE〜RECONCILED）・`build-pending.py`の読取規則、V3の`proposal_map`との違いを書き出す。
  2. 置き場の比較：registry DB（採番と同じ所）／approvals.sqlite3（連絡と同じ所）／Markdown維持の3案で、書込み担当・CLI・backup・正本の関係を並べる。
  3. 移行案：既存8＋本日分の扱い（写す・凍結・並行しない）と、`CLAUDE_PENDING_TASKS.md`・`FABLE_PENDING_TASKS.md`の役割を案にする。
  4. 返却：採否の材料を正本へ。実装は別判断。
- 対象外: 実装、DBのschema変更、既存queueの移行・削除。
- 完了条件: 検討結果（採否の材料と案）が正本に残り、採否はユーザー／調整担当が決める。
- 前提・既存task候補: V3 Registry（OPS-167系）、連絡DB（OPS-156）。CP-20261019-001と同じ「切替で旧経路に残った表示」。
- 担当候補・受入担当: 未定（ユーザー／調整担当が割当）
- 停止条件: 検討の割当がない間は着手しない。
- 成果・検証: 未着手
- Codex reconciliation: 未処理

### `CP-20261019-001` — Studioの旧「依頼中」欄の削除

- queue状態: `AWAITING_COORDINATOR`
- 発見元・ユーザー指示: 2026-10-19、ユーザー「依頼中が6件みえるんだけど、実際どうなんだろ？」→調査で6件とも返却・受入済みと判明。「そもそも欄自体を削除しようか。作業だしな、区分としては」「じゃ、それやって」。Astraの使用量に余裕がないため姫が実施。
- 種別候補: `EXECUTION`
- 対象範囲: `RegistryApp/index.template.html`（欄・`renderRequests()`・呼び出し・専用CSS・リセット確認文の語）、`RegistryApp/build-pending.py`（依頼票の読取と`requests`出力）、`RegistryApp/README.md:292`へ一行。
- 対象外: 採番待ちの表示、連絡DB、本番DB・8088・本番出力への書込み、commit。
- 完了条件: 欄が生成されず、採番待ちと既存試験が変わらない。
- 前提・既存task候補: OPS-156（連絡DB。依頼は連絡で見る）への統合候補。統合か別IDかは調整担当が決める。
- 担当候補・受入担当: 姫（実施）／調整担当（受入）
- 停止条件: 修正が2つ続く、または採番待ち・既存試験が変わる。
- 成果・検証: 実施済み。詳細と一時作業物の記録（削除済み）は`Current/STUDIO_COMMUNICATION_STORE.md`末尾「姫：旧『依頼中』欄の削除」。V3 sync・`verify_v3.cjs`・`test-*.cjs` 23本・`v3/test_serve_v3_mode.py` 12件が変更前後で一致、headless WebKitで欄なし・エラー0。本番画面はユーザーの「正本から新しく始める」で反映を確認（欄が消え、採番待ち0件。0件は本queueの全8件がRECONCILEDで正しい）。未commit。
- Codex reconciliation: 未処理

### `CP-20261018-005` — Registry Studio ユーザビリティ改善案（姫）

- queue状態: `RECONCILED`（OPS-125へ正式接続、提案資料受領・実装なし）
- 発見元・ユーザー指示: 2026-10-18、試験専用headlessで見取り図を触った後、ユーザー「ひめタスクでユーザビリティ改善案つくっといてよ」。
- 範囲: 試験専用サーバー（別ポート・空の一時Inbox）をheadlessで見て、案を`Current/STUDIO_USABILITY_PROPOSAL_HIME_20261018.md`に書いた。根拠のスクリーンショット4枚は`Current/Evidence/CP-20261018-005/`。
- 対象外: 実装、使用中のサーバー・ブラウザ・編集データ、保存・承認の操作。
- 結果: 案8件（ヘッダーの固定範囲、スクロール位置、「開始不明」表示、局所図の題名切れ、ホバー説明が残る件〈実機は未確認〉、カード一覧の編集欄、狭い画面、到達点への線の集中）と、推奨の順番。試験サーバーとブラウザは終了済み、一時ファイルは削除済み。
- Codex reconciliation: 2026-10-18 Astra：OPS-125（USER_ONLY、親OPS-048）へ登録。案8件と証拠の所在を受領。既存OPS-089は保存操作の採否なので統合せず、表示・閲覧の採否を別扱い。観察の独立再現・実装承認は含まない。

### `CP-20261018-004` — 判断座標草案の10-18改訂と、姫のキャッシュの手入れ

- queue状態: `RECONCILED`（TEST-005へ統合・限定受領）
- 発見元・ユーザー指示: 2026-10-18、判断座標（`Testing/JudgmentCoordinates`）を今の景色から見直した会話の後、ユーザー「改訂したければどうぞ。他にもお手入れ作業してどうぞ」。
- 範囲:
  1. `Testing/JudgmentCoordinates/JUDGMENT_COORDINATES.md`の10-18改訂。変更箇所に「（10-18改訂）」と付けた。
     - 持ち主の表：メンテナンス役、`Cache/Hime/`、Fableの代理、共通規則も表に含む。
     - 4節：キャッシュの文は確定の写し（OPS-101の4種）。
     - 5節：FOCUS.mdとの関係（遅延評価の情報への拡張）。
     - 7節：OPS-096の実地例。「調整役Codex」の名前を役割へ直した。
     - 9節：要約後の再開とOPS-096初回の観察。
  2. 姫のキャッシュ（Git管理外）。
     - `CURRENT.md`に失効の印（本文は保持）。
     - `STUDIO_JUDGMENTS.md`：§1の欠落を補った。§3は共通規則の根拠を書き、補助は断らないと明記。§4は0.6.1へのリンク修正と「蒸し返さない」の範囲の限定。
  3. 姫の自動メモリーに1件（共通規則は照合範囲の内側）。
- 対象外: 原本（Archived）・回収写し・README・FOCUS.md・DESIGN.md・他担当のキャッシュ・規則。規則への昇格はしない（草案10節のまま）。
- 結果・検証: 文書の変更だけ。リンク先`Milestones/0.6.1/10_SPI.md`の存在を確認した。commitなし。
- 調整担当による照合・統合: 2026-10-18 Astra。改訂commitとローカルキャッシュを確認し、TEST-005の恒久維持へ統合。TEST-008は完了維持。草案・自己報告・規則を区別し、自動メモリーの実体は未確認。詳細は[受領記録](Current/JUDGMENT_COORDINATES_REVISION_RECEIPT.md)。追加依頼なし。

### `CP-20261018-003` — DESIGN.mdへの姫の感想

- queue状態: `RECONCILED`（OPS-043へ感想として受領）
- 発見元・ユーザー指示: 2026-10-18、ユーザーが`Maintanance/DESIGN.md`を添付し「これの感想も書いて欲しいかもw」（CP-20261018-002に続く未採番の依頼）。
- 範囲: 感想を`CLAUDE_OBSERVATIONS.md`の2026-10-18「DESIGN.mdを読んで：型はユーザー、実装はAI」に記入（常設の委任）。
- 対象外: DESIGN.md（ユーザー作成物、AIの改変禁止）・FOCUS.md・規則の変更、変更提案。
- 結果: 感想のみ。要点は4つ。
  - 構造はユーザー、情報設計はAIという委任が、FOCUS.mdで実際に動いている。
  - Studioは判断の場として使われ始めている。
  - 外部仕様が黙っている所でAIの解釈が入る（OPS-096）。
  - 小さい仕事で作業内訳を省いていた自省。
- Codex reconciliation: 2026-10-19 Astra：OPS-043へ感想として受領。DESIGN.mdに関する姫本人の感想本文を照合。規則・設計の変更や提案の実行承認ではない。

### `CP-20261018-002` — FOCUS.md草案への姫の感想

- queue状態: `RECONCILED`（OPS-043へ感想として受領）
- 発見元・ユーザー指示: 2026-10-18、ユーザーが`Maintanance/FOCUS.md`を添付し「未採番で感想書いて」。
- 範囲: 感想を`CLAUDE_OBSERVATIONS.md`の2026-10-18「FOCUS.mdを読んで：忘れるのは、捨てることではなかった」に記入（常設の委任）。
- 対象外: FOCUS.md本体・DESIGN.md・規則・キャッシュの変更、草案への提案。
- 結果: 感想のみ。要点は3つ。
  - 「忘れる＝通常の探索対象から外す」は、今日の経験（OPS-100・101）と合う。
  - 範囲外の共通規則（OPS-101第2回の誤分類の原因）は、現在地にかかわらず範囲内に数えるとよさそう。
  - 全履歴を読まずに再開できた例が1件ある（観察1回）。
- Codex reconciliation: 2026-10-19 Astra：OPS-043へ感想として受領。FOCUS.mdに関する姫本人の感想本文を照合。一回の観察として保持し、一般的効果や規則へ昇格しない。

### `CP-20261018-001` — GRAPH-001：マイルストーンの取り扱いと、正本のみ／編集込みの健全性確認

- queue状態: `RECONCILED`（GRAPH-001へ限定受入）
- 発見元・ユーザー指示: 2026-10-18、Studioサーバー停止中の初回メンテナンスの文脈で、ユーザー「未採番で、マイルストーンの取り扱いと、正本のみの健全性確認と、編集も合わせた健全せいの確認ができるようにしてほしいかな」。
- 範囲: 姫のlocal projection（`.task-graphs/`、Git対象外）と、GRAPH-001の正本`Maintanance/Graph/TASK_GRAPH_DB_EXPERIMENT.md`への記録。
  - マイルストーンをtaskと同じグラフで扱う（線の意味：必須・材料・開始・到達後、`why`・`impact`がたどる）。
  - `health canon`（正本だけの健全性）と`health edit`（編集版・Inboxを含む健全性）。どちらも読み取りだけ。
- 対象外: Registry・Studio・Inboxの変更、検査規則の一般化（2026-10-18のAstra確認どおり、個別判定は規則にしない）。
- 結果・検証：実施済み。正本の「マイルストーンの取り扱いと健全性確認（2026-10-18、CP-20261018-001）」節に記録した。
  - `health canon`・`health edit`はどちらも現行でPASS。
  - ツール自身の検査は39項目PASS。
  - `why`・`impact`は到達点をたどる。
- Codex reconciliation: 2026-10-19 Astra：GRAPH-001へ限定受入。一時DBで39項目fixture、health canon/editをAstraが独立実行し通過。現行task109・依存10・到達点29・接続26、Inbox7件、要確認0。古い土台の情報は保持。正本末尾へ範囲を記録。

### `CP-20261017-014` — Registry Studio：依頼中のtaskを表示する

- queue状態: `RECONCILED`（OPS-048へ統合・Astra受入）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「依頼状態もスタジオでみたいなぁ」→姫が作業内訳を返す→「いったんこみっと。依頼状態みれるようにしよう」。
- 実施: `build-pending.py`に依頼票（`CLAUDE_TASK.md`・`FABLE_TASK.md`）の`## <TASK-ID> — 題名`節を読む処理を追加。Registryの行と照合し、Registryにあって未完（DONE・EXCLUDED・ARCHIVED以外）のものだけを「依頼中」として出す。Registryから圧縮済みのIDの節は履歴として出さない。同じIDの節が複数あれば本文をまとめて1件にする。`index.template.html`に「依頼中」欄（採番待ち欄の上）と`renderRequests`を追加。カードに状態・依頼票の持ち主・Registryの担当を表示し、押すと依頼票の節の原文を開く。カードの横にtaskカードと同じ「正本」リンク（Registryの行が指す正本）を付けた（ユーザー「正本リンク足して欲しい。確認の手間がふえるから」）。依頼カードは中身に合わせて高さを伸ばす（task用の固定高で切れた崩れを修正）。宛先（姫・Fable）ごとに行を分け、依頼のない行と、全体が0件なら欄ごと非表示（ユーザー「Fableと姫は2行に分けた方がいいな。で、無ければ非表示」）。状態の正本はRegistryのまま。
- 検証: `sync.py`で生成とverify通過。生成HTMLの`pendingSeed`で依頼中はOPS-074（ACTIVE・姫）とOPS-063（ACTIVE・Fable）の2件。verifyに依頼表示専用の検査は足していない。Safariでの見た目は未確認。
- 対象外: Registry・依頼票の変更、依頼状態の新しい正本化。
- commit: していない。
- Codex reconciliation: 2026-10-17 Astra：OPS-048へ統合・限定受入。sync/verifyと生成requestsの照合済み。Safari未確認。詳細はCurrent/TASK_REGISTRY_APP.md。

### `CP-20261017-015` — Registry Studio：常設task数の決め打ち検査で同期が止まった件

- queue状態: `RECONCILED`（OPS-048へ統合・Astra受入）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「スタジオがこわれて真っ赤なのですが」。
- 実施: `sync.py`がverifyで止まり、生成物が前の版へ戻っていた。原因は`verify.cjs` 118行の`assert.equal(permanent.length,10)`で、OPS-077（常設）の追加により11件になっていた。件数を`original.tasks.filter(t=>t.permanent).length`と照合するように変え、下限10件の検査を残した。
- 検証: `sync.py`で生成とverifyが通過。Safariの表示は未確認。
- 対象外: Registry・テンプレートの変更。
- Codex reconciliation: 2026-10-17 Astra：OPS-048へ統合・受入。commit照合とverify再実行PASS。Safari未確認。詳細はCurrent/TASK_REGISTRY_APP.md。

### `CP-20261017-016` — OPS-076追記のうち判断にはみ出した記述の再検証と再送

- queue状態: `RECONCILED`（OPS-077へ統合・補正付きAstra受入）
- 発見元・ユーザー指示: 2026-10-17、ユーザー「判断にはみだすと、それって依存が何層かあるはずなので、判断抽出したものについて再検証と、全体の再送をおねがいしたいが」。OPS-076はDONE後の直接依頼。
- 実施: 15件を抽出し、依存の層を固定版`1175e583`で確かめ直した（[JUDGMENT_RECHECK.md](Current/Evidence/OPS-076/JUDGMENT_RECHECK.md)）。支持7、範囲限定4、取り下げ4（うち2件は受入時に補正済み）。`CANONICAL_EVIDENCE_ROLLOUT.md`の末尾に再送のReturnを置いた。元の追記・Return・証拠は書き換えていない。
- 対象外: OPS-076の状態変更、各判断そのものの精査（OPS-077の範囲）。
- Codex reconciliation: 2026-10-17 Astra：OPS-077へ統合し、OPS-076正本末尾へ補正付き受入を記録。15項目の優先精査。19件・77件は実施件数として維持し、全判断の再承認とはしない。OPS-076はDONE維持。

[2026-10-17の照合・圧縮記録（2）](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-17_2.md)：CP-009→OPS-075、010→OPS-048、011→OPS-070/071、012→OPS-073、013→OPS-074。未完作業は各正式taskで追跡する。

2026-10-17までのreconciliation済みentry（CP-20261016-013、CP-20261017-001〜008）と2026-10-16〜17の照合節の原文は[2026-10-17の圧縮記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-17.md)へ保存。CP-013はOPS-059（FROZEN）、001〜004はOPS-047 / OPS-048、005はOPS-048、006はQUALITY-002、007はRBT-048判断材料、008はOPS-044へ統合済み。

CP-004〜012は[照合済み履歴](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_3.md)、CP-014〜016は[原文と統合結果](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_4.md)へ保存済み。

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-15_2.md`（`CP-20261015-006`→`OPS-042`）

- [2026-10-16の照合記録](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16.md)（CP-20261015-007 → PERM-072）
- [2026-10-16の照合記録（2）](Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-16_2.md)（CP-20261016-001〜003 → HIST-003・TEST-006・TEST-007）
