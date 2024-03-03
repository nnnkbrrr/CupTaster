//
//  Setting Folders.swift
//  CupTaster
//
//  Created by Nikita on 01.03.2024.
//

import SwiftUI
import SwipeActions

struct Settings_FoldersView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    @ObservedObject var moveRows: RowMove = .init()
    
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
                    let folder: Folder = .init(context: moc)
                    folder.ordinalNumber = Int16(folders.count)
                    try? moc.save()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .navigationTitle("Folders")
        .defaultNavigationBar()
    }
    
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
            SwipeView {
                SettingsTextFieldSection(text: $folder.name, prompt: "New Folder", systemImageName: "folder") {
                    Image(systemName: "line.3.horizontal")
                        .foregroundColor(.gray)
                        .font(.title2)
                        .contentShape(Rectangle())
                }
                .submitLabel(.done)
                .onChange(of: folder.name) { _ in
                    try? moc.save()
                }
            } trailingActions: { _ in
                SwipeAction {
                    withAnimation {
                        moc.delete(folder)
                        try? moc.save()
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
            .cornerRadius()
            .background(Color.backgroundSecondary)
            .cornerRadius()
            .frame(height: 60)
            .offset(offset)
            .offset(y: moveRows.rows.contains(folder.ordinalNumber) && offset == .zero ? rowOffsetValue * (moveRows.edge == .top ? -1 : 1) : 0)
            .onChange(of: rawOrdinalOffset) { _ in
                UISelectionFeedbackGenerator().selectionChanged()
            }
            .dragGesture(gestureType: .simultaneous) { } onUpdate: { gesture in
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
                
                try? moc.save()
            } onCancel: {
                withAnimation {
                    self.offset = .zero
                    moveRows.reset()
                }
            }
        }
        
        func orderValidation() {
            for (index, folder) in folders.sorted(by: { $0.ordinalNumber < $1.ordinalNumber }).enumerated() {
                folder.ordinalNumber = Int16(index)
            }
        }
    }
}
