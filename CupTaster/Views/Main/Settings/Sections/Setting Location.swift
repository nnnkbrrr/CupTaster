//
//  Setting Location.swift
//  CupTaster
//
//  Created by Nikita on 16.02.2024.
//

import SwiftUI
import MapKit
import SwipeActions

struct Settings_LocationView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Location.entity(), sortDescriptors: []) var locations: FetchedResults<Location>
    
    @State var showLocationAuthorizationSheet: Bool = false
    @ObservedObject var locationManager: LocationManager = .shared
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
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
                            
                            locationManager.attachLocation = value
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
                    
                    SettingsFooter("Maximum distance for grouping cuppings by location.")
                    
                    SettingsHeader("Locations")
                    
                    let sortedLocations: [Location] = locations.sorted(by: { $0.cuppings.count > $1.cuppings.count } )
                    if sortedLocations.isEmpty {
                        SettingsSection(title: "Empty")
                    }
                    
                    ForEach(sortedLocations) { location in
                        SwipeView {
                            SettingsNavigationSection(title: location.address, leadingBadge: "\(location.cuppings.count)") {
                                Settings_LocationAdjustmentView(location: location)
                            }
                        } trailingActions: { _ in
                            SwipeAction {
                                withAnimation {
                                    moc.delete(location)
                                    try? moc.save()
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
                        .cornerRadius()
                        .background(Color.backgroundSecondary)
                        .cornerRadius()
                    }
                } else {
                    SettingsFooter("Turn on location services to attach location to the conducted cuppings.")
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
        .navigationTitle("Location")
        .defaultNavigationBar()
    }
}

struct Settings_LocationAdjustmentView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var location: Location
    @State var mapIsExpanded: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
                SettingsHeader("Address")
                
                SettingsTextFieldSection(text: $location.address, prompt: "Unknown")
                    .onChange(of: location.address) { _ in
                        try? moc.save()
                    }
                    .submitLabel(.done)
                
                SettingsHeader("Map")
                
                Map (
                    coordinateRegion: .constant(
                        MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                        )
                    ),
                    annotationItems: [location],
                    annotationContent: {
                        MapMarker(coordinate: .init(latitude: $0.latitude, longitude: $0.longitude))
                    }
                )
                .frame(height: 200)
                .cornerRadius()
                .allowsHitTesting(false)
                .contentShape(Rectangle())
                .onTapGesture {
                    mapIsExpanded = true
                }
                .fullScreenCover(isPresented: $mapIsExpanded) {
                    MapModalView(location: location)
                }
                
                SettingsHeader("Cuppings: \(location.cuppings.count)")
                
                ForEach(Array(location.cuppings)) { cupping in
                    CuppingPreview(cupping)
                }
            }
            .padding(.small)
        }
        .background(Color.backgroundPrimary)
        .defaultNavigationBar()
        .fullScreenCover(isPresented: $mapIsExpanded) {
            MapModalView(location: location)
        }
    }
}

struct MapModalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var location: Location
    @State var region: MKCoordinateRegion
    
    init(location: Location) {
        self.location = location
        self._region = State(initialValue: .init(
            center: .init(latitude: location.latitude, longitude: location.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Map (
                coordinateRegion: $region,
                showsUserLocation: true,
                annotationItems: [location],
                annotationContent: {
                    MapMarker(
                        coordinate: .init(latitude: $0.latitude, longitude: $0.longitude),
                        tint: .red
                    )
                }
            )
            .edgesIgnoringSafeArea(.all)
            
            HStack {
                Text(location.address)
                    .font(.title2)
                
                Spacer()
                
                Image(systemName: "xmark")
                    .font(.subheadline.bold())
                    .frame(width: 40, height: 40)
                    .background(Color.gray.opacity(0.2))
                    .background(.bar)
                    .clipShape(Circle())
                    .onTapGesture { dismiss() }
            }
            .padding(.horizontal, .small)
            .padding(.top, .large)
            .background(
                LinearGradient(
                    colors: [.backgroundPrimary.opacity(0.5), .backgroundPrimary.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                ignoresSafeAreaEdges: .top
            )
        }
    }
}
