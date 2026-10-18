# 移行史の追加探索 — 残したもの・撤去したもの

## TL;DR（人間向け）

UnsafeNodeの2026-01-18〜22の削除・再導入を調べ、型本体と主要責務は連続し、実際のfactory・Equatable・名称変更は別の変更として区別した。AstraがGitから独立照合して受入済み。作者の意図・当時のテスト成功・HEAD外の系譜は未確認で、移行史全体の完了や後続調査の開始を意味しない。

Created 2026-10-16 by Astra. Fixed ID HIST-002; type DISCOVERY.
Parent HIST-001 is the permanent AtCoder 2025 migration-history node. Assigned to V3 author; accepted by Astra.
The user authorized preparation and registration of this additional investigation. It is an individual assignment for V3 when handed this document by the user, not an assignment to anyone else who reads it.

<a id="目的"></a>
## Purpose

Investigate one insufficiently explained turning point in the migration history and return evidence supporting or correcting the account, or the limits of that evidence. Reinforcing an existing success story or exhaustively covering all history is not the objective.

Inputs are `Maintanance/History/RefactoringFromAtCoder2025/README.md` and `EVIDENCE.md`. Start with relevant sections and proceed to necessary Git history, preserved source and tests. Past memory may guide discovery; connect factual claims to artifacts. Archived materials are historical evidence, not revived current instructions.

<a id="任せる探索"></a>
## Delegated investigation

V3 chooses the question, investigation order and approach to evidence within this history. The following are Astra's suggestions, neither a complete checklist nor priorities; another question may be chosen.

- For the short-lived reference-count/strong-uniqueness trial, what changed at introduction and removal? Is the reason documented, or only inferred from structure?
- During UnsafeNode removal/reintroduction on 2026-01-18–22, what continued or changed in name, implementation and responsibility?
- Choose one invariant in the period of relaxed Keystone checks and trace its later check, explicitly noting if no transfer record is found.

Start with one question and one interval or responsibility. Follow adjacent material directly relevant to the result. If costly, narrow scope or return the established point and next lead. No obligation to exhaust the suggestions, add periodic entries or meet a work quota.

Freedom concerns investigation method. It excludes new product policy/contracts, unfreezing or implementation changes; return those as questions if needed.

<a id="証拠と返却"></a>
## Evidence and return

Record only what is needed in the Return below:

- Selected question, scope and investigation HEAD.
- Established facts and traceable evidence such as commits and historical paths.
- Interpretations and unexplained points; mark author intent as inference unless directly documented.
- A location and brief proposed update to README / EVIDENCE if worthwhile; no update is also valid.
- Completion or partial return, remaining leads and release of editing ownership.

Distinguish existence of tests from historical execution and success. A commit message alone does not prove green; failure to find evidence does not prove non-execution. A present rerun is not evidence of historical execution. This assignment does not require rebuilding old configurations or remeasuring performance.

Edit only this document's Return. Treat existing migration history and evidence appendix as fixed inputs and return proposed changes. No Registry, numbering, product source, tests or others' work changes. Separate permanent delegations retain their own conditions. No commit/push permission is included.

<a id="受入条件"></a>
## Acceptance conditions

A traceable conclusion and unverified boundary for one question suffice. New discoveries are optional: confirmation that the existing account suffices, or inability to settle a bounded question, are acceptable outcomes. If an answer requires unlimited expansion, identify the investigated scope and dead end. Mere non-start is not completion.

Astra checks evidence and proposed updates, makes necessary document/Registry updates and retains HIST-001 as permanent. Completing this child neither completes the parent nor automatically starts further investigations. Parentage is organizational; no mandatory Task precedence edge is added.

## 返却欄（V3記入）

### 選んだ問いと範囲

2026-01-18〜22の`UnsafeNode`について、path上の削除・再導入が実装や責務の断絶だったのかを調べた。
調査時のHEADは`8094d43748174bbc981a481f9760c582f1b050ab`。現行HEADの祖先にあるcommitだけを対象に、
型本体のblob、rename判定、削除直前と再追加直後のdiff、およびこの区間で型本体を変更したcommitを照合した。

### 確認できた事実

- `a5995bec`（2026-01-18 15:34 +09:00）は、
  `UnsafeTreeV2/Tree/___Primitive/UnsafeNode.swift`を
  `__tree/Unsafe/UnsafeNode.swift`へ`R100`で移した。移動前後のblobはともに
  `1eddf823efadf925a17711a05081edaf588a0ea6`であり、この時点では実装変更を伴わない。
- `364c203d`（同日15:59）は同じblobを`__tree/unsafe_tree/UnsafeNode.swift`へ、
  `7cac21d8`（2026-01-19 04:28）は同じblobを`__tree/_types/unsafe_node.swift`へ、いずれも`R100`で移した。
  したがって1月18〜19日のpath・大文字小文字の変更は、型本体については同一実装の連続である。
- 型本体の実質的な変更は1月21日にあった。`0e3c417f`で、pointer extensionにあった
  `create(id:)`を`UnsafeNode.create(id:)`へ移し、子・親を呼出元pointerではなく`nullptr`で初期化する形にした。
  `e99f83b6`でそのfactoryを`package`へ公開し、`b9baeb13`で`Equatable`適合を加えた。
- `658c70a6`（2026-01-22 12:42:36 +09:00）は`__tree/_types/unsafe_node.swift`を削除し、
  直後の`96d45467`（12:43:43）は`__tree/unsafe_tree/unsafe_node.swift`を追加した。削除直前のblobは
  `1753a92bbfdb9e717c24fb083ab9065d4f615a27`、再追加後は
  `7bb1b235bd19ad31d9fe9831517388918f4560ff`で一致しないが、diffは空白と
  `extension UnsafeNode: Equatable { }`から`extension UnsafeNode: Equatable {}`への整形だけである。
  373行の型・field・method・可視性に意味上の差は見つからなかった。
- 再追加後の同日17:55〜18:03には、`a87dcdb4`、`f9100295`、`08062511`で
  `pointerIndex`を`rawIndex`へ、保存fieldとinitializer labelを`___node_id_`から`___raw_index`へ改名した。
  これは削除・再追加そのものとは別の後続変更であり、Nodeが保持する整数identityの責務は残っている。

### 解釈と未確認範囲

この区間は「`UnsafeNode`実装を撤去して別実装を再導入した」とは説明しにくい。1月18〜19日は100% rename、
1月22日の67秒間の削除・再追加も意味上は同一内容のpath移設であり、Node本体、pointer link、payload直後配置、
deinitialize flag、CoW用の整数identityという主要責務は連続している。一方、1月21日のfactory変更と
`Equatable`追加、1月22日夕方のidentity名称変更は実際の変更として分ける必要がある。

commit messageは`many`、`remove`、`file`、`some`等に留まり、削除と再追加を二commitに分けた作者意図を
直接説明する記録は今回の限定範囲では確認できなかった。したがって「path再編のため」という意図までは確定せず、
実物の差から「結果としてpath移設になっている」とだけ判定する。当時のtest実行・green範囲は調べておらず、
現行HEAD外の試作系譜も対象外とした。

### 反映案と返却

`EVIDENCE.md`の系譜表にある「一時削除」は誤りではないが、実装断絶にも読める。
同表の`UnsafeNode`行を「V2側から100% renameで移動。`658c70a6`で削除後、67秒後の`96d45467`で
空白整形のみの内容を別pathへ再追加」に具体化し、未確認欄の「同一実装の継続範囲は未確定」は、
「型本体は上記範囲で連続。二commitに分けた意図と当時のtest実行範囲は未確認」へ更新する価値がある。

本調査は完了として返却する。残る手掛かりは、作者意図を示す同時期の外部記録と当時のtest実行記録である。
編集したのは本書の返却欄だけで、移行史本文、証拠別紙、Registry、製品source、testには触れていない。


<a id="独立受入2026-10-16--astra"></a>
## Independent acceptance (2026-10-16 / Astra)

After V3's completed return and release, independently checked from Git that the eleven cited commits are ancestors of current HEAD, the three R100 moves and identical blobs, deletion/addition times and blob differences, and factory/Equatable/identity-name changes. No discrepancy; accepted without changing the original return.

Updated the UnsafeNode row and unverified field in EVIDENCE.md and added reproducible evidence. No change to README's general account was needed. Historical test success, author intent and off-HEAD experiments remain unverified. No historical build/test execution.

HIST-002 was accepted, WAITING_USER for commit confirmation; permanent parent HIST-001 remained ACTIVE. No new investigation was assigned.

On 2026-10-16 the user's commit instruction was received; save accepted HIST-002 as DONE.
