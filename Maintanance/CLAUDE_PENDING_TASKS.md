# Claude採番待ちqueue

CodexがstableなRegistry IDを採番できない間に、ユーザーとClaudeが発見・整理・明示実行した作業を
一時的に受け渡す。このfileはTask Registryではなく、Claudeが自律的に次作業を選ぶbacklogでもない。

現在の入口は[進捗 V2](ProgressV2/PROGRESS_OVERVIEW_V2.md)、正式なtaskの状態・担当・依存・再開条件は
[Task Registry V2](ProgressV2/TASK_REGISTRY_V2.md)、制度・採番・文書権限は
[Task制度 V2](ProgressV2/TASK_RULES_V2.md)を参照する。CodexからClaudeへの個別依頼と返却は
[CLAUDE_TASK.md](CLAUDE_TASK.md)で扱う。

## 規則

- 仮IDは`CP-YYYYMMDD-NNN`とする。同日の末尾番号を増やし、再利用しない。
- ユーザーが「記録」「分解」「採番待ち」を依頼しただけなら、候補を記録して着手しない。
- ユーザーがClaudeへ具体的で境界のある実行を明示依頼した場合、その範囲だけ採番前に実行できる。
- 仮IDはTask precedence、正式な完了報告、別taskの依存、commit messageのstable IDとして使わない。
- ClaudeはRegistryの状態、最終受入、公開方針、Codex担当の完成判定を代行しない。
- 一件を終えても、別の採番待ち候補へ自動的に移らない。
- Codexは照合依頼や成果の返却を受けて関係するentryを読み、重複・衝突を確認し、正式登録、既存taskへの統合、却下のいずれかを判断する。通常起動時の一括読みに加えない。
- 正式採番後も仮IDを消さず、正式IDと処理結果を記録して追跡可能にする。
- reconciliation済みentryは、[圧縮・アーカイブ手順](ProgressV2/TASK_REGISTRY_ARCHIVE.md)に従い、原文と追跡経路を残して`Archived/`へ移し、現役queueから除く。
- 履歴文書（過去のreconciliation済みentryを含む）の効力は、[AGENTS.mdの「現在の仕事と正本」](../AGENTS.md#現在の仕事と正本)に従う。

## entry template

### `CP-YYYYMMDD-NNN` — <短い名称>

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_CODEX` / `RECONCILED`
- 発見元・ユーザー指示:
- 種別候補: `DISCOVERY` / `DECISION` / `EXECUTION`
- 対象範囲:
- 対象外:
- 完了条件:
- 前提・既存task候補:
- 担当候補・受入担当:
- 停止条件:
- 成果・検証: 未着手
- Codex reconciliation: 未処理

## 採番待ち

### `CP-20261014-002` — 副作用の勾配とタスクリファクタリングの参考資料化

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-14の会話。ユーザーが「それ、参考資料化したいな」と明示依頼した。
- 種別候補: `EXECUTION`（文書作成のみ）
- 対象範囲: `Maintanance/EFFECT_GRADIENT_REFERENCE.md`の新規作成。
- 対象外: `AGENTS.md`、`User/`、Orientation文書、Task Registryへの反映。規則化や正本採用。
- 完了条件: 会話で整理した副作用の勾配、タスクリファクタリング改訂版、Haskell対応、注意点、由来を、
  正本を上書きしない参考資料として一つの文書にまとめる。
- 前提・既存task候補: なし。Orientation V4草案（作業中）との関係づけはCodexとユーザーが判断する。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 既存正本との矛盾が見つかった場合は、参考資料側を直し、正本は触らない。
- 成果・検証: 作成済み。V4草案4件に同じ内容がないことをgrepで確認した（`User/MEMO.md`にユーザー自身の自己紹介文があるだけ）。
- Codex reconciliation: 未処理

### `CP-20261014-003` — 最小オリエンテーション草案（生成元と持ち主の表）

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-14の会話。「生成元の考え方」と「持ち主の表」の2つだけで新しい会話のAIを
  立ち上げられるか、という話の後、ユーザーが「ちょっとドラフトつくって、それ」と明示依頼した。
- 種別候補: `EXECUTION`（草案作成のみ）
- 対象範囲: `Maintanance/MINIMAL_ORIENTATION_DRAFT.md`の新規作成。
- 対象外: 採用、Orientation V4への統合、`AGENTS.md`・`CLAUDE.md`の変更、比較実験の実施。
- 完了条件: 生成元（3つの問い）、持ち主の表、既存規則の導出例、確かめ方の案を一つの草案にまとめる。
- 前提・既存task候補: `CP-20261014-002`（参考資料）。作業中のOrientation V4との関係はCodexとユーザーが判断する。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 持ち主の表の事実が正本と食い違えば、草案側を直す。
- 成果・検証: 作成済み。持ち主の表は`AGENTS.md`（Repository operation authority、Ownership boundaries、Xcode agent
  boundary）とRegistryの文書ランク節を読んで照合した。比較実験は未実施。
- Codex reconciliation: 未処理

### `CP-20261014-004` — 変化量・知っていること・タイムラグのドラフト

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-14の会話。ユーザーが「ここだけにするのもったいないから、ドラフト文書化ほしいな」と明示依頼した。
- 種別候補: `EXECUTION`（草案作成のみ）
- 対象範囲: `Maintanance/CHANGE_KNOWLEDGE_LAG_DRAFT.md`の新規作成。
- 対象外: 採用、参考資料・ポスター・Orientationへの反映、commit規約の変更。
- 完了条件: 所有と占有、課題グラフと問題グラフ、変化量、3本目の軸、タイムラグ、保留を確定として扱うときの決断・信任・責任（同日追記）、commit↔task差し戻しの観測を一つの草案にまとめる。
- 前提・既存task候補: `CP-20261014-002`、`CP-20261014-003`の続き。`GRAPH-001`（commit↔task対応表）。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 観測の数値が正本（git履歴・Registry）と食い違えば草案側を直す。
- 成果・検証: 作成済み。差し戻し4件は該当commitのRegistry差分を読んで確認した。性能CIの仮説は未検証。
- Codex reconciliation: 未処理

### `CP-20261014-005` — 判断の座標系の統合草案とAGENTS.md再評価

- queue状態: `AWAITING_CODEX`
- 発見元・ユーザー指示: 2026-10-14の会話。ユーザーが「これまでの3文書を姫がまとめ直して、ちゃっぴーと揉んで、確定し、
  そのあとのAGENTS.mdをその観点で評価し直したい」と述べ、手順の確認に「いえす」と答えた。
- 種別候補: `EXECUTION`（統合と評価）、確定は`DECISION`（ユーザー）
- 対象範囲: (1) `Maintanance/JUDGMENT_COORDINATES_DRAFT.md`の新規作成、(2) ChatGPTレビューの反映、
  (3) ユーザーの確定、(4) 確定した観点での`AGENTS.md`の評価文書（読むだけ）。
- 対象外: `AGENTS.md`・`CLAUDE.md`・Registryの変更、統合元3文書の削除。
- 完了条件: (1)〜(4)。(4)は評価結果を書いた時点で完了し、`AGENTS.md`を直すかはPrimeとユーザーが決める。
- 前提・既存task候補: `CP-20261014-002`〜`004`の統合。
- 担当候補・受入担当: 姫（Claude）実行 / ユーザー確定 / Codex受入。
- 停止条件: (2)の後、ユーザーの確定まで(4)に進まない。
- 成果・検証: (1)作成済み。補足資料`Maintanance/JUDGMENT_COORDINATES_BUDDHISM_NOTE.md`もユーザーの提案で追加。(2)ChatGPTレビュー反映済み。(3)ユーザー「もうほぼ確定。90％ぐらい」。(4)`Maintanance/AGENTS_MD_COORDINATE_REVIEW.md`作成済み（`AGENTS.md`は読むだけ）。
  評価中に、ID再利用禁止が`AGENTS.md`に10-06からあったと確認した。草案2本の「規則が消えた」は言い過ぎだが、
  確定済みの草案は触らず、訂正は評価文書の側に置いた（ユーザー「かくていしたものはさわっちゃだめ」）。
  その後ユーザーが評価結果を残り10％の差し戻しと位置づけ、「それでやって」と指示したので、統合草案に訂正とR-1〜R-5を反映した。持ち主の表は`MINIMAL_ORIENTATION_DRAFT.md`の照合済みの内容を写し、tag pushにreleaseと注記した（`AGENTS.md`の「tag push are user-operated」と照合）。
- Codex reconciliation: 未処理

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`
