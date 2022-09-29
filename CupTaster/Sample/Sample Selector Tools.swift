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
                    .frame(width: 44, height: 44)
            } else {
                Image(systemName: "sum")
                    .foregroundColor(.accentColor)
                    .padding(10)
                    .frame(width: 44, height: 44)
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
                .frame(width: 44, height: 44)
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
