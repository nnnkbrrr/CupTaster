//
//  Sample Footer.swift
//  CupTaster
//
//  Created by Никита on 22.08.2022.
//

import SwiftUI

struct SampleToolsView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        HStack {
            if sample.finalScore != 0 {
                Text(String(format: "%.1f", sample.finalScore))
                    .bold()
            } else {
                Image(systemName: "sum")
                    .foregroundColor(.accentColor)
                    .padding(10)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        sample.calculateFinalScore()
                        for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                        try? moc.save()
                    }
            }
            
            TextField("Sample name", text: $sample.name)
                .multilineTextAlignment(.center)
                .submitLabel(.done)
                .onSubmit {
                    sample.cupping.objectWillChange.send()
                    try? moc.save()
                }
                .padding(.horizontal)
            
            Image(systemName: sample.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(sample.isFavorite ? .red : .gray)
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    sample.isFavorite.toggle()
                    sample.cupping.objectWillChange.send()
                    try? moc.save()
                }
        }
        .padding(.horizontal, 10)
    }
}

struct SampleSelectorToolsView: View {
    @Environment(\.managedObjectContext) private var moc
//    @ObservedObject var sample: Sample
//    var sortedSamples: [Sample]
    @Binding var selectedSample: Sample?
//    @State var selectedSampleIndex: Int
    
    var body: some View {
        HStack(spacing: 0) {
#warning("should be info")
            Image(systemName: "info.circle")
//                .foregroundColor(.accentColor)
                .padding(10)
                .contentShape(Rectangle())
//                .onTapGesture {
//                    if let selectedSample = selectedSample {
//                        moc.delete(selectedSample)
//
//                        if sortedSamples.count > 1 {
//                            if selectedSampleIndex != 0 {
//                                self.selectedSampleIndex -= 1
//                                self.selectedSample = sortedSamples[selectedSampleIndex]
//                            } else {
//                                self.selectedSample = sortedSamples[selectedSampleIndex + 1]
//                            }
//                        } else {
//                            self.selectedSampleIndex = 0
//                            self.selectedSample = nil
//                        }
//
//                        try? moc.save()
//                    }
//                }
            
            Spacer()
            
            StopwatchView()
            
            Spacer()
            
            Image(systemName: "square.on.square")
                .foregroundColor(.accentColor)
                .padding(10)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedSample = nil
                }
        }
        .font(.title2)
        .frame(height: 44)
        .padding(.horizontal, 10)
    }
}
