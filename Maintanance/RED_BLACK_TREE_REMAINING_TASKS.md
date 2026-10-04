# RedBlackTree 残タスク

最終更新: 2026-10-04 / Codex

## 目的

RedBlackTreeCollectionsを「完成」と判断するまでに残っている作業を管理する。
テスト件数を増やすこと自体ではなく、公開設計を確定し、その契約を実装・テスト・文書で
同じ内容にすることを完了条件とする。

## 現在の判定

赤黒木アルゴリズムと4つの公開コンテナの基本的な正しさについては、完成判断に使える
証拠が揃っている。一方、公開`Index`の表現と契約が確定していないため、
RedBlackTreeCollections全体はまだ完成とはしない。

### 確認済みの根拠

- Set / MultiSet / Dictionary / MultiMapの参照モデル付きfuzz testと、各操作後の木の不変条件検査
- 4コンテナとRange Viewに対するIndex世代、CoW後のIndex寿命、範囲操作のテスト
- C++標準コンテナとの4組・35テストの挙動比較
  - macOS / LLVM libc++: Debug・Release成功
  - Linux / GNU libstdc++: Debug成功
- raw treeの専用テストターゲット、通常到達可能行のcoverage確認
- Debug寿命検査、境界Death Test、LinuxでのDeath Test実行実績

C++比較の詳細は`CPP_BEHAVIOR_COMPARISON_MATRIX.md`を正本とする。

## 外部契約と二種類の内部実装を分ける

Indexの検討では、利用者に見える契約と、その契約を実現・調査する内部機構を
同じ選択肢として扱わない。さらに内部機構を、外部へ波及し得るものと
実装内へ閉じるものに分ける。

### 外部契約

- `RedBlackTreeIndex`を`Comparable`へ適合させるか
- `==`と、採用する場合の`<`が何を意味するか
- 比較、移動、dereferenceの計算量
- staleなIndexを各公開APIがoptional、precondition failure等のどれで扱うか
- 利用者が「失敗状態を格納したIndex」を値として受け取る必要があるか

### 外部へ影響し得る内部実装

公開APIとして直接説明しなくても、利用者のコード、互換性、または他ライブラリへ
影響し得るため、外部契約を決めた後に慎重に選ぶ。

- public typealiasが露出する具体型。現状では`Result`がそのまま見える
- `RedBlackTreeIndex`を固有nominal型にするか
- `Comparable`等の適合と、特に標準型へのretroactive conformance
- `@frozen`型の保存プロパティ、サイズ、レイアウト
- `@inlinable`から参照され、利用側へ埋め込まれ得る処理
- Indexコピー・比較・dereferenceのRelease性能
- エラー状態をIndex値に含めることで生じるoverload resolutionやgeneric制約への影響

この層は便宜上「内部」と呼べても、自由に差し替えられる実装詳細とは扱わない。

### 外部へ影響させない内部実装

- 外部型のレイアウトから隠したノードポインタ、世代、tie、tracking tagの保持方法
- 検証・移動処理が`SealError`を`Result`で運ぶ方法
- 外部型から隠された内部tokenとresolved pointer
- Debug専用の失敗理由、assertion、調査用表示
- 公開契約へ変換する前の内部helperと制御フロー

`SealError`を伴う`Result`が内部調査に有用であることと、公開Indexそのものを
`Result`にすることは別問題である。内部の診断能力は、外部契約へ失敗状態を
露出せずに維持できる。

## 依存関係と実行順

重要度の一覧と着手順を混同しない。赤黒木完成までの主経路は次のとおり。

```text
A. 外部: RedBlackTreeCollectionsの公開面を監査
    ↓
B. 外部: 意図した公開・境界内部・TestCode・内部へ分類して縮小
    ↓
C. 外部: 既存の安全性・計算量契約を固定
    ↓
D. 外部: IndexのComparableが本当に必要かを判断
    ↓
E. 外部: 公開APIに失敗Indexが必要か判断
    ↓
F. Indexの外部契約を固定
    ↓
G. 境界内部: 外部へ波及する表現候補を導く
   ├─ 現行Result typealias
   ├─ 成功tokenだけのIndex
   └─ 失敗状態を隠蔽する固有nominal Index型
    ↓
H. 境界内部: 必要な候補だけ試作・Release計測
    ↓
I. 境界内部の表現を最終決定
    ↓
J. 閉じた内部: resolver・SealError・診断経路を実装
    ↓
K. 境界内部: Index表現とRange/Viewを実装・追従
    ↓
L. 回帰検証・文書同期・完成判定
```

境界内部の表現は、外部契約より先に固定しない。Comparable不要なら
retroactive conformance問題は消えるが、調査用の失敗状態を公開Indexへ残す妥当性は
別途判断する。Comparableが必要なら、標準`Result`へのretroactive conformanceを
避けられる表現だけをG以降の候補にする。

公開面監査では、外部所有型extensionに加えて、内部実装由来に見えるpublic宣言も扱う。
具体的には`SealError`、`Unsafe*`型、`_` / `__`接頭辞の型・typealias・member、
public typealiasが露出する具体型、public protocol適合を対象にする。

TestCode専用と確認できたfixture・実験経路は先にproduction targetから外せる。
ただし`Result: Comparable`はIndexのComparable採否に依存するため、分類だけ行い、
D〜Iの判断が済むまで最終処置を固定しない。

公開範囲の縮小はデッドコード判断より先に行う。未使用コードは外部へ見えなければ
後から削除できるが、意図しないpublic APIは利用者が現れた時点から変更コストを持つ。

一方、外部へ影響させないresolverの`Result`や`SealError`診断は、外部契約を変えずに
維持・改善できる。ただし境界内部の型を先に仮定して大量に作り込まず、Iの決定後に
Jで接続する。

未結線コードやテスト支持層の整理は主経路と並行できる。ただしIndex、Range、Viewに
触れる整理はJ・Kと競合するため、Iの設計確定まで開始しない。MSVC比較や大規模ベンチは
主経路の依存先ではなく、完成後にも実施できる追加検証である。

## 主経路: Indexの表現と契約の確定

これは赤黒木の完成を止める最優先タスクである。

現行の`RedBlackTreeIndex`は`UnsafeIndexV3`、さらに
`Result<_LazyTieWrap<_NodePtrSealing>, SealError>`の別名である。ノードのsealed pointer、
世代、ストレージの同一性・解放検出を組み合わせ、CoWで分岐した木ではtracking tagを
使って対応ノードを解決する。

この仕組みは既存テストを通過しているが、現在の表現を公開契約として確定するかは
別の判断である。少なくとも次を明文化して比較する。

### 外部契約の主論点: `Comparable`にするか

`Index`を`Comparable`へ適合させるかを決める。適合させる場合は、少なくとも次を
公開契約として説明できなければならない。

- `<`がコンテナ内の論理位置順を表すこと
- MultiSet / MultiMapの同値キーに属する別nodeも順序付けられること
- 異なる木に由来するIndex同士をどう扱うか
- `Equatable`との整合性
- 比較の計算量。特に同値キー間の位置比較はO(log N)になり得る
- 標準`Range`等から、反復ごとの比較によるO(N log N)経路が意図せず生じないこと

適合させない場合は、現在Comparableを期待しているコードまたは外部コンテナ設計との
関係を確認し、独自`IndexRange` / `IndexRangeExpression`で必要な操作を満たせるかを
確定する。

現状の`Comparable`実装はDebug構成に限定されている。これは調査用の状態であり、
公開仕様が確定した根拠にはしない。

特に、`Index`が標準ライブラリの`Result`のtypealiasである現状では、Indexだけを
`Comparable`にできない。`Result`へretroactiveな`Comparable`適合を追加すると、
RedBlackTreeのIndexに閉じず、条件を満たすすべての`Result`へ適合が見える。
これは1ライブラリの都合で標準型の意味を拡張し、他ライブラリまたは将来の
標準ライブラリによる同じ適合と衝突し得るため、正式な解決策にはしない。

### 外部境界の副論点: 失敗Indexを公開するか

現在はpublic typealiasにより、`Index`そのものが`Result<成功値, SealError>`である。
まず内部表現を考えず、利用者が失敗状態を格納したIndexを受け取る必要があるかを判断する。
この形を採った当初の主な理由は、失敗状態と原因をそのまま保持でき、実装の調査が
容易になると考えたためである。公開Indexが失敗値を保持する必要がある、という
API契約から導かれた設計ではない。したがって、調査上の利便性だけを恒久的な
公開表現の根拠にはしない。

1. 失敗状態をIndex本体に保持する
   - 移動や検証の失敗状態をIndex値として運べる
   - 失敗Indexが公開Indexの通常表現へ混在する
   - `Comparable` / `Hashable`の意味を`SealError`まで含めて定義する必要が生じる
2. 失敗状態をIndex本体から分離する
   - Indexは有効位置またはstaleになり得る位置の識別子へ絞られる
   - 移動・検証の失敗はAPI境界でoptional、`Result`、precondition等として返す
   - 現在Resultを直接伝播している内部経路の変更量とコード生成を確認する必要がある

### 外部へ影響し得る内部表現の選択

`RedBlackTreeIndex`を固有のnominal typeにするかは、外部契約を決めた後の表現上の判断である。
失敗状態を保持する場合にも分離する場合にも固有型を利用できる。

- `RedBlackTreeIndex`を固有型にする
   - 内部に成功値または失敗状態を保持しても、適合をIndex型だけへ限定できる
   - `Result`へretroactive conformanceを追加せず`Comparable`を実装できる
   - typealiasから固有型への移行コスト、公開レイアウト、inliningへの影響を確認する

`Result`の採否は、`Comparable`を採用した場合の比較規則を不自然にしないこと、
および不正pointerをdereference前に拒否できることを条件に決める。

有力な分離案は、Index本体には位置を識別するtokenだけを保持し、解決・検証を
`Result<ResolvedPointer, SealError>`として返す構造である。stale、recycled、detached等の
詳しい失敗理由は内部診断として維持できる一方、公開Indexが生成時から`.failure`である
状態を排除できる。移動失敗についても、内部では`Result`を保ち、公開API境界でoptional、
precondition failure等の契約へ変換する。

### 既存契約として維持するもの

今回の設計判断では、検証済みのCoW、世代、detach、Range/Viewの契約を一から
選び直すことを主目的にしない。ComparableまたはResult表現の変更に必要な範囲で、
既存契約を満たせるか確認する。

- stale / recycled / detachedなIndexをraw pointer参照前に拒否する
- CoWで分岐した木の対応要素へ、既存契約の範囲でIndexを解決する
- 親コンテナとRange ViewのIndex契約を一貫させる
- 通常の全走査と範囲走査をO(N)に保つ

### 主経路のチェックリスト

- [ ] A: 外部所有型extensionと、内部実装由来に見えるpublic宣言を列挙する
- [ ] `EXTERNAL_TYPE_EXTENSION_AUDIT.md`のRedBlackTreeCollections対象を確定する
- [ ] `SealError`、`Unsafe*`、`_` / `__`系public宣言とpublic typealiasを抽出する
- [ ] B: 意図した公開API、境界内部、TestCode専用、内部用途へ分類する
- [ ] source compatibilityを意図する公開API以外を、可能な範囲でpackage/internalへ縮小する
- [ ] TestCode専用の宣言と実験経路をproduction targetから分離する
- [ ] C: 外部へ保証する安全性・CoW・走査計算量の契約を確認する
- [ ] D: 外部APIでComparableが必要になる利用箇所と、非適合時の代替を確認する
- [ ] Comparableあり・なしの2案を比較し、必要APIと計算量を表にする
- [ ] E: 利用者へ失敗Indexを公開する必要があるか判断する
- [ ] F: Comparable採否、失敗時の公開API、計算量を外部契約として固定する
- [ ] G: 固定した外部契約から、typealias、固有Index型等の境界表現候補を導く
- [ ] 標準`Result`へのretroactive `Comparable`適合を正式案から除外する
- [ ] 調査用の`SealError`情報を、Index本体から分離しても維持できることを確認する
- [ ] H: 必要な境界表現候補だけ小さく試作し、比較・移動・dereferenceをRelease計測する
- [ ] I: 採用した境界表現と不採用案、その理由をDesign文書へ記録する
- [ ] J: 外部から隠すresolver、`SealError`、診断経路を採用表現へ接続する
- [ ] K: Index本体を実装し、4コンテナと両Range Viewへ追従させる
- [ ] L: テスト・DocC・API Matrixを採用案へ同期する

### Index完了ゲート

- [ ] Comparableの採否と理由が明記されている
- [ ] ResultをIndex本体に残すか、API境界へ分離するかが決まっている
- [ ] 標準型へのretroactive conformanceへ依存していない
- [ ] stale / recycled / detached / out-of-rangeを、確保外メモリへ触れる前に処理できる
- [ ] CoW前後の契約が4コンテナとViewで一貫している
- [ ] 採用する`==`、`<`、`hash(into:)`の意味と計算量が矛盾しない
- [ ] 通常の全走査と範囲走査が意図せずO(N log N)にならない
- [ ] Debugだけで成立する適合や検査を公開仕様の根拠にしない
- [ ] Index表現を変更した場合もC++比較・fuzz・不変条件検査が成功する

## Kで処理するIndex依存タスク

- [ ] `index(inserting:)`を4コンテナのどこまで提供するか確定する
- [ ] `erase(exactly:)`を4コンテナのどこまで提供するか確定する
- [ ] KeyValue Range Viewの値変更で、範囲外Indexを拒否する契約とテストを確定する
- [ ] cross-tree indexingのテストが公開契約と一致しているか再監査する
- [ ] eraseのrange sanitizeをすり抜ける入力に対するテストを追加する
- [ ] MultiMapの`unsafeAddress`利用経路をReleaseでも確認する

これらは現在のIndex表現を前提に先走って横展開しない。Index契約の決定によって
API名、戻り値、検査方法が変わり得る。

## 主経路と並行できる完成前の整理

- 公開面の監査・縮小は主経路A・Bで先に行う。この節のデッドコード判断を先行させない。
- [ ] 未結線コードを削除するか、用途を確定してテストを付ける
  - `_Reverse4`関連
  - iteratorの未接続API
  - `swap_key` / `swap_mapped_value`
  - `Message.outOfRange` / `keyMismatch`
  - BufferHeaderの`payloadLayout` / `__root_ptr()`
  - RawRangeの`contains(range:pointer:)`
  - `_TrackingTag.retire`
- [ ] `RedBlackTreeTestSupport`と`DebugAdditionals`の責務を整理する
- [ ] UnsafeNode / RawBufferのクロスチェックと単層テストの役割を記録する
- [ ] `Tests/TESTING.md`の古いC++比較件数と次作業の記述を更新する

## 完成を止めない追加検証

- MSVC STLとのC++挙動比較
- ランダム比較失敗時の自動縮小
- SortedCollectionsとの大規模性能比較
- Strict Memory Safetyの全面適用に向けたstorage再設計
- 並行アクセス時の`lazyDetach`等の一度だけの初期化保証
- Swift更新後のCoWコード生成の再計測

これらは重要だが、現時点では赤黒木の完成条件へ含めない。公開契約または安全性に
新しい問題が見つかった場合のみ主経路またはIndex依存タスクへ昇格する。

## 完成条件

RedBlackTreeCollectionsを完成と判断する条件は次のとおり。

1. 主経路A〜Lが完了し、意図した公開面とIndex契約について実装・テスト・文書が一致している。
2. Index依存APIと安全性境界が、そのIndex契約に基づいて確定している。
3. 公開範囲の縮小を終えた後、未結線コードについて残す理由または削除の判断が記録されている。
4. 4コンテナのfuzz・不変条件検査・C++比較に回帰がない。
5. 未完了の追加検証が、完成を止めない理由とともに明示されている。

## 関連文書

- `Tests/TESTING.md`
- `Tests/TESTING_REFERENCE.md`
- `Maintanance/CPP_BEHAVIOR_COMPARISON_MATRIX.md`
- `Maintanance/EXTERNAL_TYPE_EXTENSION_AUDIT.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-CopyOnWrite.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-MemorySafety.md`
- `Sources/RedBlackTreeCollections/Documentation/Design/Design-Range.md`
- `Sources/RedBlackTreeCollections/Documentation/API-Matrix.md`
