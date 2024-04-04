//
//  All Cuppings Empty.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.07.2023.
//

import SwiftUI

extension MainTabView {
    var isEmpty: some View {
        VStack(spacing: .large) {
            Image("EmptyState")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.horizontal, .extraLarge)
            
            Text("No cuppings yet")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Looks like you didn’t add any cuppings yet")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
            
            Button("Create") {
                newCuppingModalIsActive = true
            }
            .buttonStyle(.capsule(extraWide: false))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea()
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .navigationBarTitle("", displayMode: .inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(destination: SettingsTabView()) {
                    Image(systemName: "gearshape")
                        .font(.title3)
                        .foregroundStyle(.accent)
                }
            }
        }
    }
    
    var noResults: some View {
        Text("No results were found")
            .font(.title2)
            .bold()
            .multilineTextAlignment(.center)
    }
    
    var folderIsEmpty: some View {
        VStack(spacing: .large) {
            Text("It’s empty here")
                .font(.title2)
                .bold()
                .multilineTextAlignment(.center)
            
            Text("Looks like you didn’t add any cuppings or samples yet")
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
        }
    }
}
