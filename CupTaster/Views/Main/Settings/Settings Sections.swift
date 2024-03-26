//
//  Settings Sections.swift
//  CupTaster
//
//  Created by Nikita on 12.02.2024.
//

import SwiftUI

// MARK: Info Sections

struct SettingsSection<Content: View>: View {
    let header: String?
    let isFoldable: Bool
    let footer: String?
    let content: () -> Content
    
    @State var isFolded: Bool = false
    
    init(_ header: String? = nil, isFoldable: Bool = false, footer: String? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.isFoldable = isFoldable
        self.footer = footer
        self.content = content
    }
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: .extraSmall) {
            if let header { 
                HStack {
                    Text(header)
                        .font(.subheadline)
                        .bold()
                        .frame(height: 40, alignment: .bottom)
                        .padding(.leading, .small)
                    
                    if isFoldable {
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .padding(.trailing, .extraSmall)
                            .rotationEffect(.degrees(isFolded ? 0 : 90))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { withAnimation { isFolded.toggle() } }
            }
            
            content()
            
            if let footer { 
                Text(footer)
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.leading, .small)
            }
        }
    }
}

// MARK: Standart Sections

struct SettingsButtonSection<LeadingContent: View, TrailingContent: View>: View {
    let title: String
    @Binding var systemImageName: String?
    let action: () -> ()
    let leadingContent: (() -> LeadingContent)?
    let trailingContent: () -> TrailingContent
    
    init(
        title: String,
        action: @escaping () -> (),
        @ViewBuilder leadingContent: @escaping () -> LeadingContent,
        trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) {
        self.title = title
        self.leadingContent = leadingContent
        self._systemImageName = .constant(nil)
        self.action = action
        self.trailingContent = trailingContent
    }
    
    init(
        title: String,
        systemImageName: @escaping () -> String,
        action: @escaping () -> (),
        trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) where LeadingContent == Image {
        self.title = title
        self._systemImageName = Binding(get: { systemImageName() }, set: { _ in })
        self.action = action
        self.leadingContent = nil
        self.trailingContent = trailingContent
    }
    
    init(
        title: String,
        systemImageName: String? = nil,
        action: @escaping () -> (),
        trailingContent: @escaping () -> TrailingContent = { EmptyView() }
    ) where LeadingContent == Image {
        self.title = title
        self._systemImageName = .constant(systemImageName)
        self.action = action
        self.leadingContent = nil
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            if let leadingContent {
                SettingsRow(title: title, leadingContent: leadingContent, trailingContent: trailingContent)
            } else {
                SettingsRow(title: title, systemImageName: $systemImageName, trailingContent: trailingContent)
            }
        }
        .buttonStyle(.plain)
    }
}

struct SettingsNavigationSection<Destination: View>: View {
    let title: String
    let systemImageName: String?
    let destination: () -> Destination
    let trailingBadge: String?
    
    init(title: String, systemImageName: String? = nil, trailingBadge: String? = nil, destination: @escaping () -> Destination) {
        self.title = title
        self.systemImageName = systemImageName
        self.trailingBadge = trailingBadge
        self.destination = destination
    }
    
    var body: some View {
        NavigationLink(destination: destination) {
            SettingsRow(title: title, systemImageName: systemImageName) {
                HStack {
                    if let trailingBadge {
                        Text(trailingBadge)
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
        SettingsRow(title: title) {
            isOn ? systemImageNames.on : systemImageNames.off
        } trailingContent: {
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

struct SettingsTextFieldSection<TrailingContent: View>: View {
    @Binding var text: String
    let prompt: String
    let systemImageName: String?
    let trailingContent: () -> TrailingContent
    
    init(text: Binding<String>, prompt: String, systemImageName: String? = nil, trailingContent: @escaping () -> TrailingContent = { EmptyView() }) {
        self._text = text
        self.prompt = prompt
        self.systemImageName = systemImageName
        self.trailingContent = trailingContent
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
            
            TextField(prompt, text: $text)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            trailingContent()
        }
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
        SettingsRow(title: title, systemImageName: systemImageName) {
            Picker(title, selection: $selection) {
                content()
            }
            .labelsHidden()
        }
    }
}

// MARK: Styles

struct SettingsRow<LeadingContent: View, TrailingContent: View>: View {
    let title: String
    let leadingContent: (() -> LeadingContent)?
    @Binding var systemImageName: String?
    let trailingContent: () -> TrailingContent
    
    init(title: String, leadingContent: @escaping () -> LeadingContent, trailingContent: @escaping () -> TrailingContent = { EmptyView() }) {
        self.title = title
        self.leadingContent = leadingContent
        self._systemImageName = .constant(nil)
        self.trailingContent = trailingContent
    }
    
    init(title: String, systemImageName: @escaping () -> String, trailingContent: @escaping () -> TrailingContent = { EmptyView() }) where LeadingContent == Image {
        self.title = title
        self.leadingContent = nil
        self._systemImageName = Binding(get: { systemImageName() }, set: { _ in })
        self.trailingContent = trailingContent
    }
    
    init(title: String, systemImageName: Binding<String?>, trailingContent: @escaping () -> TrailingContent = { EmptyView() }) where LeadingContent == Image {
        self.title = title
        self.leadingContent = nil
        self._systemImageName = systemImageName
        self.trailingContent = trailingContent
    }
    
    init(title: String, systemImageName: String? = nil, trailingContent: @escaping () -> TrailingContent = { EmptyView() }) where LeadingContent == Image {
        self.title = title
        self.leadingContent = nil
        self._systemImageName = .constant(systemImageName)
        self.trailingContent = trailingContent
    }
    
    var body: some View {
        HStack {
            if let leadingContent {
                leadingContent()
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.gray)
                    .background(Color.backgroundTertiary)
                    .cornerRadius()
            } else if let systemImageName {
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
            
            trailingContent()
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
