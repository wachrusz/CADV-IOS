//
//  LocalAuthView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 11.02.2025.
//

import ComposableArchitecture
import SwiftUI

struct LocalAuthViewTCA: View {
    let store: StoreOf<LocalAuthFeature>
    
    var body: some View{
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack{
                
            }
        }
    }
}
