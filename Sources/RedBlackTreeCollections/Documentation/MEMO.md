<!-- エージェント向けではなく、自分向け、人間向けの事柄を記載すること -->
# RedBlackTreeCollections

## 現状と目標

(2026/09/30)

この赤黒木を見つけた人が、実際に試したいと感じてもらえるよう、条件を整える
1.0に向けて洗練するよう努める

## API設計

初心者にとって難しい型推論エラーの解決が発生しないよう配慮する。

Swiftの知識で一旦それっぽく使える状態を維持する。

## inlinable / inline

ジェネリクスやプロトコルではwitness tableによる低速化を避けるため、`@inlinable`を基本とする。

`@inline(__always)`を中途半端に付与するとオプティマイザの妨げになり、偶然の最適化に依存する可能性があるため、機械的には付与しない。

subscript、subscript helper、accessor coroutine、access handlerなど、明確に小さく頻繁に呼び出される箇所を主な対象とする。

構造が複雑なため、標準コンテナやswift-collectionsのinline指定をそのまま模倣しても同じ結果になるとは限らない。必要に応じてRelease buildの生成コードと性能を確認する。

## 生成コードの確認

### object fileを直接確認する

特定targetの生成コードを局所的に確認したい場合は、Release build後のobject fileを`otool`で逆アセンブルする。

```sh
swift build -c release --target ABC411F
ls -l .build/release/ABC411F.build/main.swift.o
otool -tvV .build/release/ABC411F.build/main.swift.o > ABC411F.asm
```

### 最終バイナリを確認する

リンク後の最終的な生成コードを確認したい場合は、Release buildした実行バイナリを`llvm-objdump`で逆アセンブルする。

```sh
swift build -c release --product benchmark

xcrun llvm-objdump \
  -d \
  --demangle \
  .build/release/benchmark \
  > benchmark.asm
```

変更前後のバイナリをそれぞれ保存し、逆アセンブル結果をdiffすることで生成コードの変化を確認できる。

必要に応じてSILも確認する。

```sh
swiftc -O -emit-sil ...
```

specialization、witness経由の呼び出し、不要なallocationや一時オブジェクトの生成などが疑われる場合は、SILと最終assemblyの両方を確認する。

** 人間がasmを全部読むんじゃなくて、エージェントに差分候補を掘らせて、人間が意味を見る。**

## Memoize

`swift-ac-memoize`はdropしたため、現在のMemoizeは趣味的・補助的な位置づけとする。
