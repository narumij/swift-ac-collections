import NextPermutationModule

// 期待: compile error。ownerは`~Copyable`なので、代入はmoveになり元の変数は使えない。
func copyOwner() {
  var original = [1, 2].nextPermutations()
  var copy = original
  _ = original.next()
  _ = copy.next()
}
