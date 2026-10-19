# 作業イベントカードの担当表示（OPS-124）

## TL;DR（人間向け）

作業イベントの小さい履歴カードへ、既存ownerを使って担当を表示した変更記録。関連試験と文字の安全な表示を確認して技術受入した。表示の限定変更で、実ブラウザは未確認。

User request, 2026-10-18; implemented by Astra, parent OPS-048.
Change small history cards to 「タスクID · 担当 · 工程」. During consideration use 「OPS-xxx · Astra · 検討中」 without repeating the owner. Read the existing owner field; do not infer it. Retain owner display in details/title. Recent-work cards already have an owner row and are unchanged. No save-format, server or approval-operation changes.

<a id="技術受入"></a>
## Technical acceptance

Updated expected activity-test headings to include owner; PASS. Existing fixture containing HTML-like owner text still displays it as text. Work-lane tests PASS; real browser unverified. Cancelled the old preapproval card because it omitted a test file and registered a replacement including it.
