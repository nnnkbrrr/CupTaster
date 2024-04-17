//
//  Samples Controller Pages.swift.swift
//  CupTaster
//
//  Created by Nikita on 29.01.2024.
//

import SwiftUI

struct SamplesControllerPagesView: View {
    @ObservedObject var sampleGesturesControllerModel: SampleGesturesControllerModel = .shared
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    @ObservedObject var stopwatchModel: StopwatchModel = .shared
    
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
    @State var lastFocusStateChangeDate: Date? = nil
    @State var lastFocusStateSampleID: ObjectIdentifier? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                let samplesCount: Int = samplesControllerModel.cupping?.samples.count ?? 0
                
                ForEach(0..<samplesCount, id: \.self) { index in
                    Capsule()
                        .frame(width: samplesControllerModel.selectedSampleIndex == index ? .large : .extraSmall)
                        .frame(height: .extraSmall)
                        .foregroundStyle(Color.separatorPrimary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, .extraSmall)
            
            ZStack {
                if let cupping = samplesControllerModel.cupping {
                    GeometryReader { geometry in
                        let spacing: CGFloat = .large
                        let sampleOffset: CGFloat = -(geometry.size.width + spacing)
                        
                        HStack(spacing: spacing) {
                            let sortedSamples = cupping.sortedSamples
                            
                            ForEach(sortedSamples) { sample in
                                let isFirst: Bool = sample.ordinalNumber == 0
                                let isLast: Bool = sample.ordinalNumber == sortedSamples.last?.ordinalNumber ?? 0
                                
                                SampleNameTextField(sample: sample, gsw: geometry.size.width, sampleNameTextfieldFocus: _sampleNameTextfieldFocus)
                                    .rotation3DEffect(
                                        isFirst ? sampleGesturesControllerModel.firstSampleRotationAngle : .zero,
                                        axis: (0, 1, 0)
                                    )
                                    .rotation3DEffect(
                                        isLast ? sampleGesturesControllerModel.lastSampleRotationAngle : .zero,
                                        axis: (0, 1, 0)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: CGFloat(samplesControllerModel.selectedSampleIndex) * sampleOffset)
                        .offset(x: sampleGesturesControllerModel.swipeOffset)
                    }
                    .frame(height: .smallElementContainer)
                }
                
                HStack {
                    Button {
                        samplesControllerModel.exit()
                    } label: {
                        Image(systemName: "checkmark")
                            .frame(width: .smallElement, height: .smallElement)
                            .background(Color.backgroundTertiary)
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Button {
                        withAnimation(.bouncy(duration: 0.5, extraBounce: 0.25)) {
                            samplesControllerModel.stopwatchOverlayIsActive = true
                        }
                    } label: {
                        ZStack {
                            if stopwatchModel.state == .idle {
                                Image(systemName: "stopwatch")
                            } else {
                                TimelineView(.periodic(from: Date(), by: 1)) { context in
                                    ZStack {
                                        CircularProgressView(
                                            progress: stopwatchModel.seconds / 60,
                                            style: .init(lineWidth: 2),
                                            outlineColor: .backgroundTertiary,
                                            progressColor: stopwatchModel.state == .stopped ? .gray : .accentColor
                                        )
                                        .animation(.linear(duration: 1), value: context.date)
                                        .padding(1)
                                        
                                        Text("\(stopwatchModel.minutes)")
                                            .foregroundStyle(stopwatchModel.state == .stopped ? .gray : .accentColor)
                                    }
                                }
                            }
                        }
                        .frame(width: .smallElement, height: .smallElement)
                        .background(Color.backgroundTertiary)
                        .clipShape(Circle())
                    }
                }
                .padding(.horizontal, .small)
            }
        }
        .padding(.horizontal, .extraSmall)
        .background {
            ZStack {
                BackdropBlurView(radius: .small)
                    .padding(.bottom, .extraSmall)
                
                TransparentBlurView()
                    .mask(
                        LinearGradient(
                            stops: [
                                .init(color: .white, location: 0.5),
                                .init(color: .white.opacity(0), location: 1),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                
                LinearGradient(
                    colors: [.backgroundPrimary.opacity(0.5), .backgroundPrimary.opacity(0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .edgesIgnoringSafeArea(.top)
        }
        .onChange(of: SamplesControllerModel.shared.selectedSample) { sample in
            if let lastFocusStateChangeDate, let sample, Date().timeIntervalSince(lastFocusStateChangeDate) < 1 && lastFocusStateSampleID != sample.id {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    sampleNameTextfieldFocus = sample.id
                }
            }
            lastFocusStateSampleID = sample?.id
        }
        .onChange(of: sampleNameTextfieldFocus) { _ in
            lastFocusStateChangeDate = Date()
            lastFocusStateSampleID = SamplesControllerModel.shared.selectedSample?.id
        }
    }
    
    private struct SampleNameTextField: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
        @ObservedObject var sample: Sample
        let gsw: CGFloat
        private let nameLengthLimit: Int = 50
        @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
        
        var body: some View {
            ZStack {
                if !samplesControllerModel.stopwatchOverlayIsActive || samplesControllerModel.selectedSample != sample {
                    TextField("Sample name", text: $sample.name)
                        .submitLabel(.done)
                        .onSubmit { sampleNameTextfieldFocus = nil }
                        .focused($sampleNameTextfieldFocus, equals: Optional(sample.id))
                        .submitLabel(.done)
                        .onReceive(NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)) { obj in
                            DispatchQueue.main.async {
                                if let textField = obj.object as? UITextField {
                                    textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
                                }
                            }
                        }
                        .resizableText(weight: .light)
                        .padding(.horizontal, .smallElement + .small) // Tools overlay
                        .frame(width: gsw, height: .smallElementContainer)
                        .multilineTextAlignment(.center)
                        .onChange(of: sample.name) { name in
                            if name.count > nameLengthLimit {
                                sample.name = String(name.prefix(nameLengthLimit))
                            }
                            if TestingManager.shared.allowSaves { try? moc.save() }
                        }
                        .bottomSheetBlock()
                        .matchedGeometryEffect(
                            id: "\(sample.id).page.container",
                            in: NamespaceControllerModel.shared.namespace
                        )
                        .frame(width: gsw, height: .smallElementContainer)
                        .onTapGesture { sampleNameTextfieldFocus = sample.id }
                } else {
                    Color.clear.frame(width: gsw)
                }
            }
            .shadow(color: .backgroundPrimary.opacity(0.75), radius: .small, x: 0, y: 0)
        }
    }
}
