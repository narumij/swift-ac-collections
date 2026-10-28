# Third-party licenses

LLVM libc++'s red-black tree implementation is the source of code adapted for this library. Swift adaptations and modifications are identified in the source headers.

- License: [LLVM-libcxx.txt](LLVM-libcxx.txt), copied without modification.
- Source: https://raw.githubusercontent.com/llvm/llvm-project/main/libcxx/LICENSE.TXT
- Retrieved: 2026-10-29
- SHA-256: `539dd7aed86e8a4f12cbdd0e6c50c189c7d74847e4fecc64ce2c6ee3a01da38b`

This is a copy of the upstream license retrieved on the date above. The revision originally used for the Swift port has not yet been identified. The file includes historical notices; inclusion does not imply that every historical license applies to every adapted file.

The project license is in [LICENSE](../LICENSE). Original third-party notices remain in the source files.

## Swift Collections and Swift Algorithms

- [swift-collections](swift-collections.txt): copied unchanged from https://raw.githubusercontent.com/apple/swift-collections/main/LICENSE.txt on 2026-10-29. SHA-256: `770af8291f708538d8ff885a0bbc4e045cd700531741c4f99528d435c14d7f55`.
- [swift-algorithms](swift-algorithms.txt): copied unchanged from https://raw.githubusercontent.com/apple/swift-algorithms/main/LICENSE.txt on 2026-10-29. SHA-256: `770af8291f708538d8ff885a0bbc4e045cd700531741c4f99528d435c14d7f55`.

Both license files include the Runtime Library Exception.

Source references found in this repository:

- Swift Collections: `Sources/RedBlackTreeCollections/Implements/Misc/Description.swift`, adapted from `Sources/InternalCollectionsUtilities/Descriptions.swift`.
- Swift Algorithms: `Sources/NextPermutationModule/Compatibility/AtCoder2025/NextPermutationProtocol.swift`, with references to `Sources/Algorithms/Permutations.swift` and `Rotate.swift`.

The maintainer confirmed that the permutation code comes from Swift Algorithms and the description helpers come from Swift Collections. The permutation file's header has been corrected accordingly. The original imported revisions remain unidentified; these license copies do not complete a file-by-file provenance audit.

The maintainer reports that LLVM porting took place from approximately 2023 through recent development; this is a time range, not an identified upstream revision.
