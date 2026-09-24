// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CryptoResearch",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(
            name: "CryptoResearch",
            targets: ["CryptoResearch"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.0.0")
    ],
    targets: [
        .executableTarget(
            name: "CryptoResearch",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "CryptoResearchTests",
            dependencies: [
                "CryptoResearch",
                .product(name: "GRDB", package: "GRDB.swift")
            ],
            path: "Tests",
            resources: [
                .process("TestFixtures")
            ]
        )
    ]
)
