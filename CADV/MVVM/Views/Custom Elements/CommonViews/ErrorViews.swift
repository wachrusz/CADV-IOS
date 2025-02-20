//
//  ErrorsView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 29.10.2024.
//
import SwiftUI

struct ErrorScreenView: View{
    var image: String
    var text: String
    
    var body: some View{
        VStack{
            Image(image)
                .resizable()
                .frame(maxWidth: 100, maxHeight: 100)
            Text(text)
                .font(Font.custom("Inter", size: 14).weight(.semibold))
                .foregroundColor(.black)
                .cornerRadius(10)
                .frame(alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.leading)
        .background(.white)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct ErrorPopUp: View {
    @Binding var showErrorPopup: Bool
    @State private var progress: CGFloat = 1.0
    let errorMessage: String
    let font: Font = Font.custom("Inter", size: 12).weight(.semibold)
    
    var body: some View {
        VStack {
            if showErrorPopup {
                VStack(spacing: 0) {
                    CustomText(
                        text: errorMessage,
                        font: font,
                        color: Color("bg")
                    )
                    .padding(.horizontal)
                    .frame(width: 300, height: 28)
                    .background(Color("fg").opacity(0.75))

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .foregroundColor(Color("fg").opacity(0.75))
                                .frame(width: geometry.size.width, height: 2)
                            
                            Rectangle()
                                .foregroundColor(Color("m5"))
                                .frame(width: (1 - progress) * geometry.size.width, height: 2)
                                .animation(.linear(duration: 5), value: progress)
                        }
                    }
                    .frame(width: 300, height: 2)
                }
                .cornerRadius(5)
                .onAppear {
                    startProgress()
                }
            }
        }
        .padding()
        .animation(.bouncy, value: showErrorPopup)
    }
    
    private func startProgress() {
        withAnimation(.linear(duration: 5)) {
            progress = 0.0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            withAnimation {
                showErrorPopup = false
                progress = 1.0
            }
        }
    }
}
