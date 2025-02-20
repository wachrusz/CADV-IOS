//
//  CustomSubViews.swift
//  CADV
//
//  Created by Misha Vakhrushin on 13.02.2025.
//

import SwiftUI

struct SliderIndicator: View{
    var isActive: Bool
    
    var body: some View{
        Rectangle().frame(height: 3).foregroundStyle(isActive ? .black : .gray)
    }
}
