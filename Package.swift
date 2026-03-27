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
            exclude: [
                "src/stockfish/nn-1c0000000000.nnue",
                "src/stockfish/nn-37f18f62d772.nnue",
                "src/stockfish/incbin/UNLICENCE",
            ],
            sources: ["src/"],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("src/stockfish"),
                .headerSearchPath("src/stockfish/nnue"),
                .headerSearchPath("src/stockfish/syzygy"),
                .headerSearchPath("src/stockfish/incbin"),
                .define("NDEBUG"),
                .define("USE_PTHREADS"),
                .define("IS_64BIT"),
                .define("USE_POPCNT"),
                .define("USE_NEON", .when(platforms: [.iOS, .macOS])),
            ],
            linkerSettings: [
                .linkedLibrary("pthread"),
            ]
        ),

        .target(
            name: "LucidEngine",
            dependencies: ["CStockfish"],
            path: "Sources/LucidEngine"
        ),

        .testTarget(
            name: "LucidEngineTests",
            dependencies: ["LucidEngine", "CStockfish"],
            path: "Tests/LucidEngineTests"
        ),
    ],
    cxxLanguageStandard: .cxx17
)
