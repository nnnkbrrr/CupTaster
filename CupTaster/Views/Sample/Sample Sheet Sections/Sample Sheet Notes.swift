//
//  Sample Sheet Notes.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

extension SampleBottomSheetView {
    struct SheetNotesSection: View {
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        var body: some View {
            SampleSheetSection(title: "Notes") {
                ZStack {
                    if let qcGroup: QCGroup = samplesControllerModel.selectedQCGroup {
                        NotesTextField(qcGroup: qcGroup)
                    } else {
                        Text("What do you feel?")
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
        
        struct NotesTextField: View {
            @ObservedObject var qcGroup: QCGroup
            
            var body: some View {
                TextViewWrapper(text: $qcGroup.notes)
                    .frame(minHeight: 38)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
