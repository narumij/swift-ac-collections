# 接続表示の選択追従修正

## TL;DR（人間向け）

別カードを選んでも接続表示の中心が以前のまま残る問題を修正した記録。入力保護を通過した選択時に中心と展開状態を更新し、限定回帰試験・独立再実行とユーザーの改善報告を経て完了した。実ブラウザでの網羅確認は行っておらず、別件の線・配置修正は対象外。

Task: OPS-093 / parent OPS-048
Written by Astra, 2026-10-18. Formally requested of Hime with user approval.

<a id="現象と目的"></a>
## Phenomenon and purpose

On the user's screen, even after selecting another card in the map or the independent-task column, the centre of 「接続を見る」 stays on the previous card. First reproduce it in the current code and check the cause, then fix it so that the connections of the selected card can be checked. The cause has not been determined yet.

<a id="姫への依頼受入条件"></a>
## Request to Hime and acceptance conditions

1. After selecting card A → B in the map and then opening 「接続を見る」, B is the centre.
2. The same when selecting A → B in the independent-task column. Check both the route opening from the tab and the route from the inspector's button.
3. If there is a route to change the selected card while the connection view is shown, the centre follows that selection too.
4. Do not break the existing operations 「ここを中心に」, 「この先を展開」 and 「1段に戻す」. When a different card is newly selected, do not carry over the previous centre's expansion state.
5. Viewing connections alone must not commit or discard unapplied input on its own, and must not change the canonical, connections, states or saved edit versions. Keep the existing input protection on card selection.
6. Run a limited regression test that detects the reproduction before the fix and passes after it, the existing verify, and sync/check. No screen operation. State that it is unconfirmed in a real browser.

<a id="占有範囲"></a>
## Occupancy and scope

Editable: RegistryApp/index.template.html, the needed verify.cjs, this task's own Evidence/OPS-093/, and the Return field of this document. Needed generation is allowed. Occupancy of the target implementation is handed to Hime and Astra waits for the return.

Keep Astra's uncommitted diffs in the current working tree, such as the restart-notice band. Do not change serve.py, the Registry, Rules, others' documents, or the real Inbox or Milestones. Do not extend into fixing OPS-092's duplicate display, lines or layout; they are out of scope. Return out-of-scope findings briefly.

No commit is requested this time. After fixing and verifying, fill in the Return and return it to Astra.

## Return（姫記入）

2026-10-18 / 姫・Opus 5.5。入力HEAD`ef50c83d7`＋作業ツリー。Astraの未commit差分（再起動案内帯など、`index.template.html`・`serve.py`・README）は保持し、`serve.py`には触れていない。

**原因**：`renderNeighborhood()`は、中心が未設定のときだけ選択中のカードを中心にしていた（`if(!neighborCenter)neighborCenter=selected`）。中心が一度決まると、その後の選択は中心に反映されなかった。ユーザー画面の現象はこれと一致する。

**再現**：`Evidence/OPS-093/smoke.cjs`を修正前の生成ページで実行すると、最初の検査「A first」で、中心が起動時の選択（GRAPH-001）のまま失敗した（`before_fix.txt`）。

**修正**（`index.template.html`の`select()`を1行）：
- 既存の入力ガード（未適用入力があれば破棄の確認）を通った後でだけ、中心を新しい選択にし、前の展開を消す。
- 確認を取り消した場合は、選択も中心も変わらない。
- 「ここを中心に」「この先を展開」「1段に戻す」は選択を変えないので、従来どおり。

**検証**：
- `smoke.cjs`（修正後PASS、stub DOM）：
  - 見取り図でA→Bを選んでからタブで開くとBが中心になる。インスペクタのボタンからも同じ。
  - 独立タスク欄のA→Bでも、タブ・ボタンの両経路で同じ。
  - 接続表示を開いたままインスペクタのID選択で選び直すと追従する。
  - 手動の展開・中心変更・1段に戻すは動き、新しい選択では前の展開を持ち込まない。
  - 未適用入力があって移動を取り消すと、選択・入力・中心が保たれる。
  - 編集版は不変。
- OPS-091のスモークも引き続きPASS。verify 31 PASS、`sync.py`成功、`--check`でずれなし。
- 実ブラウザでは確認していない。

**範囲外**：なし（OPS-092の表示重複・線・レイアウトには触れていない）。

commitはしていない。

<a id="astra受入2026-10-18"></a>
## Astra acceptance (2026-10-18)

Checking the returned diff and independently re-running the OPS-093 and OPS-091 operation smokes succeeded, and sync --check shows no drift. Accepted updating the centre after the input check in select() and resetting the expansion. The real screen was not operated. The user also reported an improvement. Request finished; waiting for commit.

2026-10-18: by the user's commit approval this task is DONE. The recorded unresolved items and verification scope are unchanged.
