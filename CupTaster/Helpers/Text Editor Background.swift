//
//  Text Editor Background.swift
//  CupTaster
//
//  Created by Никита on 08.09.2022.
//

import SwiftUI

extension View {
    func textEditorBackgroundColor(_ color: UIColor) -> some View {
        self.onAppear { UITextView.appearance().backgroundColor = color }
    }
}
