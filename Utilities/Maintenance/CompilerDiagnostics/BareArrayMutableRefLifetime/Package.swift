// swift-tools-version: 6.4

import PackageDescription

let package = Package(
  name: "BareArrayMutableRefLifetimeCompilerDiagnostic",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: "../../../..")
  ],
  targets: [
    .target(
      name: "BareArrayMutableRefValid",
      dependencies: [
        .product(name: "AcCollections", package: "swift-ac-collections")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]
    ),
    .target(
      name: "BareArrayMutableRefEscape",
      dependencies: [
        .product(name: "AcCollections", package: "swift-ac-collections")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]
    ),
  ]
)
