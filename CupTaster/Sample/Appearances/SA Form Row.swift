//
//  SA Form Row.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.03.2023.
//

import SwiftUI

struct SampleFormRowView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var sample: Sample
    
    var body: some View {
        TextField("Sample name", text: $sample.name)
            .submitLabel(.done)
            .onSubmit { try? moc.save() }
    }
}
