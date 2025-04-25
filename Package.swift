// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "ABCWaas",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "ABCWaas",
            targets: ["ABCWaas"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "ABCWaas",
            dependencies: ["ABCWaasCore"],
            path: "Sources/ABCWaas"),
        .binaryTarget(
            name: "ABCWaasCore",
            path: "Sources/ABCWaas/libs/ABCWaasCore.xcframework")
    ]
)
