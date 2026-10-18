# 最近の作業レーン実装（OPS-119）

## TL;DR（人間向け）

直近200件の活動と未完承認から、タスク単位の「最近の作業」を導出表示した実装・補修・技術受入の記録。承認UIを一つにまとめ、疎通専用書式と実務の言及を区別する試験が成功した。全taskの現在地や同taskの並行依頼は識別せず、正式状態は生成時の正本から表示する。実ブラウザは未確認。

2026-10-18, Astra. Parent OPS-048; inputs: OPS-118 proposal/Astra supplements. The user chose recent-activity display and approved continuing implementation.

<a id="姫への正式依頼"></a>
## Formal assignment to 姫

On notification, read CLAUDE_TASK and this document; no additional start confirmation for this task. Minimally implement the repaired/accepted `STUDIO_WORK_LANE_PROPOSAL.md` under these boundaries.

<a id="成果と境界"></a>
### Outputs and boundaries

- At the prior approval-lane location, show small task-based recent-work cards. Clearly limit to 「直近200件の活動＋未完の承認」, not all tasks' current positions.
- Derive latest stage/owner/time/short reason from practical events, with Registry state separate. Unknown start stays unknown; missing request does not mean old work is consideration. New consideration can use existing work+description.
- Latest commit means 「記録コミット済み」; complete means 「作業区切り」, not Registry DONE. Regress RBT-026 WAITING_USER+commit. recheck does not create a new cycle; handle awaiting-commit after complete.
- Show pending/approved/claimed by task, not inferred cycles/timestamps. Include approvals-only tasks as no activity information. Same-task parallel requests remain indistinguishable. Keep consumed/cancelled history.
- Preserve existing approval controller/target-set contract for individual, cancel and approve-all-visible. Details may fold, but pending count/action entry must remain visible. One approval UI; work cards do not approve.
- Exclude only dedicated PING/WAKE/ACK formats from stage inference, keeping general practical mentions. Explain concrete positive/negative fixtures; retain source event strip.
- Keep activity strip as history. Update lane locally only on activity/approval fetch, preserving edits/input/selection/scroll/focus. On failure retain last display plus warning; preserve hidden-page pause/timeout.
- No server/API/DB/schema changes, new authority or automatic start; derived view only.

<a id="占有と検証"></a>
### Ownership and verification

Editable by 姫: `Maintanance/RegistryApp/index.template.html`, new `Maintanance/RegistryApp/test-work-lane.cjs`, relevant lane prose in `Maintanance/RegistryApp/README.md`, Return below. Report required old-smoke environment repair rather than expanding. No Registry/other canonicals/server/activity.py/approvals.py/AGENTS edits, commit, restart or user-screen operations.

Write a short initial breakdown and continue within scope. Check pure-function transitions, old/unknown starts, approvals-only/multiple approvals, probe exclusions, RBT-026, local DOM/input/focus, existing activity/approval checks, sync/verify. Generate to cache; state real-screen limitations.

Record actual work/verification/return events as OPS-119, owner 姫. Return changed files, rules, tests, limits and consulted-cache line. Stop for Astra acceptance.

## 姫 Return

2026-10-18 姫・Opus 5.5。開始HEAD `16ec8d0d64f15330355bb342c0bb0bfbccf89a62`。commitなし、サーバー操作・再起動なし、実画面は未確認。

作業内訳（着手時に記入）：(1) 既存のactivity・承認の作りを読む。(2) 純粋関数と疎通判別を書いて試験する。(3) 承認レーンの位置に描画し、取得時だけ局所更新する。(4) READMEに説明を足し、既存試験・sync・verifyを流す。

### 変更ファイル

- `RegistryApp/index.template.html`（+74/−4）
  - 承認レーンの直前に「最近の作業」セクションを置いた。既存の「コミット事前承認」はそのまま下に残し、承認・取消・全部承認の操作はそこだけ。
  - 純粋関数`workLaneItems`、疎通判別`isProbeEvent`、描画`createWorkLaneView`、状態保持`createWorkLane`、遅延生成`workLaneInstance`を足した。
  - activityの行に、元の項目（`raw`：taskId・owner・reason・時刻）を足した（既存の帯は使わない追加項目）。
  - activity・承認の各取得のviewを薄く包み、成功・失敗のときにレーンへも渡す。
- 新規 `RegistryApp/test-work-lane.cjs`
- `RegistryApp/README.md`：「最近の作業レーン（OPS-119）」の節を、作業イベント更新ルールの直後に足した。

### 具体的な規則

- 工程：そのtaskの最新の実務イベントで決める。request＝依頼済み、work＝作業中（reasonが「相談待ち：」で始まれば相談待ち）、verification＝確認中、return＝返却・受入待ち、recheck＝再確認中、acceptance＝受入済み、complete＝作業区切り、awaiting-commit＝コミット待ち、commit＝記録コミット済み。RegistryのDONEへは変換しない。Registryの状態は別の行に出す（生成時の正本seedから）。
- 開始：範囲内の最新のrequestの時刻。なければ「開始は記録範囲外または未記録」。requestが見えないことから検討中とは断定しない。recheckで別のカードを作らない。completeの後のawaiting-commitはコミット待ち。
- 承認：同じtaskのpending・approved・claimedの数をtask単位で出す。時刻で依頼へ結び付けない。承認だけのtaskは「活動情報なし」で出す。consumed・cancelledは数えず、既存の履歴に残る。同じtaskの並行依頼は区別しないことを、見出しの説明に明記した。
- 疎通の判別（`isProbeEvent`）：次のどちらかなら、工程に数えない。帯には残る。
  - reasonが`ACK `（ACK＋空白）で始まる。
  - reasonに`(PING|WAKE)-数字8桁-英数字`のIDを含む。前後が英数字やハイフンにつながる場合は除く。
  - 陰性（数える）：「PINGの仕組みを説明」「WAKE-UP手順」「XPING-20261018-A」「ACKNOWLEDGE」など。
- 更新：既存のactivity取得・承認取得が成功・失敗したときだけ描き直す。どちらかが不調なら、最後の表示を残して「〜の取得不調・最終情報を保持」と出す。フォーカスがレーン内のカードにある間は、カードを並べ替えない（文字だけ更新）。横スクロール位置は保持する。

### 試験結果

- `test-work-lane.cjs` PASS。確かめた内容：
  - 9種のイベントの状態遷移。recheckでカードが1枚のまま。complete→awaiting-commit。相談待ち。
  - 起点不明。承認のみ。同じtaskの複数承認（consumed・cancelledを除く）。承認で工程が変わらない。
  - 疎通の陽性4件・陰性6件。commit後のPINGで再開しない。PINGに触れた実務は残る。
  - RBT-026（WAITING_USER＋commit）。新しい順の並び。
  - DOMの局所更新：ノードの同一性、フォーカス中は動かさない、スクロール保持、失敗時に表示を保持、承認バッジ。
  - 配線と、承認操作がレーンにないこと。
- 既存：`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-activity.py`・`test-approvals.py`・`test-work-progress.py` OK。
- sync（verify.cjs通過）、`--check`差分なし。生成物はキャッシュへ。
- 実データでの導出（読み取りだけ）：OPS-119が確認中、OPS-118がDONE＋記録コミット済み。RBT-026とOPS-117はWAITING_USER＋記録コミット済み。OPS-048は、ACKを除いた最新がcompleteで作業区切り。

### 限界

- 実ブラウザでの表示・操作・フォーカスの挙動は未確認（擬似DOMの試験だけ）。
- 直近200件より古い仕事は出ない。開始が範囲外なら不明と出す。
- 疎通の除外は表記の約束（PING-／WAKE-のID、`ACK `）に頼る。約束どおりでない疎通は工程に数えられる。
- OPS-093・094の古いsmokeが`clearTimeout`等で落ちる件（OPS-116で報告済み）は、今回は触っていない。

参照したキャッシュ：なし。

<a id="astra確認限定補修依頼"></a>
## Astra review and limited repair assignment

2026-10-18. Independently ran new test-work-lane.cjs: PASS. Repair only these two before acceptance; retain first Return and append second. Same scope, no start reconfirmation/server operations.

1. Recent work and approvals remain two large sections. Fold existing approval details into recent work to match user's one-lane intent. Keep counts/action entry, controller/targets/history; one approval UI, structurally tested.
2. isProbeEvent also excludes practical mentions of probe IDs. Keep 「PING-20261018-Aの判定不具合を修正」 as practical work. Restrict detection to dedicated send/ACK formats, with actual positives and this negative. No new schema.

Preserve other unverified display-environment limits; no additional improvements.

## 第2回Return（姫記入）

2026-10-18 姫・Opus 5.5。初回Returnは保持。指摘の2点だけを補修した。commitなし、サーバー操作なし、実画面は未確認。

1. **承認を作業レーンの中へまとめた**（`index.template.html`）
   - 独立した「コミット事前承認」セクションをなくし、「最近の作業」セクション1つにした。
   - 見出し行には常に次を出す：レーンの件数、「コミット事前承認：承認待ちN件・承認済みM件」（既存の`approval-status`）、「表示中の未承認N件を承認」ボタン（既存の`approval-all`）。
   - 説明（`approval-policy`）、承認カード（`approval-track`）、使用と取消の履歴は、折り畳み「コミット事前承認の詳細（個別の承認・取消・履歴）」に入れた。
   - IDは全部そのままなので、既存の承認コントローラ・表示・対象集合・履歴・詳細ダイアログは変えていない。承認のUIは1つだけ。
   - 試験（`test-work-lane.cjs`）で次を確かめる：承認関係の6つのIDがHTMLにそれぞれ1つだけあること。件数と全部承認が折り畳みの外（見出し）にあること。カード・履歴・説明が折り畳みの中にあること。独立した承認セクションがないこと。
2. **疎通の判別を専用の書式に絞った**（`isProbeEvent`）
   - 送信：IDの直後にコロンがある形（`(PING|WAKE)-数字8桁-英数字` の直後に`：`か`:`）。IDの前は、文頭か空白。
   - 応答：reasonが`ACK <ID>`で始まる形。
   - 文中でIDに触れただけのもの（「PING-20261018-Aの判定不具合を修正」「疎通ID PING-20261018-A の扱いを整理」）は実務として残る。
   - 陽性：今日の実際の送信4件（A・B・C1・WAKE-D）と応答3件。陰性：上の2例に加え、「PINGの仕組み」「WAKE-UP」「XPING-…：」「ACKNOWLEDGE」「ACK の表記」。いずれも試験した。
   - 初回の試験にあった「疎通専用 PING-20261018-Z」（コロンなし）は、新しい書式に合わせて、コロン付きの送信例に直した。
   - READMEの説明（承認のまとめ方、疎通の書式）も合わせて直した。

試験：`test-work-lane.cjs` PASS。`test-activity.cjs`・`test-approvals.cjs`・`test-work-progress.cjs` PASS。`test-*.py` 3件 OK。sync（verify通過）、`--check`差分なし。

限界：折り畳みが閉じている間は、個別の承認・取消ボタンは見えない（入口は折り畳みの見出しと、見出し行の全部承認）。表記の約束から外れた疎通は、工程に数えられる。実ブラウザは未確認。

参照したキャッシュ：なし。

<a id="astra技術受入2026-10-18"></a>
## Astra technical acceptance (2026-10-18)

Compared both Returns and accepted. Independently ran test-work-lane/activity/approvals/work-progress: all four PASS; git diff --check clean. Confirmed single folded approval UI with counts/entry visible. Tests distinguish dedicated probes/practical ID mentions and Registry state/record committed. No server/API changes. Formal state uses generation-time canonical seed. Real browser appearance/interaction unverified; technical acceptance does not substitute for visual inspection. No further assignment.

Approval 675d98979eb7448fb913da58ebc842de was approved at acceptance. Commit the specified files.
