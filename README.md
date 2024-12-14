# swift-ac-collections

`swift-ac-collections` は、競技プログラミングで利用するために作成された、赤黒木（Red-Black Tree）を基盤としたコレクションライブラリです。このプロジェクトでは、LLVMの `__tree` を Swift に移植し、平衡二分木を活用したさまざまなデータ構造を提供します。

## 内容

### RedBlackTreeModule

[平衡二分木](https://ja.wikipedia.org/wiki/平衡二分探索木)の一種である [赤黒木](https://ja.wikipedia.org/wiki/赤黒木) を用いたコレクションを実装しています。このモジュールは、以下の3つのデータ構造を提供します：

#### RedBlackTreeSet
- 二分探索木をベースにした集合(Set)のデータ構造です。
- 要素の挿入、削除、探索を効率的に行えます。

#### RedBlackTreeMultiSet
- 重複要素を許容する集合(MultiSet)のデータ構造です。
- 同じ要素を複数回保持できる点が `RedBlackTreeSet` との違いです。

#### RedBlackTreeDictionary
- 辞書(Dictionary)として利用可能なキーと値のペアを管理するデータ構造です。
- **補助的な実装であり、実用性や機能性が十分ではありません。**
  - シンプルな動作や基本的な用途には対応していますが、競技プログラミングでの使用には注意が必要です。

### 使用例

以下のリンクから具体的な使用例を見ることができます：
- [使用例](https://atcoder.jp/contests/abc370/submissions/57922896)

この実装は、[SortedSet](https://github.com/tatyam-prime/SortedSet) を参考にし、公開されているメンバー関数やメンバー変数をベースにしています。

## ライセンス

このプロジェクトは LLVM の派生成果物であり、特例が不要であるため、Apache 2.0 ライセンスに基づいて公開されています。

もしライセンスに関して誤解や間違いがある場合は、ご指摘いただけると幸いです。
