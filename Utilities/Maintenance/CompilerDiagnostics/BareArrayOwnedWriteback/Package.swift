// swift-tools-version: 6.4

import PackageDescription

let package = Package(
  name: "BareArrayOwnedWritebackCompilerDiagnostic",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: "../../../..")
  ],
  targets: [
    .testTarget(
      name: "BareArrayOwnedWritebackCompilerDiagnosticTests",
      dependencies: [
        .product(name: "AcCollections", package: "swift-ac-collections")
      ],
      swiftSettings: [
        .enableExperimentalFeature("Lifetimes")
      ]
    )
  ]
)
