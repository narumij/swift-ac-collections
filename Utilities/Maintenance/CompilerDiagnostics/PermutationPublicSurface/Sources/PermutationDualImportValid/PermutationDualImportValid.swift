import NextPermutationModule
import PermutationModule

public func dualImportPermutation() -> [Int] {
#if COMPATIBLE_ATCODER_2025
  return [1, 2].nextPermutations().map(Array.init).first ?? []
#else
  var iterator = [1, 2].nextPermutations()
  let permutation: NextPermutations<Int>.Permutation = iterator.next()!
  return Array(permutation)
#endif
}
