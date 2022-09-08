//
//  SampleEditor.swift
//  CupTaster
//
//  Created by Никита on 10.07.2022.
//

import SwiftUI

struct SampleSelectorView: View {
    @ObservedObject var cupping: Cupping
    @State var selectedSample: Sample
    
    var body: some View {
        TabView(selection: $selectedSample) {
            ForEach(cupping.getSortedSamples()) { sample in
                SampleView(sample: sample)
                    .tag(sample)
            }
        }
        .tabViewStyle(.page)
        .toolbar { StopwatchToolbarItem() }
        .navigationBarTitle("", displayMode: .inline)
    }
    
    public var preview: some View {
        NavigationLink(destination: self) {
            HStack {
                Image(systemName: "heart" + (selectedSample.isFavorite ? ".fill" : ""))
                    .foregroundColor(selectedSample.isFavorite ? .red : .gray)
                    .scaleEffect(selectedSample.isFavorite ? 1 : 0.75)
                
                if selectedSample.finalScore != 0 {
                    Text(String(format: "%.1f", selectedSample.finalScore))
                        .font(.caption)
                        .padding(5)
                        .frame(width: 50)
                        .background(Color(uiColor: .systemGray3), in: Capsule())
                }
                
                Text(selectedSample.name)
            }
        }
    }
}
