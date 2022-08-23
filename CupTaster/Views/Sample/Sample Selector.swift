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
                ZStack {
                    SampleView(sample: sample).padding(.vertical, 44)
                    VStack(spacing: 0) {
                        SampleSelectorHeaderView(sample: sample)
                        Divider()
                        Spacer()
                        Divider()
                        FinalScoreView(sample: sample)
                    }
                }
                .cornerRadius(10)
                .padding(15)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .toolbar { StopwatchToolbarItem() }
    }
    
    public var preview: some View {
        NavigationLink(destination: self) { Text(selectedSample.name) }
    }
}

struct SampleSelectorHeaderView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        HStack {
            Image(systemName: "chevron.left")
                .padding(.leading, 20)
            TextField("", text: $sample.name)
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .onSubmit {
                    sample.cupping.objectWillChange.send()
                    try? moc.save()
                }
            Image(systemName: "chevron.right")
                .padding(.trailing, 20)
        }
        .frame(height: 44)
        .background(Blur(style: .systemMaterial))
    }
}
