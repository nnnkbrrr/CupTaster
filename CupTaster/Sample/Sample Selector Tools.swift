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
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
    
    var body: some View {
        ZStack {
            HStack {
                TextField("Sample name", text: $sample.name)
                    .keyboardType(.alphabet)
                    .autocorrectionDisabled()
                    .focused($sampleNameTextfieldFocus, equals: sample.id)
                    .multilineTextAlignment(sampleNameTextfieldFocus == nil ? .center : .leading)
                    .submitLabel(.done)
                    .onSubmit {
                        try? moc.save()
                    }
                    .padding(.horizontal)
                
                if sampleNameTextfieldFocus != nil {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .padding(10)
                        .onTapGesture {
                            sample.name = ""
                        }
                }
            }
            
            if sampleNameTextfieldFocus == nil {
                HStack {
                    if sample.finalScore != 0 {
                        Text(String(format: "%.1f", sample.finalScore))
                            .bold()
                            .lineLimit(1)
                            .frame(width: 50, height: 44)
                    } else {
                        Image(systemName: "sum")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(.accentColor)
                            .shadow(color: Color(uiColor: .systemBackground).opacity(0.25), radius: 7, x: 0, y: 0)
                            .padding(10)
                            .frame(width: 50, height: 44)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                sample.calculateFinalScore()
                                for qcGroup in sample.qualityCriteriaGroups { qcGroup.isCompleted = true }
                                try? moc.save()
                            }
                    }
                    
                    Spacer()
                    
                    Image(systemName: sample.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(sample.isFavorite ? .red : .gray)
                        .frame(width: 50, height: 44)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            sample.isFavorite.toggle()
                            try? moc.save()
                        }
                }
            }
        }
        .animation(.default, value: sampleNameTextfieldFocus)
        .padding(.horizontal, 10)
    }
}
