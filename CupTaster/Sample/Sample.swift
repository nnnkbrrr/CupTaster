//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cuppingModel: CuppingModel
    @State var sample: Sample
    
    @Binding private var appearance: SampleAppearance
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: SampleAppearance = .criteria) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = .constant(appearance)
    }
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: Binding<SampleAppearance>) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = appearance
    }
    
    var body: some View {
        switch appearance {
        case .criteria:
            criteriaAppearance
                .padding(.bottom, 100) // toolbar
                .resignKeyboardOnDragGesture() { try? moc.save() }
        case .info:
            infoAppearance
                .padding(.bottom, 100) // toolbar
                .resignKeyboardOnDragGesture() { try? moc.save() }
        }
    }
}

// MARK: Change appearance

enum SampleAppearance {
    case criteria, info
}

// MARK: All appearances

extension SampleView {
    private var criteriaAppearance: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    EvaluationGroupView(qcGroup: qcGroup)
                }
            }
            .padding(.horizontal)
        }
    }
}

extension SampleView {
    private var infoAppearance: some View {
        Form {
            RadarChart(sample: sample)
            
            Section {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        moc.delete(sample)
                        
                        let cupping: Cupping = sample.cupping
                        let sortedSamples: [Sample] = cupping.getSortedSamples()
                        if sortedSamples.count > 1 {
                            if cuppingModel.selectedSampleIndex != 0 {
                                self.cuppingModel.selectedSampleIndex! -= 1
                                self.cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex!]
                            } else {
                                self.cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex! + 1]
                            }
                        } else {
                            self.cuppingModel.selectedSampleIndex = 0
                            self.cuppingModel.selectedSample = nil
                        }
                        
                        try? moc.save()
                    }
                }
            }
        }
    }
}

// MARK: Extra

extension SampleView {
    public var preview: some View {
        VStack(alignment: .leading, spacing: 0) {
            RadarChart(sample: sample, useShortLabels: true)
            
            HStack {
                ZStack {
                    if sample.finalScore != 0 { Text(String(format: "%.1f", sample.finalScore)) }
                    else { Text("-") }
                }
                .frame(width: 30)
                
                Divider()
                    .frame(height: 15)
                
                Text(sample.name)
                    .fixedSize(horizontal: true, vertical: true)
                
                if sample.isFavorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
        }
        .padding(10)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }
}

struct SampleFormRowView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        TextField("Sample name", text: $sample.name)
            .submitLabel(.done)
            .onSubmit { try? moc.save() }
    }
}
