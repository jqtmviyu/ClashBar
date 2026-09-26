// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "ClashBar",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "ClashBar", targets: ["ClashBar"]),
        .executable(name: "ClashBarProxyHelper", targets: ["ClashBarProxyHelper"]),
        .executable(name: "ClashBarLoginItem", targets: ["ClashBarLoginItem"]),
    ],
    targets: [
        .target(
            name: "ProxyHelperShared",
            path: "Sources/ProxyHelperShared"),
        .executableTarget(
            name: "ClashBar",
            dependencies: ["ProxyHelperShared"],
            path: "Sources/ClashBar",
            resources: [
                .process("Resources"),
            ]),
        .executableTarget(
            name: "ClashBarProxyHelper",
            dependencies: ["ProxyHelperShared"],
            path: "Sources/ProxyHelper/Daemon",
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/ProxyHelper/LaunchServices/Info.plist",
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__launchd_plist",
                    "-Xlinker", "Sources/ProxyHelper/LaunchServices/com.clashbar.helper.plist",
                ])),
        ),
        .executableTarget(
            name: "ClashBarLoginItem",
            path: "Sources/ClashBarLoginItem"),
    ])
