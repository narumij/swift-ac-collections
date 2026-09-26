# RedBlackTreeCollectionsの設計

## この文書の目的

この文書は、RedBlackTreeCollectionsの設計文書を読むための入口である。
個別の型やアルゴリズムを網羅するのではなく、この実装が何を成立させるために
作られているのか、各設計判断がどのようにつながっているのかを示す。

## この実装をどう捉えるか

改めて見ると、これは「赤黒木をSwiftで実装したもの」というより、
**赤黒木を値型コレクションとして成立させるためのストレージシステム**である。

赤黒木の検索・挿入・削除・平衡化は中核にある。しかし、それだけではSwiftの
コレクションとして次の性質を同時に満たせない。

- 値型としてコピーできること
- 変更前にはストレージ共有を安全に解消すること
- ノードのアドレスを使うIndexを扱えること
- 削除・再利用・CoWをまたいで、古いIndexを誤認しないこと
- 不要な確保、参照管理、探索をホットパスへ持ち込まないこと
- payloadを型に応じて正しく初期化・破棄すること

この実装の独自性は、平衡木アルゴリズムそのものよりも、ポインタベースの木を
Swiftの値セマンティクス、メモリ所有権、Indexの寿命の中で運用する仕組みにある。

## 三つの要求

設計の中心には、互いに緊張関係を持つ三つの要求がある。

~~~text
                    値セマンティクス
                  Copy on Writeによる分離
                         ▲
                        / \
                       /   \
                      /     \
                     /       \
          メモリ安全性 ◄──────► 実行性能
       世代・木・寿命の検証      raw pointerとpool
~~~

安全性を一律に厚くすると、木内部のホットパスへ検査と参照管理が増える。
性能だけを優先してraw pointerを外部へ出すと、削除、再利用、CoW、木の解放を
またぐIndexを安全に扱えない。単純なCoWは値セマンティクスを満たすが、
木全体の O(N) コピーとノードアドレスの変更を伴う。

RedBlackTreeCollectionsは、保証が必要になる境界を分け、それぞれの費用を
常時ではなく必要な場面で支払う。

## 設計判断のつながり

主要な仕組みは独立した最適化ではなく、同じノードストレージを介してつながっている。

~~~text
bucketによる一括確保
    │
    ├── 容量拡張ではbucketを追加
    │       └── 既存ノードのアドレスを維持
    │
    ├── 削除済みslotをRecycle Poolへ
    │       ├── payloadだけを破棄
    │       └── recycle countで世代を更新
    │
    ├── tracking tagでslotを識別
    │       └── CoW時に旧ノードと新ノードを対応付ける
    │
    └── CoWで単一bucketへ再配置
            ├── 値セマンティクスのためストレージを分離
            ├── 使用歴とRecycle Poolを再構築
            └── tagからノードへの問い合わせを O(1) に戻す
~~~

### ノードを個別に確保しない

ノードとpayloadはbucket内へ隣接配置される。通常の容量拡張では既存領域を
再確保せず、secondary bucketを追加する。これにより、すでに存在するノードの
アドレスを維持しながら容量を増やせる。

### 削除を領域の解放にしない

削除時にはpayloadを破棄するが、ノードslotはRecycle Poolへ送る。
次の挿入ではFresh PoolよりRecycle Poolを優先し、同じ領域を再利用する。

アドレスが同じでも、削除前と再利用後は別のノードである。recycle countを
世代として使うことで、古いIndexが新しいノードを指したように見えることを防ぐ。

### tracking tagを論理キーと分離する

tracking tagは要素の順序や検索には使わない。ノードslotの識別、CoW時の
ポインタ変換、診断と検証のために使う。

この分離により、木の論理構造を変えずに、物理ストレージ上の対応を追跡できる。

### CoWをストレージ正規化の機会にする

CoWは値セマンティクスのために必要な O(N) の処理である。この実装はコピーを
単なる負債で終わらせず、容量拡張によって複数に分かれたbucketを単一bucketへ
再配置する機会としても使う。

単一bucketではtracking tagを配列indexとして扱える。
_BucketAccessorは先頭アドレスへ stride * trackingTag を加えることで
対応ノードを直接求めるため、tagからノードへの問い合わせは O(1) になる。

つまりCoWは、共有ストレージを分離すると同時に、分散したメモリレイアウトを
単純化し、その後の問い合わせを安くする処理でもある。

### 安全性を段階的に付加する

木の所有下で即時に完結する処理はraw pointerを使う。ポインタがIndexとして
外部へ渡る境界では、必要な保証を段階的に追加する。

~~~text
raw pointer
    └── nodeの世代
        └── 所属する木の同一性
            └── 必要な場合だけraw memoryの寿命を延長
~~~

すべての内部操作へ同じ安全機構を被せるのではなく、時間差で削除、再利用、CoW、
木の解放が起こり得る境界に限定して費用を払う。

## 各層の役割

~~~text
公開コレクション
Set / Dictionary / MultiSet / MultiMap
        │
        ▼
UnsafeTreeV2
値型API、CoW、Index、Rangeとの接続
        │
        ▼
__tree
検索、挿入、削除、赤黒木の平衡化
        │
        ▼
Node Storage
bucket、node、payload、Fresh/Recycle Pool
        │
        ▼
Memory Safety
世代、木の同一性、遅延寿命管理
~~~

公開コレクションは木アルゴリズムやメモリ管理を直接実装しない。
UnsafeTreeV2がSwift側の値セマンティクスと低レベルの木を接続し、
UnsafeTreeV2BufferHeaderが木構造とallocator、pool、寿命管理の境界になる。

## 設計文書の案内

### [内部アーキテクチャ](Design-InternalArchitecture.md)

公開コレクション、UnsafeTreeV2、libc++由来の __tree、
ノードストレージの層と依存方向を説明する。

### [ノードストレージの設計](Design-NodeStorage.md)

primary/secondary bucket、UnsafeNode + Payloadのレイアウト、
Fresh Pool、Recycle Pool、特殊ノード、容量拡張、CoW時の再配置を説明する。
この実装の物理的な土台を扱う。

### [メモリレイアウトの設計](Design-MemoryLayout.md)

NodeとPayloadからslotのstrideを求める方法、alignmentを満たす開始位置、
primary/secondary bucketの確保量、初期化状態との境界を説明する。

### [Copy on Writeの設計](Design-CopyOnWrite.md)

ストレージ共有、一意性確認、木全体の再構築、tracking tagによるリンク変換、
コピー先へ持ち越さない状態を説明する。

### [メモリ安全性の設計](Design-MemorySafety.md)

削除と再利用の検出、Indexと木の同一性、木より長く残るIndexのための
遅延寿命管理、失敗の表現を説明する。

### [RangeとIndex反復の設計](Design-Range.md)

標準Rangeの比較コスト、代替Range、反復方法の検討を扱う。
この領域は実験中の設計を含むため、確定したストレージ設計とは区別して読む。

## 推奨する読み順

1. このOverviewで設計上の問題と仕組みのつながりを把握する。
2. Design-NodeStorage.mdで物理レイアウトとノードのライフサイクルを確認する。
3. Design-MemoryLayout.mdでアドレス計算とalignmentの契約を確認する。
4. Design-CopyOnWrite.mdで値型としての分離方法を確認する。
5. Design-MemorySafety.mdでIndexへ追加される保証を確認する。
6. Design-InternalArchitecture.mdでコード上の各層へ対応付ける。
7. Rangeなど実験中の領域は、必要に応じて個別文書を読む。

## この設計の性格

この実装では、局所的には特殊に見える処理が多い。

- rootをend nodeの左リンクへ置く
- begin nodeを別に保持する
- optional pointerではなく実体のあるnullptrを使う
- 削除済みノードの左リンクをfree listへ転用する
- CoWで有効要素だけでなく使用歴のあるslotまでコピーする
- Indexが残る場合だけbucketの解放責任を移譲する

これらは単独では理解しにくいが、ストレージ、CoW、Index安全性を同時に成立させる
という観点では相互に理由がある。

したがって変更時には、目の前の処理だけを単純化するのではなく、その状態が
どの層から参照され、どの計算量や安全性を支えているかを確認する必要がある。

## まとめ

RedBlackTreeCollectionsの中心的な問いは、
「赤黒木をどう実装するか」だけではない。

**ポインタベースの木を、Swiftの値セマンティクスとIndexの寿命の中で、
余分なコストを常時払わずにどう運用するか**である。

bucket、二つのpool、tracking tag、世代管理、CoW時の再配置、遅延寿命管理は、
この問いに対する一続きの回答になっている。
