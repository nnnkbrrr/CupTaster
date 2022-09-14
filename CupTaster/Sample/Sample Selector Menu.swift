//
//  Sample Footer.swift
//  CupTaster
//
//  Created by Никита on 22.08.2022.
//

import SwiftUI

struct SampleSelectorMenuView: View {
    @ObservedObject var cupping: Cupping
    @ObservedObject var sample: Sample
    @Binding var selectedSample: Sample?
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                if selectedSample == sample {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: geometry.size.width * 1.1, height: 44)
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .frame(width: geometry.size.width)
                        .opacity(cupping.getSortedSamples().first != sample ? 1 : 0)
                        .transition(.scale)
                }
                
                SampleMenuView(sample: sample)
                    .frame(
                        width: selectedSample == sample ? geometry.size.width * 0.86 : geometry.size.width * 1.1,
                        height: 44
                    )
                    .background(Color(uiColor: .systemGray3), in: RoundedRectangle(cornerRadius: 12))
                    .frame(width: geometry.size.width)
                
                if selectedSample == sample {
                    RoundedRectangle(cornerRadius: 12)
                        .frame(width: geometry.size.width * 1.1, height: 44)
                        .foregroundColor(Color(uiColor: .systemGray3))
                        .frame(width: geometry.size.width)
                        .opacity(cupping.getSortedSamples().last != sample ? 1 : 0)
                        .transition(.scale)
                }
            }
            .frame(width: geometry.size.width, height: 44, alignment: .center)
        }
        .animation(.easeInOut(duration: 0.1), value: selectedSample)
        .frame(height: 44)
    }
}

struct SampleMenuView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        HStack {
            if sample.finalScore != 0 {
                Text(String(format: "%.1f", sample.finalScore))
                    .bold()
            } else {
                Button {
                    sample.calculateFinalScore()
                    for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                    try? moc.save()
                } label: {
                    Image(systemName: "sum")
                        .padding(10)
                        .contentShape(Rectangle())
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
            
            Button {
                sample.isFavorite.toggle()
                sample.cupping.objectWillChange.send()
                try? moc.save()
            } label: {
                Image(systemName: sample.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(sample.isFavorite ? .red : .gray)
                    .padding(10)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 10)
    }
}
