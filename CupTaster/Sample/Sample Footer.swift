//
//  Sample Footer.swift
//  CupTaster
//
//  Created by Никита on 22.08.2022.
//

import SwiftUI

struct SampleFooterView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    @State private var finalScoreValue: Double? = nil
    private let iconsSize: CGFloat = 20

    var body: some View {
        HStack(spacing: 0) {
            toggleIsFavorite
            Spacer()
            finalScore
            Spacer()
            deleteSample
        }
        .padding()
        .frame(height: 44)
        .background(Blur(style: .systemUltraThinMaterial))
    }
}

// MARK: Is Favorite

extension SampleFooterView {
    var toggleIsFavorite: some View {
        Button {
            sample.isFavorite.toggle()
            sample.cupping.objectWillChange.send()
            try? moc.save()
        } label: {
            Image(systemName: sample.isFavorite ? "heart.fill" : "heart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconsSize, height: iconsSize)
                .foregroundColor(sample.isFavorite ? .red : .gray)
                .padding(10)
                .contentShape(Rectangle())
        }
        
    }
}

// MARK: Delete

extension SampleFooterView {
    var deleteSample: some View {
        Button {
            moc.delete(sample)
            try? moc.save()
        } label: {
            Image(systemName: "trash")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: iconsSize, height: iconsSize)
                .padding(10)
                .contentShape(Rectangle())
        }
    }
}

// MARK: Final Score

extension SampleFooterView {
    var finalScore: some View {
        HStack(spacing: 0) {
            Text("Final score: ")
            if sample.finalScore != 0 {
                Text(String(format: "%.1f", sample.finalScore))
                    .bold()
            } else {
                Button("calculate") {
                    sample.calculateFinalScore()
                    for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                    try? moc.save()
                }
            }
        }
    }
}
