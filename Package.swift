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
  "USE_UNSAFE_TREE", // TODO: そのうち消す
  //"USE_OLD_FIND",
//  "ALLOCATION_DRILL" // リリース時はオフ
  
  "USE_FRESH_POOL_V1"
//    "USE_FRESH_POOL_V2"
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
    
    // .define("USE_SIMPLE_COPY_ON_WRITE"), // この定義は今後悩み
    // 注意: COMPATIBLE_ATCODER_2025が優先し、その場合この定義は無効になります。
    // 平衡二分探索木(赤黒木)の魅力と言えば、探索や削除の速度だと思います。
    // CoWが効くと都度コピーが発生し、この魅力が損なわれてしまうため、現在はキャンセル気味の動作となっています。
    // 安全側に振る場合は、(COMPATIBLE_ATCODER_2025を無効にし)、この定義を有効にしてください。
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
      from: "1.2.1"),

    .package(
      url: "https://github.com/google/swift-benchmark",
      from: "0.1.0"),

    .package(
      url: "https://github.com/narumij/swift-ac-foundation",
      branch: "main"),
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
      name: "Benchmark0",
      dependencies: [
        "RedBlackTreeModule",
        .product(name: "Benchmark", package: "swift-benchmark"),
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Benchmarks/Benchmark0",
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "Benchmark1",
      dependencies: [
        "RedBlackTreeModule",
        .product(name: "Benchmark", package: "swift-benchmark"),
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Benchmarks/Benchmark1",
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "Benchmark2",
      dependencies: [
        "RedBlackTreeModule",
        .product(name: "Algorithms", package: "swift-algorithms"),
        .product(name: "Benchmark", package: "swift-benchmark"),
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Benchmarks/Benchmark2",
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "Executable",
      dependencies: [
        //         .product(name: "Collections", package: "swift-collections"),
        "RedBlackTreeModule",
        "PermutationModule",
      ],
      path: "Tests/Executables/Executable",
      swiftSettings: _settings
    ),
    .executableTarget(
      name: "SimpleInsert",
      dependencies: [
        "AcCollections",
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Tests/Executables/SimpleInsert"),
    .executableTarget(
      name: "SimpleRemove",
      dependencies: [
        "AcCollections",
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Tests/Executables/SimpleRemove"),
    .executableTarget(
      name: "SimpleCreate",
      dependencies: [
        "AcCollections",
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Tests/Executables/SimpleCreate"),
    .executableTarget(
      name: "MarriedSource",
      dependencies: [
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
      ],
      path: "Tests/Executables/MarriedSource"),
  ]
)
