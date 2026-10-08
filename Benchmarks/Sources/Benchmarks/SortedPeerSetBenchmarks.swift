// RedBlackTreeSet<Int> / SortedSet<Int> peer tasks (S01–S13).
//
// The two functions below are written as mirror images: every task has the same ID,
// input, operation order, timed region, and outside-the-timer check on both sides.
// Construction and deallocation stay outside `timer.measure` for mutating tasks.
// Each task also validates its observable result once in the prepare step, before
// returning the timed closure.

import CollectionsBenchmark
import RedBlackTreeModule
import SortedCollections

extension Benchmark {
  mutating func addRedBlackTreeSetPeerBenchmarks() {
    typealias S = RedBlackTreeSet<Int>
    let p = "RedBlackTreeSet<Int> peer "

    func insertionBuilt(_ input: SortedPeerInput) -> S {
      var s = S()
      for k in input.insertionOrder { s.insert(k) }
      return s
    }

    // S01: sorted unique ints, sorted-specialized bulk path.
    add(title: p + "S01 build sorted, specialized", input: SortedPeerInput.self) { input in
      let n = input.size
      peerCheck(S(0..<n).elementsEqual(0..<n), "S01", n)
      return { timer in
        var s: S?
        timer.measure { s = S(0..<n) }
        blackHole(s)
      }
    }

    // S02 (capability difference): sorted buffer through the general initializer.
    add(title: p + "S02 build sorted, general init", input: SortedPeerInput.self) { input in
      peerCheck(S(input.sortedKeys).elementsEqual(input.sortedKeys), "S02", input.size)
      return { timer in
        var s: S?
        timer.measure { s = S(input.sortedKeys) }
        blackHole(s)
      }
    }

    // S03: shuffled buffer through the general initializer.
    add(title: p + "S03 build shuffled, general init", input: SortedPeerInput.self) { input in
      peerCheck(S(input.insertionOrder).elementsEqual(input.sortedKeys), "S03", input.size)
      return { timer in
        var s: S?
        timer.measure { s = S(input.insertionOrder) }
        blackHole(s)
      }
    }

    // S04: incremental insertion into unique storage, no reservation.
    add(title: p + "S04 insert shuffled", input: SortedPeerInput.self) { input in
      peerCheck(insertionBuilt(input).elementsEqual(input.sortedKeys), "S04", input.size)
      return { timer in
        var s = S()
        var inserted = 0
        timer.measure {
          for k in input.insertionOrder {
            if s.insert(k).inserted { inserted += 1 }
          }
        }
        peerCheck(inserted == input.size && s.count == input.size, "S04", input.size)
        blackHole(s)
      }
    }

    // S05: successful contains.
    add(title: p + "S05 contains, hit", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where s.contains(k) { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "S05", input.size)
      return { timer in blackHole(run()) }
    }

    // S06: unsuccessful contains, misses between stored keys.
    add(title: p + "S06 contains, miss", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where s.contains(k) { found += 1 }
        return found
      }
      peerCheck(run() == 0, "S06", input.size)
      return { timer in blackHole(run()) }
    }

    // S07a: exact index lookup, hit.
    add(title: p + "S07a index lookup, hit", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where s.find(k) != s.endIndex { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "S07a", input.size)
      return { timer in blackHole(run()) }
    }

    // S07b: exact index lookup, miss.
    add(title: p + "S07b index lookup, miss", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where s.find(k) != s.endIndex { found += 1 }
        return found
      }
      peerCheck(run() == 0, "S07b", input.size)
      return { timer in blackHole(run()) }
    }

    // S08a/S08b: strict upper bound at stored keys / between stored keys.
    for (id, name, queries) in [
      ("S08a", "upper bound, at keys", \SortedPeerInput.hitQueries),
      ("S08b", "upper bound, between keys", \SortedPeerInput.missQueries),
    ] {
      add(title: p + id + " " + name, input: SortedPeerInput.self) { input in
        let s = insertionBuilt(input)
        let q = input[keyPath: queries]
        func run() -> (sum: Int, ends: Int) {
          var sum = 0
          var ends = 0
          for k in q {
            let i = s.upperBound(k)
            if i != s.endIndex { sum &+= s[i] } else { ends += 1 }
          }
          return (sum, ends)
        }
        peerCheck(run() == input.expectedUpperBounds(q), "S08", input.size)
        return { timer in blackHole(run()) }
      }
    }

    // S09: ascending iteration after the S01 build.
    add(title: p + "S09 iteration, sorted build", input: SortedPeerInput.self) { input in
      let s = S(0..<input.size)
      peerCheck(s.elementsEqual(0..<input.size), "S09", input.size)
      return { timer in
        for e in s { blackHole(e) }
      }
    }

    // S10: ascending iteration after the S04 insertion history.
    add(title: p + "S10 iteration, shuffled insertion", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      peerCheck(s.elementsEqual(input.sortedKeys), "S10", input.size)
      return { timer in
        for e in s { blackHole(e) }
      }
    }

    // S11: remove every element in a shuffled order.
    add(title: p + "S11 remove all, shuffled", input: SortedPeerInput.self) { input in
      return { timer in
        var s = insertionBuilt(input)
        var removed = 0
        timer.measure {
          for k in input.removalOrder {
            if s.remove(k) != nil { removed += 1 }
          }
        }
        peerCheck(removed == input.size && s.isEmpty, "S11", input.size)
        blackHole(s)
      }
    }

    // S12: one insertion into an O(1) copy (copy-on-write detachment).
    add(title: p + "S12 insert after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.newKey
      var check = base
      check.insert(x)
      peerCheck(
        check.count == input.size + 1 && check.contains(x) && !base.contains(x), "S12", input.size)
      return { timer in
        var c = base
        var inserted = false
        timer.measure { inserted = c.insert(x).inserted }
        peerCheck(inserted && c.count == input.size + 1, "S12", input.size)
        blackHole(c)
      }
    }

    // S13: one removal from an O(1) copy (copy-on-write detachment).
    add(title: p + "S13 remove after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.existingKey
      var check = base
      check.remove(x)
      peerCheck(
        check.count == input.size - 1 && !check.contains(x) && base.contains(x), "S13", input.size)
      return { timer in
        var c = base
        var removed: Int?
        timer.measure { removed = c.remove(x) }
        peerCheck(removed == x && c.count == input.size - 1, "S13", input.size)
        blackHole(c)
      }
    }
  }

  mutating func addSortedSetPeerBenchmarks() {
    typealias S = SortedSet<Int>
    let p = "SortedSet<Int> peer "

    func insertionBuilt(_ input: SortedPeerInput) -> S {
      var s = S()
      for k in input.insertionOrder { s.insert(k) }
      return s
    }

    // S01: sorted unique ints, sorted-specialized bulk path.
    add(title: p + "S01 build sorted, specialized", input: SortedPeerInput.self) { input in
      let n = input.size
      peerCheck(S(sortedElements: 0..<n).elementsEqual(0..<n), "S01", n)
      return { timer in
        var s: S?
        timer.measure { s = S(sortedElements: 0..<n) }
        blackHole(s)
      }
    }

    // S02 (capability difference): sorted buffer through the general initializer.
    add(title: p + "S02 build sorted, general init", input: SortedPeerInput.self) { input in
      peerCheck(S(input.sortedKeys).elementsEqual(input.sortedKeys), "S02", input.size)
      return { timer in
        var s: S?
        timer.measure { s = S(input.sortedKeys) }
        blackHole(s)
      }
    }

    // S03: shuffled buffer through the general initializer.
    add(title: p + "S03 build shuffled, general init", input: SortedPeerInput.self) { input in
      peerCheck(S(input.insertionOrder).elementsEqual(input.sortedKeys), "S03", input.size)
      return { timer in
        var s: S?
        timer.measure { s = S(input.insertionOrder) }
        blackHole(s)
      }
    }

    // S04: incremental insertion into unique storage, no reservation.
    add(title: p + "S04 insert shuffled", input: SortedPeerInput.self) { input in
      peerCheck(insertionBuilt(input).elementsEqual(input.sortedKeys), "S04", input.size)
      return { timer in
        var s = S()
        var inserted = 0
        timer.measure {
          for k in input.insertionOrder {
            if s.insert(k).inserted { inserted += 1 }
          }
        }
        peerCheck(inserted == input.size && s.count == input.size, "S04", input.size)
        blackHole(s)
      }
    }

    // S05: successful contains.
    add(title: p + "S05 contains, hit", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where s.contains(k) { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "S05", input.size)
      return { timer in blackHole(run()) }
    }

    // S06: unsuccessful contains, misses between stored keys.
    add(title: p + "S06 contains, miss", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where s.contains(k) { found += 1 }
        return found
      }
      peerCheck(run() == 0, "S06", input.size)
      return { timer in blackHole(run()) }
    }

    // S07a: exact index lookup, hit.
    add(title: p + "S07a index lookup, hit", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.hitQueries where s.index(of: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == input.size, "S07a", input.size)
      return { timer in blackHole(run()) }
    }

    // S07b: exact index lookup, miss.
    add(title: p + "S07b index lookup, miss", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      func run() -> Int {
        var found = 0
        for k in input.missQueries where s.index(of: k) != nil { found += 1 }
        return found
      }
      peerCheck(run() == 0, "S07b", input.size)
      return { timer in blackHole(run()) }
    }

    // S08a/S08b: strict upper bound at stored keys / between stored keys.
    for (id, name, queries) in [
      ("S08a", "upper bound, at keys", \SortedPeerInput.hitQueries),
      ("S08b", "upper bound, between keys", \SortedPeerInput.missQueries),
    ] {
      add(title: p + id + " " + name, input: SortedPeerInput.self) { input in
        let s = insertionBuilt(input)
        let q = input[keyPath: queries]
        func run() -> (sum: Int, ends: Int) {
          var sum = 0
          var ends = 0
          for k in q {
            if let i = s.firstIndex(after: k) { sum &+= s[i] } else { ends += 1 }
          }
          return (sum, ends)
        }
        peerCheck(run() == input.expectedUpperBounds(q), "S08", input.size)
        return { timer in blackHole(run()) }
      }
    }

    // S09: ascending iteration after the S01 build.
    add(title: p + "S09 iteration, sorted build", input: SortedPeerInput.self) { input in
      let s = S(sortedElements: 0..<input.size)
      peerCheck(s.elementsEqual(0..<input.size), "S09", input.size)
      return { timer in
        for e in s { blackHole(e) }
      }
    }

    // S10: ascending iteration after the S04 insertion history.
    add(title: p + "S10 iteration, shuffled insertion", input: SortedPeerInput.self) { input in
      let s = insertionBuilt(input)
      peerCheck(s.elementsEqual(input.sortedKeys), "S10", input.size)
      return { timer in
        for e in s { blackHole(e) }
      }
    }

    // S11: remove every element in a shuffled order.
    add(title: p + "S11 remove all, shuffled", input: SortedPeerInput.self) { input in
      return { timer in
        var s = insertionBuilt(input)
        var removed = 0
        timer.measure {
          for k in input.removalOrder {
            if s.remove(k) != nil { removed += 1 }
          }
        }
        peerCheck(removed == input.size && s.isEmpty, "S11", input.size)
        blackHole(s)
      }
    }

    // S12: one insertion into an O(1) copy (copy-on-write detachment).
    add(title: p + "S12 insert after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.newKey
      var check = base
      check.insert(x)
      peerCheck(
        check.count == input.size + 1 && check.contains(x) && !base.contains(x), "S12", input.size)
      return { timer in
        var c = base
        var inserted = false
        timer.measure { inserted = c.insert(x).inserted }
        peerCheck(inserted && c.count == input.size + 1, "S12", input.size)
        blackHole(c)
      }
    }

    // S13: one removal from an O(1) copy (copy-on-write detachment).
    add(title: p + "S13 remove after copy", input: SortedPeerInput.self) { input in
      let base = insertionBuilt(input)
      let x = input.existingKey
      var check = base
      check.remove(x)
      peerCheck(
        check.count == input.size - 1 && !check.contains(x) && base.contains(x), "S13", input.size)
      return { timer in
        var c = base
        var removed: Int?
        timer.measure { removed = c.remove(x) }
        peerCheck(removed == x && c.count == input.size - 1, "S13", input.size)
        blackHole(c)
      }
    }
  }
}
