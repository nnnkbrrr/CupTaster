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
    
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
    
    @State private var confirmDeleteAction: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            let sortedSamples: [Sample] = cuppingModel.sortedSamples
            
            VStack(spacing: 3) {
                let sampleViewVisible: Bool = cuppingModel.sampleViewVisible
                let validPosition: Bool = !cuppingModel.switchingToPreviews || cuppingModel.offset.height > -150
                
                if sampleViewVisible && validPosition {
                    HStack(spacing: 0) {
                        ForEach(sortedSamples) { sample in
                            let gsw: CGFloat = geometry.size.width
                            let sampleWidth: CGFloat = gsw * 1.1 - (gsw * 0.25 * (abs(cuppingModel.offset.width)/gsw))
                            let selectedSampleWidth: CGFloat = gsw * 0.85 + (gsw * 0.25 * (abs(cuppingModel.offset.width)/gsw))
                            
                            SampleToolsView(sample: sample, sampleNameTextfieldFocus: _sampleNameTextfieldFocus)
                                .frame(
                                    width: cuppingModel.selectedSample == sample || cuppingModel.switchingToPreviews ? selectedSampleWidth : sampleWidth,
                                    height: 44
                                )
                                .background(Color.keyboardKey.opacity(sampleNameTextfieldFocus == nil ? 0.75 : 1))
                                .background(.thinMaterial)
                                .cornerRadius(12)
                                .shadow(color: .clear, radius: 1) // view rendering
                                .frame(width: geometry.size.width)
                                .zIndex(2)
                        }
                    }
                    .offset(
                        x: cuppingModel.offset.width - geometry.size.width * CGFloat(cuppingModel.selectedSampleIndex!),
                        y: cuppingModel.offset.height < 0 && abs(cuppingModel.offset.height) > abs(cuppingModel.offset.width) ? cuppingModel.offset.height/3 : 0
                    )
                    .frame(width: geometry.size.width, alignment: .leading)
                    .transition(.scale(scale: 0.5).combined(with: .move(edge: .top)).combined(with: .opacity))
                }
                
                if sampleNameTextfieldFocus == nil {
                    HStack {
                        Group {
                            if cuppingModel.samplesEditorActive {
                                Button {
                                    moc.rollback()
                                    cuppingModel.samplesEditorActive = false
                                } label: {
                                    Text("Cancel")
                                }
                            } else if !cuppingModel.sampleViewVisible {
                                Button {
                                    cuppingModel.samplesEditorActive = true
                                } label: {
                                    Text("Edit")
                                }
                            } else if !cuppingModel.switchingToPreviews {
                                Image(systemName: "info.circle")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .padding(10)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
										withAnimation(.default) {
											if cuppingModel.samplesAppearance == .criteria {
												cuppingModel.samplesAppearance = .info
											} else {
												cuppingModel.samplesAppearance = .criteria
											}
										}
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        StopwatchView()
                            .font(.title2)
                            .frame(maxWidth: .infinity)
                        
                        Group {
                            if cuppingModel.samplesEditorActive {
                                Button {
                                    try? moc.save()
                                    cuppingModel.samplesEditorActive = false
                                } label: {
                                    Text("Save")
                                }
                            } else if !cuppingModel.sampleViewVisible {
                                Button("Done") {
                                    presentationMode.wrappedValue.dismiss()
                                }
                            } else if !cuppingModel.switchingToPreviews {
                                Image(systemName: "square.on.square")
                                    .font(.title2)
                                    .foregroundColor(.accentColor)
                                    .padding(10)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            cuppingModel.sampleViewVisible = false
                                        }
                                    }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 44)
                }
            }
            .frame(height: toolbarHeight, alignment: .bottom)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        if cuppingModel.sampleViewVisible && gesture.startLocation.y < 70 {
                            withAnimation {
                                cuppingModel.offset = gesture.translation
                                cuppingModel.switchingToPreviews = gesture.translation.height < -50 && abs(gesture.translation.height) > abs(gesture.translation.width)
                            }
                        }
                    }
                    .onEnded { gesture in
                        if cuppingModel.sampleViewVisible {
                            withAnimation(.interpolatingSpring(stiffness: 400, damping: 100)) {
                                if cuppingModel.switchingToPreviews {
                                    cuppingModel.sampleViewVisible = false
                                } else {
                                    let longGesture: Bool = abs(gesture.translation.width) > geometry.size.width / 3
                                    let fastGesture: Bool = abs(gesture.predictedEndTranslation.width) > 150
                                    
                                    if longGesture || fastGesture {
                                        let newIndex = cuppingModel.selectedSampleIndex! + -Int(copysign(1, gesture.translation.width))
                                        cuppingModel.selectedSampleIndex = min(max(Int(newIndex), 0), sortedSamples.count - 1)
                                        cuppingModel.selectedSample = sortedSamples[cuppingModel.selectedSampleIndex!]
                                        
                                        if sampleNameTextfieldFocus != nil {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                sampleNameTextfieldFocus = cuppingModel.selectedSample!.id
                                            }
                                        }
                                    }
                                    cuppingModel.offset = .zero
                                    cuppingModel.switchingToPreviews = false
                                }
                            }
                        }
                    }
            )
        }
        .frame(height: toolbarHeight, alignment: .bottom)
        .background(Color.keyboardBackground.opacity(sampleNameTextfieldFocus == nil ? 0.2 : 1), ignoresSafeAreaEdges: .all)
        .background(.ultraThinMaterial, ignoresSafeAreaEdges: .all)
		.overlay(alignment: .top) { Divider() }
    }
    
    private var toolbarHeight: CGFloat {
        if cuppingModel.sampleViewVisible {
            if sampleNameTextfieldFocus == nil {
                return 100
            }
            return 54
        }
        return 44
    }
}
