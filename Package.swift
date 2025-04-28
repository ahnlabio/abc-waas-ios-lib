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
    dependencies: [
        .package(url: "https://github.com/ahnlabio/abc-mpc-ios-lib", from: "0.1.1")
    ],
    targets: [
        .target(
            name: "ABCWaas",
            dependencies: [
                "ABCWaasCore",
                .product(name: "ABCMpc", package: "abc-mpc-ios-lib", condition: .none)
            ],
            path: "Sources/ABCWaas"),
        .binaryTarget(
            name: "ABCWaasCore",
            path: "Sources/ABCWaas/libs/ABCWaasCore.xcframework")
    ]
)
