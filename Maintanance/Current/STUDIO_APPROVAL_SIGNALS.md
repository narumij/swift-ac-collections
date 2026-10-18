# 承認レーンの信号表示（OPS-121）

## TL;DR（人間向け）

承認レーンの件数を赤・緑・黄と文字で示し、未取得や失敗を「未処理なし」と誤表示しない変更記録。既存試験と表示生成の確認を技術受入した。承認権限や保存方式は変更せず、実ブラウザ表示は未確認。

Implemented by Astra on 2026-10-18 after user approval 「そうそう」. Parent OPS-048.

<a id="要求と対応"></a>
## Requirement and response

In the approval-lane heading, show counts with pending as 🔴承認待ち, approved as 🟢承認済み・Astra未処理, and claimed as 🟡Astra処理中. Show multiple states side by side. If all are 0, show ⚪未処理なし. consumed/cancelled stay in the existing history. While loading or on failure, the existing checking / trouble display takes precedence; never call an unloaded state 未処理なし. States are distinguished by text as well as colour. The probe lane is unchanged.

<a id="範囲"></a>
## Scope

Display in index.template.html only. Approval authority, storage, API and server operations are unchanged.

<a id="確認技術受入"></a>
## Checks and technical acceptance

The existing test-approvals.cjs and test-work-lane.cjs PASS. Ran the display-building part of the implementation directly and confirmed: empty / history only → white; three states mixed → one each of red, green and yellow. git diff --check is clean. Not checked in a real browser.
