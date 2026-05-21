// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var defines: [String] = [
  //  "TREE_INVARIANT_CHECKS",
  //  "GRAPHVIZ_DEBUG",
  //  "USING_ALGORITHMS",
  //  "USING_COLLECTIONS",
  //  "ENABLE_PERFORMANCE_TESTING",
  //  "PERFOMANCE_CHECK",
  "WITHOUT_SIZECHECK"
  //  "USE_OLD_FIND",
  //    "DEATH_TEST",
  //  "BENCHMARK",
  //  "ALLOCATION_DRILL" // リリース時はオフ
  //  "USE_C_MALLOC",
  //  "USE_INT128", // これはpackage traitにしたい
  //  "RESERVE_CAPACITY_BENCH",
  //  "USE_RECYCLE_POOL_PROTOCOL",
  //  "USE_FRESH_POOL_PROTOCOL",
  //  "USE_COMPACT_NODE_METADATA",
]

var _settings: [SwiftSetting] =
  [
    // このコードベースは当初、2025新ジャッジ搭載を目指して開発し、無事に搭載できました。
    // できましたが、引き続き開発をつづけており、APIの修正も含めて様々な改善をしています。
    // 過去版が単純なコード補完に反応しにくい設計だったこともあり、サポートプロジェクトでこちらを採用しています。
    // サポートプロジェクトで不都合を最小限にとどめるための定義モードです。
    .define("COMPATIBLE_ATCODER_2025"),

    // CoWの挙動チェックを可能にするマクロ定義
    // アロケーション関連のテストを走らせるために必要
    .define("AC_COLLECTIONS_INTERNAL_CHECKS", .when(configuration: .debug)),

    // ツリーの不変性チェックの有効無効を切り替えるマクロ定義
    // 対象のメソッドは必ずassertかXCTAssert...を介して利用する。
    // このため、リリース時はどちらにせよ無効になる
    .define("TREE_INVARIANT_CHECKS", .when(configuration: .debug)),

    // コーディング時に頻繁にテストする場合の回転向上のためのマクロ定義
    // オフにすることでいろいろスキップできる
    .define("ENABLE_PERFORMANCE_TESTING", .when(configuration: .release)),

    // swift_slowAllocを避ける動作をするマクロ定義
    // 少しだけパフォーマンスが改善するが、利用には注意が必要
    .define(
      "USE_C_MALLOC",
      .when(traits: ["USE_C_MALLOC"])
    ),
    
    // ノードの付帯情報のビット幅を半分にするマクロ定義
    // 特定の条件の操作でパフォーマンスが改善するが、取り扱えるノード数の上限がInt32.maxとなる
    // TODO: AtCoderジャッジ搭載時はオンにする
    .define(
      "USE_COMPACT_NODE_METADATA",
      .when(traits: ["USE_COMPACT_NODE_METADATA"])
    ),
  ]
  + defines.map { .define($0) }

let additionalDepencencies: [Target.Dependency] =
  defines.contains("USE_C_MALLOC") ? ["_malloc_free"] : []

let platforms: [SupportedPlatform]? =
  defines.contains("USE_INT128")
  ? [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .macCatalyst(.v18)]
  : nil

let package = Package(
  name: "swift-ac-collections",
  platforms: platforms,
  products: [.library(name: "AcCollections", targets: ["AcCollections"])],
  traits: [
    .trait(
      name: "USE_COMPACT_NODE_METADATA",
      description:
        "Use compact node metadata to reduce memory footprint and improve cache locality. This may limit the maximum number of nodes in a single tree."
    ),
    .trait(
      name: "USE_C_MALLOC"
    ),
  ],
  dependencies: [

    .package(
      url: "https://github.com/apple/swift-algorithms.git",
      from: "1.2.1")
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
      path: "Sources/RedBlackTreeCollections",
      exclude: ["MEMO.md"],
      swiftSettings: _settings + [
        // .strictMemorySafety()
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
  ]
)
