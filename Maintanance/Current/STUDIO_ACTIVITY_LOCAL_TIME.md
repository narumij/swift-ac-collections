# 作業イベントの時刻表示

## TL;DR（人間向け）
作業イベントのマウスオーバーがUTC原文だったため、通常表示と読み違えた。tooltipもブラウザのローカル時刻へ変換し、日付・年・タイムゾーンを明示する。保存UTCは変更しない。

OPS-146 / 2026-10-19ユーザー依頼。担当Astra調整。index.template.htmlのvalidateActivityRowsとtest-activity.cjsのみ編集占有。他担当は正本翻訳のみで競合なし。サーバー操作なし、commitは別承認。

## 受入条件
イベントと履歴tooltipの表示がローカル時刻で、日跨ぎを含め正しく、入力timestamp原本は不変。既存poller/表示検査と異なるTZで確認する。

## 受入
Astra調整：通常表示はすでにローカル変換済み、tooltipだけ生ISOを使用していたことを確認。tooltipを年・日付・秒・短いタイムゾーン付きローカル表示へ変更。Asia/TokyoとAmerica/Los_Angelesで既存activity検査と日跨ぎの追加確認PASS。入力timestampとraw.atの不変を確認。実ブラウザは未操作。
