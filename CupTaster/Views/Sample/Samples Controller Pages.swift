//
//  Samples Controller Pages.swift.swift
//  CupTaster
//
//  Created by Nikita on 29.01.2024.
//

import SwiftUI

struct SamplesControllerPagesView: View {
    @ObservedObject var samplesControllerModel: SamplesControllerModel = .shared
    
    @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
    @State var lastFocusStateChangeDate: Date? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                let samplesCount: Int = samplesControllerModel.cupping?.samples.count ?? 0
                
                ForEach(0..<samplesCount, id: \.self) { index in
                    Capsule()
                        .frame(width: samplesControllerModel.selectedSampleIndex == index ? .large : .extraSmall)
                        .frame(height: .extraSmall)
                        .foregroundStyle(Color.separator)
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
                                        isFirst ? samplesControllerModel.firstSampleRotationAngle : .zero,
                                        axis: (0, 1, 0)
                                    )
                                    .rotation3DEffect(
                                        isLast ? samplesControllerModel.lastSampleRotationAngle : .zero,
                                        axis: (0, 1, 0)
                                    )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .offset(x: CGFloat(samplesControllerModel.selectedSampleIndex) * sampleOffset)
                        .offset(x: samplesControllerModel.swipeOffset)
                    }
                    .frame(height: .smallElementContainer)
                }
                
                HStack {
                    Button {
                        samplesControllerModel.exit()
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: .smallElement, height: .smallElement)
                                .foregroundStyle(.bar)
                            Image(systemName: "chevron.left")
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: .smallElement, height: .smallElement)
                                .foregroundStyle(.bar)
                            Image(systemName: "stopwatch")
                        }
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
            if let lastFocusStateChangeDate, let sample, Date().timeIntervalSince(lastFocusStateChangeDate) < 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    sampleNameTextfieldFocus = sample.id
                }
            }
        }
        .onChange(of: sampleNameTextfieldFocus) { _ in
            lastFocusStateChangeDate = Date()
        }
    }
    
    private struct SampleNameTextField: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var sample: Sample
        let gsw: CGFloat
        private let nameLengthLimit: Int = 50
        @FocusState var sampleNameTextfieldFocus: ObjectIdentifier?
        
        var body: some View {
            TextField("Sample name", text: $sample.name)
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
                .frame(width: gsw)
                .frame(height: .smallElementContainer)
                .multilineTextAlignment(.center)
                .onChange(of: sample.name) { name in
                    if name.count > nameLengthLimit {
                        sample.name = String(name.prefix(nameLengthLimit))
                    }
                    try? moc.save()
                }
                .bottomSheetBlock()
                .cornerRadius()
                .onTapGesture { sampleNameTextfieldFocus = sample.id }
                .shadow(color: .backgroundPrimary.opacity(0.75), radius: .small, x: 0, y: 0)
        }
    }
}
