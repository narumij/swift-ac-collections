// swift-tools-version: 6.4

import PackageDescription

// runtime-check版`NextPermutations`の公開表面のcompile fixture（PERM-056 G0）。
// `PermutationSurfaceValid`はbuildが通ること、他の3 targetはbuildが失敗することを
// `Utilities/Maintenance/VerifyPermutationCompilerDiagnostics.sh`が検証する。
let package = Package(
  name: "PermutationPublicSurfaceCompilerDiagnostic",
  platforms: [.macOS(.v15)],
  dependencies: [
    .package(path: "../../../..")
  ],
  targets: [
    .target(
      name: "PermutationSurfaceValid",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationLegacyImportValid",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationFacadeImportValid",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationDualImportValid",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationDirectInit",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationCopy",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
    .target(
      name: "PermutationSequence",
      dependencies: [.product(name: "AcCollections", package: "swift-ac-collections")]
    ),
  ]
)
