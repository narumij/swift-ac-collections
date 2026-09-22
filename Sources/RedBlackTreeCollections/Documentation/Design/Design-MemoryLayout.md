# メモリレイアウトの設計

## この文書の目的

この文書は、RedBlackTreeCollectionsがraw memory上へbucket、特殊ノード、通常ノード、
payloadを配置する規則を記録する。

所有関係とノードのライフサイクルは `Design-NodeStorage.md` で扱う。ここでは特に、
`MemoryLayout` の値からアドレスと確保量を導く方法、および変更時に同時に保つべき
レイアウト不変条件へ焦点を当てる。

## レイアウトを型のABIと混同しない

この実装が必要とするのは、特定プラットフォーム上のバイト数を設計へ固定することではなく、
コンパイルされた型の `stride` と `alignment` から一貫して配置を計算することである。

`UnsafeNode`、`_Bucket`、pointer、payloadの具体的なサイズは、architecture、ビルド条件、
`USE_COMPACT_NODE_METADATA`、payload型によって変わり得る。したがって、文書中の図は
fieldの順序やバイト幅を表すABI図ではない。コード上の契約は次の値から導かれる。

- `MemoryLayout<UnsafeNode>.stride`
- `MemoryLayout<UnsafeNode>.alignment`
- `MemoryLayout<Payload>.stride`
- `MemoryLayout<Payload>.alignment`
- `MemoryLayout<_Bucket>.stride`
- `MemoryLayout<_Bucket>.alignment`
- `MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.stride`
- `MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.alignment`

実測値を性能比較へ使う場合は、対象のtoolchain、architecture、コンパイル条件とともに記録する。

## 一つのelement slot

通常ノードは `UnsafeNode` とpayloadを一つのslotとして配置する。

```text
slot i
┌──────────────────────┬──────────────────────┬───────────────┐
│ UnsafeNode           │ Payload              │ tail padding  │
└──────────────────────┴──────────────────────┴───────────────┘
^ nodeAddress          ^ payloadAddress       ^ next nodeAddress
```

記号を次のように置く。

```text
N = MemoryLayout<UnsafeNode>.stride
P = MemoryLayout<Payload>.stride
A = max(UnsafeNode.alignment, Payload.alignment)
S = alignUp(N + P, to: A)
```

`_MemoryLayout.init(UnsafeNode.self, Payload.self)` が保持するpair layoutは、
`alignment = A`、`stride = S` である。`A` は2の累乗であるため、実装では
次の式で切り上げている。

```text
S = (N + P + A - 1) & -A
```

slot `i` のアドレスは次のようになる。

```text
node(i)    = start + S * i
payload(i) = node(i) + N
```

payloadアクセスに使う `p.advanced(by: 1)` は、typed pointerを
`MemoryLayout<UnsafeNode>.stride` だけ進める。このため、NodeとPayloadの間へ
paddingを挿入することはできない。payloadのalignmentは、slot列の `start` 自体を
調整して満たす。

`size` ではなく `stride` を使うことも契約の一部である。Swift型は末尾paddingを
含み得るため、連続配置とtyped pointerの前進量は `stride` に合わせる必要がある。

## slot列の開始位置

bucket header直後の未調整アドレスを `storage` とする。payloadのalignmentが
`UnsafeNode` 以下なら、`storage` がそのまま最初のnodeになる。

payloadのalignmentがより大きい場合は、payload位置を先にalignし、そこから
`N` byte戻った位置をnodeの開始位置にする。

```text
payloadStart = alignUp(storage + N, to: Payload.alignment)
start        = payloadStart - N
```

```text
storage
  │  leading gap       slot 0
  ▼◄────────────►┌────────────┬────────────┐
                 │ UnsafeNode │ Payload    │
                 └────────────┴────────────┘
                 ^            ^ aligned to Payload.alignment
                 start
```

raw allocationの先頭はpair alignmentへ揃っているため、`storage` のallocation先頭からの
offsetが分かれば、実際のleading gapは確保前に計算できる。

```text
G(prefix) = alignUp(prefix + N, to: Payload.alignment) - (prefix + N)
```

ここで `prefix` はallocation先頭から `storage` までのbyte数である。allocatorは
alignmentの最大余裕ではなく、この実際のgapだけを確保量へ加える。

## Primary bucket

primary bucketは木ごとに一つだけ存在し、通常slot列の前にbegin pointerとend nodeを持つ。

```text
┌─────────┬───────────┬──────────┬─────────────┬────────────────────┐
│ _Bucket │ begin ptr │ end node │ leading gap │ element slots ...  │
└─────────┴───────────┴──────────┴─────────────┴────────────────────┘
^ head                                        ^ start
```

各位置は前のtyped valueを1個進めて求める。

```text
begin_ptr      = head + MemoryLayout<_Bucket>.stride
end_ptr        = begin_ptr + pointer stride
primaryStorage = end_ptr + N
start          = aligned slot start derived from primaryStorage
```

capacityを `C` とすると、確保に必要なbyte数は概念上次のとおりである。

```text
primaryPrefix = _Bucket.stride + pointer.stride + N

primaryBytes = C == 0
             ? primaryPrefix
             : primaryPrefix
               + G(primaryPrefix)
               + S * (C - 1)
               + N + P
```

capacityが0なら通常slotとそのalignment余裕は不要だが、`_Bucket`、begin pointer、
end nodeは存在する。したがって空の木にもroot格納場所とend iteratorの実体がある。

## Secondary bucket

secondary bucketは特殊ノードを持たず、bucket headerと通常slot列だけで構成する。

```text
┌─────────┬─────────────┬────────────────────┐
│ _Bucket │ leading gap │ element slots ...  │
└─────────┴─────────────┴────────────────────┘
^ head                  ^ start
```

```text
secondaryStorage = head + MemoryLayout<_Bucket>.stride
secondaryPrefix  = _Bucket.stride
secondaryBytes   = secondaryPrefix
                 + G(secondaryPrefix)
                 + S * (C - 1)
                 + N + P
```

secondary bucketのcapacityは必ず1以上である。primary bucketと同じslot算式を使うため、
通常ノードを扱う側は所属bucketの種類に関係なく `start + S * i` で走査できる。
最後のslotでは後続nodeをalignするためのtail paddingが不要なので、確保量には含めない。
このため、最後のpayloadの末尾とallocationの末尾は一致する。

## alignmentの成立条件

raw allocation自体はpair layoutの `A` をalignmentとして確保する。これにより
bucket先頭はNodeとPayloadのうち厳しい方のalignmentを満たす。同じraw allocationには
`_Bucket` とbegin pointerも置かれるため、現行レイアウトは次の関係にも依存する。

```text
MemoryLayout<_Bucket>.alignment <= A
MemoryLayout<UnsafeMutablePointer<UnsafeNode>>.alignment <= A
```

つまりallocationへ渡すalignmentは、実際には同じ領域へ配置する全型のalignmentを
満たさなければならない。現行実装では `UnsafeNode.alignment` が `_Bucket` とpointerの
alignment以上であることを前提として、pair layoutの `A` をそのまま使用している。

加えて、slot列の開始位置を調整することで次を同時に成立させる。

- `node(i)` は `UnsafeNode.alignment` を満たす。
- `payload(i)` は `Payload.alignment` を満たす。
- `S` は `A` の倍数なので、すべての後続slotでも同じ条件が保たれる。

この推論はSwiftが返すalignmentが2の累乗であることと、`N` が
`UnsafeNode.alignment` の倍数であることに依存する。

## 初期化状態は配置と別に管理する

確保済みbyteが存在することと、その領域にSwift valueが初期化されていることは別である。

| 領域 | 初期化の契機 | 破棄の条件 |
| --- | --- | --- |
| `_Bucket` | bucket作成時 | bucket解放時 |
| begin pointer | primary bucket作成時 | primary bucket解放時 |
| end node | primary bucket作成時 | primary bucket解放時 |
| 通常の`UnsafeNode` | Fresh Poolから初回取得時 | 使用歴のあるslotをbucket解放時に走査 |
| payload | nodeを要素として構築するとき | `___has_payload_content == true` のとき |

Recycle Pool上のslotには初期化済みの `UnsafeNode` が残るが、payloadは破棄済みである。
したがってslotのアドレスだけからpayloadを読み出してはならず、
`___has_payload_content` とpoolの状態を守る必要がある。

## アドレス計算を共有する利用者

同じpair strideと開始位置は複数の処理から利用される。

- `_BucketQueue` はFresh Poolから次の未使用slotを取り出す。
- `_BucketTraverser` はbucket chain上のslotを順に走査する。
- `_BucketAccessor` はtracking tagに対応するslotを探す。
- `_FreshPoolUsedIterator` は初期化履歴のあるnodeを列挙する。
- `_BucketAllocator` は初期化済みnodeとpayloadを破棄する。

いずれか一つだけ異なるstrideやstart計算を使うと、読み出しの誤りだけでなく、
未初期化領域のdeinitializeや別slotの二重破棄につながる。

## キャッシュ局所性とアドレス安定性

NodeとPayloadを同じslotへ隣接配置するため、木のリンクを辿った直後にpayloadへ
アクセスする処理では、別々に確保する方式より局所性を得やすい。またbucket内のslotは
連続しているため、使用履歴の走査と一括破棄にも適する。

一方、木の順序はslot順とは一致しない。検索やin-order traversalが連続アドレスを
辿る保証はなく、レイアウトだけで木走査のcache localityが保証されるわけではない。

容量拡張時には既存bucketをreallocateせずsecondary bucketを追加する。これにより
既存nodeのアドレスは保たれるが、木全体は単一の連続領域ではなくなる。CoWでは
tracking tag順に単一primary bucketへ再配置されるため、再び `start + S * tag` という
直接計算が可能になる。

## 維持すべき不変条件

- payloadは常に対応する `UnsafeNode` の直後、`p.advanced(by: 1)` にある。
- slot strideはNodeとPayloadのstrideの和をpair alignmentへ切り上げた値である。
- slot列のstartはNodeとPayloadの双方のalignmentを満たす。
- primary bucketだけがbegin pointerとend nodeを持つ。
- capacity 0のprimary bucketにもbegin pointerとend nodeが存在する。
- secondary bucketのcapacityは1以上である。
- raw allocationのalignmentは、`_Bucket`、begin pointer、`UnsafeNode`、payloadの
  すべてのalignmentを満たす。
- 初期化されていないslotをtyped valueとして読み書きまたは破棄しない。
- payloadは `___has_payload_content` がtrueの場合だけ読み出し・破棄する。
- bucket内の全利用者が同じstartとpair strideを使う。

## 変更時の確認事項

次の変更はメモリレイアウト全体の再検証を必要とする。

- `UnsafeNode` または `_Bucket` のfield、型、コンパイル条件を変える。
- `_Bucket`、pointer、`UnsafeNode`のalignmentの大小関係を変える。
- payload位置を `p.advanced(by: 1)` 以外へ変える。
- pair strideまたはstart alignmentの算式を変える。
- primary bucketのbegin pointer、end nodeの順序を変える。
- raw allocationへ渡すbyte countまたはalignmentを変える。
- capacity 0の扱いを変える。

変更時には少なくとも次を確認する。

1. alignmentが `UnsafeNode` より小さい、等しい、大きいpayloadでstartが正しい。
2. capacity 0、1、複数の確保量が領域末尾を越えない。
3. capacityが1以上なら、最後のpayloadの末尾とallocationの末尾が一致する。
4. `node(i)` と `payload(i)` が各型のalignmentを満たす。
5. queue、accessor、traverser、iterator、deinitializerが同じslotを指す。
6. Fresh、live、Recycleの各状態で初期化と破棄が一度ずつ対応する。
7. build configurationごとの `UnsafeNode` レイアウト差を前提にしても算式が成立する。

## 関連文書

- `Design-NodeStorage.md`: bucketの所有、pool、ノードのライフサイクル
- `Design-CopyOnWrite.md`: tracking tagを用いた単一bucketへの再配置
- `Design-MemorySafety.md`: 削除、再利用、Indexの寿命と検証
- `Design-InternalArchitecture.md`: allocatorとtree層の責務境界
