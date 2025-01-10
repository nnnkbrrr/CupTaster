//
//  Recipes Tab.swift
//  CupTaster
//
//  Created by Nikita on 1/9/25.
//

import SwiftUI

struct RecipesTabView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        entity: Recipe.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.date, ascending: false)]
    ) var recipes: FetchedResults<Recipe>
    
    @State var activeRecipe: ObjectIdentifier? = nil
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                if recipes.isEmpty {
                    Text("Рецептов пока нет")
                        .padding(.regular)
                }
                
                let pinnedRecipes: [Recipe] = recipes.filter { $0.isPinned }
                let recentRecipes: [Recipe] = recipes.filter { !$0.isPinned }
                
                if !pinnedRecipes.isEmpty {
                    Text("Pinned")
                        .font(.title3)
                        .padding(.top, .regular)
                        .padding([.bottom, .leading], .extraSmall)
                }
                
                ForEach(pinnedRecipes) { RecipePreview(recipe: $0, activeRecipe: $activeRecipe) }
                
                Text("Recent")
                    .font(.title3)
                    .padding(.top, .regular)
                    .padding([.bottom, .leading], .extraSmall)
                
                ForEach(recentRecipes) { RecipePreview(recipe: $0, activeRecipe: $activeRecipe) }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .navigationTitle("Все рецепты")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "plus")
                    .font(.title2)
                    .frame(width: .large, height: .large)
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        let newRecipe: Recipe = .init(context: moc)
                        newRecipe.date = Date()
                        
                        newRecipe.name = ""
                        newRecipe.grindSize = ""
                        newRecipe.temperature = ""
                        newRecipe.coffeeAmount = ""
                        newRecipe.waterAmount = ""
                        newRecipe.notes = ""
                        newRecipe.name = ""
                        newRecipe.isPinned = false
                        
                        save(moc)
                        
                        DispatchQueue.main.async {
                            activeRecipe = newRecipe.id
                        }
                    }
            }
        }
        .defaultNavigationBar()
    }
    
    struct RecipePreview: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var recipe: Recipe
        
        @Binding var activeRecipe: ObjectIdentifier?
        
        var body: some View {
            SwipeView(gestureType: .simultaneous) {
                NavigationLink(destination: RecipeView(recipe: recipe), tag: recipe.id, selection: $activeRecipe) {
                    HStack {
                        VStack(alignment: .leading, spacing: .extraSmall) {
                            Text(recipe.name == "" ? "Новый рецепт" : recipe.name)
                            Text(recipe.date, style: .date)
                                .foregroundStyle(.gray)
                                .font(.caption)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "pin" + (recipe.isPinned ? ".fill" : ""))
                            .font(.title2)
                            .frame(width: .large, height: .large)
                            .foregroundStyle(.accent)
                            .onTapGesture {
                                withAnimation { recipe.isPinned.toggle() }
                                save(moc)
                            }
                    }
                    .padding(.horizontal, .regular)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: .smallElementContainer)
                    .background(Color.backgroundSecondary)
                    .cornerRadius()
                }
            } trailingActions: { _ in
                SwipeActionView(systemImage: "trash.fill", title: "Delete", color: .red) {
                    withAnimation {
                        moc.delete(recipe)
                        save(moc)
                    }
                }
            }
            .defaultSwipeStyle()
        }
    }
}
