# メンバー状態を連絡DBへ接続する

## TL;DR
連絡DBの受領・着手と本人申告を区別して表示する。返却済みから本人待機を推定しない。
姫がすでに提出した内訳を使い、現状確認・対応表の受入後に実装へ進む。内訳の再提出を求めない。

OPS-183 / ACTIVE / 2026-10-19。ユーザー指示で正式登録。担当：姫、受入：調整担当。第1区切り受入済み。実装・試験を姫へ依頼（下記）。原返却：CP-20261019-003（CLAUDE_PENDING_TASKS.md）。親OPS-048。

## 既存の作業内訳（姫の案を引継ぎ）
  1. 現状の固定：`createMemberLampView`の入力・「新着」「継続確認」の条件と既存試験（`test-view-model-members.cjs`）を控える。
  2. 出どころの案：本人申告（旧活動）と連絡DBの宛先ごとの開いた連絡（`/letters-inbox?owner=`）をどう合わせるか。本人申告を連絡DBへ移すかは調整担当へ返す。
  3. 実装：ランプが連絡DBも読む。読めないときの表示を決める。
  4. 試験：一時DBで、担当中・返答済み・連絡なしのランプを確認。

## 区切りと受入
- 最初は上記1・2。コードと現行規約を確認し、出どころ・表示・操作の対応表を返す。全履歴を調査し直さない。
- 調整担当が既存要求との一致を確認する。既決事項は再度ユーザーに聞かず適用し、新しい意味や権限の判断だけユーザーへ返す。
- 3・4は対応表の受入後、実装範囲・担当・完了条件を明示して依頼する。現在の登録だけでは実装を開始しない。
- 一時DB・試験サーバーで入力→VM→実画面まで確認し、必要な操作は送信→受信→本人応答まで通す。部品試験だけで接続完了としない。既存試験を維持できた範囲と変更理由を残す。本番再起動や本番DB変更は別途依頼された範囲のみ。

## 境界
連絡DBの受領・着手と本人申告を区別して表示する。返却済みから本人待機を推定しない。
通信不能を連絡なしと表示しない。本人の状態と一件の依頼状態を区別する。承認・commit運用（CP-005）は対象外。通信規約や状態遷移の変更が必要なら、実装を進めず具体的な差分を返す。

全連絡原文・履歴へのユーザーアクセスは元の要求として維持する。この表示修正だけでその要求全体を達成したとは扱わない。全点検CP-006は関連する証拠として必要箇所だけ参照する。

## 参照
- [通信規約](COMMUNICATION_PROTOCOL.md)
- [連絡DB正本](STUDIO_COMMUNICATION_STORE.md)
- [Studio利用手順](../RegistryApp/README.md)

## Return / Acceptance

### 姫返却（第1区切り：現状確認と対応表、2026-10-19）
ユーザー直接指示「タスクやって」（OPS-183・184の第1区切り）。基準commit `0dada5204`。コード・DB・サーバーは変えていない。DBは読み取り専用で開いた。

**1. 現状（コードで確認）**
- 入力は`/activity-events`（`Activity/events.jsonl`の直近200件）と`/continuity`（`Activity/continuity.json`）だけ。連絡DB（`approvals.sqlite3`の`letters`・`letter_events`）は読まない。`deriveStudio`の`members`は`memberModel(act.value)`＝`presenceStates`＋`startPendings`、継続確認は`studioContinuity`。
- 表示する担当＝活動のowner ∪ 開始待ちの宛先 ∪ 継続確認のowner（`memberViewModels`）。連絡DBの送り手・宛先は入らない。
- 各ランプは規約§2の3つ（申告状態・最後の活動・確認の新しさ）＋開始待ち。開始待ちはjsonlの依頼IDの書式から導く（OPS-151）。
- 影響：連絡DBには10-19 14:59〜22:25 JSTに89通（全件Astra→姫、kind=request）。最後の状態は閉じた61・返答済み28。これらの受領・着手・返答は、ランプの「最後」にも開始待ちにも出ない。
- 既存試験（基準時点ですべてPASS）：`test-view-model-members.cjs`・`test-start-pending.cjs`・`test-view-model-current-wake.cjs`・`test-view-model-letters.cjs`。

**2. 対応表（案）**
- 申告状態（作業中・待機中・待機終了・未申告）：今のまま。jsonlの本人の`presence`だけで変わる。連絡DBの出来事では変えない（規約§2「推定しない」、正本の境界「返却済みから本人待機を推定しない」）。
- 最後の活動：jsonlの最後の実務記録と、連絡DBで**その担当が行った**最後の出来事（宛先なら受領・着手・返答・辞退・停止応答、送り手なら停止要請・閉じた）の新しい方。表示は「最後 着手 LTR-…短縮 hh:mm」の形。
- 連絡の行（開始待ちの連絡DB版）：宛先の開いた連絡（未受領・受領・担当中・停止要請＝`OPEN_FOR_RECIPIENT`）を1件1行で出す。「未受領 LTR-…（Astra hh:mm）」「担当中 LTR-…」「停止要請 LTR-…」。既存の開始待ちと同じく、申告状態は変えない。3件超は件数で畳む（既存`pendingLines`と同じ）。
- 返答済み・未close：宛先のランプには出さない（宛先側は終わっている）。送り手のランプに「返答あり・未確認 n件」を出すかは判断が要る（下のD2）。
- 担当の集合：上の和集合に、連絡DBの送り手・宛先を足す。
- 取得の不調：連絡DBの読取失敗は、そのランプに「連絡：取得不調」の1行を足す。連絡なしとは書かない。活動の不調とは別に扱い、片方が読めれば片方は表示を続ける。
- 継続確認：今回は変えない（ファイルのまま。CP-20261019-006のC2）。

**3. 調整担当へ返す判断**
- D1 取り方：(a) `/letters?brief=1`を1本で定期取得し画面側で担当ごとに分ける、(b) 担当ごとに`/letters-inbox?owner=`。姫の推奨は(a)（取得1本、OPS-184と共有）。ただし今の軽量一覧は最後の出来事の**時刻**（`lastEventAt`）だけで、**誰の出来事か**を持たない。「最後の活動」には、一覧へ`lastEvent:{event,actor}`を足すサーバーの小変更が要る（本文は読まない形のまま）。これは実装区切りでの変更範囲に入れるかの判断。
- D2 送り手のランプに「返答あり・未確認 n件」を出すか。今は28件で、出すなら件数だけを推奨。
- D3 本人の申告（presence）を連絡DBへ移すかは今回扱わない。移すなら規約の変更になるので別判断。

**4. 停止点**：ここで止める。3・4（実装・試験）は受入と依頼の後。

**姫の補正（2026-10-19 23:55ごろ）**：上の「返答済み・未close：宛先のランプには出さない」と、会話で姫が出した「返答済み・未closeは今回は画面に出さない」の既定案は、ユーザーの判断ではなく姫の提案。ユーザー指摘（`TASK_REGISTRY_APP.md`「返答済み連絡を省略しない」）に従い、既定にしない。返答済みは「確認待ち」として相手の作業中と区別して出し、原文へ辿れる形を前提に案を作り直す。原返却は変えず、この補正を優先する。


## 連携
OPS-183・OPS-184は対応表の共通読取部分を共有できる。並行実装時は同じファイルの占有を重ねず、受入時に分担する。

## Astra acceptance and implementation assignment (2026-10-19)

Stage 1 is accepted with the corrections below, including Hime's returned-letter correction. The user requested that Astra complete acceptance and send the implementation assignment. Hime may now implement stages 3–4 for OPS-183 and OPS-184 together; no further stage-1 approval is pending. This accepts the mapping, not a completed implementation.

- Share one `/letters?brief=1` reader between member status and recent work; add last-event metadata to the brief response. Preserve actor/effective/proxy distinctions. Do not infer self-declared presence from letter events or present a counterpart's action as the member's own activity. If last-event-only data cannot support a per-member latest-action claim, label the narrower observation honestly.
- Merge legacy activity and letter events chronologically; do not replace or erase either source. Keep returned/unclosed letters visible as sender confirmation pending, distinct from recipient work. Counts/collapsing are allowed only with access to originals. Do not auto-close old letters.
- A closed letter means that exchange is closed, not that the task is DONE. Task grouping must not hide other still-open/confirmation-pending letters under a newer closed exchange.
- Respect pagination: one shared reader does not mean one page. Older pending letters must remain discoverable; an incomplete/failed fetch must not be shown as zero/no communication. Retain explicit loading/error/incomplete states.
- Use existing JSONL WAKE semantics: extend `comm.py letter watch` to observe WAKE alongside letters, with independent progress/deduplication and existing ACK behavior. Do not introduce a new DB kind or substitute work withdrawal for waiting termination.

### Scope and completion
Hime owns the related Studio client/VM/template, brief-list server metadata, comm.py watcher, focused tests and necessary usage documentation for these two tasks. One writer handles shared files. Presence storage, continuity storage, approval policy, database migration and unrelated cleanup are outside this assignment.

Prepare isolated tests first and demonstrate a failing regression before fixing it. Use temporary DBs, a dedicated test server/port and headless browser: send → receive/start/reply → VM → rendered member/work display, plus WAKE → watch → ACK → display. Cover returned/unclosed, closed versus task completion, pagination and fetch failure. Record retained tests and justified changes. Do not use port 8088, production data, restart the user's server or commit. Report unsupported real-browser checks honestly; component checks alone do not complete acceptance.

Return implementation, evidence and remaining limitations to Astra; stop and report after two consecutive correction rounds. Do not ask the user again about the choices settled here. This bounded implementation does not close the broader all-communications requirement and does not authorize routine autonomous operation.
