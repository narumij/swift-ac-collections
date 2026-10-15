import NextPermutationModule

// 期待: compile error。ownerは公開initializerを持たず、`nextPermutations()`からだけ作れる。
func constructOwnerDirectly() {
  _ = NextPermutations<Int>(copying: [1, 2])
}
