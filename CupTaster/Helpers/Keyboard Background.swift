//
//  Keyboard Background.swift
//  CupTaster
//
//  Created by Никита Баранов on 16.02.2023.
//

import SwiftUI

struct KeyboardBackgroundColor: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View { colorScheme == .dark ? Color(white: 0.22) : Color(white: 0.83) }
}
