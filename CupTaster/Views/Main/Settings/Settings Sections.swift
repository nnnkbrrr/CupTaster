//
//  Settings Sections.swift
//  CupTaster
//
//  Created by Nikita on 12.02.2024.
//

import SwiftUI

// MARK: Standart Sections

struct SettingsHeader: View {
    let title: String
    
    init(_ title: String) {
        self.title = title
    }
    
    var body: some View {
        Text(title)
            .font(.subheadline)
            .bold()
            .frame(height: 40, alignment: .bottom)
            .padding(.leading, .small)
    }
}

struct SettingsButtonSection<LeadingContent: View>: View {
    let title: String
    let systemImageName: String?
    let action: () -> ()
    let leadingContent: () -> LeadingContent
    
    init(title: String, systemImageName: String? = nil, action: @escaping () -> (), leadingContent: @escaping () -> LeadingContent = { EmptyView() }) {
        self.title = title
        self.systemImageName = systemImageName
        self.action = action
        self.leadingContent = leadingContent
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            SettingsSection(title: title, systemImageName: systemImageName) { leadingContent() }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsNavigationSection<Destination: View>: View {
    let title: String
    let systemImageName: String?
    let destination: () -> Destination
    
    init(title: String, systemImageName: String? = nil, destination: @escaping () -> Destination) {
        self.title = title
        self.systemImageName = systemImageName
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            SettingsSection(title: title, systemImageName: systemImageName) { SettingsLeadingNavigationIndicator() }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsToggleSection: View {
    let title: String
    let systemImageNames: (on: String, off: String)
    @Binding var isOn: Bool
    
    var body: some View {
        SettingsSection(title: title) {
            isOn ? systemImageNames.on : systemImageNames.off
        } leadingContent: {
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

// MARK: Styles

private struct SettingsSection<LeadingContent: View>: View {
    let title: String
    @Binding var systemImageName: String?
    let leadingContent: () -> LeadingContent
    
    init(title: String, systemImageName: @escaping () -> String, leadingContent: @escaping () -> LeadingContent) {
        self.title = title
        self._systemImageName = Binding(get: { systemImageName() }, set: { _ in})
        self.leadingContent = leadingContent
    }
    
    init(title: String, systemImageName: String?, leadingContent: @escaping () -> LeadingContent) {
        self.title = title
        self._systemImageName = .constant(systemImageName)
        self.leadingContent = leadingContent
    }
    
    var body: some View {
        HStack {
            if let systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.gray)
                    .background(Color.backgroundTertiary)
                    .cornerRadius()
            }
            
            Text(title)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            leadingContent()
        }
        .frame(height: 60)
        .padding(.horizontal, 10)
        .background(Color.backgroundSecondary)
        .cornerRadius()
    }
}

struct SettingsLeadingNavigationIndicator: View {
    var body: some View {
        Image(systemName: "chevron.right")
            .font(.body.bold())
            .foregroundStyle(.gray)
            .padding(.trailing, 10)
    }
}
