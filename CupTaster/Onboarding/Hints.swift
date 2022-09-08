//
//  Hints.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct OnboardingHintsView: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Text("Do you want to turn hints on?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom)
                Text("you have no choice yet...")
                    .foregroundColor(.gray)
            }
            .multilineTextAlignment(.center)
            .padding(50)
        }
    }
}
