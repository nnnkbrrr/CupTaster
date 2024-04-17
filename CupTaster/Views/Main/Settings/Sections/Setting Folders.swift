//
//  Setting Folders.swift
//  CupTaster
//
//  Created by Nikita on 01.03.2024.
//

import SwiftUI

struct Settings_FoldersView: View {
    static let nameLengthLimit = 25
    
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    @ObservedObject var moveRows: RowMove = .init()
    
    @State var newFolderModalIsActive: Bool = false
    @State var newFolderTitle: String = ""
    @State var newFolderCuppings: [Cupping] = []
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection {
                    ForEach(FolderFilter.pinnedFolders) { pinnedFolder in
                        SettingsRow(title: pinnedFolder.name ?? "New Folder", systemImageName: "folder") {
                            Image(systemName: "pin.fill")
                                .foregroundColor(.gray)
                                .padding(.trailing, .small)
                        }
                    }
                }
                
                if !folders.isEmpty {
                    SettingsSection("Added") {
                        ForEach(folders) { folder in
                            FolderRowView(folder: folder, moveRows: moveRows)
                        }
                    }
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    newFolderModalIsActive = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Folders")
        .defaultNavigationBar()
        .modalView(
            isPresented: $newFolderModalIsActive,
            toolbar: .init(
                leadingToolbarItem: .init("Cancel") { newFolderModalIsActive = false },
                title: "New Folder",
                trailingToolbarItem: .init("Add") {
                    let folder: Folder = .init(context: moc)
                    folder.name = newFolderTitle
                    folder.ordinalNumber = Int16(folders.count)
                    for cupping in newFolderCuppings { folder.addToCuppings(cupping) }
                    save(moc)
                    newFolderModalIsActive = false
                }
            )
        ) {
            NewFolderView(newFolderTitle: $newFolderTitle, newFolderCuppings: $newFolderCuppings)
        }
    }
}

extension Settings_FoldersView {
    class RowMove: ObservableObject, Equatable {
        static func == (lhs: Settings_FoldersView.RowMove, rhs: Settings_FoldersView.RowMove) -> Bool {
            lhs.rows == rhs.rows
        }
        
        @Published var rows: [Int16]
        @Published var edge: VerticalAlignment
        
        init() {
            self.rows = []
            self.edge = .center
        }
        
        func reset() {
            rows = []
            edge = .center
        }
    }
    
    struct FolderRowView: View {
        @Environment(\.managedObjectContext) private var moc
        @FetchRequest(
            entity: Folder.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
        ) var folders: FetchedResults<Folder>
        @ObservedObject var folder: Folder
        
        @ObservedObject var moveRows: RowMove
        @State var offset: CGSize = .zero
        @State var rawOrdinalOffset: Int16 = 0
        
        let rowOffsetValue: CGFloat = 60 + .extraSmall / 2 // height + spacing
        
        var body: some View {
            SwipeView(gestureType: GestureType.unspecified) {
                SettingsTextFieldSection(text: $folder.name, prompt: "New Folder", systemImageName: "folder") {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                        .font(.title2)
                }
                .submitLabel(.done)
                .onChange(of: folder.name) { folderName in
                    if folderName.count > Settings_FoldersView.nameLengthLimit {
                        folder.name = String(folderName.prefix(Settings_FoldersView.nameLengthLimit))
                    }
                    save(moc)
                }
                .frame(height: 60)
                .background(Color.backgroundSecondary)
                .cornerRadius()
                .offset(offset)
                .offset(y: moveRows.rows.contains(folder.ordinalNumber) && offset == .zero ? rowOffsetValue * (moveRows.edge == .top ? -1 : 1) : 0)
                .onChange(of: folder.name) { _ in
                    save(moc)
                }
                .overlay(alignment: .trailing) {
                    Color.clear
                        .frame(width: .smallElementContainer, height: .smallElementContainer)
                        .contentShape(Rectangle())
                        .dragGesture(gestureType: .highPriority) { } onUpdate: { gesture in
                            let translation: CGSize = gesture.translation
                            self.offset = translation
                            
                            withAnimation {
                                rawOrdinalOffset = Int16(translation.height / rowOffsetValue)
                                if rawOrdinalOffset + folder.ordinalNumber < 0 { rawOrdinalOffset = -folder.ordinalNumber }
                                else if rawOrdinalOffset > folders.count - 1 { rawOrdinalOffset = Int16(folders.count) - folder.ordinalNumber - 1 }
                                
                                if rawOrdinalOffset > 0 {
                                    moveRows.rows = Array(folder.ordinalNumber...(folder.ordinalNumber + rawOrdinalOffset))
                                    moveRows.edge = .top
                                } else if rawOrdinalOffset < 0 {
                                    moveRows.rows = Array(((folder.ordinalNumber + rawOrdinalOffset)..<folder.ordinalNumber))
                                    moveRows.edge = .bottom
                                } else {
                                    moveRows.rows = []
                                    moveRows.edge = .center
                                }
                            }
                        } onEnd: { gesture in
                            for row in moveRows.rows {
                                for folder in folders {
                                    if folder.ordinalNumber == row && folder != self.folder {
                                        folder.ordinalNumber += moveRows.edge == .top ? -1 : 1
                                    }
                                }
                            }
                            self.folder.ordinalNumber += rawOrdinalOffset
                            
                            self.offset = .zero
                            moveRows.reset()
                            orderValidation()
                            
                            save(moc)
                        } onCancel: {
                            self.offset = .zero
                            moveRows.reset()
                        }
                }
            } trailingActions: { _ in
                SwipeAction {
                    withAnimation {
                        moc.delete(folder)
                        save(moc)
                    }
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
            .onChange(of: rawOrdinalOffset) { _ in UISelectionFeedbackGenerator().selectionChanged() }
        }
        
        func orderValidation() {
            for (index, folder) in folders.sorted(by: { $0.ordinalNumber < $1.ordinalNumber }).enumerated() {
                folder.ordinalNumber = Int16(index)
            }
        }
    }
}

extension Settings_FoldersView {
    struct NewFolderView: View {
        @FetchRequest(
            entity: Cupping.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
        ) var cuppings: FetchedResults<Cupping>
        
        @Binding var newFolderTitle: String
        @Binding var newFolderCuppings: [Cupping]
        
        var body: some View {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection {
                    TextField("Title", text: $newFolderTitle)
                        .resizableText(weight: .light)
                        .submitLabel(.done)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .padding(.vertical, .regular)
                        .onChange(of: newFolderTitle) { newFolderTitle in
                            if newFolderTitle.count > Settings_FoldersView.nameLengthLimit {
                                self.newFolderTitle = String(newFolderTitle.prefix(Settings_FoldersView.nameLengthLimit))
                            }
                        }
                        .bottomSheetBlock()
                }
                
                SettingsSection("Add Cuppings") {
                    ForEach(Array(cuppings)) { cupping in
                        SettingsButtonSection(title: cupping.name == "" ? "New Cupping" : cupping.name) {
                            if newFolderCuppings.contains(cupping) { newFolderCuppings.removeAll(where: { $0 == cupping })}
                            else { newFolderCuppings.append(cupping) }
                        } leadingContent: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                                .opacity(newFolderCuppings.contains(cupping) ? 1 : 0)
                        }
                    }
                }
            }
            .padding(.small)
        }
    }
}
