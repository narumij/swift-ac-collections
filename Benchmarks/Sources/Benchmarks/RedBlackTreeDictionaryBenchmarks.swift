//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2021 - 2026 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
// SPDX-License-Identifier: Apache-2.0 WITH Swift-exception
//
//===----------------------------------------------------------------------===//

// modified by narumij

import CollectionsBenchmark
import RedBlackTreeModule

extension Benchmark {
  public mutating func addRedBlackTreeDictionaryBenchmarks() {
    self.add(
      title: "RedBlackTreeDictionary<Int, Int> init(uniqueKeysWithValues:)",
      input: [Int].self
    ) { input in
      return { timer in
        blackHole(
          RedBlackTreeDictionary(
            uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) }
          )
        )
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> sequential iteration",
      input: [Int].self
    ) { input in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for item in d {
          blackHole(item.key)
          blackHole(item.value)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> sequential iteration (inlined buffer)",
      input: [Int].self
    ) { input in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.map { ($0, 2 * $0) })
      return { timer in
        for item in d {
          blackHole(item.key)
          blackHole(item.value)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int>.Keys sequential iteration",
      input: [Int].self
    ) { input in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for item in d.keys {
          blackHole(item)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int>.Values sequential iteration",
      input: [Int].self
    ) { input in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for item in d.values {
          blackHole(item)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> sequential iteration, indices",
      input: [Int].self
    ) { input in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for i in d.__indices {
          blackHole(d[i])
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> indexing subscript",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      let indices = lookups.map { d.index(forKey: $0)! }
      return { timer in
        for i in indices {
          blackHole(d[i])
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, successful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for i in lookups {
          precondition(d[i] == 2 * i)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, unsuccessful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      let c = input.count
      return { timer in
        for i in lookups {
          precondition(d[i + c] == nil)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, noop setter",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        let c = input.count
        timer.measure {
          for i in lookups {
            d[i + c] = nil
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, set existing",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            d[i] = 0
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, _modify",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            d[i]! *= 2
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.addSimple(
      title: "RedBlackTreeDictionary<Int, Int> subscript, insert, unique",
      input: [Int].self
    ) { input in
      var d: RedBlackTreeDictionary<Int, Int> = [:]
      for i in input {
        d[i] = 2 * i
      }
      precondition(d.count == input.count)
      blackHole(d)
    }

    self.addSimple(
      title: "RedBlackTreeDictionary<Int, Int> subscript, insert, shared",
      input: [Int].self
    ) { input in
      var d: RedBlackTreeDictionary<Int, Int> = [:]
      for i in input {
        let copy = d
        d[i] = 2 * i
        blackHole((copy, d))
      }
      precondition(d.count == input.count)
      blackHole(d)
    }

    self.addSimple(
      title: "RedBlackTreeDictionary<Int, Int> subscript, insert, reserving capacity",
      input: [Int].self
    ) { input in
      var d: RedBlackTreeDictionary<Int, Int> = [:]
      d.reserveCapacity(input.count)
      for i in input {
        d[i] = 2 * i
      }
      precondition(d.count == input.count)
      blackHole(d)
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, remove existing, unique",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            d[i] = nil
          }
        }
        precondition(d.isEmpty)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, remove existing, shared",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            let copy = d
            d[i] = nil
            blackHole((copy, d))
          }
        }
        precondition(d.isEmpty)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript, remove missing",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        let c = input.count
        timer.measure {
          for i in lookups {
            d[i + c] = nil
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> subscript(position:)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      let indices = lookups.map { d.firstIndex(of: $0)! }
      return { timer in
        for i in indices {
          blackHole(d[i])
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> defaulted subscript, successful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for i in lookups {
          precondition(d[i, default: -1] != -1)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> defaulted subscript, unsuccessful lookups",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        let c = d.count
        for i in lookups {
          precondition(d[i + c, default: -1] == -1)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> defaulted subscript, _modify existing",
      input: [Int].self
    ) { input in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in input {
            d[i, default: -1] *= 2
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> defaulted subscript, _modify missing",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        let c = input.count
        timer.measure {
          for i in lookups {
            // TODO: CIで落ちる件の調査
             d[c + i, default: -1] *= 2

            //            Running 18 tasks on 60 sizes from 1 to 64k:
            //              RedBlackTreeSet<Int> init from range
            //              RedBlackTreeSet<Int> sequential iteration
            //              RedBlackTreeSet<Int> successful find
            //              RedBlackTreeSet<Int> unsuccessful find
            //              RedBlackTreeSet<Int> insert
            //              RedBlackTreeSet<Int> remove
            //              RedBlackTreeSet<Int> insert, shared
            //              RedBlackTreeSet<Int> remove, shared
            //              RedBlackTreeDictionary<Int, Int> init(uniqueKeysWithValues:)
            //              RedBlackTreeDictionary<Int, Int> sequential iteration
            //              RedBlackTreeDictionary<Int, Int> subscript, successful lookups
            //              RedBlackTreeDictionary<Int, Int> subscript, unsuccessful lookups
            //              RedBlackTreeDictionary<Int, Int> subscript, insert, unique
            //              RedBlackTreeDictionary<Int, Int> subscript, remove existing, unique
            //              RedBlackTreeDictionary<Int, Int> subscript, insert, shared
            //              RedBlackTreeDictionary<Int, Int> subscript, remove existing, shared
            //              RedBlackTreeDictionary<Int, Int> defaulted subscript, _modify existing
            //              RedBlackTreeDictionary<Int, Int> defaulted subscript, _modify missing
            //            Output file: /home/runner/work/swift-ac-collections/swift-ac-collections/head/benchmark-results/current.json
            //            Discarding all existing data.
            //
            //            Collecting data:
            //
            //            *** Signal 4: Backtracing from 0x55e8f46101ab... done ***
            //
            //            *** Swift runtime failure: arithmetic overflow ***
            //
            //            Platform: x86_64 Linux (Ubuntu 24.04.5 LTS)
            //
            //            Thread 0 "benchmark" crashed:
            //
            //             0 [inlined] [system]      0x000055e8f46101ab Swift runtime failure: arithmetic overflow in benchmark at //<compiler-generated>
            //             1                         0x000055e8f46101ab closure #2 in closure #1 in closure #23 in Benchmark.addRedBlackTreeDictionaryBenchmarks() + 667 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/Sources/Benchmarks/RedBlackTreeDictionaryBenchmarks.swift:336:35
            //             2 [ra]                    0x000055e8f455dc0b Timer.measure(_:) + 154 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Basics/Timer.swift:68:5
            //             3 [ra]                    0x000055e8f460feb6 closure #1 in closure #23 in Benchmark.addRedBlackTreeDictionaryBenchmarks() + 293 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/Sources/Benchmarks/RedBlackTreeDictionaryBenchmarks.swift:334:15
            //             4 [ra] [inlined]          0x000055e8f4561e85 static Timer._nestedMeasure(_:) in benchmark at Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Basics/Timer.swift:41:5
            //             5 [ra]                    0x000055e8f4561e85 Task.measure(size:input:options:) + 596 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/Task.swift:87:26
            //             6 [ra]                    0x000055e8f44cb327 _ConcreteTask.measure(size:input:options:) + 230 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/AnyTask.swift:119:18
            //             7 [ra] [inlined]          0x000055e8f44d8924 AnyTask.measure(size:input:options:) in benchmark at Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/AnyTask.swift:49:10
            //             8 [ra]                    0x000055e8f44d8924 specialized Benchmark.measureOneCycle(tasks:sizes:options:delegate:) + 1779 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/Benchmark+RunOptions.swift:40:28
            //             9 [ra] [inlined] [system] 0x000055e8f44d8f1f Benchmark.measureOneCycle(tasks:sizes:options:delegate:) in benchmark at //<compiler-generated>
            //            10 [ra]                    0x000055e8f44d8f1f specialized Benchmark.run(options:delegate:) + 206 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/Benchmark+RunOptions.swift:84:11
            //            11 [ra] [inlined] [system] 0x000055e8f4524adc Benchmark.run(options:delegate:) in benchmark at //<compiler-generated>
            //            12 [ra]                    0x000055e8f4524adc specialized _Document.run(benchmark:options:) + 3019 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/BenchmarkCLI/_Document.swift:149:19
            //            13 [ra] [inlined]          0x000055e8f44f6136 _Document.run(benchmark:options:) in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/BenchmarkCLI/BenchmarkCLI+Library+Run.swift
            //            14 [ra]                    0x000055e8f44f6136 specialized _BenchmarkCLI.Library.Run.run(benchmark:) + 3109 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/BenchmarkCLI/BenchmarkCLI+Library+Run.swift:68:20
            //            15 [ra] [inlined] [system] 0x000055e8f44f5211 _BenchmarkCLI.Library.Run.run(benchmark:) in benchmark at //<compiler-generated>
            //            16 [ra] [thunk]            0x000055e8f44f5211 protocol witness for _BenchmarkCommand.run(benchmark:) in conformance _BenchmarkCLI.Library.Run + 64 in benchmark at //<compiler-generated>:50:19
            //            17 [ra]                    0x000055e8f455e75b Benchmark.main() + 442 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/checkouts/swift-collections-benchmark/Sources/CollectionsBenchmark/Benchmark/Benchmark+Main.swift:32:21
            //            18 [ra]                    0x000055e8f442c8a8 main + 311 in benchmark at /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/Sources/benchmark-tool/main.swift:12:11
            //            19 [ra]                    0x00007fc183a2a1ca <unknown> in libc.so.6
            //            20 [ra]                    0x00007fc183a2a28b <unknown> in libc.so.6
            //
            //
            //            Registers:
            //
            //            rax 0x000055e91c7005f0  fe ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  þÿÿÿÿÿÿÿ········
            //            rdx 0x000055e91c7005f0  fe ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  þÿÿÿÿÿÿÿ········
            //            rcx 0x55e91c7000000000  6190510430159372288
            //            rbx 0x95e91c7000000000  10802196448586760192
            //            rsi 0x000055e91c7005f0  fe ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  þÿÿÿÿÿÿÿ········
            //            rdi 0x4000000000000000  4611686018427387904
            //            rbp 0x00007ffd4fe9aed0  60 af e9 4f fd 7f 00 00 0b dc 55 f4 e8 55 00 00  `¯éOý····ÜUôèU··
            //            rsp 0x00007ffd4fe9ae70  05 00 00 00 00 00 00 00 70 01 70 1c e9 55 00 00  ········p·p·éU··
            //             r8 0x000055e91c7005f0  fe ff ff ff ff ff ff ff 00 00 00 00 00 00 00 00  þÿÿÿÿÿÿÿ········
            //             r9 0x0000000000000000  0
            //            r10 0x0000000000000001  1
            //            r11 0x00007fc185ca3000  c2 d2 03 00 01 00 00 00 db 24 6a 7a ab 00 00 00  ÂÒ······Û$jz«···
            //            r12 0x000055e91c7091b0  0d 00 00 00 00 00 00 00 00 00 00 00 01 00 00 00  ················
            //            r13 0x000000000000000a  10
            //            r14 0x000055e91c7091c8  f0 05 70 1c e9 55 00 00 38 61 70 1c e9 55 00 00  ð·p·éU··8ap·éU··
            //            r15 0x0000000000000011  17
            //            rip 0x000055e8f46101ab  0f 0b 0f 0b 90 55 48 89 e5 41 57 41 56 41 55 41  ·····UH·åAWAVAUA
            //
            //            rflags 0x0000000000010a86  SF PF
            //
            //            cs 0x0033  fs 0x0000  gs 0x0000
            //
            //
            //            Images (19 omitted):
            //
            //            0x000055e8f43ce000–0x000055e8f46f16d8 8619e777cced528678e613f597817b00e8d1114c benchmark /home/runner/work/swift-ac-collections/swift-ac-collections/head/Benchmarks/.build/out/Products/Release-linux-x86_64/benchmark
            //            0x00007fc183a00000–0x00007fc183bb0039 a4a7992a8e66555c8141ab2a08a8465ff6e0ea65 libc.so.6 /usr/lib/x86_64-linux-gnu/libc.so.6
            //
            //            Backtrace took 1.11s
            //
            //            /home/runner/work/_temp/51512716-cefb-41fc-b034-9f1145aff423.sh: line 8:  2879 Illegal instruction     (core dumped) swift run -c release benchmark library run --library ./Libraries/CI.json ../benchmark-results/current.json --max-size 64k --cycles 1 --mode replace-all
            //              1.2.4...8.

//            d[c &+ i, default: -1] &*= 2
          }
        }
        precondition(d.count == 2 * input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> successful index(forKey:)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for i in lookups {
          precondition(d.index(forKey: i) != nil)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> unsuccessful index(forKey:)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      let missingLookups = lookups.map { $0 + input.count }
      return { timer in
        for i in missingLookups {
          precondition(d.index(forKey: i) == nil)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> updateValue(_:forKey:), existing",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            d.updateValue(0, forKey: i)
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> updateValue(_:forKey:), insert",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            d.updateValue(0, forKey: input.count + i)
          }
        }
        precondition(d.count == 2 * input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> random removals (existing keys)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
        timer.measure {
          for i in lookups {
            precondition(d.removeValue(forKey: i) != nil)
          }
        }
        precondition(d.count == 0)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> random removals (missing keys)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      return { timer in
        let c = input.count
        var d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { (c + $0, 2 * $0) })
        timer.measure {
          for i in lookups {
            precondition(d.removeValue(forKey: i) == nil)
          }
        }
        precondition(d.count == input.count)
        blackHole(d)
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> equality, unique",
      input: [Int].self
    ) { input in
      let keysAndValues = input.map { ($0, 2 * $0) }
      let left = RedBlackTreeDictionary(uniqueKeysWithValues: keysAndValues)
      let right = RedBlackTreeDictionary(uniqueKeysWithValues: keysAndValues)
      return { timer in
        timer.measure {
          precondition(left == right)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> equality, shared",
      input: [Int].self
    ) { input in
      let keysAndValues = input.map { ($0, 2 * $0) }
      let left = RedBlackTreeDictionary(uniqueKeysWithValues: keysAndValues)
      let right = left
      return { timer in
        timer.measure {
          precondition(left == right)
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> successful contains(key:)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      return { timer in
        for i in lookups {
          precondition(d.contains(key: i))
        }
      }
    }

    self.add(
      title: "RedBlackTreeDictionary<Int, Int> unsuccessful contains(key:)",
      input: ([Int], [Int]).self
    ) { input, lookups in
      let d = RedBlackTreeDictionary(uniqueKeysWithValues: input.lazy.map { ($0, 2 * $0) })
      let missingLookups = lookups.map { $0 + input.count }
      return { timer in
        for i in missingLookups {
          precondition(!d.contains(key: i))
        }
      }
    }

  }
}

#if false
  extension RedBlackTreeDictionary {

    @inlinable
    @inline(__always)
    func index(forKey key: Key) -> Index? {
      firstIndex(of: key)
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var keys: KeyIterator<Tree, Key, Value> {
      keys()
    }

    /// - Complexity: O(1)
    @inlinable
    @inline(__always)
    public var values: ValueIterator<Tree, Key, Value> {
      values()
    }
  }
#endif
