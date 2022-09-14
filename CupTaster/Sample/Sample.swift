//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @State var sample: Sample
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    EvaluationGroupView(qcGroup: qcGroup)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 100) // footer
            .resignKeyboardOnDragGesture()
        }
    }
}
