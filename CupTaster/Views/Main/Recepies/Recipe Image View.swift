//
//  Recipe Image View.swift
//  CupTaster
//
//  Created by Nikita on 1/10/25.
//

import SwiftUI

struct RecipeImagePreview: View {
    @State var image: UIImage? = nil
    let recipe: Recipe
    @Binding var isPresented: Bool
    @State var imageOffset: CGFloat = 0
    
    init(recipe: Recipe, isPresented: Binding<Bool>) {
        self.recipe = recipe
        self._isPresented = isPresented
    }
    
    var body: some View {
        VStack(spacing: .regular) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .cornerRadius()
                    .overlay {
                        RoundedRectangle(cornerRadius: .defaultCornerRadius)
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                    }
                    .padding(.large)
            } else {
                ProgressView()
                    .onAppear {
                        image = RecipeImageView(recipe: recipe).asImage
                    }
            }
            
            Image(systemName: "arrow.down")
                .font(.title2)
                .offset(y: imageOffset)
                .frame(width: .large, height: .large)
                .foregroundStyle(.accent)
                .padding(.regular)
                .background(Color.backgroundSecondary)
                .clipShape(Circle())
                .overlay {
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                }
                .onTapGesture {
                    save()
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.all)
        .background(Color.black.opacity(0.75))
        .onTapGesture { isPresented = false }
    }
    
    func save() {
        if let image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            
            withAnimation(.easeIn(duration: 0.2)) {
                imageOffset = 150
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                imageOffset = -150
                withAnimation(.easeIn(duration: 0.2)) {
                    imageOffset = 0
                }
            }
            
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }
}

fileprivate struct RecipeImageView: View {
    @ObservedObject var recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: .small) {
            HStack(alignment: .top) {
                Text(recipe.name)
                    .foregroundStyle(.accent)
                    .font(.system(size: 25, design: .monospaced))
                
                Spacer()
                
                HStack {
                    VStack(alignment: .trailing) {
                        Text("CupTaster")
                        Text("Beta")
                    }
                    .padding(.leading, .large)
                    
                    Image("LogoColored")
                        .resizable()
                        .frame(width: 25, height: 25)
                }
                .font(.system(size: 10))
                .foregroundStyle(.accent)
                .padding(.top, .extraSmall)
            }
            
            VStack(alignment: .leading, spacing: .small) {
                Text("Помол: \(recipe.grindSize)")
                Text("Температура: \(recipe.temperature)ºC")
                Text("Кол-во кофе: \(recipe.coffeeAmount) г.")
                Text("Кол-во воды: \(recipe.waterAmount) г.")
            }
            .foregroundStyle(Color.white)
            .font(.system(size: 15, design: .monospaced))
            
            Text("Рецепт")
                .foregroundStyle(.accent)
                .font(.system(size: 25, design: .monospaced))
                .padding(.top, .regular)
            
            VStack(alignment: .leading, spacing: .small) {
                ForEach(recipe.sortedSteps) { step in
                    HStack {
                        let paddedInput = step.time.padding(toLength: 3, withPad: "0", startingAt: 0)
                        let minutes: String = String(paddedInput.prefix(1))
                        let seconds: String = String(paddedInput.suffix(2))
                        
                        Text("\(minutes):\(seconds)")
                            .frame(width: 75, alignment: .leading)
                        
                        Text("\(step.coffeeAmount) г.")
                    }
                }
                
                if recipe.notes != "" {
                    Text("\(recipe.notes)")
                        .foregroundStyle(.gray)
                        .font(.caption)
                        .frame(width: 350, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.top, .small)
                }
            }
            .foregroundStyle(Color.white)
            .font(.system(size: 15, design: .monospaced))
        }
        .frame(width: 350, alignment: .leading)
        .frame(maxHeight: .infinity)
        .padding(.large)
        .background(Color.black)
    }
}
