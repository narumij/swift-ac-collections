import MT19937
import RedBlackTreeModule

var mt = mt19937_64(seed: 0)

#if false
  var f = Fixture<Int>()
  let count = 10_000_000
  f.reserveCapacity(10_000_000)
  for i in 0..<count {
    f.insert(i)
  }
  print(f.sorted().count)
#endif

#if false
  for _ in 0..<1_000_000 {
    for count in [0, 32, 1024, 8192] {
      let fixture = RedBlackTreeSet<Int>()
      var f = fixture
      //    f.reserveCapacity(8192)
      f.insert((0..<count).randomElement(using: &mt) ?? 0)
      //    var fixture = RedBlackTreeSet<Int>()
      //    fixture.insert((0..<count).randomElement(using: &mt) ?? 0)
    }
  }
#endif

do {
  for count in [0, 32, 1024, 8192] {
    let ii = (0..<count).shuffled(using: &mt)
    for _ in 0..<2_000 {
      var fixture = RedBlackTreeSet<Int>()
      for i in ii {
        fixture.insert(i)
      }
    }
  }

  //  do {
  //    let count = 100000
  //    var fixture = RedBlackTreeSet<Int>((0..<count).map { $0 * 2 - 1 })
  //    let ii = (0..<count).shuffled(using: &mt)
  //    for i in ii {
  //      fixture.insert(i)
  //    }
  //  }
}
