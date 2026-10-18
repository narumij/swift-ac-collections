# OPS-115 承認経路の疎通確認

## TL;DR（人間向け）

承認保存からAstraによる取得・一件ずつの実行・画面表示までを、7色の固定ジョブで確かめた疎通試験。隔離検査とユーザーの実画面確認を経て受入済み。常設監視や実コミットの検査ではなく、会話終了後の自動再開・通知も未実装。

Requested by the user on 2026-10-18. This is a functional probe, not permanent monitoring.

Arrange seven fixed probe jobs: 1=red, 2=orange, 3=yellow, 4=green, 5=blue, 6=indigo, 7=violet. Reuse the approval API and individual/batch UI approval processing, while keeping the database and execution separate from commits. Astra retrieves approved jobs and executes them one at a time to change the text and color. The server alone must not advance the colors.

<a id="操作"></a>
## Operation

- `python3 -B Maintanance/RegistryApp/probe.py seed`: register seven jobs; reject if any remain unprocessed.
- In the UI probe section, approve individually or approve all currently displayed jobs.
- Astra checks with `probe.py list` and executes the first approved job with `probe.py run`. Never execute an unapproved job or execute one twice. To observe multiple colors, space runs farther apart than the UI polling interval of three seconds.
- After all jobs have been used or cancelled, seed can start another trial. History remains in Git-ignored Approvals/probe.sqlite3.

Automatic wakeup and notification are unimplemented. Approval after the conversation ends does not automatically resume Astra. This probe checks approval persistence → Astra retrieval → result persistence → UI display. Actual commit execution checks belong to OPS-114.

<a id="状態"></a>
## Status

An isolated database verified prevention of unapproved execution, sequential processing of all seven colors, prevention of reuse, re-registration and refusal of commit claims. Existing shared approval UI tests and Studio regeneration/structural checks passed. The user batch-approved all seven probe jobs; Astra processed them at four-second intervals, and the user confirmed the actual display changed: 「うごいてたｗ」. Accepted. The probe section starts collapsed to avoid clutter and opens only when testing. Astra did not operate the UI.
