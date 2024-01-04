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
            HStack {
                Image(systemName: "trash")
                Text("Delete")
            }
            .foregroundStyle(Color.red)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture {
#warning("delete")
            }
        }
    }
}
