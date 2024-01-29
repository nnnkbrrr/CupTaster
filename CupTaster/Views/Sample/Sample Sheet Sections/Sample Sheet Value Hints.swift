//
//  Sample Sheet Value Hints.swift
//  CupTaster
//
//  Created by Nikita on 22.01.2024.
//

import SwiftUI
import Combine

extension SampleBottomSheetView {
    struct SheetValueHintsSection: View {
        class HintsManager: ObservableObject {
            private class HintsCache {
                static private var cache: [String: String] = [:]
                static subscript(description: String) -> String? {
                    get { HintsCache.cache[description] }
                    set { HintsCache.cache[description] = newValue }
                }
                
                static func getDescription(for criteria: QualityCriteria) -> String {
                    return "\(criteria.configuration.id).\(criteria.value)"
                }
            }
            
            @Published private var selectedCriteria: QualityCriteria? = SamplesControllerModel.shared.selectedCriteria
            @Published private var selectedCriteriaValue: Double?
            
            @Published var hint: String? = nil
            
            var cancellableSet: Set<AnyCancellable> = []
            
            init() {
                hitsPublisher
                    .receive(on: RunLoop.main)
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] hint in
                        self?.hint = hint
                    })
                    .store(in: &self.cancellableSet)
                
                selectedCriteria?.publisher(for: \.value)
                    .removeDuplicates()
                    .sink(receiveValue: { [weak self] value in
                        self?.selectedCriteriaValue = value
                    })
                    .store(in: &self.cancellableSet)
            }
            
            var hitsPublisher: AnyPublisher<String?, Never> {
                Publishers
                    .CombineLatest($selectedCriteria, $selectedCriteriaValue)
                    .removeDuplicates(by: { oldValues, newValues in
                        return oldValues.0?.id == newValues.0?.id && oldValues.1 == newValues.1
                    })
                    .map { criteria, value in
                        if let criteria, let value {
                            let hintDescription: String = HintsCache.getDescription(for: criteria)
                            
                            if let hint: String = HintsCache[hintDescription] {
                                return hint == "unavailable" ? nil : hint
                            } else {
                                for hint in criteria.configuration.hints.sorted(by: { $0.lowerBound > $1.lowerBound }) {
                                    if value >= hint.lowerBound {
                                        HintsCache[hintDescription] = hint.message
                                        return hint.message
                                    }
                                }
                            }
                            
                            HintsCache[hintDescription] = "unavailable"
                        }
                        return nil
                    }
                    .eraseToAnyPublisher()
            }
        }
        
        @ObservedObject var hintsManager: HintsManager = .init()
        
        var body: some View {
            ZStack {
                if let hint = hintsManager.hint {
                    SampleSheetSection(title: "With the selected value:") {
                        Text(hint)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: hintsManager.hint)
        }
    }
}
