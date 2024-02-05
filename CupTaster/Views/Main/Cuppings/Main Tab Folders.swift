//
//  Main Tab Folders.swift
//  CupTaster
//
//  Created by Nikita on 03.02.2024.
//

import SwiftUI
import CoreData

protocol FolderElement: NSManagedObject, Identifiable {
    var isFavorite: Bool { get set }
    var date: Date { get }
}

extension Cupping: FolderElement { }
extension Sample: FolderElement {
    var date: Date { self.cupping.date }
}

struct AnyFolderElement: Identifiable, Hashable {
    static func == (lhs: AnyFolderElement, rhs: AnyFolderElement) -> Bool {
        rhs.wrapped.id == lhs.wrapped.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(wrapped)
    }
    
    var id: NSManagedObjectID
    var wrapped: any FolderElement
    
    init(wrapped: any FolderElement) {
        self.id = wrapped.objectID
        self.wrapped = wrapped
    }
}

class FolderFilter: Identifiable, Hashable {
    var animationId: UUID
    let ordinalNumber: Int
    let folder: Folder?
    let name: String
    let predicate: ([any FolderElement]) -> ([any FolderElement])
    
    init(folder: Folder) {
        self.animationId = UUID()
        self.ordinalNumber = Int.random(in: 0...10)
        self.folder = folder
        self.name = folder.name
        self.predicate = { data in return data }
    }
    
    init(name: String, ordinalNumber: Int, predicate: @escaping ([any FolderElement]) -> ([any FolderElement])) {
        self.animationId = UUID()
        self.ordinalNumber = ordinalNumber
        self.folder = nil
        self.name = name
        self.predicate = predicate
    }
    
    static let all: FolderFilter = .init(name: "All", ordinalNumber: -2) { return $0.filter { $0 is Cupping } }
    static let favorites: FolderFilter = .init(name: "Favorites", ordinalNumber: -1) { return $0.filter { $0.isFavorite } }
    
    static func == (lhs: FolderFilter, rhs: FolderFilter) -> Bool {
        return lhs.ordinalNumber == rhs.ordinalNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(ordinalNumber)
    }
}

struct MainTabToolbar: View {
    let allFolderFilters: [FolderFilter]
    @Binding var selectedFolderFilter: FolderFilter
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .small) {
                ForEach(allFolderFilters) {
                    FolderFilterView($0, selected: $selectedFolderFilter)
                }
            }
            .padding(.horizontal, .regular)
            .frame(height: .extraLarge)
        }
    }
    
    struct FolderFilterView: View {
        let folderFilter: FolderFilter
        @Binding var selectedFolderFilter: FolderFilter
        
        init(_ folderFilter: FolderFilter, selected selectedFolderFilter: Binding<FolderFilter>) {
            self.folderFilter = folderFilter
            self._selectedFolderFilter = selectedFolderFilter
        }
        
        var body: some View {
            ZStack(alignment: .bottom) {
                let isSelected: Bool = selectedFolderFilter == folderFilter
                Text(folderFilter.name)
                    .foregroundStyle(isSelected ? Color.accentColor : .gray)
                    .frame(maxHeight: .infinity)
                    .padding(.horizontal, .small)
                    .onTapGesture {
                        folderFilter.animationId = UUID()
                        selectedFolderFilter = folderFilter
                    }
                
                if isSelected {
                    Capsule()
                        .foregroundStyle(.accent)
                        .frame(height: 3)
                        .matchedGeometryEffect(id: "folder.underline", in: NamespaceControllerModel.shared.namespace)
                }
            }
        }
    }
}
