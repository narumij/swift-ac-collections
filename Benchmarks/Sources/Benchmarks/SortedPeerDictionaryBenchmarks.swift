// RedBlackTreeDictionary<Int, Int> / SortedDictionary<Int, Int> peer tasks (D01–D10).
//
// Mirror images in the same way as `SortedPeerSetBenchmarks.swift`. Pair inputs are
// unlabeled `[(Int, Int)]`; this statically selects SortedDictionary's unlabeled
// `init(keysWithValues:)`/`init(sortedKeysWithValues:)` overloads (the labeled
// `(key:value:)` overloads, which update stored keys, cannot match this element type)
// and RedBlackTreeDictionary's `Collection` overload of `init(uniqueKeysWithValues:)`.

import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

extension Benchmark {
  mutating func addRedBlackTreeDictionaryPeerBenchmarks() {
    typealias D = RedBlackTreeDictionary<Int, Int>
    let p = "RedBlackTreeDictionary<Int, Int> peer "

    func insertionBuilt(_ input: SortedPeerInput) -> D {
      var d = D()
      for (k, v) in input.shuffledPairs { d.updateValue(v, forKey: k) }
      return d
    }
    func matches(_ d: D, _ input: SortedPeerInput, delta: Int = 1) -> Bool {
      d.elementsEqual(input.sortedKeys) { $0.key == $1 && $0.value == $1 + delta }
    }

    // D01 (capability difference): sorted unique pairs; RedBlackTree has no sorted-only API.
    add(title: p + "D01 build sorted pairs", input: SortedPeerInput.self) { input in
      peerCheck(matches(D(uniqueKeysWithValues: input.sortedPairs), input), "D01", input.size)
      return { timer in
        var d: D?
        timer.measure { d = D(uniqueKeysWithValues: input.sortedPairs) }
        blackHole(d)
      }
    }

    // D02: shuffled unique pairs through the general initializer.
    add(title: p + "D02 build shuffled pairs, general init", input: SortedPeerInput.self) { input in
      peerCheck(matches(D(uniqueKeysWithValues: input.shuffledPairs), input), "D02", input.size)
      return { timer in
        var d: D?
        timer.measure { d = D(uniqueKeysWithValues: input.shuffledPairs) }
        blackHole(d)
      }
    }

    // D03: insert new keys (updateValue returns nil) into unique storage.
    add(title: p + "D03 insert new keys", input: SortedPeerInput.self) { input in
      peerCheck(matches(insertionBuilt(input), input), "D03", input.size)
      return { timer in
        var d = D()
        var inserted = 0
        timer.measure {
          for (k, v) in input.shuffledPairs where d.updateValue(v, forKey: k) == nil {
            inserted += 1
          }
        }
        peerCheck(inserted == input.size && d.count == input.size, "D03", input.size)
        blackHole(d)
      }
    }

    // D04: replace the value of every existing key.
    add(title: p + "D04 update existing keys", input: SortedPeerInput.self) { input in
      var check = insertionBuilt(input)
      for k in input.hitQueries { check.updateValue(k + 2, forKey: k) }
      peerCheck(matches(check, input, delta: 2), "D04", input.size)
      return { timer in
        var d = insertionBuilt(input)
        var oldSum = 0
        timer.measure {
          for k in input.hitQueries {
            if let old = d.updateValue(k + 2, forKey: k) { oldSum &+= old }
          }
        }
        peerCheck(oldSum == input.valueSum && d.count == input.size, "D04", input.size)
        blackHole(d)
      }
    }

    // D05a/D05b: subscript lookup, hit / miss.
    add(title: p + "D05a subscript, hit", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var sum = 0
        for k in input.hitQueries { if let v = d[k] { sum &+= v } }
        return sum
      }
      peerCheck(run() == input.valueSum, "D05a", input.size)
      return { timer in blackHole(run()) }
    }

    add(title: p + "D05b subscript, miss", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where d[k] != nil { found += 1 }
        return found
      }
      peerCheck(run() == 0, "D05b", input.size)
      return { timer in blackHole(run()) }
    }

    // D06a/D06b: index(forKey:), hit / miss.
    add(title: p + "D06a index lookup, hit", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where d.index(forKey: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "D06a", input.size)
      return { timer in blackHole(run()) }
    }

    add(title: p + "D06b index lookup, miss", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where d.index(forKey: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == 0, "D06b", input.size)
      return { timer in blackHole(run()) }
    }

    // D07: defaulted-subscript increment of every existing key.
    add(title: p + "D07 defaulted subscript increment", input: SortedPeerInput.self) { input in
      var check = insertionBuilt(input)
      for k in input.hitQueries { check[k, default: 0] += 1 }
      peerCheck(matches(check, input, delta: 2), "D07", input.size)
      return { timer in
        var d = insertionBuilt(input)
        timer.measure {
          for k in input.hitQueries { d[k, default: 0] += 1 }
        }
        peerCheck(d.count == input.size, "D07", input.size)
        blackHole(d)
      }
    }

    // D08: remove every key in a shuffled order.
    add(title: p + "D08 remove all, shuffled", input: SortedPeerInput.self) { input in
      return { timer in
        var d = insertionBuilt(input)
        var removedSum = 0
        timer.measure {
          for k in input.removalOrder {
            if let v = d.removeValue(forKey: k) { removedSum &+= v }
          }
        }
        peerCheck(removedSum == input.valueSum && d.isEmpty, "D08", input.size)
        blackHole(d)
      }
    }

    // D09a: ascending iteration after the D01 build.
    add(title: p + "D09a iteration, sorted build", input: SortedPeerInput.self) { input in
      let d = D(uniqueKeysWithValues: input.sortedPairs)
      peerCheck(matches(d, input), "D09a", input.size)
      return { timer in
        for e in d {
          blackHole(e.key)
          blackHole(e.value)
        }
      }
    }

    // D09b: ascending iteration after the D03 insertion history.
    add(title: p + "D09b iteration, shuffled insertion", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      peerCheck(matches(d, input), "D09b", input.size)
      return { timer in
        for e in d {
          blackHole(e.key)
          blackHole(e.value)
        }
      }
    }

    // D10a: one new-key updateValue on an O(1) copy.
    add(title: p + "D10a insert after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.newKey
      var check = base
      check.updateValue(x + 1, forKey: x)
      peerCheck(check.count == input.size + 1 && check[x] == x + 1 && base[x] == nil, "D10a", input.size)
      return { timer in
        var c = base
        var old: Int? = 0
        timer.measure { old = c.updateValue(x + 1, forKey: x) }
        peerCheck(old == nil && c.count == input.size + 1, "D10a", input.size)
        blackHole(c)
      }
    }

    // D10b: one removeValue on an O(1) copy.
    add(title: p + "D10b remove after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.existingKey
      var check = base
      _ = check.removeValue(forKey: x)
      peerCheck(check.count == input.size - 1 && check[x] == nil && base[x] == x + 1, "D10b", input.size)
      return { timer in
        var c = base
        var removed: Int?
        timer.measure { removed = c.removeValue(forKey: x) }
        peerCheck(removed == x + 1 && c.count == input.size - 1, "D10b", input.size)
        blackHole(c)
      }
    }
  }

  mutating func addSortedDictionaryPeerBenchmarks() {
    typealias D = SortedDictionary<Int, Int>
    let p = "SortedDictionary<Int, Int> peer "

    func insertionBuilt(_ input: SortedPeerInput) -> D {
      var d = D()
      for (k, v) in input.shuffledPairs { d.updateValue(v, forKey: k) }
      return d
    }
    func matches(_ d: D, _ input: SortedPeerInput, delta: Int = 1) -> Bool {
      d.elementsEqual(input.sortedKeys) { $0.key == $1 && $0.value == $1 + delta }
    }

    // D01 (capability difference): sorted unique pairs, sorted-only initializer.
    add(title: p + "D01 build sorted pairs", input: SortedPeerInput.self) { input in
      peerCheck(matches(D(sortedKeysWithValues: input.sortedPairs), input), "D01", input.size)
      return { timer in
        var d: D?
        timer.measure { d = D(sortedKeysWithValues: input.sortedPairs) }
        blackHole(d)
      }
    }

    // D02: shuffled unique pairs through the general initializer.
    add(title: p + "D02 build shuffled pairs, general init", input: SortedPeerInput.self) { input in
      peerCheck(matches(D(keysWithValues: input.shuffledPairs), input), "D02", input.size)
      return { timer in
        var d: D?
        timer.measure { d = D(keysWithValues: input.shuffledPairs) }
        blackHole(d)
      }
    }

    // D03: insert new keys (updateValue returns nil) into unique storage.
    add(title: p + "D03 insert new keys", input: SortedPeerInput.self) { input in
      peerCheck(matches(insertionBuilt(input), input), "D03", input.size)
      return { timer in
        var d = D()
        var inserted = 0
        timer.measure {
          for (k, v) in input.shuffledPairs where d.updateValue(v, forKey: k) == nil {
            inserted += 1
          }
        }
        peerCheck(inserted == input.size && d.count == input.size, "D03", input.size)
        blackHole(d)
      }
    }

    // D04: replace the value of every existing key.
    add(title: p + "D04 update existing keys", input: SortedPeerInput.self) { input in
      var check = insertionBuilt(input)
      for k in input.hitQueries { check.updateValue(k + 2, forKey: k) }
      peerCheck(matches(check, input, delta: 2), "D04", input.size)
      return { timer in
        var d = insertionBuilt(input)
        var oldSum = 0
        timer.measure {
          for k in input.hitQueries {
            if let old = d.updateValue(k + 2, forKey: k) { oldSum &+= old }
          }
        }
        peerCheck(oldSum == input.valueSum && d.count == input.size, "D04", input.size)
        blackHole(d)
      }
    }

    // D05a/D05b: subscript lookup, hit / miss.
    add(title: p + "D05a subscript, hit", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var sum = 0
        for k in input.hitQueries { if let v = d[k] { sum &+= v } }
        return sum
      }
      peerCheck(run() == input.valueSum, "D05a", input.size)
      return { timer in blackHole(run()) }
    }

    add(title: p + "D05b subscript, miss", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where d[k] != nil { found += 1 }
        return found
      }
      peerCheck(run() == 0, "D05b", input.size)
      return { timer in blackHole(run()) }
    }

    // D06a/D06b: index(forKey:), hit / miss.
    add(title: p + "D06a index lookup, hit", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where d.index(forKey: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "D06a", input.size)
      return { timer in blackHole(run()) }
    }

    add(title: p + "D06b index lookup, miss", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where d.index(forKey: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == 0, "D06b", input.size)
      return { timer in blackHole(run()) }
    }

    // D07: defaulted-subscript increment of every existing key.
    add(title: p + "D07 defaulted subscript increment", input: SortedPeerInput.self) { input in
      var check = insertionBuilt(input)
      for k in input.hitQueries { check[k, default: 0] += 1 }
      peerCheck(matches(check, input, delta: 2), "D07", input.size)
      return { timer in
        var d = insertionBuilt(input)
        timer.measure {
          for k in input.hitQueries { d[k, default: 0] += 1 }
        }
        peerCheck(d.count == input.size, "D07", input.size)
        blackHole(d)
      }
    }

    // D08: remove every key in a shuffled order.
    add(title: p + "D08 remove all, shuffled", input: SortedPeerInput.self) { input in
      return { timer in
        var d = insertionBuilt(input)
        var removedSum = 0
        timer.measure {
          for k in input.removalOrder {
            if let v = d.removeValue(forKey: k) { removedSum &+= v }
          }
        }
        peerCheck(removedSum == input.valueSum && d.isEmpty, "D08", input.size)
        blackHole(d)
      }
    }

    // D09a: ascending iteration after the D01 build.
    add(title: p + "D09a iteration, sorted build", input: SortedPeerInput.self) { input in
      let d = D(sortedKeysWithValues: input.sortedPairs)
      peerCheck(matches(d, input), "D09a", input.size)
      return { timer in
        for e in d {
          blackHole(e.key)
          blackHole(e.value)
        }
      }
    }

    // D09b: ascending iteration after the D03 insertion history.
    add(title: p + "D09b iteration, shuffled insertion", input: SortedPeerInput.self) { input in
      let d = insertionBuilt(input)
      peerCheck(matches(d, input), "D09b", input.size)
      return { timer in
        for e in d {
          blackHole(e.key)
          blackHole(e.value)
        }
      }
    }

    // D10a: one new-key updateValue on an O(1) copy.
    add(title: p + "D10a insert after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.newKey
      var check = base
      check.updateValue(x + 1, forKey: x)
      peerCheck(check.count == input.size + 1 && check[x] == x + 1 && base[x] == nil, "D10a", input.size)
      return { timer in
        var c = base
        var old: Int? = 0
        timer.measure { old = c.updateValue(x + 1, forKey: x) }
        peerCheck(old == nil && c.count == input.size + 1, "D10a", input.size)
        blackHole(c)
      }
    }

    // D10b: one removeValue on an O(1) copy.
    add(title: p + "D10b remove after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.existingKey
      var check = base
      _ = check.removeValue(forKey: x)
      peerCheck(check.count == input.size - 1 && check[x] == nil && base[x] == x + 1, "D10b", input.size)
      return { timer in
        var c = base
        var removed: Int?
        timer.measure { removed = c.removeValue(forKey: x) }
        peerCheck(removed == x + 1 && c.count == input.size - 1, "D10b", input.size)
        blackHole(c)
      }
    }
  }
}
