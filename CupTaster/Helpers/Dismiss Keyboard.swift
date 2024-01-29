//
//  Dismiss Keyboard.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI
import Combine
import UIKit

extension UIApplication {
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}

struct ResignKeyboardOnGesture: ViewModifier {
    var onResign: () -> ()
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture()
                    .onChanged { _ in
                        UIApplication.shared.endEditing(true)
                        onResign()
                    }
            )
        // MARK: - breaks navigation
        // .simultaneousGesture(
        //     TapGesture()
        //         .onEnded { _ in
        //             UIApplication.shared.endEditing(true)
        //             onResign()
        //         }
        // )
    }
}

extension View {
    func resignKeyboardOnGesture(onResign: @escaping () -> () = { } ) -> some View {
        return modifier(ResignKeyboardOnGesture() { onResign() } )
    }
}

