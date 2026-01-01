// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var defines: [String] = [
  //  "AC_COLLECTIONS_INTERNAL_CHECKS",
  //  "TREE_INVARIANT_CHECKS",
  //  "GRAPHVIZ_DEBUG",
  //  "USING_ALGORITHMS",
  //  "USING_COLLECTIONS",
  //  "DISABLE_COPY_ON_WRITE", // やや危険。クラッシュは減った。Unit Testが通らない箇所が増える
  //  "ENABLE_PERFORMANCE_TESTING",
  //  "SKIP_MULTISET_INDEX_BUG",
  //  "PERFOMANCE_CHECK",
  "WITHOUT_SIZECHECK",
  "COMPATIBLE_ATCODER_2025",

  "USE_UNSAFE_TREE",
]

var _settings: [SwiftSetting] =
  [
    .define("AC_COLLECTIONS_INTERNAL_CHECKS", .when(configuration: .debug)),
    // CoWの挙動チェックを可能にするマクロ定義
    // アロケーション関連のテストを走らせるために必要

    .define("TREE_INVARIANT_CHECKS", .when(configuration: .debug)),
    // ツリーの不変性チェックの有効無効を切り替えるマクロ定義
    // 対象のメソッドは必ずassertかXCTAssert...を介して利用する。
    // このため、リリース時はどちらにせよ無効になる

    .define("ENABLE_PERFORMANCE_TESTING", .when(configuration: .release)),
    // コーディング時に頻繁にテストする場合の回転向上のためのマクロ定義

    .define("USE_ENUM_NODE_REF"),
    // この定義をオフにすると参照に符号なし整数を用い、レジスタ一本に収まるようになる
  ]
  + defines.map { .define($0) }

let package = Package(
  name: "swift-ac-collections",
  //  platforms: [.macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v10), .macCatalyst(.v17)],
  platforms: [.macOS(.v15), .iOS(.v18), .tvOS(.v18), .watchOS(.v11), .macCatalyst(.v18)],
  products: [
    // Products define the executables and libraries a package produces, making them visible to other packages.
    .library(
      name: "AcCollections",
      targets: ["AcCollections"])
  ],
  dependencies: [
    //     .package(
    //       url: "https://github.com/apple/swift-collections.git",
    //       branch: "main"
    //     ),
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
      name: "RedBlackTreeModule",
      dependencies: [],
      exclude: ["MEMO.md"],
      swiftSettings: _settings
    ),
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
        //         .product(name: "Algorithms", package: "swift-algorithms"),
        "PermutationModule"
      ],
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "Executable",
      dependencies: [
        //         .product(name: "Collections", package: "swift-collections"),
        "RedBlackTreeModule",
        "PermutationModule",
      ],
      path: "Tests/Executable",
      swiftSettings: _settings
    ),
  ]
)
