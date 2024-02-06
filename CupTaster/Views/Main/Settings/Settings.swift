//
//  Settings.swift
//  CupTaster
//
//  Created by Никита Баранов on 11.07.2023.
//

import SwiftUI

struct SettingsTabView: View {
#warning("screen: Settings")
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                
                // MARK: - Main
                
                NavigationSettingsSection(title: "Default Cupping Form", systemImageName: "doc.plaintext") {
                    Settings_CuppingForms()
                }
                
                NavigationSettingsSection(title: "General Info Fields", systemImageName: "info") {
                    Text("Empty")
                }
                .disabled(true)
                
                NavigationSettingsSection(title: "Folders", systemImageName: "folder") {
                    Text("Empty")
                }
                .disabled(true)
                
                // MARK: - Conditional
                
                SettingsHeader("Conditional")
                
                NavigationSettingsSection(title: "Section", systemImageName: "square.dashed") {
                    Text("Empty")
                }
                .disabled(true)
                
                NavigationSettingsSection(title: "Section", systemImageName: "square.dashed") {
                    Text("Empty")
                }
                .disabled(true)
                
                // MARK: - Contacts
                
                SettingsHeader("Contacts")
                
                NavigationSettingsSection(title: "Section", systemImageName: "square.dashed") {
                    Text("Empty")
                }
                .disabled(true)
                
                NavigationSettingsSection(title: "Section", systemImageName: "square.dashed") {
                    Text("Empty")
                }
                .disabled(true)
                
                Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "???")")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .onTapGesture(count: 10) {
                        print("tester tab visible")
                        //                        testerTabVisible = true
#warning("Tester section")
                    }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Settings")
        .defaultNavigationBar()
    }
}

// MARK: Standart Sections

extension SettingsTabView {
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
    
    struct NavigationSettingsSection<Destination: View>: View {
        let title: String
        let systemImageName: String
        let destination: () -> Destination
        
        init(title: String, systemImageName: String, destination: @escaping () -> Destination) {
            self.title = title
            self.systemImageName = systemImageName
            self.destination = destination
        }
        
        var body: some View {
            NavigationLink(destination: destination) {
                SettingsSection(title: title, systemImageName: systemImageName) { LeadingNavigationIndicator() }
            }
            .buttonStyle(.plain)
        }
    }
    
    struct ToggleSettingsSection: View {
        let title: String
        let systemImageNames: (on: String, off: String)
        @Binding var isOn: Bool
        
        var body: some View {
            SettingsSection(title: title, systemImageName: Binding(get: { isOn ? systemImageNames.on : systemImageNames.off }, set: { _ in })) {
                Toggle("", isOn: $isOn)
                    .labelsHidden()
            }
        }
    }
}

// MARK: Styles

extension SettingsTabView {
    private struct SettingsSection<LeadingContent: View>: View {
        let title: String
        @Binding var systemImageName: String
        let leadingContent: () -> LeadingContent
        
        init(title: String, systemImageName: Binding<String>, leadingContent: @escaping () -> LeadingContent) {
            self.title = title
            self._systemImageName = systemImageName
            self.leadingContent = leadingContent
        }
        
        init(title: String, systemImageName: String, leadingContent: @escaping () -> LeadingContent) {
            self.title = title
            self._systemImageName = .constant(systemImageName)
            self.leadingContent = leadingContent
        }
        
        var body: some View {
                HStack {
                    Image(systemName: systemImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .frame(width: 40, height: 40)
                        .foregroundStyle(.gray)
                        .background(Color.backgroundTertiary)
                        .cornerRadius()
                    
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
    
    private struct LeadingNavigationIndicator: View {
        var body: some View {
            Image(systemName: "chevron.right")
                .font(.body.bold())
                .foregroundStyle(.gray)
                .padding(.trailing, 10)
        }
    }
}

struct Settings_CuppingForms: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared

    @State var deleteAlertActive: Bool = false
    @State var deleteAlertCuppingForm: CuppingForm? = nil
    var body: some View {
        Form {
            if cuppingForms.count > 0 {
                Section("Default cupping form") {
                    ForEach(cuppingForms) { cuppingForm in
                        let isDeprecated: Bool = cuppingForm.isDeprecated
                        Button {
                            cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                        } label: {
                            Label {
                                Text(isDeprecated ? "\(cuppingForm.shortDescription) (deprecated)" : cuppingForm.title)
                            } icon: {
                                Image(systemName: "checkmark").opacity(cuppingForm.isDefault ? 1 : 0)
                            }
                        }
                        .foregroundColor(isDeprecated ? .red : .accentColor)
                    }
                    .onDelete { offsets in
                        let cuppingForm: CuppingForm = cuppingForms[offsets.first!]
                        if cuppingForm.cuppings.count > 0 {
                            deleteAlertActive = true
                            deleteAlertCuppingForm = cuppingForm
                        } else {
                            moc.delete(cuppingForm)
                            try? moc.save()
                        }
                        cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first)
                    }
                }
                .confirmationDialog(
                    "Are you sure you want to delete cupping form and all related cuppings?",
                    isPresented: $deleteAlertActive,
                    titleVisibility: .visible,
                    actions: {
                        Button("Delete", role: .destructive) {
                            if let deleteAlertCuppingForm {
                                moc.delete(deleteAlertCuppingForm)
                                try? moc.save()
                            }
                            deleteAlertCuppingForm = nil
                            deleteAlertActive = false
                        }
                        Button("Cancel", role: .cancel) {
                            deleteAlertCuppingForm = nil
                            deleteAlertActive = false
                        }
                    }
                )
            }
            
            let availableCFsModels = cfManager.allCFModels.filter {
                $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
            }
            
            if availableCFsModels.count > 0 {
                Section("Available cupping forms") {
                    ForEach(availableCFsModels) { cfModel in
                        Button {
                            if let addedForm = cfModel.createCuppingForm(context: moc) {
                                cfManager.setDefaultCuppingForm(cuppingForm: addedForm)
                            }
                        } label: {
                            Label(cfModel.title, systemImage: "plus")
                        }
                    }
                }
            }
        }
    }
}
