# V3の隔離HTTP・ブラウザ試行

## TL;DR
DBとStudioの編集関数の往復に続き、隔離サーバーと画面を出さないブラウザで保存・再開を試す。普段のStudio・実DB・Inboxは変更しない。

OPS-166 / EXECUTION / Astra調整・姫 / 2026-10-19ユーザー継続指示。

## 範囲
OPS-162工程3の残り。OPS-165の単一task担当/状態編集と明示的V3基準を再利用する。最初はファイル単位の変更内訳と、使えるブラウザ実行手段を姫が返す。Astra受入後に実装。

許可する実行は、専用TemporaryDirectoryのfixture DB・保存領域、127.0.0.1のOS割当ポート、既存インストール済みheadlessブラウザのみ。実験serverは起動者が終了させる。依存のインストールが必要なら事実を返す。現用8088のserver、実DB/Inbox/workspace、ユーザー画面、現用template/sync/serveは変更しない。

実験folder内のコードとREADMEのみ姫が変更する。表示用templateの隔離コピーで必要な互換patchは明示し、原本は読取専用。実験が本番経路を呼ばないことを確認する。

## 受入条件
HTTPから読込→実際の編集UIで担当/状態変更→隔離領域へ保存→ページ再開→同じ編集と基準が保持→最新DBとの差分確認→単一task更新を通す。再送の二重適用、同欄競合、別欄変更、世代変更、未対応編集の拒否を確認する。実験のDB反映操作は明示操作とし、保存だけで正本更新しない。

ユーザー画面は操作せずheadlessで実施。使用engineと実行範囲・省略した機能・互換patchを報告する。広い本番機能の再実装ではなく、実経路の最小確認に限定する。正本/Registry/commitはAstra。

## 実装内訳の受入（2026-10-19）

LTR-20261019-20EB16AE80CF434A99695D077B2D4237の提案を採用。既存Node/Playwright/WebKitで実行可能、インストール不要。実験folderにstdlib HTTP server、Node browser driver、Python試験を追加する。原本templateはメモリ上のコピーでOPS-165の3patchのみ適用する案。追加patchが必要なら明示する。

GET /・/workspace・/v3/latest、POST /save・/v3/applyのみ提供。saveは専用領域への追記だけ、applyは保存IDを指定した明示操作だけ。その他は404。ブラウザのroute interceptionで隔離origin外への通信を送信前に拒否し、要求記録でも検証する。

WebKitで実編集、再開、再送、別欄/同欄競合、世代変更、未対応編集混在を試す。実サーバーの稼働情報/連絡/承認/文書表示等は対象外。スクリーンショットは必要なとき一時証跡とし、目視品質保証とは呼ばない。serverとbrowserはfinallyで停止する。

## 受入結果（2026-10-19）

返却LTR-20261019-F712EE9162344E1EB5018C9EC31A7BD4を受入。AstraがResourceWarning有効で全105試験（既存98＋browser7）を独立再実行し、23.164秒で全件成功・警告なし。WebKit 2370 / Playwright 1.64.1を使用。

実UIの担当/状態編集→HTTP保存→新しいbrowser contextで自動再開→明示apply→再送で改訂が増えないことを確認。保存時にはtask・改訂・操作履歴が不変。同欄競合、別欄の独立変更、復元後の世代変更、未対応の辺編集混在を検証。隔離origin外への通信は送信前に拒否する負例を含む。server/browserの終了は試験cleanupで行う。

原本template/sync/serve/inboxは変更なし。互換patchはOPS-165のP1〜P3のみ。証跡は実験folderのevidence/ops166。採番待ち・連絡・承認・文書表示・server状態は空または404のため、画面に出る旧server警告と「Inboxを取り込んで」の文面は実験上の未対応表示。これらの実運用機能や視覚品質を受け入れたものではない。

限定した隔離経路として完了。本番切替、旧保存移行、複数task/構造編集、multi-tab保存系列の完全対応は別。次はOPS-162工程4の切替リハーサル設計で、残差と復旧時の採番境界を明示して扱う。
