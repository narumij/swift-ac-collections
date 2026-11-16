import CollectionsBenchmark

var benchmark = Benchmark(title: "NextPermutations Benchmarks")
benchmark.addPermutationBenchmarks()
benchmark._addCppPermutationBenchmarks()
benchmark.main()
