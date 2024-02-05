//
//  Cupping Settings Modal.swift
//  CupTaster
//
//  Created by Nikita on 05.02.2024.
//

import SwiftUI

extension CuppingView {
    struct CuppingSettingsView: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var cupping: Cupping
        @Binding var isActive: Bool
        
        private let nameLengthLimit = 50
        
        var body: some View {
            VStack(spacing: .extraSmall) {
                TextField("Cupping Name", text: $cupping.name)
                    .resizableText(weight: .light)
                    .submitLabel(.done)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, .regular)
                    .onChange(of: cupping.name) { name in
                        if cupping.name.count > nameLengthLimit {
                            cupping.name = String(cupping.name.prefix(nameLengthLimit))
                        }
                        try? moc.save()
                    }
                    .bottomSheetBlock()
                
                Text("\(cupping.form?.title ?? "") • \(cupping.samples.count) Samples • \(cupping.cupsCount) Cups")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .padding(.vertical, .extraSmall)
                
                HStack(spacing: .extraSmall) {
                    Button {
#warning("action")
                    } label: {
                        HStack(spacing: .extraSmall) {
                            Image(systemName: "folder")
                            Text("Folders")
                        }
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button {
#warning("action")
                    } label: {
                        HStack(spacing: .extraSmall) {
                            Image(systemName: "square.and.arrow.up")
                            Text("Share")
                        }
                    }
                    .buttonStyle(.bottomSheetBlock)
                }
                
#warning("location block")
                VStack { }.bottomSheetBlock()
                
                HStack(spacing: .extraSmall) {
                    Button {
#warning("action")
                    } label: {
                        Text("Delete")
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.bottomSheetBlock)
                    
                    Button("Done") {
                        isActive = false
                    }
                    .buttonStyle(.accentBottomSheetBlock)
                }
            }
            .padding([.horizontal, .bottom], .small)
        }
    }
}
