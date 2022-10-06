//
//  Cupping Toolbar.swift
//  CupTaster
//
//  Created by Никита on 24.09.2022.
//

import SwiftUI

struct CuppingToolbarView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var moc
    @ObservedObject var cuppingModel: CuppingModel
    let namespace: Namespace.ID
    
    @State private var confirmDeleteAction: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let sortedSamples: [Sample] = cuppingModel.sortedSamples
            
            VStack(spacing: 3) {
                if cuppingModel.selectedSample != nil &&
                    (!cuppingModel.switchingSamplesAppearance || cuppingModel.offset.height > -150) {
                    
                    // MARK: Top part
                    
                    HStack(spacing: 0) {
                        ForEach(sortedSamples) { sample in
                            let gsw: CGFloat = geometry.size.width
                            let sampleWidth: CGFloat = gsw * 1.1 - (gsw * 0.25 * (abs(cuppingModel.offset.width)/gsw))
                            let selectedSampleWidth: CGFloat = gsw * 0.85 + (gsw * 0.25 * (abs(cuppingModel.offset.width)/gsw))
                            
                            SampleToolsView(sample: sample)
                                .frame(
                                    width: cuppingModel.selectedSample == sample || cuppingModel.switchingSamplesAppearance ? selectedSampleWidth : sampleWidth,
                                    height: 44
                                )
                                .background(Color(uiColor: .systemGray3), in: RoundedRectangle(cornerRadius: 12))
                                .frame(width: geometry.size.width)
                                .matchedGeometryEffect(id: "\(sample.id) tools", in: namespace)
                                .zIndex(2)
                        }
                    }
                    .offset(
                        x: cuppingModel.offset.width - geometry.size.width * CGFloat(cuppingModel.selectedSampleIndex!),
                        y: cuppingModel.offset.height < 0 && abs(cuppingModel.offset.height) > abs(cuppingModel.offset.width) ? cuppingModel.offset.height/4 : 0
                    )
                    .frame(width: geometry.size.width, alignment: .leading)
                }
                
                // MARK: Bottom part
                
                HStack {
                    
                    // MARK: BP Leading
                    
                    Group {
                        if cuppingModel.samplesEditorActive {
                            Button {
                                moc.rollback()
                                cuppingModel.samplesEditorActive = false
                            } label: {
                                Text("Cancel")
                            }
                        } else if cuppingModel.selectedSample == nil {
                            Button {
                                cuppingModel.samplesEditorActive = true
                            } label: {
                                Text("Edit")
                            }
                        } else if !cuppingModel.switchingSamplesAppearance {
                            Image(systemName: "info.circle")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .padding(10)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if cuppingModel.samplesAppearance == .criteria {
                                        cuppingModel.samplesAppearance = .info
                                    } else {
                                        cuppingModel.samplesAppearance = .criteria
                                    }
                                }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // MARK: BP Center
                    
                    if StopwatchView().timeSince != nil || cuppingModel.selectedSample != nil  {
                        StopwatchView()
                            .frame(maxWidth: .infinity)
                    }
                    
                    // MARK: BP Trailing
                    
                    Group {
                        if cuppingModel.samplesEditorActive {
                            Button {
                                try? moc.save()
                                cuppingModel.samplesEditorActive = false
                            } label: {
                                Text("Save")
                            }
                        } else if cuppingModel.selectedSample == nil {
                            Button("Done") {
                                presentationMode.wrappedValue.dismiss()
                            }
                        } else if !cuppingModel.switchingSamplesAppearance {
                            Image(systemName: "square.on.square")
                                .font(.title2)
                                .foregroundColor(.accentColor)
                                .padding(10)
                                .contentShape(Rectangle())
                                .onTapGesture { cuppingModel.switchToPreviews() }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding(.horizontal, 20)
                .frame(height: 44)
            }
            .frame(height: cuppingModel.switchingSamplesAppearance || cuppingModel.selectedSample == nil ? 44 : 100, alignment: .bottom)
            .contentShape(Rectangle())
            // MARK: Gestures
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if cuppingModel.selectedSample != nil {
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 100)) {
                                cuppingModel.offset = gesture.translation
                                cuppingModel.switchingSamplesAppearance = gesture.translation.height < -50 && abs(gesture.translation.height) > abs(gesture.translation.width)
                            }
                        }
                    }
                    .onEnded { gesture in
                        if cuppingModel.selectedSample != nil {
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 100)) {
                                if cuppingModel.switchingSamplesAppearance {
                                    cuppingModel.switchToPreviews()
                                } else {
                                    let longGesture: Bool = abs(gesture.translation.width) > geometry.size.width / 3
                                    let fastGesture: Bool = abs(gesture.predictedEndTranslation.width) > 150
                                    
                                    if longGesture || fastGesture {
                                        let newIndex = cuppingModel.selectedSampleIndex! + -Int(copysign(1, gesture.translation.width))
                                        cuppingModel.selectedSampleIndex = min(max(Int(newIndex), 0), sortedSamples.count - 1)
                                        cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex!]
                                    }
                                }
                                cuppingModel.offset = .zero
                                cuppingModel.switchingSamplesAppearance = false
                            }
                        }
                    }
            )
        }
        .frame(height: cuppingModel.switchingSamplesAppearance || cuppingModel.selectedSample == nil ? 44 : 100, alignment: .bottom)
        .background(.bar)
    }
}


