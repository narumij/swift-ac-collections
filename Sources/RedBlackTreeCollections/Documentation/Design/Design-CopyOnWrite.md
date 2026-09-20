# Copy on Writeの設計

## この文書の目的

RedBlackTreeCollectionsの値型コレクションが、木のストレージをどのように共有し、
どの時点で複製するかを記録する。Copy on Write（CoW）は値セマンティクスを
実現するために必要だが、木全体の複製は O(N) であり、赤黒木の単一操作が持つ
O(log N) の利点を容易に打ち消す。

この文書は現行の `UnsafeTreeV2`、`UnsafeTreeV2Buffer`、
`UnsafeTreeV2BufferHeader` の実装を基準とする。

## 所有構造

公開コレクションは値型であり、内部に `UnsafeTreeV2<Base>` を保持する。
`UnsafeTreeV2` 自体も値型だが、その実体は
`ManagedBufferPointer<UnsafeTreeV2BufferHeader, Void>` である。

```text
RedBlackTreeSet / Dictionary / MultiSet / MultiMap
└── UnsafeTreeV2<Base>
    └── ManagedBufferPointer
        └── UnsafeTreeV2Buffer
            ├── UnsafeTreeV2BufferHeader
            └── bucket群
                └── UnsafeNode + Payload
```

コレクションのコピーでは、最初は `ManagedBufferPointer` だけが共有される。
変更操作の直前に参照の一意性を確認し、共有されている場合に木全体を複製する。

## 変更操作の入口

公開APIは、変更の種類に応じて次の処理を呼び出す。

- `ensureUnique()`: 削除や値更新など、容量追加を必要としない変更
- `ensureUniqueAndCapacity()`: 挿入など、一意性と空き容量の両方が必要な変更
- `ensureUniqueAndCapacity(to:)`: 必要容量が事前に分かる変更
- `unsafeEnsureCapacity()`: 呼び出し元で一意性を確保済みの内部経路
- `_strongEnsureUnique()`: 現行の非互換モードでは `ensureUnique()` と同じ

`isUnique()` は `ManagedBufferPointer.isUniqueReference()` を利用する。
一意ならコピーせず、そのまま変更する。共有されていれば `copy()` または
`_ensureUniqueSlow` を通して新しい木へ切り替える。

一意性検査をホットパスに残し、実際のコピー処理は低速経路へ分離する。
`copy()` は現在 `@inline(never)` であり、呼び出し元のレジスタ圧を下げる
意図がある。この指定やファイル配置はコード生成へ影響しているため、変更時には
Releaseビルドで再計測する。

## 空の共有ストレージ

空の木には `_emptyTreeStorage` という共有シングルトンがある。
これは読み取り専用として扱われる。

容量が必要になった場合、`ensureCapacity()` は読み取り専用ストレージかを確認し、
新しい一意な木を生成する。`unsafeEnsureCapacity()` は読み取り専用でないことを
事前条件とし、内部の一意性確保済み経路だけで使う。

## 木のコピー

コピーは単なるバイト列複製ではない。新しいバッファを確保し、利用歴のあるノードを
tracking tag順に再構築する。

現行実装は次を維持する。

- ノードのtracking tag
- 左・右・親へのリンク関係
- ルートとbegin node
- 赤黒木の色情報
- 有効ノード数
- fresh poolの利用済み数
- recycle poolの状態
- payloadを持つノードの値

削除済みノードがrecycle poolに存在するとtracking tagに抜けが生じるため、
有効要素数ではなく `freshPoolUsedCount` までをコピー対象とする。

新しい木のポインタは古い木と異なる。リンクはtracking tagから新しいポインタへ
写像して再構築する。

### コピー直後の単一bucket

コピー先は、少なくともコピー直後にはfresh poolを単一bucketに保つ。
tracking tagによるノードアドレス解決を O(1) にするためである。

bucketが複数ある場合でもフォールバック実装は探索できるが、bucket走査が必要になる。
CoW後の性能を維持するため、コピー生成時の単一bucketは重要な不変条件である。

### コピー先へ持ち越さない状態

`_tied` と `_lazyDetach` はコピー先へそのまま移さない。
これらは元ストレージに由来するIndex・Iteratorの寿命と同一性を表すため、
新しい木には新しい管理関係が必要である。

コピー後のヘッダでは `_tied == nil` が期待される。

## IndexとCoW

`UnsafeIndexV3` はノードポインタだけではなく、ノードの世代と
`_LazyTie` の同一性を保持する。

CoWで作られた木は値として等価でも、別のストレージである。
そのため、コピー元から作られたIndexをコピー先の木へそのまま適用できることを
公開契約にはしない。通常構成では `_LazyTie` が一致しないIndexは
`.crossTree` として拒否される。

内部にはtracking tagを使ってCoW由来の差異を解決するための経路もあるが、
`ALLOW_CROSS_TREE_INDEX` が有効な場合の実験的動作であり、通常のAPI契約ではない。

CoW後もtracking tagを維持することと、Indexを別の木で利用可能にすることは
別の問題である。前者は内部再構築と検査に必要だが、後者を保証するものではない。

## CoWを減らすAPI方針

木全体のコピーは O(N) であり、単一の検索・挿入・削除より高価になり得る。
そのため、次の方針を取る。

- 変更ループの途中で一意性検査やCoWを繰り返さない。
- 範囲変更は、可能なら専用APIの入口で一度だけ一意性を確保する。
- 内部ループでは、一意性確保済みを前提とする `unsafeEnsureCapacity()` を使う。
- 反復と単要素削除の組み合わせへ利用者を誘導しない。
- ViewやIndexを不必要に長寿命化し、ストレージ管理を複雑にしない。
- CoWを避ける目的で値セマンティクスやメモリ安全性を破らない。

## 容量拡張との統合

`ensureUniqueAndCapacity` は一意性と容量を同じ入口で処理する。

- 共有中なら、必要容量を満たす新しい木へコピーする。
- 一意なら、既存ヘッダのfresh poolを拡張する。
- 空き容量がある場合は追加確保しない。

コピーと容量拡張を別々に行うと、短時間に複数の確保や移送が発生し得るため、
必要容量が分かる経路では統合して処理する。

## 検証

CoW関連の変更では、少なくとも次を確認する。

- 値型をコピーした後、一方の変更が他方へ反映されないこと
- 一意な木の変更では木全体のコピーが発生しないこと
- 共有された木の最初の変更でのみコピーが発生すること
- コピー前後で要素、順序、count、tracking tagが対応すること
- 削除済みノードを含む木でもコピー後のrecycle poolが正しいこと
- コピー直後のfresh poolが単一bucketであること
- コピー先が元の `_tied` と `_lazyDetach` を継承しないこと
- 古いIndexが新しい木で誤って有効扱いされないこと
- `AC_COLLECTIONS_INTERNAL_CHECKS` の `copyCount` で発火回数を確認できること
- Releaseビルドでコピー低速経路の分離とホットパスのコード生成を確認すること

## 関連文書

- [ノードストレージの設計](Design-NodeStorage.md)
- [RangeとIndex反復の設計](Design-Range.md)
- [メモリ安全性の設計](Design-MemorySafety.md)
- [内部アーキテクチャ](Design-InternalArchitecture.md)
