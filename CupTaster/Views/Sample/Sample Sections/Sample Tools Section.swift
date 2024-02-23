//
//  Sample Tools Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

extension SampleView {
    struct ActionsToolsSection: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        
        @State var deleteModalIsActive: Bool = false
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: samplesControllerModel.selectedSample?.isFavorite ?? false ? "heart.fill" : "heart") {
                    withAnimation {
                        samplesControllerModel.selectedSample?.isFavorite.toggle()
                        samplesControllerModel.objectWillChange.send()
                    }
                    try? moc.save()
                },
                .init(systemImageName: "folder.badge.gearshape") {
#warning("action")
                },
                .init(systemImageName: "trash") {
                    deleteModalIsActive = true
                }
            ])
            .adaptiveSizeSheet(isPresented: $deleteModalIsActive) {
                VStack(spacing: .small) {
                    Text("Delete \(samplesControllerModel.selectedSample?.name ?? "Sample")?")
                        .resizableText(initialSize: 30)
                    
                    HStack(spacing: .extraSmall) {
                        if let selectedSample: Sample = samplesControllerModel.selectedSample {
                            Button("Delete") {
                                #warning("does not work")
//                                selectedSample.cupping.objectWillChange.send()
//                                moc.delete(selectedSample)
//                                deleteModalIsActive = false
//                                try? moc.save()
                            }
                            .buttonStyle(.bottomSheetBlock)
                        }
                        
                        Button("Cancel") {
                            deleteModalIsActive = false
                        }
                        .buttonStyle(.accentBottomSheetBlock)
                    }
                }
                .padding(.small)
            }
        }
    }
    
    struct GeneralInfoToolsSection: View {
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: "textformat") {
#warning("action")
                },
                .init(systemImageName: "photo") {
#warning("action")
                },
                .init(systemImageName: "camera") {
#warning("action")
                },
                .init(systemImageName: "qrcode.viewfinder") {
#warning("action")
                },
                .init(systemImageName: "doc") {
#warning("action")
                }
            ])
        }
    }
}
