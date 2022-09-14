//
//  SampleEditor.swift
//  CupTaster
//
//  Created by Никита on 10.07.2022.
//

import SwiftUI

struct SampleSelectorView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cupping: Cupping
    @Binding var selectedSample: Sample?
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Spacer()
                .safeAreaInset(edge: .bottom) {
                    Color(uiColor: .systemGray6)
                        .frame(height: 1)
                        .background(Color(uiColor: .systemGray6))
                }
            
            TabView(selection: $selectedSample) {
                ForEach(cupping.getSortedSamples()) { sample in
                    ZStack(alignment: .bottom) {
                        SampleView(sample: sample)
                        
                        Blur(style: .systemUltraThinMaterial)
                            .frame(height: 100)
                        
                        SampleSelectorMenuView(cupping: cupping, sample: sample, selectedSample: $selectedSample)
                            .padding(.bottom, 47)
                    }
                    .tag(Optional(sample))
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack(spacing: 0) {
#warning("should be info")
                Button {
                    if let selectedSample = selectedSample {
                        moc.delete(selectedSample)
                        try? moc.save()
                    }
                } label: {
                    Image(systemName: "trash")
                        .padding(10)
                        .contentShape(Rectangle())
                }

                Spacer()

                StopwatchView()

                Spacer()

                Button {
                    selectedSample = nil
                } label: {
                    Image(systemName: "square.on.square")
                        .padding(10)
                        .contentShape(Rectangle())
                }
            }
            .font(.title2)
            .frame(height: 44)
            .padding(.horizontal, 10)
            .zIndex(3)
        }
    }
}
