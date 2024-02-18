//
//  Settings Sections.swift
//  CupTaster
//
//  Created by Nikita on 12.02.2024.
//

import SwiftUI

// MARK: Info Sections

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

struct SettingsFooter: View {
    let text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.caption)
            .foregroundStyle(.gray)
            .padding(.leading, .small)
    }
}

// MARK: Standart Sections

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
    let leadingBadge: String?
    
    init(title: String, systemImageName: String? = nil, leadingBadge: String? = nil, destination: @escaping () -> Destination) {
        self.title = title
        self.systemImageName = systemImageName
        self.leadingBadge = leadingBadge
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            SettingsSection(title: title, systemImageName: systemImageName) {
                HStack {
                    if let leadingBadge {
                        Text(leadingBadge)
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    
                    SettingsLeadingNavigationIndicator()
                }
            }
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

struct SettingsTextFieldSection: View {
    @Binding var text: String
    let prompt: String
    
    var body: some View {
        TextField(prompt, text: $text)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 60)
            .padding(.horizontal, .regular)
            .background(Color.backgroundSecondary)
            .cornerRadius()
    }
}

struct SettingsPickerSection<T: Hashable, Content: View>: View {
    let title: String
    let systemImageName: String?
    @Binding var selection: T
    let content: () -> Content
    
    init(title: String, systemImageName: String? = nil, selection: Binding<T>, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImageName = systemImageName
        self._selection = selection
        self.content = content
    }
    
    var body: some View {
        SettingsSection(title: title, systemImageName: systemImageName) {
            Picker(title, selection: $selection) {
                content()
            }
            .labelsHidden()
        }
    }
}

// MARK: Styles

struct SettingsSection<LeadingContent: View>: View {
    let title: String
    @Binding var systemImageName: String?
    let leadingContent: () -> LeadingContent
    
    init(title: String, systemImageName: @escaping () -> String, leadingContent: @escaping () -> LeadingContent = { EmptyView() }) {
        self.title = title
        self._systemImageName = Binding(get: { systemImageName() }, set: { _ in})
        self.leadingContent = leadingContent
    }
    
    init(title: String, systemImageName: String? = nil, leadingContent: @escaping () -> LeadingContent = { EmptyView() }) {
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
                .padding(.horizontal, systemImageName == nil ? .extraSmall : 0)
            
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
