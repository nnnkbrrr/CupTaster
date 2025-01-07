//
//  Dismiss Keyboard.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

extension UIApplication {
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}

extension UIApplication {
    func addPanGestureRecognizer() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let window = windowScene.windows.first else { return }
        let panGesture = UIPanGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        panGesture.requiresExclusiveTouchType = false
        panGesture.cancelsTouchesInView = false
        panGesture.delegate = self
        window.addGestureRecognizer(panGesture)
    }
}

extension UIApplication: @retroactive UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !otherGestureRecognizer.isKind(of: UILongPressGestureRecognizer.self)
    }
}
