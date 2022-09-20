//
//  SampleEditor.swift
//  CupTaster
//
//  Created by Никита on 10.07.2022.
//

import SwiftUI

struct SampleSelectorView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var cupping: Cupping
    var sortedSamples: [Sample]
    @Binding var selectedSample: Sample?
    @State var selectedSampleIndex: Int
    
    var namespace: Namespace.ID
    
    init(cupping: Cupping, selectedSample: Binding<Sample?>, namespace: Namespace.ID) {
        self.cupping = cupping
        self.sortedSamples = cupping.getSortedSamples()
        self._selectedSample = selectedSample
        self._selectedSampleIndex = State(initialValue: sortedSamples.firstIndex(of: selectedSample.wrappedValue!)!)
        self.namespace = namespace
    }
    
    @State var offset: CGSize = .zero
    @State var exiting: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                HStack(spacing: exiting ? 50 : 0) {
                    ForEach(sortedSamples) { sample in
                        VStack {
                            SampleView(sample: sample)
                                .frame(width: geometry.size.width)
                            
                            if exiting {
                                Text(sample.name)
                                    .font(.system(size: 25, weight: .heavy))
                                    .frame(width: geometry.size.width * 0.9, height: 44)
                                    .background(Color(uiColor: .systemGray3), in: RoundedRectangle(cornerRadius: 12))
                                    .padding(.bottom)
                                    .matchedGeometryEffect(id: "\(sample.id) tools", in: namespace)
                                    .zIndex(2)
                            }
                        }
                        .background(Color(uiColor: .systemBackground))
                        .cornerRadius(exiting ? 25 : 0)
                        .matchedGeometryEffect(id: sample.id, in: namespace)
                    }
                }
                .offset(x: offset.width - geometry.size.width * CGFloat(selectedSampleIndex))
                .frame(width: geometry.size.width, alignment: .leading)
                .scaleEffect(exiting ? 0.7 + (offset.height/(geometry.size.height*2)) : 1)
                
                VStack(spacing: 3) {
                    if !exiting {
                        HStack(spacing: 0) {
                            ForEach(sortedSamples) { sample in
                                let gsw: CGFloat = geometry.size.width
                                let sampleWidth = gsw * 1.1 - (gsw * 0.25 * (abs(offset.width)/gsw))
                                let selectedSampleWidth = gsw * 0.85 + (gsw * 0.25 * (abs(offset.width)/gsw))
                                
                                SampleToolsView(sample: sample)
                                    .frame(
                                        width: selectedSample == sample ? selectedSampleWidth : sampleWidth,
                                        height: 44
                                    )
                                    .background(Color(uiColor: .systemGray3), in: RoundedRectangle(cornerRadius: 12))
                                    .frame(width: geometry.size.width)
                                    .scaleEffect(exiting ? 0.7 + (offset.height/geometry.size.height) : 1)
                                    .matchedGeometryEffect(id: "\(sample.id) tools", in: namespace)
                                    .zIndex(2)
                            }
                        }
                        .offset(
                            x: offset.width - geometry.size.width * CGFloat(selectedSampleIndex),
                            y: offset.height < 0 ? offset.height/4 : 0
                        )
                        .frame(width: geometry.size.width, alignment: .leading)
                    }
                    
                    SampleSelectorToolsView(selectedSample: $selectedSample)
                }
                .frame(height: exiting ? 50 : 100, alignment: .bottom)
                .background(.bar)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            offset = gesture.translation
                            withAnimation(.interpolatingSpring(stiffness: 350, damping: 100)) {
                                exiting = gesture.translation.height < -150
                            }
                        }
                        .onEnded { gesture in
                            if exiting {
                                withAnimation {
                                    selectedSample = nil
                                }
                            } else {
                                withAnimation(.spring()) {
                                    let longGesture: Bool = abs(gesture.translation.width) > geometry.size.width / 3
                                    let fastGesture: Bool = abs(gesture.predictedEndTranslation.width) > 150
                                    
                                    if longGesture || fastGesture {
                                        let newIndex = selectedSampleIndex + -Int(copysign(1, gesture.translation.width))
                                        selectedSampleIndex = min(max(Int(newIndex), 0), sortedSamples.count - 1)
                                        selectedSample = sortedSamples[selectedSampleIndex]
                                    }
                                    
                                    self.offset = .zero
                                }
                            }
                        }
                )
            }
        }
    }
}
