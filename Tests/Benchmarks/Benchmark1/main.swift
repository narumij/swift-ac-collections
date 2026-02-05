import Benchmark
import Foundation
import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

typealias Fixture = RedBlackTreeSet

#if !COMPATIBLE_ATCODER_2025
  fatalError()
#else
  print("Benchmark1")
  print()
  print("UNSAFE_TREE_V2")
  print(Date.now)
  print()

  for count in [0, 32, 256, 1024, 8192, 10000, 100000, 1_000_000] {
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
#endif
