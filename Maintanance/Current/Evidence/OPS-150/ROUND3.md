# 第3限定評価 D-20261019-03 — 開始表示修正

## 結論

主要経路は隔離試験で成立した。ただし、H-20261019-06で限定した閉じる条件が、実装・規約追記では「任意のpresence」へ広がっている1件を返す。受入・修正・仕様確定は行わない。

## 固定入力

2026-10-18T21:35:48Zに読取、HEAD `72ebbdb075c1a8f354f4effe5eeba23b88081bfa`。以下は未commitの作業ファイルのSHA256。21:36:29Zの再照合でも一致した。

| ファイル | SHA256 |
| --- | --- |
| index.template.html | d367a4996f0a076ab4b452acebee8852c1d487766a005afe25197ee4185dc357 |
| test-start-pending.cjs | 9bad2502f92b19567c745820a9c3d781f0358d02f2df7cbe0ccdb6cd009b8ff3 |
| test-handoff-signals.cjs | ac07c363b2f149d65869ba62c43c8e8f61698f6b7d6d0afe299971012d6095f5 |
| COMMUNICATION_PROTOCOL.md | dcb07c32b1f9b43fa85a0a8c08b2980ae9a76c4ac1931f35a34bd18178cbe678 |

仕様入力はMEMBER_START_VISIBILITY_FIX.mdのH-06補正。姫実装返却は実装説明として読み、確定依頼を置換するものとは扱わない。

## 指摘1：waitingだけで開始待ちが閉じる

- **期待・根拠**：H-06の「同じIDの本人working/return/endedで開始待ちを閉じる」。waiting単独は列挙に含まれず、作業カードにも実着手として出さない。
- **実態**：index.template.htmlのstartPendingsは `r.presence || row.event==='return'` を閉じる候補とし、ID/task一致なら削除する。したがって依頼→同ID/task/宛先本人の `work + presence=waiting` で開始待ちは0件になり、本人状態はwaiting。メモリ上で実関数にこの2行を渡し再現した。ファイル追加・ログへの試験データ書込なし。
- **区分**：**実装側：確定依頼H-06との不一致**。同時に規約追記§2が「a declared state or a return」と広げており、**仕様文書側にも依頼とのずれ**がある。実装と追記が相互一致していても、H-06の限定を満たした証拠にはしない。waitingも閉じる意図へ変更するかは調整担当・姫の協議事項で、評価役は決定しない。
- **影響**：本人が開始・返却・終了を申告せず待機だけ伝えた場合、開始待ちの補助表示が消える。現実の発生件数・実画面への影響は未検査。新規fixtureにはwaitingが作業カードを進めないassertはあるが、pendingを残すassertはない。

## 成立した範囲

新規test-start-pending.cjs、既存test-activity.cjs、test-work-lane.cjsを各1回実行し終了0/PASS。初回3fixtureは再実行していない。限定ソース照合と新規fixtureでは、先頭ID・task・宛先本人の対応、02と020の非合流、旧WAKE ACK/別ID/別task/他者記録で閉じないこと、新宛先の本人記録なし、主申告を変更しない補助表示、対応する本人workingだけが作業カードの着手になることを確認。

本人開始は21:36:02Zの会話依頼に基づく記録が先行し、親の正式requestイベントは21:36:03Zだった。親の指示を受け、正式イベント受領後の21:36:29ZにD-20261019-03で本人開始を追記した。過去時刻は変更していない。この記録順序は入力の対応条件として区別する。

## 既知境界・未確認・返却

旧宛先「デバッグ試行」のD-20261019-01開始待ち残存は既知、取消/宛先訂正未実装の境界。新発見に数えない。200件窓、実行確認、代理停止、取消、実画面・HTTP・サーバー稼働版は未評価/範囲外。修正・sync・画面/サーバー操作・commitなし。対処優先度、仕様協議、受入は調整担当へ返す。本書返却で占有を終了し、本人returnとpresence/continuity endedを既存CLIで記録する。
