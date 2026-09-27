# メモリ安全性の設計

## この文書の目的

RedBlackTreeCollectionsは、生ポインタと独自アロケータを使って赤黒木を実装する。
そのため、無効化済みノード、再利用されたアドレス、解放済みバッファ、別の木に
由来するIndexを区別しなければならない。

この文書では、現行コードがポインタをどの層で扱い、どこで安全性を付加しているかを
記録する。目標は、誤った操作を必ず成功させることではなく、失敗時にも
確保外メモリへアクセスしないことである。

## 基本方針

- 生ポインタは、木の所有下で即時に完結する内部処理に限定する。
- 外部へ渡るIndexには、ノードの世代とストレージの同一性を付加する。
- 削除されたノードと、同じアドレスへ再配置された新しいノードを区別する。
- 木が解放された後のIndexは、raw pointerへ触れる前にdetachedとして拒否する。
- CoWで分岐した木では、tracking tagを使って対応するノードを解決できる。
- 安全性のためであっても、ホットループへ不要な O(log N) 検査を追加しない。
- この型群はスレッドセーフではない。並行変更を許可する仕組みではない。

## ポインタの層

現行実装には、用途の異なる複数のポインタ表現がある。

| 層 | 主な型 | 役割 |
| --- | --- | --- |
| raw | `UnsafeMutablePointer<UnsafeNode>` | 所有中の内部処理で使う最速経路 |
| safe result | `_SafePtr` | 生ポインタまたは `SealError` を伝える |
| sealed | `_NodePtrSealing` / `_SealedPtr` | アドレスとノード世代を組にする |
| lazy tied | `_LazyTieWrap<_NodePtrSealing>` | sealed pointerへ木の同一性と解放検出を加える |
| public index | `UnsafeIndexV3` | lazy tied pointerの公開別名 |

raw pointerは、呼び出し中に所有木が存続し、対象ノードが無効化されないことが
構造上明らかな箇所で使う。時間差で変更や解放が起こり得る境界ではsealedまたは
lazy tiedな表現へ移行する。

## ノード世代による再利用検出

ノードを削除してrecycle poolへ送る際、`___recycle_count` を増加させる。
`_NodePtrSealing` はIndex生成時のポインタと、その時点のrecycle countを保持する。

利用時に現在のrecycle countと保存値を比較し、一致しなければ `.unsealed` として
失敗する。これにより、同じメモリアドレスが別のノードとして再利用されても、
古いIndexを新しいノードとして誤認しない。

recycle countは有限幅であり、周回して同じ値になる可能性は仕様上残る。
これは世代カウンタ方式の既知の限界である。

payloadを破棄したノードでは `___has_payload_content` もfalseになる。
`accessible` はpayloadアクセス前にこの状態を確認し、削除済みノードを
`.garbaged` として扱う。

## Indexと木の同一性

`UnsafeIndexV3` は `_LazyTie` への参照を保持する。
木側も必要になった時点で `_LazyTie` を遅延生成する。

Indexを木へ解決するとき、木の `_lazyDetach` とIndexの `lazyDetach` を
参照同一性で比較する。

- 一致する場合はsealed pointerの世代を検査する。
- 一致せず `ALLOW_CROSS_TREE_INDEX` が無効なら `.crossTree` とする。
- 一致せず `ALLOW_CROSS_TREE_INDEX` が有効なら、保存されたtracking tagとsealから
  対象木の対応ノードを探す。

`Package.swift` の現行構成では `ALLOW_CROSS_TREE_INDEX` が有効であり、これは
CoWで分岐したコレクション間でIndexを利用するための経路である。無関係な
コレクションから取得したIndexの利用は事前条件違反であり、tracking tag等が
偶然一致した場合を含めて検出を保証しない。

## IndexとIteratorの寿命

現行構成のIndexはsealed pointerと `_LazyTie` を保持するが、bucketの所有権は
保持しない。木のバッファが解放されると `_LazyTie.isDetached` が設定され、
以後のIndex解決はraw pointerを検査する前に `.detached` として失敗する。
これにより、Indexのためだけに解放済みノード領域へアクセスすることを避ける。

現行のIteratorは `UnsafeTreeV2` の値をスナップショットとして保持する。
コレクションとIteratorは最初は同じストレージを共有し、その後コレクションを
変更するとCoWが発生するため、Iteratorは作成時の木を走査し続けられる。

## `_TiedRawBuffer` とアクセス禁止

`_TiedRawBuffer` はバケット先頭とdeallocatorを保持し、deinitでバケットを解放する。
また `isValueAccessAllowed` を持つ。

これは `COMPATIBLE_ATCODER_2025` のIteratorなど、互換・旧実装の寿命管理で使う。
現行のIndexは `_LazyTie` によるdetached検出、現行のIteratorは木のCoW共有を使うため、
通常経路でIndexのためにbucket所有権を `_TiedRawBuffer` へ移すものではない。

互換経路で木本体の寿命終了後もメモリを残す場合、元の木としての値アクセスが
引き続き正しいとは限らない。そのため、共有済みのtied bufferにはアクセス禁止状態を
設定できる。

メモリが生存していることと、その内容を有効な木の値として利用できることは
別の保証である。

## エラー表現

ポインタ検証は `SealError` で失敗理由を運ぶ。主な区分は次のとおりである。

- `.null`: 想定外のnull pointer
- `.garbaged`: payloadが破棄されたノード
- `.unknown`: tracking tagなどから解決できない状態
- `.limit`: 指定された移動限界を越えた
- `.notAllowed`: 元の木の解放などによりアクセスできない
- `.detached`: Indexの由来するストレージがすでに解放された
- `.unsealed`: 保存した世代と現在のノード世代が一致しない
- `.lowerOutOfBounds` / `.upperOutOfBounds`: 木の範囲外
- `.outOfBounds`: 範囲外の方向を区別しない失敗
- `.crossTree`: 別の木に由来するIndex
- `.other`: 上記へ分類しない内部失敗

公開APIでは、操作の契約に応じてoptional、`Result`、precondition failure、
fatal errorへ変換される。内部で失敗理由を保持することにより、不正ポインタを
そのままdereferenceする経路を避ける。

## 削除と反復

削除は次の二つを同時に起こす。

- payloadを破棄する。
- recycle countを進め、既存のsealed pointerを無効化する。

したがって、反復中に現在ノードまたは次ノードを削除すると、イテレータの進行に
必要なリンクや値が無効になる可能性がある。範囲削除は専用APIへ集約し、
一般的な反復中の削除を支援しない。

## CoWとの関係

CoWで新しい木を作ると、ノードアドレスと `_LazyTie` は新しくなる。
tracking tagを維持し、`ALLOW_CROSS_TREE_INDEX` の経路でコピー元Indexを
コピー先の対応ノードへ解決する。

`ALLOW_CROSS_TREE_INDEX` 有効時のコピーは `___recycle_count` も引き継ぐ。
コピー先では、Indexが保存したsealと対応ノードのrecycle countを比較するため、
再利用前のstale Indexは `.unsealed` として拒否される。

ただし `count == 0` のコピーは使用済みslotと世代履歴を再構築しない。
空になった木をCoWした後の世代継承は、現時点の保証に含めない。

元ストレージ自体が解放された場合は `_LazyTie.isDetached` により、元のraw pointerを
dereferenceする前に拒否する。

## 並行アクセス

`UnsafeTreeV2BufferHeader` とその遅延プロパティはスレッドセーフではない。
`tiedRawBuffer` と `lazyDetach` の初期化も、複数スレッドからの同時初期化を
保証していない。

一部だけをatomic化しても、木全体の変更が同期されていなければ安全にはならない。
並行利用には外部同期が必要である。

## 不変条件

変更時には少なくとも次を維持する。

- raw pointerを所有バッファの寿命外へ持ち出さない。
- 外部へ渡すIndexは世代情報と `_LazyTie` を保持する。
- recycle poolへ送る前後で世代を進める。
- `ALLOW_CROSS_TREE_INDEX` 有効時のCoWでは、要素を持つ木のrecycle countを引き継ぐ。
- payload破棄後は `___has_payload_content == false` とする。
- cross-tree解決はCoW由来の木を前提とし、無関係な木での成功を契約にしない。
- 現行Indexはbucketを所有せず、detached確認後にのみpointerを検証する。
- 互換経路で `_TiedRawBuffer` へ所有権を移した場合、木側から直接解放しない。
- 失敗した検証結果からpointerを強制的に取り出さない。
- Indexの安全性を理由に、確保外メモリへ検査アクセスしない。

## 検証

- 削除済みIndexが `.garbaged` または `.unsealed` として拒否されること
- 同じストレージ内でrecycleされた同一アドレスを古いIndexが指せないこと
- cross-tree無効時は別の木のIndexが `.crossTree` になること
- 木よりIndexが長生きした場合は `.detached` となり、確保外アクセスが起こらないこと
- Iteratorが作成時の木を保持し、元コレクションの変更時にCoWされること
- 互換経路の所有権移行でbucketが二重解放されないこと
- CoW由来の有効なIndexをtracking tagから対応付けられること
- 再利用前のstale IndexがCoW後の木でも `.unsealed` になること
- 空の木では世代履歴を継承しない制限を確認すること
- DebugとReleaseの両方で検証経路が成立すること
- sanitizerおよび削除・再利用を繰り返すテストで問題がないこと

## 関連文書

- [設計Overview](Design-Overview.md)

- [ノードストレージの設計](Design-NodeStorage.md)
- [Copy on Writeの設計](Design-CopyOnWrite.md)
- [RangeとIndex反復の設計](Design-Range.md)
- [内部アーキテクチャ](Design-InternalArchitecture.md)
