//
//  SA Preview.swift
//  CupTaster
//
//  Created by Никита Баранов on 01.03.2023.
//

import SwiftUI

extension SampleView {
    public var preview: some View {
        VStack(alignment: .leading, spacing: 0) {
            RadarChart(sample: sample, useShortLabels: true)
            
            HStack {
                Group {
                    if sample.finalScore != 0 { Text(String(format: "%.1f", sample.finalScore)) }
                    else { Text("-") }
                }
                .lineLimit(1)
                .frame(width: 30)
                
                Divider()
                    .frame(height: 15)
                
                Text(sample.name)
                    .fixedSize(horizontal: true, vertical: true)
                
                if sample.isFavorite {
                    Spacer()
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                }
            }
            .font(.caption)
        }
        .padding(10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .cornerRadius(15)
    }
}
