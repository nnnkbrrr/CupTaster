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
                        ScrollView {
                            if let folderElementsGroupedByMonth: [(key: Date, value: (cuppings: [Cupping], samples: [Sample]))] =
                                getFolderElementsGroupedByMonth(folderFilter: folderFilter)
                            {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(folderElementsGroupedByMonth, id: \.key) { date, folderElements in
                                        Text(DateFormatter.fullMonthAndYear.string(from: date))
                                            .bold()
                                            .padding(.horizontal, .extraSmall)
                                            .frame(height: .smallElement)
                                        
                                        LazyVStack(spacing: .extraSmall) {
                                            ForEach(folderElements.cuppings) { CuppingPreview($0) }
                                            
                                            LazyVGrid(
                                                columns: [
                                                    GridItem(
                                                        .adaptive(minimum: 150, maximum: 200),
                                                        spacing: .extraSmall,
                                                        alignment: .top
                                                    )
                                                ],
                                                spacing: .extraSmall
                                            ) {
                                                ForEach(folderElements.samples) { SamplePreview($0, showCupping: true, animationId: folderFilter.animationId) }
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, .small)
                            } else {
                                isEmpty
                            }
                        }
                        .background(Color.backgroundPrimary)
                        .id(selectedFolderFilter.animationId)
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
    func getFolderElementsGroupedByMonth(folderFilter: FolderFilter) -> [(key: Date, value: (cuppings: [Cupping], samples: [Sample]))]? {
        let filteredCuppings: [Cupping] = folderFilter.predicate(Array(cuppings)).compactMap { $0 as? Cupping ?? nil }
        let filteredSamples: [Sample] = folderFilter.predicate(Array(samples)).compactMap { $0 as? Sample ?? nil }
        
        guard let firstCupping: Cupping = filteredCuppings.first else { return nil }
        var key: Date = firstCupping.date
        var groupedFolderElements: [Date: (cuppings: [Cupping], samples: [Sample])] = [key: (cuppings: [firstCupping], samples: [])]

        let calendar: Calendar = Calendar.current
        for (prevCupping, nextCupping) in zip(filteredCuppings, filteredCuppings.dropFirst()) {
            if !calendar.isDate(prevCupping.date, equalTo: nextCupping.date, toGranularity: .month) {
                key = nextCupping.date
            }
            groupedFolderElements[key, default: (cuppings: [], samples: [])].cuppings.append(nextCupping)
        }
        
        for (prevSample, nextSample) in zip(filteredSamples, filteredSamples.dropFirst()) {
            if !calendar.isDate(prevSample.date, equalTo: nextSample.date, toGranularity: .month) {
                key = nextSample.date
            }
            groupedFolderElements[key, default: (cuppings: [], samples: [])].samples.append(nextSample)
        }
        
        return groupedFolderElements.mapValues { (cuppings: [Cupping], samples: [Sample]) in
            (cuppings: cuppings.sorted(by: { $0.date < $1.date }), samples: samples.sorted(by: { $0.ordinalNumber < $1.ordinalNumber }) )
        }.sorted(by: { $0.key > $1.key })
    }
}
