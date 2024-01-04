//
//  General Info Section.swift
//  CupTaster
//
//  Created by Nikita on 04.01.2024.
//

import SwiftUI

extension SampleView {
    struct GeneralInfoSection: View {
        let gridCellSize: CGFloat
        
        var body: some View {
            LazyVGrid(
                columns: [
                    GridItem(
                        .adaptive(minimum: 150, maximum: 200),
                        spacing: .extraSmall,
                        alignment: .top
                    )
                ],
                spacing: .extraSmall
            ) {
                ForEach(0..<4, id: \.self) { _ in
                    Text("#General Info#")
                        .foregroundStyle(.gray)
                        .frame(maxWidth: .infinity)
                        .frame(height: .smallElementContainer)
                        .background(Color.backgroundSecondary)
                        .cornerRadius()
                }
            }
        }
    }
}
