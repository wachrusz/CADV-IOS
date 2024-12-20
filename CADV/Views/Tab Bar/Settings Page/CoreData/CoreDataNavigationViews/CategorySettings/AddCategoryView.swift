//
//  AddCategory.swift
//  CADV
//
//  Created by Misha Vakhrushin on 07.11.2024.
//

import SwiftUI
import CoreData

struct AddCategory: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) var dismiss
    
    @State var name: String = ""
    @Binding var category: String
    @State var navigationTitle: String
    @State var isConstant: Bool = false
    @State var imageName: String = "-"
    @State private var showErrorPopup: Bool = false
    @State private var errorMessage: String = ""
    
    let availableIcons: [String] = [
        "tech", "auto", "beach", "cash", "deal"
    ]
    
    var body: some View {
        ZStack{
            VStack(alignment: .center){
                CategoryPreview(
                    imageName: $imageName,
                    name: $name
                )
                HStack{
                    Picker("тут иконка", selection: $imageName) {
                        ForEach(availableIcons, id: \.self) { icon in
                            Image(icon)
                                .resizable()
                                .frame(width: 40, height: 40)
                        }
                    }
                    .pickerStyle(NavigationLinkPickerStyle())
                    .frame(maxWidth: 60, maxHeight: 40)
                    
                    TextField("Название категории", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(15)
                        .frame(maxHeight: 40)
                }
                HStack {
                    Button(action: {
                        isConstant = true
                    }) {
                        Text("Постоянный")
                            .fontWeight(isConstant ? .bold : .regular)
                            .foregroundColor(isConstant ? .white : .black)
                            .padding()
                            .background(isConstant ? Color.black : Color.white)
                            .cornerRadius(15)
                            .frame(maxHeight: 40)
                    }
                    
                    Button(action: {
                        isConstant = false
                    }) {
                        Text("Переменный")
                            .fontWeight(!isConstant ? .bold : .regular)
                            .foregroundColor(!isConstant ? .white : .black)
                            .padding()
                            .background(!isConstant ? Color.black : Color.white)
                            .cornerRadius(15)
                            .frame(maxHeight: 40)
                    }
                }
                .padding(.vertical, 10)
                ActionDissmisButtons(
                    action: saveCategory,
                    actionTitle: "Сохранить"
                )
                Spacer()
            }
            if showErrorPopup {
                VStack {
                    Text(errorMessage)
                        .font(Font.custom("Inter", size: 14).weight(.semibold))
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.red, lineWidth: 2))
                        .scaleEffect(1.1)
                        .transition(.scale)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6))
                    Spacer()
                }
                .padding()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showErrorPopup = false
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .colorScheme(.light)
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationTitle(navigationTitle)
    }
    private func saveCategory() {
        if check(){
            let newCategory = CategoryEntity(context: managedObjectContext)
            newCategory.name = name
            newCategory.categoryType = category
            newCategory.isConstant = isConstant
            newCategory.iconName = imageName
            
            do {
                try managedObjectContext.save()
                dismiss()
            } catch {
                print("Ошибка сохранения категории: \(error)")
            }
        }else{
            
        }
    }
    
    private func check() -> Bool{
        if name.isEmpty{
            showError(message: "Название не должно быть пустым")
            return false
        }
        if imageName.isEmpty || imageName == "-"{
            showError(message: "Вы обязаны выбрать иконку")
            return false
        }
        return true
    }
    private func showError(message: String) {
        errorMessage = message
        withAnimation {
            showErrorPopup = true
        }
    }
}

struct CategoryPreview: View{
    @Binding var imageName: String
    @Binding var name: String
    var amountText: String = "0"
    var body: some View{
        HStack{
            HStack{
                Image(imageName)
                    .resizable()
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(15)
                if name.isEmpty{
                    Text("Название")
                }else{
                    Text(name)
                }
            }
            .frame(alignment: .leading)
            HStack{
                Text(amountText)
            }
            .frame(idealWidth: 300,alignment: .trailing)
        }
    }
}
