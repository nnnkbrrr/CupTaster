//
//  Hints View.swift
//  CupTaster
//
//  Created by Никита Баранов on 08.10.2022.
//

import SwiftUI

struct HintsMenuView: View {
    let qcGroupConfig: QCGroupConfig
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(qcGroupConfig.title)
                .font(.largeTitle)
                .bold()

            if let qcgcHintMessage: String = qcGroupConfig.hint?.message {
                Text(qcgcHintMessage)
                    .bold()
            }
            
            ForEach(Array(qcGroupConfig.qcConfigurations)) { qcConfig in
                if qcConfig.hints.count > 0 {
                    Rectangle()
                        .frame(height: 1)
                        .padding(.vertical)
                }
                
                ForEach(qcConfig.hints.sorted(by: { $0.lowerBound < $1.lowerBound })) { qcHint in
                    let formattedLowerBound: String = formatValue(qcHint.lowerBound)
                    Text(formattedLowerBound + "+")
                        .fontWeight(.heavy)
                    
                    Text(qcHint.message)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
    
    func formatValue(_ value: Double) -> String {
        switch value.truncatingRemainder(dividingBy: 1) {
            case 0: return String(format: "%.0f", value)
            case 0.5: return String(format: "%.1f", value)
            default: return String(format: "%.2f", value)
        }
    }
}
