//
//  New Cupping Modal.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI
import MapKit
import CoreLocation
import CoreData

class NewCupping: ObservableObject {
    @Published var name: String = ""
    @Published var cupsCount: Int = 5
    @Published var date: Date = Date()
    @Published var samplesCount: Int = 10
    @Published var folderFilters: [FolderFilter] = []
    @Published var location: Location?
    @Published var address: String = "Location is unavailable"
    @Published var horizontalAccuracy: Double?
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    init() { }
    
    func create(cuppingForm: CuppingForm, context moc: NSManagedObjectContext) {
        let cupping: Cupping = .init(context: moc)
        cupping.name = name
        cupping.setup(
            moc: moc,
            date: date,
            cuppingForm: cuppingForm,
            cupsCount: cupsCount,
            samplesCount: samplesCount
        )
        
        if let location {
            cupping.location = location
        } else if let latitude, let longitude {
            let location: Location = .init(context: moc)
            location.address = address
            location.latitude = latitude
            location.longitude = longitude
            if let horizontalAccuracy { location.horizontalAccuracy = horizontalAccuracy }
            cupping.location = location
        }
        
        for folderFilter in folderFilters {
            folderFilter.addCupping(cupping, context: moc)
        }
        
        save(moc)
    }
}

struct NewCuppingModalView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @FetchRequest(
        entity: Folder.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Folder.ordinalNumber, ascending: true)]
    ) var folders: FetchedResults<Folder>
    @FetchRequest(entity: Location.entity(), sortDescriptors: []) var locations: FetchedResults<Location>
    
    @StateObject var cfManager = CFManager.shared
    @ObservedObject var locationManager: LocationManager = .shared
    
    @Binding var isPresented: Bool
    @State var mapIsExpanded = false
    @State var cuppingFormPickerIsActive: Bool = false
    @State var foldersModalIsActive = false
    @State var loadingAddress: Bool = true
    
    private let nameLengthLimit = 50
    
    @ObservedObject var newCupping: NewCupping = .init()
    
    var body: some View {
        VStack(spacing: .extraSmall) {
            if TestingManager.shared.cuppingDatePickerIsVisible {
                DatePicker("", selection: $newCupping.date, displayedComponents: [.date])
            }
            
            TextField("Cupping Name", text: $newCupping.name)
                .resizableText(weight: .light)
                .submitLabel(.done)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, .regular)
                .onChange(of: newCupping.name) { name in
                    if name.count > nameLengthLimit {
                        newCupping.name = String(name.prefix(nameLengthLimit))
                    }
                }
                .bottomSheetBlock()
            
            HStack(spacing: .extraSmall) {
                VStack(spacing: .small) {
                    Text("Cups")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    TargetHorizontalScrollView(
                        1...5, selection: $newCupping.cupsCount,
                        elementWidth: .smallElement, height: 18, spacing: .extraSmall
                    ) { cupsNum in
                        Text("\(cupsNum)")
                            .foregroundStyle(cupsNum == newCupping.cupsCount ? Color.primary : .gray)
                            .frame(width: .smallElement)
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black, .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .bottomSheetBlock()
                
                VStack(spacing: .small) {
                    Text("Samples")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    TargetHorizontalScrollView(
                        1...20, selection: $newCupping.samplesCount,
                        elementWidth: .smallElement, height: 18, spacing: .extraSmall
                    ) { samplesNum in
                        Text("\(samplesNum)")
                            .foregroundStyle(samplesNum == newCupping.samplesCount ? Color.primary : .gray)
                            .frame(width: .smallElement)
                    }
                    .mask(
                        LinearGradient(
                            gradient: Gradient(colors: [.clear, .black, .clear]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .bottomSheetBlock()
            }
            
            HStack(spacing: .regular) {
                ZStack {
                    if let location = newCupping.location {
                        Map (
                            coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            ),
                            annotationItems: [CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)],
                            annotationContent: { MapMarker(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude)) }
                        )
                        .frame(width: .smallElement * 2, height: .smallElement * 2)
                        .scaleEffect(0.5)
                        .fullScreenCover(isPresented: $mapIsExpanded) {
                            MapModalView (
                                location: location,
                                specifyingLocation: true
                            ) { newLocation, coordinates, address in
                                if let newLocation {
                                    newCupping.location = newLocation
                                } else {
                                    newCupping.location = nil
                                    (newCupping.latitude, newCupping.longitude) = (coordinates.latitude, coordinates.longitude)
                                    newCupping.address = address
                                }
                                save(moc)
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    } else if let latitude = newCupping.latitude, let longitude = newCupping.longitude {
                        Map (
                            coordinateRegion: .constant(
                                MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                )
                            ),
                            annotationItems: [CLLocationCoordinate2D(latitude: latitude, longitude: longitude)],
                            annotationContent: { MapMarker(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude)) }
                        )
                        .frame(width: .smallElement * 2, height: .smallElement * 2)
                        .scaleEffect(0.5)
                        .fullScreenCover(isPresented: $mapIsExpanded) {
                            MapModalView (
                                coordinates: .init(latitude: latitude, longitude: longitude),
                                address: newCupping.address,
                                specifyingLocation: true
                            ) { newLocation, coordinates, address in
                                if let newLocation {
                                    newCupping.location = newLocation
                                } else {
                                    newCupping.location = nil
                                    (newCupping.latitude, newCupping.longitude) = (coordinates.latitude, coordinates.longitude)
                                    newCupping.address = address
                                }
                                save(moc)
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    } else {
                        Image(systemName: "mappin.slash")
                    }
                }
                .frame(width: .smallElement, height: .smallElement)
                .cornerRadius(.small)
                .overlay {
                    RoundedRectangle(cornerRadius: .small)
                        .stroke(Color.separatorPrimary, lineWidth: 2)
                }
                .allowsHitTesting(false)
                
                VStack(alignment: .leading) {
                    Text(newCupping.address)
                        .lineLimit(1)
                    
                    if newCupping.location != nil || (newCupping.latitude != nil && newCupping.longitude != nil) {
                        Text("\(Image(systemName: "mappin.and.ellipse")) Specify")
                            .foregroundStyle(Color.accentColor)
                            .font(.caption)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.small)
            .bottomSheetBlock()
            .contentShape(Rectangle())
            .onTapGesture {
                if newCupping.location != nil || (newCupping.latitude != nil && newCupping.longitude != nil) {
                    mapIsExpanded = true
                }
            }
            
            HStack(spacing: .extraSmall) {
                Button {
                    cuppingFormPickerIsActive = true
                } label: {
                    HStack(spacing: .extraSmall) {
                        Image(systemName: "doc.plaintext")
                        let defaultCuppingFormTitle: String? = cfManager.getDefaultCuppingForm(from: cuppingForms)?.title
                        Text(defaultCuppingFormTitle ?? "Cupping Form")
                            .foregroundStyle(defaultCuppingFormTitle == nil ? .red : .primary)
                    }
                }
                .buttonStyle(.bottomSheetBlock)
                
                Button {
                    foldersModalIsActive = true
                } label: {
                    HStack(spacing: .extraSmall) {
                        Image(systemName: "folder")
                        let foldersCount: Int = newCupping.folderFilters.count
                        Text("Folders \(foldersCount == 0 ? "" : "(\(foldersCount))")")
                    }
                }
                .buttonStyle(.bottomSheetBlock)
            }
            
            HStack(spacing: .extraSmall) {
                Button {
                    if let defaultCuppingForm: CuppingForm = cfManager.getDefaultCuppingForm(from: cuppingForms) {
                        newCupping.create(cuppingForm: defaultCuppingForm, context: moc)
                        isPresented = false
                    } else {
                        cuppingFormPickerIsActive = true
                    }
                } label: {
                    HStack(spacing: .small) {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(.accentBottomSheetBlock)
            }
        }
        .modalView(
            isPresented: $cuppingFormPickerIsActive,
            toolbar: .init(
                title: "Default Cupping Form",
                trailingToolbarItem: .init("Done") {
                    cuppingFormPickerIsActive = false
                    cfManager.objectWillChange.send()
                }
            )
        ) {
            Settings_CuppingFormsView(showNavigationBar: false)
        }
        .modalView(
            isPresented: $foldersModalIsActive,
            toolbar: .init(
                title: "Folders",
                trailingToolbarItem: .init("Done") {
                    foldersModalIsActive = false
                }
            )
        ) {
            ScrollView {
                LazyVStack(spacing: .extraSmall) {
                    ForEach([FolderFilter.favorites] + folders.map { FolderFilter(folder: $0) }) { folderFilter in
                        let folderFilterIsSelected: Bool = newCupping.folderFilters.contains(folderFilter)
                        
                        SettingsButtonSection(title: folderFilter.name ?? folderFilter.folder?.name ?? "New Folder") {
                            if folderFilterIsSelected { newCupping.folderFilters.removeAll(where: { $0 == folderFilter }) }
                            else { newCupping.folderFilters.append(folderFilter) }
                        } leadingContent: {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color.accentColor)
                                .opacity(folderFilterIsSelected ? 1 : 0)
                        }
                    }
                }
            }
            .padding(.horizontal, .small)
        }
        .padding([.horizontal, .bottom], .small)
        .onAppear {
            Task {
                if locationManager.attachLocation {
                    if let locationData = await locationManager.getLocationData() {
                        let coordinates: CLLocation = .init(latitude: locationData.latitude, longitude: locationData.longitude)
                        
                        var minDistance: Double = Double.greatestFiniteMagnitude
                        for location in locations {
                            let distance: Double = coordinates.distance(from: location.coordinates)
                            if distance < locationManager.unionDistance && distance < minDistance {
                                minDistance = distance
                                newCupping.location = location
                                newCupping.address = location.address
                            }
                        }
                        
                        if newCupping.location == nil {(
                            newCupping.address,
                            newCupping.horizontalAccuracy,
                            newCupping.latitude,
                            newCupping.longitude
                        ) = locationData }
                    }
                }
                
                withAnimation {
                    loadingAddress = false
                }
            }
        }
    }
}
