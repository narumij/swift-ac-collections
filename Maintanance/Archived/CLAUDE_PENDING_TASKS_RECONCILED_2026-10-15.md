# Claude採番待ちqueue — 2026-10-15 reconciliation済み原文

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

- queue状態: `CANDIDATE` / `USER_AUTHORIZED` / `AWAITING_COORDINATOR` / `RECONCILED`
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

- queue状態: `RECONCILED`
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
- Codex reconciliation: `CP-20261014-003`〜`005`とともに`OPS-037`へ統合。参考資料として受け入れ、現行規則にはしない。

### `CP-20261014-003` — 最小オリエンテーション草案（生成元と持ち主の表）

- queue状態: `RECONCILED`
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
- Codex reconciliation: `CP-20261014-002`・`004`・`005`とともに`OPS-037`へ統合。V5以前の草案として受け入れ、現行orientationにはしない。

### `CP-20261014-004` — 変化量・知っていること・タイムラグのドラフト

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-14の会話。ユーザーが「ここだけにするのもったいないから、ドラフト文書化ほしいな」と明示依頼した。
- 種別候補: `EXECUTION`（草案作成のみ）
- 対象範囲: `Maintanance/CHANGE_KNOWLEDGE_LAG_DRAFT.md`の新規作成。
- 対象外: 採用、参考資料・ポスター・Orientationへの反映、commit規約の変更。
- 完了条件: 所有と占有、課題グラフと問題グラフ、変化量、3本目の軸、タイムラグ、保留を確定として扱うときの決断・信任・責任（同日追記）、commit↔task差し戻しの観測を一つの草案にまとめる。
- 前提・既存task候補: `CP-20261014-002`、`CP-20261014-003`の続き。`GRAPH-001`（commit↔task対応表）。
- 担当候補・受入担当: 姫（Claude）実行 / Codex受入。
- 停止条件: 観測の数値が正本（git履歴・Registry）と食い違えば草案側を直す。
- 成果・検証: 作成済み。差し戻し4件は該当commitのRegistry差分を読んで確認した。性能CIの仮説は未検証。
- Codex reconciliation: `CP-20261014-002`・`003`・`005`とともに`OPS-037`へ統合。草案として受け入れ、確定した一般規則にはしない。

### `CP-20261014-005` — 判断の座標系の統合草案とAGENTS.md再評価

- queue状態: `RECONCILED`
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
- Codex reconciliation: `CP-20261014-002`〜`004`とともに`OPS-037`へ統合。統合・再評価の完了を受け入れ、後続の`OPS-034`・`OPS-035`との接続を記録した。

### `CP-20261015-001` — Task履歴SQLite索引の抽出器試作

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。ユーザーが`ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md`を示して整備を依頼し、
- 
  範囲の選択肢から「c：ignore設定とscript試作まで」を指定した。手順書のドラフトはAstra、試作の実施は姫（Claude）と明示された。
- 種別候補: `EXECUTION`（試作のみ）
- 対象範囲: 生成先のignore確認、Git管理する抽出器scriptの試作、task専用の一時directoryでの動作確認。
- 対象外: 手順書への実在コマンドの追記、手順書・抽出規則の採用、repository内の`Maintanance/TaskHistoryIndex/`への初回作成、
  Registry・`TASK_RULES_V2.md`の変更。
- 完了条件: 手順書の「初回作成」「通常の差分更新」「結果の確認」「再作成・中断・切替」に沿って動くscriptが置かれ、
  一時DBでの作成・差分更新・検査・検索の結果を記録する。
- 前提・既存task候補: `TASK_RULES_V2.md`「履歴の照合とSQLite索引」。`GRAPH-001`とは別物（こちらはGit履歴の索引）。
- 担当候補・受入担当: 手順書ドラフトAstra / 試作 姫（Claude）/ 手順書追記・採用はCodexまたはユーザー。
- 停止条件: 手順書の規定どうしが食い違う、または試作で新しい判断点（抽出規則の方針など）が出たら、試作側で仮置きして明記し、採用判断へ渡す。
- 成果・検証: 試作済み。
  - ignore: `.gitignore`の`/Maintanance/TaskHistoryIndex/`（commit `35d27990`で既設）が予定名のDBと付随ファイルに効くことを`git check-ignore`で確認。変更なし。
  - script: `Utilities/Maintenance/TaskHistoryIndex.py`（Python 3標準libraryのみ）。`build`・`update`・`status`・`verify`・`search`。
    別名の一時DBへ作成し検査後に置換、200 commitごとに出現と処理済みを同じtransactionで確定、lock fileで書き込み担当を一つに制限、
    読み取り系は存在しないDBを作らない。
  - 一時directoryでの確認（HEAD `35d1f604`、5506 commits、約13秒、出現16544件）: `verify` ok。古いcommitまで作成→差分更新した索引が全件作成と一致。
    独立したperl抽出との完全照合で523 commits（merge 20件・root含む）すべて一致。途中で出た3件の不一致はchecker側の誤りと確認した。
    lock中・対象範囲外の処理済みcommit・rule版違いで`update`が停止すること、欠けたcommitを`verify`が検出し`update`で補えることを確認。一時directoryは削除済み。
  - 試作で仮置きした判断（採用時に要判断）: (1) ID照合は採番表の18 prefixを固定し、prefix追加はrule版の更新と再作成とする。
    (2) mergeは第一親との差分、rename検出なし（削除と追加として記録）、binaryは対象外。(3) DBはrollback journal（WALを使わない）。
    (4) scriptの配置を`Utilities/Maintenance/`とした。
  - 未実施: 手順書への実在コマンド追記、repository内の`Maintanance/TaskHistoryIndex/`への初回作成。
- Codex reconciliation: `OPS-036`へ統合し、抽出器・採用規則・初回DBを一つの完了成果として受け入れた。

### `CP-20261015-002` — Task履歴索引へのRegistry行変化（介入の参考資料印）の追加

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。過去資料から介入を拾う方法として、「その時点でACTIVEまたはFROZENだったtaskに影響したか」を
  Registry行の変化で見る案を話し、ユーザーが「あくまでDB」に参考資料の印を持つ形を求め、「ひきうけてくれるなら是非やって欲しい」と依頼した。
- 種別候補: `EXECUTION`（試作のみ）
- 対象範囲: `CP-20261015-001`の`Utilities/Maintenance/TaskHistoryIndex.py`に、Registry行の状態・本文の変化を派生表として抽出し、
  等級つきの参考資料印を付ける処理と一覧コマンドを足す。動作確認はtask専用の一時directoryで行う。
- 対象外: 過去文書・Archived・Registryへの書き込み、等級規則の採用、介入かどうかの個別判定、手順書への追記。
- 完了条件: 等級を仮置き規則として明記した派生表が作成・差分更新で同じ結果になり、前回の手集計と件数を照合できる。
- 前提・既存task候補: `CP-20261015-001`。
- 担当候補・受入担当: 試作 姫（Claude）/ 等級規則の採用はCodexまたはユーザー。
- 停止条件: 等級の決め方に新しい判断が要る場合は、仮置きとして明記して採用判断へ渡す。
- 成果・検証: 試作済み。
  - script: `registry_changes`表（全行`mark = 参考資料`）と`changes`コマンドを追加。schema・rule版を2へ上げたため、版1の索引は差分更新できず再作成になる。
  - 抽出: merge以外のcommitで、Registry 2 file（旧`PROGRESS_OVERVIEW.md`・`TASK_REGISTRY_V2.md`）から消えたACTIVE・FROZEN行を、
    同じcommitで追加された同IDの行（Registry優先、なければArchived等）と対にし、状態か本文が変わったものだけを記録。
  - 一時directoryでの確認（HEAD `35d1f604`）: 336件。作成→差分更新と全件作成が一致。無作為12件を親・子commitのfile内容と照合し全件一致。一時directoryは削除済み。
  - 会話中の手集計307件との差29件は、同じcommitでArchivedへ移しながら状態を変えた行（FROZEN→EXCLUDED 15件、FROZEN→DONE 10件など）を今回は対にできたため。対にできず消えただけの行は0件。
  - 試作で仮置きした判断（採用時に要判断）: (1) 等級は structural＝FROZENから他状態・ACTIVE→FROZEN、routine＝ACTIVE→DONE、candidate＝その他。
    FROZEN→DONE・FROZEN→EXCLUDEDもstructuralに入る（再開・除外の指示を経たとみなす）。(2) merge commitは対象外。
    (3) 2026-10-04より前の別文書上のtaskは対象外。(4) 指示語の検出は補助情報で、等級には使わない。
- Codex reconciliation: `OPS-036`へ統合。等級は介入の意味を自動確定しない参考資料として受け入れた。

### `CP-20261015-003` — Task履歴索引の補助資料作成と採用反映

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。ユーザーが手順書を示して「これの補助資料でも作って書いておいて」と依頼し、続けて
  「めんどいから採用でいいよ」「文句でたら修正する」と、`CP-20261015-001`・`002`の成果の採用を指示した。
- 種別候補: `EXECUTION`（文書作成）、採用は`DECISION`（ユーザー、同日決定）
- 対象範囲: `Maintanance/TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md`の新規作成（同日、ユーザー指示で`Maintanance/ProgressV2/`へ移動）。採用指示を受け、手順書`ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md`の
  状態欄と「抽出器実装時に追記するもの」節へ採用記録と実在コマンドを追記し、scriptのdocstringを採用済みの記述へ更新。
- 対象外: `TASK_RULES_V2.md`の「SQLite索引は未実装」の記述、Task Registry、repository内の初回作成。
- 完了条件: 補助資料が手順書との対応・規則・確認結果・限界をまとめ、手順書から辿れる。
- 前提・既存task候補: `CP-20261015-001`、`CP-20261015-002`。
- 担当候補・受入担当: 姫（Claude）実行 / 採用はユーザー決定済み / Registry反映はCodex。
- 停止条件: 採用後に問題が出た場合はユーザーの指示で修正する（ユーザー「文句でたら修正する」）。
- 成果・検証: 作成済み。補助資料の使用例を一時directoryで実行し、`build`・`verify`・`search`・`changes`・`status`が動くことを確認した（一時directoryは削除済み）。
  手順書の既存本文は書き換えず、作成時点の状態を状態欄に残した。
  Codexへの連絡事項: `TASK_RULES_V2.md`「履歴の照合とSQLite索引」の「SQLite索引は未実装」が採用後の状態と合わなくなった。
- Codex reconciliation: `OPS-036`へ統合。採用済み実装としてV2の制度・作成接続記録を現状へ更新した。

### `CP-20261015-004` — Task履歴索引の場面ごとのメンテ操作と補助資料の配置

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。ユーザーが「通常メンテ操作、アーカイブ時メンテ操作、介入後メンテ操作が必要」と述べ、
  続けて補助資料について「資料ここにはいちしといて」と`Maintanance/ProgressV2/`を指定した。
- 種別候補: `EXECUTION`
- 対象範囲: `Utilities/Maintenance/TaskHistoryIndex.py`へ`routine`・`archive-check`・`intervention`を追加（schema版を3へ）。補助資料を
  `Maintanance/ProgressV2/TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md`へ`git mv`し、相対リンクを修正。手順書の採用済み実装の節へ場面ごとの操作を追記。
- 対象外: アーカイブ手順`TASK_REGISTRY_ARCHIVE.md`の本文、`TASK_RULES_V2.md`、Registry、過去のアーカイブ記録の修正。
- 完了条件: 3操作が一時環境で動き、手順書と補助資料から辿れる。
- 前提・既存task候補: `CP-20261015-001`〜`003`。
- 担当候補・受入担当: 姫（Claude）実行 / Registry反映はCodex。
- 停止条件: 採用後に問題が出た場合はユーザーの指示で修正する。
- 成果・検証: 作成済み。詳細は補助資料の「場面ごとのメンテ操作の確認」。一時directory・一時cloneは削除済み。
  `archive-check`の照合キーを初版から直した（状態の列を含めて誤認したため）。過去のアーカイブcommit 7件のうち3件で指摘が出たが、
  いずれも現行のアーカイブ手順以前の操作で、記録に残すだけにした。
  Codexへの連絡事項: `TASK_REGISTRY_ARCHIVE.md`の手順4から`archive-check --worktree`へ案内するかは、手順の持ち主の判断に残した。
- Codex reconciliation: `OPS-036`へ統合。3操作を採用済み抽出器の運用面として受け入れた。

### `CP-20261015-005` — Task履歴索引のrepository内初回作成

- queue状態: `RECONCILED`
- 発見元・ユーザー指示: 2026-10-15の会話。ユーザーが「V3オーサーに調査してもらってて、DBがないっていうからここにきてる」と述べ、DBの作成を求めた。
- 種別候補: `EXECUTION`
- 対象範囲: `Maintanance/TaskHistoryIndex/task_history.sqlite3`の初回作成（`build`）と`verify`。手順書・補助資料の「未作成」の記述の更新。
- 対象外: V3オーサーの調査そのもの、`HIST-001`の再開判断、Registry。
- 完了条件: DBが作成され`verify`がokで、V3オーサーが既定のpathで検索できる。
- 前提・既存task候補: `CP-20261015-001`〜`004`。調査の利用先は`HIST-001`（V3オーサー、FROZEN）の可能性があるが未確認。
- 担当候補・受入担当: 姫（Claude）実行 / Registry反映はCodex。
- 停止条件: なし。
- 成果・検証: 作成済み。HEAD `35d1f604`まで5506 commits、出現16544件、Registry行変化336件、schema 3・rule 2、`verify` ok。
  DBは`.gitignore`の対象（`git check-ignore`で確認）で、約6.6MB。未commitのscript・文書の変更は収録範囲に入らない。
- Codex reconciliation: `OPS-036`へ統合。Codexが既定DBを現在HEAD `f132c6a5`まで更新し、`verify`成功を確認した。

過去のreconciliation済みentryは次を参照する。

- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-13.md`
- `Archived/CLAUDE_PENDING_TASKS_RECONCILED_2026-10-14.md`

<!-- 2026-10-18ユーザー指示による状態名の一括統一。過去の引用中も現在の表記に正規化した。内容・当時の担当・処理結果は変更していない。変更前の表記はGit履歴で参照できる。 -->
