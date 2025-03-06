//
//  Bottom Sheet.swift
//  CupTaster
//
//  Created by Nikita on 09.01.2024.
//

import SwiftUI
import Combine

struct BottomSheetConfiguration {
    static let spacing: CGFloat = .regular
    static let verticalPadding: CGFloat = .small
    
    struct Capsule {
        static let width: CGFloat = 40
        static let height: CGFloat = 5
    }
}

struct SheetModifier<SheetContent: View>: ViewModifier {
    @State private var bottomSheetOffset: CGFloat = 0
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent
    
    init(isPresented: Binding<Bool>, content: @escaping () -> SheetContent) {
        self._isPresented = isPresented
        self.sheetContent = content
    }
    
    func body(content: Content) -> some View {
        content
            .fullScreenCover(isPresented: $isPresented) {
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
                        Color.backgroundPrimary
                            .frame(height: geometry.frame(in: .global).height * 2, alignment: .top)
                    }
                    .offset(y: bottomSheetOffset)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .background(
                    ClearModalBackground(isPresented: $isPresented)
                        .onTapGesture { isPresented = false }
                )
                .dragGesture(
                    gestureType: .highPriority,
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
                            isPresented = value.translation.height < 150
                            bottomSheetOffset = 0
                        }
                    }, onCancel: {
                        withAnimation(.bouncy) {
                            bottomSheetOffset = 0
                        }
                    }
                )
            }
            .animation(.spring(), value: isPresented)
    }
}

extension View {
    func adaptiveSizeSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        content: @escaping () -> SheetContent
    ) -> some View {
        return modifier(SheetModifier(isPresented: isPresented, content: content))
    }
}

struct ClearModalBackground: UIViewRepresentable {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresented: Bool
    
    @State var sheetBackground: UIView?
    @State var contentOverlay: UIView?
    let backgroundOpacity: CGFloat?
    
    init(isPresented: Binding<Bool>, backgroundOpacity: CGFloat? = nil) {
        self._isPresented = isPresented
        self.backgroundOpacity = backgroundOpacity
    }
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            sheetBackground = view.superview?.superview
            contentOverlay = view.superview?.superview?.superview
            sheetBackground?.backgroundColor = .clear
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        var bgOpacity: CGFloat {
            if let backgroundOpacity { return backgroundOpacity }
            else {
                if colorScheme == .dark { return 0.75 }
                else { return 0.5 }
            }
        }
        UIView.animate(withDuration: 0.3) {
            contentOverlay?.backgroundColor = UIColor(Color.black.opacity(bgOpacity).opacity(isPresented ? 1 : 0))
        }
    }
}
