//
//  Cupping Samples.swift
//  CupTaster
//
//  Created by Никита on 17.08.2022.
//

import SwiftUI

//extension CuppingSamplesView {
//    var tempSamplesCountPicker: some View {
//        HStack {
//            if addingTempSamples {
//                GeometryReader { outerGeometry in
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        HStack {
//                            ForEach(1...50, id: \.self) { samplesToAddCount in
//                                GeometryReader { innerGeometry in
//                                    Button {
//                                        withAnimation {
//                                            addingTempSamples = false
//                                            addTempSamples(count: samplesToAddCount)
//                                        }
//                                    } label: {
//                                        Text("\(samplesToAddCount)")
//                                            .frame(width: 60, height: 30)
//                                            .background(.bar, in: Capsule())
//                                            .scaleEffect(
//                                                buttonScale(
//                                                    outerGeometry: outerGeometry,
//                                                    innerGeometry: innerGeometry
//                                                )
//                                            )
//                                    }
//                                    .tag(samplesToAddCount)
//                                }
//                                .frame(width: 60, height: 30)
//                            }
//                        }
//                        .padding(.horizontal, outerGeometry.size.width/2 - 30)
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .frame(height: 30)
//                .transition(
//                    .opacity
//                        .combined(with: .scale)
//                        .combined(with: .move(edge: .trailing))
//                )
//            } else {
//                Button("Add") { withAnimation { addingTempSamples = true } }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//
//                Text("Samples")
//
//                Spacer().frame(maxWidth: .infinity)
//            }
//        }
//    }
//
//    private func addTempSamples(count: Int) {
//        for _ in 1...count {
//            withAnimation {
//                tempSamples.append(
//                    TempSample(
//                        defaultName:
//                            SampleNameGenerator().generateSampleDefaultName(
//                                usedNames: tempSamples.map{ $0.name } +
//                                tempSamples.map{ $0.defaultName } +
//                                cupping.samples.map{ $0.name }
//                            )
//                    )
//                )
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
//                focusedTempSample = .row(id: tempSamples.first?.defaultName ?? "")
//            }
//        }
//    }
//
//    private func buttonScale(outerGeometry: GeometryProxy, innerGeometry: GeometryProxy) -> CGFloat {
//        let outerGeometryWidth: CGFloat = outerGeometry.size.width
//        let scalingSegment: CGFloat = outerGeometryWidth/6
//
//        let leadingOffset = outerGeometry.frame(in: .global).minX
//
//        if innerGeometry.frame(in: .global).midX < scalingSegment + leadingOffset {
//            return (innerGeometry.frame(in: .global).midX - leadingOffset)/scalingSegment
//        } else if innerGeometry.frame(in: .global).midX > scalingSegment*5 + leadingOffset {
//            return -(innerGeometry.frame(in: .global).midX - outerGeometryWidth - leadingOffset)/scalingSegment
//        } else {
//            return 1
//        }
//    }
//}

