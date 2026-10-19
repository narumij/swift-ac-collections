# 未採番DBの単独試作

## TL;DR
未採番1件を長いMarkdownの読み直しなしに扱える、小さな単独DB試作を姫へ依頼する。正式タスクで改訂後のCLAUDE.mdに沿った仕事ができるかも観察する。いまいちなら凍結し、成果の救済を目的にしない。

正式ID：`OPS-185` / DONE

## Request — 2026-10-20
ユーザー：「未採番依頼を取り消して、タスクで依頼してください。単独動作を足して構わない」「いまいちなら凍結すればいいんだよ」。担当：姫。受入：Astra。CP-20261020-004の再依頼は取り消し、この依頼で仕切り直す。

Purpose: reduce the coordinator's reading and reconciliation burden per pending item. This is a small working prototype, not a production migration.

Build a standalone SQLite-backed tool: add a free-text item, list open items, show one item, close it with an outcome, and read closed history. Record timestamps automatically. A small CLI is sufficient; Studio and the communication server must not be required to run it. Reuse earlier code only where it fits this request; do not revive the withdrawn scope.

Follow the current CLAUDE.md communication guidance. Start with the smallest useful explanation of the purpose, working form and checked facts. The scope above is authorized; do not request approval again for settled premises. Then implement and actually use one representative item end to end. Do not invent feedback from Astra or call a role-play independent acceptance.

Editable scope: a task-owned prototype directory under Maintanance/Cache/Hime/Temporary/ (record its path), and this document's Return section. No production DB/server changes, queue migration, Studio UI integration, formal-ID issuing, or commit. No git stash operations. Existing user edits remain untouched.

Return the runnable command, artifact path, actual observed results and any unmet requirement concisely. Acceptance checks: (1) runs without the existing servers, (2) the receiver can reproduce add/list/show/close from the supplied instructions, (3) closed text and outcome remain readable. Do not leave missing investigation or repair to the receiver. Stop after this first usable slice; further integration is a separate decision. If it is not useful, freezing is a valid outcome rather than expanding the work to rescue it.

## Return — 姫
2026-10-20 05:13。第1スライス完了。commitなし、本番DB・サーバー・queueは未変更。

- 成果物：`Maintanance/Cache/Hime/Temporary/OPS-185/pending.py`（標準ライブラリのみ・約90行）。DBは同じ場所の`pending.sqlite3`、`PENDING_DB`で切替可。
- 使い方（作業ディレクトリは問わない）：
  - `echo '本文' | python3 pending.py add --by 名前 --title 件名 [--task ID]` → `PD-YYYYMMDD-NNN`を表示
  - `python3 pending.py list`（未処理）／`list --closed`（閉じた分と結果）
  - `python3 pending.py show ID`（未処理・閉じた分とも）
  - `python3 pending.py close ID --by 名前 --outcome 結果`（結果は必須）
- 実際に確かめたこと：
  1. 代表1件（CP-20261020-003の内容）でadd→list→show→close→`list --closed`→showを通した。閉じた後も本文と結果を読めた。時刻は各操作で自動記録。このcloseは動作確認のため姫が行ったもので、照合・判断ではない（CP-20261020-003は未処理のまま）。
  2. 別ディレクトリ・別DB（`mktemp -d`、実行後に削除）で上の手順を再現できた。名前欄に`Astra`と入れたが、Astraの操作ではない。
  3. 二重close・存在しないID・空の本文は、メッセージを出して終了コード1で止まる。
  4. 依存は`argparse, datetime, os, sqlite3, sys`だけで、ネットワークもStudioも使わない。実行時にlistenしているpythonプロセスは0件だった。
- 満たしていない点・気づき（直していない）：close前に情報を足す手段がない。受け取る側に何をしてほしいかの欄がない。closeできる人を制限していない。番号は件数から振るので、同時に複数が登録すると重なりうる。

一時作業物:
- `Maintanance/Cache/Hime/Temporary/OPS-185/`（実体 `/Users/narumij/Documents/GitHub/swift-ac-collections/Maintanance/Cache/Hime/Temporary/OPS-185`）・姫・2026-10-20 05:12・試作のCLIと試作DB・状態「使用中」。Git管理外（`.gitignore:21`）

## Acceptance — Astra
2026-10-20：限定した単独試作として受入。Astraが別の一時DB・別作業ディレクトリで登録→一覧→詳細→close→閉じた一覧→詳細を実行し、本文と結果の保持を確認。コードの依存は標準ライブラリのみでネットワーク使用なし。3点を追加の実装修復なしで確認できた。

返却のコマンドはpending.pyの場所を別途合わせる必要があり、「作業ディレクトリは問わない」はスクリプトのパス指定が前提。検収では成果物の絶対パスを使用した。その他、未達の明示と試験操作・実際の判断の区別はできている。未対応として申告された同時登録、追記、権限制御は今回の限定受入に含めない。本番運用・移行・UIの受入ではない。今後の採用や拡張は別判断とし、追加依頼しない。

