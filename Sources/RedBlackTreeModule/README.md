# RedBlackTreeModule

## データ構造

- RedBlackTreeSet
- RedBlackTreeMultiSet
- RedBlackTreeDictionary
- RedBlackTreeMultiMap

## __treeディレクトリ

- LLVMの移植部分
- 抽象木としての実装となっている
- 命名は元のソースに倣う
- C++でのポインタとイテレータは移植後のコードで区別はない
- プロトコルの命名にprefixは特にない

## _RedBlackTreeディレクトリ

- 内部木の具象実装 (`___RedBlackTree+Tree`)
- 各コンテナのmixin実装
- `___RedBlackTree`のなかにいろいろ入っているのは、盆栽時代の衝突回避の名残
- C++に無い内部実装は`___`をprefixにつけている場合がほとんど
- 木の具象実装に対するプロトコルは`Tree_`をprefixにつけている
- データ構造に対するプロトコルは`RedBlackTree`をprefixにつけている

## Sequenceディレクトリ

- 各コンテナのシーケンスとサブシーケンスの実装

## Memoizeディレクトリ

- メモ化向けのコンテナ

