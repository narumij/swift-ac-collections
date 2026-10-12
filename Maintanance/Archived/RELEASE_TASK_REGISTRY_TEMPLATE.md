# Release <version> 実行task

生成日時: <YYYY-MM-DD> / <生成者>
Source template commit: `<commit>`

## 起動方法

- [ ] 中間ゴール設定時に、このテンプレートから正本を作成し、必要項目を埋めてコミットする。
- [ ] 中間ゴール達成時に、コミット済みの正本をGit管理対象外の`_ReleaseTask/ACTIVE.md`へコピーして起動する。
- [ ] コピーによる起動ではコミットしない。起動後の実行は`ACTIVE.md`のTask Registryへ委譲する。

## Active release

- Registry identity: `<release identity>`
- Life cycle: `ACTIVE`
- Mode: `RELEASE / STEP EXECUTION`
- Version: `<version>`
- Current blocker: none
- Next permitted operation: `REL-000のCHANGELOG対応を実行する`

## Release Task Registry

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 証拠 |
| --- | --- | --- | --- | --- | --- |
| `REL-000` | `READY` | Codex | [EXECUTION] CHANGELOG対応 | 対象versionの変更内容をCHANGELOGへ反映し、内容を確認する | `<evidence>` |
| `REL-001` | `BLOCKED` | Codex | [EXECUTION] candidate確定 | CHANGELOGを含むcandidateを確定する | `<candidate>` |
| `REL-002` | `BLOCKED` | Codex | [EXECUTION] デバッグビルド | candidateのDebug build結果を記録する | `<evidence>` |
| `REL-003` | `BLOCKED` | Codex | [EXECUTION] リリースビルド | candidateのRelease build結果を記録する | `<evidence>` |
| `REL-004` | `BLOCKED` | Codex | [EXECUTION] ドキュメントビルド | candidateのdocumentation build結果を記録する | `<evidence>` |
| `REL-005` | `BLOCKED` | User / Codex | [DECISION] プッシュ | ユーザーがプッシュについて一問で判断する | `<decision>` |
| `REL-006` | `BLOCKED` | User / Codex | [DECISION] CI green | ユーザーがcandidate CI greenについて一問で判断する | `<decision>` |
| `REL-007` | `BLOCKED` | User / Codex | [DECISION] マージ | ユーザーがマージについて一問で判断する | `<decision>` |
| `REL-008` | `BLOCKED` | User / Codex | [DECISION] main green | ユーザーがmain CI greenについて一問で判断する | `<decision>` |
| `REL-009` | `BLOCKED` | User / Codex | [DECISION] タグ打刻可否 | ユーザーがタグを打つか一問で判断する | `<decision>` |
| `REL-010` | `BLOCKED` | Codex | [EXECUTION] タグ打刻 | 許可された対象へタグを打つ | `<tag>` |
| `REL-011` | `BLOCKED` | User / Codex | [DECISION] tag push可否 | 正確なtag refを提示し、ユーザーがpushするか一問で判断する | `<decision>` |
| `REL-012` | `BLOCKED` | User | [EXECUTION] tag push | ユーザーが許可したtag refだけをpushし、Codexがremote tag objectとpeeled targetを確認する | `<remote-tag>` |
| `REL-013` | `BLOCKED` | User / Codex | [DECISION] 作業ブランチ作成可否 | ユーザーがrelease後の作業ブランチを作成するか一問で判断する | `<decision>` |
| `REL-014` | `BLOCKED` | Codex | [EXECUTION] 作業ブランチ作成 | 許可されたrelease後の作業ブランチを作成する | `<branch>` |
| `REL-015` | `BLOCKED` | Codex | [EXECUTION] 結果記録 | 全工程の判断、証拠、外部副作用を記録する | `<result>` |

## Task precedence

| 後続task | 前提task | Flow | 制約 |
| --- | --- | --- | --- |
| `REL-001` | `REL-000` | `SEQUENCE` | CHANGELOG対応後にcandidateを確定する |
| `REL-002` | `REL-001` | `SEQUENCE` | 確定したcandidateをDebug buildする |
| `REL-003` | `REL-002` | `SEQUENCE` | Debug build後にRelease buildする |
| `REL-004` | `REL-003` | `SEQUENCE` | Release build後にdocumentation buildする |
| `REL-005` | `REL-004` | `GATE` | 三つのbuild完了後にプッシュをユーザー判断する |
| `REL-006` | `REL-005` | `SEQUENCE` | プッシュ判断がYesの場合だけCI greenをユーザー判断する |
| `REL-007` | `REL-006` | `SEQUENCE` | CI green判断がYesの場合だけマージをユーザー判断する |
| `REL-008` | `REL-007` | `SEQUENCE` | マージ判断がYesの場合だけmain greenをユーザー判断する |
| `REL-009` | `REL-008` | `SEQUENCE` | main green判断がYesの場合だけタグ打刻可否をユーザー判断する |
| `REL-010` | `REL-009` | `SEQUENCE` | タグ打刻判断がYesの場合だけタグを打つ |
| `REL-011` | `REL-010` | `GATE` | タグ打刻後にtag pushを別判断として確認する |
| `REL-012` | `REL-011` | `SEQUENCE` | tag push判断がYesの場合だけユーザーが正確なrefをpushし、remote到達を確認する |
| `REL-013` | `REL-012` | `SEQUENCE` | tagのremote到達確認後に作業ブランチ作成可否をユーザー判断する |
| `REL-014` | `REL-013` | `SEQUENCE` | 作業ブランチ作成判断がYesの場合だけ作業ブランチを作成する |
| `REL-015` | `REL-014` | `SEQUENCE` | 作業ブランチ作成後に結果を記録する |
| `REL-015` | `REL-013` | `CONDITIONAL` | 作業ブランチ作成判断がNoの場合は作成を飛ばし、中断結果を記録する |

## Step execution

Task Registryを`REL-000`から順に一taskずつ実行する。`DECISION`では一問だけ提示し、回答前に後続taskを実行しない。
正常系はこの順序を基準線とし、失敗、No、外部状態の不一致が起きた場合は、AIが必要な調査、task分解、依存の組み替え、
結果記録、cleanupを行う。

## Release boundary

- 実際のbranch作成、commit、pushは、それぞれ直前に一問でユーザー許可を得る。
- candidate branch push、GitHub merge、tag pushはユーザーが実行し、完了報告とremote確認後に後続へ進む。
- candidate確定後はtracked fileを変更せず、進行中の証拠を`ACTIVE.md`へ記録する。
- 終了時は`COMPLETED`または`CANCELLED`としてcleanupする。

## Release終了時の共通cleanupチェックリスト

- [ ] Registry全体を`COMPLETED`または`CANCELLED`へ移す。
- [ ] 判断結果、release結果、外部副作用、残存物の所有者を通常Task Registryへ還元する。
- [ ] リリースTask Registryの完了処理の最後に`_ReleaseTask/ACTIVE.md`を削除する。
