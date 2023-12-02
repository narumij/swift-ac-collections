# swift-ac-collections

## 目的

AtCoderで必要とされるデータ構造のうち、SwiftとAC(AtCoder) Libraryの双方に欠けているものを埋めることを目的としています。

自分がまだ競プロerとして駆け出しなこともあり、基本的にupsolveを補助するためのモノです。

## 内容

・RedBlackSet, RedBlackDictionary

C++のSTLのsetやmapと同等の動作をするモノを目指して開発しています。

木の回転や、木のリバランシングに関しては、LLVMのコードをほぼ丸写しでつかっています。ありがとうございます。

## 今後

swift-collectionsの動向次第ではありますが、

bitsetやswift-collectionsをあてにしており追加の予定はありません。

heapや優先キューは動向を見守りつつ必要そうなら追加するかもしれません。

