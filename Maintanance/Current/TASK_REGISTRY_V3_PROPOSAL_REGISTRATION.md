# V3提案登録の隔離試行

## TL;DR
仮カードを正式採番し、接続先も同時に置き換える。途中失敗では採番と接続をともに戻す。同じ提案か曖昧な保存は保留。本番や復旧後の採番再開は扱わない。

OPS-171 / EXECUTION / Astra調整・姫 / OPS-167 K4 / 2026-10-19継続指示。

## 範囲と受入条件
OPS-167返却LTR-20261019-5B9211B1BBF446F196142AF4CE7B0858の限定内訳を採用。新規の隔離DBを用い、復元DBは書込停止のまま。register_proposalはtask/highwater/proposal_mapと、そのdraftを参照するprogress/linkを同一transactionで確定する。制約違反や途中失敗では全体をrollbackし、成功の再送では同じIDを返す。

prefixと正式fields、各接続のconstraint、根拠は明示resolutionで渡す。相談待ちは保存だけで解除しない。draft間接続は今回未対応として明示拒否。saveId/draftIdをキーとし、系列を推定しない。明示された祖先保存に同draftの登録があればidentity確認待ち。系列情報の欠落を独立した新規保存の証拠にせず、呼出側が独立保存か既知系列かを明示する。sameAsや新規と決め直す処理は今回実装しない。

proposal群が含む辺/linkを既存構造群から二重に適用しない。選択・consumption claim・operation digestを一体で扱う。複数draft全体の原子性は保証しない。既存single-task経路はproposalを引き続き拒否する。

変更対象はExperiments/registry_v3_read内のwrite/adapter/harness、試験とREADMEのみ。現用template/server/DB/Inbox、採番復旧helper、CURRENT切替は変更しない。姫は実装・試験を返却、Astraが独立受入と記録・commit。

## 初回受入の補正（2026-10-19）
返却LTR-20261019-ED187FD938B140928A94F02E0B7B6B79。Astraが二接続で、childのidentity確認後にancestorを登録する順序を再現した。ancestor/draft-1がTASK-006へ登録された後もchild/draft-1がTASK-007へ登録され、明示祖先の登録済み保留をすり抜けた。正式ID自体の衝突ではなく、同じ提案の重複登録である。

補正依頼LTR-20261019-ACEFE5229C7442F980B6EC5135EE57A7。ancestryを要求とdigestに含め、登録transaction内で再確認する。直接APIと再送でもidentity契約を守り、決定的な二接続試験を追加する。受入保留、本番変更なし。

## 受入結果（2026-10-19）
補正返却LTR-20261019-ACEFE5229C7442F980B6EC5135EE57A7を受領。Astraが全162試験を30.404秒で独立実行し成功、ResourceWarningなし。祖先確認を登録transaction内へ置き、ancestryを要求digestに含めた。競合した子側はidentity待ちとなり、番号・mapping・claim・操作履歴を追加しない。直接APIのidentity契約と正式fieldsの型も検証する。

採番と全接続の原子的登録、再送、失敗rollback、明示系列、同一提案保留を隔離範囲で受入。draft間接続・複数draftの一括原子性・sameAs・本番接続・復旧再開は対象外。OPS-171完了。
