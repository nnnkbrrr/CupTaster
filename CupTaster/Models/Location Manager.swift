//
//  Location Manager.swift
//  CupTaster
//
//  Created by Nikita on 15.02.2024.
//

import SwiftUI
import CoreLocation
import Contacts

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @PublishedAppStorage("attach-location") var attachLocation: Bool = false
    
    var authorized: Bool {
        return switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied: false
            case .authorizedAlways, .authorizedWhenInUse, .authorized: true
            @unknown default: false
        }
    }
    private let locationManager = CLLocationManager()
    static let shared: LocationManager = .init()
    
    override private init () {
        super.init()
        locationManager.delegate = self
    }
    
    public func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    func getLocationData() async -> (address: String, horizontalAccuracy: Double, latitude: Double, longitude: Double)? {
        guard let location: CLLocation = locationManager.location else { return nil }
        guard let address: String = try? await AddressDecoder.getShortAddress(for: location) else { return nil }
        return (
            address: address,
            horizontalAccuracy: location.horizontalAccuracy,
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude
        )
    }
    
    func getLocationAddress() async -> String? {
        guard let location = locationManager.location else { return nil }
        return try? await AddressDecoder.getShortAddress(for: location)
    }
}

enum AddressDecoder {
    enum AddressError: Error {
        case noAddressFound
    }
    
    static func getAddress(for location: CLLocation) async throws -> String {
        let geocoder = CLGeocoder()
        let lines = try await geocoder.reverseGeocodeLocation(location)
        guard let mark = lines.first, let address = mark.postalAddress else { throw AddressError.noAddressFound }
        return CNPostalAddressFormatter.string(from: address, style: .mailingAddress)
    }
    
    static func getShortAddress(for location: CLLocation) async throws -> String {
        guard let fullAddress: String = try? await getAddress(for: location) else { throw AddressError.noAddressFound }
        guard let shortAddress: String = fullAddress.components(separatedBy: CharacterSet.newlines).first else { throw AddressError.noAddressFound }
        return shortAddress
    }
}
