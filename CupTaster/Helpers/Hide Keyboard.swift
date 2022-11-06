//
//  Hide Keyboard.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
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

struct ResignKeyboardOnDragGesture: ViewModifier {
    var onResign: () -> ()
    
    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .onChanged {_ in
                        UIApplication.shared.endEditing(true)
                        onResign()
                    }
            )
    }
}

extension View {
    func resignKeyboardOnDragGesture() -> some View {
        return modifier(ResignKeyboardOnDragGesture() { } )
    }
    
    func resignKeyboardOnDragGesture(onResign: @escaping () -> ()) -> some View {
        return modifier(ResignKeyboardOnDragGesture() { onResign() } )
    }
}
