//
//  S Slider.swift
//  CupTaster
//
//  Created by Никита Баранов on 22.02.2023.
//

import SwiftUI

struct Settings_Slider: View {
    @Binding var isActive: Bool
    
    @AppStorage("slider-spacing") var sliderSpacing: Double = 25.0
    @State var template: Double = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 10) {
                VStack(spacing: 3) {
                    Text("Customize")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    
                    SliderView(value: $sliderSpacing, lowerBound: 15, upperBound: 75, step: 5)
                        .animation(.default, value: sliderSpacing)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
                
                VStack(spacing: 3) {
                    Text("Try it out!")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)
                    
                    SliderView(value: $template, lowerBound: 0, upperBound: 10, step: 0.25)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .navigationBarTitle("Slider spacing", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isActive = false }
                }
            }
        }
    }
}
