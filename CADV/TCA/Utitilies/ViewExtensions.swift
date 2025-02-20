//
//  ViewExtensions.swift
//  CADV
//
//  Created by Misha Vakhrushin on 06.02.2025.
//

import SwiftUI
import Foundation

extension View {
    func hideBackButton() -> some View {
        self.modifier(HideBackButtonModifier())
    }
}

struct HideBackButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(true)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}

struct CustomPadding: ViewModifier {
    let edges: Edge.Set
    let length: CGFloat

    func body(content: Content) -> some View {
        content
            .padding(edges, length)
    }
}

extension View {
    func customPadding(_ edges: Edge.Set = .all, _ length: CGFloat) -> some View {
        self.modifier(CustomPadding(edges: edges, length: length))
    }
}

extension View {
    
    func focusablePadding(_ edges: Edge.Set = .all, _ size: CGFloat? = nil) -> some View {
        modifier(FocusablePadding(edges, size))
    }
    
}

private struct FocusablePadding : ViewModifier {
    
    private let edges: Edge.Set
    private let size: CGFloat?
    @FocusState private var focused: Bool
    
    init(_ edges: Edge.Set, _ size: CGFloat?) {
        self.edges = edges
        self.size = size
        self.focused = false
    }
    
    func body(content: Content) -> some View {
        content
            .focused($focused)
            .padding(edges, size)
            .contentShape(Rectangle())
            .onTapGesture { focused = true }
    }
    
}
