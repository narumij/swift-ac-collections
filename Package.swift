// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var defines: [String] = [
  //  "TREE_INVARIANT_CHECKS",
  "GRAPHVIZ_DEBUG",
  //  "USING_ALGORITHMS",
  //  "USING_COLLECTIONS",
  //  "ENABLE_PERFORMANCE_TESTING",
  //  "PERFOMANCE_CHECK",
  "WITHOUT_SIZECHECK",
  //  "USE_OLD_FIND",
  //  "DEATH_TEST",
  //  "BENCHMARK",
  //  "ALLOCATION_DRILL" // リリース時はオフ
  //  "USE_C_MALLOC",
  //  "USE_INT128", // これはpackage traitにしたい
  //  "COLLECTION_BENCHMARK",
]

var _settings: [SwiftSetting] =
  [
    //    .define("COMPATIBLE_ATCODER_2025"),
    // このコードベースは当初、2025新ジャッジ搭載を目指して開発し、無事に搭載できました。
    // できましたが、引き続き開発をつづけており、APIの修正も含めて様々な改善をしています。
    // 過去版が単純なコード補完に反応しにくい設計だったこともあり、サポートプロジェクトでこちらを採用しています。
    // サポートプロジェクトで不都合を最小限にとどめるための定義モードです。

    .define("AC_COLLECTIONS_INTERNAL_CHECKS", .when(configuration: .debug)),
    // CoWの挙動チェックを可能にするマクロ定義
    // アロケーション関連のテストを走らせるために必要

    .define("TREE_INVARIANT_CHECKS", .when(configuration: .debug)),
    // ツリーの不変性チェックの有効無効を切り替えるマクロ定義
    // 対象のメソッドは必ずassertかXCTAssert...を介して利用する。
    // このため、リリース時はどちらにせよ無効になる

    .define("ENABLE_PERFORMANCE_TESTING", .when(configuration: .release)),
    // コーディング時に頻繁にテストする場合の回転向上のためのマクロ定義
    // オフにすることでいろいろスキップできる

    // .define("USE_C_MALLOC"),
    // swift_slowAllocを避ける動作をするマクロ定義
    // 少しだけパフォーマンスが改善するが、利用には注意が必要
  ]
  + defines.map { .define($0) }

let additionalDepencencies: [Target.Dependency] =
  defines.contains("USE_C_MALLOC") ? ["_malloc_free"] : []

let platforms: [SupportedPlatform]? =
  defines.contains("USE_INT128") || defines.contains("COLLECTION_BENCHMARK")
  ? [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .macCatalyst(.v18)]
  : nil

let collectionBenchmarks: [Target] =
  defines.contains("COLLECTION_BENCHMARK")
  ? (0...12).map { i in
    .executableTarget(
      name: "CollectionBenchmark\(i)",
      dependencies: [
        "RedBlackTreeModule",
        .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "SortedCollections", package: "swift-collections"),
      ],
      path: "Tests/CollectionBenchmarks/CollectionBenchmark\(i)",
      swiftSettings: _settings
    )
  } : []

// 順次削っていきたい
let _mt19937: Target = .target(
  name: "_MT19937",
  path: "Utilities/_MT19937",
  publicHeadersPath: "include",
  cxxSettings: [
    .headerSearchPath("include"),
    .define("NDEBUG", .when(configuration: .release)),
    .unsafeFlags(["-std=c++17"]),
  ])

// 順次削っていきたい
let mt19937: Target = .target(
  name: "MT19937",
  dependencies: ["_MT19937"],
  path: "Utilities/MT19937")

// 順次削っていきたい
let _fastIO: Target = .target(
  name: "_FastIO",
  path: "Utilities/_FastIO",
  publicHeadersPath: "include",
  cSettings: [
    .headerSearchPath("include"),
    .define("NDEBUG", .when(configuration: .release)),
  ])

// 順次削っていきたい
let IOUtil: Target = .target(
  name: "IOUtil",
  dependencies: ["_FastIO"],
  path: "Utilities/IOUtil",
  swiftSettings: _settings)

// 順次削っていきたい
let executableTargets: [Target] =
  [
    "Executable",
    "SimpleInsert",
    "SimpleRemove",
    "SimpleCreate",
    "SimpleValue",
    "MultiRoundTrip",
    "ABC411F",
    "LRU",
  ]
  .map { name in
    .executableTarget(
      name: "\(name)",
      dependencies: [
        "AcCollections",
        "MT19937",
        "IOUtil",
        .product(name: "Collections", package: "swift-collections"),
        .product(
          name: "SortedCollections",
          package: "swift-collections"),
      ],
      path: "Tests/Executables/\(name)")
  }
  + (0...7).map { i in
    .executableTarget(
      name: "Benchmark\(i)",
      dependencies: [
        "RedBlackTreeModule",
        "MT19937",
        "IOUtil",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Benchmark", package: "swift-benchmark"),
        .product(name: "Collections", package: "swift-collections"),
      ],
      path: "Tests/Benchmarks/Benchmark\(i)",
      swiftSettings: _settings
    )
  }
  + collectionBenchmarks

let package = Package(
  name: "swift-ac-collections",
  platforms: platforms,
  products: [.library(name: "AcCollections", targets: ["AcCollections"])],
  dependencies: [

    .package(
      url: "https://github.com/apple/swift-collections.git",
      branch: "main",
      traits: ["UnstableSortedCollections"]
    ),

    .package(
      url: "https://github.com/apple/swift-algorithms.git",
      from: "1.2.1"),

    .package(
      url: "https://github.com/google/swift-benchmark",
      from: "0.1.0"),

    //    .package(
    //      url: "https://github.com/narumij/swift-ac-foundation",
    //      branch: "main"),

    //    .package(
    //      url: "https://github.com/apple/swift-collections",
    //      from: "1.3.0"),

    .package(
      url: "https://github.com/swiftlang/swift-docc-plugin",
      from: "1.0.0"),

    .package(
      url: "https://github.com/apple/swift-collections-benchmark",
      from: "0.0.0"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.

    .target(
      name: "AcCollections",
      dependencies: ["RedBlackTreeModule", "PermutationModule"],
      swiftSettings: _settings
    ),

    .target(
      name: "_malloc_free",
      publicHeadersPath: "include",
      cSettings: [
        .headerSearchPath("include"),
        .define("NDEBUG", .when(configuration: .release)),
      ]),

    .target(
      name: "RedBlackTreeModule",
      dependencies: [] + additionalDepencencies,
      path: "Sources/RedBlackTreeModule",
      exclude: ["MEMO.md"],
      swiftSettings: _settings + [
        //        .strictMemorySafety()
      ]),

    .testTarget(
      name: "RedBlackTreeTests",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        "RedBlackTreeModule",
      ],
      swiftSettings: _settings
    ),

    .target(
      name: "PermutationModule",
      dependencies: [],
      swiftSettings: _settings
    ),
    .testTarget(
      name: "PermutationTests",
      dependencies: [
        // .product(name: "Algorithms", package: "swift-algorithms"),
        "PermutationModule"
      ],
      swiftSettings: _settings
    ),

    _mt19937,
    mt19937,
    _fastIO,
    IOUtil,
  ]
    + executableTargets
)
