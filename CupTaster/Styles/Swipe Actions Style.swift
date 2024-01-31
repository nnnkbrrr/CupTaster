//
//  Swipe Actions Style.swift
//  CupTaster
//
//  Created by Nikita on 30.01.2024.
//

import SwiftUI
import SwipeActions

public extension SwipeView {
    func allCuppingsActionsStyle() -> SwipeView {
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
