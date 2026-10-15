# Task履歴SQLite索引のメンテナンス手順

> 採用済み。2026-10-15、ユーザーの採用指示により、本書と抽出器`Utilities/Maintenance/TaskHistoryIndex.py`、およびその抽出規則・等級規則を採用した。同日、V3オーサーの調査のため、ユーザーの依頼でrepository内に初回作成した（HEAD `35d1f604`まで、5506 commits）。実在するコマンドは末尾の節、試作時の確認結果と規則の詳細は[補助資料](TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md)を参照する。索引の意味と限界は[制度の参照](TASK_RULES_V2.md#履歴の照合とsqlite索引)に従う。
>
> 2026-10-14の作成時点の状態：候補・未採用。SQLite本体・抽出器・専用の更新コマンドは未実装。

## 目的と置き場

commitに現れるtask IDを検索し、必要な履歴へ短くたどれる状態を保つ。検索のための生成物なので、Gitと抽出条件から作り直せるようにする。

| 対象 | 配置と扱い |
| --- | --- |
| SQLite本体 | `Maintanance/TaskHistoryIndex/task_history.sqlite3`。生成物としてGitから除外 |
| 一時DB・更新log・DB付随ファイル | 同じ`Maintanance/TaskHistoryIndex/`内。Gitから除外 |
| 抽出器・検索手順 | `Utilities/Maintenance/TaskHistoryIndex.py`と本書をGit管理する。生成物のフォルダには置かない |
| この手順 | `Maintanance/ProgressV2/TASK_HISTORY_INDEX_MAINTENANCE.md`。V2文書とともにGit管理 |

## メンテナンスが必要なとき

| 状況 | 行うこと |
| --- | --- |
| 初めて索引を使う、DBがない | 対象範囲を決めて初回作成 |
| 検索したいcommitが収録範囲より新しい | 同じ条件なら差分更新 |
| 対象履歴・抽出規則・DB構造が変わった、破損した | 別のDBへ再作成し、確認後に切替 |
| 検索対象が既に収録済み | そのまま検索。起動のたびに更新しない |

作業を任された担当が必要時に行う。定期実行や別の管理担当を、この手順だけで新設しない。

収録範囲・重複・DB整合の定型検査は抽出器へまとめ、通常の更新ではAIが対象範囲と結果を確認する。毎回、全履歴や本書の全手順を読み直して判断し直す運用にしない。

## 作成・更新前に確かめる

1. 対象リポジトリと、検索に必要なref・commit範囲を確かめる。refは実行開始時のcommit SHAへ解決して固定する。初回の範囲案は、その時点の`HEAD`から到達できる履歴。別branch・tagの履歴は必要なときに加える。
2. 既存DBがあれば、対象リポジトリ、収録済みcommit、対象範囲、抽出器・抽出規則・DB構造の版、前回結果を読む。索引の更新日時だけで現在性を判断しない。
3. 書き込み担当は一つにする。別の更新処理が動いていれば重ねて起動せず、その結果か終了を確かめる。
4. 生成先がignore対象であることを確認する。ローカルにあるGitの履歴を読み、未commitの作業内容は収録範囲と分ける。

次は現在も利用できる確認例。リポジトリ直下で実行する。

```sh
git rev-parse --show-toplevel
git rev-parse --verify HEAD
git rev-parse --is-shallow-repository
git check-ignore -v -- Maintanance/TaskHistoryIndex/task_history.sqlite3
```

shallow cloneや参照できないGit objectがある場合、得られた範囲を記録する。必要な履歴が欠けている検索結果を「出現なし」「未使用」の根拠にしない。取得済みの範囲で足りる検索は続けられる。

## 初回作成

1. 対象commit集合を固定し、新しい一時DBへ抽出する。専用コマンドは抽出器の実装時に本書へ記載する。
2. commitメッセージと、変更差分の追加行・削除行からtask IDの出現を記録する。commit SHA、出現箇所、ファイルパス、原文へ戻れる位置を保つ。差分の文脈行に現れるだけのIDを「変更したID」に混ぜない。
3. merge commitの差分をどの親と比較するか、root commitをどう扱うかは、抽出器の規則として固定・記録する。差分からの出現には比較元の親を残し、規則の異なる結果を同じ索引へ混ぜない。
4. IDが出なかったcommitも処理済みと記録する。途中までの抽出と、対象範囲をすべて処理した結果を区別できるようにする。
5. 下の「結果の確認」を行い、成功したDBを検索に使う。失敗した場合は、処理済み範囲と失敗箇所を残し、完了した索引として渡さない。

## 通常の差分更新

1. 対象リポジトリ・抽出規則・DB構造が前回と同じことを確かめる。
2. Gitのcommit集合と処理済み集合の差から、追加分を求める。日時や「前回の最終commitより後」だけで、branchやmergeのcommitを取りこぼさないようにする。
3. 追加分を抽出する。出現記録と、そのcommitの処理完了・収録範囲の更新を同じtransactionで確定する。途中失敗で、実データより進んだ完了位置を残さない。同じ更新を再実行しても出現を重複させない。
4. 更新後に「結果の確認」を行い、今回の追加範囲を報告する。収録済みの全履歴をAIが読み直す必要はない。

対象refの付け替えやrebaseなどで、対象commit集合が単純な追加にならない場合は再作成へ進む。旧履歴の出現を、新しい対象範囲にも含まれるように見せない。

## 結果の確認

- **収録範囲**：対象commit集合と処理済み集合が一致するかを抽出器で確認する。部分完了なら、欠けた範囲と失敗を明示する。
- **出現の正しさ**：初回・抽出規則変更時は、メッセージ・追加・削除・merge・root commitを含む該当例を元のGit表示と照合する。通常更新では抽出器の検査結果を確認し、疑わしい結果や未対応の形式が出た範囲を原文へ戻って調べる。例の照合だけで全件正しいとは判定しない。
- **DBの整合**：既存DBを読み取り専用で検査する。DB検査の成功は、Gitからの抽出の正しさや全履歴の収録を保証しない。

DB作成後に使う検査例。専用のschemaを前提にしない。

```sh
sqlite3 -noinit -readonly -batch -bail \
  Maintanance/TaskHistoryIndex/task_history.sqlite3 \
  'PRAGMA quick_check;'
```

正常時は`ok`が返る。ファイルが存在しなければ、この読み取り専用コマンドで空のDBを作らず、初回作成の未実施として扱う。破損が疑われる場合は検索結果の利用を止め、再作成する。

## 再作成・中断・切替

再作成は元のGit履歴と固定した抽出条件から、別名の一時DBへ行う。既存DBに手で出現記録を足し引きして修復しない。確認が済むまでは既存DBを保ち、収録条件に違いがあれば旧範囲の索引として区別する。

切替時は読み書きの接続を閉じ、使用するjournal方式に応じて未反映の書き込みを完了させてから、検査済みDBへ切り替える。WAL使用中のDB本体だけをコピー・置換したり、`-wal`・`-shm`を独立に消したりしない。この切替は実装側で扱い、通常の運用者にファイルの手作業を要求しない。

| 起きたこと | 対応 |
| --- | --- |
| ロック中 | 更新元を確認し、同時更新を解消して再実行する |
| 更新が中断・失敗 | 最後に確定した処理済み範囲を確認し、未確定分を再実行する。再開できない実装なら別DBへ再作成する |
| 抽出器・規則・DB構造の版が違う | 同じ条件へ戻すか、新しい条件で再作成する。版の違いを無視して追記しない |
| 必要なGit objectがない | 利用できる範囲を明示する。取得・復旧が必要な部分だけを別途扱う |
| 一時DBが残った | どの実行の生成物か、使用中でないか、再開に必要かを確認してから整理する |

索引が使えない間も、必要なID・commit・ファイルを絞ってGitとMarkdownの原文を参照できる。索引の復旧を、独立した製品作業の一律の待ち条件にしない。

## 終了時に残すこと

更新結果には、対象リポジトリ・対象commit範囲、抽出器と規則の版、処理件数、失敗や未収録範囲、確認結果を残す。通常の報告は「どこまで検索できるようになったか」と残る制約に絞る。

番号の出現だけでRegistryの状態を変えず、採番表も自動更新しない。番号の不整合を見つけたら原文へ戻って照合し、現在の記録の修正として別に扱う。

## 抽出器実装時に追記するもの

実装を受け入れるときに、ソースの配置、初回作成・差分更新・状態表示・検索・再作成の実在するコマンドを本書へ追記する。対象範囲、mergeの比較方法、IDの抽出規則、DB構造の版と、失敗時の再開・切替方法も確定した実装に合わせる。

それまでは、上のGit確認と既存DB向け検査以外を実行可能なコマンドとして扱わない。本書の作成は、抽出器の実装完了や運用開始を意味しない。

### 2026-10-15に採用した実装

抽出器は`Utilities/Maintenance/TaskHistoryIndex.py`（Python 3標準libraryのみ）。リポジトリ直下で実行し、`--db`を省略すると`Maintanance/TaskHistoryIndex/task_history.sqlite3`を使う。現在の版はschema 3・rule 2。

| 操作 | コマンド |
| --- | --- |
| 初回作成 | `python3 Utilities/Maintenance/TaskHistoryIndex.py build [--ref REF]` |
| 再作成 | `python3 Utilities/Maintenance/TaskHistoryIndex.py build --replace [--ref REF]` |
| 差分更新 | `python3 Utilities/Maintenance/TaskHistoryIndex.py update [--ref REF]` |
| 状態表示 | `python3 Utilities/Maintenance/TaskHistoryIndex.py status` |
| 結果の確認 | `python3 Utilities/Maintenance/TaskHistoryIndex.py verify` |
| ID検索 | `python3 Utilities/Maintenance/TaskHistoryIndex.py search TASK-ID` |
| Registry行変化（参考資料） | `python3 Utilities/Maintenance/TaskHistoryIndex.py changes [--grade structural\|routine\|candidate] [--task TASK-ID]` |

- 対象範囲：開始時に`--ref`（既定は`HEAD`）をSHAへ解決し、そこから到達できる全commit。
- mergeの比較：第一親と比較し、rootは空treeと比較する。出現ごとに比較元の親を残す。差分は文脈0行、rename検出なし、binaryは対象外。
- IDの抽出規則：採番表の18 prefixに固定する。prefixが増えたらrule版を上げて再作成する。
- Registry行変化：merge以外のcommitで、ACTIVE・FROZENだった行の状態・本文の変化を等級つきで記録し、全行に`参考資料`の印を付ける。等級は介入の有無を決めない。
- 失敗時の再開・切替：作成は別名の一時DBで検査してから置き換え、journalはrollback方式（WALを使わない）。更新は200 commitごとに確定し、中断後は`update`で未確定分から再実行する。lock fileが残った場合は、更新元が動いていないことを確かめてから消す。

#### 場面ごとのメンテ操作

| 場面 | いつ | コマンド | 行うこと |
| --- | --- | --- | --- |
| 通常メンテ | 検索したいcommitが収録範囲より新しいとき | `routine [--ref REF]` | 差分更新、結果の確認、今回追加した範囲（commit数・出現数・Registry行変化の等級別件数）の報告をまとめて行う |
| アーカイブ時メンテ | [圧縮・アーカイブ手順](TASK_REGISTRY_ARCHIVE.md)の手順4で、現行から外す前。commit後の見直しにも使える | `archive-check --worktree`、または`archive-check [REV]` | Registryから外した表の行（task行・依存辺）が、Archivedへそのまま保存され、Registryから保存先へ辿れるかを照合する。DBを使わない |
| 介入後メンテ | ユーザーの介入（再開・停止・方針変更など）がRegistryへ反映された後 | 未commitなら`intervention --worktree`、commit後は`intervention [--since REV]` | ACTIVE・FROZENだったtaskの行変化のうち、`structural`・`candidate`を一覧する。commit後はDBへ取り込んでから一覧する |

- `archive-check`が照合するのは表の行だけである。本文・見出しの保存と意味の確認は、アーカイブ手順のとおり人が行う。問題を出した行は外さずに残すか、理由を確かめて判断する。
  - 「Archivedに原文がない」：保存せずに外したtask行。
  - 「移動と同時に書き換え」：保存先の行が移す前の内容と違う。移す前の内容と照合する。
  - 「外した依存辺がArchivedにない」：前提が満たされた証拠か、不要になった理由を辿れるか確かめる。
  - 「Registryから辿れない保存先」：「過去の記録への入口」へのリンクを確かめる。
- `intervention --worktree`はDBへ書かない。DBに入るのはcommitした変化だけである。介入だったかどうかは、一覧を手掛かりに原文で確かめる。

規則の詳細と、採用時点の確認結果は[補助資料](TASK_HISTORY_INDEX_PROTOTYPE_NOTES.md)に記す。
