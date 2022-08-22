//
//  TempSample.swift
//  CupTaster
//
//  Created by Никита on 16.08.2022.
//

import SwiftUI
import CoreData

class TempSample: ObservableObject, Identifiable, Equatable {
    static func == (lhs: TempSample, rhs: TempSample) -> Bool { return lhs.id == rhs.id }
    
    @Published var name: String
    
    let defaultName: String
    let timelineDate: Date
    
    init(defaultName: String) {
        self.name = ""
        
        self.defaultName = defaultName
        self.timelineDate = Date(
            timeIntervalSinceNow: TimeInterval(.random(in: 0.0...1.0))
        )
    }
    
    public func getName() -> String {
        return name == "" ? defaultName : name
    }
    
    public func addToCupping(cupping: Cupping, context: NSManagedObjectContext) {
        let sample = Sample(context: context)
        sample.name = self.getName()
        sample.ordinalNumber = Int16(cupping.samples.count)
        
        if let cuppingForm = cupping.form {
            for groupConfig in cuppingForm.qcGroupConfigurations {
                let qcGroup: QCGroup = QCGroup(context: context)
                qcGroup.sample = sample
                qcGroup.configuration = groupConfig
                for qcConfig in groupConfig.qcConfigurations {
                    let qualityCriteria = QualityCriteria(context: context)
                    qualityCriteria.title = qcConfig.title
                    qualityCriteria.value = qcConfig.value
                    qualityCriteria.group = qcGroup
                    qualityCriteria.configuration = qcConfig
                }
            }
        }
        
        cupping.addToSamples(sample)
    }
}

enum Focusable: Hashable {
  case none
  case row(id: String)
}

struct TempSampleEditorView: View {
    @ObservedObject var tempSample: TempSample
    @FocusState var isFocused: Focusable?
    
    let addToSamples: () -> ()
    
    var body: some View {
        TimelineView(.animation) { timeline in
            let isFocused: Bool = isFocused == .row(id: tempSample.defaultName)
            let timeNow = timeline.date.timeIntervalSince(tempSample.timelineDate)
            let angle = Angle(degrees: abs(timeNow.remainder(dividingBy: 0.3)) * 10 - 0.5)
            
            ZStack(alignment: .trailing) {
                TextField("\(tempSample.defaultName)", text: $tempSample.name)
                    .frame(height: 44)
                    .focused($isFocused, equals: .row(id: tempSample.defaultName))
                    .submitLabel(.done)
                    .keyboardType(.webSearch)
                    .autocorrectionDisabled()
                
                Button {
                    addToSamples()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .frame(width: 44, height: 44, alignment: .trailing)
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.init(uiColor: .secondarySystemGroupedBackground))
                    .rotationEffect(angle)
            )
            .padding(.horizontal, 20)
            .scaleEffect(isFocused ? 1.05 : 1)
        }
        .animation(.default, value: isFocused)
    }
}
