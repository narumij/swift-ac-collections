# Release専用Task Registry設計

最終更新: 2026-10-09 / Codex

## Task

- 種別: `DISCOVERY`
- 担当: User / Codex
- 状態: `PROPOSED`
- 再開条件: 0.5.2 release完了後、今回の実績を入力としてユーザーとCodexが設計を開始する。

## 目的

release候補commitを固定した後も、候補treeを変更せずにgate、判断、権限、実績、次の操作を更新できる
release専用Task Registryを設計する。

## 発見の根拠

0.5.2ではremote CI green後、通常のTask Registryとrelease正本へrelease可否を記録した結果、候補commitが
変わり、再pushと同一commitへのCI再実行が必要になった。task分解や依存の組み替えでは解消できない、
記録の保存場所と候補treeの結合が原因だった。

## 設計対象

- 固定候補のbranch、commit SHA、tree。
- local gate、remote CI、documentation、性能、独立確認の状態と証拠。
- ユーザー判断と、merge、tag、push、公開に関する操作権限。
- 次に許可される操作とhard stop。
- release完了後に通常Task Registryとversion固有正本へ還元する内容と時点。
- branch切り替え、別worktree、事故復旧、削除操作に対する保存性。
- 生成された実行用正本だけを読んでもrelease中のtask運用を再開できる、task運用summary。
- activeなrelease専用Registryの検出方法と、通常Task Registryより優先して読むstartup precedence。

## Release中の正本優先順位

activeなrelease専用Registryが存在する間は、release実行に関する正本優先順位を次の順にする。

1. ユーザーの最新指示。
2. activeなrelease専用Registry。
3. 通常の`PROGRESS_OVERVIEW.md` Task Registry。
4. release専用Registryが参照するchecklist、version固有正本、CIなどの証拠。
5. Archived recordsと旧log。

release専用Registryはrelease中の候補SHA、gate、判断、権限、次の操作について通常Registryを上書きする。
release外のtask状態や中間ゴールまで上書きしてはならない。release完了時にactive状態を閉じ、結果を新しい
作業branchの通常Registryへ還元した後は、通常のstartup precedenceへ戻す。

固定入口は`_ReleaseTask/ACTIVE.md`とする。これは同じworkspace内で進行中のrelease作業に限った運用上の正本であり、
別worktree、clone、端末から同じactive状態を検出または共有するものではない。startupではこのpathの存在だけを確認し、
repositoryやdirectory全体をscanしない。`AGENTS.md`のStartupは、active正本が存在するときに通常Task Registryより先に読む。

## Life cycleと中止

release専用Registry全体に`FROZEN`状態を設けない。開始後は、完了するまでactiveを維持するか、releaseを
明示的に中止して閉じるかのどちらかとする。

- ユーザー判断、外部CI、使用量回復、時刻などを待つ間もRegistry全体はactiveのままにする。個別taskは
  `WAITING_USER`または`WAITING_EXTERNAL`を使用できる。
- 続行しない場合は`CANCELLED`として、固定候補、実施済みの外部操作、残存branch・tag・artifact、取消不能な
  影響、安全な再開方法を記録する。
- 中止したRegistryを暗黙に再開しない。再度releaseする場合は、新しい実行taskをtemplateから生成し、その時点の
  候補と証拠を取り直す。
- `COMPLETED`または`CANCELLED`を通常Registryへ還元するまで、実行用正本を削除しない。

したがってRegistry全体のlife cycleは少なくとも`ACTIVE`、`COMPLETED`、`CANCELLED`を持つ。生成前の状態を
表現する必要がある場合は通常Task Registryの`PROPOSED`で扱い、release実行用正本へ`FROZEN`を持ち込まない。

## 訓練モード

release訓練では、初期化時に訓練目的、到達するgate、実行しない操作、終了条件を記録する。実releaseの証拠や
許可と混同しないよう、模擬入力と訓練中のユーザー回答には`REHEARSAL ONLY`を付け、後続releaseへ再利用しない。
訓練の入口は`RELEASE_TASK_REGISTRY_REHEARSAL_TEMPLATE.md`へ残すが、実releaseのtaskとprecedenceは複製しない。
同文書を薄いoverlayとして使い、`RELEASE_TASK_REGISTRY_TEMPLATE.md`から必要なtaskを生成して訓練目的、模擬入力、
除外、境界だけを加える。これにより、今後も別テーマのrehearsalを実施でき、二重管理によるtask欠落や順序差も防ぐ。

- 訓練対象にしたユーザー判断taskへ実際に一問を提示し、回答によって後続taskのready状態が変わるところまで確認する。
- 訓練対象の判断へ到達する前に、その判断taskや必要な模擬前提taskを`EXCLUDED`にしない。
- build、remote CI、merge、tag、push、release pageなど実行しない操作は、模擬結果で成功扱いにせず、訓練境界として
  `EXCLUDED`または未実施と明記する。
- 予定したgate確認後は、残るrelease操作を中止し、Registry全体を`CANCELLED`としてterminal cleanupへ進める。
- 訓練の`CANCELLED`は予定された終了であり、製品releaseの中止や失敗を意味しない。ただし到達予定だったgateを
  確認できなかった場合は、訓練結果を成功とせず未達理由を通常Registryへ還元する。
- 訓練から実releaseへ移行しない。実releaseは新しい`ACTIVE.md`と新しい候補・証拠・task IDで開始する。

## Terminal cleanupの共通原則

`COMPLETED`または`CANCELLED`への状態変更だけでrelease実行taskを閉じない。cleanupと通常Registryへの還元を
terminal transitionの一部にする。

- 削除より先に、固定候補、実施済みgate、ユーザー判断、外部副作用、残存物、次の所有者をsnapshotする。
- local生成物、local branch・tag、remote branch・tag、PR、release page、CI artifactを別々の対象として扱う。
- remote refの削除、公開物の撤回、PR closeなどの外部変更をcleanupへ暗黙に含めない。一操作ごとに権限を確認する。
- ユーザー専任の操作をagentがcleanup名目で代行、承認依頼、催促しない。
- cleanupで`git reset --hard`、広い`git clean`、未確認の再帰削除を使用しない。
- active入口は、還元先と残存物の所有者が確定するまで解除しない。入口を解除した後は通常Task Registryが再び
  startupの正本になる。

## 完了時のcleanup

1. merge commit、main CI、tag object、tag対象commit、tag push、実施した公開操作を読み戻す。
2. mainではなくrelease後の作業branchを用意し、version固有正本、通常Task Registry、再利用可能な運用上の教訓を
   更新してcommitする。
3. 実行用Registryへ`COMPLETED`、還元先branch・commit、未実施の任意操作、残存物と所有者を記録する。
4. release専用に生成したlocalの一時artifact、log、作業directoryを、対象を列挙してから削除する。通常build cacheや
   他taskと共有する生成物はcleanup対象へ含めない。
5. release branch、PR branch、local worktreeの削除は自動化しない。保持方針と権限に従う独立taskとして扱う。
   remote branchの削除がユーザー専任なら、完了条件へ含めず残存物として引き渡す。
6. 還元commitを読み戻し、未所有の残存物がないことを確認してactive入口を解除する。
7. version別実行用fileは、還元内容の検証が終わるまで保持する。その後削除するか、ignored領域のclosed recordとして
   残すかは保存方式の設計で決める。

完了時はrelease成果を取り消さない。tag、release page、配布物の削除はcleanupではなく、別の製品判断を要する
撤回操作である。

## 中止時のcleanup

1. 新しいrelease操作を停止し、実行用Registryを`CANCELLED`へ移す前に中止理由と最後に成功した境界を記録する。
2. 候補SHA、local／remote gate、作成済みbranch・PR・tag、push済みref、公開物、実行中CIをsnapshotし、各対象を
   `PRESERVE`、`REMOVE_CANDIDATE`、`USER_ONLY`、`UNKNOWN`へ分類する。
3. remoteへ到達していない一時artifactだけを、安全なlocal cleanup候補にする。local tagやbranchも証拠になり得るため、
   中止したという理由だけで削除しない。
4. remote branch・tagの削除、PR close、CI cancel、release page撤回は、それぞれ独立した権限taskにする。特に
   push済みtagは自動削除せず、公開済みversionの撤回判断として扱う。
5. 通常Registryへの還元はmainまたは中止候補branchへ直接積まず、mainを基点にした新しい作業branchで行う。
   中止理由、残存副作用、再利用禁止の証拠、後続所有者、新しいreleaseを始める条件を記録してcommitする。
6. `UNKNOWN`と所有者未定を解消し、残す外部対象を明記してからactive入口を解除する。削除待ちの`USER_ONLY`対象は
   催促せず、通常Registryへ所有権と再開条件を引き渡す。
7. 中止した実行用Registryを再利用しない。次回は新しいversion別fileをtemplateから生成し、候補とgateを取り直す。

中止時のcleanupは「開始前の状態へ完全に戻す」ことを完了条件にしない。すでに外部へ到達した操作を正確に残し、
未承認の巻き戻しを行わず、安全な所有者へ引き渡せたことを完了条件にする。

## 実行用正本に内包するtask運用summary

version別のrelease実行taskには、チェック項目だけでなく、少なくとも次の運用規則を短く載せる。

- 現在の中間ゴール、固定候補、完了条件を先に確認する。
- activeなrelease専用Registryをrelease実行の正本として、通常Task Registryより先に読む。
- `DISCOVERY`、一判断だけを閉じる`DECISION`、判断済み事項だけを扱う`EXECUTION`を混在させない。
- 一つのユーザー判断taskでは一問だけを尋ね、複数の判断が必要なら先にtaskを分解する。
- 依存が完了していても現在のゴールに必要とは限らないため、`DIRECT`、`NEAR`、`FAR`、`LATER`、
  `OUTSIDE`で距離を確認してから次を選ぶ。
- 判断材料が不足している場合は、直ちにユーザー判断へ送らず、既決事項、実装、test、CIを先に調べる。
- `USER_ONLY`の操作はagentが実行、代行、承認依頼、催促をしない。
- release実行全体を凍結しない。待機中はactiveを保ち、続行しない場合は明示的に中止する。
- merge、tag作成、tag push、release pageなど、権限が分かれた操作を一つの承認へ束ねない。
- 候補固定後は通常Task Registry、version固有release正本、CHANGELOGを含む候補treeを更新せず、release中の
  状態と証拠はgitignoreされた実行用正本だけへ記録する。
- 候補が変わった場合は、影響するgateを同じcommitへ取り直す。greenだった旧commitの証拠を流用しない。
- release完了後、新しい作業branchで実績と再利用可能な教訓を通常Registryと正本文書へ還元する。
- candidate branch push、GitHub merge、tag pushはユーザー専任操作として、対象を一度提示して完了報告を待つ。
- branch作成、commit、pushの実操作は、それぞれ直前に一問で許可を得て、別操作へ許可を流用しない。
- pushまたはmerge完了と後続CI greenを同時に閉じず、CIを外部待機にして同一commitの完了結果を別taskで確認する。
- tag確認後、trackedな結果記録より先にmainからrelease後の作業branchへ移り、bookkeepingをmainへ直接積まない。

このsummaryは`TASK_ORIENTATION.md`全体の複製ではなく、release中に停止・再開・権限判断を誤らないための
最小版とする。

## 現在の案

repository直下のgitignore対象`_ReleaseTask/ACTIVE.md`を実行中正本とする。候補branchを切り替えても同じ
workspaceから参照でき、候補treeを動かさない。一方、別worktree、clone、別端末へ自動では引き継がれず、
`git clean -fdx`で失われるため、terminal cleanup前の通常Registryへの還元を必須にする。

trackedなsnippetとして`RELEASE_TASK_REGISTRY_TEMPLATE.md`を置き、`_ReleaseTask/ACTIVE.md`へコピーする。
通常Task Registryの`PROGRESS_OVERVIEW_TEMPLATE.md`に対応し、release固有の優先順位、
task運用summary、task graph、checklist、完了／中止cleanup、session restartを一枚へ含める。配置方式の採用と
startup precedence、`.gitignore`を0.5.3のrelease開始前に実装する。

## Discoveryの出力

1. 正本の配置と永続化方式の候補、利点、失敗条件を比較する。
2. Registryの最小schemaとlife cycleを定める。
3. active正本の固定入口とstartup precedenceを定める。
4. checklistとtask運用summaryを含むversion別実行taskのtemplateを定める。
5. 通常Task Registry、version固有release正本、CI、PRとの責任境界を定める。
6. ユーザー判断が必要な論点を、一判断ごとの`DECISION` taskへ分離する。
7. 判断不要の作成、検証、移行を`EXECUTION` taskへ分離する。

## Checklistから抽出する実行task

release開始前の通常Task Registryには、release全体を表すtaskを一つだけ置く。`ACTIVE.md`内は通常Registryと別の
名前空間とし、releaseまたは訓練ごとに`REL-000`から採番する。内部IDはそのactive Registry内でだけstableとし、
完了後に外から参照する場合は`0.5.3/REL-000`や`rehearsal-2/REL-000`のようにRegistry識別子で修飾する。
生成後の最初の`DISCOVERY`でchecklist本文と既決事項を読み、以降の判断task、実行task、必須依存を登録する。

通常Task Registryの連番を内部taskへ割り当てず、release一回につき通常IDを一つだけ消費する。別のrelease専用Registryで
同じ`REL-000`以降を再使用してよい。内部IDの一意性はRegistry識別子との組で保証する。

実行taskは、release差分準備、CHANGELOG準備、候補固定、local一次検収、候補branchのremote反映、remote CI確認、
採用時の独立チェック、release可否、merge判断、merge、main CI確認、tag作成判断、tag作成、tag push判断、tag push、
任意公開操作、完了結果の還元とcleanupへ分ける。ユーザー判断と実操作を混在させず、ユーザー専任操作は
`USER_ONLY`として扱う。中止結果の還元とcleanupは、どの実行段階からでも移れるterminal taskとする。

CHANGELOG本文の作成は候補固定後の検査や失敗時のリカバリーではなく、決定済みscopeとrelease差分を入力にした
候補準備taskである。候補固定はCHANGELOG準備を必須前提とし、固定時にはその内容が候補treeへ含まれることを
読み戻す。固定後に不足が判明した場合は候補を無効化し、CHANGELOG準備、新しい候補固定、影響するgateの再実施へ戻る。

checklist自体は、どの項目がユーザー判断で、判断結果がどの操作を許可するかをtask graphとして表現していない。
そのため節や並びを機械的にtaskへ変換しない。各項目を読んで、製品方向、公開上の約束、release方式、必須gate、
不可逆操作、予約された権限に関わる選択を一判断ごとの`DECISION`へ分け、その結論を必要とする`EXECUTION`へ
`SEQUENCE`で接続する。証拠を揃えるtaskはrelease可否判断へ`PARALLEL_JOIN`し、単なる確認は判断taskにしない。

この接続をrelease gateとして扱う。証拠taskの`PARALLEL_JOIN`は「判断可能になる条件」、`DECISION`から操作への
`SEQUENCE`は「操作可能になる条件」を表す。したがってgateをchecklist外で別に発明せず、checklistの内容、権限、
既決事項をtaskと依存へ分解した結果として構成する。

旧`RELEASE_CHECKLIST.md`の内容をtemplateへ移した後は、同checklistを実行用の第二正本として残さずArchivedへ移す。
参照先をtemplateとrelease専用Registryへ切り替え、startup precedenceと初期化、通常Registryへの還元を一往復検証する。

## 完了条件

- 候補commitを動かさずにrelease進捗を更新できる構造が説明されている。
- branch切り替えと事故復旧を含む保存性が評価されている。
- 生成された実行用正本だけで、release taskの再開と次の操作の判定ができる。
- activeなrelease専用Registryが存在するときだけ通常Registryより優先され、終了後に通常優先順位へ戻る。
- release実行全体に`FROZEN`がなく、待機と中止の扱いが区別されている。
- `COMPLETED`と`CANCELLED`それぞれのcleanup順序、証拠保全、外部操作の権限境界、active入口の解除条件が
  定義されている。
- 一つのtaskへ複数のユーザー判断を束ねていない。
- 採用判断と実装taskがTask Registryへ登録され、依存関係が明示されている。

このDISCOVERY自体は配置方式を採用せず、`_ReleaseTask/`の作成や`.gitignore`変更も行わない。
