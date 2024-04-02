//
//  All Cuppings.swift
//  CupTaster
//
//  Created by Никита Баранов on 28.06.2023.
//

import SwiftUI

class SearchModel: ObservableObject {
    static let shared: SearchModel = .init()
    
    @Published var searchIsActive: Bool = false
    @Published var searchValue: String = ""
    
    private init() { }
}

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
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    @State var selectedFolderFilter: FolderFilter = FolderFilter.all
    @State var prevSelectedFolderFilterOrdinalNumber: Int = FolderFilter.all.ordinalNumber
    
    @Namespace var namespace
    @FocusState var searchBarIsFocusd: Bool
    @ObservedObject var searchModel: SearchModel = .shared
    @State var newCuppingModalIsActive: Bool = false
    
    init() {
        Navigation.configureWithoutBackground()
    }
    
    var body: some View {
        NavigationView {
            let allFolderFilters: [FolderFilter] = [.all, .favorites] + folders.map { FolderFilter(folder: $0) }
            let folderFilterName: String = {
                if let folder = selectedFolderFilter.folder { return folder.name == "" ? "New Folder" : folder.name }
                else { return selectedFolderFilter.name ?? "New Folder" }
            }()
            
            ScrollView {
                let sectionsData: [SectionData] = getSectionsData(
                    folderFilter: selectedFolderFilter,
                    searchValue: searchModel.searchValue
                )
                
                if sectionsData.isEmpty { isEmpty } else {
                    LazyVStack(alignment: .leading, spacing: 0) {
                        ForEach(sectionsData) { sectionData in
                            MonthSection(sectionData: sectionData, folderFilter: selectedFolderFilter)
                        }
                    }
                    .padding([.horizontal, .bottom], .small)
                    .background(Color.backgroundPrimary)
                    .id(selectedFolderFilter.animationId)
                    .transition(.asymmetric(
                        insertion: .move(edge: prevSelectedFolderFilterOrdinalNumber > selectedFolderFilter.ordinalNumber ? .leading : .trailing),
                        removal: .opacity.combined(with: .scale(scale: 0.75))
                    ))
                }
            }
            .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
            .navigationBarTitle(folderFilterName)
            .navigationBarHidden(true)
            .navigationToolbar {
                VStack(spacing: .small) {
                    HStack(spacing: .small) {
                        if !searchModel.searchIsActive {
                            NavigationLink(destination: SettingsTabView()) {
                                Image(systemName: "gearshape")
                                    .font(.title3)
                                    .foregroundStyle(.accent)
                            }
                            
                            Spacer()
                            
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .font(.caption)
                                    .matchedGeometryEffect(id: "search-bar-image", in: namespace)
                                
                                Text(folderFilterName)
                                    .font(.subheadline)
                                    .matchedGeometryEffect(id: "search-bar-text", in: namespace)
                            }
                            .foregroundStyle(.gray)
                            .padding(7)
                            .padding(.trailing, .extraSmall)
                            .background(
                                Capsule()
                                    .foregroundStyle(.bar)
                                    .matchedGeometryEffect(id: "search-bar-background", in: namespace)
                            )
                            .id(selectedFolderFilter.animationId)
                            .onTapGesture {
                                withAnimation(.smooth) {
                                    searchModel.searchIsActive = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        searchBarIsFocusd = true
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "plus")
                                .font(.title3)
                                .foregroundStyle(.accent)
                                .onTapGesture {
                                    newCuppingModalIsActive = true
                                }
                        } else {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                                    .matchedGeometryEffect(id: "search-bar-image", in: namespace)
                                
                                TextField("Search", text: $searchModel.searchValue)
                                    .focused($searchBarIsFocusd)
                                    .matchedGeometryEffect(id: "search-bar-text", in: namespace)
                            }
                            .frame(height: 37)
                            .padding(.horizontal, .regular)
                            .background(
                                Rectangle()
                                    .foregroundStyle(.bar)
                                    .cornerRadius()
                                    .matchedGeometryEffect(id: "search-bar-background", in: namespace)
                            )
                            
                            Button("Cancel") {
                                withAnimation(.smooth) {
                                    searchModel.searchValue = ""
                                    searchBarIsFocusd = false
                                    searchModel.searchIsActive = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal, .regular)
                    .frame(height: 35)

                    MainTabToolbar(allFolderFilters: allFolderFilters, selectedFolderFilter: $selectedFolderFilter)
                }
            }
        }
        .navigationViewStyle(.stack)
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
        let sectionData: SectionData
        let folderFilter: FolderFilter
        
        @State var isExpanded: Bool = true
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text(sectionData.id)
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
                        ForEach(sectionData.cuppings) { CuppingPreview($0) }
                        
                        if !sectionData.samples.isEmpty {
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
                                ForEach(sectionData.samples) {
                                    SamplePreview($0, showCupping: true, animationId: folderFilter.animationId)
                                }
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
    func getSectionsData(folderFilter: FolderFilter, searchValue: String) -> [MainTabView.SectionData] {
        let filteredCuppings: [Cupping] = {
            if let folderCuppings = folderFilter.folder?.cuppings {
                if searchValue != "" {
                    return Array(folderCuppings).filter { $0.name.contains(searchValue) }
                }
                return Array(folderCuppings)
            } else {
                return folderFilter.predicate(Array(cuppings)).compactMap {
                    if let cupping: Cupping = $0 as? Cupping {
                        if searchValue == "" || cupping.name.contains(searchValue) {
                            return cupping
                        }
                    }
                    return nil
                }
            }
        }()
        let filteredSamples: [Sample] = {
            if let folderSamples = folderFilter.folder?.samples {
                if searchValue != "" {
                    return Array(folderSamples).filter { $0.name.contains(searchValue) }
                }
                return Array(folderSamples)
            } else {
                return folderFilter.predicate(Array(samples)).compactMap {
                    if let sample: Sample = $0 as? Sample {
                        if searchValue == "" || sample.name.contains(searchValue) {
                            return sample
                        }
                    }
                    return nil
                }
            }
        }()
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
        
        return sectionsData.sorted(by: { $0.monthAndYear > $1.monthAndYear })
    }
}
