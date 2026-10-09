# Release <version> 実行task

生成日時: <YYYY-MM-DD HH:MM TZ> / <生成者>

> このtracked templateを`_ReleaseTask/ACTIVE.md`へコピーし、山括弧のplaceholderと例示taskを置き換える。
> 実行中のfileはgitignore対象とし、release候補treeへ含めない。

## Active release

- Life cycle: `ACTIVE`
- Version: `<version>`
- Base tag: `<previous-version>`
- Release方式: `<main / release branch / other>`
- Source template commit: `<commit SHA>`
- Candidate branch: `<branch / not fixed>`
- Candidate commit: `<commit SHA / not fixed>`
- Candidate tree: `<tree SHA / not fixed>`
- Current blocker: `<none / user decision / external / technical>`
- Next permitted operation: `<one concrete operation>`

Life cycleは`ACTIVE`、`COMPLETED`、`CANCELLED`だけを使用し、release実行全体を`FROZEN`にしない。
待機中も全体は`ACTIVE`を保ち、個別taskを`WAITING_USER`または`WAITING_EXTERNAL`にする。

## Source-of-truth precedence

activeなこのfileが存在する間、release実行に関する優先順位は次のとおり。

1. ユーザーの最新指示。
2. このrelease専用Registry。
3. 通常のTask Registry。
4. このRegistryが参照するchecklist、version固有正本、CIなどの証拠。
5. Archived recordsと旧log。

このfileは同じworkspace内で進行中のrelease作業に限った運用上の正本であり、別worktree、clone、端末との
active状態の共有や検出を担わない。release外のtask状態や中間ゴールを上書きせず、terminal cleanupと通常Registryへの
還元が完了するまで、active入口を解除しない。

このfileは、通常Task Registry上でversion、scope、release方式、gate、権限、停止点を提示した
release開始可否のユーザー判断が完了した後にだけ生成する。release開始判断をこのfile内のtaskへ置かない。
判断前にこのfileを生成したり、life cycleを`ACTIVE`にしたりしない。

## Task operation summary

- 中間ゴール、固定候補、完了条件を先に確認する。
- `DISCOVERY`、一判断だけの`DECISION`、判断済み範囲の`EXECUTION`を混在させない。
- 一つのユーザー判断taskでは一問だけを尋ねる。一問で足りなければ先に分解する。
- readyだけで選ばず、現在のgoalへの`DIRECT`、`NEAR`、`FAR`、`LATER`、`OUTSIDE`を確認する。
- 不明点を直ちにユーザー判断へ送らず、既決事項、source、test、CIを先に調べる。
- `USER_ONLY`はagentが実行、代行、承認依頼、催促をしない。
- 記録済みworkflowが`USER_ONLY`へのhandoffを明示する場合、正確な対象を一度だけ提示して完了報告を待つ。
- branch作成、commit、pushは、実操作の直前にそれぞれ一問でユーザー許可を得る。許可を他の操作へ流用しない。
- candidate branch push、GitHub merge、tag pushはユーザー専任とし、完了報告後にCodexが対象を読み戻す。
- merge、tag作成、tag push、release pageを一つの承認へ束ねない。
- 候補固定後は候補treeを更新せず、進捗と証拠はこのfileだけへ記録する。
- 候補が変わったら影響するgateを同じcommitへ取り直し、旧commitのgreenを流用しない。
- candidate pushやmergeの完了と後続CIのgreen確認を同じ状態遷移で閉じない。CIは`WAITING_EXTERNAL`を経て、
  完了した同一commitの結果を別taskで確認する。
- 終了時は新しい作業branchへ実績を還元する。
- tag確認後、trackedな結果記録より先にmainからrelease後の作業branchへ移る。post-release bookkeepingをmainへ積まない。

### Rehearsal mode

訓練の場合は、目的、到達する判断gate、模擬入力、実行しない操作、終了条件を先に記録する。訓練対象の判断まで
実際に一問を提示し、その回答で後続taskがreadyになることを確認するまでは、対象判断と必要な模擬前提を
`EXCLUDED`にしない。実行しないbuild、CI、merge、tag、push、公開操作は成功扱いにせず、訓練境界として除外する。

予定したgate確認後は残るrelease操作を中止し、Registry全体を`CANCELLED`としてcleanupする。訓練中の模擬証拠と
ユーザー回答には`REHEARSAL ONLY`を付け、実releaseへ再利用しない。予定したgateへ到達できなかった訓練は成功扱いに
せず、未達理由を通常Registryへ還元する。実releaseは同じRegistryを再利用せず、新しい入口から開始する。

## Release Task Registry

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 証拠 |
| --- | --- | --- | --- | --- | --- |
| `REL-000` | `ACTIVE` | User / Codex | [DECISION] candidate branch作成可否 | `<candidate branch>`を提示し、一問で作成可否を判断する | `<decision>` |
| `REL-001` | `PROPOSED` | Codex | [EXECUTION] candidate branch作成 | 許可されたbranchを作成し、現在branchを読み戻す | `<branch>` |
| `REL-002` | `PROPOSED` | Codex | [EXECUTION] release差分準備 | `<scope>`へ含める変更と後続へ残す変更を分離する | `<diff>` |
| `REL-003` | `PROPOSED` | Codex | [EXECUTION] CHANGELOG準備・本文確認 | `<version>`項目を準備し、scopeとの一致を読み戻す | `<CHANGELOG path / content>` |
| `REL-004` | `PROPOSED` | Codex | [EXECUTION] candidate内容確認 | worktree、生成物、commit一覧、version、Package、README、文書、公開面を確認する | `<readout>` |
| `REL-005` | `PROPOSED` | User / Codex | [DECISION] candidate commit作成可否 | commit対象とmessageを提示し、一問で作成可否を判断する | `<decision>` |
| `REL-006` | `PROPOSED` | Codex | [EXECUTION] candidate commit固定 | 許可された内容だけをcommitし、branch、commit、treeを固定する | `<commit / tree>` |
| `REL-007` | `PROPOSED` | Codex | [EXECUTION] Debug test | 同じcandidateで`DEATH_TEST`を含むDebug testを確認する | `<command / result>` |
| `REL-008` | `PROPOSED` | Codex | [EXECUTION] Release test | 同じcandidateで`DEATH_TEST`を含むRelease testを確認する | `<command / result>` |
| `REL-009` | `PROPOSED` | Codex | [EXECUTION] documentation test | 同じcandidateでwarning-as-errorのdocumentation testを確認する | `<command / result>` |
| `REL-010` | `PROPOSED` | Codex | [EXECUTION] 既知事項分類 | 未確認事項と既知事項をrelease阻害、非阻害、後続へ分類する | `<classification>` |
| `REL-011` | `PROPOSED` | User | [EXECUTION] candidate branch push | `<candidate branch>`の`<candidate commit>`をuser専任でpushする | `<remote ref / commit>` |
| `REL-012` | `PROPOSED` | Codex | [EXECUTION] candidate CI確認 | 同じcandidateの通常test、documentation、performance、ASanと必須jobを確認する | `<CI URL / commit / jobs>` |
| `REL-013` | `PROPOSED` | `<owner / EXCLUDED>` | [EXECUTION] 独立チェック | 採用した場合だけ固定candidateと証拠を独立確認する | `<report / reason excluded>` |
| `REL-014` | `PROPOSED` | User / Codex | [DECISION] release可否 | local、remote、既知事項、独立確認を入力に一問で判断する | `<decision>` |
| `REL-015` | `PROPOSED` | User | [EXECUTION] GitHub merge | `<merge target>`へ固定candidateをuser専任でmergeする | `<merge report>` |
| `REL-016` | `PROPOSED` | Codex | [EXECUTION] merge commit確認 | merge commitがcandidateを含むことを読み戻す | `<merge commit / candidate>` |
| `REL-017` | `PROPOSED` | Codex | [EXECUTION] main CI確認 | 同じmerge commitの必須CIを確認する | `<CI URL / merge commit / jobs>` |
| `REL-018` | `PROPOSED` | User / Codex | [DECISION] annotated tag作成可否 | `<tag>`、merge commit、messageを示し一問で判断する | `<decision>` |
| `REL-019` | `PROPOSED` | Codex | [EXECUTION] annotated tag作成 | 許可されたtagを作成し、tag objectと対象commitを読み戻す | `<tag object / commit>` |
| `REL-020` | `PROPOSED` | User | [EXECUTION] tag push | `<tag ref>`をuser専任でpushする | `<push report>` |
| `REL-021` | `PROPOSED` | Codex | [EXECUTION] remote tag確認 | remote tag refと対象commitを読み戻す | `<remote ref / commit>` |
| `REL-022` | `PROPOSED` | User / Codex | [DECISION] post-release branch作成可否 | `<post-release branch>`を提示し一問で判断する | `<decision>` |
| `REL-023` | `PROPOSED` | Codex | [EXECUTION] post-release branch作成 | mainを離れて記録用branchを作成し、現在branchを読み戻す | `<branch>` |
| `REL-024` | `PROPOSED` | Codex | [EXECUTION] 完了結果の還元とcleanup | 結果を還元し、残存物の所有者を確認してactive入口を閉じる | `<handoff commit>` |
| `REL-025` | `PROPOSED` | Codex | [EXECUTION] 中止結果の還元とcleanup | 中止時だけ成功境界と副作用を保存してactive入口を閉じる | `<handoff commit>` |

> 上の行は標準リリース手順である。中間ゴール設定時にversion正本へコピーし、山括弧の値、担当、採用gateを埋めて
> release開始gateまで待機する。別手順を採用する場合はこのtableを開始時に組み替えず、別templateを用意する。
> 通常Task RegistryのIDを内部taskへ割り当てない。内部IDはこのRegistryのlife cycle中は変更または再利用しない。

checklistの節名やチェック順だけからtask typeを決めない。各項目の内容と既決事項を読み、製品範囲、公開上の約束、
release方式、必須gate、不可逆操作または予約された権限を選ぶものだけを`DECISION`にする。判断後の操作は別の
`EXECUTION`にし、その判断taskを必須依存として接続する。事実確認だけで閉じない未決事項の探索は`DISCOVERY`にする。
証拠taskから判断への`PARALLEL_JOIN`を判断gate、判断から操作への`SEQUENCE`を操作gateとして扱い、完了していない
前提を持つ判断や操作をreadyにしない。

個別taskの状態は`PROPOSED`、`ACTIVE`、`WAITING_USER`、`WAITING_EXTERNAL`、`USER_ONLY`、`EXCLUDED`、
`DONE`を使用できる。release全体と個別taskのどちらにも`FROZEN`を使用しない。続行しない個別taskは理由を
残して`EXCLUDED`、release全体は`CANCELLED`にする。

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `REL-001` | `REL-000` | `SEQUENCE` | branch作成許可後にだけ作成する |
| `REL-002` | `REL-001` | `SEQUENCE` | candidate branch上でrelease差分を準備する |
| `REL-003` | `REL-002` | `SEQUENCE` | release差分を入力にCHANGELOGを準備する |
| `REL-004` | `REL-003` | `SEQUENCE` | CHANGELOGを含むcandidate内容を確認する |
| `REL-005` | `REL-004` | `SEQUENCE` | commit対象を確認後に作成可否を判断する |
| `REL-006` | `REL-005` | `SEQUENCE` | commit許可後にbranch、commit、treeを固定する |
| `REL-007` | `REL-006` | `PARALLEL_JOIN` | 同じ固定candidateでDebug testを行う |
| `REL-008` | `REL-006` | `PARALLEL_JOIN` | 同じ固定candidateでRelease testを行う |
| `REL-009` | `REL-006` | `PARALLEL_JOIN` | 同じ固定candidateでdocumentation testを行う |
| `REL-010` | `REL-007` | `PARALLEL_JOIN` | Debug test結果を既知事項分類へ渡す |
| `REL-010` | `REL-008` | `PARALLEL_JOIN` | Release test結果を既知事項分類へ渡す |
| `REL-010` | `REL-009` | `PARALLEL_JOIN` | documentation test結果を既知事項分類へ渡す |
| `REL-011` | `REL-010` | `SEQUENCE` | local gateと既知事項確認後にcandidateをpushする |
| `REL-012` | `REL-011` | `SEQUENCE` | push後に同じcandidateのCIを確認する |
| `REL-013` | `REL-010` | `PARALLEL_JOIN` | 採用時はlocal evidenceを独立確認へ渡す |
| `REL-013` | `REL-012` | `PARALLEL_JOIN` | 採用時はremote evidenceを独立確認へ渡す |
| `REL-014` | `REL-010` | `PARALLEL_JOIN` | release判断前にlocal evidenceと既知事項を揃える |
| `REL-014` | `REL-012` | `PARALLEL_JOIN` | release判断前にremote evidenceを揃える |
| `REL-014` | `REL-013` | `PARALLEL_JOIN` | 独立確認を採用した場合だけ判断前に合流する |
| `REL-015` | `REL-014` | `SEQUENCE` | release可の判断後にuserがGitHub mergeする |
| `REL-016` | `REL-015` | `SEQUENCE` | merge完了報告後にcommitを読み戻す |
| `REL-017` | `REL-016` | `SEQUENCE` | 同じmerge commitのmain CIを確認する |
| `REL-018` | `REL-017` | `SEQUENCE` | main CI green後にtag作成を判断する |
| `REL-019` | `REL-018` | `SEQUENCE` | tag作成許可後に作成・確認する |
| `REL-020` | `REL-019` | `SEQUENCE` | local tag確認後にuserがtagをpushする |
| `REL-021` | `REL-020` | `SEQUENCE` | tag push完了報告後にremote refを確認する |
| `REL-022` | `REL-021` | `SEQUENCE` | remote tag確認後に記録branch作成を判断する |
| `REL-023` | `REL-022` | `SEQUENCE` | branch作成許可後にmainを離れる |
| `REL-024` | `REL-023` | `SEQUENCE` | 記録branchで結果を還元して完了cleanupする |

必要な内部task間のAND依存だけを書く。便利な順番や同じfileを触ることを必須依存にしない。

## Checklist

### 0. Initialization

- [ ] versionと製品上の到達範囲をユーザーが決定済み。
- [ ] 既存の`_ReleaseTask/ACTIVE.md`がないことを確認してから、このfileを固定入口へ配置した。
- [ ] template commitと生成日時を記録した。
- [ ] release方式と操作権限を確認した。
- [ ] 通常Registryではrelease全体のtask一つだけを使用し、内部taskを同Registryの連番へ混ぜていない。
- [ ] 内部taskへ`REL-000`からIDを付け、型、担当、完了条件、証拠欄をRegistryへ登録した。
- [ ] 必須依存をTask precedenceへ登録した。
- [ ] placeholderと不要な例示taskをすべて除去した。
- [ ] `Next permitted operation`が登録taskと依存から一意に説明できる。
- [ ] 通常Registry上で、version、scope、方式、gate、権限、停止点を提示したrelease開始判断taskが完了している。
- [ ] 通常Task Registryをrelease進捗の更新先にしないことを確認した。
- [ ] 訓練の場合、到達する判断gate、模擬入力、実行しない操作、予定した`CANCELLED`終了を記録した。
- [ ] 決定済みscopeに対応するrelease差分とCHANGELOGを、候補固定前のtaskとして完了した。

### 1. Candidate

- [ ] branch、commit、treeを固定した。
- [ ] worktreeがcleanで、意図しない生成物やlocal fileがない。
- [ ] previous tagからの差分、version、CHANGELOG、Package、利用者向け文書を確認した。
- [ ] 候補固定後のtree更新を停止した。

### 2. Evidence

- [ ] Debug test、Release test、documentation testの三つのlocal gateが同じcandidate commitで成功した。
- [ ] macOSのDebug／Release testでは、事前に`DEATH_TEST`を有効とし、対象testの発見・実行を確認した。
- [ ] 必須remote CIが同じcandidate commitでgreenになった。
- [ ] performanceとAddress Sanitizerを採用した場合、candidate push後のremote CIとして結果を確認した。
- [ ] documentation、性能、独立確認の採否と結果を記録した。
- [ ] 既知事項をrelease阻害、非阻害、後続へ分類した。

### 3. Decision and operations

- [ ] release可否を一つのユーザー判断で閉じた。
- [ ] merge対象と権限を確認し、merge後のmain commitを読み戻した。
- [ ] main CIが同じmerge commitでgreenになった。
- [ ] tag作成を独立承認で実施し、対象commitを読み戻した。
- [ ] tag pushを独立承認で実施し、remote refを読み戻した。
- [ ] release pageなど任意の公開操作を、必要な場合だけ独立承認で実施した。

## Completed cleanup

- [ ] merge、main CI、tag object、tag対象、remote tag、公開操作をsnapshotした。
- [ ] 新しい作業branchでversion正本、通常Registry、再利用可能な教訓を更新してcommitした。
- [ ] このfileへ`COMPLETED`、還元commit、未実施操作、残存物と所有者を記録した。
- [ ] release専用local artifactだけを、対象確認後にcleanupした。
- [ ] branch、PR、worktree、remote refの削除を暗黙に実行していない。
- [ ] 未所有の残存物がないことを確認し、active入口を解除した。

## Cancelled cleanup

ユーザーの`中止`指示は、release進行の停止だけでなく、下記の内部cleanupを直ちに開始する権限を含む。
内部cleanupについて改めて開始許可を求めない。外部refやbranchの削除、巻き戻し、pushなど別権限が必要な操作と、
commitは中止指示へ含めず、それぞれの規則に従って停止する。

- [ ] 中止理由と最後に成功した境界を記録した。
- [ ] branch、PR、tag、remote ref、公開物、CIをsnapshotした。
- [ ] 各残存物を`PRESERVE`、`REMOVE_CANDIDATE`、`USER_ONLY`、`UNKNOWN`へ分類した。
- [ ] external cleanupを一操作ごとの権限taskへ分離した。
- [ ] main基点の新しい作業branchへ、中止結果と後続所有者を還元した。
- [ ] `UNKNOWN`と所有者未定を解消し、このfileを`CANCELLED`にしてactive入口を解除した。

中止時は開始前へ完全に戻すことを要求しない。外部副作用を保存し、未承認の巻き戻しを行わず、残存物を
安全な所有者へ引き渡せたことを完了条件にする。

## Session restart

1. このfileだけを読み、life cycle、candidate SHA、blocker、next permitted operationを確認する。
2. ユーザーの最新指示と衝突しないtaskを選ぶ。
3. 状態、担当、依存、権限、証拠を確認する。
4. 選択taskが参照する正本と証拠だけを追加で読む。
5. branch、HEAD、worktreeを確認し、candidate SHAとの一致を検証する。
6. 不一致があればrelease操作を止め、候補再固定または中止へ戻る。

## Initialization snippet

次は設計用snippetであり、配置方式と`.gitignore`を採用した実装taskで検証してから使用する。

```sh
test ! -e _ReleaseTask/ACTIVE.md
mkdir -p _ReleaseTask
cp Maintanance/RELEASE_TASK_REGISTRY_TEMPLATE.md _ReleaseTask/ACTIVE.md
```

生成後、placeholderと例示taskを実releaseの内容へ置き換える。既存の`_ReleaseTask/ACTIVE.md`を上書きしない。
配置、実release taskのRegistry登録、依存登録、placeholder除去、next operation確認が終わるまでは、release実行の
初期化を完了扱いにしない。
