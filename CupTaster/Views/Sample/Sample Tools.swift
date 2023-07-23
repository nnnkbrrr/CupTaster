//
//  Sample Sidebar.swift
//  CupTaster
//
//  Created by Никита Баранов on 23.07.2023.
//

import SwiftUI

extension SampleView {
    var sampleTools: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                SampleToolButton(systemImageName: "textformat") {
#warning("action")
                }
                
                horizontalDivider
                
                SampleToolButton(systemImageName: "camera") {
#warning("action")
                }
            }
            
            Rectangle()
                .foregroundColor(.systemGroupedBackground)
                .frame(height: 2)
            
            HStack(spacing: 0) {
                SampleToolButton(systemImageName: "link") {
#warning("action")
                }
                
                horizontalDivider
                
                SampleToolButton(systemImageName: "photo") {
#warning("action")
                }
            }
            
            verticalDivider
            
            HStack(spacing: 0) {
                SampleToolButton(systemImageName: "doc") {
#warning("action")
                }
                
                horizontalDivider
                
                SampleToolButton(systemImageName: "folder.badge.gearshape") {
#warning("action")
                }
            }
            
            verticalDivider
            
            HStack(spacing: 0) {
                SampleToolButton(systemImageName: "square.and.arrow.up") {
#warning("action")
                }
                
                horizontalDivider
                
                SampleToolButton(systemImageName: "trash") {
#warning("action")
                }
            }
        }
    }
    
    private var verticalDivider: some View {
        Rectangle()
            .foregroundColor(.systemGroupedBackground)
            .frame(height: 2)
    }
    
    private var horizontalDivider: some View {
        Rectangle()
            .foregroundColor(.systemGroupedBackground)
            .frame(width: 2)
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
        }
    }
}

