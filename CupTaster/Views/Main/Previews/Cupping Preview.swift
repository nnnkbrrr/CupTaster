//
//  Main Tab Cupping Preview.swift
//  CupTaster
//
//  Created by Nikita on 04.02.2024.
//

import SwiftUI

struct CuppingPreview: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    @ObservedObject var cupping: Cupping
    @State var foldersModalIsActive: Bool = false
    
    @State var exportCuppingWithDeprecatedForm: Bool = false
    @State var migrationCuppingFormCopy: CuppingForm? = nil
    
    init(_ cupping: Cupping) {
        self.cupping = cupping
    }
    
    var body: some View {
        SwipeView(gestureType: .simultaneous) {
            if cupping.isFault {
                EmptyView()
            } else {
                if cupping.form?.isDeprecated ?? false {
                    Button {
                        if let cuppingForm: CuppingForm = cupping.form, cuppingForm.title.contains("SCA") {
                            migrationCuppingFormCopy = cuppingForm
                        } else {
                            exportCuppingWithDeprecatedForm = true
                        }
                    } label: {
                        content
                    }
                } else {
                    NavigationLink(destination: CuppingView(cupping)) {
                        content
                    }
                }
            }
        } leadingActions: { context in
            if cupping.isFavorite {
                SwipeActionView(systemImage: "heart.slash.fill", title: "Remove", color: .accentColor) {
                    cupping.isFavorite = false
                    save(moc)
                    context.state.wrappedValue = .closed
                }
            } else {
                SwipeActionView(systemImage: "heart.fill", title: "Mark", color: .accentColor) {
                    cupping.isFavorite = true
                    save(moc)
                    context.state.wrappedValue = .closed
                }
            }
            
            SwipeActionView(systemImage: "folder.fill.badge.gearshape", title: "Folders", color: .indigo) {
                foldersModalIsActive = true
                context.state.wrappedValue = .closed
            }
        } trailingActions: { _ in
            SwipeActionView(systemImage: "trash.fill", title: "Delete", color: .red) {
                withAnimation {
                    moc.delete(cupping)
                    save(moc)
                }
            }
        }
        .defaultSwipeStyle()
        .contextMenu {
            Section {
                Button {
                    cupping.isFavorite.toggle()
                    save(moc)
                } label: {
                    if cupping.isFavorite {
                        Label("Remove from Favorites", systemImage: "heart.slash.fill")
                    } else {
                        Label("Add to Favorites", systemImage: "heart")
                    }
                }
                
                Button {
                    foldersModalIsActive = true
                } label: {
                    Label("Manage Folders", systemImage: "folder.badge.gearshape")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    withAnimation {
                        moc.delete(cupping)
                        save(moc)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
        .modalView(
            isPresented: $foldersModalIsActive,
            toolbar: .init(
                title: "Folders",
                trailingToolbarItem: .init("Done") {
                    foldersModalIsActive = false
                }
            )
        ) {
            ScrollView {
                LazyVStack(spacing: .extraSmall) {
                    ForEach([FolderFilter.favorites] + folders.map { FolderFilter(folder: $0) }) { folderFilter in
                        let folderContainsCupping: Bool = folderFilter.containsCupping(cupping)
                        
                        SettingsButtonSection(title: folderFilter.name ?? folderFilter.folder?.name ?? "New Folder") {
                            if folderContainsCupping { folderFilter.removeCupping(cupping, context: moc) }
                            else { folderFilter.addCupping(cupping, context: moc) }
                        } leadingContent: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                                .opacity(folderContainsCupping ? 1 : 0)
                        }
                    }
                }
            }
            .padding(.horizontal, .small)
        }
        .adaptiveSizeSheet(isPresented: Binding(
            get: { migrationCuppingFormCopy != nil },
            set: { _ in migrationCuppingFormCopy = nil }
        )) {
            DeprectaredCuppingFormMigrationModalView(cuppingFormToMigrate: $migrationCuppingFormCopy)
        }
        .adaptiveSizeSheet(isPresented: $exportCuppingWithDeprecatedForm) {
            VStack(spacing: .large) {
                Text("This cupping form is no longer supported")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .regular)
                
                Text("We apologize for the inconvenience. You can export all your cupping data.")
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .regular)
                
                HStack(spacing: .extraSmall) {
                    Button("OK") {
                        exportCuppingWithDeprecatedForm = false
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button("Export") {
                        cupping.shareCSV()
                    }
                    .buttonStyle(.accentBottomSheetBlock)
                }
            }
            .padding(.small)
        }
    }
    
    var content: some View {
        HStack(spacing: .extraSmall) {
            VStack(alignment: .leading, spacing: .extraSmall) {
                Text(cupping.name == "" ? "New Cupping" : cupping.name)
                    .multilineTextAlignment(.leading)
                    .font(.callout)
                
                let titleText: String = "\(cupping.form?.title ?? "")"
                let samplesText: String = "\(cupping.samples.count) Samples"
                let cupsText: String = "\(cupping.cupsCount) Cups"
                
                HStack {
                    if cupping.form?.isDeprecated ?? false {
                        Image(systemName: "exclamationmark.triangle")
                            .foregroundStyle((cupping.form?.title ?? "").contains("SCA") ? .orange : .gray)
                    }
                    Text("\(titleText) • \(samplesText) • \(cupsText)")
                        .foregroundColor(.gray)
                }
                .font(.caption)
                
                if let location: Location = cupping.location {
                    Text("\(Image(systemName: "mappin.circle")) \(location.address)")
                        .multilineTextAlignment(.leading)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            
            Spacer()
            
            if cupping.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .font(.caption)
            }
            
            Text(cupping.date.short)
                .font(.caption)
                .foregroundStyle(.gray)
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
        }
        .padding(.regular)
        .background(Color.backgroundSecondary)
        .cornerRadius()
    }
}
