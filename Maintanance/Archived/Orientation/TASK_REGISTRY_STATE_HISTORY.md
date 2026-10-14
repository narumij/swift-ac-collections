# Task Registry状態変化の履歴調査

## この文書の段階

この文書は、Task Registryの状態モデルが変化した過程をGit履歴から復元するための作業記録である。
現時点では、完成した歴史説明でも、現行運用を定める正本でもない。

まずcommit順に事実を蓄積する。状態の追加理由、当時の意図、変更の評価は、前後の証拠が揃った後で
重ねる。記録だけでは分からない部分には、作者の記憶を接続する余地を残す。材料が十分に貯まった後、
必要なら事実・証拠の正本と、証拠から成立する履歴説明へ分離する。

調査の終点は、commit `5c88335d`（`best codex was gone`）の直前にあるcommit `1b1505d3`
（2026-10-09 15:08:14 +0900）とする。それ以後の変更や解釈を、当時の履歴へ混ぜない。

## 現時点で見える進化の骨格

初期履歴からは、task管理が暫定的に次の順で発展したように見える。

> handoffを残す
> → 要望と停止を区別する
> → 現在地と履歴を分ける
> → 分野別作業面を横断する
> → ID・状態・依存として形式化する

これは調査途中の要約であり、確定した歴史解釈ではない。後続commitの調査や作者の記憶との照合により、
段階の追加、統合、順序の修正があり得る。

## 調査方法

`Tests/TESTING.md`、`Maintanance/MAINTENANCE.md`、`Maintanance/PROGRESS_OVERVIEW.md`を変更したcommitを
古い順に追い、各時点について次を記録する。

- 状態一覧と定義
- 直前の版から追加、削除、改名された状態
- task行に現れた状態
- 状態と依存関係の役割に関する記述
- 同じcommitで加わった、変化の意味を調べる手掛かり
- Gitの記録だけでは確定できない点

単語の初出検索だけで変更理由を確定しない。状態一覧が変わらないcommitも確認対象に含める。

## 2026-09-28〜2026-10-03: `TESTING.md`が担った最初の作業面

### `7e7f10f5` `refactoring tests?`: 最初の運用記録

現在確認できる最初のtask管理文書は、`Tests/RedBlackTreeTests/TESTING.md`である。初版には状態一覧や
task IDはなく、次の三つが同居していた。

- `Test as Spec`などの作業規則。
- `Safe migration workflow`という実行・検証・commit可能状態までの手順。
- `Current handoff`という、完了範囲、残件、次の開始地点の引き継ぎ。

この段階では、独立したtask台帳というより、テスト整理作業を壊さず継続するための規則と現在地の記録
だった。ただし、後のtask管理を構成する「何を守るか」「どこまで済んだか」「次に何をするか」は、
すでに同じ文書に存在した。

### `34f0e422` `refactoring tests?`: ユーザー要望をhandoffより上位へ置く

`User requests for the next session`が追加された。ここには、次回の優先対象、残すものと削除してよいもの、
配置方針、停止条件、保留判断をユーザーが記入できた。文書は、この欄を`Current handoff`より先に読み、
完了項目もagentが勝手に削除しないよう定めた。

したがって、後のtask管理にあるユーザー指示の優先、停止、保留、受入後の整理は、Registry導入より前に、
テスト作業の継続方法として現れていた。

### `676b6bd9` `codex memo`: 自然文による状態区分

ユーザー記入欄が次の区分へ分かれた。

| 節 | 当時の役割 |
| --- | --- |
| `優先事項` | 次回に進める作業 |
| `連絡事項` | 条件、注意、利用可能時間などの実行文脈 |
| `停止条件` | 新規着手を止め、検証・記録・振り返りへ移る条件 |
| `保留中の判断・懸念` | 未確定事項、破損、後で判断する論点 |
| `完了済みの要望` | 対応が済んだユーザー要望 |

まだ状態値はないが、taskは文書内の位置を移ることで、優先、保留、完了を表せるようになった。

### `6d8551a3` `memo`: 目的、担当、禁止境界までを同じ面で管理

`ビジョン`が加わり、CodexとClaudeの担当差、勝手に判断してはいけない内部区分、検証基準、保留中の
設計論点も同じ文書へ蓄積された。`TESTING.md`は、テスト規則だけでなく、目的、優先、担当、停止、判断、
完了、handoffを扱う作業面へ成長した。

この構造は後のRegistryより疎である一方、ユーザーの意図と作業の詳細が近接していた。状態遷移は
列値ではなく、見出し間の移動、本文への追記、`Current handoff`の更新として行われた。

### `c08af11f` `some`: RedBlackTree専用からTests全体へ

文書は`Tests/RedBlackTreeTests/TESTING.md`から`Tests/TESTING.md`へ移動された。本文は99%維持され、
BareArray、OptionalArray、Permutationなど他のtest targetも将来扱う配置であることが追記された。

これは管理対象の拡張であり、まだproject全体のtask管理への分離ではない。公開ドキュメント作業には、
同日の`a5d6ad36`で別の`Documentation/MAINTENANCE.md`が作られていた。

### `5add4655` `doc`: 詳細ログを分離し、dashboardへ圧縮

膨張した`TESTING.md`は52行の「テストメンテナンス・ダッシュボード」へ再構成された。

- 詳細履歴を`Tests/TESTING_REFERENCE.md`へ退避した。
- 現在情報を`目的`、`優先事項`、`現在地`、`判断待ち`、`直近の引き継ぎ`へ圧縮した。
- 現在地は上書きし、長文報告や年代順ログを追加しないと定めた。

これは後のRegistryと同じく、現役の判断面と詳細履歴を分ける動きである。ただし対象はまだテスト領域で、
task ID、統一状態、依存関係はなかった。

## 2026-10-01〜2026-10-04: `MAINTENANCE.md`内のtask管理

### `a5d6ad36` `doc`: 文書作業用の姉妹作業面

`Documentation/MAINTENANCE.md`が追加された。これは`TESTING.md`から全taskを移した文書ではなく、公開文書、
コメントドック、DocC、CHANGELOGを扱う姉妹の作業面だった。Task Registry、永続ID、統一された状態tableは
まだ存在しない。一方、`TESTING.md`で育った管理構造は、最初の版からほぼ同じ形で採用された。

| 節 | 当時の役割 |
| --- | --- |
| `ビジョン` | 到達させたい継続的な状態 |
| `優先事項` | 次に進めるユーザー要望と作業順 |
| `相談事項` | 方針を決める必要がある論点 |
| `連絡事項` | 運用規則と、別文書で見つけた不足の伝達 |
| `停止条件` | 推測で進めず停止する条件と、全体完了の上位条件 |
| `保留中の判断・懸念` | 未確定の仕様、反証、後続候補 |
| `完了済みの要望` | 判断・実装・検証が済んだ要求 |
| `Current handoff` | 直近の実績、残件、次作業を次のagentへ渡す追記型記録 |

文書は`User requests for the next session`を`Current handoff`より先に読むよう定めていた。ユーザー要望を
優先し、完了した項目を勝手に削除せず、完了済みへ移すかユーザー確認後に整理する運用だった。

この時点のtaskは、個別IDを持つrowではない。ユーザー要望、作業項目、判断待ち、証拠、完了報告が、
見出しによる分類と自然文の更新・移動によって管理されていた。

### `877eac14` `many`: `Maintanance/`への移動

`Documentation/MAINTENANCE.md`は内容を変えず`Maintanance/MAINTENANCE.md`へ移された。同じcommitでは
`TESTING.md`も更新されているが、両者は引き続きテスト領域と文書領域の別dashboardだった。

### 2026-10-01〜2026-10-04: 同じ文書内でtaskと結果を更新

`MAINTENANCE.md`は、追加後から`PROGRESS_OVERVIEW.md`初版まで繰り返し更新された。

- `c80d83c5`では、C++標準ライブラリとの継続的な挙動照合が`優先事項`へ追加された。
- 後続commitでは、Permutation改修、strict memory safety、テスト基盤、履歴調査などの要望と結果が
  同じ各節へ追加・更新された。
- 調査済みだが採用未決定、根拠確認済みだが公開コメント変更はユーザー判断待ち、という中間状態も
  項目本文の注記で表現された。
- 完了実績は`Current handoff`へ時系列に蓄積され、未確定事項は`保留中の判断・懸念`へ残された。

したがって、最初の管理方式は単純なtodo listではなかった。優先、判断、停止、保留、完了、handoffを
区別していたが、その区別はtaskの属性や状態値ではなく、文書内の配置と文章に埋め込まれていた。

## 2026-10-04〜2026-10-06: 二つの文書が併存した移行期

### `1a235c31` `interview?`: 全体進捗の分離

`PROGRESS_OVERVIEW.md`が新設され、`MAINTENANCE.md`に混在していた作業のうち、project全体の主要taskを
成果単位で横断表示する文書が分離された。

新しい文書には6状態が定義され、taskは次の節へ整理された。

- 完了した主要task。
- 現在進行中の主経路。
- 判断待ち。
- 保留・完成を止めない追加検証。
- 中止・再開禁止。

一方、同じcommit時点の`MAINTENANCE.md`には、`User requests for the next session`、優先事項、相談事項、
停止条件、保留中の判断、完了済み要望、`Current handoff`が残っていた。`PROGRESS_OVERVIEW.md`へ全task管理が
一度に移されたわけではなく、文書整備の作業面と全体進捗の集約面が併存した。

初版`PROGRESS_OVERVIEW.md`の項目は、旧文書の単純な転記でもなかった。C++比較、Permutation、
BareArray／OptionalArray、strict memory safety、履歴調査などをmodule横断で再分類し、完了実績も含む
project snapshotへ再構成していた。

### `3fe9f719` `refresh documentation maintenance dashboard`: 役割移管の明示

`MAINTENANCE.md`が大きく再構成された。

- 追記型だった`User requests for the next session`を、`Current dashboard`と履歴節へ再編した。
- 現在状態、文書に関係する未決事項、文書管理の運用をdashboardとして先頭へ置いた。
- 古い要望とhandoffを「現在のtask queueとして解釈しない」履歴へ分離した。
- 個別taskの長文結果を詳細正本へ置き、本書へ重複させない方針を明記した。
- 「テストの現在地は`Tests/TESTING.md`、全体進捗は`PROGRESS_OVERVIEW.md`を正とする」と明記した。

このcommitで、`MAINTENANCE.md`はproject全体のtask queueから、文書領域のdashboard、恒久規則、handoffへ
責務を狭めた。ただし、文書に関係する未決事項と現在handoffはまだ保持しており、役割移管の途中だった。

### `9f21c6e2`〜`50273dfe`: 正本分離と担当境界の整理

Registry導入までの間に、完了した調査・比較記録は`Archived/`や利用者向けDocumentationへ移され、
`MAINTENANCE.md`と`PROGRESS_OVERVIEW.md`の参照先が同期された。

`50273dfe`では、公開ドキュメントの第一担当をCodexとし、Claudeへ委譲できる範囲を事実確認、独立review、
限定修正へ狭めた。同じcommitで、Compatibility文書の包括監査を現行taskから外す変更が
`PROGRESS_OVERVIEW.md`にも反映された。

この期間には、taskの状態だけでなく、成果を置く正本、現役と履歴の境界、担当範囲も二文書をまたいで
整理されていた。

## 2026-10-06〜2026-10-07: Registryへの集約と旧文書の縮小

### `e4aa207d` `Use task registry as the project entry point`

`PROGRESS_OVERVIEW.md`へ永続ID付きTask Registryが導入された。同じcommitで`MAINTENANCE.md`には、
project作業の入口ではなく、Registryの文書taskから参照された場合だけ読む、と明記された。

この変更により、移行期に残っていた役割分担が次の形で確定した。

- Task Registry: 状態、担当、再開・完了条件、詳細正本を持つ唯一の作業入口。
- `PROGRESS_OVERVIEW.md`の後続section: 完了実績、詳細内訳、全体説明。
- `MAINTENANCE.md`: 文書整備の規則、文書dashboard、文書handoff。
- 個別正本: taskの長文結果、設計、監査、証拠。
- Archived: 現在の再開判断に使わない完了履歴。

Registry導入時の24行は、新規taskを一から発見したものではない。移行期の`PROGRESS_OVERVIEW.md`と
`MAINTENANCE.md`、各詳細正本に存在した主経路、未決事項、保留、禁止、完了実績へID、担当、再開条件を
与えて集約したものだった。

導入直前の`60ded377`とRegistry導入後を照合すると、旧sectionから新状態への移行は一対一の名称変更では
なかった。

| 旧section・扱い | Registryでの主な扱い | 例 |
| --- | --- | --- |
| 現在進行中の主経路 | `ACTIVE`または、既に閉じたものは`DONE` | P10残存記述確認、C++挙動比較 |
| 判断待ち | `WAITING_USER`または、再開自体が必要なら`FROZEN` | Index完了ゲート、`Result`比較overload |
| 保留・完成を止めない追加検証 | 主に`FROZEN` | OptionalArray／BareArray監査、性能比較、strict安全性 |
| 中止・再開禁止 | 理由に応じて`USER_ONLY`、`EXCLUDED`、または行を作らない | ABC328E実提出、MSVC比較、Compatibility包括監査 |
| 完了実績 | 継続参照するものだけ`DONE` | C++挙動比較 |

特に旧`中止・再開禁止`は一状態へ移されなかった。人間専任、実施対象外、task自体の撤回を区別した。
また旧`判断待ち`も、ユーザーが今決められるものと、明示的再開や別条件が先に必要なものへ分かれた。
Task Registry導入は、旧6状態の英訳ではなく、配置と自然文に埋め込まれていた待機理由、所有権、採否を
task行へ外在化する再分類だった。

### `236434ff` `Archive completed maintenance document history`

Registry導入翌日、`MAINTENANCE.md`と`PROGRESS_OVERVIEW.md`の古い要望、handoff、完了チェック、詳細履歴が
Archivedへ移された。

`MAINTENANCE.md`は、文書整備の恒久ルール、短いdashboard、現在handoff、文書の役割表を中心とする形へ
縮小された。役割表では`PROGRESS_OVERVIEW.md`を「Task Registryと現在状態の唯一の入口」、
`MAINTENANCE.md`を「文書整備の恒久ルールと現在handoff」と明記した。

したがって、現在の形はTask Registry導入commitだけで一度に完成したのではない。旧作業面から全体進捗を
分離し、正本と履歴を外へ出し、入口をRegistryへ一本化し、最後に旧handoffをアーカイブする段階移行で
成立した。

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

- 旧サマリー、完了チェック、判断待ち等が`Archived/PROGRESS_OVERVIEW_COMPLETED_2026-10-07.md`へ移された。
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
- 日本語6状態から英語7状態へ移る際の対応はsection単位で確認した。個々の旧checklist項目が、独立task、
  親taskの内訳、完了履歴、または非登録のどれへ移ったかという全件対応は未調査。
- どの介入、失敗、再開上の問題が各区別を必要としたか。
- 「最初の3状態」という記憶が指す対象。

## 評価・観察記録のcommit索引

評価・観察記録そのものを変更したcommitをGitログから抽出した。内容の解釈や状態モデルとの因果関係は、
この索引には含めない。

| 日付 | Codex記録 | Claude記録 |
| --- | --- | --- |
| 2026-10-04 | `fc89e3bd` | `fc89e3bd` |
| 2026-10-05 | `d75bbbdd`、`11acf803`、`ebda7370`、`19e12a1a` | `7c48016f`、`d75bbbdd`、`11acf803`、`d2485ca6`、`ebda7370`、`19e12a1a` |
| 2026-10-06 | `bf0d5136` | `bf0d5136`、`9f21c6e2`、`3041a784`、`930b9b4c` |
| 2026-10-07 | `89f0cff2`、`9a3ac792` | `08764bb6`、`9b43a249`、`f1d8a5f8`、`39360dd8`、`a4fa4984`、`25cb9ee5`、`4b4616fe` |
| 2026-10-08 | `3b8ac878`、`d7df92f7`、`221b2e3f`、`ad82f4e7`、`3e94d642`、`31064eab`、`faa5813f` | `4288b8fd`、`bb463e01`、`b9aff2d8`、`728d052f` |
| 2026-10-09 | `6504becb`、`bae1e99a`、`4b68cd2c` | `b3550c4f`、`624fad23`、`617c1363` |

本調査の終点`1b1505d3`より後の評価・観察記録commitは、この索引から除外した。

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
