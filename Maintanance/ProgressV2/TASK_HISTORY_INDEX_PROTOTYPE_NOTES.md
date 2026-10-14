# Task履歴SQLite索引 試作の補助資料

> 補助資料。2026-10-15、姫（Claude）が試作した抽出器について、[メンテナンス手順](TASK_HISTORY_INDEX_MAINTENANCE.md)（ドラフト：Astra）との対応、規則、確認結果をまとめる。同日、ユーザーの採用指示により、手順書・抽出器・下記の規則を採用し、手順書へ実在コマンドを追記した。本書は手順書の本文、索引の意味と限界を定める[制度の参照](TASK_RULES_V2.md#履歴の照合とsqlite索引)、およびTask Registryを上書きしない。
>
> 採番待ちqueue：`CP-20261015-001`（抽出器）、`CP-20261015-002`（Registry行変化）、`CP-20261015-003`（本書）、`CP-20261015-004`（場面ごとのメンテ操作）

## 置き場

| 対象 | 配置 | 状態 |
| --- | --- | --- |
| 抽出器 | [`Utilities/Maintenance/TaskHistoryIndex.py`](../../Utilities/Maintenance/TaskHistoryIndex.py) | 2026-10-15に採用。Python 3標準libraryのみ |
| SQLite本体 | `Maintanance/TaskHistoryIndex/task_history.sqlite3`（scriptの既定値） | 2026-10-15に初回作成（HEAD `35d1f604`まで）。`.gitignore`の`/Maintanance/TaskHistoryIndex/`で除外済み |
| 一時DB・lock | DBと同じdirectoryの`<DB名>.building-<pid>`・`<DB名>.lock` | 実行中だけ存在する |

## コマンド

リポジトリ直下で実行する。`--db`を省略すると上の既定のDBを使う。挙動を試すだけなら、`mktemp -d`で作ったdirectoryを`--db`で指定すると既定のDBに触れずに済む。

| コマンド | 働き | 手順書の対応箇所 |
| --- | --- | --- |
| `build [--ref REF] [--replace]` | 対象commit集合を固定して別名の一時DBへ作成し、検査が通ったら置き換える。既存DBがあれば`--replace`なしでは止まる | 初回作成、再作成・中断・切替 |
| `update [--ref REF]` | 処理済み集合との差分だけを追加する。条件が違えば止まり、再作成を求める | 通常の差分更新 |
| `status` | 収録範囲、件数、版、最終実行を表示する。HEADが範囲外なら知らせる | 作成・更新前に確かめる（2） |
| `verify` | DB整合、版、repository、収録範囲の一致を読み取り専用で検査する | 結果の確認 |
| `search TASK-ID` | IDの出現（message・追加行・削除行）を時系列で表示する | — |
| `changes [--grade G] [--task ID]` | Registry行変化（参考資料）を表示する | — |
| `routine [--ref REF]` | 通常メンテ。差分更新・検査・今回追加した範囲の報告 | 通常の差分更新、結果の確認、終了時に残すこと |
| `archive-check [REV \| --worktree]` | アーカイブ時メンテ。外した表の行の保存と、保存先へのリンクを照合する。DBを使わない | [圧縮・アーカイブ手順](TASK_REGISTRY_ARCHIVE.md)の手順4 |
| `intervention [--since REV \| --worktree]` | 介入後メンテ。ACTIVE・FROZENだったtaskの`structural`・`candidate`の変化を一覧する。`--worktree`はDBへ書かない | — |

```sh
dir=$(mktemp -d)
python3 Utilities/Maintenance/TaskHistoryIndex.py build  --db "$dir/index.sqlite3"
python3 Utilities/Maintenance/TaskHistoryIndex.py verify --db "$dir/index.sqlite3"
python3 Utilities/Maintenance/TaskHistoryIndex.py search --db "$dir/index.sqlite3" RELEASE-077
python3 Utilities/Maintenance/TaskHistoryIndex.py changes --db "$dir/index.sqlite3" --grade structural
rm -rf "$dir"
```

読み取り系（`status`・`verify`・`search`・`changes`）は、DBがなければ「初回作成は未実施」と返し、空のDBを作らない。

## 手順書の要求と試作の実装

| 手順書の要求 | 試作での実装 |
| --- | --- |
| refを開始時のSHAへ固定する | 開始時に`rev-parse`で解決し、`meta.target_sha`へ記録する |
| 対象repositoryを確かめる | root commitのSHAをrepositoryの識別に使い、異なる索引への更新を止める |
| 書き込み担当を一つにする | lock fileを排他作成する。残っていれば止まり、更新元の確認を求める |
| shallow cloneの範囲を記録する | `meta.shallow`へ記録する |
| 文脈行を変更に混ぜない | 差分を文脈0行で読む |
| merge・rootの比較元を固定・記録する | mergeは第一親、rootは空treeと比較し、出現ごとに比較元の親を残す |
| IDが出なかったcommitも処理済みにする | 全commitを`commits`表へ記録する |
| 出現と処理完了を同じtransactionで確定する | 200 commitごとに出現・処理済み・Registry行変化を一度に確定する。重複は一意制約で無視する |
| 日時ではなく集合の差で追加分を求める | 到達可能なcommit集合と処理済み集合の差を使う |
| 単純な追加でなければ再作成する | 処理済みcommitが新しい対象範囲に含まれなければ止まる |
| 版の違いを無視して追記しない | schema・ruleの版が違えば止まる |
| 別名の一時DBへ作り、確認後に切替える | 一時DBで検査してから置き換える。rollback journalを使い、WALは使わない |
| 既存DBを読み取り専用で検査する | 読み取り専用で開き、`quick_check`と収録範囲の一致を見る |
| 番号の出現でRegistryや採番表を変えない | DBから文書へは何も書き戻さない |

## 規則（試作時に仮置きし、2026-10-15に採用）

現在の版はschema 3・rule 2。規則を変えたら版を上げ、`build --replace`で作り直す。

1. **ID照合**：2026-10-15時点の採番表にある18 prefixに固定した。prefixが増えたら版を上げる。`SHA-256`のような同じ形の文字列を誤って拾わないための選択である。
2. **差分の範囲**：rename検出を使わず、renameは削除と追加として記録する。binaryは対象外。
3. **Registry行変化**：merge以外のcommitで、Registry 2 file（旧`Maintanance/PROGRESS_OVERVIEW.md`と`Maintanance/ProgressV2/TASK_REGISTRY_V2.md`）から消えたACTIVE・FROZEN行を、同じcommitで追加された同IDの行と対にする。Registry側の行を優先し、なければArchived等の行を使う。状態か本文が変わった場合だけ記録する。mergeは第一親との差分が枝のcommitと重なるため除く。
4. **等級**：全行に`参考資料`の印を付ける。等級は介入の有無を決めない。

| 等級 | 対象 | 理由 |
| --- | --- | --- |
| `structural` | FROZENから他の状態、ACTIVE→FROZEN | 制度上、凍結の解除と停止には明示的な指示が要る。FROZEN→DONE・FROZEN→EXCLUDEDも含む |
| `routine` | ACTIVE→DONE | 大半は通常の受入 |
| `candidate` | 上記以外。状態を変えない本文変更を含む | 方向修正か進捗記録かは原文で確かめる |

5. **指示語**：「ユーザー指示」などの語が新しく加わったかを`user_marker`に記録する。補助情報であり、等級には使わない。

## 確認結果（2026-10-15、HEAD `35d1f604`）

すべて`mktemp -d`で作った一時directoryで行い、確認後に削除した。

| 確認 | 結果 |
| --- | --- |
| 全履歴の作成 | 5506 commits、約13秒。出現16544件、Registry行変化336件。`verify` ok |
| 差分更新の一致 | 古いcommitまで作成してから差分更新した索引が、全件作成と出現・commit・Registry行変化のすべてで一致 |
| 出現の正しさ | 独立に書いたperl抽出と523 commits（merge 20件・root含む）を完全照合し、全件一致。途中の3件の不一致はchecker側の誤り（差分記号を外さず、IDで始まる行を落とした） |
| Registry行変化の正しさ | 無作為12件を、親commitと子commitのfile内容に記録された状態と照合し、全件一致 |
| 停止条件 | lock中、対象範囲外の処理済みcommit、rule版違いで`update`が止まる。欠けたcommitを`verify`が検出し、`update`で補える |

Registry行変化の内訳は次のとおり。会話中の手集計（307件）との差29件は、Archivedへ移しながら状態を変えた行を対にできたためである。対にできず消えただけの行はなかった。

| 等級 | 件数 |
| --- | ---: |
| `structural` | 123 |
| `candidate` | 108 |
| `routine` | 105 |

### 場面ごとのメンテ操作の確認

| 確認 | 結果 |
| --- | --- |
| 通常メンテ | 10-14より前のcommitまで作成した索引に`routine`を実行し、今回の51 commits・出現2812件・Registry行変化（structural 6・candidate 17・routine 3）を報告した |
| 介入後メンテ | `intervention --since`で同じ範囲のstructural・candidate 23件を一覧した。新しいcommitがなければ0件と`--worktree`の案内を出す |
| 作業ツリー | 一時cloneで、完了行をArchivedへ移す操作と、FROZEN行をACTIVEにする介入を再現した。保存先へのリンクがなければ`archive-check --worktree`が指摘し、リンクを足すとok、保存先の行を書き換えると「移動と同時に書き換え」を出した。`intervention --worktree`は`RBT-008`のFROZEN→ACTIVEをstructuralとして出した。一時cloneは削除済み |
| 過去のアーカイブcommit | Archived保存先を新規作成した7 commitsに`archive-check`を当てた。4件はok。2件（10-13・10-14）は完了・除外と同時に行を書き換えて移していた。1件（10-12の`1775cf99`）は、付け替えた依存辺2本（`ARRAY-005`←`ARRAY-004`、`ARRAY-006`←`ARRAY-005`）を保存せずに外していた。いずれも現行のアーカイブ手順ができる前の操作で、記録として残すだけにする |

照合キーの初版は、task行の状態の列まで含めていた。そのため、その場で状態だけ変えた行（`RBT-005`のFROZEN→WAITING_EXTERNALなど）をArchivedへの移動と誤認した。task行はID、依存辺は後続・前提の組をキーにするよう直した。

## 限界

- Registryが現在の形になった2026-10-04より前のtaskは、別の文書にあったためRegistry行変化に含まれない。IDの出現は全履歴が対象。
- commit messageにtask IDがあるcommitは47件だけで、commitとtaskの対応は主に差分の中のIDに頼る。
- 介入はチャットや未commitの編集で起きることが多く、文書に残るのはAIによる言い換えが中心である。DBはその痕跡を拾うだけで、介入だったかは原文とユーザー・Codexの判断で決める。
- 出現がないことは未使用の証拠にならない。番号の出現からRegistryの状態や採番表を変えない（手順書・制度の参照と同じ）。

## 未実施

- [制度の参照](TASK_RULES_V2.md#履歴の照合とsqlite索引)の「SQLite索引は未実装」の記述の更新、およびTask Registryへの反映（Codexの照合待ち）。
- `candidate`の個別判定。
