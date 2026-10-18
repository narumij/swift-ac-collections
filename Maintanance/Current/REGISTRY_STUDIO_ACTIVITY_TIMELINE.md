# 作業イベント・コミットの二段帯（OPS-111）

## TL;DR（人間向け）

担当が記録する作業イベントと実際のGitコミットを二段の履歴帯に示し、往復や差し戻しを観察できるようにした実装記録。隔離試験・独立確認・ユーザーの表示確認を経て完了した。イベント帯は観察用であり正式な状態・受入の正本ではなく、実ブラウザの全操作の非干渉を網羅保証したものでもない。

2026-10-18, Astra. Parent OPS-048. Expand OPS-110's current-stage-only strip into two history-card rows reflecting the user's intent.

<a id="目的受入条件"></a>
## Purpose and acceptance criteria

Enable users to observe flow such as 「差し戻した」 and 「往復が多い」.

1. Upper row: owner-appended events at occurrence, with task ID, event, owner, time and optional short reason. Cover request/work/verification/acceptance/return/recheck/completion/awaiting-commit/commit. Keep repetitions; infer neither success nor completion.
2. Lower row: actual commits read from current checkout Git HEAD, showing short SHA/subject and access to date/full SHA. Events with commit SHA may show correspondence.
3. Both horizontally scroll old→new. Initially show newest; follow additions only if already at the end, preserving historical viewing position otherwise. Avoid rebuilding cards on polling; retain focus.
4. Small fixed two-row region fetching only this data about every 3 seconds. No effects on editing document, unsaved edits, selection, diff, global render or sync. Retain hidden-page pause, timeout and nonoverlap. Each row retains last good data on failure.
5. Append source events to Git-excluded RegistryApp/Activity/events.jsonl using that directory's .gitignore; do not delete on sync/restart/commit. Not canonical for judgments, acceptance or task status. Initially 200 events/30 commits suffice; no unauthorized source compression.
6. Safe local event CLI, format/examples in README; HTTP read-only fixed routes. Validate JSON/strings, display with textContent, fixed Git arguments/timeouts. Do not invent past stages.

<a id="作業依頼"></a>
## Assignments

Implementation Sol: only RegistryApp implementation/necessary tests/README/Activity/.gitignore. No Sources, Registry, Rules, other canonicals, Inbox or live server changes. No commit/restart/UI operations. Replace initial current-stage display with two rows; retaining old work-progress readers for compatibility is allowed. Run limited tests/return. Astra handles live sync.

Checker Sol: independently validate after implementation, return only acceptance-blocking findings; no fixes. Astra accepts/reflects records.

<a id="記録"></a>
## Record

Design/assignment prepared. Advance commit authorization is a separate policy discussion, not permission to commit here.

<a id="実装返却受入2026-10-18"></a>
## Implementation, return and acceptance (2026-10-18)

Worker Sol changed RegistryApp/activity.py, Activity/.gitignore, serve.py, index.template.html, README, two dedicated tests and the old JS test entry. Upper row: 200 events; lower: HEAD's 30 commits. Original event history retained.

Astra requested rework when removing oldest cards at the display limit shifted viewing position. Fixed by preserving a surviving visible card/position pair and not following new arrivals while a card is focused. Added checks; checker Sol independently compared. Recorded actual round trips through the CLI, not reconstructed past stages.

Python activity tests 3 (including multiprocess append), old-reader compatibility tests 2, and JS repeated retention/DOM/scroll/recovery/hidden-page/nonoverlap/per-row-failure tests passed. Checker independently checked actual HEAD reading, history retention and fixed routes. Astra live sync/existing verify passed.

Accepted within code/isolated-test scope. Real browser appearance/interaction retention and restarted live-server communication unverified. Existing server/screens untouched. Available after server restart/page reload. This document is formal acceptance; strip is observational.

Judgment caches consulted: neither Sol read any. Implementation/acceptance complete, awaiting commit; permission not yet obtained.

<a id="ユーザー確認と終了"></a>
## User confirmation and closure

2026-10-18: user display confirmation/commit approval 「みれました。コミットを」; complete. Not comprehensive real-browser noninterference assurance. Append actual SHA after commit and keep prior history.
