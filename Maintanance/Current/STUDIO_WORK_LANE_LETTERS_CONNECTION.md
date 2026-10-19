# 最近の作業と待機完了を連絡DBへ接続する

## TL;DR
2026-10-20ユーザー指示によりOPS-184の実装を撤回。最近の作業カード合成とletter watchのWAKE追加を元に戻す。OPS-183は維持。以下の受入・投入記録は経緯であり、再実装の許可ではない。
連絡DBの受領・着手・返答を表示し、待機完了の操作から相手への到達・本人ACKまで確認する。
姫がすでに提出した内訳を使い、現状確認・対応表の受入後に実装へ進む。内訳の再提出を求めない。

OPS-184 / PROPOSED / 2026-10-19。ユーザー指示で正式登録。担当：姫、受入：調整担当。実装・隔離試験をAstra受入済み。本番表示は未確認（下記）。原返却：CP-20261019-004（CLAUDE_PENDING_TASKS.md）。親OPS-048。

## 既存の作業内訳（姫の案を引継ぎ）
  1. 現状の固定：`workLaneItems`の入力と、`/activity-wake`が書く先・誰が読むかを確かめ、既存試験（`test-work-lane.cjs`等）を控える。
  2. 対応表：連絡DBの状態（sent/received/started/returned/declined/withdrawn/stopped/closed）を作業カードの段階へ写す案を作る。旧活動を残すか（併記・置換）を調整担当へ返す。
  3. 実装：レーンが`/letters?brief=1`も読む。待機完了は連絡DBの連絡（停止要請や専用kind）へ寄せるかを2の判断に従う。
  4. 試験：一時DBで状態ごとのカードを確認し、既存試験の差分を説明する。

## 区切りと受入
- 最初は上記1・2。コードと現行規約を確認し、出どころ・表示・操作の対応表を返す。全履歴を調査し直さない。
- 調整担当が既存要求との一致を確認する。既決事項は再度ユーザーに聞かず適用し、新しい意味や権限の判断だけユーザーへ返す。
- 3・4は対応表の受入後、実装範囲・担当・完了条件を明示して依頼する。現在の登録だけでは実装を開始しない。
- 一時DB・試験サーバーで入力→VM→実画面まで確認し、必要な操作は送信→受信→本人応答まで通す。部品試験だけで接続完了としない。既存試験を維持できた範囲と変更理由を残す。本番再起動や本番DB変更は別途依頼された範囲のみ。

## 境界
連絡DBの受領・着手・返答を表示し、待機完了の操作から相手への到達・本人ACKまで確認する。
通信不能を連絡なしと表示しない。本人の状態と一件の依頼状態を区別する。承認・commit運用（CP-005）は対象外。通信規約や状態遷移の変更が必要なら、実装を進めず具体的な差分を返す。

全連絡原文・履歴へのユーザーアクセスは元の要求として維持する。この表示修正だけでその要求全体を達成したとは扱わない。全点検CP-006は関連する証拠として必要箇所だけ参照する。

## 参照
- [通信規約](COMMUNICATION_PROTOCOL.md)
- [連絡DB正本](STUDIO_COMMUNICATION_STORE.md)
- [Studio利用手順](../RegistryApp/README.md)

## Return / Acceptance

### 姫返却（第1区切り：現状確認と対応表、2026-10-19）
ユーザー直接指示「タスクやって」（OPS-183・184の第1区切り）。基準commit `0dada5204`。コード・DB・サーバーは変えていない。DBは読み取り専用で開いた。共通の読取は[OPS-183の返却](STUDIO_MEMBER_LETTERS_CONNECTION.md#姫返却第1区切り現状確認と対応表2026-10-19)のD1と同じ。

**1. 現状（コードで確認）**
- カードは`workLaneItems(活動, 承認, Registry状態)`。活動は`/activity-events`（jsonl直近200件）で、taskごとに最後の実務記録から段階・次の担当・依頼時刻を作る。承認は`/commit-approvals`の件数。連絡DBは読まない。
- 「待機完了」：ボタン→`POST /activity-wake`→`activity.request_wake`がjsonlへ`WAKE-…：待機終了依頼`を1行書く。応答の判定（`wakeStatus`）もjsonlの`ACK WAKE-…`だけを見る。
- **見つけた食い違い**：現在の待機の道具`comm.py letter watch`は`/letters-inbox`だけを読む（`comm.py:213`）。連絡DBで待機している担当には、Studioの待機完了（jsonl）が届かない。コードからの読みで、実機では試していない。
- 影響：連絡DBの89通（14:59〜22:25 JST）の受領・着手・返答は、レーンに出ない。返答済み・未close 28通の内訳はOPS-167が23、OPS-158が2、OPS-169・170・179が各1。
- 既存試験（基準時点ですべてPASS）：`test-work-lane.cjs`・`test-wake.cjs`・`test-view-model-cards.cjs`・`test-view-model-current-wake.cjs`。

**2. 対応表（案）**：連絡の最後の状態→カードの段階と次の担当。
- 未受領（sent）→「依頼（未受領）」、次：宛先
- 受領（received）→「受領」、次：宛先
- 担当中（started）→「着手」、次：宛先（連絡DB正本の姫の設計案§3「連絡DBの依頼ではDBの状態が開始待ち・実着手の代わり」による。採用の記録は§3の1〈letter_eventsを活動記録の正本〉までで、この読み替え自体の受入は未確認）
- 返答済み（returned）→「返答済み」、次：送り手（確認・close待ち）
- 辞退（declined）→「辞退」、次：送り手
- 停止要請（withdrawn）→「停止要請」、次：宛先（応答待ち）
- 停止済み（stopped）→「停止済み」、次：送り手
- 閉じた（closed）→「終了」、次：なし（「この仕事は終了」）
- 合わせ方：今と同じくtaskごとに1枚。jsonlの最後の記録と連絡の`lastEventAt`の新しい方をカードの段階にし、連絡由来ならLTR IDの短縮を添える。依頼時刻の行は`sentAt`。旧活動は消さずに合わせて読む（併記）。これは受入済みの方針（letter_eventsを新方式の活動記録の正本にし、jsonlへ写さない。画面で両方を時刻順に読む）に沿う。
- 量：返答済み・未closeの28通は、そのまま「次：Astra」のカードになる。taskごとに畳むので、今は5枚。
- 待機完了の選択肢：
  - (a) jsonlのまま。`comm.py letter watch`がjsonlのWAKEも見るように変える。規約は変えない。
  - (b) WAKEを連絡DBの新しいkindにする。受領＝ACK。規約§5と状態遷移の変更になるので、境界どおり実装は進めず、差分案だけを返す。
  - (c) 停止要請（withdrawn）で代える：意味が違う（仕事の停止と待機の終了）ので推奨しない。
  - 姫の推奨は(a)を先に（届かない状態を最小の変更で解く）。(b)は正本の「WAKEは第2段」の続きとして別判断。

**3. 調整担当へ返す判断**
- E1 旧活動と連絡の併記（推奨）か置換か。
- E2 待機完了は(a)か(b)か。(a)なら`comm.py`の変更が実装範囲に入る。
- E3 返答済み・未closeのカードの扱い。今は送り手がcloseしない限り残る。closeの運用で解くか、表示で畳むか。
- D1（取り方と、一覧に誰の出来事かを足す件）はOPS-183と共通。

**4. 停止点**：ここで止める。3・4（実装・試験）は受入と依頼の後。


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

### 姫返却：実装区切り（OPS-183/184共通、2026-10-20）
共通の返却は[OPS-183の正本の同名の節](STUDIO_MEMBER_LETTERS_CONNECTION.md#姫返却実装区切りops-183184共通2026-10-20)に置いた（変更・試験・限界・第1区切りの訂正）。OPS-184に当たるのは、カードの合成、待機完了→watch→ACK→表示、閉じた連絡とtask完了の区別。

### Astra implementation acceptance (2026-10-20)

Accepted the bounded implementation for OPS-183/184 after reviewing the actual diff and independently running `test-letters-lanes-browser.py` (1 WebKit test), `test-studio-letters.py` (25 tests), and `test-letters-lanes.cjs`, `test-view-model-members.cjs`, `test-work-lane.cjs`, `test-view-model.cjs` (all passed). `git diff --check` passed. The browser scenario seeds letter transitions through the real store, then exercises the real server read routes and rendered page; WAKE uses the page action, watcher and ACK. It is not proof of every real-agent communication route.

Returned/unclosed remains visible, closed exchanges do not set task DONE, member presence is not inferred from a return, and failed reads retain prior content with an error indicator. Separate legacy-last and last-letter lines are accepted because their sources are explicit. Pagination/cap coverage is unit-level; the browser case is one page. The 200-event WAKE window and incomplete-feed indication are retained limitations.

This completes these implementation tasks, not production deployment or the broader all-communications requirement. No live restart or user browser was operated. User Safari and post-restart production display remain unverified. The reported Store-construction exception is outside this change and remains an observation, not a fixed defect.

Communication reconciliation: the implementation return was received in these canonical documents via the user's acceptance request. LTR-20261019-7958BDD87963439EA5EED856FA7E7995 was still `sent` when checked; do not fabricate Hime's receipt/start/reply events. Acceptance is recorded here and separately communicated to Hime.

### Production deployment (2026-10-20)

User explicitly requested production deployment so the result can be viewed after one exchange. Astra gracefully stopped the identified port-8088 server and restarted it with the same V3 DB/Inbox arguments (new PID 98738). HTTP checks confirmed the served page includes the shared letter-feed wiring and the production brief endpoint returns events/lastEvent for 91 letters, hasMore=false. No save was discarded or DB migrated. Existing browser tabs require a normal reload to load the new JavaScript; the user browser was not operated. Production HTTP integration is verified; visual rendering on user Safari remains unverified.

## 2026-10-20 ユーザー指示による撤回

「ごめん、184だけもどし」に従い、OPS-184の最近の作業への連絡カード合成とletter watchのWAKE監視追加を撤去。OPS-183のメンバー状態への連絡DB接続と共通読取は維持する。過去の受入は履歴として残すが、184の完了扱いを取り消しPROPOSEDへ戻す。新たな実装は依頼しない。既存の通信記録・判断・保存データは削除しない。

確認：連絡CLI/store 24件、VM・letters-lanes検査、隔離WebKitでメンバー表示・読取失敗/復帰・連絡カードが増えないことを確認。最初のブラウザ試験は稼働中サーバーのログ更新とlive-file検査が競合し失敗。サーバー停止後の同試験は成功。
