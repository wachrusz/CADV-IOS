//
//  PopUpContentViews.swift
//  CADV
//
//  Created by Misha Vakhrushin on 16.09.2024.
//

import SwiftUI

struct ErrorNoConnection: View {
  var body: some View {
    VStack(spacing: 15) {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 75, height: 75)
        .background(
          AsyncImage(url: URL(string: "https://via.placeholder.com/75x75"))
        )
        .shadow(
          color: Color(red: 0.59, green: 0.28, blue: 1, opacity: 0.20), radius: 20, y: 4
        )
      VStack(spacing: 5) {
        Text("Отсутствует интернет-соединение")
          .font(Font.custom("Gilroy", size: 20).weight(.bold))
          .lineSpacing(20)
          .foregroundColor(.black)
        Text("Вы не сможете редактировать и удалять информацию в приложении, пока не возобновится соединение ")
          .font(Font.custom("Gilroy", size: 14).weight(.semibold))
          .lineSpacing(15)
          .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
      }
      .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
      HStack(spacing: 10) {
        Text("Закрыть")
          .font(Font.custom("Gilroy", size: 16).weight(.semibold))
          .lineSpacing(20)
          .foregroundColor(.black)
      }
      .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
      .frame(width: 140)
      .background(.white)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .inset(by: 1)
          .stroke(.black, lineWidth: 1)
      )
    }
    .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
    .frame(width: 300, height: 265)
    .background(.white)
    .cornerRadius(10);
  }
}

struct ErrorWrongCode: View {
  var body: some View {
    VStack(spacing: 15) {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 75, height: 75)
        .background(
          AsyncImage(url: URL(string: "https://via.placeholder.com/75x75"))
        )
        .shadow(
          color: Color(red: 0.59, green: 0.28, blue: 1, opacity: 0.20), radius: 20, y: 4
        )
      VStack(spacing: 5) {
        Text("Введен неверный код")
          .font(Font.custom("Gilroy", size: 20).weight(.bold))
          .lineSpacing(20)
          .foregroundColor(.black)
        Text("У вас осталось n попыток")
          .font(Font.custom("Gilroy", size: 14).weight(.semibold))
          .lineSpacing(15)
          .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
      }
      .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
      HStack(spacing: 10) {
        Text("Закрыть")
          .font(Font.custom("Gilroy", size: 16).weight(.semibold))
          .lineSpacing(20)
          .foregroundColor(.black)
      }
      .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
      .frame(width: 140)
      .background(.white)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .inset(by: 1)
          .stroke(.black, lineWidth: 1)
      )
    }
    .padding(EdgeInsets(top: 15, leading: 5, bottom: 15, trailing: 5))
    .frame(width: 300, height: 265)
    .background(.white)
    .cornerRadius(10);
  }
}

struct NewUpdate: View {
  var body: some View {
    VStack(spacing: 15) {
      Rectangle()
        .foregroundColor(.clear)
        .frame(width: 75, height: 75)
        .background(
          AsyncImage(url: URL(string: "https://via.placeholder.com/75x75"))
        )
        .shadow(
          color: Color(red: 0.59, green: 0.28, blue: 1, opacity: 0.20), radius: 20, y: 4
        )
      VStack(spacing: 5) {
        Text("Доступно обновление")
          .font(Font.custom("Gilroy", size: 20).weight(.bold))
          .lineSpacing(20)
          .foregroundColor(.black)
        Text("Обновите приложение, чтобы воспользоваться новыми функциями и улучшениями")
          .font(Font.custom("Gilroy", size: 14).weight(.semibold))
          .lineSpacing(15)
          .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
      }
      .frame(maxWidth: .infinity, minHeight: 70, maxHeight: 70)
      HStack(alignment: .top, spacing: 5) {
        HStack(spacing: 10) {
          Text("Обновить")
            .font(Font.custom("Gilroy", size: 16).weight(.semibold))
            .lineSpacing(20)
            .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .frame(height: 40)
        .background(.black)
        .cornerRadius(10)
      }
    }
    .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
    .frame(width: 300, height: 245)
    .background(.white)
    .cornerRadius(10);
  }
}

struct GivePermission: View {
  var body: some View {
    VStack(spacing: 15) {
      VStack(spacing: 5) {
        Text("Требуется разрешить доступ, чтобы продолжить")
          .font(Font.custom("Inter", size: 16).weight(.semibold))
          .lineSpacing(20)
          .foregroundColor(.black)
        Text("Разрешите приложению доступ к памяти устройства, чтобы установить новое изображение в профиль")
          .font(Font.custom("Gilroy", size: 14).weight(.semibold))
          .lineSpacing(15)
          .foregroundColor(Color(red: 0.60, green: 0.60, blue: 0.60))
      }
      .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
      HStack(alignment: .top, spacing: 5) {
        HStack(spacing: 10) {
          Text("Разрешить")
            .font(Font.custom("Gilroy", size: 16).weight(.semibold))
            .lineSpacing(20)
            .foregroundColor(.white)
        }
        .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
        .frame(height: 40)
        .background(.black)
        .cornerRadius(10)
      }
      HStack(spacing: 10) {
        Text("Назад")
          .font(Font.custom("Gilroy", size: 16).weight(.semibold))
          .lineSpacing(20)
          .foregroundColor(.black)
      }
      .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
      .frame(width: 140)
      .background(.white)
      .cornerRadius(10)
      .overlay(
        RoundedRectangle(cornerRadius: 10)
          .inset(by: 1)
          .stroke(.black, lineWidth: 1)
      )
    }
    .padding(EdgeInsets(top: 15, leading: 10, bottom: 15, trailing: 10))
    .frame(width: 300, height: 230)
    .background(.white)
    .cornerRadius(10);
  }
}
