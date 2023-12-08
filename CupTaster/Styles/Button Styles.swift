//
//  Button Styles.swift
//  CupTaster
//
//  Created by Никита Баранов on 05.07.2023.
//

import SwiftUI

// Primary

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundColor(.accentColor)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(.primary)
            .cornerRadius()
    }
}

extension ButtonStyle where Self == PrimaryButtonStyle {
    static var primary: Self {
        return .init()
    }
}