# <Project Name> 進捗一覧

最終更新: <YYYY-MM-DD> / <更新者>

> このファイルを別projectへコピーしたら、山括弧のplaceholderと「例」行を置き換える。
> Task Registryを残taskの唯一の入口とし、会話や古いchecklistを正本にしない。

<統合担当>はsession開始時に、まずこの文書のTask Registryだけを読む。taskを選択した後、その行が示す
詳細正本だけを追加で読む。完了済みの長い記録は必要に応じて`Archived/`へ移す。

内部のRegistry、ID、状態名、handoffはagentの管理道具である。ユーザーへfile確認や状態照合を返さず、
agentが読み取った現在地、意味、次の選択肢、必要なユーザー判断へ翻訳して報告する。評価やretrospective
から別sessionでも守るべき知見が得られた場合は、長い記録を起動時に読ませず、AGENTS規則または運用
playbookへ短い行動規則として昇格させる。

## Task Registry

**現在の律速:** <なし／外部条件／ユーザー判断／技術的blocker。影響するtaskも書く>

**一時運用:** <期限付きの稼働制限、変更凍結、担当制限など。なければ「なし」>

### 中間ゴール

中間ゴールは、複数taskをまたぐ到達状態である。taskではないためIDや状態を持たず、Registryの担当、
依存、凍結、再開条件を上書きしない。「何をするか」ではなく「何が判断・引き渡し可能になるか」で書く。

**現在の中間ゴール:**

- <例: Component Aをユーザードキュメント作業へ渡せる状態にする。>
- <例: 次のrelease候補を品質gateで判定できる状態にする。>

**後続の中間ゴール:**

- <現在のgoal達成後に扱う到達状態。未定なら「未設定」>

taskが依存上readyでも、現在の中間ゴールに必要とは限らない。次taskを選ぶときは、現在のgoalを直接
閉じる`DIRECT`、その必須入力である`NEAR`、複数の中間taskやgateを経るが現goalに必要な`FAR`、
後続goalの`LATER`、記録されたgoalへ寄与しない`OUTSIDE`のどこにあるかを確認する。これは状態や
必須依存を置き換えるfieldではなく、今進める必要性を見るための選択観点である。近さだけを優先度へ
読み替えず、関係を形式化していない場合は根拠のない数値距離を付けない。

### taskの型

- `DISCOVERY`: 事実、選択肢、依存、判断task候補を発見する。仕様や方針を決定しない。
- `DECISION`: ユーザー判断を一つだけ閉じ、結論を後続taskの入力にする。
- `EXECUTION`: 必要な判断が確定した範囲で、実装、文書反映、検証を行う。

複数のユーザー判断を一つのtaskへ束ねない。`DISCOVERY`が判断点を見つけたら、一判断ごとの
`DECISION`へ分ける。`EXECUTION`中に新しい判断が必要になったら、agentは推測で埋めずに停止して
task分割へ戻す。

### 推奨順と今回扱わない判断

**soft order:** <例: `CORE-001` → `DOC-001`。必須依存でなければ「なし」>

soft orderは、同時に着手可能なtask間の推奨順であり、Task precedenceの必須依存ではない。
完了taskだけになったsoft orderは現行部から削除する。

**現在の作業へ含めない判断:**

- <判断が混入しやすい事項。なければ「なし」>

### Tasks

| ID | 状態 | 担当 | 項目 | 再開・完了条件 | 詳細正本 |
| --- | --- | --- | --- | --- | --- |
| `IDEA-001` | `PROPOSED` | Codex | [DISCOVERY] <候補task> | 範囲、完了条件、依存を確定して状態を更新するまで着手しない | `<path/to/canonical.md>` |
| `AREA-001` | `ACTIVE` | Codex | [DISCOVERY] <調査対象> | <必要な事実と判断候補を整理する> | `<path/to/canonical.md>` |
| `AREA-002` | `WAITING_USER` | User / Codex | [DECISION] <一つの判断> | <選択肢と根拠を確認し一つ決める> | `<path/to/canonical.md>` |
| `AREA-003` | `FROZEN` | Codex | [EXECUTION] <判断後の作業> | `AREA-002`完了後に実装・検証する | `<path/to/canonical.md>` |

> 上の4行は形式例。project開始時に実taskへ置き換える。存在しないtaskを例のまま残さない。

## Task precedence

内部task間の必須AND依存だけを書く。便利な実施順、同じfileを触ること、同じgoalに属することだけを
理由に辺を追加しない。外部条件やユーザーの明示的再開はRegistryの状態・条件欄で表す。

このgraphのトポロジカル判定は、前提未完了のtaskを除き、ready候補を求めるために使う。一意の実施順を
決めるものではない。依存上readyでも、`PROPOSED`、`FROZEN`、`USER_ONLY`、`WAITING_USER`、
`WAITING_EXTERNAL`は着手しない。cycleを検出した場合は実行を止め、task分割または依存辺を見直す。
`EXCLUDED`の前提taskを自動的に達成扱いしない。後続も不要なら`EXCLUDED`にし、別経路で成立するなら
依存辺と完了条件を更新してからreadyを再判定する。

| 後続task | 前提task | 制約 |
| --- | --- | --- |
| `AREA-002` | `AREA-001` | 調査結果を確認後に判断する |
| `AREA-003` | `AREA-002` | 判断確定後に実行する |

> 必須依存がなければ、見出しとtable headerを残してデータ行を空にする。

## Registry rules

### 状態

- `PROPOSED`: 会話や調査で発見した候補。忘失防止の記録であり、範囲と完了条件を確定して状態を
  更新するまで着手、委任しない。
- `ACTIVE`: 着手可能または進行中。
- `WAITING_USER`: ユーザーの判断または操作待ち。必要な問いを明示する。
- `WAITING_EXTERNAL`: 外部条件待ち。解消確認方法を明示する。
- `FROZEN`: 明示的な再開指示まで着手しない。
- `USER_ONLY`: ユーザー専任。agentは着手、代行、催促をしない。
- `EXCLUDED`: 実施しないと確定。理由を残し、IDを再利用しない。
- `DONE`: 完了条件を証拠付きで満たし、正本とRegistryの同期を確認済み。
- `ARCHIVED`: 現行Registryから履歴へ移した。移動先を残す。

### ID

- `<領域>-<連番3桁>`を基本とする。例: `CORE-001`、`DOC-001`。
- IDは永続的に扱い、状態、担当、分類が変わってもrename、renumber、reuseしない。
- IDはagent向け座標であり、通常のユーザー報告では人間が読めるtask名を優先する。

### `PROPOSED`の昇格

`PROPOSED`を`ACTIVE`などへ移す前に、型、範囲、対象外、担当、詳細正本、完了条件、停止条件、
必須依存、既存taskとの重複を確認する。採用しない場合は削除せず、理由と移管先を残して
`EXCLUDED`にする。提案時に付けたIDは変更しない。

### 更新と完成判定

- 優先順位は、ユーザーの最新指示、Task Registry、選択taskの詳細正本、Archived・旧logの順とする。
- Task Registryの確定更新は<統合担当>が行う。
- 担当agentの完了報告だけで`DONE`にしない。diff、test、根拠、完了条件を照合する。
- 新しい判断点、前提との衝突、scope逸脱を見つけたら実装を止め、task分割または状態更新へ戻る。
- `EXCLUDED`は失敗の隠蔽ではない。前提誤りや方針変更の理由を保存する完了状態として扱う。
- 完了taskがRegistryを読みにくくしたら、ID、結果、commit、移動先を残して履歴へ移す。

## Session restart procedure

<統合担当>は新しいsessionで次の順に再開する。

1. このRegistryだけを読む。
2. ユーザーの最新指示に合うtaskを選ぶ。
3. 状態、担当、再開条件、必須依存を確認する。
4. 選択taskの詳細正本だけを読む。
5. worktreeと直近commitを確認する。
6. 着手可能なら小さな単位で進め、判断不足なら停止してユーザーへ返す。

`PROPOSED`、`WAITING_USER`、`FROZEN`、`USER_ONLY`、`WAITING_EXTERNAL`を、古い文書の未完了記述だけで開始しない。

## Bootstrap checklist

別projectへ導入するときに一度だけ確認する。

- [ ] project名、日付、更新者を置き換えた。
- [ ] 例示taskとplaceholderを実データへ置き換えた。
- [ ] 現在の中間ゴールを到達状態として書いた。
- [ ] ready taskを現在のgoalへの必要性と`DIRECT / NEAR / FAR / LATER / OUTSIDE`で見直した。
- [ ] 既存の未完了作業を重複なしでRegistryへ登録した。
- [ ] 凍結、ユーザー専任、外部待ちを明示した。
- [ ] task候補は`PROPOSED`に置き、実行taskと区別した。
- [ ] 各taskから詳細正本へ辿れる。
- [ ] 複数判断を含むtaskを分割した。
- [ ] 必須依存とsoft orderを分けた。
- [ ] Registryと同じ状態を繰り返すsummaryやchecklistを作っていない。
- [ ] 完了した中間goal、完了taskだけのsoft order、古い概要を現行部に残していない。
- [ ] AGENTS.mdなどのsession開始規則から、このRegistryを唯一の入口として参照した。
- [ ] 新しいsessionで、会話履歴なしに次taskを選べるか試した。

## AGENTS.md startup snippet

次をprojectの`AGENTS.md`へ移し、実際のpathへ置き換える。ほかの規則と重複する場合は一つへ統合する。

```markdown
## Task management startup

1. Read only the Task Registry at the top of `<path/to/PROGRESS_OVERVIEW.md>`
   to establish the current task state.
2. Treat that Registry as the sole source of truth for remaining tasks, status,
   ownership, restart conditions, and required task dependencies.
3. After selecting a task, read only the detailed canonical document linked
   from that task row.
4. Do not scan all planning documents or archived records at session start.
   Do not revive tasks from old checklists, handoffs, or logs.
5. Priority order is: the user's latest instruction, the Task Registry, the
   selected task's canonical document, then archived records and old logs.
6. Never start `PROPOSED`, `WAITING_USER`, `FROZEN`, `USER_ONLY`, or `WAITING_EXTERNAL` tasks
   unless their explicit activation or restart condition has been satisfied.
7. Codex owns final Registry updates and completion acceptance unless the
   Registry explicitly assigns that responsibility elsewhere.
8. Internal Registry files, IDs, states, and handoffs are agent tools. Inspect
   them yourself and translate the result; do not ask the user to operate the
   task-management system or read an internal file to learn current status.
9. Ask the user only for product direction, reserved authority, or a decision
   that cannot be made safely from the recorded evidence.
10. Dependency-ready does not mean necessary or next. Before selecting or
    assigning work, check whether it is `DIRECT`, `NEAR`, `FAR`, `LATER`, or
    `OUTSIDE` relative to the current intermediate goal.
```
