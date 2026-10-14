# Task Registry一般状態とtask分解の使用履歴

## この文書の段階

この文書は、Task Registryで多用された`ACTIVE`、`FROZEN`、`WAITING_USER`、`DONE`が、task分解と
依存関係の形成にどう使われたかをGit履歴から調べる作業記録である。現行運用を定める正本ではない。

調査範囲は、Task Registry導入commit `e4aa207d`から、commit `5c88335d`
（`best codex was gone`）直前の`1b1505d3`までとする。希少状態は
`TASK_REGISTRY_RARE_STATE_USAGE.md`で別に扱う。

## 一時SQLite projection

`Maintanance/PROGRESS_OVERVIEW.md`を変更した172 commitについて、各commit時点のTask Registryと
Task precedenceをGitから復元し、追跡対象外の一時SQLite databaseへ投入した。

| table | 内容 | 件数 |
| --- | --- | ---: |
| `commits` | 対象commitの時系列 | 172 |
| `task_snapshots` | commitごとのtask行 | 14,982 |
| `precedence_snapshots` | commitごとの依存辺 | 9,540 |

snapshotに現れたtaskは201件である。databaseは履歴を照会するための一時projectionであり、Task Registryや
本調査文書に代わる正本ではない。

初期のTask precedence表は`Flow`列を持たず、後からGate、さらに`SEQUENCE`／`PARALLEL_JOIN`へ変化した。
このため現段階では、辺の有無と向きは使うが、全期間の第3列を同じ`Flow`として比較しない。

## 初出時の状態

201 taskがRegistryへ最初に現れたときの状態は次のとおりだった。

| 初期状態 | task数 |
| --- | ---: |
| `FROZEN` | 81 |
| `ACTIVE` | 72 |
| `DONE` | 24 |
| `WAITING_USER` | 11 |
| `EXCLUDED` | 9 |
| `WAITING_EXTERNAL` | 2 |
| `USER_ONLY` | 1 |
| `PROPOSED` | 1 |

`FROZEN`が最多なのは、停止事象が81回起きたという意味ではない。まだ着手しない後続、条件付きbranch、
合流点、明示的再開待ちを、分解時に先に採番して保持したtaskが多く含まれる。

## 同時追加されたtask群

同じcommitで3件以上のtaskが初出した群を抽出すると、Registry導入時の移行分を除いて23群あった。
commit件名にも`Split`、`Decompose`、`Plan`、`Assign`、`Register`、`Queue`などが現れ、個別taskの偶然の
同時追加ではなく、作業を構造化した痕跡として読める。

代表例を時系列で示す。

| Commit | 追加された構造 | task数 | 同時に初出した依存辺 |
| --- | --- | ---: | ---: |
| `dc5c7572` | Permutation互換作業とgraph smell調査 | 9 | 10 |
| `fee7223a` | Permutation／RedBlackTree文書準備 | 8 | 3 |
| `d4027ff0` | BareArray監査graph | 6 | 8 |
| `a2cf88a6` | OptionalArray監査の受入構造 | 7 | 8 |
| `a58a29d1` | OptionalArray証拠収集の独立task | 10 | 10 |
| `0877d80f` | task適性表の独立review・統合・条件付き判断 | 4 | 4 |
| `15c8f965` | Permutation文書証拠と引き渡し | 4 | 4 |
| `c91a6ff4` | RedBlackTree文書証拠と統合 | 3 | 3 |
| `1812f1ce` | OptionalArrayのユーザー判断 | 4 | 4 |
| `a31dbcb3` | retrospective replay fixture群 | 5 | 11 |
| `24aa7107` | OptionalArray仕様test編成 | 3 | 5 |
| `fc67a29f` | OptionalArray品質証拠の並行reviewと統合 | 4 | 7 |
| `0295b5cc` | precedence gateの段階移行 | 4 | 4 |
| `0b08e523` | precedence gate判断の分割 | 8 | 8 |
| `98e249a0` | BareArray公開API監査の後続 | 3 | 7 |
| `8fd4d06d` | Array系命名reviewと後続判断 | 4 | 3 |
| `0a878245` | release templateの内容別task | 6 | 6 |

### task群と辺は初期から同時に作られた

`dc5c7572`では、Permutation互換作業が`PERM-003`〜`PERM-010`へ分かれ、先頭以外は`FROZEN`で
登録された。同じcommitで、直列部分、分岐部分、最後の合流を表す10辺も加わった。

後の`a58a29d1`では、10件の独立した`ACTIVE`証拠taskが追加され、その10件から二つの既存監査taskへ
合流する10辺も同時に加わった。`0b08e523`では、一つずつ判断する8 taskを直列化するのではなく、8件を
親判断の前提として並べる8辺が加わった。

少なくともTask Registry導入初期から、分解はtaskの列挙だけではなく、実行順、分岐、合流を含むgraphとして
記録されていた。後に変化したのは、辺の存在そのものではなく、Gateや`SEQUENCE`／`PARALLEL_JOIN`で
依存の意味を区別する表現である。その表現変化と分解方法の関係は、後続の履歴照合で重ねる。

### 辺の意味表現の変化

SQLite上で、各辺の第3列に現れた語の初出を追うと次の順だった。

| Commit | 表現 | 意味上の変化 |
| --- | --- | --- |
| `19ce8b5f` | Flow列なし | 前提taskと制約文で必須順序を記録 |
| `b617682b` | `START`／`COMPLETE`／`UNCLASSIFIED` | 着手前提と完了前提をGateとして分離し、未分類を推測で埋めない |
| `3bed5e60` | `HEAD`／`LAST` | 同期障壁の位置として名称を変更 |
| `8b47a1a6` | `SEQUENCE`／`PARALLEL_JOIN` | 実行flowとして直列と並行後の合流を表現 |

これは状態の追加ではなく、同じtask群をどの順序と合流条件で成立させるかという、分解後の関係表現が
段階的に改訂された履歴である。

## `ACTIVE`の使用

`ACTIVE`で初出した72 taskのうち、59件は最初の状態変更で`DONE`へ進んだ。ほかは`FROZEN`が3件、
`EXCLUDED`が3件、`WAITING_EXTERNAL`が2件だった。

初出時の依存graph上の位置は一様ではなかった。

| 初出時の位置 | task数 |
| --- | ---: |
| 他taskの前提になる葉または中間task | 43 |
| 前提を持ち、後続の前提にもなる中間task | 16 |
| 前提だけを持つ合流・終端task | 6 |
| 明示辺を持たないtask | 7 |

したがって`ACTIVE`は「いま一つだけ実行中」を表す状態ではなく、依存上着手可能な複数の葉や中間taskを
同時に表すためにも使われていた。

## `FROZEN`の使用

`FROZEN`で初出した81 taskのうち、基準点までに最初に離脱した先は次のとおりだった。

| 最初の離脱先 | task数 |
| --- | ---: |
| `DONE` | 17 |
| `ACTIVE` | 15 |
| `WAITING_USER` | 12 |
| `EXCLUDED` | 2 |
| `WAITING_EXTERNAL` | 1 |

残りは基準点まで`FROZEN`から離脱していない。

この分布から、`FROZEN`には少なくとも異なる二つの使い方が共存していたことが分かる。

- 明示的な再開、外部条件、将来phase、または実害の発生を待つ長期保留。
- 分解時に先に採番され、前提成立後に`ACTIVE`、`WAITING_USER`、または直接`DONE`へ進む後続task。

初出時に明示的なprecedence辺を持たない`FROZEN` taskは39件だった。Task Registry導入時からある長期保留、
単独の明示的再開待ち、条件を文章だけで持つtaskが含まれる。辺がないことだけをもって、依存がなかった、
またはすべて同じ種類のユーザー停止だったとは判定できない。

## `WAITING_USER`の使用

`WAITING_USER`で初出した11 taskのうち、6件は他taskの前提、2件は前提を持ちながら後続も止める中間点、
3件は初出時に明示辺を持たなかった。基準点までに最初に離脱したものは、7件が`DONE`、2件が
`WAITING_EXTERNAL`だった。

OptionalArrayの判断4件、0.5.0到達範囲、BareArray公開API判断など、分解で分離されたユーザー判断点が
割り当てられている。後続を止める辺と同時に登録された例では、「ユーザーへ聞くこと」と「その結論を
必要とする後続」が別taskとして表現されていた。

一方、`FROZEN → WAITING_USER`も14回確認されている。これは、後続候補として先に保持されていたtaskが、
前提整理後に実際のユーザー判断点として表面化した例を含む。`WAITING_USER`を単なる作業停滞とみなすと、
この分解上の役割を失う。

## `DONE`の使用

`DONE`で初出した24 taskには、Registryへ登録する以前に完了済みだった成果と、分解commitで既に成立済みと
整理された前提taskが含まれる。たとえばrelease template内容の6件は、`0a878245`で6 taskと6辺へ
分解された時点からすべて`DONE`だった。

また、基準点までに`ACTIVE → DONE`が76回、`FROZEN → DONE`が17回、`WAITING_USER → DONE`が11回、
`WAITING_EXTERNAL → DONE`が4回確認されている。`DONE`は単に実装が終わった状態ではなく、調査、判断、
証拠受入、外部結果確認など、それぞれのtask境界が閉じた終端として使われていた。

## 現段階で見える分解の形

履歴から、少なくとも次の分解形が反復して現れる。

1. 親taskを、独立に観測できる証拠taskへ分け、親または統合taskへ合流させる。
2. 調査taskの後ろに、必要な場合だけ表面化する判断taskを置く。
3. 判断taskと、その結論だけを実装するtaskを分ける。
4. 複数の並行成果を、引き渡しまたは完成判定taskへ合流させる。
5. 将来必要になり得る後続を`FROZEN`で先に採番し、前提成立後に状態を変える。
6. 調査で前提が崩れた系列を`EXCLUDED`へ閉じ、誤った分解の痕跡も残す。

この一覧は、分解を正当化する規則を後から当てはめたものではない。まずGit snapshotから同時追加、状態、
依存辺、離脱先を抽出し、その反復形を記述した段階である。各形が意図的な設計だったか、会話から偶然
形成されたか、後から採用された原則とどこまで対応するかは、次の履歴照合で重ねる。

## 状態遷移に現れない整理

連続するRegistry snapshot間で、task行が状態変更なしに消えたcommitも抽出した。

### 完了履歴の圧縮

`7ead1703`では、`DONE` 105件と`EXCLUDED` 15件が現行Registryから一括で外れ、完了履歴へ移された。
これはtaskの消滅ではなく、現行Registryを圧縮する`ARCHIVED`相当の操作として区別できる。

### 分解後の吸収・終了・枝刈り

一括アーカイブ後には、別の理由で行を直接外す操作が続いた。

| Commit | 外れたtask | 直前状態 | commitに記録された扱い |
| --- | --- | --- | --- |
| `97d8d004` | `PERM-008`、`RELEASE-004` | `FROZEN` | compatibility branch統合taskを終了 |
| `ec0a4e25` | `GRAPH-005` | `ACTIVE` | graph DB交流taskを終了 |
| `cf8a5dea` | `GRAPH-002`、`GRAPH-004`、`GRAPH-017`、`GRAPH-018` | `ACTIVE`／`FROZEN` | Codex側graph DB実験を終了 |
| `1a4f9878` | `OPT-003`、`OPT-004` | `FROZEN` | 委譲規則へ吸収されたtaskを終了 |
| `ea7b42f4`〜`ec5ef8c9` | `OPS-012`、`OPS-016`〜`OPS-023`、`OPS-013` | `WAITING_USER` | 一時的な判断・分類taskを一件ずつ閉じる |
| `bc3a092f` | `OPS-014` | `WAITING_USER` | 条件付きtask保持方針の決定後に閉じる |
| `e5ebc35a` | `OPS-015` | `FROZEN` | 一時的な低燃費運用を終了 |
| `afeb3ee0` | `BENCH-001`、`EVAL-001`、`PERF-001`、`RBT-006`、`TEST-001`〜`TEST-004` | `FROZEN` | speculative frozen taskを整理 |

これらは`DONE`または`EXCLUDED`への状態遷移としては数えられない。分解した断片が別の規則や成果へ
吸収された場合、移行のためだけに作った判断taskが役目を終えた場合、将来候補を枝刈りした場合に、行と
関連辺をRegistryから直接除去していた。

したがって、状態遷移だけからtask分解の履歴を復元すると、インライン化、責務吸収、一時taskの終了を
取り落とす。commit差分、行消失、依存辺の消失を併せて見る必要がある。

### `BARE-008`のID再利用

行消失後に同じIDが再登場した例は、基準点までに`BARE-008`の1件だけ確認できた。

1. `d23cf6a8`で、`[DECISION] BareArray監査を再開するか`として追加された。
2. `3c3a4103`でRegistryから外れた。
3. 28回目のRegistry更新に当たる`45d6d27b`で、`[DISCOVERY] BareArray品質評価初版`という別taskとして
   同じIDが再登場した。

これは同じtaskの再開ではなく、項目と役割が異なるID再利用である。現在のstable ID規則との関係や、
この事例が後の規則化を直接引き起こしたかは、Git記録だけでは確定しない。
