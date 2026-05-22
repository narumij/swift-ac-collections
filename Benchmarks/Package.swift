// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v15), .iOS(.v18), .watchOS(.v11), .tvOS(.v18), .visionOS(.v2)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Benchmarks",
            targets: ["Benchmarks"]
        ),
    ],
    dependencies: [
      .package(name: "swift-ac-collections", path: ".."),
//      .package(
//        url: "https://github.com/narumij/swift-ac-collections",
//        branch: "release/AtCoder/2025"),
      .package(url: "https://github.com/apple/swift-collections-benchmark", from: "0.0.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Benchmarks",
            dependencies: [
              .product(name: "AcCollections", package: "swift-ac-collections"),
              .product(name: "CollectionsBenchmark", package: "swift-collections-benchmark"),
              "CppBenchmarks",
            ],
        ),
        .target(
          name: "CppBenchmarks",
        ),
        .executableTarget(
          name: "benchmark",
          dependencies: [
            "Benchmarks",
          ],
          path: "Sources/benchmark-tool",
        ),

    ],
    swiftLanguageModes: [.v6]
)
