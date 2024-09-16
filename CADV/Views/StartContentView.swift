//
//  StartContentView.swift
//  CADV
//
//  Created by Misha Vakhrushin on 08.09.2024.
//

import SwiftUI


struct Start: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.white
                    .edgesIgnoringSafeArea(.all)

                NavigationLink(destination: NewUser()) {
                    VStack {
                        Spacer()

                        Text("Cash Advisor")
                            .font(Font.custom("Montserrat", size: 50).weight(.bold))
                            .foregroundColor(.black)
                            .padding(.bottom, 10)

                        Text("Управляйте личными финансами эффективно")
                            .font(Font.custom("Inter", size: 14).weight(.semibold))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            .padding(.bottom, 50)

                        Spacer()

                        Text("Нажмите, чтобы продолжить")
                            .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                            .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                            .padding(.bottom, 50)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

struct NewUser: View {
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("#финздоровье\n#акции\n#дивиденды\n#финграм\n#благосостояние\n#обязательства\n#Cash Advisor\n#активы\n#инвестиции\n#налоги\n#банки\n#сбережения\n#планирование")
                    .font(Font.custom("Montserrat", size: 40).weight(.bold))
                    .foregroundColor(Color(red: 0.94, green: 0.94, blue: 0.94))
                    .padding()

                Spacer()

                VStack(alignment: .center, spacing: 20) {
                    HStack(spacing: 20) {
                            NavigationLink(destination: RegisterContentView()){
                                Text("Регистрация")
                                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(width: 140, height: 40)
                                    .background(Color.black)
                                    .cornerRadius(10)
                            }
                            NavigationLink(destination: LoginContentView()) {
                                Text("Вход")
                                    .font(Font.custom("Gilroy", size: 16).weight(.semibold))
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(width: 140, height: 40)
                                    .background(Color.white)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.black, lineWidth: 1)
                                    )
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    Text("Зарегистрируйтесь, если у Вас нет аккаунта, \nили войдите, если аккаунт уже создан")
                        .font(Font.custom("Inter", size: 12).weight(.semibold))
                        .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 8)

                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct StartContentView: View {
    var body: some View {
        Start()
    }
}
