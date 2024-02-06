//
//  Sample Sheet Section.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

struct SampleSheetSection<Content: View>: View {
    let title: String
    let content: () -> Content
    
    init(title: String, content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: .small) {
            Text(title)
                .bold()
                .frame(maxWidth: .infinity, alignment: .leading)
            Divider()
            content()
        }
        .padding(.regular)
        .background(Color.backgroundSecondary)
        .cornerRadius()
    }
}
