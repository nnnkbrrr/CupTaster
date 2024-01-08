//
//  Sample Delete Section.swift
//  CupTaster
//
//  Created by Nikita on 04.01.2024.
//

import SwiftUI

extension SampleView {
    struct DeleteSection: View {
        var body: some View {
            Button {
#warning("delete")
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Delete")
                }
            }
            .buttonStyle(.sampleBlock(height: .smallElementContainer))
        }
    }
}
