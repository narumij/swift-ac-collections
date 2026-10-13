import PermutationModule

// 期待: compile error。ownerは`Sequence`に適合しないので`for-in`できない。
func iterateWithForIn() {
  for permutation in [1, 2].nextPermutations() {
    _ = permutation
  }
}
