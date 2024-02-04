//
//  All Cuppings.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.06.2023.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @FetchRequest(
        entity: Cupping.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Cupping.date, ascending: false)]
    ) var cuppings: FetchedResults<Cupping>
    
    @FetchRequest(
        entity: Sample.entity(),
        sortDescriptors: []
    ) var samples: FetchedResults<Sample>
    
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.lastModifiedDate, ascending: false)]
    ) var folders: FetchedResults<Folder>
    @State var selectedFolderFilter: FolderFilter = FolderFilter.all
    @State var prevSelectedFolderFilterOrdinalNumber: Int = FolderFilter.all.ordinalNumber
    @State var animationID: UUID = UUID()
    
    @State var newCuppingModalIsActive: Bool = false
    
    init() {
        Navigation.configureWithoutBackground()
    }
    
    var body: some View {
        let allFolderFilters: [FolderFilter] = [.all, .favorites] + folders.map { FolderFilter(folder: $0) }
        
        NavigationView {
            ZStack {
                ForEach(allFolderFilters) { folderFilter in
                    if selectedFolderFilter == folderFilter {
                        GeometryReader { geometry in
                            ScrollView {
                                if let folderElementsGroupedByMonth: [Dictionary<Date, [AnyFolderElement]>.Element] =
                                    getFolderElementsGroupedByMonth(folderFilter: folderFilter)
                                {
                                    LazyVStack(alignment: .leading, spacing: 0) {
                                        ForEach(folderElementsGroupedByMonth, id: \.key) { date, anyFolderElements in
                                            Text(DateFormatter.fullMonthAndYear.string(from: date))
                                                .bold()
                                                .padding(.horizontal, .extraSmall)
                                                .frame(height: .smallElement)
                                            
                                            LazyVGrid(
                                                columns: [
                                                    GridItem(.flexible(), spacing: .extraSmall, alignment: .topLeading),
                                                    GridItem(.flexible(), spacing: .extraSmall, alignment: .topLeading)
                                                ],
                                                spacing: .extraSmall
                                            ) {
                                                ForEach(anyFolderElements) { anyFolderElement in
                                                    if let cupping: Cupping = anyFolderElement.wrapped as? Cupping {
                                                        CuppingPreview(cupping)
                                                            .frame(width: geometry.size.width - .small * 2)
                                                        
                                                        Color.clear
                                                    } else if let sample = anyFolderElement.wrapped as? Sample {
                                                        SamplePreview(sample, page: .main)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .padding(.horizontal, .small)
                                } else {
                                    isEmpty
                                }
                            }
                        }
                        .background(Color.backgroundPrimary)
                        .id(selectedFolderFilter.animationID)
                        .transition(.asymmetric(
                            insertion: .move(
                                edge: prevSelectedFolderFilterOrdinalNumber > selectedFolderFilter.ordinalNumber ? .leading : .trailing
                            ),
                            removal: .opacity.combined(with: .scale(scale: 0.75))
                        ))
                    }
                }
            }
            .background(Color.backgroundPrimary)
            .navigationBarTitle(selectedFolderFilter.name, displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: SettingsTabView()) {
                        Image(systemName: "gearshape")
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        newCuppingModalIsActive = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .navigationToolbar { MainTabToolbar(allFolderFilters: allFolderFilters, selectedFolderFilter: $selectedFolderFilter) }
        }
        .adaptiveSizeSheet(isActive: $newCuppingModalIsActive) {
            NewCuppingModalView(isActive: $newCuppingModalIsActive)
        }
        .animation(.smooth(duration: 0.3), value: selectedFolderFilter)
        .onChange(of: selectedFolderFilter) { newValue in
            DispatchQueue.main.async {
                self.prevSelectedFolderFilterOrdinalNumber = newValue.ordinalNumber
            }
        }
    }
}

extension MainTabView {
    func getFolderElementsGroupedByMonth(folderFilter: FolderFilter) -> [Dictionary<Date, [AnyFolderElement]>.Element]? {
        let filteredCuppings: [AnyFolderElement] = folderFilter.predicate(Array(cuppings)).map { .init(wrapped: $0) }
        let filteredSamples: [AnyFolderElement] = folderFilter.predicate(Array(samples)).map { .init(wrapped: $0) }
        let filteredFolderElements: [AnyFolderElement] = filteredCuppings + filteredSamples
        
        guard let firstElement: AnyFolderElement = filteredFolderElements.first else { return nil }
        
        var key: Date = firstElement.date
        var groupedFolderElements: [Date: [AnyFolderElement]] = [key: [firstElement]]
        
        let calendar: Calendar = Calendar.current
        for (prevElement, nextElement) in zip(filteredFolderElements, filteredFolderElements.dropFirst()) {
            if !calendar.isDate(prevElement.date, equalTo: nextElement.date, toGranularity: .month) {
                key = nextElement.date
            }
            groupedFolderElements[key, default: []].append(nextElement)
        }
        
        #warning("sort inner elements by ordinal number")
        return groupedFolderElements.sorted(by: { $0.key > $1.key })
    }
}
