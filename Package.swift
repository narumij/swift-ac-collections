// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import Foundation
import PackageDescription

var defines: [String] = [
  //  "TREE_INVARIANT_CHECKS",
  //  "USING_ALGORITHMS",
  //  "ENABLE_PERFORMANCE_TESTING",
  //  "PERFOMANCE_CHECK",
  //  "SIZECHECK",
  //  "USE_OLD_FIND",
  //  "DEATH_TEST"
  //  "BENCHMARK",
  //  "USE_C_MALLOC",
  //  "USE_INT128",
  //  "USE_RECYCLE_POOL_PROTOCOL",
  //  "USE_FRESH_POOL_PROTOCOL",
  //  "USE_COMPACT_NODE_METADATA", // これは廃止でいいかも。むしろ遅くなるし
  //    "USE_INT128",
  //  "ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND"
  //  "ENABLE_OFFSET_OVERFLOW_GUARD",

  //  "ALLOW_CROSS_TREE_INDEX"  //木をまたいだインデックスの利用を許可するかどうか

  "USE_LAZY_DETACH", // IntなIndexをできる限り模倣する為に必要だったが、staleをかなり受け入れる現行版では不要になっている
]

var _settings: [SwiftSetting] =
  [
    // このコードベースは当初、2025新ジャッジ搭載を目指して開発し、無事に搭載できました。
    // できましたが、引き続き開発をつづけており、APIの修正も含めて様々な改善をしています。
    // 過去版が単純なコード補完に反応しにくい設計だったこともあり、サポートプロジェクトでこちらを採用しています。
    // サポートプロジェクトで不都合を最小限にとどめるための定義モードです。
    //    .define("COMPATIBLE_ATCODER_2025"),

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
    // 利用可能な型アライメントが8に制限される
    .define("USE_C_MALLOC", .when(traits: ["USE_C_MALLOC"])),

    // 一部のポインタ比較で128bit幅のパス表現を用いる
    // Int.maxサイズのノード数を用いる場合に必要となるが、現実的には不要
    // 念のために用意してある
    // メモリ計算の都合、Int.max / pair.strideが上限となる
    .define("USE_INT128", .when(traits: ["USE_INT128"])),

    // オフセット計算がオーバーフロー演算になっているので、Int.max / pair.stride以上のサイズでは内部計算が不正になる
    // そこまでのメモリを積んだマシンは現実的には無いとは思うが、もしも限界付近まで利用する場合には以下が必要になる
    // チェックコードは除算を利用していて、あくまで間に合わせ実装になっている
    .define("ENABLE_OFFSET_OVERFLOW_GUARD", .when(traits: ["ENABLE_OFFSET_OVERFLOW_GUARD"])),

    // ノードの付帯情報のビット幅を半分にするマクロ定義
    // 特定の条件の操作でパフォーマンスが改善するが、取り扱えるノード数の上限がInt32.maxとなる
    // 各種ベンチマークで余り差がみられないが、removeの際のfindの速度に変化がみられる
    // TODO: AtCoderジャッジ搭載時どちらがいいか、再度確認する
    // GitHub Actionsのテスト実行時間をみると、あまり速くない事が気になる。
    .define(
      "USE_COMPACT_NODE_METADATA",
      .when(traits: ["USE_COMPACT_NODE_METADATA"])
    ),

    .define("BENCHMARK", .when(traits: ["BENCHMARK"])),

    .define("GRAPHVIZ_DEBUG", .when(traits: ["GRAPHVIZ_DEBUG"])),

    .define("DEATH_TEST", .when(platforms: [.macOS])),

    .define(
      "ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND",
      .when(traits: ["ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND"])),

    // 一応用意してあるが、あまり効果が無いどころか逆効果かもしれない
    .unsafeFlags(["-Ounchecked"], .when(configuration: .release, traits: ["_O_UNCHECKED"])),
  ]
  + defines.map { .define($0) }

let additionalDepencencies: [Target.Dependency] =
  defines.contains("USE_C_MALLOC") ? ["_malloc_free"] : []

let package = Package(
  name: "swift-ac-collections",
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
    .trait(
      name: "USE_INT128"
    ),
    .trait(
      name: "BENCHMARK"
    ),
    .trait(
      name: "GRAPHVIZ_DEBUG"
    ),
    .trait(
      name: "ENABLE_LEGACY_TREE_LOWER_UPPER_BOUND"
    ),
    .trait(
      name: "ENABLE_OFFSET_OVERFLOW_GUARD"
    ),
    .trait(
      name: "_O_UNCHECKED"
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
      dependencies: [
        "RedBlackTreeCollections",
        "RedBlackTreeModule",
        "PermutationModule",
        "OptionalArrayModule",
        "BareArrayModule",
      ],
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
      name: "RedBlackTreeCollections",
      dependencies: [] + additionalDepencencies,
      path: "Sources/RedBlackTreeCollections",
      exclude: ["Documentation"],
      swiftSettings: _settings + [
        // .strictMemorySafety()
      ]),

    .target(
      name: "RedBlackTreeModule",
      dependencies: ["RedBlackTreeCollections"],
      path: "Sources/_RedBlackTreeModule"
    ),

    .testTarget(
      name: "RedBlackTreeTests",
      dependencies: [
        .product(name: "Algorithms", package: "swift-algorithms"),
        "RedBlackTreeCollections",
      ],
      swiftSettings: _settings
    ),

    .target(
      name: "OptionalArrayModule",
    ),
    .testTarget(
      name: "OptionalArrayModuleTests",
      dependencies: [
        "OptionalArrayModule"
      ]
    ),

    .target(
      name: "BareArrayModule",
    ),
    .testTarget(
      name: "BareArrayModuleTests",
      dependencies: [
        "BareArrayModule"
      ]
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
