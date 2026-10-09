#if DEBUG && DEATH_TEST
  @testable import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeMultiMapInternalTests {

    @Test
    func boundExpressionIndexValidity() {
      let map = RedBlackTreeMultiMap<Int, Int>(
        keysWithValues: (0..<10).map { ($0, $0 + 3) }
      )

      #expect(map.isValid(.index(map.startIndex)))
      #expect(!map.isValid(.index(map.endIndex)))
      #expect(!map.isValid(.index(.nullptr)))
    }
  }
#endif
