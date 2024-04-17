//
//  Setting Location.swift
//  CupTaster
//
//  Created by Nikita on 16.02.2024.
//

import SwiftUI
import MapKit

struct Settings_LocationView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Location.entity(), sortDescriptors: []) var locations: FetchedResults<Location>
    
    @State var showLocationAuthorizationSheet: Bool = false
    @ObservedObject var locationManager: LocationManager = .shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection(
                    footer: locationManager.attachLocation ?
                    "Maximum distance for grouping cuppings by location." : "Turn on location services to attach location to the conducted cuppings."
                ) {
                    SettingsToggleSection(title: "Attach location", systemImageNames: (on: "location.fill", off: "location.slash"), isOn: Binding(
                        get: { locationManager.authorized && locationManager.attachLocation },
                        set: { value in
                            if locationManager.authorized {
                                locationManager.attachLocation = value
                            } else {
                                if locationManager.authorizationStatus == .notDetermined {
                                    locationManager.requestAuthorization()
                                } else {
                                    showLocationAuthorizationSheet = true
                                }
                            }
                        }
                    ))
                    .adaptiveSizeSheet(isPresented: $showLocationAuthorizationSheet) {
                        VStack(spacing: .large) {
                            Text("Access denied")
                                .font(.title.bold())
                            
                            Image(systemName: "location.slash")
                                .font(.system(size: 100, weight: .light))
                                .frame(maxWidth: .infinity)
                                .foregroundStyle(.gray)
                            
                            Text("Turn on Location Services in settings to allow CupTaster determine your location.")
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.gray)
                            
                            Button {
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    showLocationAuthorizationSheet = false
                                }
                            } label: {
                                Text("Go to settings ") + Text(Image(systemName: "arrow.right"))
                            }
                            .buttonStyle(.primary)
                        }
                        .padding([.horizontal, .bottom], .small)
                    }
                    
                    if locationManager.attachLocation {
                        SettingsPickerSection(title: "Grouping distance", systemImageName: "arrow.left.and.right", selection: $locationManager.unionDistance) {
                            Text("100 m").tag(100.0)
                            Text("500 m").tag(500.0)
                            Text("1000 m").tag(1000.0)
                        }
                    }
                }
                
                if locationManager.attachLocation {
                    SettingsSection("Locations") {
                        let sortedLocations: [Location] = locations.sorted(by: { $0.cuppings.count > $1.cuppings.count } )
                        
                        if sortedLocations.isEmpty {
                            SettingsRow(title: "No locations")
                        }
                        
                        ForEach(sortedLocations) { location in
                            SwipeView {
                                SettingsNavigationSection(title: location.address, trailingBadge: "\(location.cuppings.count)") {
                                    Settings_LocationAdjustmentView(location: location)
                                }
                            } trailingActions: { _ in
                                SwipeAction {
                                    withAnimation {
                                        moc.delete(location)
                                        save(moc)
                                    }
                                } label: { _ in
                                    VStack(spacing: .extraSmall) {
                                        Image(systemName: "trash")
                                        Text("Delete")
                                    }
                                    .font(.subheadline)
                                    .foregroundStyle(.white)
                                } background: { _ in
                                    Color.red
                                }
                            }
                            .defaultSwipeStyle()
                        }
                    }
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .navigationTitle("Location")
        .defaultNavigationBar()
    }
}

struct Settings_LocationAdjustmentView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var location: Location
    @State var mapIsExpanded: Bool = false
    @State var locationPickerIsActive: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsSection {
                    SettingsTextFieldSection(text: $location.address, prompt: "Unknown")
                        .onChange(of: location.address) { _ in
                            save(moc)
                        }
                        .submitLabel(.done)
                }
                
                SettingsSection("Map") {
                    Map (
                        coordinateRegion: .constant(
                            MKCoordinateRegion(
                                center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                            )
                        ),
                        annotationItems: [location],
                        annotationContent: { MapMarker(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude)) }
                    )
                    .frame(height: 200)
                    .cornerRadius()
                    .allowsHitTesting(false)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        mapIsExpanded = true
                    }
                    .fullScreenCover(isPresented: $mapIsExpanded) {
                        MapModalView(location: location) { newLocation, coordinates, address in
                            if let newLocation {
                                location.reinit(newLocation)
                            } else {
                                (location.latitude, location.longitude) = (coordinates.latitude, coordinates.longitude)
                                location.address = address
                            }
                            save(moc)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                    
                    SettingsButtonSection(title: "Specify") {
                        locationPickerIsActive = true
                    }
                    .fullScreenCover(isPresented: $locationPickerIsActive) {
                        MapModalView(location: location, specifyingLocation: true) { newLocation, coordinates, address in
                            if let newLocation {
                                location.reinit(newLocation)
                            } else {
                                (location.latitude, location.longitude) = (coordinates.latitude, coordinates.longitude)
                                location.address = address
                            }
                            save(moc)
                        }
                        .edgesIgnoringSafeArea(.all)
                    }
                }
                
                SettingsSection("Cuppings: \(location.cuppings.count)") {
                    ForEach(Array(location.cuppings)) { cupping in
                        CuppingPreview(cupping)
                    }
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary, ignoresSafeAreaEdges: .all)
        .defaultNavigationBar()
    }
}
