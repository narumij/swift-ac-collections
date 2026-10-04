#if DEBUG && DEATH_TEST && !COMPATIBLE_ATCODER_2025
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
      // Failure-valued Index is not representable on try/index/1.
      // #expect(!map.isValid(.index(.failure(.null))))
    }
  }
#endif
