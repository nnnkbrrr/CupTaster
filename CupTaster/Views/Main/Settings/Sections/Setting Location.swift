//
//  Setting Location.swift
//  CupTaster
//
//  Created by Nikita on 16.02.2024.
//

import SwiftUI
import UIKit
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
    @State var locationPickerIsActive: Bool = false
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .extraSmall) {
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
                
                SettingsButtonSection(title: "Specify") {
                    locationPickerIsActive = true
                }
                .fullScreenCover(isPresented: $locationPickerIsActive) {
                    LocationPickerView(location: location) { coordinates, address in
                        (location.latitude, location.longitude) = (coordinates.coordinate.latitude, coordinates.coordinate.longitude)
                        location.address = address
                    }
                    .edgesIgnoringSafeArea(.all)
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

// MARK: Location Picker

public typealias successClosure = (_ coordinates: CLLocation, _ address: String) -> Void
public typealias failureClosure = (NSError) -> Void

struct LocationPickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController
    
    let location: Location
    var success: successClosure
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = LocationPickerController(location: location) { coordinates, address in
            success(coordinates, address)
        }
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

enum UIBarButtonHiddenItem: Int {
    case locate = 100
    func convert() -> UIBarButtonItem.SystemItem {
        return UIBarButtonItem.SystemItem(rawValue: self.rawValue)!
    }
}

extension UIBarButtonItem {
    convenience init(barButtonHiddenItem item:UIBarButtonHiddenItem, target: AnyObject?, action: Selector) {
        self.init(barButtonSystemItem: item.convert(), target:target, action: action)
    }
}

open class LocationPickerController: UIViewController {
    var locationData: (coordinates: CLLocation, address: String)
    fileprivate var location: Location
    
    fileprivate var mapView: MKMapView!
    fileprivate var mapPinImage: UIImageView!
    fileprivate var userTrackingButton: UIBarButtonItem!
    
    fileprivate let locationManager: CLLocationManager = CLLocationManager()
    
    fileprivate var success: successClosure?
    fileprivate var failure: failureClosure?
    
    init(location: Location) {
        self.location = location
        self.locationData = (coordinates: location.coordinates, address: location.address)
        
        self.mapPinImage = UIImageView(image: UIImage(
            systemName: "mappin",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        ))
        mapPinImage.tintColor = .white
        mapPinImage.backgroundColor  = .accent
        mapPinImage.contentMode = .center
        mapPinImage.layer.cornerRadius = 25
        
        mapPinImage.layer.masksToBounds = false
        mapPinImage.layer.shadowColor = UIColor.black.cgColor
        mapPinImage.layer.shadowOpacity = 0.25
        mapPinImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        mapPinImage.layer.shadowRadius = 10
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(location: Location, success: @escaping successClosure, failure: failureClosure? = nil) {
        self.init(location: location)
        self.success = success
        self.failure = failure
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func loadView() {
        super.loadView()
        
        self.mapView = MKMapView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let centerCoordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: false)
        self.view.addSubview(self.mapView)
        
        // overlay
        
        let circleView = UIView()
        circleView.backgroundColor = .accent
        circleView.layer.cornerRadius = 3
        circleView.layer.masksToBounds = false
        circleView.layer.shadowColor = UIColor.black.cgColor
        circleView.layer.shadowOpacity = 0.5
        circleView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circleView.layer.shadowRadius = 5
        
        mapPinImage.translatesAutoresizingMaskIntoConstraints = false
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        self.mapView.addSubview(mapPinImage)
        self.mapView.addSubview(circleView)
        
        NSLayoutConstraint.activate([
            mapPinImage.widthAnchor.constraint(equalToConstant: 50),
            mapPinImage.heightAnchor.constraint(equalToConstant: 50),
            circleView.widthAnchor.constraint(equalToConstant: 6),
            circleView.heightAnchor.constraint(equalToConstant: 6),
            
            mapPinImage.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            mapPinImage.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor, constant: 15),
            circleView.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor, constant: 50)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.mapView.setRegion(region, animated: false)
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        let cancelButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(LocationPickerController.didTapCancelButton)
        )
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        
        let doneButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(LocationPickerController.didTapDoneButton)
        )
        self.navigationItem.rightBarButtonItem = doneButtonItem
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        self.userTrackingButton = MKUserTrackingBarButtonItem(mapView: self.mapView)
        self.navigationItem.titleView = self.userTrackingButton.customView
        
        self.setPrompt("Locating...")
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

internal extension LocationPickerController {
    @objc func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDoneButton() {
        guard CLLocationCoordinate2DIsValid(self.mapView.centerCoordinate) else {
            self.failure?(NSError(
                domain: "LocationPickerControllerErrorDomain",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Invalid coordinate"]
            ))
            return
        }
        
        self.success?(self.locationData.coordinates, self.locationData.address)
        
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationPickerController: MKMapViewDelegate {
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        self.setPrompt("Locating...")
        UIView.animate(withDuration: 0.25) {
            self.mapPinImage.center.y = mapView.center.y - 25
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Task {
            let coordinates: CLLocation = .init(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            let address: String? = try? await AddressDecoder.getShortAddress(for: coordinates)
            self.locationData = (coordinates: coordinates, address: address ?? "Error")
            self.setPrompt(self.locationData.address)
        }
        
        UIView.animate(withDuration: 0.25) {
            self.mapPinImage.center.y = mapView.center.y + 15
        }
    }
}

extension LocationPickerController: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined: locationManager.requestWhenInUseAuthorization()
            default: break
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationManager.stopUpdatingLocation()
    }
    
    private func setPrompt(_ prompt: String) {
        self.navigationItem.prompt = prompt
        
        for view in self.navigationController?.navigationBar.subviews ?? [] {
            let subviews = view.subviews
            if subviews.count > 0, let label = subviews[0] as? UILabel {
                label.font = .systemFont(ofSize: 17)
            }
        }
    }
}
