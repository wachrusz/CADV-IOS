//
//  CounterTests.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import ComposableArchitecture
import Testing

@testable import CADV

@MainActor
struct CounterFeatureTests {
    @Test
    func basics() async {
        let store = TestStore(initialState: CounterFeature.State()) {
            CounterFeature()
        }
        
        await store.send(.incrementButtonTapped) {
            $0.count = 1
        }
        
        await store.send(.decrementButtonTapped) {
            $0.count = 0
        }
    }
}
