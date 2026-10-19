# V3既存カード計画編集の隔離試行

## TL;DR
既存カードの並べ替え・版間移動・表示名変更を、一つの計画更新としてDBへ反映する隔離試行。新しい版・カード、ゲート、現在位置の変更は含めない。

OPS-172 / EXECUTION / Astra調整・姫 / OPS-167 K5限定区切り / 2026-10-19継続指示。

## 範囲
内訳LTR-20261019-0509F7ECF45D47DAA79CE3F5FE5B1135から既存カードの編集だけを切り出す。版の順序・構成、gate、focus、recordedDoneは固定。既存cardの移動・順序・表示名だけを扱う。新規ID、版比較方式、本番権限の決定を含めない。

表示用pathから得られる順序は提案としてのみ読む。明示resolutionで対象版のcard順序・移動・表示名と根拠を確認する。保存基準と現在DBを比較し、影響する版の順序・名前の競合は拒否する。一つの計画群を原子的に適用し、全cardの一意所属と合成graphの循環を検証する。既存task接続は勝手に移し替えない。

骨格はDBから導出する。Studio再構築時に旧骨格が残る問題を補正するが、実在Markdownを出典と偽装しない。必要なら実験用のtemplateメモリpatchでv3-db:skeletonを扱わせ、正本と提案の区別を維持する。派生線だけを除外し、未知の線を黙って捨てない。

planConditionは正本へ自動採用しない。新規版/card・draft-ms接続・gate/focus/recordedDone・版改名/削除は今回未対応として明示する。既存group経路・再送・消費管理を維持する。experimentのwrite/adapter/harness/test/READMEのみ変更し、本番template/server/DB/Inbox/Milestones/DESIGNは変更しない。

## 受入
実UI関数経由の保存で並べ替え・移動・表示名変更、再送、変更要求の食い違い、古い基準、循環時rollback、骨格線の重複防止を検証する。復元DBは閉じたまま。姫が実装と試験、Astraが独立受入・記録・commit。

## 受入結果（2026-10-19）
返却LTR-20261019-538FA024229D4296A986B76ABD89E0B3。Astraが全175試験を32.501秒で独立実行し成功、ResourceWarningなし。対象版の順序と変更名の基準照合、移動と改名の原子的更新、循環時rollback、再送、明示確認を受入。固定IDとtask接続を維持する。

隔離harnessのP4でv3-db:skeletonを置き換え対象にし、旧派生線の残存を防いだ。adapterは提案した構造の骨格と派生線の集合一致を検査する。他の出典の線は勝手に除外しない。実Markdownを出典と偽装していない。

限定範囲として完了。本番template・Milestonesに変更なし。OPS-166の隔離browser serverにはP4がまだなく、実ブラウザ計画編集は後続接続が必要。GATE-以外のgate IDをStudio planPartsがcard扱いする制約も残り、opaque ID全般のUI保証はまだない。新規版/card・gate/focus/recordedDone等は未対応のまま明示拒否する。
