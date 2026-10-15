import NextPermutationModule

// 期待: buildが通る。公開入口から作り、手動の`next()`で各Viewを使い終えてから進める。
func enumerateWithPublicEntryPoint() -> Int {
  var permutations: NextPermutations<Int> = [1, 2, 3].nextPermutations()
  var checksum = 0
  while let permutation: NextPermutations<Int>.Permutation = permutations.next() {
    for element in permutation {
      checksum += element
    }
  }
  return checksum
}
