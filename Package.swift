// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "LucidEngine",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .library(
            name: "LucidEngine",
            targets: ["LucidEngine"]
        ),
    ],
    targets: [
        .target(
            name: "CStockfish",
            path: "Sources/CStockfish",
            sources: ["src/"],
            publicHeadersPath: "include"
        ),

        .target(
            name: "LucidEngine",
            dependencies: ["CStockfish"],
            path: "Sources/LucidEngine"
        ),

        .testTarget(
            name: "LucidEngineTests",
            dependencies: ["LucidEngine"],
            path: "Tests/LucidEngineTests"
        ),
    ]
)
