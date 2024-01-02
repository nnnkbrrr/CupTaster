//
//  Sample Tools Section.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

fileprivate let dividerWidth: CGFloat = 3
fileprivate let spacing: CGFloat = (CGFloat.extraSmall - dividerWidth) / 2

extension SampleView {
    struct ActionsToolsSection: View {
        var body: some View {
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "heart") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "square.and.arrow.up") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "trash") {
#warning("action")
                }
            }
        }
    }
    
    struct GeneralInfoToolsSection: View {
        var body: some View {
            HStack(spacing: spacing) {
                SampleToolButton(systemImageName: "textformat") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "photo") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "camera") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "qrcode.viewfinder") {
#warning("action")
                }
                
                ToolsDivider()
                
                SampleToolButton(systemImageName: "doc") {
#warning("action")
                }
            }
        }
    }
}

fileprivate struct SampleToolButton: View {
    let systemImageName: String
    let action: () -> ()
    
    init(systemImageName: String, action: @escaping () -> Void) {
        self.systemImageName = systemImageName
        self.action = action
    }
    
    var body: some View {
        Image(systemName: systemImageName)
            .font(.title2)
            .foregroundStyle(Color.accentColor)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture { action() }
    }
}

fileprivate struct ToolsDivider: View {
    var body: some View {
        Rectangle()
            .foregroundStyle(Color.backgroundTertiary)
            .frame(width: dividerWidth)
            .padding(.vertical, .regular)
    }
}
