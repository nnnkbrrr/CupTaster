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
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: false)]
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
                            let sectionsData: [SectionData] = getSectionsData(folderFilter: folderFilter)
                            
                            if sectionsData.isEmpty { isEmpty } else {
                                LazyVStack(alignment: .leading, spacing: 0) {
                                    ForEach(sectionsData) { sectionData in
                                        MonthSection(
                                            title: sectionData.monthAndYear.string,
                                            cuppings: sectionData.cuppings,
                                            samples: sectionData.samples,
                                            folderFilter: selectedFolderFilter
                                        )
                                    }
                                }
                                .padding([.horizontal, .bottom], .small)
                            }
                        }
                        .background(Color.backgroundPrimary)
                        .id(selectedFolderFilter.animationId)
                        .transition(.asymmetric(
                            insertion: .move(edge: prevSelectedFolderFilterOrdinalNumber > selectedFolderFilter.ordinalNumber ? .leading : .trailing),
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
        .adaptiveSizeSheet(isPresented: $newCuppingModalIsActive) {
            NewCuppingModalView(isPresented: $newCuppingModalIsActive)
        }
        .animation(.smooth(duration: 0.3), value: selectedFolderFilter)
        .onChange(of: selectedFolderFilter) { newValue in
            DispatchQueue.main.async {
                self.prevSelectedFolderFilterOrdinalNumber = newValue.ordinalNumber
            }
        }
    }
    
    struct MonthSection: View {
        let title: String
        let cuppings: [Cupping]
        let samples: [Sample]
        let folderFilter: FolderFilter
        
        @State var isExpanded: Bool = true
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(title)
                        .bold()
                        .padding(.horizontal, .extraSmall)
                        .frame(height: .smallElement)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .padding(.trailing, .extraSmall)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.smooth) {
                        isExpanded.toggle()
                    }
                }
                
                if isExpanded {
                    VStack(spacing: .extraSmall) {
                        ForEach(cuppings) { CuppingPreview($0) }
                        
                        if samples != [] {
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
                                ForEach(samples) { SamplePreview($0, showCupping: true, animationId: folderFilter.animationId) }
                            }
                        }
                    }
                    .transition(.offset(y: 100).combined(with: .opacity).combined(with: .scale(scale: 0, anchor: .top)))
                }
            }
        }
    }
    
    class SectionData: Identifiable {
        var id: String { monthAndYear.string }
        let monthAndYear: MonthAndYear
        var cuppings: [Cupping]
        var samples: [Sample]
        
        init(monthAndYear: MonthAndYear, cuppings: [Cupping], samples: [Sample]) {
            self.monthAndYear = monthAndYear
            self.cuppings = cuppings
            self.samples = samples
        }
        
        func sortData() {
            cuppings.sort(by: { $0.date > $1.date })
            samples.sort(by: { $0.date > $1.date && $0.ordinalNumber < $1.ordinalNumber })
        }
    }
}

extension MainTabView {
    func getSectionsData(folderFilter: FolderFilter) -> [MainTabView.SectionData] {
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
        
        let sectionsData: [MainTabView.SectionData] = groupedFolderElements.map { (key: MonthAndYear, folderElements: (cuppings: [Cupping], samples: [Sample])) in
            MainTabView.SectionData(monthAndYear: key, cuppings: folderElements.cuppings, samples: folderElements.samples)
        }
        
        for sectionData in sectionsData { sectionData.sortData() }
        
        return sectionsData.sorted(by: { $0.monthAndYear < $1.monthAndYear })
    }
}
