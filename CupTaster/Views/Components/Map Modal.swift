//
//  Map Modal.swift
//  CupTaster
//
//  Created by Nikita on 20.02.2024.
//

import SwiftUI
import UIKit
import MapKit

extension CLLocationCoordinate2D: @retroactive Identifiable, @retroactive Equatable {
    public typealias ID = String
    public var id: String { "\(self.latitude).\(self.longitude)" }
    
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool { lhs.id == rhs.id }
}

public typealias SuccessClosure = (_ location: Location?, _ coordinates: CLLocationCoordinate2D, _ address: String) -> Void
public typealias FailureClosure = (NSError) -> Void

struct MapModalView: UIViewControllerRepresentable {
    @FetchRequest(entity: Location.entity(), sortDescriptors: []) var locations: FetchedResults<Location>
    typealias UIViewControllerType = UIViewController
    
    let coordinates: CLLocationCoordinate2D
    let location: Location?
    let address: String
    let specifyingLocation: Bool
    var success: SuccessClosure
    
    init(location: Location, specifyingLocation: Bool = false, success: @escaping SuccessClosure) {
        self.location = location
        self.coordinates = .init(latitude: location.latitude, longitude: location.longitude)
        self.address = location.address
        self.specifyingLocation = specifyingLocation
        self.success = success
    }
    
    init(coordinates: CLLocationCoordinate2D, address: String, specifyingLocation: Bool = false, success: @escaping SuccessClosure) {
        self.location = nil
        self.coordinates = coordinates
        self.address = address
        self.specifyingLocation = specifyingLocation
        self.success = success
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        let viewController = LocationPickerController(
            location: location,
            coordinates: coordinates,
            address: address,
            locations: Array(locations),
            specifyingLocation: specifyingLocation
        ) { location, coordinates, address in
            success(location, coordinates, address)
        }
        return UINavigationController(rootViewController: viewController)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}

enum UIBarButtonHiddenItem: Int {
    case locate = 100
    func convert() -> UIBarButtonItem.SystemItem {
        return UIBarButtonItem.SystemItem(rawValue: self.rawValue)!
    }
}

extension UIBarButtonItem {
    convenience init(barButtonHiddenItem item:UIBarButtonHiddenItem, target: AnyObject?, action: Selector) {
        self.init(barButtonSystemItem: item.convert(), target: target, action: action)
    }
}

class LocationPickerController: UIViewController {
    var location: Location?
    var address: String
    var coordinates: CLLocationCoordinate2D
    var tempCoordinates: CLLocationCoordinate2D
    var tempAnnotation: MKPointAnnotation?
    
    let locations: [Location]
    private let locationManager: CLLocationManager = .init()
    
    private var mapView: MKMapView!
    private var mapSpecifyingPinImage: UIImageView!
    private var mapSpecifyingPoint: UIView!
    private var userTrackingButton: UIBarButtonItem!
    
    private var success: SuccessClosure?
    private var failure: FailureClosure?
    
    private var specifyingLocation: Bool
    
    init(location: Location?, coordinates: CLLocationCoordinate2D, address: String, locations: [Location], specifyingLocation: Bool = false) {
        self.location = location
        self.coordinates = coordinates
        self.tempCoordinates = coordinates
        self.address = address
        self.locations = locations
        self.specifyingLocation = specifyingLocation
        
        self.mapSpecifyingPinImage = UIImageView(image: UIImage(
            systemName: "mappin",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 30, weight: .light)
        ))
        mapSpecifyingPinImage.tintColor = .white
        mapSpecifyingPinImage.backgroundColor  = .accent
        mapSpecifyingPinImage.contentMode = .center
        mapSpecifyingPinImage.layer.cornerRadius = 25
        mapSpecifyingPinImage.layer.masksToBounds = false
        mapSpecifyingPinImage.layer.shadowColor = UIColor.black.cgColor
        mapSpecifyingPinImage.layer.shadowOpacity = 0.25
        mapSpecifyingPinImage.layer.shadowOffset = CGSize(width: 0, height: 2)
        mapSpecifyingPinImage.layer.shadowRadius = 10
        mapSpecifyingPinImage.translatesAutoresizingMaskIntoConstraints = false
        
        self.mapSpecifyingPoint = UIView()
        mapSpecifyingPoint.backgroundColor = .accent
        mapSpecifyingPoint.layer.cornerRadius = 3
        mapSpecifyingPoint.layer.masksToBounds = false
        mapSpecifyingPoint.layer.shadowColor = UIColor.black.cgColor
        mapSpecifyingPoint.layer.shadowOpacity = 0.5
        mapSpecifyingPoint.layer.shadowOffset = CGSize(width: 0, height: 2)
        mapSpecifyingPoint.layer.shadowRadius = 5
        mapSpecifyingPoint.translatesAutoresizingMaskIntoConstraints = false
        
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(
        location: Location?,
        coordinates: CLLocationCoordinate2D,
        address: String,
        locations: [Location],
        specifyingLocation: Bool = false,
        success: @escaping SuccessClosure,
        failure: FailureClosure? = nil
    ) {
        self.init(location: location, coordinates: coordinates, address: address, locations: locations, specifyingLocation: specifyingLocation)
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
        
        self.view.addSubview(self.mapView)
        
        self.mapView.addAnnotations(locations.map {
            let annotation = MKPointAnnotation()
            annotation.title = $0.address
            annotation.coordinate = .init(latitude: $0.latitude, longitude: $0.longitude)
            return annotation
        })
        
        self.mapView.addSubview(mapSpecifyingPinImage)
        self.mapView.addSubview(mapSpecifyingPoint)
        
        NSLayoutConstraint.activate([
            mapSpecifyingPinImage.widthAnchor.constraint(equalToConstant: 50),
            mapSpecifyingPinImage.heightAnchor.constraint(equalToConstant: 50),
            mapSpecifyingPoint.widthAnchor.constraint(equalToConstant: 6),
            mapSpecifyingPoint.heightAnchor.constraint(equalToConstant: 6),
            
            mapSpecifyingPinImage.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            mapSpecifyingPinImage.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor, constant: 5),
            mapSpecifyingPoint.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
            mapSpecifyingPoint.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor, constant: 40)
        ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            for view in self.navigationController?.navigationBar.subviews ?? [] {
                let subviews = view.subviews
                if subviews.count > 0, let label = subviews[0] as? UILabel {
                    label.font = .systemFont(ofSize: 17)
                }
            }
            
            if self.specifyingLocation { self.startSpecifyingLocation() }
            else { self.stopSpecifyingLocation() }
        }
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearance = UINavigationBarAppearance()
        
        self.navigationController?.navigationBar.tintColor = .label
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.compactAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
        
        self.userTrackingButton = MKUserTrackingBarButtonItem(mapView: self.mapView)
        self.navigationItem.titleView = self.userTrackingButton.customView
        
        self.setPrompt(location?.address ?? address)
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension LocationPickerController {
    @objc func startSpecifyingLocation() {
        let centerCoordinate = tempCoordinates
        let span = MKCoordinateSpan.init(latitudeDelta: 0.005, longitudeDelta: 0.005)
        let region = MKCoordinateRegion(center: centerCoordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        
        self.specifyingLocation = true
        mapSpecifyingPinImage.layer.opacity = 1
        mapSpecifyingPoint.layer.opacity = 1
        
        if let tempAnnotation {
            mapView.removeAnnotation(tempAnnotation)
        }
        
        let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(LocationPickerController.stopSpecifyingLocation))
        let saveButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action:  #selector(LocationPickerController.saveLocation))
        
        self.navigationItem.leftBarButtonItem = cancelButtonItem
        self.navigationItem.rightBarButtonItem = saveButtonItem
    }
    
    @objc func stopSpecifyingLocation() {
        Task {
            let location: Location? = {
                if let location = self.location { return location }
                else if let location = locations.first(where:  { $0.coordinates.coordinate == coordinates }) { return location }
                else { return nil }
            }()
            
            if let location {
                self.address = location.address
                let centerCoordinate = location.coordinates.coordinate
                let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
                let region = MKCoordinateRegion(center: centerCoordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.view.addSubview(self.mapView)
                self.setPrompt(address)
                self.tempCoordinates = centerCoordinate
            } else {
                let address: String = (try? await AddressDecoder.getShortAddress(for: coordinates)) ?? "Error"
                self.address = address
                let centerCoordinate = coordinates
                let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
                let region = MKCoordinateRegion(center: centerCoordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.view.addSubview(self.mapView)
                self.setPrompt(address)
                self.tempCoordinates = centerCoordinate
            }
            
            self.specifyingLocation = false
            mapSpecifyingPinImage.layer.opacity = 0
            mapSpecifyingPoint.layer.opacity = 0
            
            if location == nil {
                let annotation = MKPointAnnotation()
                annotation.title = address
                annotation.coordinate = coordinates
                
                self.tempAnnotation = annotation
                mapView.addAnnotation(annotation)
            }
            
            let specifyButtonItem = UIBarButtonItem(title: "Specify", style: .plain, target: self, action: #selector(LocationPickerController.startSpecifyingLocation))
            let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(LocationPickerController.done))
            
            self.navigationItem.leftBarButtonItem = specifyButtonItem
            self.navigationItem.rightBarButtonItem = doneButtonItem
        }
    }
    
    @objc func saveLocation() {
        UIView.animate(withDuration: 0.3) {
            self.mapSpecifyingPinImage.center.y = self.mapView.center.y + 5
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard CLLocationCoordinate2DIsValid(self.mapView.centerCoordinate) else {
                self.failure?(NSError(
                    domain: "LocationPickerControllerErrorDomain",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid coordinate"]
                ))
                return
            }
            
            self.coordinates = self.tempCoordinates
            self.success?(self.location, self.tempCoordinates, self.address)
            self.stopSpecifyingLocation()
        }
    }
    
    @objc func done() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension LocationPickerController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !animated {
            if self.specifyingLocation {
                self.setPrompt()
                
                UIView.animate(withDuration: 0.25) {
                    self.mapSpecifyingPinImage.center.y = mapView.center.y - 25
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        if !animated && self.specifyingLocation {
            if location != nil {
                self.location = nil
                self.setPrompt()
                
                mapSpecifyingPinImage.layer.opacity = 1
                mapSpecifyingPoint.layer.opacity = 1
            }
            
            Task {
                let coordinates: CLLocationCoordinate2D = mapView.centerCoordinate
                let address: String = (try? await AddressDecoder.getShortAddress(for: coordinates)) ?? "Error"
                self.tempCoordinates = coordinates
                self.address = address
                self.setPrompt(address)
            }
            
            UIView.animate(withDuration: 0.25) {
                self.mapSpecifyingPinImage.center.y = mapView.center.y + 5
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        annotationView.glyphTintColor = .white
        annotationView.markerTintColor = UIColor(Color.accentColor)
        annotationView.animatesWhenAdded = true
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if self.specifyingLocation, let centerCoordinate = view.annotation?.coordinate {
            let span = MKCoordinateSpan.init(latitudeDelta: 0.0025, longitudeDelta: 0.0025)
            let region = MKCoordinateRegion(center: centerCoordinate, span: span)
            self.mapView.setRegion(region, animated: true)
            self.location = locations.first(where: {
                $0.coordinates.coordinate == centerCoordinate
            })
            self.setPrompt(self.location?.address ?? "Error")
            
            mapSpecifyingPinImage.layer.opacity = 0
            mapSpecifyingPoint.layer.opacity = 0
        }
    }
}

extension LocationPickerController: CLLocationManagerDelegate {
    nonisolated public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
            case .notDetermined: manager.requestWhenInUseAuthorization()
            default: break
        }
    }
    
    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
    }
    
    private func setPrompt(_ prompt: String? = nil) {
        self.navigationItem.prompt = prompt ?? "Locating..."
        
        for view in self.navigationController?.navigationBar.subviews ?? [] {
            let subviews = view.subviews
            if subviews.count > 0, let label = subviews[0] as? UILabel {
                label.font = .systemFont(ofSize: 17)
            }
        }
    }
}
