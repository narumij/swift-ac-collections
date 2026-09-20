# ノードストレージの設計

## この文書の目的

RedBlackTreeCollectionsは、赤黒木の各ノードを個別に確保せず、複数のノードを
bucketへまとめて確保する。ノード本体とpayloadの配置、特殊ノード、未使用領域、
削除済み領域は同じストレージ設計の上に成り立っている。

この文書では、現行の `UnsafeTreeV2BufferHeader`、`_BucketAllocator`、
`FreshPool`、`RecyclePool` が構成するメモリレイアウトとノードの
ライフサイクルを記録する。Indexの検証と遅延寿命管理は
`Design-MemorySafety.md`、ストレージ共有と複製は
`Design-CopyOnWrite.md` を参照する。

## 設計の要点

- 木の管理状態は `UnsafeTreeV2BufferHeader` に置き、ノード領域は別に確保した
  bucket群が所有する。
- 先頭bucketだけが `begin_ptr` とend nodeを持つ。
- 通常ノードは `UnsafeNode` とpayloadを一組として隣接配置する。
- 未使用slotはFresh Pool、削除済みslotはRecycle Poolとして管理する。
- 削除時にはpayloadだけを破棄し、ノード領域は次の挿入へ再利用する。
- 通常の容量拡張では既存ノードを移動せず、bucketを末尾へ追加する。
- CoWではtracking tagによる対応を保ちながら、新しい単一bucketへノードを再構築する。

## 所有構造

`UnsafeTreeV2` は `ManagedBufferPointer` を通じて
`UnsafeTreeV2Buffer` を所有する。ManagedBufferのheaderに
`UnsafeTreeV2BufferHeader` が入り、headerがbucket chainの先頭と末尾、
各poolの状態を保持する。

```text
UnsafeTreeV2<Base>
└── ManagedBufferPointer
    └── UnsafeTreeV2Buffer
        └── UnsafeTreeV2BufferHeader
            ├── freshBucketHead ──► primary bucket ──► secondary bucket ──► ...
            ├── freshBucketLast
            ├── freshBucketCurrent
            ├── recycleHead
            ├── begin_ptr
            ├── root_ptr
            └── allocator / counts / lifetime-management references
```

bucketはManagedBufferのtail storageではなく、`_BucketAllocator` が確保する
独立したraw memoryである。この分離により、容量拡張時にManagedBufferや既存ノードを
移動せず、新しいbucketをchainへ追加できる。

## bucketのメモリレイアウト

### Primary bucket

先頭bucketだけは、通常ノード領域の前に `begin_ptr` とend nodeを持つ。

```text
┌─────────┬───────────┬──────────┬─────────┬──────────────────────┐
│ _Bucket │ begin_ptr │ end node │ padding │ element slots ...    │
└─────────┴───────────┴──────────┴─────────┴──────────────────────┘
              │           │
              │           └── __left_ がrootを保持する
              └── 最小ノード、空ならend nodeを指す
```

`root_ptr` は独立したroot格納領域ではなく、end nodeの `__left_` を指す。
したがって空の木では次の関係になる。

```text
begin_ptr.pointee == end_ptr
end_ptr.pointee.__left_ == nullptr
```

primary bucketはcapacityが0でも作成できる。この場合も木を表現するための
`begin_ptr` とend nodeは存在し、通常ノードslotだけが存在しない。

### Secondary bucket

追加bucketは管理headerと通常ノードslotだけを持つ。

```text
┌─────────┬─────────┬──────────────────────────────────────────────┐
│ _Bucket │ padding │ element slots ...                            │
└─────────┴─────────┴──────────────────────────────────────────────┘
```

各 `_Bucket` は次のbucketへのポインタ、capacity、使用済みslot数を持つ。
特殊ノードはprimary bucketに一組だけ存在し、追加bucketには複製しない。

## element slotのレイアウト

通常ノードslotは、木構造のmetadataを持つ `UnsafeNode` と、コレクション固有の
payloadを隣接配置する。

```text
element slot
┌────────────┬──────────────────┐
│ UnsafeNode │ PayloadValue     │
└────────────┴──────────────────┘
^ node ptr   ^ p.advanced(by: 1)
```

Set系ではpayloadがキーそのものであり、Dictionary系では
`RedBlackTreePair<Key, Value>` である。木アルゴリズムはnode pointerを扱い、
payloadへのアクセスは常にノード直後の領域を使う。

この配置には次の外部不変条件がある。

- payloadは `p.advanced(by: 1)` に置かれる。
- payloadの開始位置はpayload型のalignmentを満たす。
- 連続するslotの間隔は `UnsafeNode + PayloadValue` のpair strideに従う。
- `UnsafeNode` 自身はpaddingやpayload型を知らない。
- `UnsafeNode` のサイズまたは配置を変える場合、allocator側も同時に更新する。

payloadのalignmentが `UnsafeNode` より大きい場合、allocatorは最初の
`UnsafeNode` の前へpaddingを入れる。ノードの直後をpayload位置として維持するため、
paddingはNodeとPayloadの間ではなく、slot列の開始位置に置かれる。

## `UnsafeNode` が保持する情報

通常ノードは概念上、次の情報を持つ。

- 左、右、親へのポインタ
- 赤黒木の色
- tracking tag
- recycle count
- payloadが初期化済みかを示す `___has_payload_content`

tracking tagはキーや並び順の一部ではない。Fresh Poolから初めて取り出した順に
0から割り当てられ、CoW時のポインタ再構築、診断、構造検証に使われる。

recycle countは同じslotが削除・再利用された世代を区別する。これを使った
Indexの検証については `Design-MemorySafety.md` で扱う。

## 特殊ノード

### nullptr

子や親が存在しない状態にはSwiftのoptional pointerではなく、共有された
`UnsafeNode.nullptr` を使う。通常ノードとは別に確保されたsingletonであり、
tracking tagには特殊値 `.nullptr` が設定される。

### end node

end nodeはprimary bucket内にあり、tracking tagには `.end` が設定される。
payloadを持たず、その左リンクをroot格納場所として兼用する。

### begin pointer

`begin_ptr` はノードではなく、ノードポインタを格納する専用slotである。
木が空でなければ最小ノードを、空ならend nodeを指す。最小要素へのアクセスのたびに
rootから左端を探索し直さないため、変更操作でこの値を維持する。

```text
                    end node
                   /
              root
             /    \
          ...      ...
         /
begin_ptr ──► minimum node
```

## 二つのpool

確保済みslotは、まだノードとして使われたことがない領域と、削除後に再利用できる
領域を区別して管理する。

```text
                    bucket chain
                         │
          ┌──────────────┴──────────────┐
          │                             │
     Fresh Pool                    initialized history
   未使用raw slots                       │
                                  ┌──────┴──────┐
                                  │             │
                              live nodes   Recycle Pool
                                           payloadなし
```

### Fresh Pool

Fresh Poolは各bucketの未使用slotを先頭から供給する。slotを初めて取り出すときに
`UnsafeNode` を初期化し、`freshPoolUsedCount` に対応するtracking tagを
割り当てる。

現在のbucketを使い切ると次のbucketへ進む。容量拡張は新しいbucketをchainの末尾へ
追加するため、既存ノードのアドレスは変わらない。

### Recycle Pool

ノードの削除時には次の処理を行う。

1. 有効要素数を減らす。
2. recycle countを進め、古いsealed pointerの世代を無効にする。
3. payloadをdeinitializeする。
4. `___has_payload_content` をfalseにする。
5. ノードの左リンクを単方向リストのnextとして転用し、`recycleHead` へ積む。

Recycle Poolから取り出すときは先頭を外し、有効要素数を増やしてpayloadを
再初期化できる状態へ戻す。木から外れたノードの構造領域をfreeせず、次の挿入へ
使うことで、削除と再挿入のたびにallocationを発生させない。

ノードを作る経路はRecycle Poolを優先し、空の場合だけFresh Poolを使う。

## ノードのライフサイクル

```text
未使用slot
    │ Fresh Poolから取得
    │ UnsafeNode初期化・tracking tag割当
    ▼
有効ノード ◄────────────────────────────┐
    │                                     │
    │ 木から削除                          │ Recycle Poolから取得
    │ payload破棄・世代更新               │ payload再初期化
    ▼                                     │
Recycle Pool ─────────────────────────────┘
    │
    │ bucket全体の破棄
    ▼
ノードをdeinitializeしてraw memoryを解放
```

`count`、`freshPoolUsedCount`、`freshPoolCapacity` は異なる量を表す。

| 値 | 意味 |
| --- | --- |
| `count` | 現在payloadを持ち、木の要素として有効なノード数 |
| `freshPoolUsedCount` | Fresh Poolから一度でも初期化された通常ノードslot数 |
| `freshPoolCapacity` | bucket群に確保された通常ノードslotの総数 |
| `freshPoolUsedCount - count` | Recycle Poolにある削除済みノード数 |

基本関係は
`count <= freshPoolUsedCount <= freshPoolCapacity` である。

## payloadの初期化と破棄

node metadataとpayloadは隣接しているが、初期化状態は別に管理する。
`___has_payload_content` がtrueのノードだけが有効なpayloadを持つ。

bucket全体を破棄するとき、allocatorは使用歴のあるノードを走査する。

- payloadが有効なら、型消去されたdeinitializerでpayloadを破棄する。
- Recycle Pool上のノードはpayload破棄済みなので、二重に破棄しない。
- その後に `UnsafeNode` 自体をdeinitializeする。
- primary bucketではbegin pointerとend nodeも別途deinitializeする。
- 最後にraw memoryを解放する。

`_BucketAllocator` はpayload型のstride、alignment、deinitializerを生成時に保持する。
これにより、型消去されたbuffer headerからでも正しいレイアウトと破棄処理を利用できる。

## 容量拡張とアドレス安定性

一意に所有された木の容量が不足した場合、既存bucketを再確保せず、
不足分を持つsecondary bucketを追加する。

```text
before:
primary bucket

after:
primary bucket ──► new secondary bucket
```

この方式では既存ノードのアドレスを維持できる。一方、tracking tagからアドレスを
引く処理は、bucketが複数なら所属bucketを順に判定する必要がある。通常の木操作は
リンクされたnode pointerを使うため、容量拡張のたびに全ノードを移動する必要はない。

capacityの増加量は性能調整の対象であり、この文書では特定のgrowth factorを
設計上の固定条件とはしない。

## CoW時の再配置

CoWでは新しいストレージへ木を再構築するため、ノードアドレスは変わる。
コピー対象は現在の有効要素だけではなく、
`freshPoolUsedCount` までの使用歴がある全slotである。Recycle Poolにある削除済み
ノードもtracking tagの位置とfree listを再現するために必要になる。

コピー処理は次の対応を使う。

```text
old pointer
    │ old nodeのtracking tag
    ▼
new primary bucket内の同じ番号のslot
```

コピー先は使用歴のあるslotを収容できる単一のprimary bucketとして作られる。
容量拡張を重ねたコピー元が複数bucketに分かれていても、CoWによる再配置を経ると
bucket chainは一本の連続したレイアウトへ整理される。

```text
before CoW:
primary bucket ──► secondary bucket ──► secondary bucket

after CoW:
primary bucket
└── 使用歴のあるslotをtracking tag順に連続配置
```

これは有効要素だけを詰め直すcompactionではない。tracking tagの対応とRecycle Poolを
維持するため、削除済みslotを含む `freshPoolUsedCount` までの配置は残る。
整理されるのは論理的な欠番ではなく、増設によって分割されていた物理bucketである。

単一bucketになることで、tracking tagをbucket内の配列indexとして扱える。
`_BucketAccessor` は先頭nodeのアドレスに `stride * trackingTag` を加えて
対応ノードを直接求めるため、bucket chainの探索は発生しない。したがって、
CoW直後のtracking tagからノードアドレスへの問い合わせは O(1) である。

CoWは値を分離するだけでなく、それまでの段階的な容量拡張で分散した
メモリレイアウトを単純化し、tag問い合わせを O(1) に戻す機会にもなる。

その後の容量拡張でsecondary bucketが追加されると、tagが属するbucketの判定には
再びbucket chainの走査が必要になる。この O(1) 性は、CoWで再配置された時点の
単一bucketレイアウトがもたらす性質である。

コピーではtracking tag、リンク、色、payloadの有無、Recycle Poolの連結を
新しいポインタで再構築する。recycle countについては現行コードにコピー方法を
再検討するTODOがあり、固定された設計契約として扱わない。

CoWの値セマンティクス、一意性確認、コピー先へ持ち越さない寿命管理状態については
`Design-CopyOnWrite.md` を参照する。

## bucketの解放責任

通常は `UnsafeTreeV2BufferHeader` がbucket chainの解放責任を持つ。ただし、
木より長く生存するIndexやIteratorがある場合、raw memoryの寿命を直ちに終えられない。

その場合はbucket先頭とallocatorを `_TiedRawBuffer` に結び付け、
解放責任を遅延できる。メモリが残っていることとpayloadへのアクセスが許可されることは
別に管理される。この仕組みの契約は `Design-MemorySafety.md` で扱う。

## 責務の境界

| 型 | 主な責務 |
| --- | --- |
| `UnsafeTreeV2BufferHeader` | 木の入口、特殊ポインタ、pool、count、bucket chainの管理 |
| `_BucketAllocator` | 型別レイアウト計算、raw memory確保、payloadとnodeの破棄 |
| `_Bucket` | 一つの確保領域のcapacity、使用数、次bucketの保持 |
| `_BucketQueue` | Fresh Poolとして未使用slotを順に供給 |
| `UnsafeNode` | 木のリンク、色、tracking metadata、payload初期化状態 |
| `_TiedRawBuffer` | 必要な場合にbucket chainの解放責任を遅延して引き受ける |

`UnsafeNode` はpayload型、bucket、所有者を知らない。
`_BucketAllocator` は赤黒木のリンク構造を知らない。
`UnsafeTreeV2BufferHeader` が両者を接続する。

## 維持すべき不変条件

- primary bucketは必ずbegin pointerとend nodeを持つ。
- secondary bucketはbegin pointerとend nodeを持たない。
- rootはend nodeの左リンクに格納する。
- 空の木ではbeginがendを指し、rootがnullptrである。
- 通常payloadは対応する `UnsafeNode` の直後にあり、正しくalignされている。
- payloadを持つノードだけをdeinitializeする。
- Recycle Poolへ送る前にpayloadを破棄し、世代を進める。
- Recycle Poolにslotがある間はFresh Poolより再利用を優先する。
- tracking tagはキー比較や木の順序へ使用しない。
- 通常の容量拡張で既存ノードを移動しない。
- CoWのコピー先は、使用歴のあるslotを少なくとも収容する。
- CoW直後のコピー先bucketは単一である。
- `count <= freshPoolUsedCount <= freshPoolCapacity` を維持する。
- bucketの解放責任をheaderと `_TiedRawBuffer` の双方に持たせない。

## 変更時の確認事項

次の変更はレイアウト全体へ影響するため、局所的な修正として扱わない。

- `UnsafeNode` のfield、サイズ、alignmentの変更
- payload位置またはpair strideの変更
- primary bucketのbegin pointerまたはend nodeの配置変更
- tracking tagの採番方法の変更
- Fresh PoolとRecycle Poolの優先順位やcount更新の変更
- bucket追加方式からノード移動方式への変更
- CoW時の単一bucket条件の変更
- `___has_payload_content` の意味の変更
- bucketの所有権を `_TiedRawBuffer` へ移す条件の変更

変更時には、空・capacity 0・複数bucket・削除済みノードあり・CoW直後・
Indexが木より長生きする場合をそれぞれ検証する。

## 関連文書

- [設計Overview](Design-Overview.md)

- [内部アーキテクチャ](Design-InternalArchitecture.md)
- [Copy on Writeの設計](Design-CopyOnWrite.md)
- [メモリ安全性の設計](Design-MemorySafety.md)
- [RangeとIndex反復の設計](Design-Range.md)
