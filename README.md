# swift-ac-collections

## 目的

AtCoderで必要とされるデータ構造のうち、SwiftとAC(AtCoder) Libraryの双方に欠けているものを埋めることを目的としています。

自分がまだ競プロerとして駆け出しなこともあり、基本的にupsolveを補助するためのモノです。

## 内容

- RedBlackSet, RedBlackDictionary

C++のSTLのsetやmapと同等の動作をするモノを目指して開発しています。

木の回転や、木のリバランシングに関しては、LLVMのコードをほぼ丸写しでつかっています。ありがとうございます。

各種SetでACできなかった場合に、お試しください。


- NextPermutation

削除しました。permutationsでACできなかった問題が、combinationsでACできることが分かったためです。

## 今後

先日、swift-collection 1.1.0がリリースされていました。

- 多少コツが必要ですが、swift-collections 1.1.0のHeapが優先キュー代わりに使えることが分かっています。
- bitsetもswift-collections 1.1.0で来ました。
- permutationsに関しては自分の使い方の問題でした。

ジャッジ環境更新待ちではありますが、水色に必要とされるデータ構造はかなり埋まってきました。

- gcdはリリースされてはいませんが、swift-numericsに入っています。
- lowerBound等の二分探索や、popcountは依然Swift公式では実装がないので、自分で用意する必要があります。
- ac-libaryについては別途取り組んでいます。
- 黄色に必要とされる足りない部分を整えるのは、範囲外だと考えます。

あとは気の向くままに赤黒木いじりをする、だけ、になりそうです。

