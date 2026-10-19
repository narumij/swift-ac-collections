# スタジオ評価役 D-20261019-05 — H-10第1区切り

## 結論

入力→VMの列挙された意味ケースと14段baseline互換はPASS。VM→DOMでは、既存メンバーの並び替えがVM順序へ追従しない1件を確認。互換性をVMへの正しい反映と同一視しない。受入・修正判断は調整担当へ返す。

## 固定入力

2026-10-18T22:15:12Z、HEAD `73b623ea58bec87a03bca13fcb2f8250f2bcd920`。未commit作業版のSHA256。評価後の再照合でも一致。

| 対象 | SHA256 |
| --- | --- |
| STUDIO_VIEW_MODEL_DISCUSSION.md | 86fb60eefdbc42abc3fcd8986b2f4b8f431a756f5753b22a82f20435738c4f0b |
| index.template.html | b15cac3debf1ececde4b0b029920f339c2812554c1f78dbad7db517088168e0f |
| test-view-model-members.cjs | f883c0719d1de5b58d24816fb8f4e4533a6f54d14e63b32b2a2da9ee19e86e2f |
| view-model-members.baseline.json | e7cc46d7ca8bef8e96d370c4065fa2a145de7a6ad50eec8e8e6b6f89210cc6ef |

## 観点1：入力記録→VMの意味

memberModelは本人申告と開始待ちを分離。memberViewModelsはactivity担当、pendingのみ宛先、continuityのみ担当の順で情報を組む。未申告をworkingへ推定せず、ユーザーを除外。専用試験の文言・旧ACK注記・開始待ち・continuity入力・新着担当の契約ケースがPASS。関連start/handoff試験もID/task/宛先対応、waitingで閉じないこと、本人申告維持を確認した。

鮮度は現段階ではcontinuityText関数から渡る文字。時計snapshotと全Viewへの単一revision配布は段階4で、本区切りの完了とはしない。固定入力と固定VMの対応を限定検査した。

## 観点2：VM→DOM — 指摘1

- **期待・根拠**：ユーザー二観点、H-10「Viewは渡された表示状態を描く」、返却のmemberViewModels「表示の順に返す」。
- **実態**：履歴を使わない固定VMをcreateMemberLampViewへ渡す最小照合。初回 `[A,B]`、次に `[B,A]` とshowしても、DOMは `[A,B]` のまま。head/bodyは一致するが順序が異なる。スタブDOMと実関数で再現し、追加ファイルは作成していない。paintはVM位置ではなくlamps Mapの挿入順を使う。
- **区分**：**実装側（VM→DOMの順序不一致）**。以前にも同じ挿入順処理があり、今回の抽出で新たに生じた回帰とは主張しない。baseline互換PASSは不一致を否定しない。順序固定が意図ならVM順序の契約との整理が必要で、評価役は仕様変更しない。
- **試験上の不足**：専用試験はVM順序をassertし、結合DOMをbaseline比較するが、固定VMの順序変更をView単体へ渡すassertがない。互換と正しさを分けると残る問題である。

## 既知差・検証・限界

flashタイマーが最後のVMを使う差は報告済み。新規指摘に数えない。Viewがcontinuityを再読取しない設計と整合するが旧動作との完全一致ではなく、段階4の時計入力とVM revision統合で確認する予定の項目。

test-view-model-members.cjs、test-start-pending.cjs、test-handoff-signals.cjsのみ各1回実行し終了0/PASS。加えて上記固定VM→スタブDOMの最小照合を実施。baseline14段はUTC/ja-JP/固定markとage、匿名合成データによる互換証拠であり正しさの証明ではない。

実画面・CSS・ブラウザ・HTTP・実サーバー・syncは未実施。他表示、配送順序、全体snapshot統合は未評価。実装・正本・baseline変更、commitなし。返却保存の初回は親ディレクトリ不在で失敗し通知未送信を確認、ディレクトリ作成後に保存・通知した。本人返却とpresence/continuity endedを記録し占有終了。
