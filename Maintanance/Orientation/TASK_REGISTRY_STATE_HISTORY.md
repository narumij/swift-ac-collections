# Task Registry状態変化の履歴調査

## この文書の段階

この文書は、Task Registryの状態モデルが変化した過程をGit履歴から復元するための作業記録である。
現時点では、完成した歴史説明でも、現行運用を定める正本でもない。

まずcommit順に事実を蓄積する。状態の追加理由、当時の意図、変更の評価は、前後の証拠が揃った後で
重ねる。記録だけでは分からない部分には、作者の記憶を接続する余地を残す。材料が十分に貯まった後、
必要なら事実・証拠の正本と、証拠から成立する履歴説明へ分離する。

調査の終点は、commit `5c88335d`（`best codex was gone`）の直前にあるcommit `1b1505d3`
（2026-10-09 15:08:14 +0900）とする。それ以後の変更や解釈を、当時の履歴へ混ぜない。

## 調査方法

`Maintanance/PROGRESS_OVERVIEW.md`を変更したcommitを古い順に追い、各時点について次を記録する。

- 状態一覧と定義
- 直前の版から追加、削除、改名された状態
- task行に現れた状態
- 状態と依存関係の役割に関する記述
- 同じcommitで加わった、変化の意味を調べる手掛かり
- Gitの記録だけでは確定できない点

単語の初出検索だけで変更理由を確定しない。状態一覧が変わらないcommitも確認対象に含める。

## 2026-10-04: `PROGRESS_OVERVIEW.md`初版

### `1a235c31` `interview?`

`PROGRESS_OVERVIEW.md`が追加された。Task Registryという名前や永続IDはまだ存在しない。

文書は、現在の判断に必要な状態として次の6状態を明記していた。

| 登場順 | 状態 | 初版の定義 |
| --- | --- | --- |
| 1 | `完了` | 実装・必要な検証・記録まで一区切りしている |
| 2 | `完了・追加検証可` | 現在の完成判断を止めないが、環境や比較対象を増やせる |
| 3 | `進行中` | 現在の主経路に含まれる |
| 4 | `判断待ち` | ユーザーまたは設計判断が先に必要 |
| 5 | `保留` | 重要だが現在の完成条件には含めない |
| 6 | `中止` | 明示的に停止し、勝手に再開しない |

状態は一つのtableへ集約されていたが、taskは単一Registry tableではなく、文書内の見出しへ分かれていた。

- `現在進行中の主経路`
- `判断待ち`
- `保留・完成を止めない追加検証`
- `中止・再開禁止`

この時点で確認できる最初の状態一覧は3状態ではなく6状態である。3状態という記憶が別の管理対象、
別の時期、または状態の抽象化を指すかは、後続履歴を確認してから照合する。

## 2026-10-04〜2026-10-06: 6状態を維持した更新

初版の後、Task Registry導入直前の`60ded377`までに、次の32 commitが
`PROGRESS_OVERVIEW.md`を変更した。各commitの状態tableを比較した結果、6状態の表記と定義は
初版から一度も変化していない。

| 順 | Commit | 日時 | Subject | 状態一覧への変更 |
| --- | --- | --- | --- | --- |
| 1 | `92d47600` | 2026-10-04 12:02 | `agreed` | なし |
| 2 | `fc89e3bd` | 2026-10-04 17:14 | `interview` | なし |
| 3 | `69e67a21` | 2026-10-04 17:48 | `something` | なし |
| 4 | `f4421afd` | 2026-10-04 17:56 | `something` | なし |
| 5 | `a5482b2e` | 2026-10-04 20:01 | `Harden stale index validation under unchecked optimization` | なし |
| 6 | `b3570172` | 2026-10-04 20:06 | `something` | なし |
| 7 | `69756b9a` | 2026-10-04 21:26 | `narrow view identity hooks` | なし |
| 8 | `23a0de56` | 2026-10-04 21:39 | `narrow debug bound fixtures` | なし |
| 9 | `347e7500` | 2026-10-04 22:07 | `isolate legacy iterators to compatibility mode` | なし |
| 10 | `36bc19bf` | 2026-10-04 22:27 | `narrow reference tree protocols` | なし |
| 11 | `c1318574` | 2026-10-04 22:56 | `narrow bridge protocols` | なし |
| 12 | `cf7a7d36` | 2026-10-04 23:43 | `narrow multiplicity protocols` | なし |
| 13 | `c8096ebb` | 2026-10-04 23:53 | `narrow node comparison protocol` | なし |
| 14 | `c04fec93` | 2026-10-05 04:00 | `document index decisions and combining guidance` | なし |
| 15 | `aecbcddf` | 2026-10-05 04:07 | `define cross-branch Index validation workflow` | なし |
| 16 | `283d5e1a` | 2026-10-05 04:31 | `freeze exhaustive cross-branch Index inventory` | なし |
| 17 | `c3bb660c` | 2026-10-05 04:47 | `record deferred index PoC validation` | なし |
| 18 | `24410ce9` | 2026-10-05 04:56 | `validate index insertion API at scheduler call site` | なし |
| 19 | `d421972b` | 2026-10-05 05:12 | `expand AcCollections facade to all modules` | なし |
| 20 | `0b688e26` | 2026-10-05 05:13 | `record facade documentation validation` | なし |
| 21 | `57dc2741` | 2026-10-05 05:22 | `document red-black tree test support roles` | なし |
| 22 | `00ea354f` | 2026-10-05 05:26 | `document red-black tree layout test layers` | なし |
| 23 | `2796d7c2` | 2026-10-05 05:31 | `classify remaining collection backlog` | なし |
| 24 | `e8eb92c6` | 2026-10-05 18:23 | `Document runtime check policy and pre-1.0 review gate` | なし |
| 25 | `1e0c9501` | 2026-10-05 19:09 | `extend index(inserting:) and erase(exactly:) to MultiSet and Dictionary` | なし |
| 26 | `86033a7d` | 2026-10-05 22:24 | `sync planning docs to the merged Index and annotate CoW-branch specs` | なし |
| 27 | `9f21c6e2` | 2026-10-06 06:16 | `archive completed maintenance records` | なし |
| 28 | `3041a784` | 2026-10-06 06:29 | `Archive completed maintenance records` | なし |
| 29 | `dbe8c26e` | 2026-10-06 06:37 | `Refresh maintenance status and archive test history` | なし |
| 30 | `1727ca34` | 2026-10-06 06:46 | `Move C++ comparison matrix into documentation` | なし |
| 31 | `50273dfe` | 2026-10-06 06:51 | `Clarify documentation ownership and frozen user work` | なし |
| 32 | `60ded377` | 2026-10-06 06:54 | `Classify ABC328E submission as frozen user work` | なし |

注: 初版を除く対象は32 commitである。上記区間のcommit数は、初版を含めて33である。

この区間では個々の作業内容、判断、保留、中止対象は変化しているが、それらを表す状態語の体系は
6状態のまま維持された。

### Registry再編直前に見える区別の前兆

状態一覧は変わらなかったが、末尾の二つのcommitには、直後のRegistry状態へつながる具体的な区別が
現れている。

#### `50273dfe` `Clarify documentation ownership and frozen user work`

ABC328E実提出確認をPermutation互換modeから分離し、「ユーザーが手作業で行う専任項目として凍結。
AIは着手・代行・催促しない」と記録した。この時点では独立した状態名はなく、既存の文章で専任境界を
表現していた。

#### `60ded377` `Classify ABC328E submission as frozen user work`

同項目を`判断待ち`から`中止・再開禁止`へ移した。次の`e4aa207d`では、この項目が`PERM-002`として
`USER_ONLY`へ移される。

この二commitは、`USER_ONLY`という名前が登場する前に、ユーザー専任、AIの非着手、非代行、非催促という
責任境界が文章と配置で先に存在したことを示す。

## 2026-10-06: Task Registryへの再編

### `e4aa207d` `Use task registry as the project entry point`

このcommitで、文書先頭に永続IDを持つ`Task registry` tableが追加され、作業状態、担当、再開条件の
正本とされた。従来の6状態tableは、次の7状態へ置き換えられた。

| 登場順 | 状態 | 導入時の定義 |
| --- | --- | --- |
| 1 | `ACTIVE` | AIが次の作業として着手可能 |
| 2 | `WAITING_USER` | ユーザー判断または設計判断が必要 |
| 3 | `FROZEN` | 明示的な再開指示が必要 |
| 4 | `USER_ONLY` | ユーザー専任。AIは着手・代行・催促しない |
| 5 | `EXCLUDED` | 実施対象外。再開候補にも含めない |
| 6 | `DONE` | 完了。現役の正本を維持 |
| 7 | `ARCHIVED` | 完了し、履歴資料へ移動済み |

このcommitは、状態名の英訳だけを行ったものではない。

- taskへ永続IDを与えた。
- 状態、担当、項目、再開・完了条件、詳細正本を一行に集約した。
- `USER_ONLY`によってユーザー専任と催促禁止を独立させた。
- `DONE`と`ARCHIVED`によって、現役正本を維持する完了と履歴移動済みを分けた。
- `EXCLUDED`によって、再開可能な停止と実施対象外を分けた。
- Task Registryの確定更新をCodex、handoffと差分案をClaudeの担当とした。

導入時の実データには、`WAITING_USER`、`ACTIVE`、`FROZEN`、`USER_ONLY`、`DONE`、`EXCLUDED`が
現れた。`ARCHIVED`は規則として定義されたが、導入時のRegistry行には現れなかった。

導入時の`FROZEN`行には、すでに複数種類の再開条件が混在していた。

- ユーザーの明示的な再開を待つtask。
- Index契約など、別の設計確定を待つtask。
- 外部consumerの移行やSwift更新など、将来条件を待つtask。
- 実害が生じた場合、または明示的に再開された場合だけ扱う任意改善。

したがって、`FROZEN`が後から依存待ちへ拡張されたのではなく、Task Registry導入時点ですでに
「今は着手しない複数種類の条件付きtask」を収容していたことが確認できる。

### この時点で未確定のこと

- 従来6状態から新7状態への一対一の対応関係は、commit本文だけでは定義されていない。
- 新しい区別のうち、どれが事前設計で、どれが直前の介入や作業経験から必要になったかは未調査である。
- 「最初の3状態」という記憶が指す対象は、この時点までの`PROGRESS_OVERVIEW.md`からは確認できない。

## 2026-10-06: 外部待ちの分離

### `6ca7a275` `Add Codex repository startup instructions`

Task Registry導入の次に`PROGRESS_OVERVIEW.md`を変更したcommit。状態集合への変更はなかった。

### `19ce8b5f` `Clarify task dependency states`

8番目の状態として`WAITING_EXTERNAL`が追加された。

| 登場順 | 状態 | 導入時の定義 |
| --- | --- | --- |
| 8 | `WAITING_EXTERNAL` | repository内の判断だけでは解消できない外部条件を待っている |

同じcommitで、次の変更が行われた。

- 現在の律速として、`swift-collections` ContainersPreviewの`Container.Index`要件が明記された。
- `RBT-001`と`RBT-002`が`WAITING_USER`から`WAITING_EXTERNAL`へ変更された。
- `RBT-010`と`RBT-011`が`WAITING_EXTERNAL`で追加された。
- 内部taskの必須AND前提を表す`Task precedence`が追加された。
- 外部条件は状態と再開・完了条件、内部task間の順序は辺リストで扱うと記録された。
- 前提taskの待機が後続を止める場合、影響を後続taskの状態にも反映すると記録された。
- Registryの状態は「通常の再開判断に使う計算済みの表示」と説明された。

このcommitの差分から、`WAITING_EXTERNAL`追加時に実在した対象と、同時に導入された依存表現までは
確認できる。なぜこの時点で区別が必要だと認識したかという会話上の経緯は、まだ確定していない。

導入直前には、外部要件待ちのIndex関連taskが`WAITING_USER`とされていた。追加commitでは
「ユーザー判断で解消できるtaskは現在ない」と明記されたため、少なくとも記録上は、ユーザー判断待ちと
repository内では解消できない外部待ちを分離する変更だったことが確認できる。

## 2026-10-06〜2026-10-07: 8状態を維持した更新

`19ce8b5f`の後、`236434ff`までに7 commitが`PROGRESS_OVERVIEW.md`を変更した。両端を除く5 commitで、
状態集合への追加・削除はなかった。

| Commit | 日時 | Subject | 状態集合への変更 |
| --- | --- | --- | --- |
| `7784ff7f` | 2026-10-06 11:11 | `Record frozen 1.0 quality gate` | なし |
| `34b46a27` | 2026-10-06 16:33 | `Add independent task graph DB experiments` | なし |
| `149d8b8c` | 2026-10-07 00:11 | `Record completed Index quality checks` | なし |
| `ac9fb91e` | 2026-10-07 03:15 | `Close completed Result API cleanup task` | なし |
| `dc5c7572` | 2026-10-07 04:52 | `Split Permutation compatibility work into tasks and add graph smell notes` | なし |

### `236434ff` `Archive completed maintenance document history`

状態集合は8状態のまま変わらなかった。一方、文書構造は大きく縮小された。

- 旧サマリー、完了チェック、判断待ち等が`Archived/PROGRESS_OVERVIEW_HISTORY_2026-10-07.md`へ移された。
- 独立していた`状態表示`のtableが現行文書から削除された。
- 状態集合は`Registry rules`の一行へ集約された。
- Task precedenceは現行Registryの独立sectionとして残された。

このため、以後は状態の詳しい意味が`PROGRESS_OVERVIEW.md`だけでは見えにくくなり、簡潔な規則と
実際のtask行から運用を読む構造になった。

また、この整理で「状態は計算済みの表示」「前提taskの待機を後続taskの状態にも反映する」という
`19ce8b5f`の詳しい規則も現行文書から削除された。状態集合は変わらないが、状態と依存graphの関係を
説明する情報量は減っている。

## 2026-10-07〜2026-10-08: 8状態を維持した更新

`236434ff`から`bb77fafc`までに60 commitが`PROGRESS_OVERVIEW.md`を変更した。両端を除く58 commitを
確認した範囲では、状態集合への追加・削除はなかった。

この区間では、Permutation、OptionalArray、品質評価、判断task、task型、graph実験、中間ゴールなどが
多数追加・更新された。状態集合自体は8状態のまま維持された。個々のtask行の状態遷移と、状態の使われ方の
変化は後続の調査対象とする。

## 2026-10-08: 未整理候補の分離

### `bb77fafc` `Add portable task registry template`

9番目の状態として`PROPOSED`が追加された。

| 登場順 | 状態 | 導入時の定義 |
| --- | --- | --- |
| 9 | `PROPOSED` | 忘失防止のtask候補。範囲、完了条件、担当、詳細正本、必須依存を確定して状態を更新するまで着手・委任しない |

同じcommitで`PROGRESS_OVERVIEW_TEMPLATE.md`が新設された。templateでは9状態の意味が個別に記述され、
`PROPOSED`から実行可能な状態へ移す前の確認項目も定義された。

このcommit時点の現行Registryには、まだ`PROPOSED`のtask行は存在しなかった。状態と例示行は、同時に
追加されたportable templateへ先に現れた。

### `ce97783d` `Plan retrospective graph fixture replay`

`GRAPH-009`が`PROPOSED`として登録された。調査で見つかった候補を忘失防止のために保持し、fixtureの
受入後にscope、依存、担当を確定するという、実Registry上の最初の使用を確認できる。

## 2026-10-08〜2026-10-09: 依存表現と状態運用の再整理

状態集合は9状態のまま維持されたが、状態と依存graphの役割は複数段階で整理された。

### `0295b5cc` `Plan staged task precedence gate migration`

Task precedenceの辺に、着手を止める`START`、完了だけを止める`COMPLETE`、未分類の
`UNCLASSIFIED`を導入する段階移行taskが登録された。移行task自体は`ACTIVE`、後続fixtureと完成判定は
`FROZEN`として登録された。

この時点では、内部依存の種類を辺側へ移す作業を、既存の状態体系を変えずに進めようとしていた。

### `e0cc057f` `Define task assignment inlining`

taskを削除・統合せず、複数の判断不要な`EXECUTION` taskを一つのassignment packageとして実行する
インライン化が定義された。`FROZEN`、`WAITING_USER`、`WAITING_EXTERNAL`、`USER_ONLY`は
インライン化対象外とされた。

ここでは、状態が異なるtask、担当や受入責任が異なるtask、独立した証拠が必要なtaskを一つの実行単位へ
混ぜない境界として状態が使われている。

### `bc3a092f` `Define conditional task retention policy`

「上流判断前に採番済みとなった条件付きtask」を、必須依存を持たない`FROZEN`として保持する方針が
決定済みとして記録された。上流結果の判明時に、必要なら再開し、不要なら`EXCLUDED`へ送る運用である。

同commitでは、この方針を判断するための`WAITING_USER` task `OPS-014`がRegistryから除かれた。

### `afeb3ee0` `Close speculative frozen tasks`

条件付きまたは任意改善として保持されていた複数の`FROZEN` taskが現行Registryから削除された。
削除対象には、ユーザー専任の評価記録、未結線コード、歴史的test、任意改善、追加benchmarkなどが含まれる。

このcommit単体では、削除された各IDが`EXCLUDED`としてどこへ保存されたかまでは示していない。
`FROZEN`保持方針の決定直後に、不要とみなされた既存候補の掃除が行われたことは確認できる。

## 2026-10-08〜基準点: 9状態を維持

`bb77fafc`から基準点`1b1505d3`までに105 commitが`PROGRESS_OVERVIEW.md`を変更した。両端を除く
103 commitを確認した範囲では、状態集合への追加・削除はなかった。

状態集合の登場順だけを見ると、基準点までの変化は次の三段階になる。

1. `PROGRESS_OVERVIEW.md`初版の日本語6状態。
2. Task Registry導入時の英語7状態と、その直後に加わった`WAITING_EXTERNAL`。
3. portable template作成時に加わった`PROPOSED`。

| 時点 | 状態数 | 状態集合 |
| --- | --- | --- |
| `1a235c31` | 6 | `完了`、`完了・追加検証可`、`進行中`、`判断待ち`、`保留`、`中止` |
| `e4aa207d` | 7 | `ACTIVE`、`WAITING_USER`、`FROZEN`、`USER_ONLY`、`EXCLUDED`、`DONE`、`ARCHIVED` |
| `19ce8b5f` | 8 | 上記7状態 + `WAITING_EXTERNAL` |
| `bb77fafc` | 9 | 上記8状態 + `PROPOSED` |
| `1b1505d3` | 9 | 状態集合の追加・削除なし |

## ここまでで未調査のこと

- 状態集合を変えずに、状態の意味または使い方を変えたcommit。
- 日本語6状態から英語7状態へ移る際の、task単位の対応関係。
- どの介入、失敗、再開上の問題が各区別を必要としたか。
- 「最初の3状態」という記憶が指す対象。

## 172 commitのtask行状態遷移

`e4aa207d`から`1b1505d3`まで、`PROGRESS_OVERVIEW.md`を変更した172 commitについて、同じIDが
前後両方に存在する場合の状態変化を機械比較した。

行の新規追加と、アーカイブ・削除による行消失を除いた遷移数は次のとおり。

| 遷移 | 件数 | 最初に確認したcommit / task |
| --- | ---: | --- |
| `ACTIVE → DONE` | 76 | `34b46a27` / `DOC-001` |
| `FROZEN → ACTIVE` | 17 | `d4027ff0` / `BARE-001` |
| `FROZEN → DONE` | 17 | `d784b91e` / `PERM-003` |
| `FROZEN → WAITING_USER` | 14 | `1dd96c3c` / `PERM-032` |
| `WAITING_USER → DONE` | 11 | `c3e7692f` / `OPT-029` |
| `WAITING_EXTERNAL → DONE` | 4 | `149d8b8c` / `RBT-002` |
| `ACTIVE → FROZEN` | 4 | `d23cf6a8` / `BARE-001` |
| `ACTIVE → EXCLUDED` | 3 | `654c7f75` / `RBT-016` |
| `FROZEN → EXCLUDED` | 2 | `39360dd8` / `GRAPH-003` |
| `WAITING_USER → FROZEN` | 2 | `0b08e523` / `OPS-013` |
| `WAITING_USER → WAITING_EXTERNAL` | 2 | `19ce8b5f` / `RBT-001` |
| `ACTIVE → WAITING_EXTERNAL` | 2 | `f5257504` / `OPT-043` |
| `PROPOSED → ACTIVE` | 1 | `a31dbcb3` / `GRAPH-009` |
| `ACTIVE → WAITING_USER` | 1 | `98de7302` / `PERM-013` |
| `FROZEN → WAITING_EXTERNAL` | 1 | `149d8b8c` / `RBT-003` |
| `DONE → ACTIVE` | 1 | `81dc5681` / `RELEASE-002` |
| `DONE → EXCLUDED` | 1 | `81dc5681` / `PERM-005` |

この集計は、commit間のRegistry snapshotに現れた変化を数えたものである。同一commit内で途中状態を
経たか、状態更新を省略して成果と完成を同時に記録したかは判別できない。

### 集計から確認できる事実

- 最も多い完了経路は`ACTIVE → DONE`だった。
- `FROZEN → ACTIVE → DONE`の段階的な再開が繰り返し使われた。
- 同数の17件で`FROZEN → DONE`も発生し、すべてのtaskが`ACTIVE`を明示的に経由したわけではない。
- ユーザー判断taskは主に`FROZEN → WAITING_USER → DONE`として現れたが、`WAITING_USER`で直接追加された
  taskも存在する。
- `PROPOSED → ACTIVE`は基準点までに`GRAPH-009`の1件だけ確認できる。
- `USER_ONLY`から別状態への遷移は確認できない。
- 一度`DONE`になったtaskを再び`ACTIVE`または`EXCLUDED`へ変更した事例が各1件ある。

### 状態変更を伴うcommitのまとまり

状態変更は均等に発生していない。特に次の作業系列で集中した。

- OptionalArray監査では、証拠taskの`ACTIVE → DONE`、後続taskの`FROZEN → ACTIVE`、判断taskの
  `WAITING_USER → DONE`が短い間隔で連続した。
- Permutation互換作業では、親taskを`FROZEN → ACTIVE`で再開した後、子taskを
  `FROZEN → DONE`として順次閉じた。
- Task precedenceの分類では、事前登録された判断taskを`FROZEN → WAITING_USER`へ一件ずつ移した。
- BareArray監査では、棚卸し受入後に判断taskを`FROZEN → WAITING_USER`へ移し、判断後に後続実行を
  `FROZEN → ACTIVE`へ移した。

この段階では、これらを正しい状態機械として評価しない。実際の運用がどの状態を必要とし、どの遷移を
省略または混用したかを知るための観測として保存する。

## 次に調べること

状態遷移が集中した代表commitの前後を読み、状態名だけでは分からない開始許可、ユーザー判断、外部待ち、
完了受入の実際の扱いを確認する。その後、記録からは確定できない背景を作者の記憶と照合する。
