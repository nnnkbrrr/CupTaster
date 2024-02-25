//
//  Camera Manager.swift
//  CupTaster
//
//  Created by Nikita on 25.02.2024.
//

import SwiftUI
import AVFoundation

class CameraManager {
    static var isAuthorized: Bool? {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .notDetermined { return nil }
        return [.authorized, .restricted].contains(status)
    }
}
