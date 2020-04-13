// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DNDownloader",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "DNDownloader",
            targets: ["DNDownloader"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DNDownloader",
            dependencies: [],
            path: "./Sources/DNDownloader"
        ),
    ],
    swiftLanguageVersions: [
        .version("5")
    ]
)
