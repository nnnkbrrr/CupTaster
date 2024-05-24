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
        @ObservedObject private var hintsManager: HintsManager
        
        init(criteria: QualityCriteria) {
            self.hintsManager = .init(for: criteria)
        }
        
        var body: some View {
            if let currentHint: String = hintsManager.currentHint {
                SampleSheetSection(title: "With the selected value:") {
                    Text(currentHint)
                        .font(.subheadline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        
        private class HintsManager: ObservableObject {
            @Published var currentHint: String? = nil
            
            var cancellableSet: Set<AnyCancellable> = []
            init(for criteria: QualityCriteria) {
                criteria.publisher(for: \.value)
                    .receive(on: RunLoop.main)
                    .map { _ in HintsManager.getHint(for: criteria) }
                    .assign(to: \.currentHint, on: self)
                    .store(in: &cancellableSet)
                
                currentHint = Self.getHint(for: criteria)
            }

            
            static private var cache: [String: String] = [:]
            static subscript(description: String) -> String? {
                get { Self.cache[description] }
                set { Self.cache[description] = newValue }
            }
            
            private static func getDescription(for criteria: QualityCriteria) -> String {
                return "\(criteria.configuration.id).\(criteria.value)"
            }
            
            static func getHint(for criteria: QualityCriteria?) -> String? {
                if let criteria {
                    let hintDescription: String = getDescription(for: criteria)
                    
                    if let hint: String = Self.self[hintDescription] {
                        return hint == "" ? nil : hint
                    } else {
                        for hint in criteria.configuration.hints.sorted(by: { $0.lowerBound > $1.lowerBound }) {
                            if criteria.value >= hint.lowerBound {
                                Self.self[hintDescription] = hint.message
                                return hint.message
                            }
                        }
                    }
                    
                    Self.self[hintDescription] = ""
                }
                return nil
            }
        }
    }
}
