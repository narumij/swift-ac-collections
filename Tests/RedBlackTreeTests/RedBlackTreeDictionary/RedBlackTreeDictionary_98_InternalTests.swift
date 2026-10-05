#if DEBUG && DEATH_TEST && !COMPATIBLE_ATCODER_2025
  @testable import RedBlackTreeCollections
  import Testing

  struct RedBlackTreeDictionaryInternalTests {

    @Test
    func boundExpressionIndexValidity() {
      let dictionary = RedBlackTreeDictionary<Int, Int>(
        uniqueKeysWithValues: (0..<10).map { ($0, $0 + 3) }
      )

      #expect(dictionary.isValid(.index(dictionary.startIndex)))
      #expect(!dictionary.isValid(.index(dictionary.endIndex)))
      #expect(!dictionary.isValid(.index(.nullptr)))
    }
  }
#endif
