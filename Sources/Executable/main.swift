// Instrumentsでの計測用の作業コマンド

import Foundation
import RedBlackTreeModule

#if false
var tree = RedBlackTree.Container<Int>()
//let tree = RedBlackTree.Storage<Int>()

tree.reserveCapacity(1_000_000)
for i in 0 ..< 1_000_000 {
    _ = tree.__insert_unique(i)
}
#else
var tree = RedBlackTreeSet<Int>(0 ..< 1_000_000)
#endif
print("Hola!")

