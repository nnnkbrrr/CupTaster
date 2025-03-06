//
//  Recipe View.swift
//  CupTaster
//
//  Created by Nikita on 1/9/25.
//

import SwiftUI

struct RecipeView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var recipe: Recipe
    @State var imagePreviewIsActive: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                GeneralInfoView(recipe: recipe)
                StepsView(recipe: recipe)
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .onTapGesture { UIApplication.shared.endEditing(true) }
        .navigationTitle(recipe.name == "" ? "Новый рецепт" : recipe.name)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "photo.badge.arrow.down.fill")
                    .frame(width: .large, height: .large)
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        imagePreviewIsActive = true
                    }
            }
        }
        .defaultNavigationBar()
        .overlay {
            if imagePreviewIsActive {
                RecipeImagePreview(recipe: recipe, isPresented: $imagePreviewIsActive)
            }
        }
    }
    
    struct GeneralInfoView: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var recipe: Recipe
        
        @FocusState private var focusedField: FocusField?
        enum FocusField { case name, grindSize, temperature, coffeeAmount, waterAmount, notes }
        
        var body: some View {
            TextField("Name", text: $recipe.name)
                .focused($focusedField, equals: .name)
                .onSubmit { focusedField = .grindSize }
                .submitLabel(.next)
                .recipeRow()
                .onTapGesture { focusedField = .name }
            
            HStack(spacing: .extraSmall) {
                VStack(alignment: .leading, spacing: .extraSmall) {
                    Text("Помол")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    TextField("Помол", text: $recipe.grindSize)
                        .focused($focusedField, equals: .grindSize)
                        .onSubmit { focusedField = .temperature }
                        .submitLabel(.next)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .recipeRow()
                .onTapGesture { focusedField = .grindSize }
                
                VStack(alignment: .leading) {
                    Text("Температура (ºC)")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    TextField("0", text: $recipe.temperature)
                        .focused($focusedField, equals: .temperature)
                        .keyboardType(.numberPad)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .recipeRow()
                .onTapGesture { focusedField = .temperature }
            }
            
            HStack(spacing: .extraSmall) {
                VStack(alignment: .leading, spacing: .extraSmall) {
                    Text("Кол-во кофе (г.)")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    TextField("0", text: $recipe.coffeeAmount)
                        .focused($focusedField, equals: .coffeeAmount)
                        .keyboardType(.numberPad)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .recipeRow()
                .onTapGesture { focusedField = .coffeeAmount }
                
                VStack(alignment: .leading) {
                    Text("Кол-во воды (г.)")
                        .foregroundStyle(.gray)
                        .font(.caption)
                    
                    TextField("0", text: $recipe.waterAmount)
                        .focused($focusedField, equals: .waterAmount)
                        .keyboardType(.numberPad)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .recipeRow()
                .onTapGesture { focusedField = .waterAmount }
            }
            
            ZStack {
                if recipe.notes == "" {
                    Text("Add notes")
                } else {
                    Text(recipe.notes)
                }
            }
            .padding(.extraSmall)
            .font(.caption)
            .foregroundStyle(.gray)
            .background {
                TextField("Add notes", text: $recipe.notes)
                    .opacity(0)
                    .offset(y: 150)
                    .focused($focusedField, equals: .notes)
                    .onChange(of: focusedField) { _ in save(moc) }
            }
            .onTapGesture {
                focusedField = .notes
            }
        }
    }
    
    struct StepsView: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var recipe: Recipe
        
        var body: some View {
            Text("Рецепт")
                .font(.title2)
                .padding(.top, .regular)
                .padding([.bottom, .leading], .extraSmall)
            
            ForEach(recipe.sortedSteps) { step in
                SwipeView(gestureType: .highPriority) {
                    RecipeStepView(step: step)
                } trailingActions: { _ in
                    SwipeActionView(systemImage: "trash.fill", title: "Delete", color: .red) {
                        withAnimation {
                            recipe.removeFromSteps(step)
                            save(moc)
                        }
                    }
                }
                .defaultSwipeStyle()
            }
            
            Button {
                let newStep: RecipeStep = .init(context: moc)
                newStep.time = ""
                newStep.coffeeAmount = ""
                newStep.ordinalNumber = (recipe.sortedSteps.last?.ordinalNumber ?? 0) + 1
                recipe.addToSteps(newStep)
                save(moc)
            } label: {
                Image(systemName: "plus")
                    .padding(.regular)
                    .background(Color.backgroundSecondary)
                    .clipShape(Circle())
            }
            .frame(maxWidth: .infinity)
            .padding(.top, .small)
        }
    }
}

private extension View {
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct RecipeStepView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var step: RecipeStep
    
    @FocusState private var focusedField: FocusField?
    enum FocusField { case time, coffeeAmount }
    
    @State var timeTemp: String = "-"
    @State var selectedTimeComponent: Int = 0
    
    var body: some View {
        HStack(spacing: .extraSmall) {
            HStack(spacing: 0) {
                let timeComponents: [String] = Array(step.time).map { String($0) }
                
                TextWithSelection(string: timeComponents[safe: 0], isSelected: Binding(get: {
                    focusedField == .time && selectedTimeComponent == 0
                }, set: { _ in }), placeholder: "0")
                Text(":")
                TextWithSelection(string: timeComponents[safe: 1], isSelected: Binding(get: {
                    focusedField == .time && selectedTimeComponent == 1
                }, set: { _ in }), placeholder: "0")
                TextWithSelection(string: timeComponents[safe: 2], isSelected: Binding(get: {
                    focusedField == .time && selectedTimeComponent == 2
                }, set: { _ in }), placeholder: "0")
            }
            .frame(maxWidth: .infinity)
            .background {
                TextField("", text: $timeTemp)
                    .opacity(0)
                    .offset(y: 150)
                    .focused($focusedField, equals: .time)
                    .keyboardType(.numberPad)
                    .onChange(of: timeTemp) { newValue in
                        if newValue == "" {
                            let prefix: Int = selectedTimeComponent - 1
                            let timeArray = Array(step.time).prefix(upTo: prefix >= 0 ? prefix : 0)
                            step.time = String(timeArray)
                            selectedTimeComponent -= 1
                        } else if let digit = Array(newValue)[safe: 1] {
                            replaceDigit(at: selectedTimeComponent, with: digit)
                            if selectedTimeComponent >= 2 {
                                selectedTimeComponent = 0
                                focusedField = .coffeeAmount
                            } else {
                                selectedTimeComponent += 1
                            }
                        }
                        timeTemp = "-"
                        save(moc)
                    }
            }
            .onTapGesture {
                focusedField = .time
                selectedTimeComponent = 0
            }
            
            Rectangle()
                .frame(width: 2, height: .large)
                .foregroundStyle(Color.separatorPrimary)
                .cornerRadius()
                .padding(.horizontal, .small)
            
            HStack(spacing: 0) {
                TextWithSelection(string: step.coffeeAmount, isSelected: Binding(get: {
                    focusedField == .coffeeAmount
                }, set: { _ in }), placeholder: "0")
                Text(" г.")
            }
            .frame(maxWidth: .infinity)
            .background {
                TextField("", text: $step.coffeeAmount)
                    .opacity(0)
                    .offset(y: 150)
                    .focused($focusedField, equals: .coffeeAmount)
                    .keyboardType(.numberPad)
                    .onChange(of: step.coffeeAmount) { newValue in
                        step.coffeeAmount = newValue
                        save(moc)
                    }
            }
            .onTapGesture {
                focusedField = .coffeeAmount
            }
        }
        .font(.system(size: 17, design: .monospaced))
        .recipeRow()
    }
    
    func replaceDigit(at index: Int, with digit: Character) {
        guard index >= 0 && index <= 2 else { return }
        var timeArray: [Character] = Array(step.time)
        if timeArray.count < index + 1 { timeArray.append(digit) }
        else { timeArray[index] = digit }
        step.time = String(timeArray)
    }
    
    struct TextWithSelection: View {
        let string: String?
        @Binding var isSelected: Bool
        let placeholder: String
        
        var body: some View {
            let text: String? = {
                if let string, string != "" { return string }
                return nil
            }()
            
            Text(text ?? placeholder)
                .opacity(text == nil ? 0.5 : 1)
                .padding(.horizontal, 1)
                .background(Color.accentColor.opacity(isSelected ? 0.5 : 0))
                .cornerRadius(2)
                .padding(.horizontal, -1)
        }
    }
}

fileprivate struct RecipeRowView: ViewModifier {
    let height: CGFloat = .smallElementContainer
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, .regular)
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(Color.backgroundSecondary)
            .cornerRadius()
    }
}


fileprivate extension View {
    func recipeRow() -> some View {
        modifier(RecipeRowView())
    }
}
