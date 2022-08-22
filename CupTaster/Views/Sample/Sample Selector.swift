//
//  SampleEditor.swift
//  CupTaster
//
//  Created by Никита on 10.07.2022.
//

import SwiftUI

struct SampleSelector: ViewModifier {
    @ObservedObject var cupping: Cupping
    @Binding var selectedSample: Sample
    
    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            NavigationView {
                content
                    .navigationBarTitle(" ", displayMode: .inline)
            }
            .navigationViewStyle(.stack)
            
            sampleSelector
        }
        .toolbar { StopwatchToolbarItem() }
    }
    
    private var sampleSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(cupping.getSortedSamples()) { sample in
                    Button {
                        selectedSample = sample
                    } label: {
                        Text(sample.name)
                            .font(.caption)
                            .bold()
                            .frame(height: 44)
                            .padding(.horizontal, 20)
                    }
                    .disabled(selectedSample.id == sample.id)
                    
                    Capsule()
                        .frame(width: 1, height: 15)
                        .opacity(0.1)
                }
                
                Button {
#warning("pass")
                } label: {
                    Image(systemName: "plus")
                        .frame(height: 44)
                        .padding(.horizontal)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
    }
}
