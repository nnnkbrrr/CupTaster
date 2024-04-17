//
//  Alert.swift
//  CupTaster
//
//  Created by Nikita Baranov on 08.04.2024.
//

import SwiftUI

func showAlert(title: String, message: String) {
    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
    guard let window = windowScene.windows.first else { return }
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .destructive))
    window.rootViewController?.present(alert, animated: true)
}
