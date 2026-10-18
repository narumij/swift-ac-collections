# Studioのマイルストーン計画編集・限定試行

## TL;DR（人間向け）

Studioの編集版で中間カードの名称・条件・並替え・版間移動・追加と未接続版の追加を行い、差分を保存・再開する限定試行。追加フォームの入力消失を補修して独立検査で受け入れ、完了した。実マイルストーンへの反映、版比較・ゲート操作・実ファイル命名方針の確定は含まず、未追加フォームは永続保存対象外。

2026-10-18 / OPS-086 / parent OPS-048. Astra authors/accepts; Claude (Hime) implements/verifies.

<a id="目的と委任"></a>
## Purpose and delegation

Allow users to rearrange milestone plans in Studio and save/resume without the coordinator. Implementation follows 「依頼お願い」「つづけてください」. Reported 50% remaining usage is not a guarantee of feasible completion. Write a brief breakdown and implement/verify in small stages: first intermediate-card editing within existing versions, returning a working stage if resources run short. Partial return is not overall completion.

<a id="方針と境界"></a>
## Policy and boundaries

- Edit OPS-082's persistent user editing revision, not real milestone files or automatic Registry writes. Preserve baseline/save history and distinguish the latest canonical from editing proposals.
- Operations: version addition, intermediate-card addition, within-version reordering, movement between versions, and intermediate-card name/condition changes. Small forms/up/down controls suffice; dragging is optional.
- Retain existing card IDs/task connections through movement, reordering and renaming. Do not make version-END connections follow an intermediate card's movement. New proposals use noncolliding provisional IDs and are labeled unapplied proposals.
- Derive START→card sequence→END. Save machine-readable placement/order differences needed for eventual file application. Applying to canonicals needs a separate acceptance/application request.
- Exclude HEAD/version-name changes, existing version/card deletion, gate add/move/delete, automatic state completion and release operations. Plan changes do not establish arrival/passing.
- Names/conditions remain user proposals. Existing canonical links show existing canonicals, not proposals as already applied. Do not invent links for new proposals.

<a id="原型仕様と未決事項"></a>
## Prototype specification and unresolved matters

Structural authority: `Maintanance/Milestones/DESIGN.md`; current operating explanation: its README. Both DESIGN documents are user-owned and must not be edited.

Version-folder comparison is 「利用者が定める」; do not turn the current generator's implementation into a permanently approved specification. Stop only the part requiring a new ordering decision and return the minimal question/impact; independent settled existing-card operations may proceed. Known differences between prototype allowances for disconnected versions/final gates and the generator remain (Milestones/README). Do not change higher specifications or widen into comprehensive repair; identify boundary-crossing work in the breakdown.

<a id="作業の区切り"></a>
## Work stages

1. Inspect current save format/backbone generation within scope; record changed files, brief breakdown, starting HEAD and existing differences.
2. Implement name/condition edits, reorder and cross-version movement for existing cards; verify save/resume.
3. Add intermediate cards and versions where no new judgment is required. A new version may remain a gate-free proposal; do not invent connections. Separate unresolved questions.
4. Check map/card-list/inspector consistency and regression of existing operations, then return.

Record verification per stage. Implementation technique and small UI design are delegated; new policy decisions are not.

<a id="編集範囲と占有"></a>
## Editing scope and ownership

Necessary parts of RegistryApp/index.template.html, sync.py, verify.cjs, serve.py, inbox.py, README.md, this breakdown/Return and Current/Evidence/OPS-086/. RegistryApp/Inbox/README.md may explain save format if needed. Changing every listed file is not required.

No Registry, Rules, CLAUDE_TASK, DESIGN, real Milestones placement or real user Inbox changes. Preserve others' uncommitted differences. Generate into existing Cache. The completed assignment hands this scope to Hime; Astra does not edit it before return. No commit/push/branch creation delegated.

<a id="受入条件と検証"></a>
## Acceptance and verification

- On isolated data, reorder/move multiple cards while retaining IDs/task connections and generating the new backbone. Rejected operations must preserve pre-operation edits.
- Reject provisional-ID collisions, invalid connections and cycles. Read existing saves; if format changes are needed, state compatibility rather than silently discarding old saves.
- Preserve plan proposals across save/resume and update/resume, including later edits/unapplied inputs during pending responses. Do not overwrite history/baseline.
- Expose add/move/reorder/text differences for comparing baseline, proposal and latest canonical. Real canonicals/HEAD remain unchanged.
- Run existing sync/verify, --check and necessary operation smoke. Real Inbox/Milestones are not fixtures. Note unverified Safari operation explicitly.
- Return implemented operations, missing/pending decisions, files, fixed input, evidence, resume instructions and artifact handling. Astra handles acceptance/Registry updates.

## 作業内訳（姫記入）

2026-10-18 / 姫・Opus 5.5。開始HEAD`618460c62`。既存の未commit差分：DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules・本書（Astra）。どれも触らない。

**限定確認**：
- 生成データの中間カードは`milestones[]`（`gate`＝実ファイルのパス、`item`＝名前）。
- 骨格は`milestoneRelations`の生成接続（`source.path`がMilestones/README）。版ごとにSTART→カード（ファイル名順）→END→GATEとつながる。
- baselineには`milestones`がない。

**方式**：計画はOPS-082の編集版の中で、`milestones`と生成接続を直接組み替えて表す。こうすると見取り図・カード一覧・verifyの鎖検査がそのまま新しい骨格を読む。
- 編集前のカードは`baseline.milestones`に控える。読込時に無ければ写し、既存の保存版も読める。差分（追加・移動・並替え・名前・条件）はbaselineとの比較で`changes`の`milestones`に出し、AIが読める。
- 移動・並替えは、そのカードの**計画上のファイルパス**（`gate`）の変更で表す。DESIGNでは順序はファイル名順なので、並べ替えた版のカードには`10_`・`20_`…の番号を振り直す（番号以外の名前は保つ）。カードIDとtaskからの接続は変えない。task→ENDの接続は動かさない。
- 名前は`item`、到達条件の案は新しい欄`planCondition`に持つ。正本リンクは既存の正本のまま（編集案を正本として見せない）。
- 新規カード：仮ID`draft-ms-N`、計画上のパス、`planned: true`。正本リンクなし。
- 新規版：仮想START/ENDだけを足す（ゲートは足さず、ほかの版とつながない）。

**区切り**：
1. 純粋なデータ操作（名前・条件／並替え／版間移動／カード追加／版追加、生成接続の作り直し、差分）と、`check`・verifyでの検証。
2. マイルストーンのインスペクタに「計画の編集（編集版の案）」欄を足す。カード一覧タブに「中間カードを追加」「版を追加」を足す。
3. スモーク：保存→再開、更新・保存応答待ち中の保護（既存の仕組み）、カード一覧・見取り図の整合。
4. README・Return。

**判断が要りそうな点（先に分離）**：新しい版の並び順と、前後の版へのつなぎ方（ゲート）は、DESIGNでは「利用者が定める」とされている。今回は**つながない版**として置くだけにし、順序とつなぎ方は質問として返す。

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。固定入力`618460c62a8ed97d940ad7942756557efe035a32`。DESIGN 2件（ユーザー）、`CLAUDE_TASK.md`・Registry・Rules（Astra）、実`Milestones/`配置、実`Inbox/`には触れていない。変更ファイルは`index.template.html`・`verify.cjs`・`README.md`の3つで、`sync.py`・`serve.py`・`inbox.py`の変更は不要だった。

**実装済みの操作**（区切り1〜4すべて）：
- 既存版の途中のカード：名前・到達条件の案の変更、同じ版での並替え、別の版への移動。
- 中間カードの追加（`draft-ms-N`）、版の追加（つながない版）。
- 差分の取得（`milestonePlanChanges`→`changes.milestones`）。カード一覧での「計画案」表示。
- 方式は作業内訳のとおり（計画上のパス＋番号の振り直し、触った版の骨格だけ作り直し、`baseline.milestones`）。

**途中で見つけて直した不具合**：版間の移動で、元の版の古い骨格線（START→移動したカード）が残り、見かけ上の循環で拒否されていた。触った版をまとめて一度に作り直す形にした。verifyの最初の版では、これを「タスク依存による本物の循環」と誤って書いていたが、検証で誤りと分かったので直した。今は移動が成功し、古い線が残らないことも検査している。

**検証**：
- `verify.cjs`（28 PASS、以前は27）：合成した編集版で次を確かめた。
  - 通るもの：カード追加（鎖START→MS-SPI→新カード→END）、並替え（ファイル名の振り直し）、MS-SPIの版間移動（両版の鎖、古い線なし）、名前・条件、版の追加（ゲートとつながない）。
  - 差分6種が出る。taskからの接続は不変。
  - 拒むもの（編集版は不変）：範囲外の並替え・同じ版・存在しない版・空の名前・ENDの編集・版名の重複／不正、カード経由の循環。
  - 保存往復でbaselineが保たれ、配置の幾何検査も通る。
- `Evidence/OPS-086/smoke.cjs`（最小DOM stub＋fetch stub）：
  - カード一覧から追加し、インスペクタで並替え（拒否時は不変）。
  - 名前・条件（タブ切替でも未適用入力は残る）。移動でtaskからの線が保たれる。版の追加。
  - 保存応答待ち中の改名は未保存のまま。保存JSONの差分5種とbaseline（=開始時の正本）。
  - 未保存中の更新は拒否。更新応答待ち中の改名で再読込しない。
  - 再開で計画とbaselineが戻る。
  - 結果：PASS。
- 既存のOPS-082 v2/v3・OPS-084・OPS-085のスモークもPASS。`sync.py`成功、`--check`でずれなし（実正本・HEADは不変）。
- Safari・実ブラウザでの操作は未確認。

**未実装・判断待ち**（ユーザーの判断が要る）：
1. 新しい版の並び順と、前後の版へのつなぎ方（ゲートを置くか、どの版のENDから入るか）。DESIGNでは比較方法を「利用者が定める」としているので、今回は「つながない版」として置くだけにした。決まれば、ゲートの追加操作を別に作れる。
2. 並替え・移動で、その版のカードのファイル名に番号（`10_`・`20_`…）を振り直す方式でよいか。順序をファイル名で決めるDESIGNに沿うため、動かしていないカードの名前も変わることがある（差分では`reordered`として出る）。

**その他の限界**：
- 新しい版は、ENDが図に出ない仕様（ENDへの線はゲートへ描く）のため、図ではSTARTと中のカードだけが見える。
- 版名の変更、カード・版の削除、ゲートの操作、状態の完了は対象外のまま。

**再開方法**：`python3 Maintanance/RegistryApp/serve.py`で開き、計画を編集して「編集結果を保存」。次に開くと直近の保存版から再開する（OPS-082）。

**作業物**：一時ファイルなし（スモークはstub上で完結）。

commitはしていない。

<a id="astra検収2026-10-18"></a>
## Astra review (2026-10-18)

Based on user acceptance request and confirmation 「差分なので実マイルストーンファイルには反映されていなくてよい」. Actual-file application is not an acceptance condition. Preserve original Return.

Independent sync/verify 28 PASS; OPS-086 smoke PASS. Compared backbone regeneration, baseline retention and difference extraction. Name/condition/reorder/move/add/save-resume checks stand; Safari operation remains unverified.

Overall acceptance is withheld: `renderPlanTools()` does not track new-card/version names as unapplied input, so redraw loses them. Independent reproduction: open card list in OPS-086 smoke DOM harness, enter 「まだ追加していない入力」 into `planAddName`, then `ctx.select('MS-SPI')`. Input becomes empty while `formDirty=false`. No real Inbox/Milestones used/changed. Check input entered during update as another consequence of the same tracking gap.

Limit repair to add-form input retention/discard confirmation and regression. No real milestone writes. Renumbering is an editing-revision placement proposal, not approval of file naming policy. Formal connection/comparison rules for unconnected versions remain unsettled. No new implementation assignment at this point.

<a id="限定補修の再依頼2026-10-18--astra"></a>
## Bounded repair reassignment (2026-10-18 / Astra)

After review, the user approved repair by Hime. This section is the current assignment. Preserve existing output, original Return and others' differences; repair add-form input protection only.

- Protect new intermediate-card name, destination version and new version name through card selection, tab changes and redraw. Retain them or explicitly confirm discard; cancellation preserves input.
- Tracking must not make 「追加」 itself unusable. Success clears only processed input; failure retains it. Do not erase the other add form or unapplied inspector input.
- Protect update with unapplied inputs and inputs entered while save/update responses are pending. Do not mark them saved or reload them away. Persistent form saving is not requested.
- First reproduce selection-induced loss, then check both forms, successful/failed addition and pending-response protection. Run existing OPS-086 smoke, sync/verify and --check.

Editable: RegistryApp/index.template.html, verify.cjs, README.md if necessary, this additional Return and repair evidence under Evidence/OPS-086/. Return reasons for necessary changes elsewhere. No real Milestones/HEAD/DESIGN/Inbox/Registry/Rules changes. No actual-file application or decision on version ordering/naming is needed.

Redelegate to Hime; Astra awaits return. No commit. Additional Return records changes, reproduction/fix checks and unknowns.

## 補修Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力`618460c62`＋OPS-086の未commit実装。他者の差分（DESIGN・`CLAUDE_TASK.md`・Registry・Rules）、実Milestones・実Inboxには触れていない。

**再現（修正前）**：`Evidence/OPS-086/smoke_form.cjs`を修正前の生成ページで実行した。カード一覧で`planAddName`に入力してから`select('MS-SPI')`すると、「card name kept after selecting a card」で失敗した（`before_fix_form.txt`）。Astraの再現と同じ。

**変更**（`index.template.html`、`README.md`に1項目）：
- 追加欄の未追加の入力（カード名・追加先の版・新しい版名）を、画面上の変数`planDraft`に持つ。`renderPlanTools`は描画のたびにそこから値を戻すので、カードの選択・タブの切替・再描画で消えない。
  - 編集データではないので、保存には含めない。
  - `formDirty`にも入れないので、追加ボタン自身やほかの操作を止めない。
- 追加に成功したら、使った欄だけを空にする（カード名、または版名）。追加先の版は保つ。失敗時はそのまま残す。インスペクタの未適用入力がある間の追加は従来どおり止め、追加欄の入力も残る。
- 未追加の入力がある間は、「更新」を止めて案内する。画面を離れる操作（`beforeunload`）も止める。
- 更新を待つ間に追加欄が変わったら、再生成が成功しても再読込しない。
- 保存成功の表示に、「追加欄の入力はまだ追加していないので保存されていません」を添える（保存済みと誤認させない）。

**検証**：
- `smoke_form.cjs`（修正後、結果：PASS）：
  - 3つの欄が、選択・タブ切替・再描画の後も残る。
  - 未追加の入力がある間、更新は`/sync`を呼ばず案内を出し、離脱も止まる。
  - 版名の重複で失敗すると、両方の欄が残る。カード追加の成功でカード名だけが空になり、版名と追加先は残る。
  - インスペクタの未適用入力中の追加は拒否され、両方の入力が残る。
  - 保存の応答待ち中に入力した値が残り、「保存されていません」と表示される。
  - `/sync`の応答待ち中の入力で再読込しない。
- 既存のOPS-086・OPS-085・OPS-084・OPS-082 v2/v3のスモークもPASS。verify 28 PASS、`sync.py`成功、`--check`でずれなし。
- Safari・実ブラウザでの操作は未確認。

**未確認・注意**：追加欄の入力は、ページを読み込み直すと消える（永続保存は依頼の範囲外。離脱時の確認で守る）。

**作業物**：スモークのデバッグ出力は削除済み。一時ファイルなし。

commitはしていない。

<a id="astra補修受入完了2026-10-18"></a>
## Astra repair acceptance and completion (2026-10-18)

Accepted the bounded trial under the user's acceptance/commit instruction. Compared returned changes against `618460c62` for input retention, update protection and saved-state messaging. Independent sync/verify 28 PASS; OPS-086 smoke/smoke_form PASS; --check matched; git diff --check passed. Checked three fields after selection/redraw, success/failure handling, inspector protection and inputs entered during save/update waits.

Completed for the editing revision and saved differences, following user confirmation that real milestone application is unnecessary. Unapplied add-form values are not persistent; leave confirmation and unsaved notices protect them. Safari operation is unverified. Version comparison, gates and real-file naming policy are not completed by this acceptance.

OPS-086 is DONE; Hime's bounded assignment ended. User commit permission covers this output and request/acceptance records, excluding the user's two DESIGN changes.
