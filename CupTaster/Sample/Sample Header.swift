//
//  Sample Header.swift
//  CupTaster
//
//  Created by Никита on 25.08.2022.
//

import SwiftUI

struct SampleHeaderView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        HStack(spacing: 15) {
            TextField("", text: $sample.name)
                .submitLabel(.done)
                .onSubmit {
                    sample.cupping.objectWillChange.send()
                    try? moc.save()
                }
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
        .background(Blur(style: .systemMaterial))
    }
}
