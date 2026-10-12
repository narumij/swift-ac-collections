# Task Registry希少状態の使用履歴

## この文書の段階

この文書は、Task Registryで使用回数の少なかった状態が、実際にどのtaskへ、どのような経路で
割り当てられたかをGit履歴から確認する作業記録である。現行運用を定める正本ではない。

調査範囲は、Task Registry導入commit `e4aa207d`から、commit `5c88335d`
（`best codex was gone`）直前の`1b1505d3`までとする。この範囲で
`Maintanance/PROGRESS_OVERVIEW.md`を変更した172 commitのsnapshotを比較した。

`ARCHIVED`は、状態を行へ割り当てる代わりに完了行を履歴fileへ移す圧縮として使われていたため、
この調査の対象外とする。多用された`ACTIVE`、`FROZEN`、`DONE`も後回しとし、次の4状態を扱う。

| 状態 | 一度でも割り当てられたtask数 |
| --- | ---: |
| `PROPOSED` | 1 |
| `USER_ONLY` | 1 |
| `WAITING_EXTERNAL` | 7 |
| `EXCLUDED` | 15 |

## `PROPOSED`

### 使用task

| Task | 項目 | 割当commit | 離脱commit | 遷移 |
| --- | --- | --- | --- | --- |
| `GRAPH-009` | 受入済み過去graph知見のSQLite追試fixture化 | `ce97783d` | `a31dbcb3` | `PROPOSED → ACTIVE` |

### 実際の使用

`bb77fafc`で`PROPOSED`が状態集合とportable templateへ追加された時点では、現行Registryに
`PROPOSED`行はなかった。

次の`ce97783d`で`GRAPH-009`が登録された。再開・完了条件には、前提task `GRAPH-008`の後、Codexが
対象、期待結果、schema変更範囲、完了条件を確定して状態を更新するまで着手しないと記載された。

`a31dbcb3`で対象が5個の独立fixtureと完成判定へ分解され、`GRAPH-009`は`ACTIVE`へ移った。
`eea212a2`でfixture群と完成判定が受け入れられ、`DONE`へ移った。

確認できる経路は次の1件だけである。

```text
PROPOSED
  scope・期待結果・schema変更範囲・完了条件が未確定
      ↓ 分解と依存の確定
ACTIVE
      ↓ fixture受入と完成判定
DONE
```

基準点までの実績では、`PROPOSED`は未着手task一般ではなく、具体化前の候補を一時的に保持するために
一度だけ使われた。

## `USER_ONLY`

### 使用task

| Task | 項目 | 割当commit | 基準点での状態 |
| --- | --- | --- | --- |
| `PERM-002` | ABC328E実提出確認 | `e4aa207d` | `USER_ONLY`のまま |

### 状態名より前に作られた境界

`USER_ONLY`という状態名はTask Registry導入時に現れたが、責任境界は直前の二commitで先に作られた。

- `50273dfe`: ABC328E実提出確認をPermutation互換modeから分離し、「ユーザーが手作業で行う専任項目。
  AIは着手・代行・催促しない」と記録した。
- `60ded377`: 同項目を`判断待ち`から`中止・再開禁止`へ移した。
- `e4aa207d`: 永続ID `PERM-002`を与え、`USER_ONLY`として登録した。

この状態は基準点まで別状態へ移らなかった。実績上は、ユーザー操作が必要というだけでなく、AIによる
開始、代行、催促を明示的に禁止する単独の所有権境界として使われた。

## `WAITING_EXTERNAL`

### 使用task

| Task | 項目 | 入ったcommit | 直前状態 | 出たcommit | 遷移先 |
| --- | --- | --- | --- | --- | --- |
| `RBT-001` | Index完了ゲート | `19ce8b5f` | `WAITING_USER` | — | 基準点でも`WAITING_EXTERNAL` |
| `RBT-002` | Index-range `erase`の空guard | `19ce8b5f` | `WAITING_USER` | `149d8b8c` | `DONE` |
| `RBT-010` | Index完了ゲートのうち公開Index表現と完了範囲 | `19ce8b5f` | 新規 | — | 基準点でも`WAITING_EXTERNAL` |
| `RBT-011` | Indexの`Comparable`採否 | `19ce8b5f` | 新規 | — | 基準点でも`WAITING_EXTERNAL` |
| `RBT-003` | `Result`比較overloadと`_NodePtr` | `149d8b8c` | `FROZEN` | `ac9fb91e` | `DONE` |
| `BARE-012` | BareArray命名体系のAI間検討 | `f5257504` | `ACTIVE` | `1710f3e6` | `DONE` |
| `OPT-043` | OptionalArray命名体系のAI間再検討 | `f5257504` | `ACTIVE` | `1710f3e6` | `DONE` |

### 使用形態1: 外部仕様の安定待ち

`19ce8b5f`で`WAITING_EXTERNAL`が追加された。`swift-collections` ContainersPreviewの
`Container.Index`要件を現在の律速とし、ユーザー判断では解消できないことが明記された。

それまで`WAITING_USER`だった`RBT-001`と`RBT-002`が`WAITING_EXTERNAL`へ変更され、同じ外部要件に
関係する`RBT-010`と`RBT-011`も同状態で登録された。

### 使用形態2: 外部CI結果待ち

`149d8b8c`で`RBT-003`は`FROZEN`から`WAITING_EXTERNAL`へ移った。実装、4構成build、通常testは完了し、
performance jobの成功だけを待つ状態だった。`ac9fb91e`でjob成功を確認し、`DONE`へ移った。

同じcommitで`RBT-002`は、外部要件全体の安定を待たず、範囲検査維持と不要なCoW回避の実装・検証を
受け入れて`DONE`へ移った。このため、状態名が同じでも各taskの離脱条件は個別だった。

### 使用形態3: 第三者AIの回答待ち

`f5257504`で`BARE-012`と`OPT-043`は`ACTIVE`から`WAITING_EXTERNAL`へ移った。Claude初稿とCodex予備評価の
後、第三者AIへ補完調査を依頼し、その回答を待つ状態として使われた。

`1710f3e6`で回答の独立評価と統合が受け入れられ、両taskは`DONE`へ移った。

基準点までの実績では、`WAITING_EXTERNAL`は次の三種類に使われている。

- repository外の仕様安定待ち。
- remote CIなど、repository外で進行する検証結果待ち。
- 第三者AIなど、外部担当からの成果待ち。

## `EXCLUDED`

### 使用task

| Task | 項目 | `EXCLUDED`になったcommit | 直前状態 |
| --- | --- | --- | --- |
| `CPP-002` | MSVC STLとのC++挙動比較 | `e4aa207d` | Registry導入時から |
| `GRAPH-003` | 二つのtask graph DBの統合議論 | `39360dd8` | `FROZEN` |
| `RBT-016` | `RedBlackTreePair.tuple`の仕様test | `654c7f75` | `ACTIVE` |
| `RBT-017` | Mapped Values Range View範囲外更新防止 | `9390433f` | `ACTIVE` |
| `RBT-018` | Mapped Values ViewのIndex検査条件調査 | `9390433f` | 新規 |
| `RBT-019` | 全体Mapped Values Viewの範囲検査判断 | `9390433f` | 新規 |
| `RBT-020` | 部分Mapped Values Viewの更新計算量判断 | `9390433f` | 新規 |
| `RBT-021` | 範囲外停止メッセージ判断 | `9390433f` | 新規 |
| `RBT-022` | getterの範囲検査判断 | `9390433f` | 新規 |
| `RBT-023` | 範囲判定helperのinline境界判断 | `9390433f` | 新規 |
| `RBT-024` | 範囲検査の実装と機能検証 | `9390433f` | 新規 |
| `RBT-025` | 範囲検査の性能確認 | `9390433f` | 新規 |
| `PERM-019` | 利用者向けPermutation使用例の仕様test化 | `9390433f` | `ACTIVE` |
| `FIT-004` | agent task適性表の不一致decision登録 | `2423ba1f` | `FROZEN` |
| `PERM-005` | Permutation互換traitのPackage設定 | `81dc5681` | `DONE` |

### 使用形態1: 最初から実施対象外

`CPP-002`はRegistry導入時から`EXCLUDED`だった。MSVC STLとの比較を現行計画では実施しないという
ユーザー決定を、再開候補にしない形で保持した。

### 使用形態2: 方針をdrop

`GRAPH-003`は、二つのtask graph DBを統合する将来判断として`FROZEN`で保持されていた。
`39360dd8`で統合方針をdropし、exchange taskへ置き換えたため`EXCLUDED`へ移った。同時に、同taskへ
向かうprecedence辺も削除された。

### 使用形態3: 調査で不要と判明

`RBT-016`は公開仕様testを追加する`ACTIVE` taskだった。調査の結果、対象型全体がdocumentation上
internalであり、公開仕様testは不要と確認されて`EXCLUDED`へ移った。

`FIT-004`は、レビューで実質的不一致が残った場合だけdecision taskを登録する条件付きtaskだった。
実質的不一致がなかったため、登録作業自体が不要となり`EXCLUDED`へ移った。

### 使用形態4: 前提誤りから派生した系列全体を閉じる

`9390433f`では、Mapped Values Viewへ追加の範囲検査が必要という前提を撤回した。既存のAPI Matrix、
仕様test、O(1)契約が見落とされていたためである。

その結果、進行中だった`RBT-017`を`ACTIVE → EXCLUDED`とし、そこから派生する調査、判断、実装、性能確認の
`RBT-018`〜`RBT-025`を新規登録と同時に`EXCLUDED`として記録した。

ここでは、誤った前提から見えていたtaskを単に消さず、なぜ不要だったかをID付きで保存する用途に
`EXCLUDED`が使われた。

### 使用形態5: 責務を別フェーズへ移す

`PERM-019`は利用者向け使用例を先に仕様test化する`ACTIVE` taskだった。使用例の選定は利用者向け文書作業
そのものへ移したため、独立taskとしては`EXCLUDED`になった。

### 使用形態6: 完了後の方針撤回

`PERM-005`は互換traitの設定と検証を終えて一度`DONE`になった。その後`81dc5681`で、0.5.0は通常版だけを
公開し、互換切替をbranch defineで扱う方針へ変わったため`DONE → EXCLUDED`となった。

`EXCLUDED`は、失敗または未着手を一種類にまとめる状態ではなかった。基準点までに、少なくとも次を
保存するために使われている。

- 最初から実施しないと決めた作業。
- 採用しない方針。
- 調査によって不要と判明した作業。
- 誤った前提から派生したtask系列。
- 別フェーズや別taskへ責務を移した独立task。
- 一度完了したが、後の方針変更で採用しなくなった成果。

## ここまでで見えること

希少状態は、通常の実行進捗を細かく表すためではなく、通常経路から外れる責任境界や履歴を失わないために
使われていた。

- `PROPOSED`: taskとして成立する前の候補。
- `USER_ONLY`: AIへ委任されない人間専任領域。
- `WAITING_EXTERNAL`: repository内の作業では解消できない待機。
- `EXCLUDED`: 実施・採用しない理由を残す終端。

これは現時点の証拠から得られる暫定整理であり、各状態を現行運用へ残すべきだという結論ではない。
