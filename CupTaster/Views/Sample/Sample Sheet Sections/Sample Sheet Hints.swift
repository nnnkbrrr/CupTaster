//
//  Sample Sheet Hints.swift
//  CupTaster
//
//  Created by Nikita on 23.01.2024.
//

import SwiftUI

extension SampleBottomSheetView {
    struct SheetHintsSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        var body: some View {
            ZStack {
                if let hint = samplesControllerModel.selectedQCGroup?.configuration.hint {
                    SampleSheetSection(title: "Definition:") {
                        Text(hint.message)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .animation(.easeInOut(duration: 0.2), value: samplesControllerModel.selectedQCGroup)
        }
    }
}
