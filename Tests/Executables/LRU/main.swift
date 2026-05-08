import Foundation
import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

typealias Fixture = ___LRUMemoizeStorage<Int, Int>

for count in [0, 32, 256, 1024, 8192, 10000, 100000, 1_000_000] {
  var fixture = Fixture(maxCount: Int.max)
  for i in 0..<count {
    fixture[i] = i
  }
  var result = 0
  for i in 0..<count {
    result &+= fixture[i] ?? 0
  }
}
