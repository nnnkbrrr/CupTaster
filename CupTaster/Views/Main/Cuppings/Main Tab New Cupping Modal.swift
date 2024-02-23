//
//  New Cupping Modal.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI
import MapKit
import CoreLocation

struct NewCuppingModalView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(
        entity: CuppingForm.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \CuppingForm.title, ascending: false)]
    ) var cuppingForms: FetchedResults<CuppingForm>
    @FetchRequest(entity: Location.entity(), sortDescriptors: []) var locations: FetchedResults<Location>
    
    @ObservedObject var locationManager: LocationManager = .shared
    
    @Binding var isPresented: Bool
    @State var mapIsExpanded = false
    
    private let nameLengthLimit = 50
    @State var name: String = ""
    @State var cupsCount: Int = 5
    @State var samplesCount: Int = 10
    
    @State var location: Location?
    @State var loadingAddress: Bool = true
    @State var address: String = "Location is unavailable"
    @State var horizontalAccuracy: Double?
    @State var latitude: Double?
    @State var longitude: Double?
    
    var body: some View {
        VStack(spacing: .extraSmall) {
            TextField("Cupping Name", text: $name)
                .resizableText(weight: .light)
                .submitLabel(.done)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, .regular)
                .onChange(of: name) { name in
                    if name.count > nameLengthLimit {
                        self.name = String(name.prefix(nameLengthLimit))
                    }
                }
                .bottomSheetBlock()
            
            HStack(spacing: .extraSmall) {
                VStack(spacing: .small) {
                    Text("Cups")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                    
                    TargetHorizontalScrollView(
                        1...5, selection: $cupsCount,
                        elementWidth: .smallElement, height: 18, spacing: .extraSmall
                    ) { cupsNum in
                        Text("\(cupsNum)")
                            .foregroundStyle(cupsNum == cupsCount ? Color.primary : .gray)
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
                        1...20, selection: $samplesCount,
                        elementWidth: .smallElement, height: 18, spacing: .extraSmall
                    ) { samplesNum in
                        Text("\(samplesNum)")
                            .foregroundStyle(samplesNum == samplesCount ? Color.primary : .gray)
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
                    if let location {
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
                                    self.location = newLocation
                                } else {
                                    self.location = nil
                                    (self.latitude, self.longitude) = (coordinates.latitude, coordinates.longitude)
                                    self.address = address
                                }
                                try? moc.save()
                            }
                            .edgesIgnoringSafeArea(.all)
                        }
                    } else if let latitude, let longitude {
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
                                address: address,
                                specifyingLocation: true
                            ) { newLocation, coordinates, address in
                                if let newLocation {
                                    self.location = newLocation
                                } else {
                                    self.location = nil
                                    (self.latitude, self.longitude) = (coordinates.latitude, coordinates.longitude)
                                    self.address = address
                                }
                                try? moc.save()
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
                    Text(address)
                        .lineLimit(1)
                    
                    if location != nil || (latitude != nil && longitude != nil) {
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
                if location != nil || (latitude != nil && longitude != nil) {
                    mapIsExpanded = true
                }
            }
            
            HStack(spacing: .extraSmall) {
                Button {
#warning("action")
                } label: {
                    HStack(spacing: .extraSmall) {
                        Image(systemName: "doc.plaintext")
                        Text(CFManager.shared.getDefaultCuppingForm(from: cuppingForms)?.title ?? "Cupping Form")
#warning("CF not selected")
                    }
                }
                .buttonStyle(.bottomSheetBlock)
                
                Button {
#warning("action")
                } label: {
                    HStack(spacing: .extraSmall) {
                        Image(systemName: "folder")
                        Text("Folders")
                    }
                }
                .buttonStyle(.bottomSheetBlock)
            }
            
            HStack(spacing: .extraSmall) {
                Button {
                    if let defaultCuppingForm: CuppingForm = CFManager.shared.getDefaultCuppingForm(from: cuppingForms) {
                        let cupping: Cupping = .init(context: moc)
                        cupping.name = name
                        cupping.setup(
                            moc: moc,
                            date: Date(),
                            cuppingForm: defaultCuppingForm,
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
                        
                        try? moc.save()
                    } else {
                        #warning("не выбрана форма по умолчанию")
                    }
                    
                    isPresented = false
                } label: {
                    HStack(spacing: .small) {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(.accentBottomSheetBlock)
            }
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
                                self.location = location
                                self.address = location.address
                            }
                        }
                        
                        if self.location == nil {
                            (self.address, self.horizontalAccuracy, self.latitude, self.longitude) = locationData
                        }
                    }
                }
                withAnimation {
                    loadingAddress = false
                }
            }
        }
    }
}
