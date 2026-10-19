# 作業帯の一行カード化（OPS-113）

## TL;DR（人間向け）

作業履歴を小さい一行カードへ縮め、独立したコミット帯を外した変更。最初に取りこぼした現在作業の文字帯もユーザー指摘後に復活し、限定試験と表示確認・commit承認を経て完了した。担当・時刻・理由などの詳細と原履歴は保持する。

2026-10-18, Astra. Parent OPS-048. The user supplied an image and specified 「OPS-112・完了部分だけ」, 「中の色は帯と合わせて、外側が作業種別」, and no commit strip.

<a id="範囲"></a>
## Scope

One work-event row only. Small cards show ID/type; retain owner, time, reason and SHA in the existing detail tooltip. Match transparent background to the strip and distinguish type with border color. Keep commit events in the work flow. Remove commit-history display/polling without changing the existing read API. Preserve original history, editing state and scroll position. No server restart or screen operations.

<a id="検証受入"></a>
## Verification and acceptance

2026-10-18, implemented/accepted by Astra. Existing JS checks confirmed single-line cards, type attributes and no commit strip; repeated-item retention, scrolling, focus and fetch-control checks passed. Real display unverified. Owner/date/reason remain in tooltips. Awaiting commit.

<a id="取りこぼしの訂正"></a>
## Correction of an omission

User correction on 2026-10-18: only card shrinking had been implemented; the intent to restore the initial text strip was missed. The renewed assignment restored two lines above cards with current ID/stage, owner/time/details. Update from the last existing event-fetch record, without another input or fetch mechanism. Preserve the last display on communication failure. Limited checks verify latest details and failure retention.

<a id="完了"></a>
## Completion

2026-10-18: limited JS tests for the current-work text strip and single-line cards, sync/verify and diff checks passed. The user confirmed display and approved commit with 「もどった。コミットしよう」; complete.
