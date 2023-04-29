//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

enum SampleAppearance {
    case criteria, info
}

struct SampleView: View {
    @Environment(\.managedObjectContext) var moc
    @ObservedObject var cuppingModel: CuppingModel
    @State var sample: Sample
    
    @Binding private var appearance: SampleAppearance
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: SampleAppearance = .criteria) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = .constant(appearance)
    }
    
    init(cuppingModel: CuppingModel, sample: Sample, appearance: Binding<SampleAppearance>) {
        self.cuppingModel = cuppingModel
        self.sample = sample
        self._appearance = appearance
    }
    
    var body: some View {
        switch appearance {
        case .criteria: criteriaAppearance
        case .info: infoAppearance
        }
    }
}
