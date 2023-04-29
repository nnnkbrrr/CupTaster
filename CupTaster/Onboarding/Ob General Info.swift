//
//  Ob General Info.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.02.2023.
//

import SwiftUI

struct OnboardingGeneralInfoView: View {
    @Binding var currentPage: OnboardingView.OnboardingPages
    
    @Binding var selectedSGIFields: [String]
    let sgiFields: [String] = ["Roast level", "Country"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text("Additional fields")
                .font(.title3)
                .fontWeight(.heavy)
                .padding(.leading, 5)
            
            Text("You can add fields that do not affect the result")
                .foregroundColor(.secondary)
                .padding(.leading, 5)
            
            ForEach(sgiFields, id: \.self) { sgiField in
                HStack {
                    ZStack {
                        if selectedSGIFields.contains(sgiField) {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.accentColor)
                            Image(systemName: "checkmark")
                                .foregroundColor(.white)
                        } else {
                            Circle()
                                .stroke(Color.accentColor, lineWidth: 2)
                                .frame(width: 30, height: 30)
                            Image(systemName: "plus")
                                .foregroundColor(.accentColor)
                        }
                    }
                    .font(.caption.weight(.heavy))
                    
                    Text(LocalizedStringKey(sgiField))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    if selectedSGIFields.contains(sgiField) {
                        selectedSGIFields.removeAll(where: { $0 == sgiField })
                    } else {
                        selectedSGIFields.append(sgiField)
                    }
                }
            }
            .padding(.leading, 5)
            
            Color.clear.frame(height: 50) // button
        }
        .padding(30)
        .background(Color(uiColor: .systemBackground).opacity(0.25))
        .background(.ultraThinMaterial)
        .cornerRadius(50)
        .padding(30)
    }
}
