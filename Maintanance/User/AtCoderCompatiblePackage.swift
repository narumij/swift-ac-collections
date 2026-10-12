// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Answer",
  platforms: [.macOS(.v26)],
  products: [
    .library(
      name: "Answer",
      targets: ["Answer"])
  ],
  dependencies: [
    // swift 5.8.1時点での既存ライブラリです
    .package(
      url: "https://github.com/apple/swift-collections",
      exact: "1.2.1"),
    // swift 5.8.1時点での既存ライブラリです。
    .package(
      url: "https://github.com/apple/swift-algorithms",
      exact: "1.2.1"),
    // swift 5.8.1時点での既存ライブラリで、実数及び複素数です。
//    .package(
//      url: "https://github.com/apple/swift-numerics",
//      exact: "1.1.0"),
    // 多倍長整数です。
    .package(
      url: "https://github.com/attaswift/BigInt",
      exact: "5.7.0"),
    // 有理数です。
    .package(
      url: "https://github.com/dankogai/swift-bignum",
      revision: "7905f4e520bb601ed02a163d3c7410aa20f39c71"),
    // SIMDです。
//    .package(
//      url: "https://github.com/keyvariable/kvSIMD.swift",
//      exact: "1.1.0"),
    // BLAS及びLAPACKです。
//    .package(
//      url: "https://github.com/brokenhandsio/accelerate-linux",
//      revision: "8eda308ea3129130e90e5c01fc437a4c5d2ca278"),
    // Atcoder LibraryのSwift版です。
    .package(
      url: "https://github.com/narumij/swift-ac-library",
      branch: "release/AtCoder/2025"),
//      .package(
//        path: "/Users/narumij/Documents/GitHub/swift-ac-library"),
    // 高速な入力、二分探索、その他便利関数です。
    .package(
      url: "https://github.com/narumij/swift-ac-foundation",
      branch: "release/AtCoder/2025"),
    // 平衡二分探索木と順列全列挙です。
    .package(
      url: "https://github.com/narumij/swift-ac-collections",
      branch: "release/AtCoder/2025"),
    //      .package(
    //        path: "/Users/narumij/Documents/GitHub/swift-ac-collections"),
    // メモ化マクロです。
    .package(
      url: "https://github.com/narumij/swift-ac-memoize",
      branch: "release/AtCoder/2025"),
    //      branch: "main"),
  ],
  targets: [
    // Targets are the basic building blocks of a package, defining a module or a test suite.
    // Targets can depend on other targets in this package and products from dependencies.
    .target(
      name: "Answer",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Algorithms", package: "swift-algorithms"),
//        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "BigNum", package: "swift-bignum"),
//        .product(name: "kvSIMD", package: "kvSIMD.swift"),
//        .product(name: "AccelerateLinux", package: "accelerate-linux"),
        .product(name: "AtCoder", package: "swift-ac-library"),
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
        .product(name: "AcCollections", package: "swift-ac-collections"),
        .product(name: "AcMemoize", package: "swift-ac-memoize"),
      ]
    ),
    .testTarget(
      name: "AnswerTests",
      dependencies: [
        "Answer"
      ]),
    .executableTarget(
      name: "Executable",
      dependencies: ["Answer"],
      swiftSettings: [
          .enableExperimentalFeature("Lifetimes"),
      ]
    ),
    .executableTarget(
      name: "Submission",
      dependencies: [
        .product(name: "Collections", package: "swift-collections"),
        .product(name: "Algorithms", package: "swift-algorithms"),
//        .product(name: "Numerics", package: "swift-numerics"),
        .product(name: "BigInt", package: "BigInt"),
        .product(name: "BigNum", package: "swift-bignum"),
//        .product(name: "kvSIMD", package: "kvSIMD.swift"),
//        .product(name: "AccelerateLinux", package: "accelerate-linux"),
        .product(name: "AtCoder", package: "swift-ac-library"),
        .product(name: "AcFoundation", package: "swift-ac-foundation"),
        .product(name: "AcCollections", package: "swift-ac-collections"),
//        .product(name: "AcMemoize", package: "swift-ac-memoize"),
      ]
    ),
  ]
)
