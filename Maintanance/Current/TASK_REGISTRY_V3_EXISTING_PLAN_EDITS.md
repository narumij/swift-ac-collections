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
