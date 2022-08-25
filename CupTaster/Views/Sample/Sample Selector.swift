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
        TabView {
            ForEach(cupping.getSortedSamples()) { sample in
                SampleView(sample: sample)
            }
        }
        .tabViewStyle(.page)
        .toolbar { StopwatchToolbarItem() }
    }
    
    public var preview: some View {
        NavigationLink(destination: self) {
            HStack {
                Image(systemName: "heart" + (selectedSample.isFavorite ? ".fill" : ""))
                    .foregroundColor(selectedSample.isFavorite ? .red : .gray)
                    .scaleEffect(selectedSample.isFavorite ? 1 : 0.75)
                Text(selectedSample.name)
            }
        }
    }
}
