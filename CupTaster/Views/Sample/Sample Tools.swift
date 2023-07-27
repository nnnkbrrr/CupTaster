//
//  Sample Sidebar.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

fileprivate let spacing: CGFloat = 2

extension SampleView {
    var sampleTools: some View {
        VStack(spacing: spacing) {
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "textformat") {
#warning("action")
                }
                SampleToolButton(systemImageName: "camera") {
#warning("action")
                }
            }
            
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "link") {
#warning("action")
                }
                SampleToolButton(systemImageName: "photo") {
#warning("action")
                }
            }
            
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "doc") {
#warning("action")
                }
                SampleToolButton(systemImageName: "folder.badge.gearshape") {
#warning("action")
                }
            }
            
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "square.and.arrow.up") {
#warning("action")
                }
                SampleToolButton(systemImageName: "trash") {
#warning("action")
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.systemGroupedBackground)
        .cornerRadius()
    }
}

private struct SampleToolButton: View {
    let systemImageName: String
    let action: () -> ()
    
    init(systemImageName: String, action: @escaping () -> Void) {
        self.systemImageName = systemImageName
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: systemImageName)
                .font(.title2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.secondarySystemGroupedBackground)
        }
    }
}

