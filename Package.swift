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
  //  "RESERVE_CAPACITY_BENCH"
]

var _settings: [SwiftSetting] =
  [
        .define("COMPATIBLE_ATCODER_2025"),
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
  defines.contains("USE_INT128")
  ? [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .macCatalyst(.v18)]
  : nil

let package = Package(
  name: "swift-ac-collections",
  platforms: platforms,
  products: [.library(name: "AcCollections", targets: ["AcCollections"])],
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
