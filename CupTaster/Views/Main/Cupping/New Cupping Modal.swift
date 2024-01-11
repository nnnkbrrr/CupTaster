//
//  New Cupping Modal.swift
//  CupTaster
//
//  Created by Nikita on 11.01.2024.
//

import SwiftUI

struct NewCuppingModalView: View {
    @Binding var isActive: Bool
    
    private let nameLengthLimit = 50
    @State var name: String = ""
    @State var cupsCount: Int = 5
    @State var sampleCount: Int = 10
    
    var body: some View {
        VStack(spacing: .extraSmall) {
            TextField("Cupping Name", text: $name)
                .resizableText(weight: .light)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.vertical, .regular)
                .onChange(of: name) { name in
                    if name.count > nameLengthLimit {
                        self.name = String(name.prefix(nameLengthLimit))
                    }
                }
                .bottomSheetBlock()
            
            VStack(spacing: .regular) {
                Text("Cups")
                    .foregroundStyle(.gray)
                
                TargetHorizontalScrollView(
                    1...5, selection: $cupsCount,
                    elementWidth: .smallElement, height: 30, spacing: .regular
                ) { cupsNum in
                    Text("\(cupsNum)")
                        .foregroundStyle(cupsNum == cupsCount ? Color.primary : .gray)
                        .font(.title2)
                        .frame(width: .smallElement)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .bottomSheetBlock(height: 100)
            
            VStack(spacing: .regular) {
                Text("Samples")
                    .foregroundStyle(.gray)
                
                TargetHorizontalScrollView(
                    1...20, selection: $sampleCount,
                    elementWidth: .smallElement, height: 30, spacing: .regular
                ) { samplesNum in
                    Text("\(samplesNum)")
                        .foregroundStyle(samplesNum == sampleCount ? Color.primary : .gray)
                        .font(.title2)
                        .frame(width: .smallElement)
                }
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.clear, .black, .clear]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            .bottomSheetBlock(height: 100)
            
            HStack(spacing: .extraSmall) {
                Button("Cancel") {
                    isActive = false
                }
                .buttonStyle(.bottomSheetBlock)
                
                Button {
                    isActive = false
#warning("continue")
                } label: {
                    HStack(spacing: .small) {
                        Text("Continue")
                        Image(systemName: "arrow.right")
                    }
                }
                .buttonStyle(.accentBottomSheetBlock)
            }
        }
        .padding([.horizontal, .bottom], .small)
    }
}
