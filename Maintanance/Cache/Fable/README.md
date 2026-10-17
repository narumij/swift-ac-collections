# FableのAI用キャッシュ

2026-10-17、ユーザーが会話で「中間記憶領域の使用を許可」。Fable（Claude Fable 5.1、称号なし）の記憶補助領域。調整代理期間中（OPS-044、[委任記録](../../Current/FABLE_COORDINATOR_DEPUTY.md)）はAstraへの引継ぎメモの置き場も兼ねる。

規則は [Task Rules](../../ProgressV2/TASK_RULES_V2.md) のAI用キャッシュ節に従う。このREADME以外はGit管理外。正本・権限・作業状態を置き換えず、操作直前のRegistry確認を維持する。他担当のキャッシュ（`../Astra/`・`../Hime/`）を上書きしない。

用途は2つ。`HANDOFF.md`：占有中のもの・未commit・未決のユーザー判断・次の一手。Astraへ戻すときの材料で、確定した内容は`FABLE_COORDINATOR_DEPUTY.md`の記録へ移す。`NOTES.md`：探索の打ち切りや感想の前置き。評価や記録の依頼があったときに正式記録へ移す。

一時用途は `Temporary/<task IDまたは固有名>/`。用途・削除可否・作業終了時の廃棄は [COMMONS](../../ProgressV2/COMMONS.md) に従う。領域の割当てのみで、taskの着手や状態変更を許可しない。
