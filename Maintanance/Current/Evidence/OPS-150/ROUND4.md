# 第4限定返却 D-20261019-04

## 結論

ROUND3の指摘1について、H-07補正後の実装・waiting fixture・規約文の一致を確認した。test-start-pending.cjsは終了0/PASS。この1件の再確認範囲に新規指摘なし。受入判断は調整担当へ返す。

## 固定入力と結果

開始読取：2026-10-18T21:39:19Z。以下のSHA256を固定し、21:39:34Zのテスト後再照合でも一致。

| ファイル | SHA256 |
| --- | --- |
| index.template.html | 1f03f5fb5648063956b86d5edb006731555b03e011b2350aa3fce097fa40fc6a |
| test-start-pending.cjs | 31b7bf6eea6d1ee15e73971381dd07ff5259296cbb526ed69b629effdcab1109 |
| COMMUNICATION_PROTOCOL.md | 409a805a596f4292255fe15122e0ee483f9a94c9fc1bc7b926c3b2195a888972 |

- 期待・根拠：MEMBER_START_VISIBILITY_FIX.md H-07は、H-06のworking/return/ended限定を維持し、waiting単独では閉じない。
- 実態：startPendingsの同ID/task一致分岐は、workingまたはendedまたはreturnの場合だけentries.deleteする。waitingは残し、同IDなので対応未確認にも変えない。
- fixture：依頼→同ID/task/本人waitingで開始待ちが残る、段階は依頼済みのまま、続く同ID workingで閉じる、の3assertを確認。専用test-start-pending.cjsのみ実行しPASS。
- 規約：Member statusはworking/ended/returnで閉じること、同ID waitingでは残ることを明記し実装と一致。
- 区分：前回の実装側不一致・仕様文書側のずれは、この固定入力と限定範囲で補正確認済み。全体受入や実画面の保証ではない。

修正・sync・commit・HTTP・実サーバー・画面操作なし。他fixtureの再実行なし。本人開始はD-20261019-04で記録。返却とpresence/continuity endedを記録し、本書の占有を終了する。
