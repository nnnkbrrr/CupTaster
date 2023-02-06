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
                                colors: [.accentColor.opacity(0), .accentColor, .accentColor.opacity(0)],
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
                .font(.system(size: 34, weight: .heavy))
                
                FeatureView(
                    image: Image(systemName: "doc.on.doc"),
                    title: "Cuppings",
                    description: "Handy storage for all of your cupping sessions."
                )
                FeatureView(
                    image: Image(systemName: "stopwatch"),
                    title: "Stopwatch",
                    description: "Track brewing time with stopwatch."
                )
                FeatureView(
                    image: Image(systemName: "questionmark.bubble"),
                    title: "Hints [Soon]",
                    description: "Use hints to get acquainted with cupping protocol details."
                )
                .disabled(true)
            }
            .padding(50)
            .padding(.bottom, 50)
        }
    }
}

fileprivate struct FeatureView: View {
    let image: Image
    let title: String
    let description: String
    
    var body: some View {
        HStack {
            image
                .font(.system(size: 30))
                .frame(width: 30, height: 30)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .fontWeight(.heavy)
                    .foregroundColor(.accentColor)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
    }
}
