import CollectionsBenchmark
import iTree

extension Benchmark {
  public mutating func addITreeBenchmarks() {
    self.addSimple(
      title: "iTree RBTree<Int> insert",
      input: [Int].self
    ) { input in
      var tree = RBTree<Int>(empty: 0, capacity: 0)
      for value in input {
        tree.insert(value: value)
      }
      blackHole(tree)
    }

    self.add(
      title: "iTree RBTree<Int> successful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      var tree = RBTree<Int>(empty: 0, capacity: input.count + 1)
      for value in input {
        tree.insert(value: value)
      }

      return { timer in
        for value in lookups {
          precondition(tree.find(value: value) != nil)
        }
      }
    }

    self.add(
      title: "iTree RBTree<Int> unsuccessful find",
      input: ([Int], [Int]).self
    ) { input, lookups in
      var tree = RBTree<Int>(empty: 0, capacity: input.count + 1)
      for value in input {
        tree.insert(value: value)
      }
      let missingValues = lookups.map { $0 + input.count }

      return { timer in
        for value in missingValues {
          precondition(tree.find(value: value) == nil)
        }
      }
    }

    self.add(
      title: "iTree RBTree<Int> remove",
      input: ([Int], [Int]).self
    ) { input, removals in
      return { timer in
        var tree = RBTree<Int>(empty: 0, capacity: input.count + 1)
        for value in input {
          tree.insert(value: value)
        }

        timer.measure {
          for value in removals {
            tree.delete(value: value)
          }
        }
        precondition(tree.root == .empty)
        blackHole(tree)
      }
    }
  }
}
