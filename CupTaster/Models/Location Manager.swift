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
    @PublishedAppStorage("location-union-distance") var unionDistance: Double = 100
    
    var authorized: Bool {
        return switch locationManager.authorizationStatus {
            case .notDetermined, .restricted, .denied: false
            case .authorizedAlways, .authorizedWhenInUse, .authorized: true
            @unknown default: false
        }
    }
    private let locationManager = CLLocationManager()
    @MainActor static let shared: LocationManager = .init()
    
    override private init () {
        super.init()
        locationManager.delegate = self
    }
    
    public func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
        self.attachLocation = switch status {
            case .notDetermined: false
            case .denied: false
            default: true
        }
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
    
    static func getAddress(for location: CLLocationCoordinate2D) async throws -> String {
        if let address = try? await self.getAddress(for: CLLocation(latitude: location.latitude, longitude: location.longitude)) {
            return address
        } else {
            throw AddressError.noAddressFound
        }
    }
    
    static func getShortAddress(for location: CLLocationCoordinate2D) async throws -> String {
        if let address = try? await self.getShortAddress(for: CLLocation(latitude: location.latitude, longitude: location.longitude)) {
            return address
        } else {
            throw AddressError.noAddressFound
        }
    }
    
    static func getAddress(for location: Location) async throws -> String {
        if let address = try? await self.getAddress(for: CLLocation(latitude: location.latitude, longitude: location.longitude)) {
            return address
        } else {
            throw AddressError.noAddressFound
        }
    }
    
    static func getShortAddress(for location: Location) async throws -> String {
        if let address = try? await self.getShortAddress(for: CLLocation(latitude: location.latitude, longitude: location.longitude)) {
            return address
        } else {
            throw AddressError.noAddressFound
        }
    }
}
