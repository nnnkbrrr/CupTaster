//
//  SampleView.swift
//  CupTaster
//
//  Created by Никита on 27.06.2022.
//

import SwiftUI

struct SampleView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cupping: Cupping
    @State var sample: Sample
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TextField("Sample name", text: $sample.name)
                    .padding()
                    .background(Color.gray.opacity(0.25))
                    .cornerRadius(10)
                    .submitLabel(.done)
                    .onSubmit {
                        cupping.objectWillChange.send()
                        try? moc.save()
                    }
                
                ForEach(
                    sample.qualityCriteriaGroups
                        .sorted(by: { $0.configuration.ordinalNumber < $1.configuration.ordinalNumber })
                ) { qcGroup in
                    QCGroupView(qcGroup: qcGroup)
                }
            }
            .padding()
        }
        .modifier(SampleSelector(cupping: cupping, selectedSample: $sample))
    }
    
    public var preview: some View {
        NavigationLink(destination: self) {
                Text(sample.name)
        }
    }
}

struct QCGroupView: View {
    @ObservedObject var qcGroup: QCGroup
    
    var body: some View {
        VStack {
            EvaluationHeaderView(qcGroup: qcGroup)
                .frame(maxWidth: .infinity)
                .padding(.vertical)
                .background(Color.gray.opacity(0.25))
                .cornerRadius(10)
            
            if !qcGroup.isCompleted {
                VStack(spacing: 15) {
                    ForEach(qcGroup.qualityCriteria.sorted()) { qualityCriteria in
                        EvaluationView(qualityCriteria: qualityCriteria)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.25))
                .cornerRadius(10)
                .transition(
                    .scale(scale: 0, anchor: .top)
                    .combined(with: .opacity)
                )
            }
        }
    }
}
