//
//  Cupping Samples.swift
//  CupTaster
//
//  Created by Никита on 17.08.2022.
//

import SwiftUI

struct CuppingSamplesView: View {
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cupping: Cupping
    
    @State private var tempSamples: [TempSample] = []
    @State private var addingTempSamples: Bool = false
    
    @FocusState var focusedTempSample: Focusable?
    
    var body: some View {
        // Added samples
        ZStack(alignment: .top) {
            InsetFormSection {
                ForEach(cupping.getSortedSamples()) { sample in
                    SampleView(
                        cupping: cupping,
                        sample: sample
                    )
                    .preview
                    .buttonStyle(InsetFormLinkStyle())
                }
                
                if cupping.samples.count < 1 {
                    Text("No samples yet")
                }
            } header: {
                tempSamplesCountPicker
            }
        }
        
        // Temp samples
        if tempSamples.count > 0 {
            InsetFormSection.header {
                HStack {
                    Button("Clear") {
                        tempSamples.removeAll()
                    }
                    
                    Spacer()
                    
                    if tempSamples.count > 1 {
                        Button("Add All") {
                            for tempSample in tempSamples {
                                tempSample.addToCupping(cupping: cupping, context: moc)
                                tempSamples.removeAll(where: { $0.id == tempSample.id })
                            }
                        }
                    }
                }
            }
        }
        
        ForEach(tempSamples) { tempSample in
            TempSampleEditorView(
                tempSample: tempSample,
                isFocused: _focusedTempSample
            ) {
                tempSample.addToCupping(cupping: cupping, context: moc)
                try? moc.save()
                tempSamples.removeAll(where: { $0 == tempSample })
                if tempSamples.count > 0 {
                    focusedTempSample = .row(id: tempSamples.first?.defaultName ?? "")
                } else {
                    focusedTempSample = Focusable.none
                }
            }
            .transition(.move(edge: .bottom).combined(with: .scale))
            .id(tempSample.defaultName)
        }
    }
}

extension CuppingSamplesView {
    var tempSamplesCountPicker: some View {
        HStack {
            if addingTempSamples {
                GeometryReader { outerGeometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(1...50, id: \.self) { samplesToAddCount in
                                GeometryReader { innerGeometry in
                                    Button {
                                        withAnimation {
                                            addingTempSamples = false
                                            addTempSamples(count: samplesToAddCount)
                                        }
                                    } label: {
                                        Text("\(samplesToAddCount)")
                                            .frame(width: 60, height: 30)
                                            .background(.bar, in: Capsule())
                                            .scaleEffect(
                                                buttonScale(
                                                    outerGeometry: outerGeometry,
                                                    innerGeometry: innerGeometry
                                                )
                                            )
                                    }
                                    .tag(samplesToAddCount)
                                }
                                .frame(width: 60, height: 30)
                            }
                        }
                        .padding(.horizontal, outerGeometry.size.width/2 - 30)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 30)
                .transition(
                    .opacity
                        .combined(with: .scale)
                        .combined(with: .move(edge: .trailing))
                )
            } else {
                Text("Samples")
                
                Spacer()
                
                Button {
                    addingTempSamples = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 40, height: 20, alignment: .trailing)
                }
            }
        }
    }
    
    private func addTempSamples(count: Int) {
        for _ in 1...count {
            withAnimation {
                tempSamples.append(
                    TempSample(
                        defaultName:
                            SampleNameGenerator().generateSampleDefaultName(
                                usedNames: tempSamples.map{ $0.name } +
                                tempSamples.map{ $0.defaultName } +
                                cupping.samples.map{ $0.name }
                            )
                    )
                )
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                focusedTempSample = .row(id: tempSamples.first?.defaultName ?? "")
            }
        }
    }
    
    private func buttonScale(outerGeometry: GeometryProxy, innerGeometry: GeometryProxy) -> CGFloat {
        let outerGeometryWidth: CGFloat = outerGeometry.size.width
        let scalingSegment: CGFloat = outerGeometryWidth/6

        let leadingOffset = outerGeometry.frame(in: .global).minX

        if innerGeometry.frame(in: .global).midX < scalingSegment + leadingOffset {
            return (innerGeometry.frame(in: .global).midX - leadingOffset)/scalingSegment
        } else if innerGeometry.frame(in: .global).midX > scalingSegment*5 + leadingOffset {
            return -(innerGeometry.frame(in: .global).midX - outerGeometryWidth - leadingOffset)/scalingSegment
        } else {
            return 1
        }
    }
}

