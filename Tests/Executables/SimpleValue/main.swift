import MT19937
import RedBlackTreeModule

typealias SUT = RedBlackTreeDictionary<Int, Int>
//typealias SUT = [Int: Int]
var mt = mt19937_64(seed: 0)

#if false
for count in [0, 32, 1024, 8192] {
  var sut = SUT(uniqueKeysWithValues: (0..<count).map { ($0,0) })
  for i in 0..<1_000_000 {
    sut[(0..<count).randomElement(using: &mt) ?? 0] = i
  }
  for i in 0..<1_000_000 {
    _ = sut[count == 0 ? 0 : i % count]
  }
}
#elseif true
for count in [0, 32, 1024, 8192] {
  var sut = SUT(uniqueKeysWithValues: (0..<count).map { ($0,0) })
  for i in 0..<1_000_000 {
    sut[(0..<count).randomElement(using: &mt) ?? 0, default: -1] = i
  }
  for i in 0..<1_000_000 {
    _ = sut[count == 0 ? 0 : i % count, default: -1]
  }
}
#else
for count in [0, 32, 1024, 8192] {
  var sut = ___LRUMemoizeStorage<Int,Int>(maxCount: Int.max)
  for i in 0..<1_000_000 {
    sut[(0..<count).randomElement(using: &mt) ?? 0] = i
  }
  for i in 0..<1_000_000 {
    _ = sut[count == 0 ? 0 : i % count]
  }
}
#endif
