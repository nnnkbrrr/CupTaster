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
        
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: samplesControllerModel.selectedSample?.isFavorite ?? false ? "heart.fill" : "heart") {
                    withAnimation {
                        samplesControllerModel.selectedSample?.isFavorite.toggle()
                        samplesControllerModel.objectWillChange.send()
                    }
                    try? moc.save()
                },
                .init(systemImageName: "square.and.arrow.up") {
#warning("action")
                },
                .init(systemImageName: "folder.badge.gearshape") {
#warning("action")
                }
            ])
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
