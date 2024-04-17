//
//  Setting Cupping Forms.swift
//  CupTaster
//
//  Created by Nikita on 06.02.2024.
//

import SwiftUI

struct Settings_CuppingFormsView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @StateObject var cfManager = CFManager.shared
    
    @State var deleteAlertActive: Bool = false
    
    let showNavigationBar: Bool
    
    init(showNavigationBar: Bool = true) {
        self.showNavigationBar = showNavigationBar
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection {
                    let notDeprecatedCuppingForms: [CuppingForm] = cuppingForms.filter { !$0.isDeprecated }
                    let deprectaredCuppingForms: [CuppingForm] = cuppingForms.filter { $0.isDeprecated }
                    
                    if notDeprecatedCuppingForms.isEmpty {
                        SettingsRow(title: "No cupping forms forms were added")
                    }
                        
                    ForEach(notDeprecatedCuppingForms) { cuppingForm in
                        SwipeView {
                            SettingsButtonSection(title: cuppingForm.title) {
                                cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                            } leadingContent: {
                                Image(systemName: "checkmark")
                                    .opacity(cuppingForm.isDefault ? 1 : 0)
                            }
                        } trailingActions: { _ in
                            SwipeAction {
                                #warning("migration")
                                
                            } label: { _ in
                                VStack(spacing: .extraSmall) {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("Update")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            } background: { _ in
                                Color.orange
                            }
                            
                            SwipeAction {
                                if cuppingForm.cuppings.count > 0 {
                                    deleteAlertActive = true
                                } else {
                                    moc.delete(cuppingForm)
                                    save(moc)
                                }
                                cfManager.setDefaultCuppingForm(cuppingForm: cuppingForms.first(where: { !$0.isDeprecated }))
                            } label: { _ in
                                VStack(spacing: .extraSmall) {
                                    Image(systemName: "trash")
                                    Text("Delete")
                                }
                                .font(.subheadline)
                                .foregroundStyle(.white)
                            } background: { _ in
                                Color.red
                            }
                        }
                        .defaultSwipeStyle()
                        .confirmationDialog(
                            "Are you sure you want to delete cupping form and all related cuppings?",
                            isPresented: $deleteAlertActive,
                            titleVisibility: .visible,
                            actions: {
                                Button("Delete", role: .destructive) {
                                    moc.delete(cuppingForm)
                                    save(moc)
                                    deleteAlertActive = false
                                }
                                Button("Cancel", role: .cancel) {
                                    deleteAlertActive = false
                                }
                            }
                        )
                    }
                    
                    if !deprectaredCuppingForms.isEmpty {
                        SettingsNavigationSection(
                            title: "Archive",
                            systemImageName: "archivebox",
                            trailingBadge: "\(deprectaredCuppingForms.count)",
                            destination: { CuppingFormsArchiveView() }
                        )
                    }
                }
                
                let availableCuppingFormModels: [CFManager.CFModel] = cfManager.allCFModels.filter {
                    $0.getCuppingForm(storedCuppingForms: cuppingForms) == nil
                }
                
                if availableCuppingFormModels.count > 0 {
                    SettingsSection("Available") {
                        ForEach(availableCuppingFormModels) { cuppingFormModel in
                            SettingsButtonSection(title: cuppingFormModel.title, systemImageName: "plus") {
                                if let cuppingForm = cuppingFormModel.createCuppingForm(context: moc) {
                                    cfManager.setDefaultCuppingForm(cuppingForm: cuppingForm)
                                }
                            }
                        }
                    }
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .modifier(NavigationBarModifier(show: showNavigationBar))
    }
    
    private struct NavigationBarModifier: ViewModifier {
        let showNavigationBar: Bool
        
        init(show showNavigationBar: Bool) {
            self.showNavigationBar = showNavigationBar
        }
        
        func body(content: Content) -> some View {
            if showNavigationBar {
                content
                    .navigationTitle("Cupping Forms")
                    .defaultNavigationBar()
            } else {
                content
            }
        }
    }
}
