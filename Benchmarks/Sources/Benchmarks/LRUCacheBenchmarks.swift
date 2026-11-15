import CollectionsBenchmark
import RedBlackTreeModule

extension Benchmark {
  public mutating func addLRUCacheBenchmarks() {

    self.add(
      title: "LRUCache<Int, Int> subscript, successful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var c = LRUCache<Int, Int>(minimumCapacity: input.count)
        for i in input {
          c[i] = 2 * i
        }
        timer.measure {
          for i in lookups {
            precondition(c[i] == 2 * i)
          }
        }
        precondition(c.count == input.count)
      }
    }

    self.add(
      title: "LRUCache<Int, Int> subscript, unsuccessful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var c = LRUCache<Int, Int>(minimumCapacity: input.count)
        for i in input {
          c[i] = 2 * i
        }
        let n = input.count
        timer.measure {
          for i in lookups {
            precondition(c[i + n] == nil)
          }
        }
        precondition(c.count == input.count)
      }
    }

    self.addSimple(
      title: "LRUCache<Int, Int> subscript, insert, unique",
      input: [Int].self
    ) { input in
      var c = LRUCache<Int, Int>()
      for i in input {
        c[i] = 2 * i
      }
      precondition(c.count == input.count)
    }
  }
}
