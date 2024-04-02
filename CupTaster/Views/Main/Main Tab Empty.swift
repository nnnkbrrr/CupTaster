//
//  All Cuppings Empty.swift
//  CupTaster
//
//  Created by Никита Баранов on 06.07.2023.
//

import SwiftUI

#warning("screen: Нет каппингов")
extension MainTabView {
    var isEmpty: some View {
        Text("No cuppings yet")
            .frame(maxWidth: .infinity)
            .background(Color.backgroundPrimary)
    }
}

