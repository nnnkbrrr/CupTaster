//
//  Features.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

struct OnboardingFeaturesView: View {
    @State var headlineGradientAnimation: Bool = false
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                Group {
                    Text("Welcome to")
                    Text("CupTaster")
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .overlay (
                            LinearGradient(
                                colors: [.accentColor.opacity(0), .orange, .accentColor.opacity(0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .frame(width: 50)
                            .frame(
                                maxWidth: .infinity,
                                alignment: headlineGradientAnimation ? .trailing : .leading
                            )
                            .mask( Text("CupTaster") )
                        )
                        .onAppear {
                            withAnimation(.easeInOut(duration: 4.0).repeatForever(autoreverses: false)) {
                                headlineGradientAnimation.toggle()
                            }
                        }
                }
                .font(.title.weight(.heavy))
            }
            .padding(50)
        }
    }
}
