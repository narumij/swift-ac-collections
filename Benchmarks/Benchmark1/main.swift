import Benchmark
import RedBlackTreeModule
import MT19937
import Foundation

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

print("Benchmark1")
print()
#if USE_UNSAFE_TREE
print("UNSAFE_TREE")
#else
print("ARRAY_TREE")
#endif
print(Date.now)
print()

for count in [0,32,256,1024,8192,10000,100000,1000000] {
  let fixture = Fixture<Int>(0..<count)
  let indices = fixture.indices.shuffled(using: &mt)
  benchmark("remove shuffled \(count)") {
    var f = fixture
    for i in indices {
      f.remove(at: i)
    }
  }
}

Benchmark.main()
