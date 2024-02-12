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
        NavigationView {
            let allFolderFilters: [FolderFilter] = [.all, .favorites] + folders.map { FolderFilter(folder: $0) }
            
            ZStack {
                ForEach(allFolderFilters) { folderFilter in
                    if selectedFolderFilter == folderFilter {
                        ScrollView {
                            if let folderElementsGroupedByMonth: [(key: MonthAndYear, value: (cuppings: [Cupping], samples: [Sample]))] =
                                getFolderElementsGroupedByMonth(folderFilter: folderFilter)
                            {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(folderElementsGroupedByMonth, id: \.key) { monthAndYear, folderElements in
                                        Text(monthAndYear.string)
                                            .bold()
                                            .padding(.horizontal, .extraSmall)
                                            .frame(height: .smallElement)
                                        
                                        LazyVStack(spacing: .extraSmall) {
                                            ForEach(folderElements.cuppings) { CuppingPreview($0) }
                                            
                                            if folderElements.samples != [] {
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
                                }
                                .padding([.horizontal, .bottom], .small)
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
    func getFolderElementsGroupedByMonth(folderFilter: FolderFilter) -> [(key: MonthAndYear, value: (cuppings: [Cupping], samples: [Sample]))]? {
        let filteredCuppings: [Cupping] = folderFilter.predicate(Array(cuppings)).compactMap { $0 as? Cupping ?? nil }
        let filteredSamples: [Sample] = folderFilter.predicate(Array(samples)).compactMap { $0 as? Sample ?? nil }
        
        var groupedFolderElements: [MonthAndYear: (cuppings: [Cupping], samples: [Sample])] = [:]

        for cupping in filteredCuppings {
            let key = cupping.date.getMonthAndYear()
            groupedFolderElements[key, default: (cuppings: [], samples: [])].cuppings.append(cupping)
        }
        
        for sample in filteredSamples {
            let key = sample.date.getMonthAndYear()
            groupedFolderElements[key, default: (cuppings: [], samples: [])].samples.append(sample)
        }
        
        return groupedFolderElements.mapValues { (cuppings: [Cupping], samples: [Sample]) in
            (cuppings: cuppings.sorted(by: { $0.date > $1.date }), samples: samples.sorted(by: { $0.date > $1.date && $0.ordinalNumber < $1.ordinalNumber }) )
        }.sorted(by: { $0.key > $1.key })
    }
}
