import PermutationModule

public func legacyPermutation() -> [Int] {
#if COMPATIBLE_ATCODER_2025
  return [1, 2].nextPermutations().map(Array.init).first ?? []
#else
  var iterator = [1, 2].nextPermutations()
  return Array(iterator.next()!)
#endif
}
