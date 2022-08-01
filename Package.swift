// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "XMLSig",
    products: [
        .library(
            name: "DeflateModule",
            targets: ["DeflateModule"]
        ),
        .library(
            name: "XMLSig",
            targets: ["XMLSig"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections", from: "1.0.2"),
        .package(url: "https://github.com/Kitura/BlueCryptor", from: "2.0.1"),
    ],
    targets: [
        .target(
            name: "CDeflateModule",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "DeflateModule",
            dependencies: [
                .target(name: "CDeflateModule")
            ]
        ),
        .executableTarget(
            name: "deflate",
            dependencies: [
                .target(name: "DeflateModule")
            ]
        ),
        .target(
            name: "XMLSig",
            dependencies: [
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Cryptor", package: "BlueCryptor"),
            ]
        ),
        .testTarget(
            name: "XMLSigTests",
            dependencies: [
                .target(name: "XMLSig")
            ]
        ),
    ]
)
