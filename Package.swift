//
//  Package.swift
//  CADV
//
//  Created by Misha Vakhrushin on 05.02.2025.
//

let package = Package(
  dependencies: [
    .package(
      url: "https://github.com/pointfreeco/swift-composable-architecture",
      from: "1.0.0"
    ),
  ],
  targets: [
    .target(
      name: "CADV",
      dependencies: [
        .product(
          name: "ComposableArchitecture",
          package: "swift-composable-architecture"
        )
      ]
    )
  ]
)
