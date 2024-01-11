//
//  Bottom Sheet.swift
//  CupTaster
//
//  Created by Nikita on 09.01.2024.
//

import SwiftUI

struct BottomSheetConfiguration {
    static let spacing: CGFloat = .large
    static let verticalPadding: CGFloat = .extraSmall
    
    // Capsule Section
    struct Capsule {
        static let width: CGFloat = 40
        static let height: CGFloat = 5
    }
}

struct SheetModifier<SheetContent: View>: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    @State private var bottomSheetOffset: CGFloat = 0
    @Binding var isActive: Bool
    let sheetContent: () -> SheetContent
    
    init(isActive: Binding<Bool>, content: @escaping () -> SheetContent) {
        self._isActive = isActive
        self.sheetContent = content
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(Color.black.opacity(colorScheme == .dark ? 0.75 : 0.25).opacity(isActive ? 1 : 0))
            .fullScreenCover(isPresented: $isActive) {
                GeometryReader { geometry in
                    VStack(spacing: BottomSheetConfiguration.spacing) {
                        Capsule()
                            .fill(Color.gray.opacity(0.5))
                            .frame(
                                width: BottomSheetConfiguration.Capsule.width,
                                height: BottomSheetConfiguration.Capsule.height
                            )
                        
                        sheetContent()
                    }
                    .padding(.vertical, BottomSheetConfiguration.verticalPadding)
                    .frame(maxWidth: .infinity)
                    .background(alignment: .top) {
                        Color.background
                            .frame(height: geometry.frame(in: .global).height * 2, alignment: .top)
                    }
                    .offset(y: bottomSheetOffset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .background(
                    CustomModalBackgroundColorView(backgroundColor: .clear)
                        .onTapGesture { isActive = false }
                )
                .dragGesture(
                    gestureType: .simultaneous,
                    direction: .vertical,
                    onUpdate: { value in
                        let translation: CGFloat = value.translation.height
                        if translation > 0 {
                            bottomSheetOffset = translation
                        } else {
                            let additionalOffset: CGFloat = -sqrt(-translation)
                            bottomSheetOffset = 0 + additionalOffset
                        }
                    }, onEnd: { value in
                        withAnimation(.bouncy) {
                            isActive = value.translation.height < 150
                            bottomSheetOffset = 0
                        }
                    }, onCancel: {
                        withAnimation(.bouncy) {
                            bottomSheetOffset = 0
                        }
                    }
                )
            }
            .animation(.spring(), value: isActive)
    }
}

extension View {
    func adaptiveSizeSheet<SheetContent: View>(
        isActive: Binding<Bool>,
        content: @escaping () -> SheetContent
    ) -> some View {
        return modifier(SheetModifier(isActive: isActive, content: content))
    }
}

private struct CustomModalBackgroundColorView: UIViewRepresentable {
    let backgroundColor: UIColor
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = backgroundColor
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) { }
}
