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
- プロトコル適合することで`__tree_`のプロトコルを各種利用している
- コレクションに対して不足している部分を追加で実装している
- C++に無い内部実装は`___`をprefixにつけている
- 内部木に対するプロトコルは`Tree_`をprefixにつけている

## _RedBlackTreeディレクトリ

- 各コレクションの共通実装部
- 内部木をメンバとして持つ

## _Storageディレクトリ

- Copy On Writeの実行部の実装

## Memoizeディレクトリ

- メモ化向けのコンテナ

