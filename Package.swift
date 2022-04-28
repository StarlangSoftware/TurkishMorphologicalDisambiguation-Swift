// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MorphologicalDisambiguation",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "MorphologicalDisambiguation",
            targets: ["MorphologicalDisambiguation"]),
    ],
    dependencies: [
        .package(name: "AnnotatedTree", url: "https://github.com/StarlangSoftware/AnnotatedTree-Swift.git", .exact("1.0.3")),
        .package(name: "NGram", url: "https://github.com/StarlangSoftware/NGram-Swift.git", .exact("1.0.3")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "MorphologicalDisambiguation",
            dependencies: ["AnnotatedTree", "NGram"],
            resources: [.process("rootlist.txt"),.process("penntreebank.txt")]),
        .testTarget(
            name: "MorphologicalDisambiguationTests",
            dependencies: ["MorphologicalDisambiguation"]),
    ]
)
