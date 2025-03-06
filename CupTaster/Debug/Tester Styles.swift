//
//  Tester Styles.swift
//  CupTaster
//
//  Created by Nikita on 1/9/25.
//

import SwiftUI

extension TesterPanelView {
    struct TesterSectionView<TrailingContent: View>: View {
        let title: String
        @Binding var systemImageName: String?
        let trailingContent: () -> TrailingContent
        
        init(title: String, systemImageName: String? = nil, trailingContent: @escaping () -> TrailingContent = { EmptyView() } ) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.trailingContent = trailingContent
        }
        
        var body: some View {
            HStack(spacing: 5) {
                if let systemImageName {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                }
                
                Text(title)
                    .multilineTextAlignment(.leading)
                
                trailingContent()
            }
            .foregroundStyle(.primary)
            .frame(height: 35)
            .padding(.horizontal, .small)
            .background(Color.gray.opacity(0.5))
            .cornerRadius(10)
        }
    }
    
    struct TesterButton: View {
        let title: String
        @Binding var systemImageName: String
        let action: () -> ()
        
        init(title: String, systemImageName: String, action: @escaping () -> ()) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.action = action
        }
        
        init(title: String, systemImageName: @escaping () -> String, action: @escaping () -> ()) {
            self.title = title
            self._systemImageName = Binding(get: { systemImageName() }, set: { _ in})
            self.action = action
        }
        
        var body: some View {
            Button {
                action()
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                    
                    Text(title)
                        .multilineTextAlignment(.leading)
                }
                .foregroundStyle(.accent)
                .frame(height: 35)
                .padding(.horizontal, .small)
                .background(Color.backgroundSecondary)
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
        }
    }
}
