import CollectionsBenchmark
import Benchmarks

var benchmark = Benchmark(title: "AcCollection Benchmarks")
benchmark.registerCustomGenerators()
benchmark.addSetBenchmarks()
benchmark.addDictionaryBenchmarks()
benchmark.addCppBenchmarks()
benchmark.addRedBlackTreeSetBenchmarks()
benchmark.addRedBlackTreeDictionaryBenchmarks()
benchmark.main()

// swift run -c release benchmark library run --library ./Libraries/RedBlackTreeSet.json results.json --max-size 2M --cycles 1  --mode replace-all

// swift run -c release benchmark library render --library ./Libraries/RedBlackTreeSet.json results.json --max-time 10us --min-time 1ns --percentile 90 --output .

// swift run -c release benchmark library run --library ./Libraries/RedBlackTreeSet.json results.16M.json --max-size 16M --cycles 1  --mode replace-all

// swift run -c release benchmark library render --library ./Libraries/RedBlackTreeSet.json results.16M.json --max-time 10us --min-time 1ns --percentile 90 --output .

// swift run -c release benchmark library run --library ./Libraries/RedBlackTreeDictionary.json results.json --max-size 16M --cycles 1  --mode replace-all

// swift run -c release benchmark library render --library ./Libraries/RedBlackTreeDictionary.json results.json --max-time 10us --min-time 1ns --percentile 90 --output .

// swift run -c release benchmark library run --library ./Libraries/Subscript.json results.subscript.1.json --max-size 1M --cycles 1 --mode replace-all

// swift run -c release benchmark library render --library ./Libraries/Subscript.json results.subscript.1.json --max-time 10us --min-time 1ns --percentile 90 --output .

// swift run -c release benchmark results compare results.subscript.base.json results.subscript.1.json
