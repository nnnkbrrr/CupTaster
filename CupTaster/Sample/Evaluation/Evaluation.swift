//
//  EvaluationView.swift
//  CupTaster
//
//  Created by Никита on 19.07.2022.
//

import SwiftUI
import CoreData

struct EvaluationView: View {
    @Environment(\.managedObjectContext) private var moc
    @AppStorage("use-cupping-hints") var useCuppingHints: Bool = true
    @ObservedObject var qualityCriteria: QualityCriteria
    @State var currentQCHint: String?
    
    var body: some View {
        VStack {
            HStack {
                Group {
                    Text(qualityCriteria.configuration?.lowerBoundTitle ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(qualityCriteria.title)
                    Text(qualityCriteria.configuration?.upperBoundTitle ?? "")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .font(.caption2)
                .foregroundColor(.gray)
            }
            .padding(.horizontal, 5)
            
            if let qcConfig: QCConfig = qualityCriteria.configuration {
                switch qcConfig.evaluationType.unwrappedEvaluationType {
                    case .slider:
                        SliderView(
                            value: $qualityCriteria.value,
                            configuration: qcConfig.sliderConfiguration
                        )
                    case .checkboxes:
                        CheckboxesView(
                            value: $qualityCriteria.value,
                            cuppingCupsCount: Int(qualityCriteria.group.sample.cupping.cupsCount)
                        )
                    case .radio:
                        RadioView(
                            value: $qualityCriteria.value,
                            lowerBound: qcConfig.lowerBound,
                            upperBound: qcConfig.upperBound,
                            step: qcConfig.step
                        )
                    case .none:
                        EmptyView()
                            .frame(height: 40)
                }
                
                if let currentQCHint {
                    if useCuppingHints {
                        Text(currentQCHint)
                            .font(.caption)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundColor(.gray)
                            .padding(5)
                            .fixedSize(horizontal: false, vertical: true)
                            .background(Color(uiColor: .systemGray4))
                            .cornerRadius(5)
                    }
                }
            }
        }
        .onChange(of: qualityCriteria.value) { _ in
            withAnimation(.easeInOut(duration: 0.2)) { currentQCHint = getCurrentQCHint() }
            try? moc.save()
        }
        .onAppear() {
            currentQCHint = getCurrentQCHint()
        }
    }
    
    func getCurrentQCHint() -> String? {
        if let qcConfig: QCConfig = qualityCriteria.configuration {
            for hint in qcConfig.hints.sorted(by: { $0.lowerBound > $1.lowerBound }) {
                if qualityCriteria.value >= hint.lowerBound {
                    return hint.message
                }
            }
        }
        return nil
    }
}
