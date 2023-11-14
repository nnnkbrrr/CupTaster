//
//  Drag Gesture.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.11.2023.
//

import SwiftUI

struct DragGestureViewModifier: ViewModifier {
    @GestureState private var isDragging: Bool = false
    @State var gestureState: GestureStatus = .idle
    
    var onStart: () -> ()
    var onUpdate: (DragGesture.Value) -> ()
    var onEnd: (DragGesture.Value) -> ()
    var onCancel: () -> ()
    
    init(
        onStart: @escaping () -> Void = {},
        onUpdate: @escaping (DragGesture.Value) -> () = { _ in },
        onEnd: @escaping (DragGesture.Value) -> () = { _ in },
        onCancel: @escaping () -> () = {}
    ) {
        self.onStart = onStart
        self.onUpdate = onUpdate
        self.onEnd = onEnd
        self.onCancel = onCancel
    }

    func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($isDragging) { _, isDragging, _ in
                        isDragging = true
                    }
                    .onChanged(onDragChange(_:))
                    .onEnded(onDragEnded(_:))
            )
            .onChange(of: gestureState) { state in
                guard state == .started else { return }
                gestureState = .active
            }
            .onChange(of: isDragging) { value in
                if value, gestureState != .started {
                    gestureState = .started
                    onStart()
                } else if !value, gestureState != .ended {
                    gestureState = .cancelled
                    onCancel()
                }
            }
    }

    func onDragChange(_ value: DragGesture.Value) {
        guard gestureState == .started || gestureState == .active else { return }
        onUpdate(value)
    }

    func onDragEnded(_ value: DragGesture.Value) {
        gestureState = .ended
        onEnd(value)
    }

    enum GestureStatus: Equatable {
        case idle
        case started
        case active
        case ended
        case cancelled
    }
}

extension View {
    func dragGesture(
        onStart: @escaping () -> Void = {},
        onUpdate: @escaping (DragGesture.Value) -> () = { _ in },
        onEnd: @escaping (DragGesture.Value) -> () = { _ in },
        onCancel: @escaping () -> () = {}
    ) -> some View {
        modifier(
            DragGestureViewModifier() {
                onStart()
            } onUpdate: { value in
                onUpdate(value)
            } onEnd: { value in
                onEnd(value)
            } onCancel: {
                onCancel()
            }
        )
    }
}
