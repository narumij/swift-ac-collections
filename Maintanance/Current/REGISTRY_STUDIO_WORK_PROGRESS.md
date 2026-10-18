# Studio 作業進行帯（OPS-110）

## TL;DR（人間向け）

タスク番号・担当・工程・記録時刻を、他操作へ干渉しない小さい進行帯に表示した記録。独立試験とAstra受入後にユーザーの表示確認・commit承認を得て完了した。担当の記録を表示する機能で、自動的なAI稼働検出やSafari全操作との非干渉の網羅確認ではない。

Designed by Astra on 2026-10-18. Parent OPS-048. The user asked for a light design, delegation and prototype. Additional wishes: a real-time display that does not affect other operations, and the task number.

<a id="初回の契約"></a>
## Initial contract

- A compact band near the header shows the task ID, a short work name, the owner, the current step and the update time.
- The current position in preparation → work → check → acceptance → waiting for commit, with a waiting reason if needed. This is execution status, separate from Registry states such as ACTIVE.
- The coordinator updates the progress record; the screen reads only that record about every 3 seconds. It does not automatically infer whether an AI process is alive or its real progress.
- Do not mix it into saved edit versions or diffs. Periodic fetching must not do a full render, sync or reload. Keep selection, input, unsaved edits, scroll and focus.
- Communication trouble is shown only in the band, keeping the last record. Do not treat an old record as a guarantee of current activity. No file shows "not registered".
- Initially one piece of work. The progress record is Cache/RegistryStudio/work-progress.json, outside Git. Formal results and states remain in this document and the Registry. The update method and format are in the README.

<a id="依頼と境界"></a>
## Request and boundaries

Worker Sol: may change only the necessary implementation, limited tests and README within RegistryApp. May add a fixed-path read-only endpoint to the server. Include input validation, safe text display, prevention of concurrent fetches, and suppression of fetching while hidden. sync must not erase the cache. Product Sources, Registry, Rules, other management canonicals and the Inbox save mechanism may not be changed. No commit, server restart or screen operation. Return and stop on new judgments or out-of-scope issues.

Checker Sol: after implementation, independently check the contract above against the changes and verify them. Return findings without fixing. Astra does the final acceptance.

<a id="返却受入"></a>
## Return and acceptance

2026-10-18: implemented by worker Sol, independently checked by checker Sol, accepted by Astra. Targets: RegistryApp's serve.py, index.template.html, README.md and two dedicated test files.

- Implemented a fixed GET /work-progress, input limits and format validation, a fixed 48px band with task number, owner, step and record time, and updates of only the band about every 3 seconds.
- The independent check pointed out that the communication-trouble display was hidden at the end; it was moved to the front. Checked the structure: progress information is not mixed into unsaved edits, and fetching does not call a full render/sync.
- Two isolated Python tests, a JS fetch-control test (failure recovery, no duplication, stop while hidden, abort, deadline, not registered, staleness), Astra's sync/verify and a diff check succeeded.
- The real screen's appearance, keeping selection/focus/scroll in Safari, and real server communication are unverified. No screen operation and no restart of the existing server.
- The worker's live sync was rejected by the auto-approval review because the output location was outside the delegated scope. Astra ran it within the scope of this request, which includes the output, and it succeeded.
- Judgment caches referred to: none, for both worker Sol and checker Sol.

Accepted, waiting for commit. Using it needs a server restart and a page reload. The progress record reflects owners' updates on the screen; it is not automatic detection of AI activity.

<a id="ユーザー確認と終了"></a>
## User confirmation and close

On 2026-10-18 the user confirmed the display: 「機能してそう」「みえたー！」. Then completed with explicit commit approval. Do not extend this to mean non-interference with every operation in Safari was exhaustively confirmed. After the commit, delete this temporary progress record and return to the "not registered" display.
