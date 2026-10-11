// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NativeEntityExtractor",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "NativeEntityExtractor",
            targets: ["NativeEntityExtractor"]),
    ],
    targets: [
        .target(
            name: "NativeEntityExtractor",
            path: "Sources"
        ),
        .testTarget(
            name: "NativeEntityExtractorTests",
            dependencies: ["NativeEntityExtractor"],
            path: "Tests"
        ),
    ]
)

// Swift 7's import rule, today: a file must import every module whose members
// it uses, rather than leaning on another file's imports.
for target in package.targets where target.type != .system && target.type != .binary && target.type != .plugin {
    target.swiftSettings = (target.swiftSettings ?? []) + [.enableUpcomingFeature("MemberImportVisibility")]
}
