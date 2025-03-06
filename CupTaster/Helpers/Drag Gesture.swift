//
//  Drag Gesture.swift
//  CupTaster
//
//  Created by Никита Баранов on 04.11.2023.
//

import SwiftUI

enum Direction { case vertical, horizontal }
enum GestureType { case unspecified, simultaneous, highPriority }

struct GestureWithTypeViewModifier<T: Gesture>: ViewModifier {
    let gestureType: GestureType
    let gesture: T
    
    func body(content: Content) -> some View {
        switch gestureType {
            case .unspecified: content.gesture(gesture)
            case .simultaneous: content.simultaneousGesture(gesture)
            case .highPriority: content.highPriorityGesture(gesture)
        }
    }
}

extension View {
    func gestureWithType<T: Gesture>(_ gestureType: GestureType, _ gesture: () -> T) -> some View {
        modifier(GestureWithTypeViewModifier(gestureType: gestureType, gesture: gesture()))
    }
}

struct DragGestureViewModifier: ViewModifier {
    @GestureState private var isDragging: Bool = false
    @State var gestureState: GestureStatus = .idle
    let minimumDistance: CGFloat
    
    enum GestureStatus: Equatable { case idle, started, active, ended, cancelled }
    
    var onStart: () -> ()
    var onUpdate: (DragGesture.Value) -> ()
    var onEnd: (DragGesture.Value) -> ()
    var onCancel: () -> ()
    
    let gestureType: GestureType
    @State var direction: Direction?
    @State var gestureDirection: Direction?
    
    init(
        gestureType: GestureType = .unspecified,
        minimumDistance: CGFloat = 30,
        direction: Direction? = nil,
        onStart: @escaping () -> Void = { },
        onUpdate: @escaping (DragGesture.Value) -> () = { _ in },
        onEnd: @escaping (DragGesture.Value) -> () = { _ in },
        onCancel: @escaping () -> () = { }
    ) {
        self.onStart = onStart
        self.onUpdate = onUpdate
        self.onEnd = onEnd
        self.onCancel = onCancel
        
        self.direction = direction
        self.gestureType = gestureType
        self.minimumDistance = minimumDistance
    }
    
    func body(content: Content) -> some View {
        content
            .gestureWithType(gestureType) {
                DragGesture(minimumDistance: minimumDistance)
                    .updating($isDragging) { _, isDragging, _ in isDragging = true }
                    .onChanged(onDragChange(_:))
                    .onEnded(onDragEnded(_:))
            }
            .onChange(of: gestureState) { state in
                guard state == .started else { return }
                gestureState = .active
            }
            .onChange(of: isDragging) { value in
                if value, gestureState != .started { onDragStarted() }
                else if !value, gestureState != .ended { onDragCanceled() }
            }
    }
    
    func onDragStarted() {
        if direction == nil {
            gestureState = .started
            onStart()
        }
    }

    func onDragChange(_ value: DragGesture.Value) {
        guard gestureState == .started || gestureState == .active || direction != nil else { return }
        
        if direction != nil && gestureDirection == nil {
            gestureDirection = abs(value.translation.height) > abs(value.translation.width) ? .vertical : .horizontal
        }
        
        if gestureDirection == direction {
            onStart()
            onUpdate(value)
        } else if gestureState == .started || gestureState == .active { onDragCanceled() }
    }

    func onDragEnded(_ value: DragGesture.Value) {
        gestureState = .ended
        if gestureDirection == direction { onEnd(value) }
        gestureDirection = nil
    }

    func onDragCanceled() {
        gestureState = .cancelled
        onCancel()
        gestureDirection = nil
    }
}

extension View {
    func dragGesture(
        gestureType: GestureType = .unspecified,
        minimumDistance: CGFloat = 30,
        direction: Direction? = nil,
        onStart: @escaping () -> Void = {},
        onUpdate: @escaping (DragGesture.Value) -> () = { _ in },
        onEnd: @escaping (DragGesture.Value) -> () = { _ in },
        onCancel: @escaping () -> () = {}
    ) -> some View {
        modifier(
            DragGestureViewModifier(
                gestureType: gestureType,
                minimumDistance: minimumDistance,
                direction: direction,
                onStart: { onStart() },
                onUpdate: { onUpdate($0) },
                onEnd: { onEnd($0) },
                onCancel: { onCancel() }
            )
        )
    }
}
