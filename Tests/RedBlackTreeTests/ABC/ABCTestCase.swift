class ABCTestCase: RedBlackTreeTestCase {
  @inline(never)
  func print(_ items: Any...) {
    blackHole(items)
  }
}
