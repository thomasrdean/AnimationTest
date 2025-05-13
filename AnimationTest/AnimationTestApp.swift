//
//  AnimationTestApp.swift
//  AnimationTest
//
//  Created by Thomas Dean on 2025-05-12.
//

import SwiftUI

@main
struct AnimationTestApp: App {
    @State private var model = TestModel(GridWidth: 10)
    var body: some Scene {
        WindowGroup {
            ContentView(hasAnimation: true)
                .environment(model)
        }
    }
}
