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
        ZStack(alignment: .top) {
            TabView {
                ForEach(cupping.getSortedSamples()) { sample in
                    VStack(spacing: 0) {
                        SampleSelectorHeaderView(sample: sample)
                        
                        SampleView(sample: sample)
                        
                        Text("FinalScore: 0")
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(Color(uiColor: .systemGray4))
                    }
                    .cornerRadius(10)
                    .padding(15)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .toolbar { StopwatchToolbarItem() }
    }
    
    public var preview: some View {
        NavigationLink(destination: self) {
            Text(selectedSample.name)
        }
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
        .background(Color(uiColor: .systemGray4))
    }
}
