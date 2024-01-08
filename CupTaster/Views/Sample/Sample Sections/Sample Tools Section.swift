//
//  Sample Tools Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

extension SampleView {
    struct ActionsToolsSection: View {
        var body: some View {
            SampleToolsSection(tools: [
                .init(systemImageName: "heart") {
#warning("action")
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
