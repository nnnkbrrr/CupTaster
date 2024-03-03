//
//  Main Tab Folders.swift
//  CupTaster
//
//  Created by Nikita on 03.02.2024.
//

import SwiftUI

struct MainTabToolbar: View {
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    
    let allFolderFilters: [FolderFilter]
    @Binding var selectedFolderFilter: FolderFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .small) {
                Group {
                    ForEach(allFolderFilters) { folderFilter in
                        FolderFilterView(
                            title: {
                                if let folder = folderFilter.folder { folder.name == "" ? "New Folder" : folder.name }
                                else { folderFilter.name ?? "New Folder"}
                            },
                            isSelected: { selectedFolderFilter == folderFilter },
                            onSelect: {
                                folderFilter.animationId = UUID()
                                selectedFolderFilter = folderFilter
                            }
                        )
                    }
                }
            }
            .padding(.horizontal, .regular)
            .frame(height: .extraLarge)
        }
    }
        
    struct FolderFilterView: View {
        let title: () -> String
        let isSelected: () -> Bool
        let onSelect: () -> ()
        
        init(title: @escaping () -> String, isSelected: @escaping () -> Bool, onSelect: @escaping () -> Void) {
            self.title = title
            self.isSelected = isSelected
            self.onSelect = onSelect
        }
        
        var body: some View {
            Text(title())
                .foregroundStyle(isSelected() ? Color.accentColor : .gray)
                .frame(maxHeight: .infinity)
                .padding(.horizontal, .small)
                .overlay(alignment: .bottom) {
                    if isSelected() {
                        Capsule()
                            .foregroundStyle(.accent)
                            .frame(height: 3)
                            .matchedGeometryEffect(id: "folder.underline", in: NamespaceControllerModel.shared.namespace)
                    }
                }
                .onTapGesture { onSelect() }
        }
    }
}
