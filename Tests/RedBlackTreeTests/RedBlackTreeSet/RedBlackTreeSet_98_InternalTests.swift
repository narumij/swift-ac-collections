#if DEBUG && DEATH_TEST && !COMPATIBLE_ATCODER_2025
  @testable import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeSetInternalTests {

    @Test
    func boundExpressionIndexValidity() {
      let set = RedBlackTreeSet<Int>(0..<10)

      #expect(set.isValid(.index(set.startIndex)))
      #expect(!set.isValid(.index(set.endIndex)))
      #expect(!set.isValid(.index(.nullptr)))
    }
  }
#endif
