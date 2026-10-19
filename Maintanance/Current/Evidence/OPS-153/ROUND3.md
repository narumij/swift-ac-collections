# D-20261019-07 — H15補正3件の独立再評価

## 結論

ROUND2の3件をH15の確定契約で再確認し、いずれも補正を確認した。専用・直接関連3試験はPASS。この限定範囲に新規指摘なし。全体受入・commitの判断は調整担当へ返す。

## 固定入力

開始2026-10-18T22:47:43Z。未commit作業版のSHA256はテスト後も一致。

| ファイル | SHA256 |
| --- | --- |
| index.template.html | 704d18fadee01356e99c3734de98ae28664fbac5c46385bea75a4e256d0ec885 |
| test-view-model.cjs | d0012c2e56e98b54b22316178974ecfeb1dc5b5496b3be5a06c76d51cdbd28c1 |

## 3件の照合

| 前回指摘・期待 | ソースとfixtureの確認 | 区分・結果 |
| --- | --- | --- |
| 全Viewへ同revision。入力ごとに一derive | createStudio.inputはderiveStudio(s)を一回呼び、存在するpartsすべてへvm.revisionを渡す。activity/approvals/clock/continuity/WAKE選択それぞれで全4View同revision、1ViewのみのwrapperはそのViewのみ、を専用fixtureで確認。 | 前回の実装側不一致は限定補正確認済み。依存部分のみの省略なし。 |
| 実公開入口で受信時刻、continuity失敗ok=falseとlast-good保持 | createStudioのnowは注入可能、既定Date.now（epochミリ秒）。activity/失敗・approvals/失敗・continuity各入口がatを設定。continuityはdata.failedでok=false、失敗時は正常値を置換しない。専用試験は公開入口とcreateContinuityStatus.onData→studio.continuityのページ同等配線で世代/時刻/ok/last-good/不調文言を確認。鮮度用performance時計との単位を区別。 | 前回の実装側不一致は限定補正確認済み。apply直呼びだけの証拠にはしていない。 |
| A送信中→B選択→A成功/失敗をBへ帰属させない | wakeSendが開始時owner/keyをwakeSendingへ固定。sendとwakeNoteForは固定対象を使用。成功・失敗両fixtureで送信先A、Bの注記は空、noteForはA開始時キー。選択変更なしでは当人へ成功/失敗の注記を表示。 | 前回の実装側不一致は限定補正確認済み。結果を全担当の永続履歴として保持する要件は今回評価していない。 |

## 実行と保証範囲

実行：test-view-model.cjs、test-view-model-current-wake.cjs、test-continuity.cjsを各1回。すべて終了0/PASS。入力境界→snapshot/VMと、固定VM→DOM/操作の関連確認を区別した。current/WAKEのbaseline6+12段は互換証拠で、3件の正しさは上記契約fixtureとソース照合を根拠とする。

H15返却の隔離headless r2は今回再実行・画像確認していない。実画面・実サーバー・HTTP・広い再監査は未実施。activity不調中のcontinuity更新という採用済み差、200件窓、旧宛先残存、取消未定、同名制約は既知のまま。新規の仕様側指摘はなし。修正・sync・commitなし。本人returnとpresence/continuity endedを記録し本書の占有を終了する。
