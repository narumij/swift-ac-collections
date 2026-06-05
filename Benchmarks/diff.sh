swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-20260523-001320-4ec617d5.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-20260606-015607-174e304a.json

swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-20260523-001320-4ec617d5.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-20260606-015607-174e304a.json

swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-20260530-111633-c17f9ec2.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-20260606-015607-174e304a.json

swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-20260530-111633-c17f9ec2.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-20260606-015607-174e304a.json

swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-AtCoder2025-20260524-073303-8043cdb3.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeSet/results-20260606-015607-174e304a.json \
--output diff-set.html

swift run -c release benchmark results compare \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-AtCoder2025-20260524-073303-8043cdb3.json \
/Users/narumij/Documents/GitHub/swift-ac-collections/Benchmarks/Results/2M/RedBlackTreeDictionary/results-20260606-015607-174e304a.json \
--output diff-dict.html

swift package clean
