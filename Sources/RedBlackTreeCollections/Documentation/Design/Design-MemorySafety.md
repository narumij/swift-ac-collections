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
- 木が解放されてもIndexが残る場合、必要なメモリ寿命を遅延して確保する。
- 異なる木のIndexは、通常構成では拒否する。
- 安全性のためであっても、ホットループへ不要な O(log N) 検査を追加しない。
- この型群はスレッドセーフではない。並行変更を許可する仕組みではない。

## ポインタの層

現行実装には、用途の異なる複数のポインタ表現がある。

| 層 | 主な型 | 役割 |
| --- | --- | --- |
| raw | `UnsafeMutablePointer<UnsafeNode>` | 所有中の内部処理で使う最速経路 |
| safe result | `_SafePtr` | 生ポインタまたは `SealError` を伝える |
| sealed | `_NodePtrSealing` / `_SealedPtr` | アドレスとノード世代を組にする |
| lazy tied | `_LazyTieWrap<_NodePtrSealing>` | sealed pointerへ木の同一性と遅延寿命管理を加える |
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
- 一致しない場合、通常構成では `.crossTree` とする。
- `ALLOW_CROSS_TREE_INDEX` 有効時にはtracking tagから対応ノードを探す経路がある。

異なる木で同じ値や同じtracking tagが存在しても、通常の公開契約では
同じIndexとは扱わない。

## 遅延寿命管理

Indexを作るたびに完全なメモリ所有オブジェクトを生成すると、通常利用にも
参照管理と確保のコストが発生する。現行実装は `_LazyTie` を代理オブジェクトとして
使い、実際のバケット所有権移行を木の解放時まで遅延する。

通常経路は次のとおりである。

1. 木が必要になった時点で軽量な `_LazyTie` を生成する。
2. Indexはsealed pointerと `_LazyTie` を保持する。
3. 木のバッファが先に解放される場合、外部に `_LazyTie` が残っているか確認する。
4. 残っていれば `_TiedRawBuffer` を生成し、`_LazyTie.buffer` へ設定する。
5. バケットの解放責任を `_TiedRawBuffer` へ移す。
6. 最後のIndex等が解放され、`_TiedRawBuffer` が破棄された時点でバケットを解放する。

Indexが残っていなければ、木のバッファがfresh poolを直接解放する。
この分岐により、通常利用での寿命延長コストを抑える。

## `_TiedRawBuffer` とアクセス禁止

`_TiedRawBuffer` はバケット先頭とdeallocatorを保持し、deinitでバケットを解放する。
また `isValueAccessAllowed` を持つ。

木本体の寿命が終了してバケット所有権が移った場合、メモリ自体はIndexのために
残り得るが、元の木としての値アクセスが引き続き正しいとは限らない。
そのため、共有済みのtied bufferにはアクセス禁止状態を設定できる。

メモリが生存していることと、その内容を有効な木の値として利用できることは
別の保証である。

## エラー表現

ポインタ検証は `SealError` で失敗理由を運ぶ。主な区分は次のとおりである。

- `.null`: 想定外のnull pointer
- `.garbaged`: payloadが破棄されたノード
- `.unknown`: tracking tagなどから解決できない状態
- `.limit`: 指定された移動限界を越えた
- `.notAllowed`: 元の木の解放などによりアクセスできない
- `.unsealed`: 保存した世代と現在のノード世代が一致しない
- `.lowerOutOfBounds` / `.upperOutOfBounds`: 木の範囲外
- `.crossTree`: 別の木に由来するIndex

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

`Iterable` による借用反復を導入する場合は、ノンエスケープ性だけでなく、
借用スコープ中の削除保護が必要である。詳細は `Design-Range.md` を参照する。

## CoWとの関係

CoWで新しい木を作ると、ノードアドレスと `_LazyTie` は新しくなる。
tracking tagは内部対応付けのため維持されるが、コピー元Indexのコピー先での
利用を通常契約にはしない。

古いIndexは元ストレージへ結び付いたままであり、そのストレージが解放される場合は
遅延寿命管理が確保外アクセスを防ぐ。新しい木で誤って使われた場合は
木同一性検査で拒否する。

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
- payload破棄後は `___has_payload_content == false` とする。
- 別の木のIndexを通常経路で解決しない。
- バケットの解放責任を木と `_TiedRawBuffer` の双方に持たせない。
- `_TiedRawBuffer` へ所有権を移した場合、木側から直接解放しない。
- 失敗した検証結果からpointerを強制的に取り出さない。
- Indexの安全性を理由に、確保外メモリへ検査アクセスしない。

## 検証

- 削除済みIndexが `.garbaged` または `.unsealed` として拒否されること
- recycleされた同一アドレスを古いIndexが指せないこと
- 別の木のIndexが `.crossTree` になること
- 木よりIndexが長生きしても確保外アクセスが起こらないこと
- Indexが残らない通常経路ではバケットが直接解放されること
- 所有権移行時にバケットが二重解放されないこと
- CoW前後でIndexの所属が混同されないこと
- DebugとReleaseの両方で検証経路が成立すること
- sanitizerおよび削除・再利用を繰り返すテストで問題がないこと

## 関連文書

- [設計Overview](Design-Overview.md)

- [ノードストレージの設計](Design-NodeStorage.md)
- [Copy on Writeの設計](Design-CopyOnWrite.md)
- [RangeとIndex反復の設計](Design-Range.md)
- [内部アーキテクチャ](Design-InternalArchitecture.md)
