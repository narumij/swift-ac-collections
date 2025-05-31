# RedBlackTreeModule

## コレクション

- RedBlackTreeSet
- RedBlackTreeMultiSet
- RedBlackTreeDictionary
- RedBlackTreeMultiMap

## `__tree_`ディレクトリ

- LLVMの移植部分
- protocol抽象となっている
- 命名は元のソースに倣う
- C++でのポインタとイテレータは移植後のコードで区別はない
- メンバアクセスにドット記法やアロー記法を使わないため、簡易なCに近い
- プロトコルの命名にprefixは特にない

## `___Tree__`ディレクトリ

- 内部木の実装
- 型インジェクションでエレメントの種類と比較の仕方と重複の有無を切り替えている
- プロトコル適合することで`__tree_`のプロトコルを各種利用している
- コレクションに対して不足している部分を追加で実装している
- C++に無い内部実装は`___`をprefixにつけている
- 内部木に対するプロトコルは`Tree_`をprefixにつけている

## _RedBlackTreeディレクトリ

- 各コレクションの共通実装部
- 内部木をメンバとして持つ
- 非公開メンバは`___`をprefixにつけている

## _Storageディレクトリ

- Copy On Writeの実行部の実装
- コレクションだけがStorageを参照していて、この参照数でCopyOnWriteをしている
- 強めのCoWが他にある。違いについて共通実装のCopyOnWriteを参照してください

## Memoizeディレクトリ

- メモ化向けのコンテナ

