//
//  SliderView.swift
//  CupTaster
//
//  Created by Никита on 15.06.2022.
//

import SwiftUI

class SliderConfiguration {
    let bounds: ClosedRange<CGFloat>
    let step: CGFloat
    let spacing: CGFloat
    
    let fractionValues: [CGFloat]
    
    init(bounds: ClosedRange<CGFloat>, step: CGFloat, spacing: CGFloat) {
        self.bounds = bounds
        self.step = step
        self.spacing = spacing
        
        self.fractionValues = Array(
            stride(
                from: bounds.lowerBound,
                through: bounds.upperBound,
                by: step
            )
        )
    }
}

#warning("breaks on rotation")

struct SliderView: View {
    @Binding var value: Double
    let configuration: SliderConfiguration
    
    var body: some View {
        ZStack(alignment: .top) {
            GeometryReader { geometry in
                SliderScrollReader(configuration: configuration, frameWidth: geometry.size.width, value: $value) {
                    HStack(alignment: .top, spacing: 0) {
                        ForEach(configuration.fractionValues, id: \.self) { fractionValue in
                            let isCeil: Bool = fractionValue.truncatingRemainder(dividingBy: 1) == 0
                            
                            VStack(spacing: 0) {
                                Capsule()
                                    .fill(.gray)
                                    .frame(width: isCeil ? 3 : 1, height: 20)
                                
                                if isCeil {
                                    Text("\(Int(fractionValue))")
                                        .font(.caption2)
                                        .foregroundColor(.gray)
                                        .frame(height: 20)
                                }
                            }
                            .frame(width: configuration.spacing)
                        }
                    }
                }
            }
            .frame(height: 40)
            .padding(.top, 10)
            
            Capsule()
                .foregroundColor(.accentColor)
                .frame(width: 3, height: 30)
        }.mask(
            LinearGradient(
                gradient: Gradient(colors: [.clear, .black, .clear]),
                startPoint: .leading,
                endPoint: .trailing)
        )
    }
}


fileprivate struct SliderScrollReader<Content: View> : UIViewRepresentable {
    let configuration: SliderConfiguration
    var content: Content
    var frameWidth: CGFloat
    
    @State var offset: CGFloat
    @Binding var value: Double
    
    init(configuration: SliderConfiguration, frameWidth: CGFloat, value: Binding<Double>, @ViewBuilder content: @escaping () -> Content) {
        self.configuration = configuration
        self.content = content()
        self.frameWidth = frameWidth
        
        self._offset = State(
            initialValue: (value.wrappedValue - configuration.bounds.lowerBound) *
            configuration.spacing * (1.0 / configuration.step)
        )
        self._value = value
    }
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView: UIScrollView = UIScrollView()
        let swiftUIView: UIView = UIHostingController(rootView: content).view!
        let width: CGFloat = CGFloat(configuration.fractionValues.count - 1) * configuration.spacing + frameWidth
        
        swiftUIView.frame = CGRect(x: 0, y: 0, width: width, height: 40)
        swiftUIView.backgroundColor = .clear
        scrollView.contentSize = swiftUIView.frame.size
        scrollView.addSubview(swiftUIView)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = context.coordinator
        
        scrollView.setContentOffset(CGPoint(x: offset, y: 0), animated: true)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) { }
}

extension SliderScrollReader {
    func makeCoordinator() -> Coordinator {
        return SliderScrollReader.Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        var parent: SliderScrollReader
        
        init(parent: SliderScrollReader) { self.parent = parent }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) { updateValue(offset: scrollView.contentOffset.x) }
        
        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        }
        
        func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) { alignScrollViewOffset(scrollView) }

        func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
            if !decelerate { alignScrollViewOffset(scrollView) }
        }
        
        private func alignScrollViewOffset(_ scrollView: UIScrollView) {
            
            // --- Set value equal to nearest fraction ---
            
            // let scrollOffset: CGFloat = scrollView.contentOffset.x
            // let value: CGFloat = (offset / parent.configuration.spacing).rounded(.toNearestOrAwayFromZero)
            // scrollView.setContentOffset(CGPoint(x: value * parent.configuration.spacing, y: 0), animated: true)
            
            // --- Set value equal to last triggered fraction ---
            
            let configuration: SliderConfiguration = parent.configuration
            scrollView.setContentOffset(
                CGPoint(
                    x: (parent.value - configuration.bounds.lowerBound) *
                    configuration.spacing * (1.0 / configuration.step),
                    y: 0
                ),
                animated: true
            )
        }
        
        private func updateValue(offset: CGFloat) {
            let configuration: SliderConfiguration = parent.configuration
            
            let value: CGFloat = CGFloat(configuration.bounds.lowerBound) +
            offset / configuration.spacing / (1.0 / configuration.step)
            
            let valuesRange: ClosedRange<CGFloat> = parent.value < value ? parent.value...value : value...parent.value
            
            if valuesRange.lowerBound < configuration.bounds.lowerBound {
                if parent.value != configuration.bounds.lowerBound {
                    generateSelectionFeedback()
                    parent.value = configuration.bounds.lowerBound
                }
            } else if valuesRange.upperBound > configuration.bounds.upperBound {
                if parent.value != configuration.bounds.upperBound {
                    generateSelectionFeedback()
                    parent.value = configuration.bounds.upperBound
                }
            } else {
                for fractionValue in configuration.fractionValues {
                    if parent.value != fractionValue {
                        if valuesRange.contains(fractionValue) {
                            generateSelectionFeedback()
                            parent.value = fractionValue
                            return
                        }
                    }
                }
            }
        }
        
        private func generateSelectionFeedback() {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

