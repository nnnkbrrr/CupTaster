//
//  Folders Model.swift
//  CupTaster
//
//  Created by Nikita on 01.03.2024.
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
    let name: String?
    let predicate: ([any FolderElement]) -> ([any FolderElement])
    
    init(folder: Folder) {
        self.animationId = UUID()
        self.ordinalNumber = Int(folder.ordinalNumber)
        self.name = nil
        self.folder = folder
        self.predicate = { data in return data }
    }
    
    init(name: String, ordinalNumber: Int, predicate: @escaping ([any FolderElement]) -> ([any FolderElement])) {
        self.animationId = UUID()
        self.ordinalNumber = ordinalNumber
        self.folder = nil
        self.name = name
        self.predicate = predicate
    }
    
    @MainActor static let all: FolderFilter = .init(name: "All", ordinalNumber: -2) {
        if SearchModel.shared.searchValue == "" {
            return $0.filter { $0 is Cupping }
        } else { return $0 }
    }
    @MainActor static let favorites: FolderFilter = .init(name: "Favorites", ordinalNumber: -1) { return $0.filter { $0.isFavorite } }
    @MainActor static let pinnedFolders: [FolderFilter] = [.all, .favorites]
    
    static func == (lhs: FolderFilter, rhs: FolderFilter) -> Bool {
        return lhs.ordinalNumber == rhs.ordinalNumber
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(folder)
    }
}

extension FolderFilter {
    // Cuppings
    @MainActor func containsCupping(_ cupping: Cupping) -> Bool {
        if folder?.cuppings.contains(cupping) ?? false { return true }
        else if self == FolderFilter.all { return true }
        else if self == FolderFilter.favorites { return cupping.isFavorite }
        return false
    }
    
    @MainActor func addCupping(_ cupping: Cupping, context: NSManagedObjectContext) {
        if self == FolderFilter.all { return }
        else if self == FolderFilter.favorites { cupping.isFavorite = true }
        else { folder?.addToCuppings(cupping) }
        save(context)
    }
    
    @MainActor func removeCupping(_ cupping: Cupping, context: NSManagedObjectContext) {
        if self == FolderFilter.all { return }
        else if self == FolderFilter.favorites { cupping.isFavorite = false }
        else { folder?.removeFromCuppings(cupping) }
        save(context)
    }
    
    // Samples
    @MainActor func containsSample(_ sample: Sample) -> Bool {
        if folder?.samples.contains(sample) ?? false { return true }
        else if self == FolderFilter.all { return true }
        else if self == FolderFilter.favorites { return sample.isFavorite }
        return false
    }
    
    @MainActor func addSample(_ sample: Sample, context: NSManagedObjectContext) {
        if self == FolderFilter.all { return }
        else if self == FolderFilter.favorites { sample.isFavorite = true }
        else { folder?.addToSamples(sample) }
        save(context)
    }
    
    @MainActor func removeSample(_ sample: Sample, context: NSManagedObjectContext) {
        if self == FolderFilter.all { return }
        else if self == FolderFilter.favorites { sample.isFavorite = false }
        else { folder?.removeFromSamples(sample) }
        save(context)
    }
}
