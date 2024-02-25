//
//  Swipe Actions Style.swift
//  CupTaster
//
//  Created by Nikita on 30.01.2024.
//

import SwiftUI
import SwipeActions

struct SwipeActionView: View {
    let systemImage: String
    let title: String
    let color: Color
    let action: () -> ()
    
    init(systemImage: String, title: String, color: Color, action: @escaping () -> ()) {
        self.systemImage = systemImage
        self.title = title
        self.color = color
        self.action = action
    }
    
    var body: some View {
        SwipeAction {
            action()
        } label: { _ in
            VStack(spacing: .extraSmall) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.subheadline)
            .foregroundStyle(.white)
        } background: { _ in
            color
        }
    }
}

public extension SwipeView {
    func defaultSwipeStyle() -> SwipeView {
        return self
            .swipeActionsStyle(.cascade)
            .swipeActionsMaskCornerRadius(0)
            .swipeActionCornerRadius(0)
            .swipeSpacing(0)
            .swipeActionsVisibleStartPoint(0)
            .swipeActionsVisibleEndPoint(0)
            .swipeMinimumDistance(25)
    }
}
